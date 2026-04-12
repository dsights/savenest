import 'package:flutter/material.dart';
import '../../../widgets/glass_container.dart';
import '../../../theme/app_theme.dart';

class SearchBarWidget extends StatefulWidget {
  final Function(String) onChanged;
  final Function(String?)? onStateChanged;
  final String? selectedState;
  final String? hintText;
  final Map<String, List<String>>? filters;

  const SearchBarWidget({
    super.key,
    required this.onChanged,
    this.onStateChanged,
    this.selectedState,
    this.hintText,
    this.filters,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final TextEditingController _controller = TextEditingController();

  void _onFilterTap(String keyword) {
    setState(() {
      final currentText = _controller.text.trim();
      final newText = currentText.isEmpty ? keyword : '$currentText $keyword';
      _controller.text = newText;
      _controller.selection = TextSelection.fromPosition(TextPosition(offset: _controller.text.length));
    });
    widget.onChanged(_controller.text);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            // State Selector
            if (widget.onStateChanged != null)
              Container(
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
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: widget.selectedState,
                    hint: const Text('State', style: TextStyle(fontSize: 14, color: Colors.black38)),
                    style: const TextStyle(color: AppTheme.deepNavy, fontWeight: FontWeight.bold, fontSize: 14),
                    icon: const Icon(Icons.location_on_outlined, size: 18, color: AppTheme.primaryBlue),
                    items: ['NSW', 'VIC', 'QLD', 'SA', 'WA', 'ACT', 'TAS', 'NT']
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: widget.onStateChanged,
                  ),
                ),
              ),
            
            // Search Input
            Expanded(
              child: GlassContainer(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                borderRadius: 12,
                child: TextField(
                  controller: _controller,
                  onChanged: widget.onChanged,
                  style: const TextStyle(color: Colors.black87),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: widget.hintText ?? 'Search providers, features...',
                    hintStyle: const TextStyle(color: Colors.black38),
                    icon: const Icon(Icons.search, color: Colors.black38),
                    suffixIcon: _controller.text.isNotEmpty 
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _controller.clear();
                            widget.onChanged('');
                            setState(() {});
                          },
                        )
                      : null,
                  ),
                ),
              ),
            ),
          ],
        ),
        if (widget.filters != null && widget.filters!.isNotEmpty) ...[
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: widget.filters!.entries.map((entry) {
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.slate300.withOpacity(0.5)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      hint: Text(entry.key, style: const TextStyle(fontSize: 13, color: AppTheme.slate600, fontWeight: FontWeight.w600)),
                      style: const TextStyle(color: AppTheme.deepNavy, fontWeight: FontWeight.bold, fontSize: 13),
                      icon: const Icon(Icons.arrow_drop_down, size: 20, color: AppTheme.primaryBlue),
                      items: entry.value
                          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          _onFilterTap(value);
                        }
                      },
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }
}
