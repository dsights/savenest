import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class AnimatedValueProps extends StatelessWidget {
  const AnimatedValueProps({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.offWhite,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              Text(
                "Why choose SaveNest?",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontSize: 28,
                  color: AppTheme.deepNavy,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: 50,
                height: 3,
                decoration: BoxDecoration(
                  color: AppTheme.accentOrange,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 32),
                              const Wrap(
                                spacing: 40,
                                runSpacing: 40,
                                alignment: WrapAlignment.center,
                                children: [
                                  _ValuePropItem(
                                    icon: Icons.bolt,
                                    title: "Instant Comparison",
                                    desc: "Compare hundreds of plans in seconds with our advanced engine. Fast, easy, and accurate.",
                                    color: Colors.orange,
                                  ),
                                  _ValuePropItem(
                                    icon: Icons.lock_outline,
                                    title: "Data Secure",
                                    desc: "Your data is encrypted and never sold to spammers. We respect your privacy above all.",
                                    color: Colors.blue,
                                  ),
                                  _ValuePropItem(
                                    icon: Icons.thumb_up_alt_outlined,
                                    title: "100% Free",
                                    desc: "Our service is free for you. We get paid by providers, so you don't pay a cent to use us.",
                                    color: AppTheme.vibrantEmerald,
                                  ),
                                ],
                              ),            ],
          ),
        ),
      ),
    );
  }
}

class _ValuePropItem extends StatefulWidget {
  final IconData icon;
  final String title;
  final String desc;
  final Color color;

  const _ValuePropItem({
    required this.icon,
    required this.title,
    required this.desc,
    required this.color,
  });

  @override
  State<_ValuePropItem> createState() => _ValuePropItemState();
}

class _ValuePropItemState extends State<_ValuePropItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 340,
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: _isHovered ? Colors.black.withOpacity(0.1) : Colors.black.withOpacity(0.05),
              blurRadius: _isHovered ? 30 : 20,
              offset: _isHovered ? const Offset(0, 15) : const Offset(0, 10),
            ),
          ],
          border: Border.all(
            color: _isHovered ? AppTheme.accentOrange.withOpacity(0.5) : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            AnimatedScale(
              scale: _isHovered ? 1.1 : 1.0,
              duration: const Duration(milliseconds: 300),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(widget.icon, color: widget.color, size: 40),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.deepNavy,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.desc,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.slate600,
                height: 1.6,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
