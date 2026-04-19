import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
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
  bool _isUploading = false;

  void _onFilterTap(String keyword) {
    setState(() {
      final currentText = _controller.text.trim();
      final newText = currentText.isEmpty ? keyword : '$currentText $keyword';
      _controller.text = newText;
      _controller.selection = TextSelection.fromPosition(TextPosition(offset: _controller.text.length));
    });
    widget.onChanged(_controller.text);
  }

  Future<void> _pickAndUploadBill() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image == null) return;

    setState(() { _isUploading = true; });

    try {
      // Basic fallback to proxy API path or localhost depending on environment, assuming proxy API path is safest for web.
      // But for prototype running locally, we can try relative path /ocr or localhost.
      final uri = Uri.parse('/ocr'); 
      final request = http.MultipartRequest('POST', uri);
      
      // For web, readAsBytes is preferred over path. image_picker provides readAsBytes.
      final bytes = await image.readAsBytes();
      request.files.add(http.MultipartFile.fromBytes('file', bytes, filename: image.name));

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      
      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);
        if (data['success'] == true) {
           _showOcrResult(data['data']);
        } else {
           _showError('OCR returned failure');
        }
      } else {
        _showError('Failed to process bill. Status: ${response.statusCode}');
      }
    } catch (e) {
      // Fallback if relative URL fails (e.g. not on the same server)
      try {
        final uri = Uri.parse('http://127.0.0.1:8000/ocr');
        final request = http.MultipartRequest('POST', uri);
        final bytes = await image.readAsBytes();
        request.files.add(http.MultipartFile.fromBytes('file', bytes, filename: image.name));

        final response = await request.send();
        final responseBody = await response.stream.bytesToString();
        
        if (response.statusCode == 200) {
          final data = jsonDecode(responseBody);
          if (data['success'] == true) {
             _showOcrResult(data['data']);
          } else {
             _showError('OCR returned failure');
          }
        } else {
          _showError('Failed to process bill. Status: ${response.statusCode}');
        }
      } catch (innerE) {
        _showError('Error uploading bill: $innerE');
      }
    } finally {
      if (mounted) setState(() { _isUploading = false; });
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  void _showOcrResult(dynamic data) {
    if (!mounted) return;
    
    // Attempt to format or stringify data beautifully
    String displayText = '';
    if (data is Map) {
      data.forEach((key, value) {
        displayText += '$key: $value\n';
      });
    } else {
      displayText = data.toString();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Smart Scan Result', style: TextStyle(color: AppTheme.vibrantEmerald, fontWeight: FontWeight.bold)),
        content: Text('Extracted Data:\n\n$displayText\n\nWe will use this data to find your best plan soon!', style: const TextStyle(fontSize: 14)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.deepNavy)),
          )
        ]
      )
    );
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
            const SizedBox(width: 12),
            Container(
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
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: IconButton(
                icon: _isUploading 
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.document_scanner, color: Colors.white),
                tooltip: 'Upload Bill for AI Match',
                onPressed: _isUploading ? null : _pickAndUploadBill,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (widget.filters != null && widget.filters!.isNotEmpty)
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
    );
  }
}
