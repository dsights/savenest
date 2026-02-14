import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:meta_seo/meta_seo.dart';
import 'package:flutter/foundation.dart';
import '../../theme/app_theme.dart';
import 'provider_data.dart';
import '../../widgets/main_navigation_bar.dart';
import '../../widgets/main_mobile_drawer.dart';
import '../home/widgets/modern_footer.dart';

class ProviderDirectoryScreen extends StatelessWidget {
  const ProviderDirectoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      MetaSEO().author(author: 'SaveNest Team');
      MetaSEO().description(description: 'Browse our directory of Australian utility providers. Compare plans from Telstra, Optus, AGL, Origin and 50+ other brands.');
      MetaSEO().ogTitle(ogTitle: 'Provider Directory | Compare All Utility Brands | SaveNest');
    }

    final providers = providerUrls.keys.toList()..sort();

    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      endDrawer: const MainMobileDrawer(),
      body: Column(
        children: [
          const MainNavigationBar(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Hero
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [AppTheme.deepNavy, AppTheme.primaryBlue],
                      ),
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1000),
                        child: const Column(
                          children: [
                            Text(
                              'OUR PARTNERS',
                              style: TextStyle(color: AppTheme.vibrantEmerald, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Provider Directory',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'We compare 50+ Australian brands to find you the best value. Browse our full list of providers below.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white70, fontSize: 20),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Directory Grid
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1200),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 3,
                          ),
                          itemCount: providers.length,
                          itemBuilder: (context, index) {
                            final slug = providers[index];
                            final name = _deSlugify(slug);
                            return InkWell(
                              onTap: () => context.push('/provider/$slug'),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppTheme.slate300.withOpacity(0.5)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.02),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  name,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: AppTheme.deepNavy,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  const ModernFooter(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _deSlugify(String slug) {
    final overrides = {
      'agl': 'AGL',
      'nbn': 'NBN',
      'tpg': 'TPG',
      'actewagl': 'ActewAGL',
      'amaysim': 'amaysim',
      'iinet': 'iiNet',
      'adt-security': 'ADT Security',
      '1st-energy': '1st Energy',
    };
    if (overrides.containsKey(slug)) return overrides[slug]!;
    
    return slug.split('-').map((word) {
      if (word.isEmpty) return "";
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }
}
