import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class AnimatedValueProps extends StatelessWidget {
  const AnimatedValueProps({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Container(
      color: AppTheme.offWhite,
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Why choose SaveNest?",
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.deepNavy,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "We make saving money effortless. Here's how we deliver value.",
                style: TextStyle(
                  fontSize: 18,
                  color: AppTheme.slate600,
                ),
              ),
              const SizedBox(height: 48),
              if (isDesktop)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Expanded(
                      flex: 4,
                      child: _BentoCard(
                        icon: Icons.bolt,
                        title: "Instant Comparison Engine",
                        desc: "Our proprietary algorithm scans hundreds of plans across electricity, gas, internet, and insurance in a fraction of a second. We match your profile with the market to find hidden savings others miss.",
                        color: Colors.orange,
                        isLarge: true,
                        imageAsset: 'assets/images/hero_energy.jpg',
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      flex: 5,
                      child: Column(
                        children: [
                          const Expanded(
                            child: _BentoCard(
                              icon: Icons.shield_outlined,
                              title: "Bank-Grade Security",
                              desc: "Your personal data is encrypted using AES-256. We never sell your data to third-party spammers.",
                              color: Colors.blue,
                              isLarge: false,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Expanded(
                                  flex: 1,
                                  child: _BentoCard(
                                    icon: Icons.money_off,
                                    title: "100% Free",
                                    desc: "No hidden fees or markups.",
                                    color: AppTheme.vibrantEmerald,
                                    isLarge: false,
                                  ),
                                ),
                                const SizedBox(width: 24),
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppTheme.deepNavy,
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    padding: const EdgeInsets.all(32),
                                    child: const Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Icon(Icons.auto_awesome, color: AppTheme.vibrantEmerald, size: 32),
                                        SizedBox(height: 16),
                                        Text(
                                          "Smart Alerts",
                                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          "We monitor the market and alert you when a better deal appears.",
                                          style: TextStyle(color: Colors.white70, fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              else
                const Column(
                  children: [
                    _BentoCard(
                      icon: Icons.bolt,
                      title: "Instant Comparison",
                      desc: "Scan hundreds of plans in a fraction of a second.",
                      color: Colors.orange,
                      isLarge: false,
                    ),
                    SizedBox(height: 16),
                    _BentoCard(
                      icon: Icons.shield_outlined,
                      title: "Bank-Grade Security",
                      desc: "Your personal data is encrypted using AES-256.",
                      color: Colors.blue,
                      isLarge: false,
                    ),
                    SizedBox(height: 16),
                    _BentoCard(
                      icon: Icons.money_off,
                      title: "100% Free",
                      desc: "No hidden fees or markups.",
                      color: AppTheme.vibrantEmerald,
                      isLarge: false,
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BentoCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String desc;
  final Color color;
  final bool isLarge;
  final String? imageAsset;

  const _BentoCard({
    required this.icon,
    required this.title,
    required this.desc,
    required this.color,
    required this.isLarge,
    this.imageAsset,
  });

  @override
  State<_BentoCard> createState() => _BentoCardState();
}

class _BentoCardState extends State<_BentoCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: _isHovered ? widget.color.withOpacity(0.15) : Colors.black.withOpacity(0.04),
              blurRadius: _isHovered ? 24 : 10,
              offset: _isHovered ? const Offset(0, 12) : const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: _isHovered ? widget.color.withOpacity(0.3) : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              if (widget.imageAsset != null)
                Positioned(
                  bottom: -50,
                  right: -50,
                  child: Opacity(
                    opacity: 0.1,
                    child: Image.asset(
                      widget.imageAsset!,
                      width: 300,
                      height: 300,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              Padding(
                padding: EdgeInsets.all(widget.isLarge ? 40.0 : 32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: widget.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(widget.icon, color: widget.color, size: widget.isLarge ? 32 : 28),
                    ),
                    SizedBox(height: widget.isLarge ? 40 : 24),
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: widget.isLarge ? 28 : 22,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.deepNavy,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.desc,
                      style: TextStyle(
                        color: AppTheme.slate600,
                        height: 1.6,
                        fontSize: widget.isLarge ? 16 : 15,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}