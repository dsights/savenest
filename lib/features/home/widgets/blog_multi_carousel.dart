import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../blog/blog_model.dart';
import '../../blog/widgets/blog_card.dart';
import 'package:savenest/theme/app_theme.dart';

class BlogMultiCarousel extends StatefulWidget {
  final List<BlogPost> posts;

  const BlogMultiCarousel({super.key, required this.posts});

  @override
  State<BlogMultiCarousel> createState() => _BlogMultiCarouselState();
}

class _BlogMultiCarouselState extends State<BlogMultiCarousel> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.8); // Adjust viewportFraction for visible partial next/prev cards
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page?.round() ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 380, // Height of the carousel
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.posts.length,
            itemBuilder: (context, index) {
              final post = widget.posts[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0), // Spacing between cards
                child: BlogCard(
                  post: post,
                  onTap: () {
                    context.go('/blog/${post.slug}');
                  },
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        // Dots indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.posts.length, (index) {
            return GestureDetector(
              onTap: () {
                _pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeIn,
                );
              },
              child: Container(
                width: 8.0,
                height: 8.0,
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentPage == index
                      ? AppTheme.vibrantEmerald // Active dot color
                      : Colors.grey, // Inactive dot color
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
