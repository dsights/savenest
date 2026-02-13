import 'package:flutter/material.dart';
import '../../../widgets/glass_container.dart';

class SearchBarWidget extends StatelessWidget {
  final Function(String) onChanged;
  final String? hintText;

  const SearchBarWidget({
    super.key,
    required this.onChanged,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      borderRadius: 12,
      child: TextField(
        onChanged: onChanged,
        style: const TextStyle(color: Colors.black87),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText ?? 'Search providers, features, e.g. "solar", "AGL"...',
          hintStyle: const TextStyle(color: Colors.black38),
          icon: const Icon(Icons.search, color: Colors.black38),
        ),
      ),
    );
  }
}
