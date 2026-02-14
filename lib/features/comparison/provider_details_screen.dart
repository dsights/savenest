import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta_seo/meta_seo.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_theme.dart';
import 'package:savenest/features/comparison/provider_data.dart';
import 'comparison_provider.dart';
import 'comparison_model.dart';
import 'widgets/deal_card.dart';
import '../../widgets/main_navigation_bar.dart';
import '../../widgets/main_mobile_drawer.dart';
import '../home/widgets/modern_footer.dart';

class ProviderDetailsScreen extends ConsumerWidget {
  final String providerSlug;

  const ProviderDetailsScreen({super.key, required this.providerSlug});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Resolve Provider Name from Slug (e.g. 'telstra' -> 'Telstra')
    final providerName = _deSlugify(providerSlug);
    final officialUrl = providerUrls[providerSlug] ?? 'https://savenest.au';

    // 2. Fetch All Deals for this Provider
    // We can reuse the repository but filter by providerName
    final allDealsAsync = ref.watch(providerDealsProvider(providerName));

    if (kIsWeb) {
      final title = '$providerName Plans, Reviews & Comparison Australia | SaveNest';
      final description = 'Compare all $providerName plans for electricity, gas, internet, and mobile. Find the best value $providerName deals and save on your monthly bills.';
      MetaSEO().author(author: 'SaveNest Team');
      MetaSEO().description(description: description);
      MetaSEO().ogTitle(ogTitle: title);
      MetaSEO().ogDescription(ogDescription: description);
    }

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
                  // Hero Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
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
                        child: Column(
                          children: [
                            const Text(
                              'PROVIDER DIRECTORY',
                              style: TextStyle(color: AppTheme.vibrantEmerald, fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 12),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              providerName,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Compare all available plans and products from $providerName in one place.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white70, fontSize: 18),
                            ),
                            const SizedBox(height: 32),
                            ElevatedButton.icon(
                              onPressed: () => _launchURL(officialUrl),
                              icon: const Icon(Icons.open_in_new, size: 18),
                              label: const Text('VISIT OFFICIAL SITE'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: AppTheme.deepNavy,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Deals Grid
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1400),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Available $providerName Plans',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: AppTheme.deepNavy,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text('Independent comparison of current market offers.', style: TextStyle(color: AppTheme.slate600)),
                            const SizedBox(height: 40),
                            
                            allDealsAsync.when(
                              data: (deals) {
                                if (deals.isEmpty) {
                                  return const Center(child: Text('No active plans found for this provider.'));
                                }
                                return LayoutBuilder(
                                  builder: (context, constraints) {
                                    final crossAxisCount = constraints.maxWidth > 1200 ? 4 : constraints.maxWidth > 800 ? 3 : constraints.maxWidth > 600 ? 2 : 1;
                                    return GridView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: crossAxisCount,
                                        childAspectRatio: 1.0,
                                        mainAxisSpacing: 24,
                                        crossAxisSpacing: 24,
                                      ),
                                      itemCount: deals.length,
                                      itemBuilder: (context, index) => DealCard(deal: deals[index]),
                                    );
                                  }
                                );
                              },
                              loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.accentOrange)),
                              error: (err, stack) => Center(child: Text('Error: $err')),
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
          ),
        ],
      ),
    );
  }

  String _deSlugify(String slug) {
    // Hardcoded overrides for consistency with products.json providerNames
    final overrides = {
      'agl': 'AGL',
      'nbn': 'NBN',
      'tpg': 'TPG',
      'actewagl': 'ActewAGL',
      'amaysim': 'amaysim',
      'iinet': 'iiNet',
    };
    if (overrides.containsKey(slug)) return overrides[slug]!;
    
    return slug.split('-').map((word) {
      if (word.isEmpty) return "";
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      debugPrint('Could not launch $url');
    }
  }
}

final providerDealsProvider = FutureProvider.family<List<Deal>, String>((ref, providerName) async {
  final repo = ref.watch(productRepositoryProvider);
  final allCats = ProductCategory.values;
  List<Deal> results = [];
  
  for (var cat in allCats) {
    if (cat == ProductCategory.creditCards) continue; // Skip for now as it uses different model
    final deals = await repo.getDeals(cat);
    results.addAll(deals.where((d) => d.providerName.toLowerCase().contains(providerName.toLowerCase())));
  }
  return results;
});
