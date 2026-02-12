import 'package:flutter/material.dart';
import 'package:savenest/theme/app_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:meta_seo/meta_seo.dart';

import 'package:savenest/widgets/main_navigation_bar.dart';
import 'package:savenest/widgets/main_mobile_drawer.dart';

class DisclaimerScreen extends StatelessWidget {
  const DisclaimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      MetaSEO meta = MetaSEO();
      meta.nameContent(name: 'title', content: 'Disclaimer | SaveNest');
      meta.nameContent(name: 'description', content: 'Important disclaimers regarding the information and services provided by SaveNest.');
      meta.ogTitle(ogTitle: 'Disclaimer | SaveNest');
      meta.ogDescription(ogDescription: 'Important disclaimers regarding the information and services provided by SaveNest.');
      meta.propertyContent(property: 'og:url', content: 'https://www.savenest.com.au/legal/disclaimer');
      meta.ogImage(ogImage: 'https://www.savenest.com.au/assets/images/logo.png');
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
                  Text(
                    'Disclaimer',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Last Updated: February 2026',
                    style: TextStyle(color: Colors.white54, fontSize: 14),
                  ),
                  const SizedBox(height: 32),

                  _buildSectionTitle('1. General Information Only'),
                  _buildBodyText(
                      'The information provided on SaveNest (the "Site") is for general informational purposes only. All information on the Site is provided in good faith, however we make no representation or warranty of any kind, express or implied, regarding the accuracy, adequacy, validity, reliability, availability, or completeness of any information on the Site.'),

                  const SizedBox(height: 24),
                  _buildSectionTitle('2. No Financial Advice'),
                  _buildBodyText(
                      'SaveNest is not a financial adviser. The content on this Site does not constitute financial, investment, legal, or other professional advice and should not be relied upon as such.'),
                  const SizedBox(height: 12),
                  _buildBodyText(
                      'We strongly recommend that you consult with a qualified professional or financial advisor before making any decisions based on information found on this Site. Your use of the Site and your reliance on any information on the Site is solely at your own risk.'),

                  const SizedBox(height: 24),
                  _buildSectionTitle('3. Accuracy of Information'),
                  _buildBodyText(
                      'While we strive to keep our comparison data up to date, product details, prices, and terms can change without notice. We cannot guarantee that the information listed on our Site matches exactly with what is found on a third-party provider\'s website.'),
                  const SizedBox(height: 12),
                  _buildBodyText(
                      'Always review the Product Disclosure Statement (PDS), Target Market Determination (TMD), and Terms and Conditions on the provider\'s website before purchasing any product.'),

                  const SizedBox(height: 24),
                  _buildSectionTitle('4. Third Party Links'),
                  _buildBodyText(
                      'The Site may contain (or you may be sent through the Site) links to other websites or content belonging to or originating from third parties. Such external links are not investigated, monitored, or checked for accuracy, adequacy, validity, reliability, availability, or completeness by us.'),

                  const SizedBox(height: 24),
                  _buildSectionTitle('5. Affiliate Disclosure'),
                  _buildBodyText(
                      'SaveNest is an affiliate comparison site. We may receive a commission, referral fee, or other compensation from some of the providers listed on our website when you click on a link or purchase a product. This compensation may impact how and where products appear on the Site (including, for example, the order in which they appear).'),
                  const SizedBox(height: 12),
                  _buildBodyText(
                      'This helps us keep our service free for you. However, our reviews and comparisons are based on our own analysis and research.'),

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
}
