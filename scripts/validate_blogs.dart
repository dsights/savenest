import 'dart:io';
import 'dart:convert';

const int kMinWordCount = 2500;

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
    print('Quality gate: imageUrl present + image file exists + content >= $kMinWordCount words');
    print('');

    int issues = 0;
    final missingImages = <String>[];
    final shortPosts = <String>[];

    for (var i = 0; i < posts.length; i++) {
      final post = posts[i];
      final id = post['id']?.toString() ?? 'post_$i';
      final title = post['title']?.toString() ?? '(no title)';
      final img = post['imageUrl']?.toString() ?? '';
      final thumb = post['thumbnailUrl']?.toString() ?? '';
      final body = post['content']?.toString() ?? '';

      // 1. imageUrl present
      if (img.isEmpty) {
        print('FAIL [$id] "$title" — missing imageUrl');
        missingImages.add(id);
        issues++;
      } else {
        // 2. Local image file exists on disk
        if (img.startsWith('assets/')) {
          final imgFile = File(img);
          if (!imgFile.existsSync()) {
            print('FAIL [$id] "$title" — image file not found on disk: $img');
            missingImages.add(id);
            issues++;
          }
        }
      }

      // 3. thumbnailUrl present
      if (thumb.isEmpty) {
        print('FAIL [$id] "$title" — missing thumbnailUrl');
        issues++;
      }

      // 4. Content present
      if (body.isEmpty) {
        print('FAIL [$id] "$title" — missing content');
        issues++;
        continue;
      }

      // 5. Word count >= 2500 (strip HTML tags first)
      final stripped = body
          .replaceAll(RegExp(r'<[^>]+>'), ' ')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();
      final wordCount = stripped.isEmpty ? 0 : stripped.split(' ').length;
      if (wordCount < kMinWordCount) {
        final gap = kMinWordCount - wordCount;
        print('FAIL [$id] "$title" — $wordCount words ($gap short of $kMinWordCount)');
        shortPosts.add(id);
        issues++;
      }
    }

    print('');
    print('─────────────────────────────────────────');
    if (issues == 0) {
      print('✓ All ${posts.length} blog posts pass quality checks.');
    } else {
      print('✗ Found $issues issue(s) across ${posts.length} posts.');
      if (missingImages.isNotEmpty) {
        print('  Missing/broken images: ${missingImages.length} posts');
      }
      if (shortPosts.isNotEmpty) {
        print('  Under $kMinWordCount words: ${shortPosts.length} posts');
      }
      exit(1);
    }
  } catch (e) {
    print('JSON Error: $e');
    exit(1);
  }
}
