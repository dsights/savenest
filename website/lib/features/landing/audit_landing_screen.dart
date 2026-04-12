import 'package:flutter/material.dart';
import 'package:meta_seo/meta_seo.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';

import '../../theme/app_theme.dart';
import '../../widgets/main_navigation_bar.dart';
import '../../widgets/main_mobile_drawer.dart';

class AuditLandingScreen extends StatefulWidget {
  const AuditLandingScreen({super.key});

  @override
  State<AuditLandingScreen> createState() => _AuditLandingScreenState();
}

class _AuditLandingScreenState extends State<AuditLandingScreen> {
  // Timer for urgency
  late Timer _timer;
  Duration _timeLeft = const Duration(hours: 4, minutes: 12, seconds: 35);
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeft.inSeconds > 0) {
          _timeLeft = _timeLeft - const Duration(seconds: 1);
        } else {
          _timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToPricing() {
    _scrollController.animateTo(
      2800, // Approximate location of pricing section
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _launchCalendly() async {
    final Uri url = Uri.parse('https://calendly.com/savenest-au/30min');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    // SEO
    if (kIsWeb) {
      MetaSEO().author(author: 'SaveNest Team');
      MetaSEO().description(description: 'Stop paying the Lazy Tax. Book your FREE SaveNest Utility Audit today. We find the savings, you only pay for our Premium Service if you choose to proceed.');
      MetaSEO().keywords(keywords: 'free utility audit, lazy tax audit, utility savings, save money australia, bill negotiation service');
      MetaSEO().ogTitle(ogTitle: 'Stop Burning Money: Book Your Free SaveNest Audit');
      MetaSEO().ogImage(ogImage: 'https://savenest.au/assets/assets/images/landing/money_waste.jpg');
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
                
                // 1. HERO SECTION: The Problem
                Container(
                  width: double.infinity,
                  height: 700,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/landing/money_waste.jpg'),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(Colors.black54, BlendMode.darken),
                    ),
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1000),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                "WARNING: YOU ARE OVERPAYING",
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              "Stop Paying the 'Lazy Tax'",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 64,
                                fontWeight: FontWeight.w900,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              "The average Australian household wastes \$2,400 a year on overpriced bills simply because they don't have time to switch. We do.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 48),
                            ElevatedButton(
                              onPressed: _scrollToPricing,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.vibrantEmerald,
                                foregroundColor: AppTheme.deepNavy,
                                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
                                textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                elevation: 8,
                                shadowColor: AppTheme.vibrantEmerald.withOpacity(0.5),
                              ),
                              child: const Text("BOOK MY FREE AUDIT"),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              "Limited free spots available for February",
                              style: TextStyle(color: Colors.white70, fontStyle: FontStyle.italic),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // 2. THE COST OF INACTION (Urgency)
                Container(
                  color: AppTheme.deepNavy,
                  padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1000),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Every day you wait costs you \$6.57",
                                  style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  "That's the daily cost of the 'Loyalty Tax' on Energy, Insurance, and Mortgage rates combined.",
                                  style: TextStyle(color: Colors.white70, fontSize: 18),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.redAccent.withOpacity(0.5)),
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  "FREE OFFER EXPIRES IN",
                                  style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  "${_timeLeft.inHours.toString().padLeft(2, '0')}:${(_timeLeft.inMinutes % 60).toString().padLeft(2, '0')}:${(_timeLeft.inSeconds % 60).toString().padLeft(2, '0')}",
                                  style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.w900, fontFamily: 'monospace'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // 3. WHAT YOU GET (Value Stack)
                Container(
                  color: AppTheme.offWhite,
                  padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1200),
                      child: Column(
                        children: [
                          const Text(
                            "The SaveNest Comprehensive Audit",
                            style: TextStyle(color: AppTheme.deepNavy, fontSize: 42, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "We don't just compare. We negotiate, switch, and manage everything for you.",
                            style: TextStyle(color: AppTheme.slate600, fontSize: 20),
                          ),
                          const SizedBox(height: 60),
                          Wrap(
                            spacing: 40,
                            runSpacing: 40,
                            alignment: WrapAlignment.center,
                            children: [
                              _buildFeatureCard(
                                icon: Icons.bolt,
                                title: "Energy Negotiation",
                                desc: "We call your retailer and demand the 'retention rate'. If they refuse, we switch you to the market leader.",
                                value: "Est. Savings: \$450/yr",
                              ),
                              _buildFeatureCard(
                                icon: Icons.security,
                                title: "Insurance Review",
                                desc: "We analyze your PDS line-by-line to find 'junk cover' you don't need and switch you to better value.",
                                value: "Est. Savings: \$300/yr",
                              ),
                              _buildFeatureCard(
                                icon: Icons.wifi,
                                title: "NBN Optimization",
                                desc: "Stop paying for 100Mbps if you only get 50Mbps. We audit your line speed and hardware.",
                                value: "Est. Savings: \$180/yr",
                              ),
                              _buildFeatureCard(
                                icon: Icons.attach_money,
                                title: "Mortgage Health Check",
                                desc: "We refer you to our broker partners to crush your interest rate. 0.25% off is huge.",
                                value: "Est. Savings: \$2,100/yr",
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // 4. SOCIAL PROOF
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1000),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: Image.asset('assets/images/landing/happy_customer.jpg', height: 400, fit: BoxFit.cover),
                            ),
                          ),
                          const SizedBox(width: 60),
                          const Expanded(
                            flex: 5,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.format_quote, size: 60, color: AppTheme.vibrantEmerald),
                                Text(
                                  "I was paying \$120 a month for internet I barely used and my energy bill was out of control. SaveNest's audit saved me \$1,400 in the first year alone. The service paid for itself in the first month.",
                                  style: TextStyle(color: AppTheme.deepNavy, fontSize: 24, fontStyle: FontStyle.italic, height: 1.4),
                                ),
                                SizedBox(height: 24),
                                Text(
                                  "- Sarah Jenkins, Melbourne",
                                  style: TextStyle(color: AppTheme.slate600, fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.star, color: Colors.amber, size: 20),
                                    Icon(Icons.star, color: Colors.amber, size: 20),
                                    Icon(Icons.star, color: Colors.amber, size: 20),
                                    Icon(Icons.star, color: Colors.amber, size: 20),
                                    Icon(Icons.star, color: Colors.amber, size: 20),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // 5. PRICING / CTA
                Container(
                  color: AppTheme.deepNavy,
                  padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 24),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 900),
                      child: Container(
                        padding: const EdgeInsets.all(40),
                        decoration: BoxDecoration(
                          gradient: AppTheme.mainBackgroundGradient,
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Text(
                              "Book Your Free Audit",
                              style: TextStyle(color: AppTheme.deepNavy, fontSize: 36, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              "Book a free 15-minute consultation with our experts. If we find savings, you can join SaveNest Premium for just \$100/year to unlock full management.",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppTheme.slate600, fontSize: 18),
                            ),
                            const SizedBox(height: 40),
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  "FREE",
                                  style: TextStyle(color: AppTheme.deepNavy, fontSize: 80, fontWeight: FontWeight.w900),
                                ),
                              ],
                            ),
                            const Text(
                              "Initial Consultation",
                              style: TextStyle(color: AppTheme.slate600, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppTheme.deepNavy.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                "Premium Service: \$100/yr (Optional)",
                                style: TextStyle(color: AppTheme.deepNavy, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(height: 40),
                            ElevatedButton(
                              onPressed: _launchCalendly,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.deepNavy,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 24),
                                textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                              child: const Text("BOOK FREE AUDIT"),
                            ),
                            const SizedBox(height: 24),
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle, size: 16, color: AppTheme.slate600),
                                SizedBox(width: 8),
                                Text("No Credit Card Required • No Obligation • 100% Free Chat", style: TextStyle(color: AppTheme.slate600)),
                              ],
                            ),
                          ],
                        ),
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

  Widget _buildFeatureCard({required IconData icon, required String title, required String desc, required String value}) {
    return Container(
      width: 350,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.vibrantEmerald.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.vibrantEmerald, size: 32),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(color: AppTheme.deepNavy, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            desc,
            style: const TextStyle(color: AppTheme.slate600, fontSize: 16, height: 1.5),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.deepNavy,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
