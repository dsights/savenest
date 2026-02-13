import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// A utility class for standardized animations across the app.
/// This avoids external dependencies while providing engaging transitions.
class SlideFadeTransition extends StatefulWidget {
  final Widget child;
  final int delay; // milliseconds
  final Duration duration;
  final Offset offset;
  final Curve curve;

  const SlideFadeTransition({
    super.key,
    required this.child,
    this.delay = 0,
    this.duration = const Duration(milliseconds: 600),
    this.offset = const Offset(0, 0.2), // Slide up slightly (20% of height)
    this.curve = Curves.easeOutCubic,
  });

  @override
  State<SlideFadeTransition> createState() => _SlideFadeTransitionState();
}

class _SlideFadeTransitionState extends State<SlideFadeTransition> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );

    _slideAnimation = Tween<Offset>(begin: widget.offset, end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );

    if (widget.delay == 0) {
      _controller.forward();
    } else {
      Future.delayed(Duration(milliseconds: widget.delay), () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}

/// A "Knowledge Flash" widget that animates in to show a tip or fact.
class KnowledgeFlash extends StatefulWidget {
  final String text;
  final IconData icon;
  final Color? backgroundColor;
  final Color? textColor;

  const KnowledgeFlash({
    super.key,
    required this.text,
    this.icon = Icons.lightbulb_outline,
    this.backgroundColor,
    this.textColor,
  });

  @override
  State<KnowledgeFlash> createState() => _KnowledgeFlashState();
}

class _KnowledgeFlashState extends State<KnowledgeFlash> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true); // Pulse effect

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: widget.backgroundColor ?? Colors.amber.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: widget.backgroundColor?.withOpacity(0.5) ?? Colors.amber),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(widget.icon, color: widget.textColor ?? Colors.amber[800], size: 20),
            const SizedBox(width: 8),
            Text(
              widget.text,
              style: TextStyle(
                color: widget.textColor ?? Colors.amber[900],
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
