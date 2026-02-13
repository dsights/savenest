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
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.isBestValue ? AppTheme.vibrantEmerald : (_isHovered ? AppTheme.accentOrange.withOpacity(0.5) : const Color(0xFFEAECF0)),
              width: widget.isBestValue || _isHovered ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: _isHovered ? Colors.black.withOpacity(0.1) : Colors.black.withOpacity(0.05),
                blurRadius: _isHovered ? 16 : 8,
                offset: _isHovered ? const Offset(0, 8) : const Offset(0, 4),
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
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(color: Colors.amber.shade200),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 10),
                          const SizedBox(width: 2),
                          Text(
                            widget.deal.rating.toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: AppTheme.deepNavy),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: 4),

              // Middle: Info
              Column(
                children: [
                  Text(
                    widget.deal.providerName.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 8, 
                      color: AppTheme.primaryBlue, 
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.deal.planName,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.deepNavy,
                      height: 1.1,
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Bottom: Price
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.offWhite,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: [
                          if (widget.deal.category != ProductCategory.electricity && widget.deal.category != ProductCategory.gas)
                            const TextSpan(
                              text: '\$',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.deepNavy),
                            ),
                          TextSpan(
                            text: widget.deal.price > 0 
                                ? (widget.deal.price % 1 == 0 ? widget.deal.price.toStringAsFixed(0) : widget.deal.price.toStringAsFixed(2))
                                : 'Check',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppTheme.deepNavy, letterSpacing: -0.5),
                          ),
                          TextSpan(
                            text: ' / ${widget.deal.priceUnit}',
                            style: const TextStyle(fontSize: 9, color: AppTheme.slate600, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                            fontSize: 9, 
                            color: _isHovered ? Colors.white : AppTheme.primaryBlue, 
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_ios, 
                          size: 8, 
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
    final localAsset = _getLocalAssetPath(widget.deal.providerName);
    final logoUrl = widget.deal.providerLogoUrl;
    final isSvg = logoUrl.toLowerCase().endsWith('.svg');

    return Container(
      width: 32, 
      height: 32, 
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: AppTheme.offWhite, width: 1.0),
      ),
      child: ClipOval(
        child: localAsset != null
            ? Image.asset(
                localAsset, 
                fit: BoxFit.contain, 
                semanticLabel: '${widget.deal.providerName} logo',
                errorBuilder: (context, error, stackTrace) => _buildLogoFromUrl(logoUrl, isSvg),
              )
            : _buildLogoFromUrl(logoUrl, isSvg),
      ),
    );
  }

  Widget _buildLogoFromUrl(String logoUrl, bool isSvg) {
    if (logoUrl.isEmpty) return _buildFallbackLogo();
    
    return isSvg
        ? SvgPicture.network(
            logoUrl,
            fit: BoxFit.contain,
            semanticsLabel: '${widget.deal.providerName} logo',
            placeholderBuilder: (context) => _buildFallbackLogo(),
          )
        : Image.network(
            logoUrl,
            fit: BoxFit.contain,
            semanticLabel: '${widget.deal.providerName} logo',
            errorBuilder: (context, error, stackTrace) => _buildFallbackLogo(),
          );
  }

  String? _getLocalAssetPath(String providerName) {
    final name = providerName.toLowerCase().replaceAll(' ', '');
    
    // Mapping of provider name fragments to asset filenames
    if (name.contains('origin')) return 'assets/images/logos/origin_energy.png';
    if (name.contains('energyaustralia')) return 'assets/images/logos/energyaustralia.jpg';
    if (name.contains('agl')) return 'assets/images/logos/agl.png';
    if (name.contains('ovo')) return 'assets/images/logos/ovo_energy.png';
    if (name.contains('globird')) return 'assets/images/logos/globird_energy.png';
    if (name.contains('amber')) return 'assets/images/logos/amber_electric.jpg';
    if (name.contains('dodo')) return 'assets/images/logos/dodo.png';
    if (name.contains('telstra')) return 'assets/images/logos/anz.png'; // Example fallback if missing, but let's check
    if (name.contains('kogan')) return 'assets/images/logos/kogan.png';
    if (name.contains('woolworths')) return 'assets/images/logos/woolworths.png';
    if (name.contains('suncorp')) return 'assets/images/logos/suncorp.png';
    if (name.contains('westpac')) return 'assets/images/logos/westpac.png';
    if (name.contains('anz')) return 'assets/images/logos/anz.png';
    if (name.contains('cba')) return 'assets/images/logos/cba.png';
    if (name.contains('nab')) return 'assets/images/logos/nab.jpg';
    if (name.contains('airwallex')) return 'assets/images/logos/airwallex.png';
    if (name.contains('volopay')) return 'assets/images/logos/volopay.png';
    
    return null;
  }

  Widget _buildFallbackLogo() {
    return Container(
      color: widget.deal.providerColor,
      alignment: Alignment.center,
      child: Text(
        widget.deal.providerName.isNotEmpty ? widget.deal.providerName[0] : '?',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildBack() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.deepNavy,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Key Features',
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Colors.white, letterSpacing: 0.5),
                          ),
                          Icon(Icons.info_outline, size: 14, color: AppTheme.accentOrange),
                        ],
                      ),          const SizedBox(height: 12),
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
                      const Padding(
                        padding: EdgeInsets.only(top: 2.0),
                        child: Icon(Icons.check_circle, color: AppTheme.vibrantEmerald, size: 14),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          feature,
                          style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.9), height: 1.3, fontWeight: FontWeight.w500),
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
                backgroundColor: AppTheme.accentOrange,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('GO TO SITE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.5)),
                  SizedBox(width: 4),
                  Icon(Icons.open_in_new, size: 12),
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