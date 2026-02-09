import 'package:flutter/material.dart';
import 'package:meta_seo/meta_seo.dart';
import 'package:savenest/theme/app_theme.dart';
import 'package:flutter/foundation.dart'; // Import for kIsWeb

import 'package:savenest/widgets/main_navigation_bar.dart';
import 'package:savenest/widgets/main_mobile_drawer.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Update meta tags for SEO
    if (kIsWeb) {
      MetaSEO meta = MetaSEO();
      const String title = 'Privacy Policy | SaveNest';
      const String description = 'Understand how SaveNest collects, uses, and protects your personal information. Learn about our data handling, affiliate tracking, and your privacy rights.';
      const String imageUrl = 'https://savenest.au/assets/assets/images/hero_energy.jpg';

      meta.nameContent(name: 'title', content: title);
      meta.nameContent(name: 'description', content: description);
      
      // Open Graph
      meta.ogTitle(ogTitle: title);
      meta.ogDescription(ogDescription: description);
      meta.propertyContent(property: 'og:url', content: 'https://savenest.au/privacy');
      meta.ogImage(ogImage: imageUrl);

      // Twitter
      meta.nameContent(name: 'twitter:card', content: 'summary_large_image');
      meta.nameContent(name: 'twitter:title', content: title);
      meta.nameContent(name: 'twitter:description', content: description);
      meta.nameContent(name: 'twitter:image', content: imageUrl);
    }

    return Scaffold(
      backgroundColor: AppTheme.deepNavy,
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
                  const SizedBox(height: 32),
                  _buildSectionTitle('Your Privacy Matters'),
            const SizedBox(height: 16),
            _buildBodyText(
                'This policy outlines how SaveNest collects, uses, and protects your personal information. We are committed to protecting your privacy and ensuring that your data is handled securely and transparently.'),
            const SizedBox(height: 32),
            _buildSectionTitle('Information We Collect'),
            const SizedBox(height: 16),
            _buildListItem('Usage Data',
                'We collect anonymous data about how you interact with our website, such as the pages you visit and the links you click. This helps us understand how our site is used and how we can improve it.'),
            _buildListItem('Affiliate Tracking',
                'When you click on an affiliate link to a partner\'s site, a cookie may be placed on your device. This is a standard practice for affiliate marketing and allows the partner to recognize that you came from SaveNest. This cookie does not contain any personally identifiable information.'),
            const SizedBox(height: 32),
            _buildSectionTitle('How We Use Your Information'),
            const SizedBox(height: 16),
            _buildBodyText(
                'The information we collect is used to improve your experience on our site, to understand our audience, and to maintain our relationships with our partners. We do not sell your personal information to third parties.'),
            const SizedBox(height: 32),
            _buildSectionTitle('Your Rights'),
            const SizedBox(height: 16),
            _buildBodyText(
                'You have the right to understand how your data is used and to opt-out of tracking where possible. You can typically clear cookies from your browser settings if you do not wish to be tracked.'),
            const SizedBox(height: 32),
            _buildSectionTitle('Contact Us'),
            const SizedBox(height: 16),
            _buildBodyText(
                'If you have any questions about this privacy policy, please contact us at privacy@savenest.au.'),
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
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildBodyText(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 16,
        height: 1.5,
      ),
    );
  }

  Widget _buildListItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: AppTheme.vibrantEmerald, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
