import 'package:flutter/material.dart';
import '../../../widgets/glass_container.dart';
import '../../../theme/app_theme.dart';

class SearchBarWidget extends StatefulWidget {
  final Function(String) onChanged;
  final String? hintText;
  final List<String>? suggestions;

  const SearchBarWidget({
    super.key,
    required this.onChanged,
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
        GlassContainer(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          borderRadius: 12,
          child: TextField(
            controller: _controller,
            onChanged: widget.onChanged,
            style: const TextStyle(color: Colors.black87),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: widget.hintText ?? 'Search providers, features, e.g. "solar", "AGL"...',
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
