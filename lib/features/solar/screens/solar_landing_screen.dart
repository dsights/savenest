import 'package:flutter/material.dart';
import 'package:meta_seo/meta_seo.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../theme/app_theme.dart';
import '../../../widgets/main_navigation_bar.dart';
import '../../../widgets/main_mobile_drawer.dart';

class SolarLandingScreen extends StatefulWidget {
  const SolarLandingScreen({super.key});

  @override
  State<SolarLandingScreen> createState() => _SolarLandingScreenState();
}

class _SolarLandingScreenState extends State<SolarLandingScreen> {
  final ScrollController _scrollController = ScrollController();
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _email = '';
  String _postcode = '';
  String _billAmount = '';
  String _phone = '';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToForm() {
    _scrollController.animateTo(
      600, // Approximate location of the lead form
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _submitLead() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isSubmitting = true;
      });

      try {
        final response = await http.post(
          Uri.parse('http://127.0.0.1:8000/api/solar-lead'), // Update to prod URL later
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'name': _name,
            'email': _email,
            'postcode': _postcode,
            'billAmount': _billAmount,
            'phone': _phone,
          }),
        );

        if (response.statusCode == 200) {
          _formKey.currentState!.reset();
          if (mounted) {
            context.go('/solar-thank-you');
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to submit form. Please try again.')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Network error. Please check your connection.')),
        );
      } finally {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      MetaSEO().author(author: 'SaveNest Solar Team');
      MetaSEO().description(description: 'Stop paying high electricity bills. Get a free solar quote and see if your home qualifies for the 2026 Solar Rebates.');
      MetaSEO().keywords(keywords: 'solar panels australia, solar quotes, solar rebates 2026, save on electricity, SaveNest Solar');
      MetaSEO().ogTitle(ogTitle: 'SaveNest Solar: Find Out How Much You Can Save');
      // MetaSEO().ogImage(ogImage: '...');
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
                
                // 1. HERO SECTION
                Container(
                  width: double.infinity,
                  height: 700,
                  decoration: const BoxDecoration(
                    color: AppTheme.deepNavy,
                    // Use a fallback gradient if image isn't ready
                    gradient: LinearGradient(
                      colors: [AppTheme.deepNavy, Color(0xFF1A365D)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1200),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 5,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: AppTheme.vibrantEmerald.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: AppTheme.vibrantEmerald),
                                    ),
                                    child: const Text(
                                      "2026 STATE REBATES ACTIVE",
                                      style: TextStyle(color: AppTheme.vibrantEmerald, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  const Text(
                                    "Crush Your Power Bill With Solar.",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 64,
                                      fontWeight: FontWeight.w900,
                                      height: 1.1,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  const Text(
                                    "Find out if your roof qualifies for government incentives and get 3 free quotes from trusted, CEC-accredited installers in your area.",
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 22,
                                      height: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 48),
                                  ElevatedButton(
                                    onPressed: _scrollToForm,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.vibrantEmerald,
                                      foregroundColor: AppTheme.deepNavy,
                                      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
                                      textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                      elevation: 8,
                                    ),
                                    child: const Text("CHECK MY ELIGIBILITY"),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 40),
                            Expanded(
                              flex: 4,
                              child: _buildLeadForm(),
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
                  padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1200),
                      child: Column(
                        children: [
                          const Text(
                            "Why Choose SaveNest Solar?",
                            style: TextStyle(color: AppTheme.deepNavy, fontSize: 42, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "We do the heavy lifting to ensure you get the best system at the best price.",
                            style: TextStyle(color: AppTheme.slate600, fontSize: 20),
                          ),
                          const SizedBox(height: 60),
                          Wrap(
                            spacing: 40,
                            runSpacing: 40,
                            alignment: WrapAlignment.center,
                            children: [
                              _buildFeatureCard(
                                icon: Icons.verified_user,
                                title: "Vetted Installers",
                                desc: "We only partner with Clean Energy Council (CEC) accredited installers. No cowboys.",
                              ),
                              _buildFeatureCard(
                                icon: Icons.monetization_on,
                                title: "Maximize Rebates",
                                desc: "We calculate exactly what government rebates you are eligible for right now.",
                              ),
                              _buildFeatureCard(
                                icon: Icons.speed,
                                title: "Fast Process",
                                desc: "Get quotes within 24 hours. From approval to installation in as little as 14 days.",
                              ),
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

  Widget _buildLeadForm() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Calculate Savings",
              style: TextStyle(color: AppTheme.deepNavy, fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Takes 30 seconds.",
              style: TextStyle(color: AppTheme.slate600, fontSize: 16),
            ),
            const SizedBox(height: 24),
            TextFormField(
              decoration: InputDecoration(
                labelText: "Full Name",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Please enter your name';
                return null;
              },
              onSaved: (value) => _name = value!,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: "Email Address",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || !value.contains('@')) return 'Please enter a valid email';
                return null;
              },
              onSaved: (value) => _email = value!,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: "Your Postcode",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
                labelText: "Average Quarterly Bill (\$)",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                child: _isSubmitting 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                    : const Text("GET MY FREE QUOTES"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({required IconData icon, required String title, required String desc}) {
    return Container(
      width: 320,
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
        ],
      ),
    );
  }
}
