import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:savenest/theme/app_theme.dart';

import 'features/home/landing_screen.dart';

// Deferred Imports for Route Splitting
import 'package:savenest/features/about/about_us_screen.dart' deferred as about;
import 'package:savenest/features/about/contact_us_screen.dart' deferred as contact;
import 'package:savenest/features/about/how_it_works_screen.dart' deferred as how_it_works;
import 'package:savenest/features/blog/blog_list_screen.dart' deferred as blog_list;
import 'package:savenest/features/blog/blog_post_screen.dart' deferred as blog_post;
import 'package:savenest/features/comparison/comparison_model.dart';
import 'package:savenest/features/comparison/comparison_screen.dart' deferred as comparison;
import 'package:savenest/features/comparison/deal_details_screen.dart' deferred as deal_details;
import 'package:savenest/features/comparison/state_guide_screen.dart' deferred as state_guide hide StringExtension;
import 'package:savenest/features/legal/disclaimer_screen.dart' deferred as disclaimer;
import 'package:savenest/features/legal/privacy_policy_screen.dart' deferred as privacy;
import 'package:savenest/features/legal/terms_of_service_screen.dart' deferred as terms;
import 'package:savenest/features/misc/sitemap_screen.dart' deferred as sitemap;
import 'package:savenest/features/partners/advertise_with_us_screen.dart' deferred as advertise;
import 'package:savenest/features/savings/savings_screen.dart' deferred as savings;

// Helper for deferred loading
Widget _deferredWidget(Future<void> loadLibrary, Widget Function() builder) {
  return FutureBuilder(
    future: loadLibrary,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.done) {
        return builder();
      }
      return const Scaffold(
        backgroundColor: AppTheme.deepNavy,
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.vibrantEmerald),
        ),
      );
    },
  );
}

final goRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LandingScreen(),
    ),
    GoRoute(
      path: '/savings',
      builder: (context, state) => _deferredWidget(
        savings.loadLibrary(),
        () => savings.SavingsScreen(),
      ),
    ),
    GoRoute(
      path: '/deal/:dealId',
      builder: (context, state) {
        final dealId = state.pathParameters['dealId'];
        return _deferredWidget(
          deal_details.loadLibrary(),
          () => deal_details.DealDetailsScreen(dealId: dealId!),
        );
      },
    ),
    GoRoute(
      path: '/guides/:state/:utility',
      builder: (context, state) {
        final stateCode = state.pathParameters['state']!;
        final utility = state.pathParameters['utility']!;
        return _deferredWidget(
          state_guide.loadLibrary(),
          () => state_guide.StateGuideScreen(stateCode: stateCode, utility: utility),
        );
      },
    ),
    GoRoute(
      path: '/deals/electricity',
      builder: (context, state) => _deferredWidget(
        comparison.loadLibrary(),
        () => comparison.ComparisonScreen(initialCategory: ProductCategory.electricity),
      ),
    ),
    GoRoute(
      path: '/deals/gas',
      builder: (context, state) => _deferredWidget(
        comparison.loadLibrary(),
        () => comparison.ComparisonScreen(initialCategory: ProductCategory.gas),
      ),
    ),
    GoRoute(
      path: '/deals/internet',
      builder: (context, state) => _deferredWidget(
        comparison.loadLibrary(),
        () => comparison.ComparisonScreen(initialCategory: ProductCategory.internet),
      ),
    ),
    GoRoute(
      path: '/deals/mobile',
      builder: (context, state) => _deferredWidget(
        comparison.loadLibrary(),
        () => comparison.ComparisonScreen(initialCategory: ProductCategory.mobile),
      ),
    ),
    GoRoute(
      path: '/deals/insurance',
      builder: (context, state) => _deferredWidget(
        comparison.loadLibrary(),
        () => comparison.ComparisonScreen(initialCategory: ProductCategory.insurance),
      ),
    ),
    GoRoute(
      path: '/deals/insurance/health',
      builder: (context, state) => _deferredWidget(
        comparison.loadLibrary(),
        () => comparison.ComparisonScreen(initialCategory: ProductCategory.insurance),
      ),
    ),
    GoRoute(
      path: '/deals/insurance/car',
      builder: (context, state) => _deferredWidget(
        comparison.loadLibrary(),
        () => comparison.ComparisonScreen(initialCategory: ProductCategory.insurance),
      ),
    ),
    GoRoute(
      path: '/deals/credit-cards',
      builder: (context, state) => _deferredWidget(
        comparison.loadLibrary(),
        () => comparison.ComparisonScreen(initialCategory: ProductCategory.creditCards),
      ),
    ),
    GoRoute(
      path: '/loans/home',
      builder: (context, state) => _deferredWidget(
        savings.loadLibrary(),
        () => savings.SavingsScreen(),
      ),
    ),
    GoRoute(
      path: '/blog',
      builder: (context, state) => _deferredWidget(
        blog_list.loadLibrary(),
        () => blog_list.BlogListScreen(),
      ),
    ),
    GoRoute(
      path: '/blog/:slug',
      builder: (context, state) {
        final slug = state.pathParameters['slug'];
        return _deferredWidget(
          blog_post.loadLibrary(),
          () => blog_post.BlogPostScreen(slug: slug!),
        );
      },
    ),
    GoRoute(
      path: '/partners/advertise',
      builder: (context, state) => _deferredWidget(
        advertise.loadLibrary(),
        () => advertise.AdvertiseWithUsScreen(),
      ),
    ),
    GoRoute(
      path: '/how-it-works',
      builder: (context, state) => _deferredWidget(
        how_it_works.loadLibrary(),
        () => how_it_works.HowItWorksScreen(),
      ),
    ),
    GoRoute(
      path: '/privacy',
      builder: (context, state) => _deferredWidget(
        privacy.loadLibrary(),
        () => privacy.PrivacyPolicyScreen(),
      ),
    ),
    GoRoute(
      path: '/terms',
      builder: (context, state) => _deferredWidget(
        terms.loadLibrary(),
        () => terms.TermsOfServiceScreen(),
      ),
    ),
    GoRoute(
      path: '/about',
      builder: (context, state) => _deferredWidget(
        about.loadLibrary(),
        () => about.AboutUsScreen(),
      ),
    ),
    GoRoute(
      path: '/contact',
      builder: (context, state) => _deferredWidget(
        contact.loadLibrary(),
        () => contact.ContactUsScreen(),
      ),
    ),
    GoRoute(
      path: '/legal/disclaimer',
      builder: (context, state) => _deferredWidget(
        disclaimer.loadLibrary(),
        () => disclaimer.DisclaimerScreen(),
      ),
    ),
    GoRoute(
      path: '/sitemap',
      builder: (context, state) => _deferredWidget(
        sitemap.loadLibrary(),
        () => sitemap.SitemapScreen(),
      ),
    ),
  ],
);
