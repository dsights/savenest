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
                    'Privacy Policy',
                    style: TextStyle(
                      color: AppTheme.deepNavy,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Last Updated: February 2026',
                    style: TextStyle(color: AppTheme.deepNavy.withOpacity(0.54), fontSize: 14),
                  ),
                  const SizedBox(height: 32),

                  _buildSectionTitle('1. Introduction'),
                  _buildBodyText(
                      'SaveNest ("we", "us", or "our") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you visit our website savenest.au. We adhere to the Australian Privacy Principles (APPs) contained in the Privacy Act 1988 (Cth).'),

                  const SizedBox(height: 24),
                  _buildSectionTitle('2. Information We Collect'),
                  _buildBodyText('We may collect personal information about you in various ways, including:'),
                  const SizedBox(height: 12),
                  _buildListItem('Personal Data',
                      'Personally identifiable information, such as your name, email address, and telephone number, that you voluntarily give to us when you subscribe to our newsletter or contact us.'),
                  _buildListItem('Derivative Data',
                      'Information our servers automatically collect when you access the Site, such as your IP address, your browser type, your operating system, your access times, and the pages you have viewed directly before and after accessing the Site.'),
                  _buildListItem('Cookies and Tracking',
                      'We use cookies and similar tracking technologies to track the activity on our Service and hold certain information. You can instruct your browser to refuse all cookies or to indicate when a cookie is being sent.'),

                  const SizedBox(height: 24),
                  _buildSectionTitle('3. How We Use Your Information'),
                  _buildBodyText('We use the information we collect to:'),
                  const SizedBox(height: 12),
                  _buildBulletPoint('Provide, operate, and maintain our website.'),
                  _buildBulletPoint('Improve, personalize, and expand our website.'),
                  _buildBulletPoint('Understand and analyze how you use our website.'),
                  _buildBulletPoint('Communicate with you, either directly or through one of our partners, for customer service, to provide you with updates and other information relating to the website, and for marketing and promotional purposes.'),
                  _buildBulletPoint('Process your affiliate referrals accurately.'),

                  const SizedBox(height: 24),
                  _buildSectionTitle('4. Disclosure of Your Information'),
                  _buildBodyText('We may share information we have collected about you in certain situations. Your information may be disclosed as follows:'),
                  const SizedBox(height: 12),
                  _buildListItem('Business Partners',
                      'We may share your information with our business partners to offer you certain products, services, or promotions. Specifically, when you click an affiliate link, we pass non-personally identifiable referral data to the provider.'),
                  _buildListItem('Service Providers',
                      'We may share your information with third-party vendors, service providers, contractors, or agents who perform services for us or on our behalf and require access to such information to do that work.'),
                  _buildListItem('Legal Requirements',
                      'We may disclose your information where we are legally required to do so in order to comply with applicable law, governmental requests, a judicial proceeding, court order, or legal process.'),

                  const SizedBox(height: 24),
                  _buildSectionTitle('5. Security of Your Information'),
                  _buildBodyText(
                      'We use administrative, technical, and physical security measures to help protect your personal information. While we have taken reasonable steps to secure the personal information you provide to us, please be aware that despite our efforts, no security measures are perfect or impenetrable, and no method of data transmission can be guaranteed against any interception or other type of misuse.'),

                  const SizedBox(height: 24),
                  _buildSectionTitle('6. Access and Correction'),
                  _buildBodyText(
                      'Under the Privacy Act, you have the right to access and correct the personal information we hold about you. If you wish to access or correct your personal information, please contact us at privacy@savenest.au.'),

                  const SizedBox(height: 24),
                  _buildSectionTitle('7. Complaints'),
                  _buildBodyText(
                      'If you have a complaint about how we handle your personal information, please contact us at privacy@savenest.au. We will respond to your complaint within a reasonable time. If you are not satisfied with our response, you may lodge a complaint with the Office of the Australian Information Commissioner (OAIC).'),
                  
                  const SizedBox(height: 24),
                  _buildSectionTitle('8. Contact Us'),
                  _buildBodyText(
                      'If you have questions or comments about this Privacy Policy, please contact us at:\n\nEmail: privacy@savenest.au'),
                  
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
      style: const TextStyle(
        color: AppTheme.deepNavy.withOpacity(0.7),
        fontSize: 16,
        height: 1.5,
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: AppTheme.deepNavy, fontSize: 16)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppTheme.deepNavy.withOpacity(0.7),
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ),
        ],
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
                    color: AppTheme.deepNavy,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    color: AppTheme.deepNavy.withOpacity(0.7),
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
