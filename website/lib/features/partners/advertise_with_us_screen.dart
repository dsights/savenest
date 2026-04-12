import 'package:flutter/material.dart';
import 'package:meta_seo/meta_seo.dart';
import 'package:savenest/theme/app_theme.dart';
import 'package:flutter/foundation.dart'; // Import for kIsWeb

import 'package:savenest/widgets/main_navigation_bar.dart';
import 'package:savenest/widgets/main_mobile_drawer.dart';

class AdvertiseWithUsScreen extends StatelessWidget {
  const AdvertiseWithUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Update meta tags for SEO
    if (kIsWeb) {
      MetaSEO meta = MetaSEO();
      meta.nameContent(name: 'title', content: 'Partner with SaveNest | Advertise Your Services');
      meta.nameContent(name: 'description', content: 'Connect with a growing audience of savvy Australian households. Learn about our promotional opportunities and how to partner with SaveNest.');
      meta.ogTitle(ogTitle: 'Partner with SaveNest | Advertise Your Services');
      meta.ogDescription(ogDescription: 'Connect with a growing audience of savvy Australian households. Learn about our promotional opportunities and how to partner with SaveNest.');
      meta.propertyContent(property: 'og:url', content: 'https://www.savenest.com.au/partners/advertise');
      meta.ogImage(ogImage: 'https://www.savenest.com.au/assets/images/logo.png');
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

                  _buildSectionTitle('For Partners'),
            const SizedBox(height: 16),
            _buildBodyText(
                'SaveNest is a rapidly growing Australian comparison platform helping households make smarter decisions and save money on their essential services. We connect with high-intent customers at the exact moment they are looking to switch providers.'),
            const SizedBox(height: 32),
            _buildSectionTitle('Our Audience'),
            const SizedBox(height: 16),
            _buildAudienceItem('Demographic',
                'Primarily Australian households, aged 25-55, who are budget-conscious and actively looking for better deals on utilities and services.'),
            _buildAudienceItem('Location Focus',
                'Capital cities and major regional centers in NSW, VIC, and QLD, with planned expansion nationwide.'),
            _buildAudienceItem('Key Pain Points',
                'Rising cost of living, confusing utility plans, loyalty tax from existing providers, and a lack of time to research alternatives effectively.'),
            const SizedBox(height: 32),
            _buildSectionTitle('Promotional Channels'),
            const SizedBox(height: 16),
            _buildChannelItem('Website Comparison Pages',
                'Directly compare providers for electricity, gas, internet, and mobile.'),
            _buildChannelItem('Educational Blog Posts',
                'In-depth guides, reviews, and money-saving tips that attract organic search traffic.'),
            _buildChannelItem('Email Newsletter',
                'A growing list of subscribers receiving curated deals and market updates.'),
            _buildChannelItem(
                'Social Media', 'Engaging content on platforms like Facebook and Instagram.'),
            const SizedBox(height: 32),
            _buildSectionTitle('Example Placements'),
            const SizedBox(height: 16),
            _buildPlacementItem('Featured Partner on Category Page',
                'Top-of-page placement with enhanced branding in our comparison tables.'),
            _buildPlacementItem('Inclusion in "Best Deals This Month" Article',
                'Showcase your offer in our popular monthly roundup blog post.'),
            _buildPlacementItem('Inclusion in "New Customer Offers" Email',
                'Directly reach our engaged email subscribers with your latest promotions.'),
            const SizedBox(height: 32),
            _buildSectionTitle('Contact Us'),
            const SizedBox(height: 16),
            _buildBodyText(
                'We partner with brands primarily through affiliate networks like Commission Factory, Impact, and others. For all partnership inquiries, please contact our team.'),
            const SizedBox(height: 16),
            const Row(
              children: [
                Icon(Icons.email, color: AppTheme.vibrantEmerald),
                SizedBox(width: 8),
                Text(
                  'contact@savenest.au',
                  style: TextStyle(
                    color: AppTheme.vibrantEmerald,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
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

  Widget _buildAudienceItem(String title, String description) {
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

  Widget _buildChannelItem(String title, String description) {
    return _buildAudienceItem(title, description);
  }

  Widget _buildPlacementItem(String title, String description) {
    return _buildAudienceItem(title, description);
  }
}
