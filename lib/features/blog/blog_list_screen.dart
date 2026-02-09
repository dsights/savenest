import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meta_seo/meta_seo.dart';
import 'package:flutter/foundation.dart';
import '../../theme/app_theme.dart';
import '../../widgets/main_navigation_bar.dart';
import '../../widgets/main_mobile_drawer.dart';
import 'blog_provider.dart';
import 'widgets/blog_card.dart';

class BlogListScreen extends ConsumerWidget {
  const BlogListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(blogPostsProvider);

    if (kIsWeb) {
      MetaSEO meta = MetaSEO();
      meta.nameContent(name: 'title', content: 'SaveNest Blog | Money Saving Tips & Insights');
      meta.nameContent(name: 'description', content: 'Read the latest insights on how to save on electricity, internet, mobile plans, and insurance in Australia.');
      meta.ogTitle(ogTitle: 'SaveNest Blog | Money Saving Tips & Insights');
    }

    return Scaffold(
      backgroundColor: AppTheme.deepNavy,
      endDrawer: const MainMobileDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const MainNavigationBar(),
            const SizedBox(height: 40),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'SaveNest Blog',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Latest insights and tips to help you save on your household bills.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 48),
                      postsAsync.when(
                        data: (posts) {
                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 400,
                              childAspectRatio: 0.85,
                              crossAxisSpacing: 24,
                              mainAxisSpacing: 24,
                            ),
                            itemCount: posts.length,
                            itemBuilder: (context, index) {
                              final post = posts[index];
                              return BlogCard(
                                post: post,
                                onTap: () => context.go('/blog/${post.slug}'),
                              );
                            },
                          );
                        },
                        loading: () => const Center(
                          child: CircularProgressIndicator(color: AppTheme.vibrantEmerald),
                        ),
                        error: (err, stack) => Center(
                          child: Text(
                            'Failed to load blog posts: $err',
                            style: const TextStyle(color: Colors.white54),
                          ),
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
      ),
    );
  }
}