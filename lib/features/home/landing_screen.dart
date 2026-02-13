import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // For web check
import 'package:go_router/go_router.dart';
import 'package:meta_seo/meta_seo.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_container.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Add Riverpod
import '../blog/blog_provider.dart'; // Import Blog Provider
import '../../widgets/animations.dart';

import 'widgets/blog_multi_carousel.dart'; // Import New Multi Carousel
import '../../widgets/main_navigation_bar.dart';
import '../../widgets/main_mobile_drawer.dart';

import 'dart:async'; // Import for Timer

// Enum for main product categories
enum _MainCategory {
  utilities,
  insurance,
  financialProducts,
}

class LandingScreen extends ConsumerStatefulWidget {
  const LandingScreen({super.key});

  @override
  ConsumerState<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends ConsumerState<LandingScreen> {
  _MainCategory _selectedMainCategory = _MainCategory.utilities;

  @override
  Widget build(BuildContext context) {
    // Update meta tags for SEO
    if (kIsWeb) {
      MetaSEO meta = MetaSEO();
      const String title = 'SaveNest | Compare & Save on Australian Utilities';
      const String description = 'Stop overpaying on your bills. SaveNest helps you compare electricity, gas, internet, and mobile plans from top Australian providers. Find a better deal in seconds.';
      const String imageUrl = 'https://savenest.au/assets/assets/images/hero_energy.jpg';

      meta.nameContent(name: 'title', content: title);
      meta.nameContent(name: 'description', content: description);
      meta.ogTitle(ogTitle: title);
      meta.ogDescription(ogDescription: description);
      meta.propertyContent(property: 'og:url', content: 'https://savenest.au/');
      meta.ogImage(ogImage: imageUrl);
      meta.propertyContent(property: 'og:type', content: 'website');
      meta.nameContent(name: 'twitter:card', content: 'summary_large_image');
      meta.nameContent(name: 'twitter:title', content: title);
      meta.nameContent(name: 'twitter:description', content: description);
      meta.nameContent(name: 'twitter:image', content: imageUrl);
    }

    return Scaffold(
        backgroundColor: AppTheme.offWhite,
        endDrawer: const MainMobileDrawer(),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const MainNavigationBar(),
              _buildModernHero(context),
              _buildCategorySection(context),
              _buildValueProps(context),
              _buildBlogSection(context),
              _buildTestimonialsSection(context),
              _buildFooter(context),
            ],
          ),
        ),
    );
  }

  Widget _buildModernHero(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 80),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth > 900;
              
              return Flex(
                direction: isDesktop ? Axis.horizontal : Axis.vertical,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Left Content
                  Expanded(
                    flex: isDesktop ? 5 : 0,
                    child: Column(
                      crossAxisAlignment: isDesktop ? CrossAxisAlignment.start : CrossAxisAlignment.center,
                      children: [
                        SlideFadeTransition(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryBlue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.verified, color: AppTheme.primaryBlue, size: 16),
                                const SizedBox(width: 8),
                                Text(
                                  "Australia's Trusted Comparison Platform",
                                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                    color: AppTheme.primaryBlue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SlideFadeTransition(
                          delay: 200,
                          child: Text(
                            "Stop overpaying on\nyour household bills.",
                            textAlign: isDesktop ? TextAlign.start : TextAlign.center,
                            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              fontSize: isDesktop ? 56 : 40,
                              height: 1.1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SlideFadeTransition(
                          delay: 400,
                          child: Text(
                            "Compare electricity, gas, internet, and insurance in minutes. \nReal savings, zero hassle.",
                            textAlign: isDesktop ? TextAlign.start : TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontSize: 18,
                              color: const Color(0xFF475467),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        SlideFadeTransition(
                          delay: 600,
                          child: Wrap(
                            spacing: 16,
                            runSpacing: 16,
                            alignment: isDesktop ? WrapAlignment.start : WrapAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () => context.go('/deals/electricity'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.accentOrange,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                                  shadowColor: AppTheme.accentOrange.withOpacity(0.4),
                                  elevation: 8,
                                ),
                                child: const Text("Start Comparing"),
                              ),
                              OutlinedButton(
                                onPressed: () => context.go('/registration'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppTheme.deepNavy,
                                  side: const BorderSide(color: Color(0xFFD0D5DD)),
                                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.upload_file, size: 20),
                                    SizedBox(width: 8),
                                    Text("Upload Bill"),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        SlideFadeTransition(
                          delay: 800,
                          child: Row(
                            mainAxisAlignment: isDesktop ? MainAxisAlignment.start : MainAxisAlignment.center,
                            children: [
                              _buildTrustBadge(Icons.star, "4.9/5 Rating"),
                              const SizedBox(width: 24),
                              _buildTrustBadge(Icons.shield_outlined, "100% Secure"),
                              const SizedBox(width: 24),
                              _buildTrustBadge(Icons.people_outline, "10k+ Users"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isDesktop) const SizedBox(width: 60),
                  // Right Image/Visual
                  if (isDesktop)
                    Expanded(
                      flex: 4,
                      child: SlideFadeTransition(
                        delay: 400,
                        offset: const Offset(0.2, 0),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              height: 500,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(32),
                                image: const DecorationImage(
                                  image: AssetImage('assets/images/hero_finance.jpg'),
                                  fit: BoxFit.cover,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 40,
                                    offset: const Offset(0, 20),
                                  ),
                                ],
                              ),
                            ),
                            // Floating Card
                            Positioned(
                              bottom: 40,
                              left: -40,
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: AppTheme.vibrantEmerald.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.savings, color: AppTheme.vibrantEmerald),
                                    ),
                                    const SizedBox(width: 16),
                                    const Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Average Savings",
                                          style: TextStyle(color: Color(0xFF667085), fontSize: 12),
                                        ),
                                        Text(
                                          "$320 / year",
                                          style: TextStyle(
                                            color: AppTheme.deepNavy,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTrustBadge(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.amber, size: 20),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppTheme.deepNavy,
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySection(BuildContext context) {
    return Container(
      color: AppTheme.offWhite,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Explore Categories",
                style: TextStyle(
                  color: AppTheme.primaryBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Everything you need to save",
                style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 32),
              ),
              const SizedBox(height: 48),
              
              // Custom Tab/Pill Selector
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: const Color(0xFFEAECF0)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: _MainCategory.values.map((category) {
                    final isSelected = _selectedMainCategory == category;
                    return InkWell(
                      onTap: () => setState(() => _selectedMainCategory = category),
                      borderRadius: BorderRadius.circular(100),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.deepNavy : Colors.transparent,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          _getMainCategoryName(category),
                          style: TextStyle(
                            color: isSelected ? Colors.white : const Color(0xFF667085),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 48),
              
              LayoutBuilder(
                builder: (context, constraints) {
                  return Wrap(
                    spacing: 24,
                    runSpacing: 24,
                    alignment: WrapAlignment.center,
                    children: _buildSubCategoryCards(context, _selectedMainCategory),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildValueProps(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              Text(
                "Why choose SaveNest?",
                style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 32),
              ),
              const SizedBox(height: 60),
              Wrap(
                spacing: 40,
                runSpacing: 40,
                alignment: WrapAlignment.center,
                children: [
                  _valuePropItem(Icons.bolt, "Instant Comparison", "Compare hundreds of plans in seconds with our advanced engine."),
                  _valuePropItem(Icons.lock_outline, "Data Secure", "Your data is encrypted and never sold to spammers."),
                  _valuePropItem(Icons.thumb_up_alt_outlined, "100% Free", "Our service is free for you. We get paid by providers."),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _valuePropItem(IconData icon, String title, String desc) {
    return SizedBox(
      width: 300,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppTheme.primaryBlue, size: 32),
          ),
          const SizedBox(height: 20),
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.deepNavy)),
          const SizedBox(height: 12),
          Text(desc, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF667085), height: 1.5)),
        ],
      ),
    );
  }

  String _getMainCategoryName(_MainCategory category) {
    switch (category) {
      case _MainCategory.utilities: return 'Utilities';
      case _MainCategory.insurance: return 'Insurance';
      case _MainCategory.financialProducts: return 'Finance';
    }
  }

  List<Widget> _buildSubCategoryCards(BuildContext context, _MainCategory mainCategory) {
    switch (mainCategory) {
      case _MainCategory.utilities:
        return [
          _categoryCard(context, 'Electricity', Icons.bolt, Colors.orange, '/deals/electricity'),
          _categoryCard(context, 'Gas', Icons.local_fire_department, Colors.red, '/deals/gas'),
          _categoryCard(context, 'Internet', Icons.wifi, Colors.blue, '/deals/internet'),
          _categoryCard(context, 'Mobile', Icons.phone_iphone, Colors.green, '/deals/mobile'),
        ];
      case _MainCategory.insurance:
        return [
          _categoryCard(context, 'General', Icons.shield, Colors.purple, '/deals/insurance'),
          _categoryCard(context, 'Health', Icons.medical_services, Colors.pink, '/deals/insurance/health'),
          _categoryCard(context, 'Car', Icons.directions_car, Colors.indigo, '/deals/insurance/car'),
        ];
      case _MainCategory.financialProducts:
        return [
          _categoryCard(context, 'Credit Cards', Icons.credit_card, Colors.orangeAccent, '/deals/credit-cards'),
          _categoryCard(context, 'Home Loans', Icons.home_work, Colors.brown, '/loans/home'),
        ];
    }
  }

  Widget _categoryCard(BuildContext context, String title, IconData icon, Color color, String route) {
    return InkWell(
      onTap: () => GoRouter.of(context).go(route),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 160,
        height: 180,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFEAECF0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.deepNavy,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlogSection(BuildContext context) { // ref is directly available as this.ref
    final postsAsync = ref.watch(blogPostsProvider);

    return Container(
      color: AppTheme.offWhite,
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Latest Insights',
                style: TextStyle(
                  color: AppTheme.deepNavy,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              
              postsAsync.when(
                data: (posts) => BlogMultiCarousel(posts: posts), // Use the new auto-scrolling carousel
                loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.vibrantEmerald)),
                error: (err, stack) => const Text('Failed to load insights', style: TextStyle(color: Colors.black54)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTestimonialsSection(BuildContext context) {
    return Container(
      color: AppTheme.deepNavy, // Dark contrast for testimonials
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 100),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              const Text(
                "Don't just take our word for it",
                style: TextStyle(color: AppTheme.vibrantEmerald, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                "Trusted by thousands of Aussies",
                style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 60),
              SizedBox(
                height: 280,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _testimonials.length,
                  itemBuilder: (context, index) {
                    final t = _testimonials[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 24.0),
                      child: Container(
                        width: 320,
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1D2939), // Slightly lighter navy
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: List.generate(5, (i) => const Icon(Icons.star, color: Colors.amber, size: 16)),
                            ),
                            const SizedBox(height: 16),
                            Expanded(
                              child: Text(
                                '"${t.quote}"',
                                style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.5),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: AppTheme.primaryBlue,
                                  radius: 16,
                                  child: Text(t.author[0], style: const TextStyle(color: Colors.white)),
                                ),
                                const SizedBox(width: 12),
                                Text(t.author, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shield_moon, color: Colors.black38, size: 24),
                  SizedBox(width: 8),
                  Text(
                    'SaveNest © 2026 | ABN 89691841059 | Pratham Technologies Pty Ltd',
                    style: TextStyle(color: Colors.black38),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 8,
                children: [
                  _footerLink(context, 'About Us', '/about'),
                  _footerLink(context, 'Contact Us', '/contact'),
                  _footerLink(context, 'Privacy Policy', '/privacy'),
                  _footerLink(context, 'Terms of Service', '/terms'),
                  _footerLink(context, 'How It Works & Business Model', '/how-it-works'),
                  _footerLink(context, 'Disclaimer', '/legal/disclaimer'),
                  _footerLink(context, 'Sitemap', '/sitemap'),
                  _footerLink(context, 'For Partners', '/partners/advertise'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _footerLink(BuildContext context, String text, String route) {
    return InkWell(
      onTap: () => GoRouter.of(context).go(route),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text(
          text,
          style: const TextStyle(color: Colors.black38, fontSize: 12),
        ),
      ),
    );
  }
}

class _Testimonial {
  final String quote;
  final String author;

  _Testimonial({required this.quote, required this.author});
}

final List<_Testimonial> _testimonials = [
  _Testimonial(
    quote: "SaveNest made comparing electricity plans so easy! I saved so much time and found a better deal instantly.",
    author: "Sarah P.",
  ),
  _Testimonial(
    quote: "I was dreading switching internet providers, but SaveNest streamlined the whole process. Highly recommend!",
    author: "David L.",
  ),
  _Testimonial(
    quote: "Honest, transparent, and incredibly helpful. SaveNest delivered on their promise to find me the best value.",
    author: "Jessica R.",
  ),
  _Testimonial(
    quote: "The savings calculator helped me understand my potential savings before even comparing. Brilliant tool!",
    author: "Mark T.",
  ),
  _Testimonial(
    quote: "Finally, a comparison site that puts the customer first. No hidden fees, just great deals.",
    author: "Emily C.",
  ),
];