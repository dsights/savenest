import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Add SVG support
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
    final String trackingId = 'user_${DateTime.now().millisecondsSinceEpoch}';
    final String separator = widget.deal.affiliateUrl.contains('?') ? '&' : '?';
    final String monetizedUrl = '${widget.deal.affiliateUrl}${separator}clickRef=$trackingId';

    final Uri url = Uri.parse(monetizedUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      debugPrint('Could not launch $url');
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
          padding: const EdgeInsets.all(16),
          borderColor: widget.isBestValue ? AppTheme.vibrantEmerald.withOpacity(0.8) : Colors.white10,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Header: Logo & Rating
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLogo(),
                  if (widget.deal.rating > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            widget.deal.rating.toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: 12),

              // Middle: Info
              Column(
                children: [
                  Text(
                    widget.deal.providerName,
                    style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.7), fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.deal.planName,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Bottom: Price
              Column(
                children: [
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: '\$',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.vibrantEmerald),
                        ),
                        TextSpan(
                          text: widget.deal.price > 0 ? widget.deal.price.toStringAsFixed(0) : 'Check',
                          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.vibrantEmerald),
                        ),
                        TextSpan(
                          text: ' ${widget.deal.priceUnit}',
                          style: const TextStyle(fontSize: 12, color: Colors.white54),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Tap for details',
                          style: TextStyle(fontSize: 10, color: Colors.white70),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.touch_app, size: 12, color: Colors.white70),
                      ],
                    ),
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

  Widget _buildLogo() {
    final logoUrl = widget.deal.providerLogoUrl;
    final isSvg = logoUrl.toLowerCase().endsWith('.svg');

    return Container(
      width: 56, 
      height: 56, 
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipOval(
        child: isSvg
            ? SvgPicture.network(
                logoUrl,
                fit: BoxFit.contain,
                placeholderBuilder: (context) => _buildFallbackLogo(),
              )
            : Image.network(
                logoUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => _buildFallbackLogo(),
              ),
      ),
    );
  }

  Widget _buildFallbackLogo() {
    return Container(
      color: widget.deal.providerColor,
      alignment: Alignment.center,
      child: Text(
        widget.deal.providerName.isNotEmpty ? widget.deal.providerName[0] : '?',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 24,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildBack() {
    return GlassContainer(
      borderRadius: 16,
      padding: const EdgeInsets.all(16),
      color: AppTheme.deepNavy.withOpacity(0.95),
      borderColor: AppTheme.vibrantEmerald.withOpacity(0.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Key Features',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.vibrantEmerald.withOpacity(0.9)),
              ),
              const Icon(Icons.info_outline, size: 16, color: Colors.white54),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              physics: const BouncingScrollPhysics(),
              children: [
                ...widget.deal.keyFeatures.map((feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 2.0),
                        child: Icon(Icons.check_circle, color: AppTheme.vibrantEmerald.withOpacity(0.8), size: 14),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          feature,
                          style: const TextStyle(fontSize: 12, color: Colors.white, height: 1.3),
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton(
              onPressed: _launchURL,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.vibrantEmerald,
                foregroundColor: AppTheme.deepNavy,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Go to Site', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color bg, Color fg) {
    return Positioned(
      top: 0,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
          boxShadow: [
            BoxShadow(
              color: bg.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: fg,
            fontWeight: FontWeight.bold,
            fontSize: 10,
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }
}
