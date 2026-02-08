import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:savenest/features/about/about_us_screen.dart';
import 'package:savenest/features/about/how_it_works_screen.dart';
import 'package:savenest/features/legal/privacy_policy_screen.dart';
import 'package:savenest/features/legal/terms_of_service_screen.dart';
import 'package:savenest/features/partners/advertise_with_us_screen.dart';
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
      path: '/deals/electricity',
      builder: (context, state) {
         return const ComparisonScreen(initialCategory: ProductCategory.electricity);
      },
    ),
    GoRoute(
      path: '/deals/gas',
      builder: (context, state) {
         return const ComparisonScreen(initialCategory: ProductCategory.gas);
      },
    ),
    GoRoute(
      path: '/deals/internet',
      builder: (context, state) {
         return const ComparisonScreen(initialCategory: ProductCategory.internet);
      },
    ),
    GoRoute(
      path: '/deals/mobile',
      builder: (context, state) {
         return const ComparisonScreen(initialCategory: ProductCategory.mobile);
      },
    ),
    GoRoute(
      path: '/deals/insurance', // General Insurance
      builder: (context, state) {
         return const ComparisonScreen(initialCategory: ProductCategory.insurance);
      },
    ),
    GoRoute(
      path: '/deals/insurance/health', // Health Insurance
      builder: (context, state) {
         return const ComparisonScreen(initialCategory: ProductCategory.insurance); // Route to generic insurance for now
      },
    ),
    GoRoute(
      path: '/deals/insurance/car', // Car Insurance
      builder: (context, state) {
         return const ComparisonScreen(initialCategory: ProductCategory.insurance); // Route to generic insurance for now
      },
    ),
    GoRoute(
      path: '/deals/credit-cards', // Credit Cards
      builder: (context, state) {
         return const ComparisonScreen(initialCategory: ProductCategory.creditCards);
      },
    ),
    GoRoute(
      path: '/loans/home', // Home Loans (placeholder)
      builder: (context, state) => const SavingsScreen(), // Temporary route to SavingsScreen
    ),
    GoRoute(
      path: '/blog/:slug',
      builder: (context, state) {
        final slug = state.pathParameters['slug'];
        return BlogPostScreen(slug: slug!);
      },
    ),
    GoRoute(
      path: '/partners/advertise',
      builder: (context, state) => const AdvertiseWithUsScreen(),
    ),
    GoRoute(
      path: '/how-it-works',
      builder: (context, state) => const HowItWorksScreen(),
    ),
    GoRoute(
      path: '/privacy',
      builder: (context, state) => const PrivacyPolicyScreen(),
    ),
    GoRoute(
      path: '/terms',
      builder: (context, state) => const TermsOfServiceScreen(),
    ),
    GoRoute(
      path: '/about',
      builder: (context, state) => const AboutUsScreen(),
    ),
    GoRoute(
      path: '/legal/disclaimer', // Placeholder for Disclaimer page
      builder: (context, state) => const AboutUsScreen(), // Using AboutUsScreen as a temporary placeholder
    ),
    GoRoute(
      path: '/sitemap', // Placeholder for Sitemap page
      builder: (context, state) => const AboutUsScreen(), // Using AboutUsScreen as a temporary placeholder
    ),
  ],
);
