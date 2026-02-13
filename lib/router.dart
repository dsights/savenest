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
import 'package:savenest/features/comparison/comparison_screen.dart';
import 'package:savenest/features/comparison/deal_details_screen.dart';
import 'package:savenest/features/comparison/state_guide_screen.dart' hide StringExtension;
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
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  const Text('Failed to load page. Please try refreshing.', 
                    style: TextStyle(color: AppTheme.deepNavy, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.go('/'),
                    child: const Text('Back to Home'),
                  ),
                ],
              ),
            ),
          );
        }
        return builder();
      }
      return const Scaffold(
        backgroundColor: AppTheme.offWhite,
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.accentOrange),
        ),
      );
    },
  );
}

// Helper for transitions
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
      path: '/savings',
      pageBuilder: (context, state) => _fadeTransition(
        context, 
        state, 
        _deferredWidget(savings.loadLibrary(), () => savings.SavingsScreen()),
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
        ComparisonScreen(initialCategory: ProductCategory.electricity),
      ),
    ),
    GoRoute(
      path: '/deals/gas',
      pageBuilder: (context, state) => _fadeTransition(
        context,
        state,
        ComparisonScreen(initialCategory: ProductCategory.gas),
      ),
    ),
    GoRoute(
      path: '/deals/internet',
      pageBuilder: (context, state) => _fadeTransition(
        context,
        state,
        ComparisonScreen(initialCategory: ProductCategory.internet),
      ),
    ),
    GoRoute(
      path: '/deals/mobile',
      pageBuilder: (context, state) => _fadeTransition(
        context,
        state,
        ComparisonScreen(initialCategory: ProductCategory.mobile),
      ),
    ),
    GoRoute(
      path: '/deals/insurance',
      pageBuilder: (context, state) => _fadeTransition(
        context,
        state,
        ComparisonScreen(initialCategory: ProductCategory.insurance),
      ),
    ),
    GoRoute(
      path: '/deals/insurance/health',
      pageBuilder: (context, state) => _fadeTransition(
        context,
        state,
        ComparisonScreen(initialCategory: ProductCategory.insurance),
      ),
    ),
    GoRoute(
      path: '/deals/insurance/car',
      pageBuilder: (context, state) => _fadeTransition(
        context,
        state,
        ComparisonScreen(initialCategory: ProductCategory.insurance),
      ),
    ),
    GoRoute(
      path: '/deals/credit-cards',
      pageBuilder: (context, state) => _fadeTransition(
        context,
        state,
        ComparisonScreen(initialCategory: ProductCategory.creditCards),
      ),
    ),
    GoRoute(
      path: '/loans/home',
      pageBuilder: (context, state) => _fadeTransition(
        context,
        state,
        _deferredWidget(savings.loadLibrary(), () => savings.SavingsScreen()),
      ),
    ),
    GoRoute(
      path: '/blog',
      pageBuilder: (context, state) => _fadeTransition(
        context,
        state,
        _deferredWidget(blog_list.loadLibrary(), () => blog_list.BlogListScreen()),
      ),
    ),
    GoRoute(
      path: '/blog/:slug',
      pageBuilder: (context, state) {
        final slug = state.pathParameters['slug'];
        return _fadeTransition(
          context,
          state,
          _deferredWidget(blog_post.loadLibrary(), () => blog_post.BlogPostScreen(slug: slug!)),
        );
      },
    ),
    GoRoute(
      path: '/partners/advertise',
      pageBuilder: (context, state) => _fadeTransition(
        context,
        state,
        _deferredWidget(advertise.loadLibrary(), () => advertise.AdvertiseWithUsScreen()),
      ),
    ),
    GoRoute(
      path: '/how-it-works',
      pageBuilder: (context, state) => _fadeTransition(
        context,
        state,
        _deferredWidget(how_it_works.loadLibrary(), () => how_it_works.HowItWorksScreen()),
      ),
    ),
    GoRoute(
      path: '/privacy',
      pageBuilder: (context, state) => _fadeTransition(
        context,
        state,
        _deferredWidget(privacy.loadLibrary(), () => privacy.PrivacyPolicyScreen()),
      ),
    ),
    GoRoute(
      path: '/terms',
      pageBuilder: (context, state) => _fadeTransition(
        context,
        state,
        _deferredWidget(terms.loadLibrary(), () => terms.TermsOfServiceScreen()),
      ),
    ),
    GoRoute(
      path: '/about',
      pageBuilder: (context, state) => _fadeTransition(
        context,
        state,
        _deferredWidget(about.loadLibrary(), () => about.AboutUsScreen()),
      ),
    ),
    GoRoute(
      path: '/contact',
      pageBuilder: (context, state) => _fadeTransition(
        context,
        state,
        _deferredWidget(contact.loadLibrary(), () => contact.ContactUsScreen()),
      ),
    ),
    GoRoute(
      path: '/legal/disclaimer',
      pageBuilder: (context, state) => _fadeTransition(
        context,
        state,
        _deferredWidget(disclaimer.loadLibrary(), () => disclaimer.DisclaimerScreen()),
      ),
    ),
    GoRoute(
      path: '/sitemap',
      pageBuilder: (context, state) => _fadeTransition(
        context,
        state,
        _deferredWidget(sitemap.loadLibrary(), () => sitemap.SitemapScreen()),
      ),
    ),
  ],
);