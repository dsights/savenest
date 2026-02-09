import 'package:flutter/material.dart';
import 'package:savenest/theme/app_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:meta_seo/meta_seo.dart';
import 'package:go_router/go_router.dart';

import 'package:savenest/widgets/main_navigation_bar.dart';
import 'package:savenest/widgets/main_mobile_drawer.dart';

class SitemapScreen extends StatelessWidget {
  const SitemapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      MetaSEO meta = MetaSEO();
      meta.nameContent(name: 'title', content: 'Sitemap | SaveNest');
      meta.nameContent(name: 'description', content: 'Explore the full site structure of SaveNest to easily find what you are looking for.');
      meta.ogTitle(ogTitle: 'Sitemap | SaveNest');
      meta.ogDescription(ogDescription: 'Explore the full site structure of SaveNest to easily find what you are looking for.');
      meta.propertyContent(property: 'og:url', content: 'https://www.savenest.com.au/sitemap');
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
                  Text(
                    'Sitemap',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'This is a placeholder for the Sitemap content. Please add the actual sitemap links here.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white70,
                        ),
                  ),
                  const SizedBox(height: 24),
                  _buildSitemapLink(context, 'Home', '/'),
                  _buildSitemapLink(context, 'Savings Calculator', '/savings'),
                  _buildSitemapLink(context, 'Electricity Deals', '/deals/electricity'),
                  _buildSitemapLink(context, 'Gas Deals', '/deals/gas'),
                  _buildSitemapLink(context, 'Internet Deals', '/deals/internet'),
                  _buildSitemapLink(context, 'Mobile Deals', '/deals/mobile'),
                  _buildSitemapLink(context, 'Blog', '/blog'), // Assuming a general blog page exists
                  _buildSitemapLink(context, 'About Us', '/about'),
                  _buildSitemapLink(context, 'How It Works', '/how-it-works'),
                  _buildSitemapLink(context, 'Privacy Policy', '/privacy'),
                  _buildSitemapLink(context, 'Terms of Service', '/terms'),
                  _buildSitemapLink(context, 'Disclaimer', '/legal/disclaimer'),
                  _buildSitemapLink(context, 'Partner With Us', '/partners/advertise'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSitemapLink(BuildContext context, String title, String route) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: () => GoRouter.of(context).go(route),
        child: Text(
          title,
          style: const TextStyle(
            color: AppTheme.vibrantEmerald,
            fontSize: 16,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }
}
