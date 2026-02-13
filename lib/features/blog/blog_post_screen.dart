import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta_seo/meta_seo.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart'; // Import this properly
import '../../theme/app_theme.dart';
import 'blog_provider.dart';
import 'blog_model.dart';
import 'package:go_router/go_router.dart';

import '../../widgets/main_navigation_bar.dart';
import '../../widgets/main_mobile_drawer.dart';

class BlogPostScreen extends ConsumerWidget {
  final String slug;

  const BlogPostScreen({super.key, required this.slug});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(blogPostsProvider);

    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      endDrawer: const MainMobileDrawer(),
      body: postsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.vibrantEmerald)),
        error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: AppTheme.deepNavy))),
        data: (posts) {
          final post = posts.firstWhere(
            (p) => p.slug == slug,
            orElse: () => BlogPost(
              id: '404',
              slug: 'not-found',
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
            final absoluteImageUrl = post.imageUrl.startsWith('http') 
                ? post.imageUrl 
                : 'https://savenest.au/assets/${post.imageUrl}';
            
            MetaSEO().author(author: post.author);
            MetaSEO().description(description: post.summary);
            MetaSEO().keywords(keywords: '${post.category}, comparison, Australia, savings, ${post.title}');
            
            // Open Graph / Facebook
            MetaSEO().ogTitle(ogTitle: post.title);
            MetaSEO().ogDescription(ogDescription: post.summary);
            MetaSEO().ogImage(ogImage: absoluteImageUrl);
            MetaSEO().propertyContent(property: 'og:type', content: 'article');
            MetaSEO().propertyContent(property: 'og:url', content: 'https://savenest.au/blog/${post.slug}');
            
            // Twitter
            MetaSEO().nameContent(name: 'twitter:card', content: 'summary_large_image');
            MetaSEO().nameContent(name: 'twitter:title', content: post.title);
            MetaSEO().nameContent(name: 'twitter:description', content: post.summary);
            MetaSEO().nameContent(name: 'twitter:image', content: absoluteImageUrl);
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                const MainNavigationBar(),
                // Back Button Row
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: TextButton.icon(
                        onPressed: () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go('/blog');
                          }
                        },
                        icon: const Icon(Icons.arrow_back, color: AppTheme.vibrantEmerald),
                        label: Text('Back to Blog', style: TextStyle(color: AppTheme.deepNavy.withOpacity(0.7))),
                      ),
                    ),
                  ),
                ),
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
                               color: Colors.black.withOpacity(0.05),
                               borderRadius: BorderRadius.circular(16),
                               border: Border.all(color: Colors.black12),
                             ),
                             child: Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                 const Text("KEY TAKEAWAYS", style: TextStyle(color: AppTheme.vibrantEmerald, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                                 const SizedBox(height: 12),
                                 Text(
                                   post.summary,
                                   style: const TextStyle(color: AppTheme.deepNavy, fontSize: 18, fontStyle: FontStyle.italic, height: 1.6),
                                 ),
                               ],
                             ),
                           ),
                           const SizedBox(height: 40),
                          
                          // Main Body
                          HtmlWidget(
                            post.content,
                            textStyle: const TextStyle(
                              color: AppTheme.deepNavy,
                              fontSize: 18,
                              height: 1.8,
                              fontFamily: 'Georgia',
                            ),
                            customStylesBuilder: (element) {
                              if (element.localName == 'h2') {
                                return {'color': '#00C853', 'margin-top': '2em', 'margin-bottom': '1em', 'font-weight': 'bold'};
                              }
                              if (element.localName == 'strong') {
                                return {'color': '#0A0E21', 'font-weight': 'bold'};
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
                                  "Calculate your potential savings today.",
                                  style: TextStyle(color: AppTheme.deepNavy, fontSize: 24, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton(
                                  onPressed: () {
                                    context.go('/savings');
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.deepNavy,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                                  ),
                                  child: const Text("USE SAVINGS CALCULATOR"),
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
