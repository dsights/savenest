import 'package:flutter/material.dart';
import 'package:meta_seo/meta_seo.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../theme/app_theme.dart';
import '../../../widgets/main_navigation_bar.dart';
import '../../../widgets/main_mobile_drawer.dart';
import '../../gamification/gamification_provider.dart';

class SolarLandingScreen extends ConsumerStatefulWidget {
  const SolarLandingScreen({super.key});

  @override
  ConsumerState<SolarLandingScreen> createState() => _SolarLandingScreenState();
}

class _SolarLandingScreenState extends ConsumerState<SolarLandingScreen>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _email = '';
  String _postcode = '';
  String _billAmount = '';
  String _phone = '';
  bool _isSubmitting = false;

  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  Timer? _countdownTimer;
  Duration _timeLeft =
      const Duration(hours: 48, minutes: 12, seconds: 35); // Urgency countdown

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && _timeLeft.inSeconds > 0) {
        setState(() {
          _timeLeft -= const Duration(seconds: 1);
        });
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _countdownTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToForm() {
    // Better way to scroll: use the key of the form if possible, 
    // but for now let's just adjust based on mobile/desktop
    final isMobile = MediaQuery.of(context).size.width < 900;
    _scrollController.animateTo(
      isMobile ? 800 : 600, 
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _submitLead() async {
    // ... (rest of the function remains same)
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isSubmitting = true;
      });

      try {
        final response = await http.post(
          Uri.parse(
              'http://127.0.0.1:8000/api/solar-lead'), // Update to prod URL later
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'name': _name,
            'email': _email,
            'postcode': _postcode,
            'billAmount': _billAmount,
            'phone': _phone,
          }),
        );

        if (!mounted) return;

        if (response.statusCode == 200) {
          // Gamification: Give user XP!
          ref.read(gamificationProvider.notifier).addXp(500);

          _formKey.currentState!.reset();
          context.go('/solar-thank-you');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Failed to submit form. Please try again.')),
          );
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Network error. Please check your connection.')),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 900;
    final isSmallMobile = screenWidth < 450;

    if (kIsWeb) {
      MetaSEO().author(author: 'SaveNest Solar Team');
      MetaSEO().description(
          description:
              'Stop paying high electricity bills. Get a free solar quote and see if your home qualifies for the 2026 Solar Rebates.');
      MetaSEO().keywords(
          keywords:
              'solar panels australia, solar quotes, solar rebates 2026, save on electricity, SaveNest Solar');
      MetaSEO()
          .ogTitle(ogTitle: 'SaveNest Solar: Find Out How Much You Can Save');
    }

    return Scaffold(
      backgroundColor: Colors.white,
      endDrawer: const MainMobileDrawer(),
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                const MainNavigationBar(),

                // 1. HERO SECTION WITH ANIMATION AND URGENCY
                Container(
                  width: double.infinity,
                  constraints: BoxConstraints(
                    minHeight: isMobile ? 800 : 700,
                  ),
                  decoration: const BoxDecoration(
                    color: AppTheme.deepNavy,
                    image: DecorationImage(
                      image: AssetImage('assets/images/hero_energy.jpg'),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black54, // Dark overlay for text readability
                        BlendMode.darken,
                      ),
                    ),
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1200),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 16 : 24,
                            vertical: isMobile ? 40 : 0),
                        child: Flex(
                          direction: isMobile ? Axis.vertical : Axis.horizontal,
                          crossAxisAlignment: isMobile
                              ? CrossAxisAlignment.center
                              : CrossAxisAlignment.center,
                          children: [
                            Flexible(
                              flex: isMobile ? 0 : 5,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: isMobile
                                    ? CrossAxisAlignment.center
                                    : CrossAxisAlignment.start,
                                children: [
                                  ScaleTransition(
                                    scale: _scaleAnimation,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: AppTheme.vibrantEmerald
                                            .withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                            color: AppTheme.vibrantEmerald,
                                            width: 2),
                                      ),
                                      child: Text(
                                        "🔥 LIMITED TIME: 2026 REBATES",
                                        style: TextStyle(
                                            color: AppTheme.vibrantEmerald,
                                            fontSize: isSmallMobile ? 12 : 14,
                                            fontWeight: FontWeight.w900),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: isMobile
                                        ? MainAxisAlignment.center
                                        : MainAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.timer,
                                          color: Colors.white, size: 20),
                                      const SizedBox(width: 8),
                                      Text(
                                        "Offer ends in: ${_timeLeft.inHours.toString().padLeft(2, '0')}:${(_timeLeft.inMinutes % 60).toString().padLeft(2, '0')}:${(_timeLeft.inSeconds % 60).toString().padLeft(2, '0')}",
                                        style: TextStyle(
                                            color: Colors.amber,
                                            fontSize: isMobile ? 16 : 18,
                                            fontWeight: FontWeight.bold),
                                      )
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                  Text(
                                    "Crush Your Power Bill With Solar.",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: isMobile ? 40 : 64,
                                      fontWeight: FontWeight.w900,
                                      height: 1.1,
                                    ),
                                    textAlign: isMobile
                                        ? TextAlign.center
                                        : TextAlign.start,
                                  ),
                                  const SizedBox(height: 24),
                                  Text(
                                    "Find out if your roof qualifies for government incentives and get 3 free quotes from trusted installers.",
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: isMobile ? 18 : 22,
                                      height: 1.5,
                                    ),
                                    textAlign: isMobile
                                        ? TextAlign.center
                                        : TextAlign.start,
                                  ),
                                  if (isMobile) const SizedBox(height: 40),
                                  if (!isMobile) ...[
                                    const SizedBox(height: 48),
                                    ElevatedButton(
                                      onPressed: _scrollToForm,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            AppTheme.vibrantEmerald,
                                        foregroundColor: AppTheme.deepNavy,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 48, vertical: 24),
                                        textStyle: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                        elevation: 8,
                                      ),
                                      child: const Text("CHECK MY ELIGIBILITY"),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            if (!isMobile) const SizedBox(width: 40),
                            Flexible(
                              flex: isMobile ? 0 : 4,
                              child: _buildLeadForm(isMobile),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // 2. VALUE PROPOSITION
                Container(
                  color: AppTheme.offWhite,
                  padding: EdgeInsets.symmetric(
                      vertical: isMobile ? 60 : 80, horizontal: 24),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1200),
                      child: Flex(
                        direction: isMobile ? Axis.vertical : Axis.horizontal,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (!isMobile)
                            Expanded(
                              flex: 1,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.asset(
                                  'assets/images/landing/happy_customer.jpg',
                                  fit: BoxFit.cover,
                                  height: 600,
                                ),
                              ),
                            ),
                          if (!isMobile) const SizedBox(width: 60),
                          Expanded(
                            flex: isMobile ? 0 : 1,
                            child: Column(
                              crossAxisAlignment: isMobile
                                  ? CrossAxisAlignment.center
                                  : CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Why Choose SaveNest Solar?",
                                  style: TextStyle(
                                      color: AppTheme.deepNavy,
                                      fontSize: isMobile ? 32 : 42,
                                      fontWeight: FontWeight.bold),
                                  textAlign: isMobile
                                      ? TextAlign.center
                                      : TextAlign.start,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  "We do the heavy lifting to ensure you get the best system at the best price.",
                                  style: TextStyle(
                                      color: AppTheme.slate600,
                                      fontSize: isMobile ? 18 : 20),
                                  textAlign: isMobile
                                      ? TextAlign.center
                                      : TextAlign.start,
                                ),
                                const SizedBox(height: 40),
                                _buildFeatureRow(
                                  icon: Icons.verified_user,
                                  title: "Vetted Installers",
                                  desc:
                                      "We only partner with Clean Energy Council (CEC) accredited installers.",
                                  isMobile: isMobile,
                                ),
                                const SizedBox(height: 24),
                                _buildFeatureRow(
                                  icon: Icons.monetization_on,
                                  title: "Maximize Rebates",
                                  desc:
                                      "We calculate exactly what government rebates you are eligible for right now.",
                                  isMobile: isMobile,
                                ),
                                const SizedBox(height: 24),
                                _buildFeatureRow(
                                  icon: Icons.speed,
                                  title: "Fast Process",
                                  desc:
                                      "Get quotes within 24 hours. From approval to installation in 14 days.",
                                  isMobile: isMobile,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // 3. OUR SERVICES
                Container(
                  color: Colors.white,
                  padding: EdgeInsets.symmetric(
                      vertical: isMobile ? 60 : 80, horizontal: 24),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1200),
                      child: Column(
                        children: [
                          Text(
                            "Energy Solutions",
                            style: TextStyle(
                                color: AppTheme.deepNavy,
                                fontSize: isMobile ? 32 : 42,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Explore our complete range of solar and energy services.",
                            style: TextStyle(
                                color: AppTheme.slate600,
                                fontSize: isMobile ? 18 : 20),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 40),
                          const Wrap(
                            spacing: 24,
                            runSpacing: 24,
                            alignment: WrapAlignment.center,
                            children: [
                              _AnimatedServicePill(
                                  icon: Icons.home,
                                  title: "Solar for Home",
                                  route: "/solar-services/home-solar"),
                              _AnimatedServicePill(
                                  icon: Icons.business,
                                  title: "Solar for Business",
                                  route: "/solar-services/business-solar"),
                              _AnimatedServicePill(
                                  icon: Icons.water_drop,
                                  title: "Hot Water Systems",
                                  route: "/solar-services/hot-water"),
                              _AnimatedServicePill(
                                  icon: Icons.price_check,
                                  title: "Rebates & Incentives",
                                  route: "/solar-services/rebates"),
                              _AnimatedServicePill(
                                  icon: Icons.battery_charging_full,
                                  title: "Battery Storage",
                                  route: "/solar-services/battery"),
                              _AnimatedServicePill(
                                  icon: Icons.energy_savings_leaf,
                                  title: "Energy Efficiency Upgrades",
                                  route: "/solar-services/efficiency"),
                              _AnimatedServicePill(
                                  icon: Icons.electric_car,
                                  title: "Electric Vehicles",
                                  route: "/solar-services/electric-vehicles"),
                              _AnimatedServicePill(
                                  icon: Icons.star,
                                  title: "Recommended Products",
                                  route:
                                      "/solar-services/recommended-products"),
                              _AnimatedServicePill(
                                  icon: Icons.calculate,
                                  title: "Solar + Battery Calculator",
                                  route: "/solar-services/calculator"),
                              _AnimatedServicePill(
                                  icon: Icons.store,
                                  title: "SaveNest Marketplace",
                                  route: "/solar-services/marketplace"),
                              _AnimatedServicePill(
                                  icon: Icons.podcasts,
                                  title: "Road to ZERO Podcast",
                                  route: "/solar-services/podcast"),
                              _AnimatedServicePill(
                                  icon: Icons.tv,
                                  title: "SaveNest TV Show",
                                  route: "/solar-services/tv-show"),
                              _AnimatedServicePill(
                                  icon: Icons.event,
                                  title: "Industry Events",
                                  route: "/solar-services/events"),
                              _AnimatedServicePill(
                                  icon: Icons.card_giftcard,
                                  title: "SaveNest Rewards",
                                  route: "/solar-services/rewards"),
                              _AnimatedServicePill(
                                  icon: Icons.compare_arrows,
                                  title: "Energy Bill Compare",
                                  route: "/solar-services/compare"),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Footer
                Container(
                  color: Colors.black,
                  padding: const EdgeInsets.all(40),
                  child: Center(
                    child: Text(
                      "© 2026 SaveNest Australia. All rights reserved.",
                      style: TextStyle(color: Colors.white.withOpacity(0.5)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeadForm(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 24 : 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10)),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Calculate Savings",
              style: TextStyle(
                  color: AppTheme.deepNavy,
                  fontSize: isMobile ? 24 : 28,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Takes 30 seconds.",
              style: TextStyle(color: AppTheme.slate600, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.stars, color: Colors.amber, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    "Earn +500 XP",
                    style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: isMobile ? 12 : 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              decoration: InputDecoration(
                labelText: "Full Name",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
              onSaved: (value) => _name = value!,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: "Email Address",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || !value.contains('@')) {
                  return 'Please enter a valid email';
                }
                return null;
              },
              onSaved: (value) => _email = value!,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: "Your Postcode",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.location_on),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty || value.length != 4) {
                  return 'Please enter a valid 4-digit postcode';
                }
                return null;
              },
              onSaved: (value) => _postcode = value!,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: "Avg Quarterly Bill (\$)",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.attach_money),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your bill amount';
                }
                return null;
              },
              onSaved: (value) => _billAmount = value!,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: "Phone Number",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your phone number';
                }
                return null;
              },
              onSaved: (value) => _phone = value!,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitLead,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.deepNavy,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  textStyle: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text("GET MY FREE QUOTES"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(
      {required IconData icon,
      required String title,
      required String desc,
      required bool isMobile}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.vibrantEmerald.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon,
                color: AppTheme.vibrantEmerald, size: isMobile ? 24 : 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                      color: AppTheme.deepNavy,
                      fontSize: isMobile ? 18 : 22,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: TextStyle(
                      color: AppTheme.slate600,
                      fontSize: isMobile ? 14 : 16,
                      height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedServicePill extends StatefulWidget {
  final IconData icon;
  final String title;
  final String route;

  const _AnimatedServicePill({
    required this.icon,
    required this.title,
    required this.route,
  });

  @override
  State<_AnimatedServicePill> createState() => _AnimatedServicePillState();
}

class _AnimatedServicePillState extends State<_AnimatedServicePill> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => context.push(widget.route),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutBack,
          width: 300,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          transform: Matrix4.identity()
            ..translate(0.0, _isHovered ? -8.0 : 0.0)
            ..scale(_isHovered ? 1.03 : 1.0),
          decoration: BoxDecoration(
            color: _isHovered ? Colors.white : AppTheme.offWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isHovered
                  ? AppTheme.vibrantEmerald
                  : AppTheme.slate300.withOpacity(0.5),
              width: _isHovered ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? AppTheme.vibrantEmerald.withOpacity(0.25)
                    : Colors.black.withOpacity(0.03),
                blurRadius: _isHovered ? 20 : 8,
                offset: Offset(0, _isHovered ? 10 : 4),
              ),
            ],
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _isHovered
                      ? AppTheme.vibrantEmerald.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: AnimatedScale(
                  scale: _isHovered ? 1.15 : 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: Icon(widget.icon,
                      color: AppTheme.vibrantEmerald, size: 32),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  style: TextStyle(
                    color: _isHovered
                        ? AppTheme.deepNavy
                        : AppTheme.deepNavy.withOpacity(0.85),
                    fontSize: 17,
                    fontWeight: _isHovered ? FontWeight.bold : FontWeight.w600,
                  ),
                  child: Text(widget.title),
                ),
              ),
              AnimatedOpacity(
                opacity: _isHovered ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  transform: Matrix4.identity()
                    ..translate(_isHovered ? 0.0 : -10.0, 0.0),
                  child: const Icon(Icons.arrow_forward_rounded,
                      color: AppTheme.vibrantEmerald, size: 24),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
