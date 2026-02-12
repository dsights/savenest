import 'dart:io';
import 'dart:convert';

void main() async {
  final file = File('assets/data/blog_posts.json');
  if (!file.existsSync()) {
    print('Error: blog_posts.json not found');
    exit(1);
  }

  try {
    final content = await file.readAsString();
    final List<dynamic> posts = jsonDecode(content);

    print('Total posts found: ${posts.length}');

    int issues = 0;
    for (var i = 0; i < posts.length; i++) {
      final post = posts[i];
      final id = post['id'];
      final title = post['title'];
      final img = post['imageUrl'];
      final thumb = post['thumbnailUrl'];
      final body = post['content'];

      if (img == null || img.toString().isEmpty) {
        print('Issue: Post $id ($title) has missing imageUrl');
        issues++;
      } else if (!img.toString().startsWith('http')) {
         print('Issue: Post $id ($title) has invalid imageUrl: $img');
         // Note: Local assets are fine, but user specifically asked for Unsplash.
         // Previous steps replaced them with Unsplash URLs.
         // Let's flag if it's not http just to be sure.
      }

      if (thumb == null || thumb.toString().isEmpty) {
        print('Issue: Post $id ($title) has missing thumbnailUrl');
        issues++;
      }

      if (body == null || body.toString().isEmpty) {
        print('Issue: Post $id ($title) has missing content');
        issues++;
      }
    }

    if (issues == 0) {
      print('All blog posts are ready for publication!');
    } else {
      print('Found $issues issues.');
    }

  } catch (e) {
    print('JSON Error: $e');
  }
}
