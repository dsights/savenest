import 'package:flutter/material.dart';
import 'package:meta_seo/meta_seo.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../widgets/main_navigation_bar.dart';
import '../../widgets/main_mobile_drawer.dart';

class StateGuideScreen extends StatelessWidget {
  final String stateCode; // nsw, vic, qld, etc.
  final String utility; // electricity, gas, internet

  const StateGuideScreen({
    super.key,
    required this.stateCode,
    required this.utility,
  });

  @override
  Widget build(BuildContext context) {
    final stateName = _getStateName(stateCode);
    final title = 'Compare $stateName ${utility.capitalize()} Plans | 2026 Guide';
    final description = 'Find the cheapest and best $utility providers in $stateName. Read our 2026 guide to tariffs, rebates, and potential savings.';

    // SEO Tags
    if (kIsWeb) {
      MetaSEO().author(author: 'SaveNest Team');
      MetaSEO().description(description: description);
      MetaSEO().keywords(keywords: 'compare $utility $stateName, cheapest $utility $stateName, best $utility provider $stateName 2026');
      MetaSEO().ogTitle(ogTitle: title);
      MetaSEO().ogDescription(ogDescription: description);
    }

    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      endDrawer: const MainMobileDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const MainNavigationBar(),
            
            // Hero
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
              decoration: const BoxDecoration(
                gradient: AppTheme.mainBackgroundGradient,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          '2026 STATE GUIDE',
                          style: TextStyle(
                            color: AppTheme.vibrantEmerald,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        '$stateName ${utility.capitalize()} Guide',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Everything you need to know about switching and saving in $stateName.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: () => context.go('/deals/$utility'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                        ),
                        child: Text('Compare $stateName Deals'),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Content Body
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSection('Market Overview'),
                      Text(
                        _getMarketOverview(stateCode, utility),
                        style: const TextStyle(color: Colors.white70, fontSize: 18, height: 1.6),
                      ),
                      const SizedBox(height: 40),
                      _buildSection('Average Costs in $stateName'),
                      Text(
                        'Based on 2026 AER data, the average household in $stateName spends approximately ${_getAverageCost(stateCode, utility)} per year on $utility. However, switching to a market offer below the reference price can save you up to 25%.',
                        style: const TextStyle(color: Colors.white70, fontSize: 18, height: 1.6),
                      ),
                      const SizedBox(height: 40),
                      _buildSection('Rebates & Concessions'),
                      Text(
                        _getRebates(stateCode),
                        style: const TextStyle(color: Colors.white70, fontSize: 18, height: 1.6),
                      ),
                      const SizedBox(height: 80),
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

  Widget _buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getStateName(String code) {
    switch (code.toLowerCase()) {
      case 'nsw': return 'New South Wales';
      case 'vic': return 'Victoria';
      case 'qld': return 'Queensland';
      case 'sa': return 'South Australia';
      case 'wa': return 'Western Australia';
      case 'act': return 'ACT';
      case 'tas': return 'Tasmania';
      case 'nt': return 'Northern Territory';
      default: return code.toUpperCase();
    }
  }

  String _getMarketOverview(String state, String utility) {
    if (utility == 'electricity') {
      if (state == 'vic') return 'Victoria has a unique market with the Victorian Default Offer (VDO). Smart meters are mandatory, allowing for advanced time-of-use tariffs. Competition is high between major players like Origin, AGL, and newcomers like Amber.';
      if (state == 'nsw') return 'NSW energy prices are regulated by the Default Market Offer (DMO). The state is seeing a surge in renewable energy zones, which is impacting peak and off-peak pricing structures. Residents should look out for "Solar Sharer" offers.';
      if (state == 'wa') return 'Western Australia\'s electricity market is regulated for residential customers. Synergy is the main retailer, but you can still optimize your bill by choosing the right tariff plan and using solar.';
    }
    return 'The $utility market in $state is competitive. Reviewing your plan annually is the best way to ensure you are not paying a "loyalty tax".';
  }

  String _getAverageCost(String state, String utility) {
    if (utility == 'internet') return '\$900';
    if (state == 'sa') return '\$1,800';
    if (state == 'vic') return '\$1,400';
    return '\$1,600';
  }

  String _getRebates(String state) {
    if (state == 'nsw') return 'NSW residents may be eligible for the Family Energy Rebate, Low Income Household Rebate, and Seniors Energy Rebate. Check your eligibility on the Service NSW website.';
    if (state == 'vic') return 'Victorians can access the Annual Electricity Concession and the Utility Relief Grant Scheme (URGS) if they are having trouble paying bills.';
    return 'Most states offer concessions for pensioners, seniors, and low-income households. Ensure your retailer has your concession card details on file.';
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
