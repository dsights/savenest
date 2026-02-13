import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../theme/app_theme.dart';
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
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.isBestValue ? AppTheme.vibrantEmerald : const Color(0xFFEAECF0),
              width: widget.isBestValue ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
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
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(color: const Color(0xFFEAECF0)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            widget.deal.rating.toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.deepNavy),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: 16),

              // Middle: Info
              Column(
                children: [
                  Text(
                    widget.deal.providerName,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF667085), fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.deal.planName,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.deepNavy,
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
                        if (widget.deal.category != ProductCategory.electricity && widget.deal.category != ProductCategory.gas)
                          const TextSpan(
                            text: '\$',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.deepNavy),
                          ),
                        TextSpan(
                          text: widget.deal.price > 0 
                              ? (widget.deal.price % 1 == 0 ? widget.deal.price.toStringAsFixed(0) : widget.deal.price.toStringAsFixed(2))
                              : 'Check',
                          style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppTheme.deepNavy, letterSpacing: -1.0),
                        ),
                        TextSpan(
                          text: '/${widget.deal.priceUnit}',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF667085), fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'View Details',
                          style: TextStyle(fontSize: 12, color: AppTheme.primaryBlue, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward, size: 14, color: AppTheme.primaryBlue),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (widget.isBestValue) _buildBadge('BEST VALUE', AppTheme.vibrantEmerald, Colors.white),
        if (widget.deal.isSponsored && !widget.isBestValue) _buildBadge('SPONSORED', const Color(0xFFF2F4F7), const Color(0xFF667085)),
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
            color: Colors.black.withOpacity(0.1),
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.deepNavy,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Key Features',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
              ),
              Icon(Icons.info_outline, size: 16, color: Colors.white.withOpacity(0.5)),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              physics: const BouncingScrollPhysics(),
              children: [
                ...widget.deal.keyFeatures.map((feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 2.0),
                        child: Icon(Icons.check_circle, color: AppTheme.vibrantEmerald, size: 16),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          feature,
                          style: const TextStyle(fontSize: 13, color: Colors.white, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _launchURL,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.vibrantEmerald,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
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