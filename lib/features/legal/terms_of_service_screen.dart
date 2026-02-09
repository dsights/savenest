import 'package:flutter/material.dart';
import 'package:meta_seo/meta_seo.dart';
import 'package:savenest/theme/app_theme.dart';
import 'package:flutter/foundation.dart'; // Import for kIsWeb

import 'package:savenest/widgets/main_navigation_bar.dart';
import 'package:savenest/widgets/main_mobile_drawer.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Update meta tags for SEO
    if (kIsWeb) {
      MetaSEO meta = MetaSEO();
      const String title = 'Terms of Service | SaveNest';
      const String description = 'Review the terms of service for using SaveNest, including details on content usage, affiliate links, disclaimers, and changes to these terms.';
      const String imageUrl = 'https://savenest.au/assets/assets/images/hero_energy.jpg';

      meta.nameContent(name: 'title', content: title);
      meta.nameContent(name: 'description', content: description);
      
      // Open Graph
      meta.ogTitle(ogTitle: title);
      meta.ogDescription(ogDescription: description);
      meta.propertyContent(property: 'og:url', content: 'https://savenest.au/terms');
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
                  _buildSectionTitle('Using Our Service'),
            const SizedBox(height: 16),
            _buildBodyText(
                'By using the SaveNest website, you agree to these terms of service. Our service is provided free of charge to help you compare and save on various household utilities and financial products.'),
            const SizedBox(height: 32),
            _buildSectionTitle('Our Content'),
            const SizedBox(height: 16),
            _buildBodyText(
                'All content on this website, including text, graphics, and logos, is the property of SaveNest and is protected by copyright laws. You may not reproduce, distribute, or transmit any content from this site without our prior written consent.'),
            const SizedBox(height: 32),
            _buildSectionTitle('Affiliate Links'),
            const SizedBox(height: 16),
            _buildBodyText(
                'SaveNest is an affiliate comparison website. We use affiliate links to our partners. When you click on these links and make a purchase, we may earn a commission. This does not affect the price you pay.'),
            const SizedBox(height: 32),
            _buildSectionTitle('Disclaimer'),
            const SizedBox(height: 16),
            _buildBodyText(
                'The information on this website is for general information purposes only. We make no representations or warranties of any kind, express or implied, about the completeness, accuracy, reliability, suitability or availability with respect to the website or the information, products, services, or related graphics contained on the website for any purpose. Any reliance you place on such information is therefore strictly at your own risk.'),
            const SizedBox(height: 32),
            _buildSectionTitle('Changes to These Terms'),
            const SizedBox(height: 16),
            _buildBodyText(
                'We may update our terms of service from time to time. We will notify you of any changes by posting the new terms of service on this page. You are advised to review this page periodically for any changes.'),
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
  }}