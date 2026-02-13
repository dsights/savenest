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
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late Timer _timer; // Declare the timer

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page?.round() ?? 0;
      });
    });

    // Initialize auto-sliding
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (_currentPage < 4) { // Assuming 5 slides (0-4 index)
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer.cancel(); // Cancel the timer
    super.dispose();
  }



  _MainCategory _selectedMainCategory = _MainCategory.utilities;

  Widget _buildHeroCarousel(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 450, // Increased height for better impact
          child: PageView(
            controller: _pageController,
            children: [
              _buildHeroSlide(
                context, 
                quote: "Power Up Your Savings.\nCompare Top Energy Plans Today.", 
                imagePath: 'assets/images/hero_energy.jpg', 
                buttonText: 'COMPARE ENERGY', 
                route: '/deals/electricity'
              ),
              _buildHeroSlide(
                context, 
                quote: "Connect for Less.\nHigh-Speed Internet Deals.", 
                imagePath: 'assets/images/hero_internet.jpg', 
                buttonText: 'COMPARE INTERNET', 
                route: '/deals/internet'
              ),
              _buildHeroSlide(
                context, 
                quote: "Talk More, Pay Less.\nBest Mobile Plans.", 
                imagePath: 'assets/images/hero_mobile.jpg', 
                buttonText: 'COMPARE MOBILE', 
                route: '/deals/mobile'
              ),
              _buildHeroSlide(
                context, 
                quote: "Protect What Matters.\nComprehensive Insurance Options.", 
                imagePath: 'assets/images/hero_insurance.jpg', 
                buttonText: 'COMPARE INSURANCE', 
                route: '/deals/insurance'
              ),
              _buildHeroSlide(
                context, 
                quote: "Smart Financial Moves.\nBetter Loans & Credit.", 
                imagePath: 'assets/images/hero_finance.jpg', 
                buttonText: 'COMPARE FINANCE', 
                route: '/loans/home'
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            return Container(
              width: 8.0,
              height: 8.0,
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentPage == index
                    ? AppTheme.vibrantEmerald
                    : Colors.white30,
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildHeroSlide(BuildContext context, {
    required String quote,
    required String imagePath,
    required String buttonText,
    required String route,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.offWhite,
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.darken),
        ),
      ),
      child: Stack(
        children: [
          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      quote,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        shadows: [
                           Shadow(
                            offset: Offset(0, 2),
                            blurRadius: 4.0,
                            color: Colors.black54,
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      alignment: WrapAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            GoRouter.of(context).go(route);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.vibrantEmerald,
                            foregroundColor: AppTheme.deepNavy,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                            textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          child: Text(buttonText),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            GoRouter.of(context).go('/savings');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppTheme.deepNavy,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                            textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          child: const Text('Savings Calculator'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Knowledge Flash Animation
          Positioned(
            top: 20,
            right: 20,
            child: SlideFadeTransition(
              delay: 1000,
              offset: const Offset(0, -0.5),
              child: KnowledgeFlash(
                text: "Did you know? Switching can save \$300/yr!",
                backgroundColor: AppTheme.vibrantEmerald.withOpacity(0.9),
                textColor: AppTheme.deepNavy,
              ),
            ),
          ),
        ],
      ),
    );
  }

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
      
      // Open Graph / Facebook
      meta.ogTitle(ogTitle: title);
      meta.ogDescription(ogDescription: description);
      meta.propertyContent(property: 'og:url', content: 'https://savenest.au/');
      meta.ogImage(ogImage: imageUrl);
      meta.propertyContent(property: 'og:type', content: 'website');

      // Twitter
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
              _buildHeroCarousel(context),
              _buildCategorySection(context),
              _buildBlogSection(context), // ref is directly available as this.ref
              _buildHowItWorksSection(context),
              _buildTestimonialsSection(context),
              _buildFooter(context),
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
      child: SlideFadeTransition(
        delay: 400,
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
      ),
    );
  }

  Widget _buildCategorySection(BuildContext context) {
    return Container(
      color: AppTheme.offWhite,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
      child: SlideFadeTransition(
        delay: 200,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'What would you like to compare?',
                  style: TextStyle(
                    color: AppTheme.deepNavy,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),
                // Main category tabs/buttons
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _MainCategory.values.map((category) {
                      final isSelected = _selectedMainCategory == category;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: ChoiceChip(
                          label: Text(_getMainCategoryName(category)),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedMainCategory = category;
                              });
                            }
                          },
                          selectedColor: AppTheme.vibrantEmerald,
                          backgroundColor: Colors.black12,
                          labelStyle: TextStyle(
                            color: isSelected ? AppTheme.deepNavy : AppTheme.deepNavy,
                            fontWeight: FontWeight.bold,
                          ),
                          side: BorderSide.none,
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 32),
                LayoutBuilder(
                  builder: (context, constraints) {
                    return Wrap(
                      spacing: 20,
                      runSpacing: 20,
                      children: _buildSubCategoryCards(context, _selectedMainCategory),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getMainCategoryName(_MainCategory category) {
    switch (category) {
      case _MainCategory.utilities:
        return 'Utilities';
      case _MainCategory.insurance:
        return 'Insurance';
      case _MainCategory.financialProducts:
        return 'Financial Products';
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
          _categoryCard(context, 'General Insurance', Icons.shield, Colors.purple, '/deals/insurance'),
          _categoryCard(context, 'Health Insurance', Icons.medical_services, Colors.pink, '/deals/insurance/health'),
          _categoryCard(context, 'Car Insurance', Icons.directions_car, Colors.indigo, '/deals/insurance/car'),
          // Add other insurance types as needed, e.g., Home Insurance, Life Insurance
        ];
      case _MainCategory.financialProducts:
        return [
          _categoryCard(context, 'Credit Cards', Icons.credit_card, Colors.orangeAccent, '/deals/credit-cards'),
          _categoryCard(context, 'Home Loans', Icons.home_work, Colors.brown, '/loans/home'),
          // Add other financial products as needed
        ];
    }
  }

  Widget _categoryCard(BuildContext context, String title, IconData icon, Color color, String route) {
    return InkWell(
      onTap: () {
        GoRouter.of(context).go(route);
      },
      child: GlassContainer(
        width: 150,
        height: 170,
        borderRadius: 16,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
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
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHowItWorksSection(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      child: SlideFadeTransition(
        delay: 600,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              children: [
                const Text(
                  'How SaveNest Works',
                  style: TextStyle(
                    color: AppTheme.deepNavy,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Our mission is to empower Australians to make smarter financial decisions by simplifying the complex world of utilities and financial products. We provide clear, independent guidance to help you find the best value and save money.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 18,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 60),
                Wrap(
                  spacing: 40,
                  runSpacing: 40,
                  alignment: WrapAlignment.center,
                  children: [
                    _stepItem(
                      '1. Tell Us Your Needs',
                      'Share some basic details about your current plans and what you\'re looking for. It\'s quick and easy!',
                      Icons.edit_note,
                    ),
                    _stepItem(
                      '2. Compare Options',
                      'Our smart engine instantly scans market offers to find you personalized, better deals.',
                      Icons.analytics_outlined,
                    ),
                    _stepItem(
                      '3. Switch & Save',
                      'Found a better deal? Switch effortlessly. We help you with the paperwork and process.',
                      Icons.savings_outlined,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _stepItem(String title, String desc, IconData icon) {
    return SizedBox(
      width: 280,
      child: Column(
        children: [
          Icon(icon, color: AppTheme.vibrantEmerald, size: 48),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.deepNavy,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            desc,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
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

  Widget _buildTestimonialsSection(BuildContext context) {
    return Container(
      color: AppTheme.offWhite, 
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      child: SlideFadeTransition(
        delay: 800,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              children: [
                const Text(
                  'What Our Customers Say',
                  style: TextStyle(
                    color: AppTheme.deepNavy, 
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                SizedBox(
                  height: 300, 
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _testimonials.length,
                    itemBuilder: (context, index) {
                      final testimonial = _testimonials[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: SizedBox(
                          width: 300, 
                          child: Card(
                            color: Colors.white,
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.format_quote, color: AppTheme.vibrantEmerald.withOpacity(0.7), size: 36),
                                  const SizedBox(height: 12),
                                  Text(
                                    testimonial.quote,
                                    style: const TextStyle(
                                      color: AppTheme.deepNavy,
                                      fontSize: 16,
                                      fontStyle: FontStyle.italic,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 4,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    '- ${testimonial.author}',
                                    style: const TextStyle(
                                      color: AppTheme.deepNavy,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
