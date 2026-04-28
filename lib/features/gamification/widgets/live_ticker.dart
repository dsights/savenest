import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class LiveActivityTicker extends StatefulWidget {
  const LiveActivityTicker({super.key});

  @override
  State<LiveActivityTicker> createState() => _LiveActivityTickerState();
}

class _LiveActivityTickerState extends State<LiveActivityTicker>
    with SingleTickerProviderStateMixin {
  static const _messages = [
    '🔥 Sarah from Melbourne saved \$287/yr on electricity!',
    '⚡ Jack in Sydney just unlocked "Deal Hunter" — compare now!',
    '💡 Emma from Brisbane cut her internet bill by \$156/yr',
    '🏆 Liam unlocked "Smart Switcher" badge — 3 switches done!',
    '💰 Olivia from Perth saved \$340/yr by comparing providers',
    '⚡ Noah in Adelaide found a plan saving him \$210/yr',
    '🌱 Chloe switched to 100% green energy and saved \$95/yr',
    '📱 James from Gold Coast cut his mobile bill by \$180/yr',
    '🏅 Ava just reached Level 3 — Smart Switcher!',
    '💸 Ethan from Canberra saved \$420/yr across 2 services',
    '⚡ Isabella found a better electricity deal in 90 seconds',
    '🔋 Mason added solar to his list — projected saving \$560/yr!',
    '🎯 Zoe earned "+50 XP" by switching her energy provider',
    '🥇 Riley is now a "Savings Pro" — Level 4 unlocked!',
  ];

  int _current = 0;
  Timer? _timer;
  late AnimationController _fadeCtrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _current = Random().nextInt(_messages.length);
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeInOut);
    _fadeCtrl.forward();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) => _next());
  }

  void _next() {
    _fadeCtrl.reverse().then((_) {
      if (mounted) {
        setState(() => _current = (_current + 1) % _messages.length);
        _fadeCtrl.forward();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
      decoration: BoxDecoration(
        color: AppTheme.vibrantEmerald.withOpacity(0.06),
        border: Border.symmetric(
          horizontal: BorderSide(
            color: AppTheme.vibrantEmerald.withOpacity(0.18),
          ),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: FadeTransition(
            opacity: _fade,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Live dot
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4CAF50),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'LIVE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF4CAF50),
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(width: 14),
                Text(
                  _messages[_current],
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.deepNavy,
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
