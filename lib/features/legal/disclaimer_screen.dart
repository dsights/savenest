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
                  Text(
                    'Disclaimer',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'This is a placeholder for the Disclaimer content. Please add the actual legal disclaimer text here.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white70,
                        ),
                  ),
                  // Add more disclaimer content here as needed
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
