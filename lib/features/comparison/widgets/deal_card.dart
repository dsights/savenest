import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../theme/app_theme.dart';
import '../comparison_model.dart';
import '../../gamification/gamification_provider.dart';

class DealCard extends ConsumerStatefulWidget {
  final Deal deal;
  final bool isBestValue;
  final bool isSelectedForComparison;
  final VoidCallback? onToggleCompare;

  const DealCard({
    super.key,
    required this.deal,
    this.isBestValue = false,
    this.isSelectedForComparison = false,
    this.onToggleCompare,
  });

  @override
  ConsumerState<DealCard> createState() => _DealCardState();
}

class _DealCardState extends ConsumerState<DealCard> with TickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  late AnimationController _pulseController;
  bool _isFront = true;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOutBack),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _flipController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (_isFront) {
      _flipController.forward();
    } else {
      _flipController.reverse();
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

  Future<void> _launchWithCelebration() async {
    ref.read(gamificationProvider.notifier).recordSwitch();
    _showXPFloat(context, '+50 XP 🏆', Colors.amber);
    await _launchURL();
    if (!mounted) return;
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.deepNavy, Color(0xFF003A72)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.amber, width: 2),
            boxShadow: [
              BoxShadow(color: Colors.amber.withOpacity(0.3), blurRadius: 24),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🎉', style: TextStyle(fontSize: 60)),
              const SizedBox(height: 12),
              const Text(
                'You\'re Switching!',
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              Text(
                'Taking you to ${widget.deal.providerName}...',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: Colors.amber),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 16),
                    SizedBox(width: 6),
                    Text(
                      '+50 XP Earned!',
                      style: TextStyle(color: Colors.amber, fontWeight: FontWeight.w900, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) Navigator.of(context, rootNavigator: true).pop();
  }

  void _showXPFloat(BuildContext ctx, String label, Color color) {
    final box = ctx.findRenderObject() as RenderBox?;
    if (box == null) return;
    final pos = box.localToGlobal(Offset.zero);
    final sz = box.size;

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => Positioned(
        left: pos.dx + sz.width / 2 - 32,
        top: pos.dy - 10,
        child: IgnorePointer(
          child: _XPFloatLabel(
            label: label,
            color: color,
            onDone: () {
              if (entry.mounted) entry.remove();
            },
          ),
        ),
      ),
    );
    Overlay.of(ctx).insert(entry);
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.03 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: AnimatedBuilder(
          animation: _flipAnimation,
          builder: (context, child) {
            final angle = _flipAnimation.value * pi;
            final isBack = angle >= pi / 2;

            return Transform(
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(angle),
              alignment: Alignment.center,
              child: isBack
                  ? Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()..rotateY(pi),
                      child: _buildBack(),
                    )
                  : _buildFront(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFront() {
    return Stack(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.isBestValue
                  ? AppTheme.vibrantEmerald
                  : (_isHovered ? widget.deal.providerColor.withOpacity(0.5) : const Color(0xFFEAECF0)),
              width: widget.isBestValue || _isHovered ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? widget.deal.providerColor.withOpacity(0.15)
                    : Colors.black.withOpacity(0.04),
                blurRadius: _isHovered ? 24 : 12,
                spreadRadius: _isHovered ? 4 : 0,
                offset: _isHovered ? const Offset(0, 12) : const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                // Background watermark
                Positioned(
                  right: -10,
                  bottom: -10,
                  child: Icon(
                    _getCategoryIcon(widget.deal.category),
                    size: 50,
                    color: AppTheme.deepNavy.withOpacity(0.03),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Top row: ECO badge (left) + Match badge (right)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.deal.isGreen)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(color: Colors.green.shade200),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.eco, color: Colors.green, size: 10),
                                SizedBox(width: 3),
                                Text(
                                  'ECO',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 9,
                                    color: Colors.green,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          const SizedBox(width: 4),
                        if (widget.deal.rating > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Colors.amber.shade400, Colors.amber.shade600],
                              ),
                              borderRadius: BorderRadius.circular(100),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.amber.withOpacity(0.4),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.auto_awesome, color: Colors.white, size: 11),
                                const SizedBox(width: 4),
                                Text(
                                  '${(widget.deal.rating * 20).toInt()}% MATCH',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 9,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          const SizedBox(width: 4),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Logo — centered and prominent
                    Center(child: _buildLogo()),

                    const SizedBox(height: 8),

                    // Provider name badge
                    InkWell(
                      onTap: () {
                        final slug = widget.deal.providerName
                            .toLowerCase()
                            .replaceAll(' ', '-')
                            .replaceAll('(', '')
                            .replaceAll(')', '');
                        context.push('/provider/$slug');
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: EdgeInsets.symmetric(
                          horizontal: _isHovered ? 8 : 6,
                          vertical: _isHovered ? 4 : 3,
                        ),
                        decoration: BoxDecoration(
                          color: _isHovered
                              ? widget.deal.providerColor
                              : widget.deal.providerColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: _isHovered
                              ? [
                                  BoxShadow(
                                    color: widget.deal.providerColor.withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  )
                                ]
                              : [],
                        ),
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 300),
                          style: TextStyle(
                            fontSize: 9,
                            color: _isHovered
                                ? (widget.deal.providerColor.computeLuminance() > 0.5
                                    ? AppTheme.deepNavy
                                    : Colors.white)
                                : (widget.deal.providerColor.computeLuminance() > 0.5
                                    ? AppTheme.deepNavy
                                    : widget.deal.providerColor),
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                            fontFamily: 'Montserrat',
                          ),
                          child: Text(
                            widget.deal.providerName.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 3),

                    // Plan name
                    Text(
                      widget.deal.planName,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.deepNavy,
                        height: 1.2,
                      ),
                    ),

                    const Spacer(),

                    // Price
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: _isHovered
                            ? AppTheme.offWhite.withOpacity(0.8)
                            : AppTheme.offWhite,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _isHovered
                              ? widget.deal.providerColor.withOpacity(0.2)
                              : Colors.transparent,
                        ),
                      ),
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          children: [
                            if (widget.deal.category != ProductCategory.electricity &&
                                widget.deal.category != ProductCategory.gas &&
                                widget.deal.category != ProductCategory.solar)
                              const TextSpan(
                                text: '\$',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.deepNavy,
                                ),
                              ),
                            TextSpan(
                              text: widget.deal.price > 0
                                  ? (widget.deal.price % 1 == 0
                                      ? widget.deal.price.toStringAsFixed(0)
                                      : widget.deal.price.toStringAsFixed(2))
                                  : 'Check',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: _isHovered
                                    ? widget.deal.providerColor
                                    : AppTheme.deepNavy,
                                letterSpacing: -0.5,
                              ),
                            ),
                            TextSpan(
                              text: widget.deal.priceUnit,
                              style: const TextStyle(
                                fontSize: 9,
                                color: AppTheme.slate600,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Bottom CTA row: Compare (left) | View Details (right)
                    Row(
                      children: [
                        // Compare button — always visible, left side
                        if (widget.onToggleCompare != null)
                          Expanded(
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                widget.onToggleCompare?.call();
                                ref.read(gamificationProvider.notifier).recordCompare();
                                _showXPFloat(context, '+10 XP', AppTheme.primaryBlue);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                padding: const EdgeInsets.symmetric(vertical: 7),
                                decoration: BoxDecoration(
                                  color: widget.isSelectedForComparison
                                      ? AppTheme.vibrantEmerald
                                      : AppTheme.primaryBlue.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: widget.isSelectedForComparison
                                        ? AppTheme.vibrantEmerald
                                        : AppTheme.primaryBlue.withOpacity(0.5),
                                    width: 1.5,
                                  ),
                                  boxShadow: widget.isSelectedForComparison
                                      ? [
                                          BoxShadow(
                                            color: AppTheme.vibrantEmerald.withOpacity(0.3),
                                            blurRadius: 6,
                                            offset: const Offset(0, 3),
                                          )
                                        ]
                                      : [],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      widget.isSelectedForComparison
                                          ? Icons.check_circle
                                          : Icons.compare_arrows,
                                      size: 11,
                                      color: widget.isSelectedForComparison
                                          ? Colors.white
                                          : AppTheme.primaryBlue,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      widget.isSelectedForComparison ? 'Added' : 'Compare',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        color: widget.isSelectedForComparison
                                            ? Colors.white
                                            : AppTheme.primaryBlue,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        if (widget.onToggleCompare != null) const SizedBox(width: 6),
                        // View Details button — always visible, right side
                        Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              _flipCard();
                              // _flipCard toggles _isFront; !_isFront now means we just revealed the back (details view)
                              if (!_isFront) {
                                ref.read(gamificationProvider.notifier).recordView();
                                _showXPFloat(context, '+5 XP', AppTheme.accentOrange);
                              }
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              padding: const EdgeInsets.symmetric(vertical: 7),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [AppTheme.accentOrange, Color(0xFFFF9500)],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.accentOrange.withOpacity(
                                      _isHovered ? 0.45 : 0.25,
                                    ),
                                    blurRadius: _isHovered ? 10 : 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'View Details',
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  SizedBox(width: 3),
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 11,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        // Top Color Accent Bar
        Positioned(
          top: 0,
          left: 20,
          right: 20,
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              color: widget.deal.providerColor,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(4)),
            ),
          ),
        ),
        if (widget.isBestValue) _buildBadge('BEST VALUE', AppTheme.vibrantEmerald, Colors.white),
        if (widget.deal.isSponsored && !widget.isBestValue)
          _buildBadge('SPONSORED', AppTheme.deepNavy, Colors.white),
      ],
    );
  }

  IconData _getCategoryIcon(ProductCategory category) {
    switch (category) {
      case ProductCategory.electricity:
        return Icons.bolt;
      case ProductCategory.gas:
        return Icons.local_fire_department;
      case ProductCategory.solar:
        return Icons.solar_power;
      case ProductCategory.internet:
        return Icons.wifi;
      case ProductCategory.mobile:
        return Icons.phone_iphone;
      case ProductCategory.insurance:
        return Icons.shield;
      case ProductCategory.creditCards:
        return Icons.credit_card;
      default:
        return Icons.category;
    }
  }

  Widget _buildLogo() {
    final localAsset = _getLocalAssetPath(widget.deal.providerName);
    final logoUrl = widget.deal.providerLogoUrl;
    final isSvg = logoUrl.toLowerCase().endsWith('.svg');

    return Container(
      width: 90,
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: widget.deal.providerColor.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: widget.deal.providerColor.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: localAsset != null
            ? Image.asset(
                localAsset,
                fit: BoxFit.contain,
                semanticLabel: '${widget.deal.providerName} logo',
                errorBuilder: (context, error, stackTrace) =>
                    _buildLogoFromUrl(logoUrl, isSvg),
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
    final name = providerName.toLowerCase().replaceAll(' ', '').replaceAll('-', '').replaceAll('_', '');

    // Energy providers
    if (name.contains('origin')) return 'assets/images/logos/origin_energy.png';
    if (name.contains('energyaustralia')) return 'assets/images/logos/energyaustralia.jpg';
    if (name.contains('agl')) return 'assets/images/logos/agl.png';
    if (name.contains('ovo')) return 'assets/images/logos/ovo_energy.png';
    if (name.contains('globird')) return 'assets/images/logos/globird_energy.png';
    if (name.contains('amber')) return 'assets/images/logos/amber_electric.jpg';
    if (name.contains('alinta')) return 'assets/images/logos/alinta_energy.png';
    if (name.contains('covau')) return 'assets/images/logos/covau.png';
    if (name.contains('diamond')) return 'assets/images/logos/diamond_energy.png';
    if (name.contains('engie')) return 'assets/images/logos/engie.png';
    if (name.contains('energylocals') || name.contains('energylocal')) return 'assets/images/logos/energy_locals.png';
    if (name.contains('1stenergy') || name.contains('firstenergy')) return 'assets/images/logos/1st_energy.png';
    if (name.contains('lumo')) return 'assets/images/logos/lumo_energy.png';
    if (name.contains('momentum')) return 'assets/images/logos/momentum_energy.png';
    if (name.contains('powershop')) return 'assets/images/logos/powershop.png';
    if (name.contains('redenergy') || (name.contains('red') && name.contains('energy'))) return 'assets/images/logos/red_energy.png';
    if (name.contains('shellenergy') || (name.contains('shell') && name.contains('energy'))) return 'assets/images/logos/shell_energy.png';
    if (name.contains('sumo')) return 'assets/images/logos/sumo.png';

    // Gas providers
    if (name.contains('kleenheat')) return 'assets/images/logos/kleenheat.png';
    if (name.contains('elgas')) return 'assets/images/logos/elgas.png';
    if (name.contains('supagas')) return 'assets/images/logos/supagas.png';

    // Internet providers
    if (name.contains('spintel')) return 'assets/images/logos/spintel.png';
    if (name.contains('aussiebroadband') || name.contains('aussiebb')) return 'assets/images/logos/aussie_broadband.png';
    if (name.contains('exetel')) return 'assets/images/logos/exetel.png';
    if (name.contains('tangerine')) return 'assets/images/logos/tangerine.png';
    if (name.contains('tpg')) return 'assets/images/logos/tpg.png';
    if (name.contains('iinet')) return 'assets/images/logos/iinet.png';
    if (name.contains('superloop')) return 'assets/images/logos/superloop.png';
    if (name.contains('flip')) return 'assets/images/logos/flip.png';
    if (name.contains('swoop')) return 'assets/images/logos/swoop.png';
    if (name.contains('southernphone')) return 'assets/images/logos/southern_phone.png';
    if (name.contains('arctel')) return 'assets/images/logos/arctel.png';
    if (name.contains('mate')) return 'assets/images/logos/mate.png';
    if (name.contains('moretelecom') || name.contains('moretele')) return 'assets/images/logos/more_telecom.png';

    // Telco/Mobile
    if (name.contains('telstra')) return 'assets/images/logos/telstra.png';
    if (name.contains('optus')) return 'assets/images/logos/optus.png';
    if (name.contains('vodafone')) return 'assets/images/logos/vodafone.png';
    if (name.contains('belong')) return 'assets/images/logos/belong.png';
    if (name.contains('amaysim')) return 'assets/images/logos/amaysim.png';
    if (name.contains('aldimobile') || name.contains('aldi')) return 'assets/images/logos/aldi_mobile.png';
    if (name.contains('boostmobile') || name.contains('boost')) return 'assets/images/logos/boost_mobile.png';
    if (name.contains('colesmobile') || (name.contains('coles') && name.contains('mobile'))) return 'assets/images/logos/coles.png';
    if (name.contains('felix')) return 'assets/images/logos/felix.png';
    if (name.contains('moosemobile') || name.contains('moose')) return 'assets/images/logos/moose_mobile.png';
    if (name.contains('everydaymobile') || (name.contains('everyday') && name.contains('mobile'))) return 'assets/images/logos/coles.png';

    // Insurance providers
    if (name.contains('aami')) return 'assets/images/logos/aami.png';
    if (name.contains('allianz')) return 'assets/images/logos/allianz.png';
    if (name.contains('bupa')) return 'assets/images/logos/bupa.png';
    if (name.contains('nrma')) return 'assets/images/logos/nrma.png';
    if (name.contains('youi')) return 'assets/images/logos/youi.png';
    if (name.contains('budgetdirect') || name.contains('budget')) return 'assets/images/logos/budget_direct.png';
    if (name.contains('bingle')) return 'assets/images/logos/bingle.png';
    if (name.contains('colesinsurance') || (name.contains('coles') && name.contains('insur'))) return 'assets/images/logos/coles.png';
    if (name.contains('medibank')) return 'assets/images/logos/medibank.png';
    if (name.contains('hcf')) return 'assets/images/logos/hcf.png';
    if (name.contains('cbhs')) return 'assets/images/logos/cbhs.png';
    if (name.contains('gmhba') || name.contains('frank')) return 'assets/images/logos/gmhba.png';
    if (name.contains('nib')) return 'assets/images/logos/nib.png';
    if (name.contains('everydayinsurance')) return 'assets/images/logos/coles.png';

    // Solar providers
    if (name.contains('arisesolar') || name.contains('arise')) return 'assets/images/logos/arise_solar.png';
    if (name.contains('energymatters')) return 'assets/images/logos/energy_matters.png';
    if (name.contains('fortunesolar') || name.contains('fortune')) return 'assets/images/logos/fortune_solar.png';
    if (name.contains('solahart')) return 'assets/images/logos/solahart.png';
    if (name.contains('solarchoice')) return 'assets/images/logos/solar_choice.png';
    if (name.contains('solargain')) return 'assets/images/logos/solargain.png';
    if (name.contains('tesla')) return 'assets/images/logos/tesla.png';

    // Dodo & Kogan (multi-category)
    if (name.contains('dodo')) return 'assets/images/logos/dodo.png';
    if (name.contains('kogan')) return 'assets/images/logos/kogan.png';

    // Banks & credit cards
    if (name.contains('woolworths')) return 'assets/images/logos/woolworths.png';
    if (name.contains('suncorp')) return 'assets/images/logos/suncorp.png';
    if (name.contains('westpac')) return 'assets/images/logos/westpac.png';
    if (name.contains('anz')) return 'assets/images/logos/anz.png';
    if (name.contains('cba') || name.contains('commonwealth')) return 'assets/images/logos/cba.png';
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
          fontSize: 20,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildBack() {
    return GestureDetector(
      onTap: _flipCard,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.deepNavy,
          borderRadius: BorderRadius.circular(12),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Key Features',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                GestureDetector(
                  onTap: _flipCard,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.arrow_back, size: 10, color: Colors.white54),
                        SizedBox(width: 3),
                        Text(
                          'Back',
                          style: TextStyle(fontSize: 9, color: Colors.white54, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                physics: const BouncingScrollPhysics(),
                children: [
                  ...widget.deal.keyFeatures.map((feature) => _buildFeatureRow(feature)),
                  if (widget.deal.details.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Divider(color: Colors.white24),
                    ),
                    ...widget.deal.details.entries.map((entry) => _buildFeatureRow('${entry.key}: ${entry.value}')),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              height: 34,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.accentOrange, Color(0xFFFF9500)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accentOrange.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _launchWithCelebration,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('GO TO SITE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.0)),
                    SizedBox(width: 5),
                    Icon(Icons.open_in_new, size: 11),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(String feature) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 1.0),
            child: Icon(Icons.check_circle, color: AppTheme.vibrantEmerald, size: 12),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              feature,
              style: TextStyle(
                fontSize: 10,
                color: Colors.white.withOpacity(0.95),
                height: 1.3,
                fontWeight: FontWeight.w600,
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
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          final isBest = widget.isBestValue;
          final scale = isBest ? 1.0 + (_pulseController.value * 0.05) : 1.0;
          return Transform.scale(
            scale: scale,
            alignment: Alignment.topCenter,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
                boxShadow: [
                  BoxShadow(
                    color: bg.withOpacity(isBest ? 0.4 + (_pulseController.value * 0.3) : 0.4),
                    blurRadius: isBest ? 8 + (_pulseController.value * 6) : 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isBest) ...[
                    const Icon(Icons.local_fire_department, color: Colors.white, size: 11),
                    const SizedBox(width: 3),
                  ],
                  Text(
                    text,
                    style: TextStyle(
                      color: fg,
                      fontWeight: FontWeight.w900,
                      fontSize: 9,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// Floating "+XP" label that animates upward and fades out
class _XPFloatLabel extends StatefulWidget {
  final String label;
  final Color color;
  final VoidCallback onDone;

  const _XPFloatLabel({
    required this.label,
    required this.color,
    required this.onDone,
  });

  @override
  State<_XPFloatLabel> createState() => _XPFloatLabelState();
}

class _XPFloatLabelState extends State<_XPFloatLabel>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    );
    _ctrl.forward().then((_) => widget.onDone());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final t = _ctrl.value;
        final opacity = t < 0.65 ? 1.0 : 1.0 - ((t - 0.65) / 0.35);
        return Transform.translate(
          offset: Offset(0, -56 * Curves.easeOut.transform(t)),
          child: Opacity(
            opacity: opacity.clamp(0.0, 1.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: widget.color,
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withOpacity(0.45),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                widget.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
