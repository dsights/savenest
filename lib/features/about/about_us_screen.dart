import 'package:flutter/material.dart';
import 'package:meta_seo/meta_seo.dart';
import 'package:savenest/theme/app_theme.dart';
import 'package:flutter/foundation.dart'; // Import for kIsWeb

import 'package:savenest/widgets/main_navigation_bar.dart';
import 'package:savenest/widgets/main_mobile_drawer.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Update meta tags for SEO
    if (kIsWeb) {
      MetaSEO meta = MetaSEO();
      const String title = 'About SaveNest | Australia\'s Smart Utility Comparison Site';
      const String description = 'Learn about SaveNest\'s mission to help Australians save money on utilities. Discover our story, our commitment to independent comparisons, and our business details.';
      const String imageUrl = 'https://savenest.au/assets/assets/images/hero_energy.jpg';

      meta.nameContent(name: 'title', content: title);
      meta.nameContent(name: 'description', content: description);
      
      // Open Graph
      meta.ogTitle(ogTitle: title);
      meta.ogDescription(ogDescription: description);
      meta.propertyContent(property: 'og:url', content: 'https://savenest.au/about');
      meta.ogImage(ogImage: imageUrl);

      // Twitter
      meta.nameContent(name: 'twitter:card', content: 'summary_large_image');
      meta.nameContent(name: 'twitter:title', content: title);
      meta.nameContent(name: 'twitter:description', content: description);
      meta.nameContent(name: 'twitter:image', content: imageUrl);
    }

    return Scaffold(
        backgroundColor: AppTheme.offWhite,
        endDrawer: const MainMobileDrawer(),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const MainNavigationBar(),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Our Story'),
              const SizedBox(height: 16),
              Image.asset(
                'assets/images/home_ins.png', // Placeholder image
                height: 150,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 16),
              _buildBodyText(
                  'SaveNest was founded with a simple mission: to help Australians navigate the confusing and often expensive world of household utilities and financial products. Our founders, with their background in utilities, real estate, and finance, saw firsthand how much money people were losing simply by not being on the right plan.'),
              const SizedBox(height: 32),
              _buildSectionTitle('Our Mission'),
              const SizedBox(height: 16),
              Image.asset(
                'assets/images/energy.png', // Placeholder image
                height: 150,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 16),
              _buildBodyText(
                  'We believe that everyone deserves to get the best value for their money. We are committed to providing a free, independent, and easy-to-use platform that helps you compare with confidence and save with ease.'),
              const SizedBox(height: 32),
              _buildSectionTitle('Business Details'),
              const SizedBox(height: 16),
              _buildBusinessDetail('Registered Business Name', 'SaveNest Pty Ltd'),
              _buildBusinessDetail('ABN', '12 345 678 910 (Placeholder)'),
            ],
          ),
        ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppTheme.deepNavy,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildBodyText(String text) {
    return Text(
      text,
      style: TextStyle(
        color: AppTheme.deepNavy.withOpacity(0.7),
        fontSize: 16,
        height: 1.5,
      ),
    );
  }

  Widget _buildBusinessDetail(String title, String detail) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Text(
            '$title: ',
            style: const TextStyle(
              color: AppTheme.deepNavy,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            detail,
            style: TextStyle(
              color: AppTheme.deepNavy.withOpacity(0.7),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
