import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../theme/app_theme.dart';
import 'mini_savings_calculator.dart';
import '../../../widgets/glass_container.dart';

class HeroCarouselSection extends StatefulWidget {
  const HeroCarouselSection({super.key});

  @override
  State<HeroCarouselSection> createState() => _HeroCarouselSectionState();
}

class _HeroCarouselSectionState extends State<HeroCarouselSection> with TickerProviderStateMixin {
  late AnimationController _bgAnimationController;
  late AnimationController _contentAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _bgAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);

    _contentAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = CurvedAnimation(parent: _contentAnimationController, curve: Curves.easeIn);
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
      CurvedAnimation(parent: _contentAnimationController, curve: Curves.easeOutQuart),
    );

    _contentAnimationController.forward();
  }

  @override
  void dispose() {
    _bgAnimationController.dispose();
    _contentAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 1100;
    final screenHeight = MediaQuery.of(context).size.height;
    
    final double? fixedHeight = isDesktop ? (screenHeight * 0.5 < 500 ? 500.0 : screenHeight * 0.5) : null;
    final double minHeight = isDesktop ? 500 : 750; 

    return Container(
      constraints: BoxConstraints(
        minHeight: minHeight,
        maxHeight: fixedHeight ?? double.infinity,
      ),
      width: double.infinity,
      child: Stack(
        children: [
          // Animated Mesh Gradient Background
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _bgAnimationController,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color.lerp(const Color(0xFF0F2027), const Color(0xFF203A43), _bgAnimationController.value)!,
                        Color.lerp(const Color(0xFF203A43), const Color(0xFF2C5364), _bgAnimationController.value)!,
                        Color.lerp(const Color(0xFF00B4DB), const Color(0xFF0083B0), 1 - _bgAnimationController.value)!,
                      ],
                      stops: const [0.0, 0.5, 1.0],
                      transform: GradientRotation(_bgAnimationController.value * math.pi),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Subtle particle overlay
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: Image.asset(
                'assets/images/hero_energy.jpg', // Using existing asset for texture
                fit: BoxFit.cover,
                colorBlendMode: BlendMode.overlay,
              ),
            ),
          ),

          // Content Overlay
          Padding(
            padding: EdgeInsets.symmetric(vertical: isDesktop ? 0 : 60),
            child: Center(
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
                            flex: 11,
                            child: _buildTextContent(isDesktop),
                          ),
                          const Spacer(flex: 1),
                          // Mini Calculator (Right Side)
                          const Expanded(
                            flex: 8,
                            child: GlassContainer(
                              blur: 15,
                              color: Colors.white10,
                              borderColor: Colors.white24,
                              child: MiniSavingsCalculator(),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildTextContent(isDesktop),
                          const SizedBox(height: 48),
                          const GlassContainer(
                            blur: 15,
                            color: Colors.white10,
                            borderColor: Colors.white24,
                            child: MiniSavingsCalculator(),
                          ),
                        ],
                      ),
                ),
              ),
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.vibrantEmerald.withOpacity(0.2),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: AppTheme.vibrantEmerald.withOpacity(0.5)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bolt, color: AppTheme.vibrantEmerald, size: 18),
                  SizedBox(width: 8),
                  Text(
                    "Switch & Save Up to \$500 Today",
                    style: TextStyle(
                      color: AppTheme.vibrantEmerald,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Stop Paying the Lazy Tax.",
              textAlign: isDesktop ? TextAlign.start : TextAlign.center,
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontSize: isDesktop ? 64 : 40,
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                    letterSpacing: -1.0,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              "Instantly compare energy, internet, and insurance. Find better value plans and slash your bills in minutes with Australia's smartest comparison engine.",
              textAlign: isDesktop ? TextAlign.start : TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: isDesktop ? 20 : 16,
                    color: Colors.white.withOpacity(0.85),
                    height: 1.5,
                  ),
            ),
            const SizedBox(height: 40),
            if (isDesktop)
              Wrap(
                spacing: 24,
                runSpacing: 16,
                children: [
                  _buildTrustBadge(Icons.shield_outlined, "100% Secure & Free"),
                  _buildTrustBadge(Icons.star_border, "5-Star Top Providers"),
                  _buildTrustBadge(Icons.timer_outlined, "Takes Only 2 Minutes"),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrustBadge(IconData icon, String text) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      borderRadius: 12,
      blur: 8,
      color: Colors.white.withOpacity(0.05),
      borderColor: Colors.white.withOpacity(0.1),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
