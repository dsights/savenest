import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // For web check
import 'package:go_router/go_router.dart';
import 'package:meta_seo/meta_seo.dart';
import 'package:url_launcher/url_launcher.dart'; // For launching app store links
import '../../theme/app_theme.dart';
import '../../widgets/glass_container.dart';
import '../savings/savings_screen.dart';
import '../comparison/comparison_screen.dart';
import '../comparison/comparison_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Add Riverpod
import '../blog/blog_provider.dart'; // Import Blog Provider
import '../blog/widgets/blog_card.dart'; // Import Blog Card
import '../blog/blog_post_screen.dart'; // Import Blog Screen

import 'widgets/blog_multi_carousel.dart'; // Import New Multi Carousel

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
          height: 400, // Adjust height as needed
          child: PageView(
            controller: _pageController,
            children: [
              _buildHeroSection(context),
              _buildSavingsCalculatorHeroCard(context),
              _buildQuoteSlide(context, 'Finding the best deals for my home has never been easier. SaveNest is a game-changer!', 'A grateful customer', 'assets/images/home_ins.png'), // Placeholder image
              _buildQuoteSlide(context, 'I saved hundreds on my electricity bill within minutes. Highly recommended!', 'A savvy saver', 'assets/images/energy.png'), // Placeholder image
              _buildQuoteSlide(context, 'Transparent, simple, and effective. SaveNest truly helps you beat the lazy tax.', 'A happy user', 'assets/images/car_ins.png'), // Placeholder image
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) { // Updated to 5 slides
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

  Widget _buildSavingsCalculatorHeroCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: AppTheme.mainBackgroundGradient,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              const Text(
                'Unlock Your Potential Savings!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              const Text(
                'Use our smart calculator to quickly estimate how much you could save on your household bills.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  GoRouter.of(context).go('/savings');
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
                child: const Text('TRY THE CALCULATOR NOW'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuoteSlide(BuildContext context, String quote, String author, String imagePath) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: AppTheme.mainBackgroundGradient,
        image: DecorationImage(
          image: AssetImage(imagePath), // Placeholder for Unsplash image
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.4), BlendMode.darken),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              Text(
                quote,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                '- $author',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  GoRouter.of(context).go('/savings');
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
                child: const Text('TRY THE CALCULATOR NOW'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Update meta tags for SEO
    if (kIsWeb) {
      MetaSEO meta = MetaSEO();
      meta.nameContent(name: 'title', content: 'SaveNest | Compare & Save on Australian Utilities');
      meta.nameContent(name: 'description', content: 'Stop overpaying on your bills. SaveNest helps you compare electricity, gas, internet, and mobile plans from top Australian providers. Find a better deal in seconds.');
      meta.ogTitle(ogTitle: 'SaveNest | Compare & Save on Australian Utilities');
      meta.ogDescription(ogDescription: 'Stop overpaying on your bills. SaveNest helps you compare electricity, gas, internet, and mobile plans from top Australian providers. Find a better deal in seconds.');
      meta.propertyContent(property: 'og:url', content: 'https://www.savenest.com.au/');
      meta.ogImage(ogImage: 'https://www.savenest.com.au/assets/images/logo.png');
    }

    return Scaffold(
        backgroundColor: AppTheme.deepNavy,
        endDrawer: _buildMobileDrawer(context),
        body: SingleChildScrollView(
          child: Column(
            children: [
              _buildNavBar(context),
              _buildHeroCarousel(context),
              if (kIsWeb) _buildDownloadAppSection(context), // New Section
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
// ...
  Widget _buildDownloadAppSection(BuildContext context) {
    return Container(
      color: AppTheme.deepNavy,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              const Text(
                'Get the Full Experience on Mobile',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 20,
                runSpacing: 20,
                alignment: WrapAlignment.center,
                children: [
                  _storeButton(
                    context,
                    'Get it on',
                    'Google Play',
                    Icons.android,
                    'https://play.google.com/store/apps/details?id=com.example.savenest', // Update with real ID
                  ),
                  _storeButton(
                    context,
                    'Download on the',
                    'App Store',
                    Icons.apple,
                    'https://apps.apple.com/app/id123456789', // Update with real ID
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _storeButton(BuildContext context, String sub, String title, IconData icon, String url) {
    return InkWell(
      onTap: () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        }
      },
      child: Container(
        width: 180,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sub,
                  style: const TextStyle(color: Colors.white70, fontSize: 10),
                ),
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlogSection(BuildContext context) { // ref is directly available as this.ref
    final postsAsync = ref.watch(blogPostsProvider);

    return Container(
      color: const Color(0xFF0F1530),
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
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              
              postsAsync.when(
                data: (posts) => BlogMultiCarousel(posts: posts), // Use the new auto-scrolling carousel
                loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.vibrantEmerald)),
                error: (err, stack) => const Text('Failed to load insights', style: TextStyle(color: Colors.white54)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      color: AppTheme.deepNavy,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.shield_moon, color: AppTheme.vibrantEmerald, size: 28),
                  const SizedBox(width: 8),
                  Text(
                    'SaveNest',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.0,
                        ),
                  ),
                ],
              ),
              if (MediaQuery.of(context).size.width > 600)
                Row(
                  children: [
                  _navLink(context, 'Electricity', '/deals/electricity'),
                  _navLink(context, 'Gas', '/deals/gas'),
                  _navLink(context, 'Internet', '/deals/internet'),
                  _navLink(context, 'Mobile', '/deals/mobile'),
                  _navLink(context, 'Savings Calculator', '/savings'),
                  ],
                )
              else
                // Mobile Menu Button
                Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white),
                    onPressed: () => Scaffold.of(context).openEndDrawer(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildMobileDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: AppTheme.deepNavy,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        children: [
          Row(
            children: [
              const Icon(Icons.shield_moon, color: AppTheme.vibrantEmerald, size: 28),
              const SizedBox(width: 8),
              Text(
                'SaveNest',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          ListTile(
            title: const Text('Electricity', style: TextStyle(color: Colors.white, fontSize: 18)),
            onTap: () {
              Navigator.pop(context);
              GoRouter.of(context).go('/deals/electricity');
            },
          ),
          ListTile(
            title: const Text('Gas', style: TextStyle(color: Colors.white, fontSize: 18)),
            onTap: () {
              Navigator.pop(context);
              GoRouter.of(context).go('/deals/gas');
            },
          ),
          ListTile(
            title: const Text('Internet', style: TextStyle(color: Colors.white, fontSize: 18)),
            onTap: () {
              Navigator.pop(context);
              GoRouter.of(context).go('/deals/internet');
            },
          ),
          ListTile(
            title: const Text('Mobile', style: TextStyle(color: Colors.white, fontSize: 18)),
            onTap: () {
              Navigator.pop(context);
              GoRouter.of(context).go('/deals/mobile');
            },
          ),
          ListTile(
            title: const Text('Savings Calculator', style: TextStyle(color: Colors.white, fontSize: 18)),
            onTap: () {
              Navigator.pop(context);
              GoRouter.of(context).go('/savings');
            },
          ),
        ],
      ),
    );
  }

  Widget _navLink(BuildContext context, String title, String route) {
    return InkWell(
      onTap: () => GoRouter.of(context).go(route),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: AppTheme.mainBackgroundGradient,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.vibrantEmerald.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.vibrantEmerald.withOpacity(0.3)),
                ),
                child: const Text(
                  'TRUSTED BY 50,000+ AUSTRALIANS',
                  style: TextStyle(
                    color: AppTheme.vibrantEmerald,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "Stop paying the 'lazy tax'.\nCompare utilities in seconds.",
                style: Theme.of(context).textTheme.displayMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.1,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              const Text(
                'We analyse your bills against thousands of market offers to find you the absolute best value for Energy, Internet, and Insurance.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySection(BuildContext context) {
    return Container(
      color: AppTheme.deepNavy,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'What would you like to compare?',
                style: TextStyle(
                  color: Colors.white,
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
                        backgroundColor: Colors.white10,
                        labelStyle: TextStyle(
                          color: isSelected ? AppTheme.deepNavy : Colors.white,
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
          _categoryCard(context, 'Savings Calculator', Icons.calculate, Colors.cyan, '/savings'), // Keep calculator prominent
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
                color: Colors.white,
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
      color: const Color(0xFF0F1530), // Slightly lighter navy
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            children: [
              const Text(
                'How SaveNest Works',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Our mission is to empower Australians to make smarter financial decisions by simplifying the complex world of utilities and financial products. We provide clear, independent guidance to help you find the best value and save money.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
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
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            desc,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white60,
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
      color: Colors.black26,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shield_moon, color: Colors.white30, size: 24),
                  SizedBox(width: 8),
                  Text(
                    'SaveNest © 2026 | ABN 89691841059 | Pratham Technologies Pty Ltd',
                    style: TextStyle(color: Colors.white30),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _footerLink(context, 'About Us', '/about'),
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
          style: const TextStyle(color: Colors.white30, fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildTestimonialsSection(BuildContext context) {
    return Container(
      color: AppTheme.deepNavy, // Changed to deepNavy
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            children: [
              const Text(
                'What Our Customers Say',
                style: TextStyle(
                  color: Colors.white, // Changed text color for contrast
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              SizedBox(
                height: 200, // Adjust height as needed
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _testimonials.length,
                  itemBuilder: (context, index) {
                    final testimonial = _testimonials[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: SizedBox(
                        width: 300, // Fixed width for each testimonial card
                        child: Card(
                          color: Colors.white10, // Changed card color for contrast
                          elevation: 8,
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
                                    color: Colors.white, // Changed text color for contrast
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
                                    color: Colors.white,
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
    );
  }
} // Closing brace for _LandingScreenState

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