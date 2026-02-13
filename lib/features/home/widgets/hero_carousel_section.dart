import 'package:flutter/material.dart';
import 'dart:async';
import 'package:go_router/go_router.dart';
import '../../../theme/app_theme.dart';

class HeroCarouselSection extends StatefulWidget {
  const HeroCarouselSection({super.key});

  @override
  State<HeroCarouselSection> createState() => _HeroCarouselSectionState();
}

class _HeroCarouselSectionState extends State<HeroCarouselSection> with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<Map<String, String>> _slides = [
    {
      'image': 'assets/images/hero_energy.jpg',
      'title': 'Compare, Switch & Save on Energy',
      'subtitle': 'Find better electricity and gas plans in minutes.'
    },
    {
      'image': 'assets/images/hero_internet.jpg',
      'title': 'High-Speed Internet for Less',
      'subtitle': 'Compare NBN and 5G home internet plans.'
    },
    {
      'image': 'assets/images/hero_insurance.jpg',
      'title': 'Peace of Mind, Better Value',
      'subtitle': 'Compare health, car, and home insurance.'
    },
    {
      'image': 'assets/images/hero_finance.jpg',
      'title': 'Smart Finance Decisions',
      'subtitle': 'Compare home loans and credit cards.'
    },
    {
      'image': 'assets/images/hero_mobile.jpg',
      'title': 'Stay Connected for Less',
      'subtitle': 'Compare the best mobile plans in Australia.'
    },
  ];

  @override
  void initState() {
    super.initState();
    _startTimer();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeIn);
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _animationController.forward();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_currentPage < _slides.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return SizedBox(
      height: isDesktop ? 650 : 850,
      width: double.infinity,
      child: Stack(
        children: [
          // Carousel Background
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemCount: _slides.length,
            itemBuilder: (context, index) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    _slides[index]['image']!,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          AppTheme.deepNavy.withOpacity(0.8),
                          AppTheme.deepNavy.withOpacity(0.4),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          // Content Overlay
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: isDesktop ? CrossAxisAlignment.start : CrossAxisAlignment.center,
                  children: [
                    // Text Content
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: isDesktop ? CrossAxisAlignment.start : CrossAxisAlignment.center,
                          children: [
                            Text(
                              _slides[_currentPage]['title']!,
                              textAlign: isDesktop ? TextAlign.start : TextAlign.center,
                              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                    fontSize: isDesktop ? 56 : 32,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(color: Colors.black.withOpacity(0.5), blurRadius: 10),
                                    ],
                                    height: 1.1,
                                  ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              _slides[_currentPage]['subtitle']!,
                              textAlign: isDesktop ? TextAlign.start : TextAlign.center,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontSize: 18,
                                    color: Colors.white.withOpacity(0.9),
                                    shadows: [
                                      Shadow(color: Colors.black.withOpacity(0.5), blurRadius: 10),
                                    ],
                                  ),
                            ),
                            const SizedBox(height: 32),
                            if (isDesktop)
                              Row(
                                children: [
                                  _buildTrustBadge(Icons.check_circle, "Free Service"),
                                  const SizedBox(width: 24),
                                  _buildTrustBadge(Icons.check_circle, "No Markups"),
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
          ),

          // Slim Bottom Comparison Bar
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _buildSlimComparisonBar(context, isDesktop),
                ),
              ),
            ),
          ),

          // Indicators
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_slides.length, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index ? AppTheme.accentOrange : Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlimComparisonBar(BuildContext context, bool isDesktop) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: AppTheme.accentOrange.withOpacity(0.5), width: 1.5),
      ),
      child: isDesktop
          ? Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 24),
                  child: Text(
                    "Compare:",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: AppTheme.deepNavy,
                        ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildSlimItem(context, Icons.bolt, "Electricity", '/deals/electricity'),
                        _buildSlimItem(context, Icons.local_fire_department, "Gas", '/deals/gas'),
                        _buildSlimItem(context, Icons.wifi, "Internet", '/deals/internet'),
                        _buildSlimItem(context, Icons.phone_iphone, "Mobile", '/deals/mobile'),
                        _buildSlimItem(context, Icons.medical_services, "Health", '/deals/insurance/health'),
                        _buildSlimItem(context, Icons.directions_car, "Car Ins.", '/deals/insurance/car'),
                        _buildSlimItem(context, Icons.home, "Home Loan", '/loans/home'),
                        _buildSlimItem(context, Icons.credit_card, "Credit Card", '/deals/credit-cards'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () => context.go('/deals/electricity'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    backgroundColor: AppTheme.primaryBlue,
                  ),
                  child: const Text("Search All"),
                ),
              ],
            )
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildSlimItem(context, Icons.bolt, "Electricity", '/deals/electricity'),
                  _buildSlimItem(context, Icons.local_fire_department, "Gas", '/deals/gas'),
                  _buildSlimItem(context, Icons.wifi, "Internet", '/deals/internet'),
                  _buildSlimItem(context, Icons.phone_iphone, "Mobile", '/deals/mobile'),
                  _buildSlimItem(context, Icons.medical_services, "Health", '/deals/insurance/health'),
                  _buildSlimItem(context, Icons.directions_car, "Car Ins.", '/deals/insurance/car'),
                  _buildSlimItem(context, Icons.home, "Home Loan", '/loans/home'),
                  _buildSlimItem(context, Icons.credit_card, "Credit Card", '/deals/credit-cards'),
                ],
              ),
            ),
    );
  }

  Widget _buildSlimItem(BuildContext context, IconData icon, String label, String route) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => GoRouter.of(context).go(route),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: AppTheme.primaryBlue, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: AppTheme.deepNavy,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrustBadge(IconData icon, String text) {
    return Row(
      children: [
        const Icon(Icons.check_circle, color: AppTheme.vibrantEmerald, size: 20),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
