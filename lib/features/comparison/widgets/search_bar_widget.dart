import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../../../widgets/glass_container.dart';
import '../../../theme/app_theme.dart';
import '../comparison_model.dart';

class SearchBarWidget extends StatefulWidget {
  final Function(String) onChanged;
  final Function(String?)? onStateChanged;
  final String? selectedState;
  final String? hintText;
  final Map<String, List<String>>? filters;
  final Set<String> activeFilters;
  final Function(String)? onFilterToggle;
  final VoidCallback? onClearAllFilters;
  final SortMode sortMode;
  final Function(SortMode)? onSortChanged;
  final double categoryMaxPrice;
  final double? filterPriceMax;
  final Function(double?)? onPriceMaxChanged;
  final List<String> suggestions;

  const SearchBarWidget({
    super.key,
    required this.onChanged,
    this.onStateChanged,
    this.selectedState,
    this.hintText,
    this.filters,
    this.activeFilters = const {},
    this.onFilterToggle,
    this.onClearAllFilters,
    this.sortMode = SortMode.defaultSort,
    this.onSortChanged,
    this.categoryMaxPrice = 0,
    this.filterPriceMax,
    this.onPriceMaxChanged,
    this.suggestions = const [],
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _searchRowKey = GlobalKey();
  final ValueNotifier<List<String>> _suggestionNotifier = ValueNotifier([]);

  bool _isUploading = false;
  Timer? _debounce;
  OverlayEntry? _overlayEntry;
  final Map<String, String?> _activeFiltersByCategory = {};

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(SearchBarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.activeFilters.isEmpty && oldWidget.activeFilters.isNotEmpty) {
      _activeFiltersByCategory.clear();
    }
    // Refresh suggestions if the pool changed
    if (widget.suggestions != oldWidget.suggestions) {
      _suggestionNotifier.value = _matchingSuggestions(_controller.text);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _hideOverlay();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    _suggestionNotifier.dispose();
    super.dispose();
  }

  // ── Autocomplete ────────────────────────────────────────────────

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      final matches = _matchingSuggestions(_controller.text);
      if (matches.isNotEmpty) _showOverlay();
    } else {
      // Delay so a suggestion tap registers before the overlay closes
      Future.delayed(const Duration(milliseconds: 180), () {
        if (mounted && !_focusNode.hasFocus) _hideOverlay();
      });
    }
  }

  List<String> _matchingSuggestions(String text) {
    final q = text.trim().toLowerCase();
    if (q.length < 2) return [];
    return widget.suggestions
        .where((s) {
          final lower = s.toLowerCase();
          return lower.contains(q) && lower != q;
        })
        .take(7)
        .toList();
  }

  void _showOverlay() {
    if (_overlayEntry != null) return;
    _overlayEntry = OverlayEntry(builder: (_) => _overlayWidget());
    Overlay.of(context, rootOverlay: true).insert(_overlayEntry!);
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Widget _overlayWidget() {
    return CompositedTransformFollower(
      link: _layerLink,
      targetAnchor: Alignment.bottomLeft,
      followerAnchor: Alignment.topLeft,
      showWhenUnlinked: false,
      offset: const Offset(0, 4),
      child: ValueListenableBuilder<List<String>>(
        valueListenable: _suggestionNotifier,
        builder: (context, suggestions, _) {
          if (suggestions.isEmpty) return const SizedBox.shrink();
          final box = _searchRowKey.currentContext?.findRenderObject() as RenderBox?;
          final width = box?.size.width ?? 400.0;
          return Material(
            elevation: 12,
            borderRadius: BorderRadius.circular(12),
            shadowColor: Colors.black.withOpacity(0.15),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: width, maxHeight: 300),
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: suggestions.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    color: AppTheme.slate300.withOpacity(0.4),
                  ),
                  itemBuilder: (context, i) => _SuggestionTile(
                    text: suggestions[i],
                    currentQuery: _controller.text,
                    onTap: () => _selectSuggestion(suggestions[i]),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _selectSuggestion(String suggestion) {
    _controller.text = suggestion;
    _controller.selection =
        TextSelection.fromPosition(TextPosition(offset: suggestion.length));
    // Fire search immediately — bypass the debounce timer for selections
    _debounce?.cancel();
    widget.onChanged(suggestion);
    _suggestionNotifier.value = [];
    _hideOverlay();
    _focusNode.unfocus();
    setState(() {});
  }

  // ── Text field ──────────────────────────────────────────────────

  void _onTextChanged(String value) {
    // Update suggestions immediately for visual feedback
    final matches = _matchingSuggestions(value);
    _suggestionNotifier.value = matches;
    if (matches.isNotEmpty && _focusNode.hasFocus) {
      _showOverlay();
    } else if (matches.isEmpty) {
      _hideOverlay();
    }

    // Debounce the actual search callback
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) widget.onChanged(value);
    });
    setState(() {});
  }

  // ── Filter chips ────────────────────────────────────────────────

  void _onFilterSelect(String category, String newValue) {
    final oldValue = _activeFiltersByCategory[category];
    if (oldValue == newValue) {
      setState(() => _activeFiltersByCategory.remove(category));
      widget.onFilterToggle?.call(newValue);
    } else {
      if (oldValue != null) widget.onFilterToggle?.call(oldValue);
      setState(() => _activeFiltersByCategory[category] = newValue);
      widget.onFilterToggle?.call(newValue);
    }
  }

  // ── OCR ─────────────────────────────────────────────────────────

  Future<void> _pickAndUploadBill() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    setState(() => _isUploading = true);
    try {
      final bytes = await image.readAsBytes();
      final data = await _tryOcr('/ocr', bytes, image.name) ??
          await _tryOcr('http://127.0.0.1:8000/ocr', bytes, image.name);
      if (data != null) {
        _handleOcrResult(data);
      } else {
        _showError('Could not process bill. Please search manually.');
      }
    } catch (e) {
      _showError('Error uploading bill: $e');
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<Map<String, dynamic>?> _tryOcr(
      String url, List<int> bytes, String filename) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(url));
      request.files.add(
          http.MultipartFile.fromBytes('file', bytes, filename: filename));
      final response = await request.send();
      if (response.statusCode != 200) return null;
      final decoded = jsonDecode(await response.stream.bytesToString());
      if (decoded['success'] == true) return decoded['data'] as Map<String, dynamic>?;
    } catch (_) {}
    return null;
  }

  void _handleOcrResult(Map<String, dynamic> data) {
    final provider = data['provider']?.toString();
    final rawText = data['raw_text']?.toString().toLowerCase() ?? '';
    if (provider != null && provider != 'Unknown Provider') {
      _controller.text = provider;
      _controller.selection =
          TextSelection.fromPosition(TextPosition(offset: provider.length));
      widget.onChanged(provider);
    }
    const stateAbbrs = ['nsw', 'vic', 'qld', 'sa', 'wa', 'act', 'tas', 'nt'];
    for (final s in stateAbbrs) {
      if (rawText.contains(s)) {
        widget.onStateChanged?.call(s.toUpperCase());
        break;
      }
    }
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Smart Scan Complete',
            style: TextStyle(
                color: AppTheme.vibrantEmerald, fontWeight: FontWeight.bold)),
        content: Text(
          (provider != null && provider != 'Unknown Provider')
              ? 'Detected provider: $provider. Showing alternative plans now.'
              : 'Bill uploaded. We couldn\'t identify a provider — please search manually.',
          style: const TextStyle(fontSize: 14),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('View Results',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.vibrantEmerald)),
          )
        ],
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  // ── Build ────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final hasActiveFilters =
        widget.activeFilters.isNotEmpty || widget.filterPriceMax != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Row 1: State + typeahead search field + OCR ───────────
        CompositedTransformTarget(
          link: _layerLink,
          child: Row(
            key: _searchRowKey,
            children: [
              if (widget.onStateChanged != null)
                _StateDropdown(
                  selectedState: widget.selectedState,
                  onStateChanged: widget.onStateChanged,
                ),

              Expanded(
                child: GlassContainer(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  borderRadius: 12,
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    onChanged: _onTextChanged,
                    style: const TextStyle(color: Colors.black87),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: widget.hintText ??
                          'Search providers, plans, features…',
                      hintStyle: const TextStyle(color: Colors.black38),
                      icon: const Icon(Icons.search, color: Colors.black38),
                      suffixIcon: _controller.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _controller.clear();
                                _suggestionNotifier.value = [];
                                _hideOverlay();
                                widget.onChanged('');
                                setState(() {});
                              },
                            )
                          : null,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),
              _OcrButton(
                isUploading: _isUploading,
                onTap: _isUploading ? null : _pickAndUploadBill,
              ),
            ],
          ),
        ),

        // ── Price range slider ────────────────────────────────────
        if (widget.categoryMaxPrice > 0) ...[
          const SizedBox(height: 10),
          _PriceSlider(
            categoryMaxPrice: widget.categoryMaxPrice,
            filterPriceMax: widget.filterPriceMax,
            onPriceMaxChanged: widget.onPriceMaxChanged,
          ),
        ],

        // ── Active filter chips ───────────────────────────────────
        if (hasActiveFilters) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              ...widget.activeFilters.map((f) => _ActiveChip(
                    label: f,
                    onRemove: () {
                      _activeFiltersByCategory.removeWhere((_, v) => v == f);
                      widget.onFilterToggle?.call(f);
                    },
                  )),
              if (widget.filterPriceMax != null)
                _ActiveChip(
                  label:
                      'Max \$${widget.filterPriceMax!.toStringAsFixed(0)}/mo',
                  onRemove: () => widget.onPriceMaxChanged?.call(null),
                ),
              if (hasActiveFilters &&
                  (widget.activeFilters.length > 1 ||
                      widget.filterPriceMax != null))
                ActionChip(
                  avatar:
                      const Icon(Icons.close, size: 14, color: Colors.red),
                  label: const Text('Clear all',
                      style: TextStyle(fontSize: 12, color: Colors.red)),
                  onPressed: () {
                    _activeFiltersByCategory.clear();
                    widget.onClearAllFilters?.call();
                  },
                  backgroundColor: Colors.red.withOpacity(0.08),
                  side: BorderSide(color: Colors.red.withOpacity(0.3)),
                ),
            ],
          ),
        ],

        // ── Row 2: Filter dropdowns + sort ────────────────────────
        if (widget.filters != null && widget.filters!.isNotEmpty) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: widget.filters!.entries.map((entry) {
                      final selected = _activeFiltersByCategory[entry.key];
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding:
                            const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: selected != null
                              ? AppTheme.vibrantEmerald.withOpacity(0.08)
                              : Colors.white.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selected != null
                                ? AppTheme.vibrantEmerald.withOpacity(0.5)
                                : AppTheme.slate300.withOpacity(0.5),
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            hint: Text(
                              selected ?? entry.key,
                              style: TextStyle(
                                fontSize: 13,
                                color: selected != null
                                    ? AppTheme.vibrantEmerald
                                    : AppTheme.slate600,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: const TextStyle(
                                color: AppTheme.deepNavy,
                                fontWeight: FontWeight.bold,
                                fontSize: 13),
                            icon: Icon(Icons.arrow_drop_down,
                                size: 20,
                                color: selected != null
                                    ? AppTheme.vibrantEmerald
                                    : AppTheme.primaryBlue),
                            items: entry.value
                                .map((s) => DropdownMenuItem(
                                      value: s,
                                      child: Row(children: [
                                        if (s == selected)
                                          const Padding(
                                            padding:
                                                EdgeInsets.only(right: 6),
                                            child: Icon(Icons.check,
                                                size: 14,
                                                color: AppTheme
                                                    .vibrantEmerald),
                                          ),
                                        Text(s),
                                      ]),
                                    ))
                                .toList(),
                            onChanged: (v) {
                              if (v != null) _onFilterSelect(entry.key, v);
                            },
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              _SortButton(
                sortMode: widget.sortMode,
                onSortChanged: widget.onSortChanged,
              ),
            ],
          ),
        ],
      ],
    );
  }
}

// ── Supporting widgets ───────────────────────────────────────────────

class _SuggestionTile extends StatelessWidget {
  final String text;
  final String currentQuery;
  final VoidCallback onTap;

  const _SuggestionTile({
    required this.text,
    required this.currentQuery,
    required this.onTap,
  });

  IconData get _icon {
    final lower = text.toLowerCase();
    if (lower.contains('nbn') || lower.contains('mbps') || lower.contains('internet')) {
      return Icons.wifi_outlined;
    }
    if (lower.contains('green') || lower.contains('solar') || lower.contains('eco')) {
      return Icons.eco_outlined;
    }
    if (lower.contains('cheap') || lower.contains('budget') || lower.contains('saver')) {
      return Icons.savings_outlined;
    }
    if (lower.contains('mobile') || lower.contains('prepaid') || lower.contains('gb')) {
      return Icons.phone_android_outlined;
    }
    return Icons.business_outlined;
  }

  // Highlight the matching substring in the suggestion label
  Widget _highlightedText(BuildContext context) {
    final q = currentQuery.trim().toLowerCase();
    final lower = text.toLowerCase();
    final idx = lower.indexOf(q);
    if (idx < 0 || q.isEmpty) {
      return Text(text,
          style: const TextStyle(fontSize: 14, color: AppTheme.deepNavy));
    }
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 14, color: AppTheme.deepNavy),
        children: [
          TextSpan(text: text.substring(0, idx)),
          TextSpan(
            text: text.substring(idx, idx + q.length),
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryBlue),
          ),
          TextSpan(text: text.substring(idx + q.length)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        child: Row(
          children: [
            Icon(_icon, size: 16, color: AppTheme.slate600),
            const SizedBox(width: 10),
            Expanded(child: _highlightedText(context)),
            const Icon(Icons.north_west, size: 12, color: AppTheme.slate300),
          ],
        ),
      ),
    );
  }
}

class _StateDropdown extends StatelessWidget {
  final String? selectedState;
  final Function(String?)? onStateChanged;

  const _StateDropdown({this.selectedState, this.onStateChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.slate300.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: selectedState,
          hint: const Text('State',
              style: TextStyle(fontSize: 14, color: Colors.black38)),
          style: const TextStyle(
              color: AppTheme.deepNavy,
              fontWeight: FontWeight.bold,
              fontSize: 14),
          icon: const Icon(Icons.location_on_outlined,
              size: 18, color: AppTheme.primaryBlue),
          items: [
            const DropdownMenuItem<String?>(
              value: null,
              child: Text('All States',
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                      fontWeight: FontWeight.normal)),
            ),
            ...['NSW', 'VIC', 'QLD', 'SA', 'WA', 'ACT', 'TAS', 'NT']
                .map((s) => DropdownMenuItem<String?>(value: s, child: Text(s))),
          ],
          onChanged: onStateChanged,
        ),
      ),
    );
  }
}

class _OcrButton extends StatelessWidget {
  final bool isUploading;
  final VoidCallback? onTap;

  const _OcrButton({required this.isUploading, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.vibrantEmerald, Color(0xFF00C853)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: AppTheme.vibrantEmerald.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4))
        ],
      ),
      child: IconButton(
        icon: isUploading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2))
            : const Icon(Icons.document_scanner, color: Colors.white),
        tooltip: 'Upload bill for instant provider match',
        onPressed: onTap,
      ),
    );
  }
}

class _ActiveChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const _ActiveChip({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return InputChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      deleteIcon: const Icon(Icons.close, size: 14),
      onDeleted: onRemove,
      backgroundColor: AppTheme.vibrantEmerald.withOpacity(0.1),
      deleteIconColor: AppTheme.vibrantEmerald,
      labelStyle: const TextStyle(
          color: AppTheme.deepNavy, fontWeight: FontWeight.w600),
      side: BorderSide(color: AppTheme.vibrantEmerald.withOpacity(0.5)),
      padding: const EdgeInsets.symmetric(horizontal: 2),
    );
  }
}

class _SortButton extends StatelessWidget {
  final SortMode sortMode;
  final Function(SortMode)? onSortChanged;

  const _SortButton({required this.sortMode, this.onSortChanged});

  String get _label {
    switch (sortMode) {
      case SortMode.priceAsc:
        return r'$ Low–High';
      case SortMode.priceDesc:
        return r'$ High–Low';
      case SortMode.ratingDesc:
        return 'Best Rated';
      case SortMode.defaultSort:
        return 'Sort';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isActive = sortMode != SortMode.defaultSort;
    return PopupMenuButton<SortMode>(
      tooltip: 'Sort results',
      onSelected: onSortChanged,
      itemBuilder: (context) => [
        _item(SortMode.defaultSort, Icons.auto_awesome, 'Default'),
        _item(SortMode.priceAsc, Icons.arrow_upward, 'Price: Low to High'),
        _item(SortMode.priceDesc, Icons.arrow_downward, 'Price: High to Low'),
        _item(SortMode.ratingDesc, Icons.star_outline, 'Best Rated'),
      ],
      child: Container(
        margin: const EdgeInsets.only(left: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isActive
              ? AppTheme.primaryBlue.withOpacity(0.1)
              : Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive
                ? AppTheme.primaryBlue.withOpacity(0.5)
                : AppTheme.slate300.withOpacity(0.5),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sort,
                size: 16,
                color: isActive ? AppTheme.primaryBlue : AppTheme.slate600),
            const SizedBox(width: 4),
            Text(_label,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isActive
                        ? AppTheme.primaryBlue
                        : AppTheme.slate600)),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<SortMode> _item(SortMode mode, IconData icon, String label) {
    return PopupMenuItem(
      value: mode,
      child: Row(children: [
        Icon(icon, size: 16, color: AppTheme.deepNavy),
        const SizedBox(width: 8),
        Text(label),
        if (sortMode == mode) ...[
          const Spacer(),
          const Icon(Icons.check, size: 14, color: AppTheme.vibrantEmerald),
        ],
      ]),
    );
  }
}

class _PriceSlider extends StatelessWidget {
  final double categoryMaxPrice;
  final double? filterPriceMax;
  final Function(double?)? onPriceMaxChanged;

  const _PriceSlider({
    required this.categoryMaxPrice,
    this.filterPriceMax,
    this.onPriceMaxChanged,
  });

  @override
  Widget build(BuildContext context) {
    final current = filterPriceMax ?? categoryMaxPrice;
    final isFiltered = filterPriceMax != null;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isFiltered
            ? AppTheme.primaryBlue.withOpacity(0.05)
            : Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isFiltered
              ? AppTheme.primaryBlue.withOpacity(0.3)
              : AppTheme.slate300.withOpacity(0.4),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.attach_money, size: 16, color: AppTheme.slate600),
          const SizedBox(width: 4),
          Text(
            isFiltered
                ? 'Max \$${current.toStringAsFixed(0)}/mo'
                : 'All prices',
            style: TextStyle(
              fontSize: 12,
              color: isFiltered ? AppTheme.primaryBlue : AppTheme.slate600,
              fontWeight: isFiltered ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          Expanded(
            child: Slider(
              min: 0,
              max: categoryMaxPrice,
              value: current.clamp(0, categoryMaxPrice),
              divisions: max(5, (categoryMaxPrice / 10).round().clamp(5, 40)),
              activeColor: AppTheme.vibrantEmerald,
              inactiveColor: AppTheme.slate300,
              onChanged: (val) {
                final atMax = val >= categoryMaxPrice - 0.5;
                onPriceMaxChanged?.call(atMax ? null : val);
              },
            ),
          ),
          if (isFiltered)
            GestureDetector(
              onTap: () => onPriceMaxChanged?.call(null),
              child: const Icon(Icons.close, size: 14, color: AppTheme.slate600),
            ),
        ],
      ),
    );
  }
}
