import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:meta_seo/meta_seo.dart';
import '../../theme/app_theme.dart';
import '../../widgets/main_navigation_bar.dart';
import '../../widgets/main_mobile_drawer.dart';
import 'package:savenest/services/seo_service.dart';

class ProviderComparisonScreen extends StatelessWidget {
  final String slugA;
  final String slugB;

  const ProviderComparisonScreen({super.key, required this.slugA, required this.slugB});

  static const _providerData = {
    'agl': {
      'name': 'AGL Energy',
      'description': 'Australia\'s largest integrated energy company, serving ~4 million customers since 1837.',
      'pros': ['Large, established retailer', 'Competitive solar feed-in tariffs', 'Good digital app and tools', 'Available in all deregulated states', '24/7 customer support'],
      'cons': ['Not always the cheapest option', 'Complex plan structures', 'Some customers report billing issues'],
      'greenRating': 3,
      'priceRating': 3,
      'serviceRating': 3,
      'nswRate': '\$1,450–\$1,750',
      'vicRate': '\$1,250–\$1,550',
      'qldRate': '\$1,400–\$1,700',
      'solar': '3–5c/kWh feed-in tariff (varies by state and plan)',
      'green': 'GreenPower options from 10% to 100%. AGL has a 50% renewable target by 2030.',
      'contract': 'No lock-in contracts on all market offers. 10-business-day cooling-off period.',
    },
    'origin-energy': {
      'name': 'Origin Energy',
      'description': 'One of Australia\'s leading energy retailers with 4.2+ million customer accounts.',
      'pros': ['Strong GreenPower credentials', 'Good customer satisfaction scores', 'Intuitive app with bill prediction', 'Available in all deregulated states', 'Flexible payment plans'],
      'cons': ['Slightly above-market pricing', 'Pay-on-time discount required for best rate', 'Exit fees on some bundled plans'],
      'greenRating': 4,
      'priceRating': 3,
      'serviceRating': 4,
      'nswRate': '\$1,420–\$1,720',
      'vicRate': '\$1,230–\$1,530',
      'qldRate': '\$1,380–\$1,680',
      'solar': '3–6c/kWh tiered feed-in tariff (higher rate for first 14 kWh/day exported)',
      'green': '\'Origin Go Green\' add-on up to 100%. Investing in 4,000MW renewable capacity by 2030.',
      'contract': 'No lock-in contracts. 10-business-day cooling-off. Some plans include optional price guarantee.',
    },
    'energy-australia': {
      'name': 'EnergyAustralia',
      'description': 'Serves ~2.4 million customers across eastern Australia. Strong brand recognition.',
      'pros': ['Competitive no-exit-fee plans', 'Strong online self-service', 'Bill smoothing option', 'Available in NSW, VIC, QLD, SA, ACT'],
      'cons': ['Fewer plan options than AGL/Origin', 'Solar rates not always competitive', 'Limited availability in WA'],
      'greenRating': 3,
      'priceRating': 3,
      'serviceRating': 3,
      'nswRate': '\$1,430–\$1,730',
      'vicRate': '\$1,240–\$1,540',
      'qldRate': '\$1,390–\$1,690',
      'solar': '2–4c/kWh flat feed-in tariff',
      'green': 'GreenPower available. EnergyAustralia has committed to net zero by 2040.',
      'contract': 'No lock-in contracts on all residential plans.',
    },
    'red-energy': {
      'name': 'Red Energy',
      'description': '100% Australian-owned retailer and subsidiary of Snowy Hydro. Strong on service.',
      'pros': ['Earn Velocity Frequent Flyer points', '100% Australian-owned', 'Excellent customer service ratings', 'Competitive flat-rate plans', 'Hardship support programs'],
      'cons': ['No Time-of-Use plans available', 'Fewer plan options', 'Not available in all states'],
      'greenRating': 4,
      'priceRating': 4,
      'serviceRating': 5,
      'nswRate': '\$1,390–\$1,650',
      'vicRate': '\$1,200–\$1,480',
      'qldRate': '\$1,360–\$1,640',
      'solar': '3–5c/kWh flat feed-in tariff',
      'green': 'Backed by Snowy Hydro — Australia\'s largest renewable energy generator.',
      'contract': 'No lock-in contracts. No exit fees.',
    },
    'alinta-energy': {
      'name': 'Alinta Energy',
      'description': 'Fast-growing retailer often among the cheapest in the market. Online-first model.',
      'pros': ['Often the cheapest rates in the market', 'No exit fees', 'Online-first — fast and simple sign-up', 'Price beat guarantee', 'Available in major east coast states'],
      'cons': ['Limited customer service channels', 'Fewer green energy options', 'Not in all states'],
      'greenRating': 2,
      'priceRating': 5,
      'serviceRating': 3,
      'nswRate': '\$1,330–\$1,580',
      'vicRate': '\$1,150–\$1,420',
      'qldRate': '\$1,320–\$1,580',
      'solar': '2–4c/kWh flat feed-in tariff',
      'green': 'GreenPower option available on select plans.',
      'contract': 'No lock-in contracts. Price Beat Guarantee — Alinta will match a verified cheaper quote.',
    },
    'simply-energy': {
      'name': 'Simply Energy',
      'description': 'Budget-focused retailer backed by ENGIE. Popular for online-savvy households.',
      'pros': ['Competitive pricing — often 15% below DMO', 'Simple plan structure', 'No exit fees', 'ENGIE-backed reliability'],
      'cons': ['Limited plan variety', 'Customer service primarily online/chat', 'Fewer advanced features'],
      'greenRating': 3,
      'priceRating': 4,
      'serviceRating': 3,
      'nswRate': '\$1,350–\$1,600',
      'vicRate': '\$1,170–\$1,440',
      'qldRate': '\$1,340–\$1,600',
      'solar': '3–5c/kWh flat feed-in tariff',
      'green': 'GreenPower available. Parent company ENGIE is a global renewable energy leader.',
      'contract': 'No lock-in contracts.',
    },
    'amber-electric': {
      'name': 'Amber Electric',
      'description': 'Innovative provider offering direct access to wholesale electricity prices.',
      'pros': ['Wholesale pricing — can be very cheap off-peak', 'Smart home integration (Tesla, SolarEdge)', 'Great for solar + battery households', 'Transparent pricing model'],
      'cons': ['Prices can spike dramatically during peak events', 'Not suitable for households without flexibility', 'Requires smart meter', 'Monthly fee in addition to usage'],
      'greenRating': 5,
      'priceRating': 3,
      'serviceRating': 4,
      'nswRate': 'Variable (wholesale spot price + \$12/mo)',
      'vicRate': 'Variable (wholesale spot price + \$12/mo)',
      'qldRate': 'Variable (wholesale spot price + \$12/mo)',
      'solar': 'Real-time wholesale feed-in rates — can reach 10–30c/kWh during peak events',
      'green': 'Primarily powered by rooftop solar and renewable sources during low-demand periods.',
      'contract': 'Monthly subscription. Cancel anytime.',
    },
    'powershop': {
      'name': 'Powershop',
      'description': 'NZ-founded retailer owned by Meridian Energy. Offers a unique pre-purchase model.',
      'pros': ['Buy electricity in advance to lock in prices', 'Strong green credentials', 'Good app and usage tracking', 'No lock-in contracts'],
      'cons': ['Pre-purchase model can be confusing', 'Not available in all states', 'Fewer plans than major providers'],
      'greenRating': 5,
      'priceRating': 3,
      'serviceRating': 4,
      'nswRate': '\$1,380–\$1,640',
      'vicRate': '\$1,190–\$1,460',
      'qldRate': '\$1,360–\$1,620',
      'solar': '3–5c/kWh flat feed-in tariff',
      'green': '100% carbon-neutral certified. Meridian Energy is a major renewable energy company.',
      'contract': 'No lock-in contracts.',
    },
  };

  Map<String, dynamic>? get dataA => _providerData[slugA];
  Map<String, dynamic>? get dataB => _providerData[slugB];
  String get nameA => dataA?['name'] ?? _titleCase(slugA);
  String get nameB => dataB?['name'] ?? _titleCase(slugB);

  String _titleCase(String s) => s.split('-').map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}').join(' ');

  @override
  Widget build(BuildContext context) {
    final title = '$nameA vs $nameB: Which Is Better in 2026?';
    final description = 'Detailed comparison of $nameA vs $nameB energy plans in Australia. We compare pricing, green energy, solar feed-in, customer service, and more.';

    if (kIsWeb) {
      MetaSEO().author(author: 'SaveNest Team');
      MetaSEO().description(description: description);
      MetaSEO().keywords(keywords: '$nameA vs $nameB, compare $nameA $nameB, best energy provider Australia 2026, $slugA vs $slugB electricity');
      MetaSEO().ogTitle(ogTitle: title);
      MetaSEO().ogDescription(ogDescription: description);
      SeoService.setCanonicalUrl('https://savenest.au/compare/$slugA-vs-$slugB');
      SeoService.injectJsonLd({
        '@context': 'https://schema.org',
        '@type': 'Article',
        'headline': title,
        'description': description,
        'author': {'@type': 'Organization', 'name': 'SaveNest Team'},
        'publisher': {'@type': 'Organization', 'name': 'SaveNest Australia'},
        'datePublished': '2026-04-26',
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
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                        child: const Text('PROVIDER COMPARISON 2026', style: TextStyle(color: AppTheme.vibrantEmerald, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        '$nameA vs $nameB',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Which energy provider is right for your home? We compare pricing, green energy, and customer service.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70, fontSize: 18),
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton.icon(
                        onPressed: () => context.go('/deals/electricity'),
                        icon: const Icon(Icons.compare_arrows),
                        label: const Text('Compare All Providers Free'),
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

            // Quick Verdict Banner
            Container(
              color: const Color(0xFFFFF9C4),
              padding: const EdgeInsets.all(20),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 860),
                  child: Row(
                    children: [
                      const Icon(Icons.lightbulb, color: Color(0xFFF57F17)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Bottom line: Neither $nameA nor $nameB is the cheapest provider in Australia. Both are large incumbents typically 10–20% above the most competitive offers. Use SaveNest to compare all 50+ providers before deciding.',
                          style: const TextStyle(fontSize: 14, height: 1.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Comparison Table
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // Score Cards
                      LayoutBuilder(builder: (context, constraints) {
                        final isWide = constraints.maxWidth > 600;
                        return isWide
                            ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Expanded(child: _providerCard(nameA, dataA)),
                                const SizedBox(width: 16),
                                Expanded(child: _providerCard(nameB, dataB)),
                              ])
                            : Column(children: [
                                _providerCard(nameA, dataA),
                                const SizedBox(height: 16),
                                _providerCard(nameB, dataB),
                              ]);
                      }),

                      const SizedBox(height: 40),
                      _sectionHeading('Price Comparison: $nameA vs $nameB'),
                      const SizedBox(height: 16),
                      _comparisonTable(nameA, nameB, [
                        ['NSW Annual Cost', dataA?['nswRate'] ?? 'N/A', dataB?['nswRate'] ?? 'N/A'],
                        ['VIC Annual Cost', dataA?['vicRate'] ?? 'N/A', dataB?['vicRate'] ?? 'N/A'],
                        ['QLD Annual Cost', dataA?['qldRate'] ?? 'N/A', dataB?['qldRate'] ?? 'N/A'],
                        ['Solar Feed-in', dataA?['solar'] ?? 'N/A', dataB?['solar'] ?? 'N/A'],
                        ['Contract', dataA?['contract'] ?? 'N/A', dataB?['contract'] ?? 'N/A'],
                        ['Green Energy', dataA?['green'] ?? 'N/A', dataB?['green'] ?? 'N/A'],
                      ]),
                      const SizedBox(height: 8),
                      const Text('* Annual cost estimates for a 3-person household at reference usage. Actual costs vary by postcode and plan selection. Compare live prices with SaveNest.', style: TextStyle(fontSize: 12, color: Color(0xFF888888), fontStyle: FontStyle.italic)),

                      const SizedBox(height: 40),
                      _sectionHeading('Our Verdict'),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.vibrantEmerald.withOpacity(0.3)),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('$nameA vs $nameB: Too Close to Call', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            const SizedBox(height: 12),
                            Text(
                              'The annual cost difference between $nameA and $nameB for a typical household is usually less than \$100. The bigger opportunity is switching from a standing offer to any competitive market offer, which can save \$300–\$500 per year.\n\nOur recommendation: don\'t limit your comparison to just these two providers. Use SaveNest to compare $nameA, $nameB, and 50+ other providers simultaneously. The cheapest option in your area may be a provider you\'ve never heard of.',
                              style: const TextStyle(fontSize: 15, height: 1.6, color: Color(0xFF555555)),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () => context.go('/deals/electricity'),
                              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.vibrantEmerald, foregroundColor: Colors.white),
                              child: const Text('Compare All Providers Now'),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),
                      _sectionHeading('Related Comparisons'),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _buildRelatedComparisons(context),
                      ),

                      const SizedBox(height: 40),
                      _sectionHeading('Frequently Asked Questions'),
                      const SizedBox(height: 16),
                      _faqItem('Is $nameA cheaper than $nameB?', 'The difference is usually less than \$100 per year for a typical household. The exact cheaper provider depends on your state, usage level, and plan selection. Use the SaveNest comparison tool to get a personalised quote.'),
                      _faqItem('Can I switch from $nameA to $nameB (or vice versa)?', 'Yes. Switching between energy providers in Australia is free and takes less than 10 minutes online. There is no interruption to your electricity supply. Most market offers have no exit fees.'),
                      _faqItem('Which provider has better customer service?', 'Both providers have improved their customer service in 2026. Based on independent consumer surveys, both score approximately 4/5 for overall satisfaction. See the ratings cards above for our detailed assessment.'),
                      _faqItem('What if neither provider is the cheapest in my area?', 'It\'s very possible. Budget providers like Alinta Energy, Simply Energy, and Red Energy often offer plans 15–20% below the major incumbents. Always compare the full market using SaveNest.'),
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

  Widget _providerCard(String name, Map<String, dynamic>? data) {
    final pros = data?['pros'] as List<dynamic>? ?? [];
    final cons = data?['cons'] as List<dynamic>? ?? [];
    final green = data?['greenRating'] as int? ?? 3;
    final price = data?['priceRating'] as int? ?? 3;
    final service = data?['serviceRating'] as int? ?? 3;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E0E0)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          const SizedBox(height: 4),
          Text(data?['description'] ?? '', style: const TextStyle(fontSize: 13, color: Color(0xFF666666), height: 1.4)),
          const SizedBox(height: 16),
          _ratingRow('Price', price),
          _ratingRow('Green Energy', green),
          _ratingRow('Customer Service', service),
          const SizedBox(height: 16),
          const Text('Pros', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
          const SizedBox(height: 6),
          ...pros.take(3).map((p) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(children: [const Icon(Icons.check, size: 14, color: AppTheme.vibrantEmerald), const SizedBox(width: 6), Expanded(child: Text(p.toString(), style: const TextStyle(fontSize: 13)))]),
          )),
          const SizedBox(height: 12),
          const Text('Cons', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFC62828))),
          const SizedBox(height: 6),
          ...cons.take(2).map((c) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(children: [const Icon(Icons.close, size: 14, color: Colors.red), const SizedBox(width: 6), Expanded(child: Text(c.toString(), style: const TextStyle(fontSize: 13)))]),
          )),
        ],
      ),
    );
  }

  Widget _ratingRow(String label, int rating) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        SizedBox(width: 110, child: Text(label, style: const TextStyle(fontSize: 13))),
        Row(children: List.generate(5, (i) => Icon(Icons.star, size: 14, color: i < rating ? AppTheme.vibrantEmerald : Colors.grey.shade300))),
      ],
    ),
  );

  Widget _sectionHeading(String text) => Text(text, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.deepNavy));

  Widget _comparisonTable(String a, String b, List<List<String>> rows) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE0E0E0)),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(color: AppTheme.deepNavy, borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12))),
            child: Row(
              children: [
                const Expanded(flex: 2, child: Text('Category', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 13))),
                Expanded(flex: 3, child: Text(a, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                Expanded(flex: 3, child: Text(b, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
              ],
            ),
          ),
          ...rows.asMap().entries.map((entry) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: entry.key.isEven ? Colors.white : const Color(0xFFF8F9FA),
              border: const Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
            ),
            child: Row(
              children: [
                Expanded(flex: 2, child: Text(entry.value[0], style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13))),
                Expanded(flex: 3, child: Text(entry.value[1], style: const TextStyle(fontSize: 13, color: Color(0xFF444444)))),
                Expanded(flex: 3, child: Text(entry.value[2], style: const TextStyle(fontSize: 13, color: Color(0xFF444444)))),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _faqItem(String q, String a) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE0E0E0))),
    child: ExpansionTile(
      title: Text(q, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
      children: [Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 16), child: Text(a, style: const TextStyle(fontSize: 14, height: 1.6, color: Color(0xFF555555))))],
    ),
  );

  List<Widget> _buildRelatedComparisons(BuildContext context) {
    final providers = _providerData.keys.toList();
    final comparisons = <Widget>[];
    for (final p in providers) {
      if (p != slugA && p != slugB) {
        comparisons.add(ActionChip(
          label: Text('$nameA vs ${_providerData[p]?['name'] ?? _titleCase(p)}'),
          onPressed: () => context.go('/compare/$slugA-vs-$p'),
        ));
        if (comparisons.length >= 6) break;
      }
    }
    for (final p in providers) {
      if (p != slugA && p != slugB) {
        comparisons.add(ActionChip(
          label: Text('$nameB vs ${_providerData[p]?['name'] ?? _titleCase(p)}'),
          onPressed: () => context.go('/compare/$slugB-vs-$p'),
        ));
        if (comparisons.length >= 10) break;
      }
    }
    return comparisons;
  }
}
