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
  bool _isHovered = false;

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
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: _flipCard,
        child: AnimatedScale(
          scale: _isHovered ? 1.03 : 1.0,
          duration: const Duration(milliseconds: 200),
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
        ),
      ),
    );
  }

  Widget _buildFront() {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: widget.isBestValue ? AppTheme.vibrantEmerald : (_isHovered ? AppTheme.accentOrange.withOpacity(0.5) : const Color(0xFFEAECF0)),
              width: widget.isBestValue || _isHovered ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: _isHovered ? Colors.black.withOpacity(0.15) : Colors.black.withOpacity(0.08),
                blurRadius: _isHovered ? 24 : 16,
                offset: _isHovered ? const Offset(0, 12) : const Offset(0, 8),
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
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(color: Colors.amber.shade200),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            widget.deal.rating.toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.deepNavy),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: 24),

              // Middle: Info
              Column(
                children: [
                  Text(
                    widget.deal.providerName.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 11, 
                      color: AppTheme.primaryBlue, 
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.deal.planName,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.offWhite,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: [
                          if (widget.deal.category != ProductCategory.electricity && widget.deal.category != ProductCategory.gas)
                            const TextSpan(
                              text: '\$',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.deepNavy),
                            ),
                          TextSpan(
                            text: widget.deal.price > 0 
                                ? (widget.deal.price % 1 == 0 ? widget.deal.price.toStringAsFixed(0) : widget.deal.price.toStringAsFixed(2))
                                : 'Check',
                            style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: AppTheme.deepNavy, letterSpacing: -1.5),
                          ),
                          TextSpan(
                            text: ' / ${widget.deal.priceUnit}',
                            style: const TextStyle(fontSize: 13, color: AppTheme.slate600, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: _isHovered ? AppTheme.accentOrange : AppTheme.primaryBlue.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'VIEW DETAILS',
                          style: TextStyle(
                            fontSize: 13, 
                            color: _isHovered ? Colors.white : AppTheme.primaryBlue, 
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward_ios, 
                          size: 12, 
                          color: _isHovered ? Colors.white : AppTheme.primaryBlue,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (widget.isBestValue) _buildBadge('BEST VALUE', AppTheme.vibrantEmerald, Colors.white),
        if (widget.deal.isSponsored && !widget.isBestValue) _buildBadge('SPONSORED', AppTheme.deepNavy, Colors.white),
      ],
    );
  }

  Widget _buildLogo() {
    final logoUrl = widget.deal.providerLogoUrl;
    final isSvg = logoUrl.toLowerCase().endsWith('.svg');

    return Container(
      width: 64, 
      height: 64, 
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppTheme.offWhite, width: 2),
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
          fontSize: 28,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildBack() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.deepNavy,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(0, 15),
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
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.white, letterSpacing: 1.0),
              ),
              const Icon(Icons.info_outline, size: 20, color: AppTheme.accentOrange),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              physics: const BouncingScrollPhysics(),
              children: [
                ...widget.deal.keyFeatures.map((feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 2.0),
                        child: Icon(Icons.check_circle, color: AppTheme.vibrantEmerald, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          feature,
                          style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.9), height: 1.5, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _launchURL,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentOrange,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('GO TO SITE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1.0)),
                  SizedBox(width: 8),
                  Icon(Icons.open_in_new, size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color bg, Color fg) {
    return Positioned(
      top: 0,
      right: 24,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
          boxShadow: [
            BoxShadow(
              color: bg.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: fg,
            fontWeight: FontWeight.w900,
            fontSize: 11,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}