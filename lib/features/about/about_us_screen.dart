import 'package:flutter/material.dart';
import 'package:meta_seo/meta_seo.dart';
import 'package:savenest/theme/app_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:savenest/widgets/main_navigation_bar.dart';
import 'package:savenest/widgets/main_mobile_drawer.dart';
import 'package:savenest/widgets/page_hero.dart';
import 'package:savenest/features/home/widgets/modern_footer.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      MetaSEO meta = MetaSEO();
      const String title = 'About SaveNest | Australia\'s Smart Utility Comparison Site';
      const String description = 'Learn about SaveNest\'s mission to help Australians save money on utilities. Discover our story, our commitment to independent comparisons, and our business details.';
      const String imageUrl = 'https://savenest.au/assets/assets/images/hero_energy.jpg';

      meta.nameContent(name: 'title', content: title);
      meta.nameContent(name: 'description', content: description);
      meta.ogTitle(ogTitle: title);
      meta.ogDescription(ogDescription: description);
      meta.propertyContent(property: 'og:url', content: 'https://savenest.au/about');
      meta.ogImage(ogImage: imageUrl);
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
          children: [
            const MainNavigationBar(),
            const PageHero(
              badge: 'Our Mission',
              title: 'Empowering Australians to Save',
              subtitle: 'SaveNest was founded to help you navigate the confusing world of household utilities and financial products. We bring transparency and savings to every Australian home.',
            ),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoSection(
                        context,
                        'Our Story',
                        'SaveNest was founded with a simple mission: to help Australians navigate the confusing and often expensive world of household utilities and financial products. Our founders, with their background in utilities, real estate, and finance, saw firsthand how much money people were losing simply by not being on the right plan.',
                        'assets/images/home_ins.png',
                      ),
                      const SizedBox(height: 80),
                      _buildInfoSection(
                        context,
                        'Our Commitment',
                        'We believe that everyone deserves to get the best value for their money. We are committed to providing a free, independent, and easy-to-use platform that helps you compare with confidence and save with ease.',
                        'assets/images/energy.png',
                        reverse: true,
                      ),
                      const SizedBox(height: 80),
                      Container(
                        padding: const EdgeInsets.all(40),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Business Details',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    color: AppTheme.deepNavy,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 32),
                            _buildBusinessDetail('Registered Business Name', 'Pratham Technologies Pty Ltd'),
                            _buildBusinessDetail('ABN', '89 691 841 059'),
                            _buildBusinessDetail('Location', 'Melbourne, Australia'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const ModernFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, String title, String text, String imagePath, {bool reverse = false}) {
    final isMobile = MediaQuery.of(context).size.width < 800;
    final content = [
      Expanded(
        flex: isMobile ? 0 : 1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppTheme.deepNavy,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            Text(
              text,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.slate600,
                  ),
            ),
          ],
        ),
      ),
      if (!isMobile) const SizedBox(width: 80),
      if (isMobile) const SizedBox(height: 40),
      Expanded(
        flex: isMobile ? 0 : 1,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Image.asset(
            imagePath,
            fit: BoxFit.cover,
            height: 300,
          ),
        ),
      ),
    ];

    return Flex(
      direction: isMobile ? Axis.vertical : Axis.horizontal,
      children: reverse && !isMobile ? content.reversed.toList() : content,
    );
  }

  Widget _buildBusinessDetail(String title, String detail) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title: ',
            style: const TextStyle(
              color: AppTheme.deepNavy,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Expanded(
            child: Text(
              detail,
              style: const TextStyle(
                color: AppTheme.slate600,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
