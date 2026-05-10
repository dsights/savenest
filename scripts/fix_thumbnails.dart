import 'dart:io';
import 'dart:convert';

void main() async {
  final file = File('assets/data/blog_posts.json');
  final content = await file.readAsString();
  List<dynamic> posts = jsonDecode(content);
  bool changed = false;

  for (var post in posts) {
    if (post['thumbnailUrl'] == null || post['thumbnailUrl'].toString().isEmpty) {
      if (post['imageUrl'] != null) {
        String img = post['imageUrl'];
        post['thumbnailUrl'] = img.replaceAll('w=800', 'w=400');
        print('Fixed thumbnail for ${post['id']}');
        changed = true;
      }
    }
  }

  if (changed) {
    await file.writeAsString(jsonEncode(posts));
    print('Saved fixes.');
  } else {
    print('No fixes needed.');
  }
}
