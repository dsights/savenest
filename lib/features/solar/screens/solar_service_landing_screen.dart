import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:meta_seo/meta_seo.dart';
import 'package:flutter/foundation.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/main_navigation_bar.dart';
import '../../../widgets/main_mobile_drawer.dart';
import '../../home/widgets/modern_footer.dart';

class SolarServiceLandingScreen extends StatelessWidget {
  final String serviceSlug;

  const SolarServiceLandingScreen({super.key, required this.serviceSlug});

  String _getServiceTitle() {
    final title = serviceSlug.replaceAll('-', ' ');
    if (title.isEmpty) {
      return 'Service';
    }
    return title
        .split(' ')
        .map((word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1)}'
            : '')
        .join(' ');
  }

  IconData _getServiceIcon() {
    if (serviceSlug.contains('home')) {
      return Icons.home;
    }
    if (serviceSlug.contains('business')) {
      return Icons.business;
    }
    if (serviceSlug.contains('hot-water')) {
      return Icons.water_drop;
    }
    if (serviceSlug.contains('rebates')) {
      return Icons.price_check;
    }
    if (serviceSlug.contains('battery')) {
      return Icons.battery_charging_full;
    }
    if (serviceSlug.contains('efficiency')) {
      return Icons.energy_savings_leaf;
    }
    if (serviceSlug.contains('vehicles') || serviceSlug.contains('ev')) {
      return Icons.electric_car;
    }
    if (serviceSlug.contains('products')) {
      return Icons.star;
    }
    if (serviceSlug.contains('calculator')) {
      return Icons.calculate;
    }
    if (serviceSlug.contains('marketplace')) {
      return Icons.store;
    }
    if (serviceSlug.contains('podcast')) {
      return Icons.podcasts;
    }
    if (serviceSlug.contains('tv')) {
      return Icons.tv;
    }
    if (serviceSlug.contains('events')) {
      return Icons.event;
    }
    if (serviceSlug.contains('rewards')) {
      return Icons.card_giftcard;
    }
    if (serviceSlug.contains('compare')) {
      return Icons.compare_arrows;
    }
    return Icons.solar_power;
  }

  String _getServiceDescription() {
    if (serviceSlug.contains('home-solar')) {
      return 'Transform your home into a clean energy powerhouse. Our residential solar solutions drastically reduce your electricity bills, increase your property value, and protect you from rising grid prices.';
    }
    if (serviceSlug.contains('business-solar')) {
      return 'Empower your enterprise with commercial-grade solar. Cut operational costs, meet ESG targets, and secure your energy future with custom-designed PV systems and attractive tax incentives.';
    }
    if (serviceSlug.contains('hot-water')) {
      return 'Heating water accounts for up to 30% of household energy use. Upgrade to energy-efficient solar hot water or heat pump systems and watch your utility bills plummet.';
    }
    if (serviceSlug.contains('rebates')) {
      return 'Navigating government incentives can be complex. We simplify the process, helping you claim maximum STCs, state-based rebates, and feed-in tariffs to lower your upfront costs.';
    }
    if (serviceSlug.contains('battery')) {
      return 'Achieve true energy independence. Store your excess daytime solar power for use at night or during blackouts with our premium battery storage solutions (like Tesla Powerwall).';
    }
    if (serviceSlug.contains('efficiency')) {
      return 'Stop wasting power. From smart home integration and LED lighting to improved insulation, our energy efficiency upgrades ensure every watt counts.';
    }
    if (serviceSlug.contains('electric-vehicles')) {
      return 'Fuel your car with the sun. We provide smart EV chargers that integrate perfectly with your solar setup, allowing you to charge your vehicle using 100% renewable energy.';
    }
    if (serviceSlug.contains('calculator')) {
      return 'Take the guesswork out of solar. Use our advanced calculator to estimate your system size, upfront costs, payback period, and lifetime savings in just a few clicks.';
    }

    final title = _getServiceTitle();
    return 'Learn more about our $title solutions and how we can help you transition to a smarter, more sustainable energy ecosystem. SaveNest is your trusted partner for $title.';
  }

  List<Map<String, dynamic>> _getServiceFeatures() {
    if (serviceSlug.contains('home-solar')) {
      return [
        {
          'icon': Icons.savings,
          'title': 'Massive Savings',
          'desc': 'Slash your quarterly power bills by up to 80%.'
        },
        {
          'icon': Icons.home,
          'title': 'Property Value',
          'desc': 'Solar-equipped homes sell faster and at a premium.'
        },
        {
          'icon': Icons.eco,
          'title': 'Eco-Friendly',
          'desc': 'Dramatically reduce your household carbon footprint.'
        },
      ];
    }
    if (serviceSlug.contains('business-solar')) {
      return [
        {
          'icon': Icons.trending_down,
          'title': 'Lower Overhead',
          'desc': 'Protect your bottom line from volatile energy markets.'
        },
        {
          'icon': Icons.account_balance,
          'title': 'Tax Benefits',
          'desc': 'Leverage instant asset write-offs and depreciation.'
        },
        {
          'icon': Icons.public,
          'title': 'Brand Image',
          'desc': 'Showcase your commitment to sustainability to clients.'
        },
      ];
    }
    if (serviceSlug.contains('battery')) {
      return [
        {
          'icon': Icons.nightlight_round,
          'title': 'Nighttime Power',
          'desc': 'Use your own solar energy even after the sun goes down.'
        },
        {
          'icon': Icons.power_off,
          'title': 'Blackout Protection',
          'desc': 'Keep critical appliances running during grid outages.'
        },
        {
          'icon': Icons.bolt,
          'title': 'VPP Ready',
          'desc': 'Join Virtual Power Plants for extra credits and savings.'
        },
      ];
    }

    // Default features
    return [
      {
        'icon': Icons.support_agent,
        'title': 'Expert Support',
        'desc': 'Our local team is ready to assist you at every step.'
      },
      {
        'icon': Icons.verified,
        'title': 'Trusted Network',
        'desc': 'We only partner with top-tier, accredited professionals.'
      },
      {
        'icon': Icons.handshake,
        'title': 'Seamless Process',
        'desc': 'From quote to installation, we handle the hard work.'
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final title = _getServiceTitle();
    final description = _getServiceDescription();
    final icon = _getServiceIcon();
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 700;

    if (kIsWeb) {
      MetaSEO().author(author: 'SaveNest Solar Team');
      MetaSEO().description(description: description);
      MetaSEO().keywords(
          keywords: '$title, solar panels, SaveNest Solar, renewable energy');
      MetaSEO().ogTitle(ogTitle: 'SaveNest Solar: $title');
    }

    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      endDrawer: const MainMobileDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const MainNavigationBar(),

            // Hero Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                  vertical: isMobile ? 60 : 80, horizontal: 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.deepNavy, Color(0xFF003A72)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Column(
                    children: [
                      Icon(icon,
                          size: isMobile ? 60 : 80,
                          color: AppTheme.vibrantEmerald),
                      const SizedBox(height: 24),
                      Text(
                        title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isMobile ? 32 : 48,
                          fontWeight: FontWeight.w900,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        description,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: isMobile ? 18 : 20,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: () => context.push('/solar-quotes'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.vibrantEmerald,
                          foregroundColor: AppTheme.deepNavy,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 20),
                          textStyle: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        child: const Text('Get Started'),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Content Section
            Container(
              padding: EdgeInsets.symmetric(
                  vertical: isMobile ? 60 : 80, horizontal: 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Column(
                    crossAxisAlignment: isMobile
                        ? CrossAxisAlignment.center
                        : CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Why Choose SaveNest for $title?',
                        style: TextStyle(
                          fontSize: isMobile ? 28 : 32,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.deepNavy,
                        ),
                        textAlign: isMobile ? TextAlign.center : TextAlign.start,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'We provide industry-leading $title tailored exactly to your needs. Our approach focuses on long-term sustainability, immediate cost reductions, and transparent pricing.',
                        style: TextStyle(
                          fontSize: isMobile ? 16 : 18,
                          color: AppTheme.slate600,
                          height: 1.6,
                        ),
                        textAlign: isMobile ? TextAlign.center : TextAlign.start,
                      ),
                      const SizedBox(height: 40),
                      Wrap(
                        spacing: 24,
                        runSpacing: 24,
                        alignment: WrapAlignment.center,
                        children: _getServiceFeatures().map((feature) {
                          return SizedBox(
                            width: isMobile
                                ? screenWidth - 48
                                : 380, // Full width on mobile, 2-column on desktop
                            child: _buildInfoCard(
                              icon: feature['icon'] as IconData,
                              title: feature['title'] as String,
                              desc: feature['desc'] as String,
                              isMobile: isMobile,
                            ),
                          );
                        }).toList(),
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

  Widget _buildInfoCard(
      {required IconData icon,
      required String title,
      required String desc,
      required bool isMobile}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: isMobile
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 40, color: AppTheme.primaryBlue),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.deepNavy,
            ),
            textAlign: isMobile ? TextAlign.center : TextAlign.start,
          ),
          const SizedBox(height: 8),
          Text(
            desc,
            style: const TextStyle(
              fontSize: 16,
              color: AppTheme.slate600,
            ),
            textAlign: isMobile ? TextAlign.center : TextAlign.start,
          ),
        ],
      ),
    );
  }
}
