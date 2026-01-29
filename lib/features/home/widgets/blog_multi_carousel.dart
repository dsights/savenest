import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../blog/blog_model.dart';
import '../../blog/widgets/blog_card.dart';

class BlogMultiCarousel extends StatefulWidget {
  final List<BlogPost> posts;

  const BlogMultiCarousel({super.key, required this.posts});

  @override
  State<BlogMultiCarousel> createState() => _BlogMultiCarouselState();
}

class _BlogMultiCarouselState extends State<BlogMultiCarousel> {
  late final ScrollController _scrollController;
  Timer? _timer;
  double _scrollPosition = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    // Use a post-frame callback to ensure the list is rendered before starting the timer
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoScroll();
    });
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (_scrollController.hasClients) {
        _scrollPosition += 1.0; // Adjust speed here
        
        // Loop back to start if we reach the end
        if (_scrollPosition >= _scrollController.position.maxScrollExtent) {
          _scrollPosition = 0;
          _scrollController.jumpTo(0);
        } else {
          _scrollController.jumpTo(_scrollPosition);
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // We duplicate the list to make it feel "infinite" for a better looping experience
    final displayPosts = [...widget.posts, ...widget.posts];

    return MouseRegion(
      onEnter: (_) => _timer?.cancel(),
      onExit: (_) => _startAutoScroll(),
      child: SizedBox(
        height: 380,
        child: ListView.separated(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(), // Disable user scroll to prevent fight with timer
          itemCount: displayPosts.length,
          separatorBuilder: (context, index) => const SizedBox(width: 20),
          itemBuilder: (context, index) {
            final post = displayPosts[index];
            return SizedBox(
              width: 300,
              child: BlogCard(
                post: post,
                onTap: () {
                  context.go('/blog/${post.id}');
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
