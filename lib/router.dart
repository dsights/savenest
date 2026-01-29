import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'features/home/landing_screen.dart';
import 'features/blog/blog_post_screen.dart';
import 'features/savings/savings_screen.dart';
import 'features/comparison/comparison_screen.dart';
import 'features/comparison/comparison_model.dart';

final goRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LandingScreen(),
    ),
    GoRoute(
      path: '/savings',
      builder: (context, state) => const SavingsScreen(),
    ),
    GoRoute(
      path: '/comparison',
      builder: (context, state) {
         // Handle optional query parameter for category if needed in future
         return const ComparisonScreen(initialCategory: ProductCategory.energy);
      },
    ),
    GoRoute(
      path: '/blog/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'];
        return BlogPostScreen(postId: id!);
      },
    ),
  ],
);
