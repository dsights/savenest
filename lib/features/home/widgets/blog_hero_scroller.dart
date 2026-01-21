import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_theme.dart';
import '../../blog/blog_model.dart';
import '../../blog/blog_provider.dart';
import '../../blog/blog_post_screen.dart';

class BlogHeroScroller extends ConsumerStatefulWidget {
  const BlogHeroScroller({super.key});

  @override
  ConsumerState<BlogHeroScroller> createState() => _BlogHeroScrollerState();
}

class _BlogHeroScrollerState extends ConsumerState<BlogHeroScroller> {
  final PageController _pageController = PageController();
  Timer? _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_pageController.hasClients) {
        _currentPage++;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final postsAsync = ref.watch(blogPostsProvider);

    return postsAsync.when(
      data: (posts) {
        if (posts.isEmpty) return const SizedBox.shrink();

        return Column(
          children: [
            SizedBox(
              height: 400,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final post = posts[index % posts.length];
                  return _buildHeroItem(post);
                },
              ),
            ),
            const SizedBox(height: 20),
            _buildPageIndicator(posts.length),
          ],
        );
      },
      loading: () => const SizedBox(
        height: 400,
        child: Center(child: CircularProgressIndicator(color: AppTheme.vibrantEmerald)),
      ),
      error: (err, stack) => const SizedBox.shrink(),
    );
  }

  Widget _buildHeroItem(BlogPost post) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => BlogPostScreen(post: post)),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          image: DecorationImage(
            image: AssetImage(post.imageUrl),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.4),
              BlendMode.darken,
            ),
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.8),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.vibrantEmerald,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      post.category.toUpperCase(),
                      style: const TextStyle(
                        color: AppTheme.deepNavy,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    post.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    post.summary,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, color: AppTheme.vibrantEmerald, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        post.date,
                        style: const TextStyle(color: Colors.white54, fontSize: 14),
                      ),
                      const SizedBox(width: 24),
                      const Icon(Icons.person, color: AppTheme.vibrantEmerald, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        post.author,
                        style: const TextStyle(color: Colors.white54, fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicator(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        bool isActive = _currentPage % count == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: isActive ? 24 : 8,
          decoration: BoxDecoration(
            color: isActive ? AppTheme.vibrantEmerald : Colors.white24,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}