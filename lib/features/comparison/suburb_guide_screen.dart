import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:meta_seo/meta_seo.dart';
import '../../theme/app_theme.dart';
import '../../widgets/main_navigation_bar.dart';
import '../../widgets/main_mobile_drawer.dart';
import 'package:savenest/services/seo_service.dart';

class SuburbGuideScreen extends StatelessWidget {
  final String stateCode;
  final String suburbSlug;
  final String utility;

  const SuburbGuideScreen({
    super.key,
    required this.stateCode,
    required this.suburbSlug,
    required this.utility,
  });

  String get suburbName => suburbSlug.split('-').map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}').join(' ');
  String get stateName => _stateNames[stateCode.toLowerCase()] ?? stateCode.toUpperCase();
  String get utilityLabel => '${utility[0].toUpperCase()}${utility.substring(1)}';
  String get utilityPath => '/deals/$utility';

  static const _stateNames = {
    'nsw': 'New South Wales', 'vic': 'Victoria', 'qld': 'Queensland',
    'sa': 'South Australia', 'wa': 'Western Australia',
    'tas': 'Tasmania', 'act': 'ACT', 'nt': 'Northern Territory',
  };

  static const _stateRebates = {
    'nsw': 'Family Energy Rebate (\$180/yr), Low Income Household Rebate (\$285/yr), Seniors Energy Rebate (\$200/yr)',
    'vic': 'Annual Electricity Concession (17.5% off usage), Utility Relief Grant Scheme (URGS) for hardship',
    'qld': 'Electricity Rebate (\$372/yr for eligible pensioners), Cost of Living Rebate applied directly to bills',
    'sa': 'Energy Bill Concession (up to \$263/yr), Retailer Energy Productivity Scheme (REPS)',
    'wa': 'Hardship Utilities Grant Scheme (HUGS) up to \$1,500/yr, Energy Assistance Payment',
    'tas': 'Electricity Concession, TasNetworks hardship program',
    'act': 'Energy Efficiency Improvement Scheme, ACOSS rebate programs',
    'nt': 'Power and Water Corporation concessions for eligible customers',
  };

  static const _stateNetworks = {
    'nsw': 'Ausgrid (Sydney metro) and Endeavour Energy (greater west/south)',
    'vic': 'AusNet Services, CitiPower, Jemena, Powercor, and United Energy',
    'qld': 'Energex (South East QLD) and Ergon Energy (regional QLD)',
    'sa': 'SA Power Networks (ElectraNet for high voltage)',
    'wa': 'Western Power (metro) and Horizon Power (regional)',
    'tas': 'TasNetworks (transmission and distribution)',
    'act': 'Evoenergy (formerly ActewAGL Distribution)',
    'nt': 'Power and Water Corporation',
  };

  static const _avgBills = {
    'nsw': '\$1,600–\$2,100',
    'vic': '\$1,400–\$1,900',
    'qld': '\$1,500–\$2,000',
    'sa': '\$1,800–\$2,400',
    'wa': '\$1,200–\$1,700',
    'tas': '\$1,300–\$1,800',
    'act': '\$1,500–\$2,000',
    'nt': '\$1,600–\$2,200',
  };

  static const _relatedSuburbs = {
    'nsw': ['Sydney', 'Parramatta', 'Newcastle', 'Wollongong', 'Penrith', 'Liverpool', 'Blacktown'],
    'vic': ['Melbourne', 'Geelong', 'Ballarat', 'Bendigo', 'Frankston', 'Dandenong', 'Ringwood'],
    'qld': ['Brisbane', 'Gold Coast', 'Sunshine Coast', 'Townsville', 'Cairns', 'Ipswich', 'Toowoomba'],
    'sa': ['Adelaide', 'Mount Barker', 'Gawler', 'Port Adelaide', 'Norwood', 'Unley'],
    'wa': ['Perth', 'Fremantle', 'Joondalup', 'Rockingham', 'Mandurah', 'Armadale'],
    'tas': ['Hobart', 'Launceston', 'Devonport', 'Burnie'],
    'act': ['Canberra', 'Belconnen', 'Tuggeranong', 'Woden', 'Gungahlin'],
    'nt': ['Darwin', 'Alice Springs', 'Palmerston'],
  };

  @override
  Widget build(BuildContext context) {
    final title = 'Compare $utilityLabel Plans in $suburbName, $stateName | 2026 Guide';
    final description = 'Find the cheapest $utility providers available in $suburbName, $stateName. Compare plans and save up to \$500/year. Free 60-second comparison tool.';

    if (kIsWeb) {
      MetaSEO().author(author: 'SaveNest Team');
      MetaSEO().description(description: description);
      MetaSEO().keywords(keywords: 'compare $utility $suburbName, cheapest $utility $suburbName, best $utility provider $suburbName $stateName, $utility plans $suburbName 2026');
      MetaSEO().ogTitle(ogTitle: title);
      MetaSEO().ogDescription(ogDescription: description);
      SeoService.setCanonicalUrl('https://savenest.au/suburb/$stateCode/$suburbSlug/$utility');
      SeoService.injectJsonLd({
        '@context': 'https://schema.org',
        '@type': 'Article',
        'headline': title,
        'description': description,
        'author': {'@type': 'Organization', 'name': 'SaveNest Team'},
        'publisher': {'@type': 'Organization', 'name': 'SaveNest Australia', 'logo': {'@type': 'ImageObject', 'url': 'https://savenest.au/assets/assets/images/logo.png'}},
        'mainEntityOfPage': {'@type': 'WebPage', '@id': 'https://savenest.au/suburb/$stateCode/$suburbSlug/$utility'}
      });
    }

    final rebates = _stateRebates[stateCode.toLowerCase()] ?? 'Contact your state government for available energy rebates and concessions.';
    final network = _stateNetworks[stateCode.toLowerCase()] ?? 'Your local distribution network';
    final avgBill = _avgBills[stateCode.toLowerCase()] ?? '\$1,500–\$2,000';
    final related = _relatedSuburbs[stateCode.toLowerCase()] ?? [];

    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      endDrawer: const MainMobileDrawer(),
      body: SingleChildScrollView(
        primary: true,
        child: Column(
          children: [
            const MainNavigationBar(),

            // Hero
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
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$stateName • $utilityLabel Comparison',
                          style: const TextStyle(color: AppTheme.vibrantEmerald, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Compare $utilityLabel Plans in $suburbName',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Find the cheapest $utility providers available in $suburbName, $stateName. Save up to \$500 per year.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white70, fontSize: 18),
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton.icon(
                        onPressed: () => context.go('/deals/$utility'),
                        icon: const Icon(Icons.bolt),
                        label: Text('Compare $utilityLabel Plans Now'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Stats Row
            Container(
              color: AppTheme.vibrantEmerald,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 40,
                    runSpacing: 16,
                    children: [
                      _stat('50+', 'Providers Compared'),
                      _stat('100%', 'Free to Use'),
                      _stat('\$300–\$500', 'Avg Annual Savings'),
                      _stat('60 sec', 'Comparison Time'),
                    ],
                  ),
                ),
              ),
            ),

            // Main Content
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 860),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionHeading('Energy Providers in $suburbName'),
                      const SizedBox(height: 12),
                      Text(
                        '$suburbName sits within the $network distribution area. This means all licensed retailers in $stateName can offer you plans at this address, with electricity physically delivered through the same poles and wires regardless of which retailer you choose.',
                        style: const TextStyle(fontSize: 16, height: 1.6, color: Color(0xFF555555)),
                      ),
                      const SizedBox(height: 24),
                      _providerCard('AGL Energy', 'One of Australia\'s largest retailers. Offers flat-rate and time-of-use plans with solar buy-back.', Icons.bolt),
                      _providerCard('Origin Energy', 'Competitive market offers with GreenPower options and monthly billing flexibility.', Icons.eco),
                      _providerCard('EnergyAustralia', 'Popular no-exit-fee plans with strong customer satisfaction scores.', Icons.star),
                      _providerCard('Red Energy', '100% Australian owned. Earn Velocity Frequent Flyer points on your bill.', Icons.flight),
                      _providerCard('Alinta Energy', 'Often among the most competitive rates in $stateName — worth comparing.', Icons.savings),
                      _providerCard('Simply Energy', 'Budget-friendly online-only plans with no lock-in contracts.', Icons.check_circle),

                      const SizedBox(height: 32),
                      _sectionHeading('Typical Electricity Costs in $suburbName'),
                      const SizedBox(height: 12),
                      Text(
                        'Households in $suburbName typically pay between $avgBill per year for electricity. This is based on average residential usage for $stateName. The exact amount depends on:',
                        style: const TextStyle(fontSize: 16, height: 1.6, color: Color(0xFF555555)),
                      ),
                      const SizedBox(height: 12),
                      _bulletList([
                        'Number of people in the household (average: 2–4 kWh/person/day)',
                        'Whether you use electric heating/cooling or gas',
                        'Time-of-Use vs flat-rate tariff',
                        'Presence of solar panels (reduces net usage)',
                        'Your current provider and plan type (standing offer vs market offer)',
                      ]),

                      const SizedBox(height: 32),
                      _sectionHeading('Government Rebates for $suburbName Residents'),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.vibrantEmerald.withOpacity(0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(children: [Icon(Icons.volunteer_activism, color: AppTheme.vibrantEmerald), SizedBox(width: 8), Text('Available Rebates & Concessions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))]),
                            const SizedBox(height: 12),
                            Text(rebates, style: const TextStyle(fontSize: 15, height: 1.5)),
                            const SizedBox(height: 12),
                            const Text('Important: Contact your energy retailer to apply your concession. Rebates are not applied automatically and will not be backdated if you forget to register.', style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: Color(0xFF666666))),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),
                      _sectionHeading('How to Find the Cheapest Plan in $suburbName'),
                      const SizedBox(height: 12),
                      _numberedList([
                        'Enter your suburb or postcode in the SaveNest comparison tool below',
                        'Select your usage level (low: <15kWh/day, medium: 15–25kWh/day, high: >25kWh/day)',
                        'Filter by your priorities: no exit fee, green energy, solar feed-in tariff',
                        'Compare annual costs — look at total cost, not just the headline rate',
                        'Click "Go to Site" to complete your switch online in under 10 minutes',
                      ]),

                      const SizedBox(height: 32),
                      // CTA
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [AppTheme.deepNavy, AppTheme.primaryBlue]),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Text('Ready to Save on Your $suburbName Bill?', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                            const SizedBox(height: 8),
                            const Text('Compare all available providers in your area — free, no sign-up required.', style: TextStyle(color: Colors.white70, fontSize: 15), textAlign: TextAlign.center),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: () => context.go('/deals/$utility'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.vibrantEmerald,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                              ),
                              child: Text('Compare $utilityLabel Plans — 60 Seconds'),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),
                      _sectionHeading('Compare $utilityLabel Plans in Nearby Areas'),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: related
                            .where((s) => s.toLowerCase() != suburbName.toLowerCase())
                            .take(8)
                            .map((s) => ActionChip(
                                  label: Text(s),
                                  onPressed: () => context.go('/suburb/$stateCode/${s.toLowerCase().replaceAll(' ', '-')}/$utility'),
                                  avatar: const Icon(Icons.location_on, size: 16),
                                ))
                            .toList(),
                      ),

                      const SizedBox(height: 32),
                      _sectionHeading('More $stateName Energy Guides'),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ActionChip(label: const Text('Electricity Guide'), onPressed: () => context.go('/guides/$stateCode/electricity')),
                          ActionChip(label: const Text('Gas Guide'), onPressed: () => context.go('/guides/$stateCode/gas')),
                          ActionChip(label: const Text('Internet Guide'), onPressed: () => context.go('/guides/$stateCode/internet')),
                          ActionChip(label: const Text('Compare All Providers'), onPressed: () => context.go('/providers')),
                        ],
                      ),
                      const SizedBox(height: 60),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(String value, String label) => Column(
        children: [
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 13)),
        ],
      );

  Widget _sectionHeading(String text) => Text(text, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.deepNavy));

  Widget _providerCard(String name, String description, IconData icon) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE0E0E0)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppTheme.vibrantEmerald.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: AppTheme.vibrantEmerald, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text(description, style: const TextStyle(color: Color(0xFF666666), fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _bulletList(List<String> items) => Column(
        children: items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(padding: EdgeInsets.only(top: 6, right: 10), child: Icon(Icons.check_circle, size: 16, color: AppTheme.vibrantEmerald)),
              Expanded(child: Text(item, style: const TextStyle(fontSize: 15, height: 1.5, color: Color(0xFF555555)))),
            ],
          ),
        )).toList(),
      );

  Widget _numberedList(List<String> items) => Column(
        children: items.asMap().entries.map((e) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28, height: 28,
                decoration: const BoxDecoration(color: AppTheme.vibrantEmerald, shape: BoxShape.circle),
                child: Center(child: Text('${e.key + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
              ),
              const SizedBox(width: 12),
              Expanded(child: Padding(padding: const EdgeInsets.only(top: 4), child: Text(e.value, style: const TextStyle(fontSize: 15, height: 1.5, color: Color(0xFF555555))))),
            ],
          ),
        )).toList(),
      );
}
