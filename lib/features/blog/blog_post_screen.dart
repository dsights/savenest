import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta_seo/meta_seo.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart'; // Import this properly
import '../../theme/app_theme.dart';
import 'blog_provider.dart';
import 'blog_model.dart';
import 'package:go_router/go_router.dart';

class BlogPostScreen extends ConsumerWidget {
  final String postId;

  const BlogPostScreen({super.key, required this.postId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(blogPostsProvider);

    return Scaffold(
      backgroundColor: AppTheme.deepNavy,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(
          color: Colors.white,
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
      ),
      body: postsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.vibrantEmerald)),
        error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.white))),
        data: (posts) {
          final post = posts.firstWhere(
            (p) => p.id == postId,
            orElse: () => BlogPost(
              id: '404',
              title: 'Post Not Found',
              category: 'Error',
              author: 'System',
              date: '',
              imageUrl: 'assets/images/energy.png',
              thumbnailUrl: 'assets/images/energy.png',
              summary: 'The requested post could not be found.',
              content: 'Please check the URL or go back to the home page.',
            ),
          );

          // SEO Meta Tags
          if (kIsWeb) {
            MetaSEO().author(author: post.author);
            MetaSEO().description(description: post.summary);
            MetaSEO().keywords(keywords: '${post.category}, comparison, Australia, savings, ${post.title}');
            MetaSEO().ogTitle(ogTitle: post.title);
            MetaSEO().ogDescription(ogDescription: post.summary);
            // In a real app, this should be a full URL
             MetaSEO().ogImage(ogImage: 'https://savenest.au/${post.imageUrl}');
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // Header Image
                SizedBox(
                  height: 400, // Taller header for blog
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      post.imageUrl.startsWith('http')
                          ? Image.network(post.imageUrl, fit: BoxFit.cover)
                          : Image.asset(post.imageUrl, fit: BoxFit.cover),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              AppTheme.deepNavy.withOpacity(0.5),
                              AppTheme.deepNavy,
                            ],
                          ),
                        ),
                      ),
                      // Title on Image
                      Positioned(
                        bottom: 40,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 800),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppTheme.vibrantEmerald,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      post.category.toUpperCase(),
                                      style: const TextStyle(
                                        color: AppTheme.deepNavy,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    post.title,
                                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      height: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      const CircleAvatar(
                                        backgroundColor: Colors.white24,
                                        radius: 16,
                                        child: Icon(Icons.person, color: Colors.white, size: 20),
                                      ),
                                      const SizedBox(width: 12),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(post.author, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                          Text(post.date, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           // Summary Box
                           Container(
                             padding: const EdgeInsets.all(24),
                             decoration: BoxDecoration(
                               color: Colors.white.withOpacity(0.05),
                               borderRadius: BorderRadius.circular(16),
                               border: Border.all(color: Colors.white10),
                             ),
                             child: Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                 const Text("KEY TAKEAWAYS", style: TextStyle(color: AppTheme.vibrantEmerald, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                                 const SizedBox(height: 12),
                                 Text(
                                   post.summary,
                                   style: const TextStyle(color: Colors.white, fontSize: 18, fontStyle: FontStyle.italic, height: 1.6),
                                 ),
                               ],
                             ),
                           ),
                           const SizedBox(height: 40),
                          
                          // Main Body
                          HtmlWidget(
                            post.content,
                            textStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              height: 1.8,
                              fontFamily: 'Georgia',
                            ),
                            customStylesBuilder: (element) {
                              if (element.localName == 'h2') {
                                return {'color': '#00C853', 'margin-top': '2em', 'margin-bottom': '1em', 'font-weight': 'bold'};
                              }
                              if (element.localName == 'strong') {
                                return {'color': '#FFFFFF', 'font-weight': 'bold'};
                              }
                              if (element.localName == 'li') {
                                return {'margin-bottom': '0.5em'};
                              }
                              return null;
                            },
                          ),
                          
                          const SizedBox(height: 80),
                          
                          // CTA
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(40),
                            decoration: BoxDecoration(
                              gradient: AppTheme.mainBackgroundGradient,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  "Stop overpaying today.",
                                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton(
                                  onPressed: () {
                                    context.go('/savings');
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: AppTheme.deepNavy,
                                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                                  ),
                                  child: const Text("COMPARE NOW"),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
