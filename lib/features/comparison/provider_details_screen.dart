import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta_seo/meta_seo.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
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
    final officialUrl = _providerUrls[providerSlug] ?? 'https://savenest.au';

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
                              label: Text('VISIT OFFICIAL SITE'),
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

  void _launchURL(String url) async {
    // Import url_launcher if needed, but assuming helper exists elsewhere or using dart:js
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

// Mapping from Slugs to Official URLs
const Map<String, String> _providerUrls = {
  '1st-energy': 'https://1stenergy.com.au',
  'adt-security': 'https://www.adt.com.au/products',
  'agl': 'https://www.agl.com.au/residential/energy-plans',
  'aldi-mobile': 'https://www.aldimobile.com.au/plans',
  'actewagl': 'https://www.actewagl.com.au/plans',
  'activ8me': 'https://www.activ8me.net.au/nbn-plans',
  'alinta-energy': 'https://alintaenergy.com.au/residential/plans',
  'amber-electric': 'https://amber.com.au/pricing',
  'arctel': 'https://arctel.com.au',
  'aurora-energy': 'https://www.auroraenergy.com.au/plans',
  'aussie-broadband': 'https://www.aussiebroadband.com.au/internet/nbn-plans/',
  'belong': 'https://www.belong.com.au/go/internet',
  'boost-mobile': 'https://www.boost.com.au/plans',
  'buddy-telco': 'https://www.buddytelco.com.au/',
  'budget-direct': 'https://www.budgetdirect.com.au',
  'coles-mobile': 'https://www.colesmobile.com.au/plans',
  'covau-energy': 'https://www.covau.com.au/plans',
  'diamond-energy': 'https://diamondenergy.com.au/plans',
  'dodo': 'https://www.dodo.com/energy-plans',
  'engie': 'https://www.engie.com.au/plans',
  'energy-locals': 'https://energylocals.com.au/plans',
  'energy-matters': 'https://www.energymatters.com.au/solar-power',
  'energyaustralia': 'https://www.energyaustralia.com.au/plans',
  'everyday-mobile': 'https://www.woolworthsmobile.com.au/plans',
  'exetel': 'https://www.exetel.com.au/broadband/nbn',
  'felix-mobile': 'https://www.felixmobile.com.au/plans',
  'flip': 'https://www.flip.com.au/',
  'globird-energy': 'https://globirdenergy.com.au/plans',
  'kleenheat': 'https://www.kleenheat.com.au/plans',
  'kogan': 'https://www.koganinternet.com.au/plans',
  'launtel': 'https://launtel.net.au/nbn-plans',
  'lebara': 'https://www.lebara.com.au/plans',
  'lumo-energy': 'https://www.lumoenergy.com.au/energy-plans',
  'mate': 'https://www.letsbemates.com.au/plans',
  'momentum-energy': 'https://www.momentumenergy.com.au/plans',
  'moose-mobile': 'https://moosemobile.com.au/plans',
  'more': 'https://www.more.com.au/nbn-plans',
  'nectr': 'https://nectr.com.au/plans',
  'ovo-energy': 'https://ovoenergy.com.au/plans',
  'optus': 'https://www.optus.com.au/broadband-nbn/home-broadband/plans',
  'origin-energy': 'https://www.originenergy.com.au/energy-plans',
  'powershop': 'https://powershop.com.au/plans',
  'red-energy': 'https://www.redenergy.com.au/plans',
  'ring': 'https://ring.com/au/en/home-security-cameras',
  'solar-choice': 'https://www.solarchoice.com.au/solar-panels',
  'southern-phone': 'https://www.southernphone.com.au/personal/broadband/nbn-broadband',
  'spintel': 'https://www.spintel.net.au/home-internet/nbn',
  'sumo': 'https://www.sumoelectrical.com.au/plans',
  'superloop': 'https://superloop.com/consumer/home-broadband/nbn.html',
  'swoop': 'https://swoopbroadband.com.au/nbn',
  'synergy': 'https://www.synergy.net.au/Residential/Plans',
  'tpg': 'https://www.tpg.com.au/nbn',
  'tangerine-telecom': 'https://www.tangerine.com.au/nbn/nbn-broadband',
  'tango-energy': 'https://tangoenergy.com.au/plans',
  'telsim': 'https://www.telsim.com.au/plans',
  'telstra': 'https://www.telstra.com.au/internet/nbn',
  'vodafone': 'https://www.vodafone.com.au/nbn',
  'wuuk-labs': 'https://wuuklabs.com/collections/all',
  'amaysim': 'https://www.amaysim.com.au/plans',
  'iinet': 'https://www.iinet.net.au/nbn',
};
