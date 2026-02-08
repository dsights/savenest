import 'package:flutter/material.dart';
import 'package:meta_seo/meta_seo.dart';
import 'package:savenest/theme/app_theme.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MetaSeo(
      metaData: const MetaData(
        title: 'About SaveNest | Australia\'s Smart Utility Comparison Site',
        description:
            'Learn about SaveNest\'s mission to help Australians save money on utilities. Discover our story, our commitment to independent comparisons, and our business details.',
      ),
      child: Scaffold(
        backgroundColor: AppTheme.deepNavy,
        appBar: AppBar(
          title: Seo.text(
            text: 'About Us',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: AppTheme.deepNavy,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Our Story'),
              const SizedBox(height: 16),
              _buildBodyText(
                  'SaveNest was founded with a simple mission: to help Australians navigate the confusing and often expensive world of household utilities and financial products. Our founders, with their background in utilities, real estate, and finance, saw firsthand how much money people were losing simply by not being on the right plan.'),
              const SizedBox(height: 32),
              _buildSectionTitle('Our Mission'),
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

  Widget _buildBusinessDetail(String title, String detail) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Text(
            '$title: ',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            detail,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
