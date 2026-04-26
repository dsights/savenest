import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta_seo/meta_seo.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../widgets/main_navigation_bar.dart';
import '../../widgets/main_mobile_drawer.dart';
import '../home/widgets/modern_footer.dart';
import 'package:savenest/services/seo_service.dart';

// Suburb data model
class SuburbData {
  final String name;
  final String state;
  final String stateCode;
  final String distributor;
  final String postcode;
  final String averageAnnualCost;
  final String averageKwh;
  final String cheapestProvider;
  final String cheapestCost;
  final String savingsVsDefault;
  final String marketOverview;
  final String topProviders;
  final String keyRebates;

  const SuburbData({
    required this.name,
    required this.state,
    required this.stateCode,
    required this.distributor,
    required this.postcode,
    required this.averageAnnualCost,
    required this.averageKwh,
    required this.cheapestProvider,
    required this.cheapestCost,
    required this.savingsVsDefault,
    required this.marketOverview,
    required this.topProviders,
    required this.keyRebates,
  });
}

final _suburbDatabase = <String, SuburbData>{
  'parramatta': const SuburbData(
    name: 'Parramatta',
    state: 'New South Wales',
    stateCode: 'nsw',
    distributor: 'Endeavour Energy',
    postcode: '2150',
    averageAnnualCost: '\$1,750',
    averageKwh: '5,200 kWh/year',
    cheapestProvider: 'Alinta Energy',
    cheapestCost: '~\$1,350/year',
    savingsVsDefault: '\$400',
    marketOverview: 'Parramatta sits on the Endeavour Energy distribution network in Western Sydney. Residents have access to all major NSW electricity retailers, with over 30 providers competing for customers. The NSW Default Market Offer (DMO) for the Endeavour zone is approximately \$1,850/year for typical usage, giving active market participants significant savings potential.',
    topProviders: 'Alinta Energy, Red Energy, Simply Energy, AGL, Origin Energy',
    keyRebates: 'NSW Low Income Household Rebate (\$285/year), NSW Family Energy Rebate (\$180/year), NSW Life Support Rebate',
  ),
  'bondi': const SuburbData(
    name: 'Bondi',
    state: 'New South Wales',
    stateCode: 'nsw',
    distributor: 'Ausgrid',
    postcode: '2026',
    averageAnnualCost: '\$1,680',
    averageKwh: '4,800 kWh/year',
    cheapestProvider: 'Alinta Energy',
    cheapestCost: '~\$1,310/year',
    savingsVsDefault: '\$370',
    marketOverview: 'Bondi and Eastern Sydney suburbs sit on the Ausgrid distribution network. Being a predominantly apartment and terrace-house suburb, average electricity usage is slightly lower than outer suburban areas. Residents benefit from access to all NSW electricity retailers, with competitive flat-rate and time-of-use plans available.',
    topProviders: 'Alinta Energy, Simply Energy, Red Energy, Powershop, AGL',
    keyRebates: 'NSW Low Income Household Rebate (\$285/year), NSW Seniors Energy Rebate (\$200/year)',
  ),
  'chatswood': const SuburbData(
    name: 'Chatswood',
    state: 'New South Wales',
    stateCode: 'nsw',
    distributor: 'Ausgrid',
    postcode: '2067',
    averageAnnualCost: '\$1,850',
    averageKwh: '5,500 kWh/year',
    cheapestProvider: 'Simply Energy',
    cheapestCost: '~\$1,410/year',
    savingsVsDefault: '\$440',
    marketOverview: 'Chatswood on Sydney\'s North Shore is served by Ausgrid. Average household energy usage is slightly higher due to larger homes and high rates of ducted air conditioning. All major NSW electricity retailers compete in this zone, with strong TOU plan options for households with smart meters.',
    topProviders: 'Simply Energy, Alinta Energy, Red Energy, EnergyAustralia, Origin Energy',
    keyRebates: 'NSW Low Income Household Rebate (\$285/year), NSW Seniors Energy Rebate (\$200/year)',
  ),
  'brunswick': const SuburbData(
    name: 'Brunswick',
    state: 'Victoria',
    stateCode: 'vic',
    distributor: 'Jemena',
    postcode: '3056',
    averageAnnualCost: '\$1,420',
    averageKwh: '4,200 kWh/year',
    cheapestProvider: 'Powershop',
    cheapestCost: '~\$1,140/year',
    savingsVsDefault: '\$280',
    marketOverview: 'Brunswick in Melbourne\'s inner north sits on the Jemena distribution network. As a predominantly terrace and apartment suburb, average electricity consumption is lower than outer Melbourne. All Victorian retailers compete here, and the mandatory smart meter rollout means all households have access to Time-of-Use tariffs.',
    topProviders: 'Powershop, Alinta Energy, Momentum Energy, EnergyAustralia, Red Energy',
    keyRebates: 'VIC Annual Electricity Concession (17.5% off usage), VIC Winter Energy Credit (\$250)',
  ),
  'richmond': const SuburbData(
    name: 'Richmond',
    state: 'Victoria',
    stateCode: 'vic',
    distributor: 'CitiPower',
    postcode: '3121',
    averageAnnualCost: '\$1,380',
    averageKwh: '4,100 kWh/year',
    cheapestProvider: 'Alinta Energy',
    cheapestCost: '~\$1,115/year',
    savingsVsDefault: '\$265',
    marketOverview: 'Richmond in Melbourne\'s inner east is on the CitiPower distribution network, covering the CBD and inner suburbs. Typical usage is lower due to apartment density. Victoria\'s mandatory smart meters mean excellent access to off-peak TOU rates, making Richmond households well-placed for bill optimisation.',
    topProviders: 'Alinta Energy, Powershop, EnergyAustralia TOU, Momentum Energy, AGL',
    keyRebates: 'VIC Annual Electricity Concession (17.5% off usage), VIC Winter Energy Credit (\$250)',
  ),
  'fitzroy': const SuburbData(
    name: 'Fitzroy',
    state: 'Victoria',
    stateCode: 'vic',
    distributor: 'CitiPower',
    postcode: '3065',
    averageAnnualCost: '\$1,360',
    averageKwh: '4,000 kWh/year',
    cheapestProvider: 'Alinta Energy',
    cheapestCost: '~\$1,095/year',
    savingsVsDefault: '\$265',
    marketOverview: 'Fitzroy is a high-density inner-Melbourne suburb on the CitiPower network. Low average consumption (mainly apartments and terraces) combined with Victoria\'s competitive retail market means significant saving potential. Smart meters enable access to the cheapest off-peak TOU rates in Australia.',
    topProviders: 'Alinta Energy, Powershop, Momentum Energy, EnergyAustralia, Red Energy',
    keyRebates: 'VIC Annual Electricity Concession (17.5% off usage), VIC Winter Energy Credit (\$250)',
  ),
  'newstead': const SuburbData(
    name: 'Newstead',
    state: 'Queensland',
    stateCode: 'qld',
    distributor: 'Energex',
    postcode: '4006',
    averageAnnualCost: '\$1,820',
    averageKwh: '5,800 kWh/year',
    cheapestProvider: 'Origin Energy',
    cheapestCost: '~\$1,580/year',
    savingsVsDefault: '\$240',
    marketOverview: 'Newstead in inner Brisbane sits on the Energex distribution network. Queensland\'s electricity market is semi-deregulated, with major retailers competing for inner Brisbane customers. High air conditioning usage drives above-average consumption. Solar penetration in Queensland is among the highest in the world, with strong FiT options available.',
    topProviders: 'Origin Energy, AGL, EnergyAustralia, Red Energy, Alinta Energy',
    keyRebates: 'QLD Electricity Rebate (\$372/year for pensioners/seniors), QLD Asset Ownership Dividend (\$50/year for all households)',
  ),
  'fortitude-valley': const SuburbData(
    name: 'Fortitude Valley',
    state: 'Queensland',
    stateCode: 'qld',
    distributor: 'Energex',
    postcode: '4006',
    averageAnnualCost: '\$1,740',
    averageKwh: '5,500 kWh/year',
    cheapestProvider: 'AGL',
    cheapestCost: '~\$1,530/year',
    savingsVsDefault: '\$210',
    marketOverview: 'Fortitude Valley is a high-density Brisbane suburb on the Energex network. A mix of apartments and commercial properties means varied usage profiles. Queensland\'s solar incentives remain strong, and high summer temperatures drive significant cooling costs — making provider comparison particularly valuable.',
    topProviders: 'AGL, Origin Energy, EnergyAustralia, Alinta Energy, Red Energy',
    keyRebates: 'QLD Electricity Rebate (\$372/year), QLD Asset Ownership Dividend (\$50/year)',
  ),
  'norwood': const SuburbData(
    name: 'Norwood',
    state: 'South Australia',
    stateCode: 'sa',
    distributor: 'SA Power Networks',
    postcode: '5067',
    averageAnnualCost: '\$1,980',
    averageKwh: '5,200 kWh/year',
    cheapestProvider: 'AGL',
    cheapestCost: '~\$1,720/year',
    savingsVsDefault: '\$260',
    marketOverview: 'Norwood in Adelaide\'s inner east is served by SA Power Networks. South Australia has the highest electricity prices in mainland Australia, but also the strongest solar market and most developed VPP (Virtual Power Plant) ecosystem. Households with solar and battery storage can achieve some of the best bill outcomes nationally through SA\'s VPP programs.',
    topProviders: 'AGL, Origin Energy, EnergyAustralia, Simply Energy, Lumo Energy',
    keyRebates: 'SA Energy Bill Concession (up to \$263/year), SA Cost of Living Concession, SA Home Battery Scheme rebates',
  ),
  'subiaco': const SuburbData(
    name: 'Subiaco',
    state: 'Western Australia',
    stateCode: 'wa',
    distributor: 'Western Power',
    postcode: '6008',
    averageAnnualCost: '\$1,620',
    averageKwh: '6,200 kWh/year',
    cheapestProvider: 'Synergy',
    cheapestCost: '~\$1,580/year',
    savingsVsDefault: '\$40',
    marketOverview: 'Subiaco in Perth\'s western suburbs is served by Western Power and Synergy (the dominant retailer). Unlike eastern states, Western Australia has a regulated electricity market with limited retailer competition. Synergy is the main provider for most residential customers. Solar is highly attractive in Perth\'s sunny climate, with the government Distributed Energy Buyback Scheme (DEBS) paying 10 c/kWh.',
    topProviders: 'Synergy (dominant), Horizon Power (regional only)',
    keyRebates: 'WA Hardship Utility Grant Scheme, WA Energy Assistance Payment (\$348/year for eligible concession holders)',
  ),
  'kingston': const SuburbData(
    name: 'Kingston',
    state: 'Australian Capital Territory',
    stateCode: 'act',
    distributor: 'Evoenergy',
    postcode: '2604',
    averageAnnualCost: '\$1,920',
    averageKwh: '6,800 kWh/year',
    cheapestProvider: 'Origin Energy',
    cheapestCost: '~\$1,760/year',
    savingsVsDefault: '\$160',
    marketOverview: 'Kingston in Canberra\'s inner south is on the Evoenergy distribution network. The ACT has above-average consumption driven by cold winters and higher-than-average home sizes. The ACT has committed to 100% renewable electricity through its large-scale renewable energy auction scheme, though retail prices remain high. Limited retailer competition compared to NSW and VIC.',
    topProviders: 'ActewAGL (dominant), Origin Energy, AGL, EnergyAustralia',
    keyRebates: 'ACT Energy Support Payment, ACT Concession Card Energy Rebate (\$700+ for eligible households)',
  ),
};

final suburbGuideProvider = Provider.family<SuburbData?, String>((ref, suburb) {
  return _suburbDatabase[suburb.toLowerCase().replaceAll(' ', '-')];
});

class SuburbGuideScreen extends ConsumerWidget {
  final String suburb;
  final String utility;

  const SuburbGuideScreen({
    super.key,
    required this.suburb,
    required this.utility,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suburbData = ref.watch(suburbGuideProvider(suburb));

    final suburbDisplay = suburbData?.name ?? suburb.split('-').map((w) => '${w[0].toUpperCase()}${w.substring(1)}').join(' ');
    final stateDisplay = suburbData?.state ?? 'Australia';
    final utilityDisplay = utility[0].toUpperCase() + utility.substring(1);

    final title = 'Compare $utilityDisplay Plans in $suburbDisplay $stateDisplay | 2026 Guide';
    final description = 'Find the cheapest $utilityDisplay providers in $suburbDisplay. Compare all available plans, prices, and rebates for $suburbDisplay residents. Save up to ${suburbData?.savingsVsDefault ?? '\$400'} in 2026.';

    if (kIsWeb) {
      MetaSEO().author(author: 'SaveNest Team');
      MetaSEO().description(description: description);
      MetaSEO().keywords(keywords: 'electricity $suburbDisplay, compare energy $suburbDisplay, cheapest $utilityDisplay $suburbDisplay, best $utilityDisplay provider $suburbDisplay 2026, energy plans $suburbDisplay');
      MetaSEO().ogTitle(ogTitle: title);
      MetaSEO().ogDescription(ogDescription: description);

      SeoService.setCanonicalUrl('https://savenest.au/suburb/$suburb/$utility');
      SeoService.injectJsonLd({
        '@context': 'https://schema.org',
        '@type': 'Article',
        'headline': title,
        'description': description,
        'author': {'@type': 'Organization', 'name': 'SaveNest Team'},
        'publisher': {
          '@type': 'Organization',
          'name': 'SaveNest',
          'logo': {'@type': 'ImageObject', 'url': 'https://savenest.au/assets/assets/images/logo.png'}
        },
        'datePublished': '2026-04-27',
        'mainEntityOfPage': {'@type': 'WebPage', '@id': 'https://savenest.au/suburb/$suburb/$utility'}
      });
    }

    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      endDrawer: const MainMobileDrawer(),
      body: SingleChildScrollView(
        primary: true,
        child: Column(
          children: [
            const MainNavigationBar(),
            _buildHero(context, suburbDisplay, stateDisplay, utilityDisplay, suburbData),
            _buildBreadcrumb(context, suburbData, utilityDisplay),
            _buildContent(context, suburbDisplay, stateDisplay, utilityDisplay, suburbData),
            const ModernFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context, String suburbDisplay, String stateDisplay, String utilityDisplay, SuburbData? data) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.deepNavy, AppTheme.primaryBlue],
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${data?.stateCode.toUpperCase() ?? 'AU'} • ${data?.postcode ?? ''} • 2026 SUBURB GUIDE',
                  style: const TextStyle(
                    color: AppTheme.vibrantEmerald,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Compare $utilityDisplay Plans in $suburbDisplay',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Cheapest available: ${data?.cheapestCost ?? 'from ~\$1,200/year'} — Save up to ${data?.savingsVsDefault ?? '\$400'} vs default rate',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () => context.go('/deals/$utility'),
                icon: const Icon(Icons.bolt),
                label: Text('Compare $suburbDisplay Plans Free'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.vibrantEmerald,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBreadcrumb(BuildContext context, SuburbData? data, String utilityDisplay) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Wrap(
            spacing: 8,
            children: [
              InkWell(
                onTap: () => context.go('/'),
                child: const Text('Home', style: TextStyle(color: AppTheme.primaryBlue)),
              ),
              const Text('›', style: TextStyle(color: AppTheme.slate600)),
              if (data != null) ...[
                InkWell(
                  onTap: () => context.go('/guides/${data.stateCode}/electricity'),
                  child: Text('${data.state} Energy', style: const TextStyle(color: AppTheme.primaryBlue)),
                ),
                const Text('›', style: TextStyle(color: AppTheme.slate600)),
              ],
              Text('$utilityDisplay in ${data?.name ?? suburb}', style: const TextStyle(color: AppTheme.slate600)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, String suburbDisplay, String stateDisplay, String utilityDisplay, SuburbData? data) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Key Stats Row
              _buildStatsRow(data, suburbDisplay, utilityDisplay),
              const SizedBox(height: 48),

              // Market Overview
              _buildSectionHeading('$utilityDisplay Market in $suburbDisplay'),
              Text(
                data?.marketOverview ?? '$suburbDisplay is part of the competitive Australian electricity market. Residents have access to multiple electricity retailers, with significant savings available for households that compare and switch from the default standing offer.',
                style: const TextStyle(color: AppTheme.slate600, fontSize: 17, height: 1.7),
              ),
              const SizedBox(height: 40),

              // Top Providers
              _buildSectionHeading('Top $utilityDisplay Providers in $suburbDisplay (2026)'),
              _buildProviderList(context, data, suburbDisplay, utilityDisplay),
              const SizedBox(height: 40),

              // Rebates
              _buildSectionHeading('Rebates & Concessions for $suburbDisplay Residents'),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.vibrantEmerald.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.vibrantEmerald.withOpacity(0.3)),
                ),
                child: Text(
                  data?.keyRebates ?? 'Check with your retailer for applicable state and federal rebates. Concession card holders may be eligible for significant discounts.',
                  style: const TextStyle(color: AppTheme.deepNavy, fontSize: 16, height: 1.6),
                ),
              ),
              const SizedBox(height: 40),

              // How to Switch
              _buildSectionHeading('How to Switch $utilityDisplay Provider in $suburbDisplay'),
              _buildSwitchSteps(context, suburbDisplay, utilityDisplay),
              const SizedBox(height: 40),

              // CTA
              _buildFinalCTA(context, suburbDisplay, utilityDisplay),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow(SuburbData? data, String suburbDisplay, String utilityDisplay) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _buildStatCard('Average Annual Bill', data?.averageAnnualCost ?? '~\$1,750', Icons.receipt_long, AppTheme.slate600),
        _buildStatCard('Average Usage', data?.averageKwh ?? '~5,000 kWh/year', Icons.bolt, AppTheme.primaryBlue),
        _buildStatCard('Cheapest Available', data?.cheapestCost ?? '~\$1,300/year', Icons.savings, AppTheme.vibrantEmerald),
        _buildStatCard('Potential Saving', data?.savingsVsDefault ?? 'Up to \$400', Icons.trending_down, Colors.orange.shade700),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.slate600)),
        ],
      ),
    );
  }

  Widget _buildSectionHeading(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppTheme.deepNavy,
        ),
      ),
    );
  }

  Widget _buildProviderList(BuildContext context, SuburbData? data, String suburbDisplay, String utilityDisplay) {
    final providers = (data?.topProviders ?? 'Alinta Energy, Red Energy, Simply Energy, AGL, Origin Energy')
        .split(',')
        .map((p) => p.trim())
        .toList();

    return Column(
      children: providers.asMap().entries.map((entry) {
        final rank = entry.key + 1;
        final name = entry.value;
        final slug = name.toLowerCase().replaceAll(' ', '-').replaceAll('(', '').replaceAll(')', '').replaceAll('dominant', '').trim();
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: rank == 1 ? AppTheme.vibrantEmerald : AppTheme.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '#$rank',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: rank == 1 ? Colors.white : AppTheme.primaryBlue,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.deepNavy)),
              ),
              TextButton(
                onPressed: () => context.go('/provider/$slug'),
                child: const Text('View Plans'),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSwitchSteps(BuildContext context, String suburbDisplay, String utilityDisplay) {
    final steps = [
      'Gather your current bill — find your NMI number and current usage (kWh/quarter)',
      'Compare all available plans using the SaveNest free tool — sorted by annual cost for your address',
      'Sign up online with the cheapest provider — takes less than 10 minutes',
      'Your new provider handles the transfer — no supply interruption, 5–10 business days',
      'Check your first bill — verify rates, concessions, and feed-in tariff are correctly applied',
    ];

    return Column(
      children: steps.asMap().entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: AppTheme.primaryBlue,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${entry.key + 1}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(entry.value, style: const TextStyle(color: AppTheme.slate600, fontSize: 16, height: 1.5)),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFinalCTA(BuildContext context, String suburbDisplay, String utilityDisplay) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.deepNavy, AppTheme.primaryBlue],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            'Compare All $utilityDisplay Plans in $suburbDisplay',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text(
            'Free comparison. No sign-up. Results in 60 seconds.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.go('/deals/$utility'),
            icon: const Icon(Icons.compare_arrows),
            label: const Text('Compare Plans Free Now'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.vibrantEmerald,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
