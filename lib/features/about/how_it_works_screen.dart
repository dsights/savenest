import 'package:flutter/material.dart';
import 'package:meta_seo/meta_seo.dart';
import 'package:savenest/theme/app_theme.dart';
import 'package:flutter/foundation.dart'; // Import for kIsWeb

import 'package:savenest/widgets/main_navigation_bar.dart';
import 'package:savenest/widgets/main_mobile_drawer.dart';

class HowItWorksScreen extends StatelessWidget {
  const HowItWorksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      MetaSEO meta = MetaSEO();
      const String title = 'How SaveNest Works | Our Business Model Explained';
      const String description = 'Learn how SaveNest helps you save money. We explain our affiliate partnerships, how we make money, and our commitment to providing transparent and independent comparisons.';
      const String imageUrl = 'https://savenest.au/assets/assets/images/hero_energy.jpg';

      meta.nameContent(name: 'title', content: title);
      meta.nameContent(name: 'description', content: description);
      
      // Open Graph
      meta.ogTitle(ogTitle: title);
      meta.ogDescription(ogDescription: description);
      meta.propertyContent(property: 'og:url', content: 'https://savenest.au/how-it-works');
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
                    _buildSectionTitle('Our Mission: Your Savings'),
              const SizedBox(height: 16),
              _buildBodyText(
                  'SaveNest’s goal is to empower Australians to make smarter financial decisions. We simplify the complex world of utilities and financial products, providing clear, independent guidance to help you find the best value and save money.'),
              const SizedBox(height: 32),
              _buildSectionTitle('How We Make Money'),
              const SizedBox(height: 16),
              _buildBodyText(
                  'Transparency is important to us. SaveNest is a free service for our users, and we want to be upfront about how we operate.'),
              const SizedBox(height: 16),
              _buildListItem('Affiliate Partnerships',
                  'When you use our comparison tools and click on a link to a provider’s website, we may use a tracked affiliate link. If you decide to sign up for a product or service through that link, the provider pays us a small commission. This comes at no extra cost to you; in fact, we often negotiate exclusive deals that can save you more.'),
              _buildListItem('Partner Networks',
                  'We work with affiliate networks like Commission Factory, Impact, and others to manage these relationships. This allows us to partner with a wide range of brands across different industries.'),
              const SizedBox(height: 32),
              _buildSectionTitle('Sponsored Placements & "Top Picks"'),
              const SizedBox(height: 16),
              _buildBodyText(
                  'To help us keep our service free, some providers may pay for priority placements in our comparison tables or guides. These will always be clearly marked as "Sponsored" or "Promoted" so you can distinguish them from our independent picks.'),
              const SizedBox(height: 16),
              _buildBodyText(
                  'Our "Top Picks" are based on our editorial team\'s assessment of a product\'s overall value, considering factors like price, features, customer service, and our own market analysis. These are not influenced by commercial partnerships.'),
              const SizedBox(height: 32),
              _buildSectionTitle('Our Commitment to You'),
              const SizedBox(height: 16),
              _buildBodyText(
                  'While we do have commercial relationships, our primary commitment is to you, our user. We strive to provide comprehensive, accurate, and up-to-date information to help you make the best choice for your needs. Our reputation is built on trust, and we work hard to maintain it.'),
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
