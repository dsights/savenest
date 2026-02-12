import 'dart:io';
import 'dart:convert';

void main() async {
  try {
    final file = File('assets/data/products.json');
    final content = await file.readAsString();
    jsonDecode(content);
    print('JSON is valid.');
  } catch (e) {
    print('JSON Error: $e');
    exit(1);
  }
}
