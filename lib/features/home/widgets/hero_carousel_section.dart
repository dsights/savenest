import 'package:flutter/material.dart';
import 'dart:async';
import '../../../theme/app_theme.dart';
import 'mini_savings_calculator.dart';

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
    final isDesktop = MediaQuery.of(context).size.width > 1100;

    return SizedBox(
      height: isDesktop ? 650 : 1000, 
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
                          AppTheme.deepNavy.withOpacity(0.9),
                          AppTheme.deepNavy.withOpacity(0.6),
                          AppTheme.deepNavy.withOpacity(0.3),
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
              constraints: const BoxConstraints(maxWidth: 1400),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: isDesktop 
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Text Content (Left Side)
                        Expanded(
                          flex: 3,
                          child: _buildTextContent(isDesktop),
                        ),
                        // Mini Calculator (Right Side)
                        const Expanded(
                          flex: 1,
                          child: Padding(
                            padding: EdgeInsets.only(left: 40),
                            child: MiniSavingsCalculator(),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildTextContent(isDesktop),
                        const SizedBox(height: 40),
                        const MiniSavingsCalculator(),
                      ],
                    ),
              ),
            ),
          ),

          // Indicators
          Positioned(
            bottom: 40,
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
                    color: _currentPage == index ? AppTheme.accentOrange : Colors.white.withOpacity(0.3),
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

  Widget _buildTextContent(bool isDesktop) {
    return FadeTransition(
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
                    fontSize: isDesktop ? 64 : 36,
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
            ),
            const SizedBox(height: 24),
            Text(
              _slides[_currentPage]['subtitle']!,
              textAlign: isDesktop ? TextAlign.start : TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 20,
                    color: Colors.white.withOpacity(0.9),
                  ),
            ),
            const SizedBox(height: 48),
            if (isDesktop)
              Wrap(
                spacing: 32,
                runSpacing: 16,
                children: [
                  _buildTrustBadge(Icons.verified_user, "100% Secure"),
                  _buildTrustBadge(Icons.star, "Top Rated Providers"),
                  _buildTrustBadge(Icons.timer, "Saves you hours"),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrustBadge(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppTheme.vibrantEmerald, size: 20),
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