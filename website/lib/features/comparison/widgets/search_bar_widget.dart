import 'package:flutter/material.dart';
import '../../../widgets/glass_container.dart';
import '../../../theme/app_theme.dart';

class SearchBarWidget extends StatefulWidget {
  final Function(String) onChanged;
  final Function(String?)? onStateChanged;
  final String? selectedState;
  final String? hintText;
  final List<String>? suggestions;

  const SearchBarWidget({
    super.key,
    required this.onChanged,
    this.onStateChanged,
    this.selectedState,
    this.hintText,
    this.suggestions,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final TextEditingController _controller = TextEditingController();

  void _onSuggestionTap(String keyword) {
    setState(() {
      if (_controller.text.isEmpty) {
        _controller.text = keyword;
      } else if (!_controller.text.contains(keyword)) {
        _controller.text = '${_controller.text} $keyword';
      }
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
        if (widget.suggestions != null && widget.suggestions!.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: widget.suggestions!.map((s) => InkWell(
              onTap: () => _onSuggestionTap(s),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.1)),
                ),
                child: Text(
                  s,
                  style: const TextStyle(
                    color: AppTheme.primaryBlue,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )).toList(),
          ),
        ],
      ],
    );
  }
}
