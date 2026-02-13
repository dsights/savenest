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
                  const SizedBox(height: 32),
                  const Text(
                    'Terms of Service',
                    style: TextStyle(
                      color: AppTheme.deepNavy,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Last Updated: February 2026',
                    style: TextStyle(color: AppTheme.deepNavy.withOpacity(0.54), fontSize: 14),
                  ),
                  const SizedBox(height: 32),

                  _buildSectionTitle('1. Acceptance of Terms'),
                  _buildBodyText(
                      'By accessing and using savenest.au ("SaveNest", "we", "our", "us"), you accept and agree to be bound by the terms and provision of this agreement. In addition, when using these particular services, you shall be subject to any posted guidelines or rules applicable to such services.'),

                  const SizedBox(height: 24),
                  _buildSectionTitle('2. Nature of Service'),
                  _buildBodyText(
                      'SaveNest is an informational comparison website. We provide information and comparison tools for various products and services, including but not limited to electricity, gas, internet, and insurance.'),
                  const SizedBox(height: 12),
                  _buildBodyText(
                      'We are NOT a product provider, insurer, or financial institution. We do not provide financial advice, recommendation, or endorsement of any specific product or service. All information provided is for general educational purposes only.'),

                  const SizedBox(height: 24),
                  _buildSectionTitle('3. Affiliate Disclosure'),
                  _buildBodyText(
                      'SaveNest participates in various affiliate marketing programs, which means we may get paid commissions on editorially chosen products purchased through our links to retailer sites.'),
                  const SizedBox(height: 12),
                  _buildBodyText(
                      'This compensation may impact how and where products appear on this site (including, for example, the order in which they appear). However, this does not influence our editorial integrity. We strive to provide accurate and unbiased information.'),

                  const SizedBox(height: 24),
                  _buildSectionTitle('4. User Responsibilities'),
                  _buildBodyText(
                      'You agree to use the website only for lawful purposes. You agree not to take any action that might compromise the security of the website, render the website inaccessible to others, or otherwise cause damage to the website or the content.'),
                  const SizedBox(height: 12),
                  _buildBodyText(
                      'You are responsible for ensuring that any information you provide to us or to our partners is accurate, complete, and up-to-date.'),

                  const SizedBox(height: 24),
                  _buildSectionTitle('5. Limitation of Liability'),
                  _buildBodyText(
                      'To the fullest extent permitted by applicable law, in no event will SaveNest, its affiliates, directors, officers, employees, agents, suppliers, or licensors be liable to any person for any indirect, incidental, special, punitive, cover or consequential damages (including, without limitation, damages for lost profits, revenue, sales, goodwill, use of content, impact on business, business interruption, loss of anticipated savings, loss of business opportunity) however caused, under any theory of liability.'),
                  const SizedBox(height: 12),
                  _buildBodyText(
                      'We do not guarantee that the prices or product details listed on our site are identical to those on the provider\'s site. Providers may change their terms at any time.'),

                  const SizedBox(height: 24),
                  _buildSectionTitle('6. Intellectual Property'),
                  _buildBodyText(
                      'The Service and its original content, features, and functionality are and will remain the exclusive property of SaveNest and its licensors. The Service is protected by copyright, trademark, and other laws of both Australia and foreign countries.'),

                  const SizedBox(height: 24),
                  _buildSectionTitle('7. Governing Law'),
                  _buildBodyText(
                      'These Terms shall be governed and construed in accordance with the laws of New South Wales, Australia, without regard to its conflict of law provisions.'),

                  const SizedBox(height: 24),
                  _buildSectionTitle('8. Changes to Terms'),
                  _buildBodyText(
                      'We reserve the right, at our sole discretion, to modify or replace these Terms at any time. By continuing to access or use our Service after those revisions become effective, you agree to be bound by the revised terms.'),

                  const SizedBox(height: 64),
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

  }