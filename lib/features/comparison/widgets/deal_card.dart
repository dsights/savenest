import 'dart:math';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/glass_container.dart';
import '../comparison_model.dart';

class DealCard extends StatefulWidget {
  final Deal deal;
  final bool isBestValue;

  const DealCard({
    super.key,
    required this.deal,
    this.isBestValue = false,
  });

  @override
  State<DealCard> createState() => _DealCardState();
}

class _DealCardState extends State<DealCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutBack),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (_isFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    _isFront = !_isFront;
  }

  Future<void> _launchURL() async {
    // Monetization: Append a unique tracking ID
    // In production, this would be a real user ID or session ID
    final String trackingId = 'user_${DateTime.now().millisecondsSinceEpoch}';
    
    // Check if URL already has query params
    final String separator = widget.deal.affiliateUrl.contains('?') ? '&' : '?';
    final String monetizedUrl = '${widget.deal.affiliateUrl}${separator}clickRef=$trackingId';

    final Uri url = Uri.parse(monetizedUrl);
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _flipCard,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final angle = _animation.value * pi;
          final isBack = angle >= pi / 2;
          
          return Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // Perspective
              ..rotateY(angle),
            alignment: Alignment.center,
            child: isBack
                ? Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(pi), // Mirror back text
                    child: _buildBack(),
                  )
                : _buildFront(),
          );
        },
      ),
    );
  }

  Widget _buildFront() {
    return Stack(
      children: [
        GlassContainer(
          borderRadius: 16,
          padding: const EdgeInsets.all(10), // Reduced from 16
          borderColor: widget.isBestValue ? AppTheme.vibrantEmerald.withOpacity(0.5) : null,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Header: Logo & Rating
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 32, // Reduced from 40
                    height: 32,
                    decoration: BoxDecoration(
                      color: widget.deal.providerColor,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      widget.deal.providerName[0],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16, // Reduced from 20
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 12),
                      const SizedBox(width: 2),
                      Text(
                        widget.deal.rating.toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
              
              // Middle: Info
              Column(
                children: [
                  Text(
                    widget.deal.providerName,
                    style: const TextStyle(fontSize: 10, color: Colors.white70),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.deal.planName,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12, // Reduced from 16
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              // Bottom: Price
              Column(
                children: [
                  Text(
                    '\$${widget.deal.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 20, // Reduced from 28
                      fontWeight: FontWeight.bold,
                      color: AppTheme.vibrantEmerald,
                    ),
                  ),
                  Text(
                    widget.deal.priceUnit,
                    style: const TextStyle(fontSize: 10, color: Colors.white54),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Tap to flip',
                    style: TextStyle(fontSize: 8, color: Colors.white30),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (widget.isBestValue) _buildBadge('BEST VALUE', AppTheme.vibrantEmerald, AppTheme.deepNavy),
        if (widget.deal.isSponsored && !widget.isBestValue) _buildBadge('SPONSORED', Colors.white24, Colors.white),
      ],
    );
  }

  Widget _buildBack() {
    return GlassContainer(
      borderRadius: 16,
      padding: const EdgeInsets.all(10), // Reduced from 16
      color: AppTheme.deepNavy.withOpacity(0.9),
      borderColor: AppTheme.vibrantEmerald.withOpacity(0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Features',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.vibrantEmerald),
              ),
              const Icon(Icons.close, size: 14, color: Colors.white54),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ...widget.deal.keyFeatures.map((feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 2.0),
                        child: Icon(Icons.check, color: AppTheme.vibrantEmerald, size: 10),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          feature,
                          style: const TextStyle(fontSize: 10, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _launchURL,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.deepNavy,
                padding: const EdgeInsets.symmetric(vertical: 4),
                minimumSize: const Size(0, 30),
              ),
              child: const Text('Go to Site', style: TextStyle(fontSize: 10)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color bg, Color fg) {
    return Positioned(
      top: 0,
      right: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: fg,
            fontWeight: FontWeight.bold,
            fontSize: 9,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
