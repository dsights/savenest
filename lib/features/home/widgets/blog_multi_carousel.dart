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
    _pageController = PageController(viewportFraction: 1.0); // Each page takes full width
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
    // specific breakpoints for blog posts
    double screenWidth = MediaQuery.of(context).size.width;
    int postsPerPage;
    if (screenWidth < 768) {
      postsPerPage = 1;
    } else if (screenWidth < 1200) {
      postsPerPage = 2;
    } else {
      postsPerPage = 4;
    }

    // Calculate total number of pages
    final int numPages = (widget.posts.length / postsPerPage).ceil();

    return Column(
      children: [
        SizedBox(
          height: 380, // Height of the carousel
          child: PageView.builder(
            controller: _pageController,
            itemCount: numPages, // Number of pages
            itemBuilder: (context, pageIndex) {
              final int startIdx = pageIndex * postsPerPage;
              final int endIdx = (startIdx + postsPerPage).clamp(0, widget.posts.length);
              final List<BlogPost> postsForPage = widget.posts.sublist(startIdx, endIdx);

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Distribute cards evenly
                children: postsForPage.map((post) {
                  return Expanded( // Each card takes equal space
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: BlogCard(
                        post: post,
                        onTap: () {
                          context.go('/blog/${post.slug}');
                        },
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        // Dots indicator
        if (numPages > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(numPages, (index) { // Dots for each page
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
