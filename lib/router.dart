import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'features/home/landing_screen.dart';
import 'package:savenest/features/about/about_us_screen.dart';
import 'package:savenest/features/about/contact_us_screen.dart';
import 'package:savenest/features/about/how_it_works_screen.dart';
import 'package:savenest/features/blog/blog_list_screen.dart';
import 'package:savenest/features/blog/blog_post_screen.dart';
import 'package:savenest/features/comparison/comparison_model.dart';
import 'package:savenest/features/comparison/comparison_screen.dart';
import 'package:savenest/features/comparison/deal_details_screen.dart';
import 'package:savenest/features/comparison/provider_details_screen.dart';
import 'package:savenest/features/comparison/provider_directory_screen.dart';
import 'package:savenest/features/comparison/state_guide_screen.dart' hide StringExtension;
import 'package:savenest/features/legal/disclaimer_screen.dart';
import 'package:savenest/features/legal/privacy_policy_screen.dart';
import 'package:savenest/features/legal/terms_of_service_screen.dart';
import 'package:savenest/features/misc/sitemap_screen.dart';
import 'package:savenest/features/misc/moving_house_screen.dart';
import 'package:savenest/features/partners/advertise_with_us_screen.dart';
import 'package:savenest/features/savings/savings_screen.dart';
import 'package:savenest/features/registration/registration_screen.dart';

// Helper for transitions
// ... (omitting transition helper for brevity in replace call if possible, but I must match exactly)
Page<dynamic> _fadeTransition(BuildContext context, GoRouterState state, Widget child) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

final goRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => _fadeTransition(context, state, const LandingScreen()),
    ),
    GoRoute(
      path: '/register',
      pageBuilder: (context, state) => _fadeTransition(context, state, const RegistrationScreen()),
    ),
    GoRoute(
      path: '/savings',
      pageBuilder: (context, state) => _fadeTransition(
        context, 
        state, 
        const SavingsScreen(),
      ),
    ),
    GoRoute(
      path: '/deal/:dealId',
      pageBuilder: (context, state) {
        final dealId = state.pathParameters['dealId'];
        return _fadeTransition(
          context,
          state,
          DealDetailsScreen(dealId: dealId!),
        );
      },
    ),
    GoRoute(
      path: '/provider/:providerSlug',
      pageBuilder: (context, state) {
        final providerSlug = state.pathParameters['providerSlug'];
        return _fadeTransition(
          context,
          state,
          ProviderDetailsScreen(providerSlug: providerSlug!),
        );
      },
    ),
    GoRoute(
      path: '/providers',
      pageBuilder: (context, state) => _fadeTransition(
        context,
        state,
        const ProviderDirectoryScreen(),
      ),
    ),
    GoRoute(
      path: '/guides/:state/:utility',
      pageBuilder: (context, state) {
        final stateCode = state.pathParameters['state']!;
        final utility = state.pathParameters['utility']!;
        return _fadeTransition(
          context,
          state,
          StateGuideScreen(stateCode: stateCode, utility: utility),
        );
      },
    ),
    GoRoute(
      path: '/deals/electricity',
      pageBuilder: (context, state) => _fadeTransition(
        context,
        state,
        const ComparisonScreen(initialCategory: ProductCategory.electricity),
      ),
    ),
    GoRoute(
      path: '/deals/gas',
      pageBuilder: (context, state) => _fadeTransition(
        context,
        state,
        const ComparisonScreen(initialCategory: ProductCategory.gas),
      ),
    ),
    GoRoute(
      path: '/deals/internet',
      pageBuilder: (context, state) => _fadeTransition(
        context,
        state,
        const ComparisonScreen(initialCategory: ProductCategory.internet),
      ),
    ),
    GoRoute(
      path: '/deals/mobile',
      pageBuilder: (context, state) => _fadeTransition(
        context,
        state,
        const ComparisonScreen(initialCategory: ProductCategory.mobile),
      ),
    ),
    GoRoute(
      path: '/deals/insurance',
      pageBuilder: (context, state) => _fadeTransition(
        context,
        state,
        const ComparisonScreen(initialCategory: ProductCategory.insurance),
      ),
    ),
    GoRoute(
      path: '/deals/insurance/health',
      pageBuilder: (context, state) => _fadeTransition(
        context,
        state,
        const ComparisonScreen(initialCategory: ProductCategory.insurance),
      ),
    ),
    GoRoute(
      path: '/deals/insurance/car',
      pageBuilder: (context, state) => _fadeTransition(
        context,
        state,
        const ComparisonScreen(initialCategory: ProductCategory.insurance),
      ),
    ),
    GoRoute(
      path: '/deals/credit-cards',
      pageBuilder: (context, state) => _fadeTransition(
        context,
        state,
        const ComparisonScreen(initialCategory: ProductCategory.creditCards),
      ),
    ),
    GoRoute(
      path: '/loans/home',
      pageBuilder: (context, state) => _fadeTransition(
        context,
        state,
        const SavingsScreen(),
      ),
    ),
    GoRoute(
      path: '/blog',
      pageBuilder: (context, state) => _fadeTransition(
        context,
        state,
        const BlogListScreen(),
      ),
    ),
    GoRoute(
      path: '/blog/:slug',
      pageBuilder: (context, state) {
        final slug = state.pathParameters['slug'];
        return _fadeTransition(
          context,
          state,
          BlogPostScreen(slug: slug!),
        );
      },
    ),
    GoRoute(
      path: '/partners/advertise',
      pageBuilder: (context, state) => _fadeTransition(
        context,
        state,
        const AdvertiseWithUsScreen(),
      ),
    ),
    GoRoute(
      path: '/how-it-works',
      pageBuilder: (context, state) => _fadeTransition(
        context,
        state,
        const HowItWorksScreen(),
      ),
    ),
    GoRoute(
      path: '/privacy',
      pageBuilder: (context, state) => _fadeTransition(
        context,
        state,
        const PrivacyPolicyScreen(),
      ),
    ),
    GoRoute(
      path: '/terms',
      pageBuilder: (context, state) => _fadeTransition(
        context,
        state,
        const TermsOfServiceScreen(),
      ),
    ),
    GoRoute(
      path: '/about',
      pageBuilder: (context, state) => _fadeTransition(
        context,
        state,
        const AboutUsScreen(),
      ),
    ),
    GoRoute(
      path: '/contact',
      pageBuilder: (context, state) => _fadeTransition(
        context,
        state,
        const ContactUsScreen(),
      ),
    ),
    GoRoute(
      path: '/legal/disclaimer',
      pageBuilder: (context, state) => _fadeTransition(
        context,
        state,
        const DisclaimerScreen(),
      ),
    ),
    GoRoute(
      path: '/sitemap',
      pageBuilder: (context, state) => _fadeTransition(
        context,
        state,
        const SitemapScreen(),
      ),
    ),
    GoRoute(
      path: '/energy/moving-house',
      pageBuilder: (context, state) => _fadeTransition(
        context,
        state,
        const MovingHouseScreen(),
      ),
    ),
  ],
);