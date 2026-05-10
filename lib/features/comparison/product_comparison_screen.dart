import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_theme.dart';
import '../../widgets/main_navigation_bar.dart';
import '../../widgets/main_mobile_drawer.dart';
import '../home/widgets/modern_footer.dart';
import 'comparison_model.dart';
import 'comparison_provider.dart';

class ProductComparisonScreen extends ConsumerStatefulWidget {
  final List<String> dealIds;
  final String categorySlug;

  const ProductComparisonScreen({
    super.key,
    required this.dealIds,
    required this.categorySlug,
  });

  @override
  ConsumerState<ProductComparisonScreen> createState() =>
      _ProductComparisonScreenState();
}

class _ProductComparisonScreenState
    extends ConsumerState<ProductComparisonScreen> {
  bool _showDiffsOnly = false;
  Map<String, dynamic>? _schema;

  @override
  void initState() {
    super.initState();
    _loadSchema();
  }

  Future<void> _loadSchema() async {
    try {
      final raw =
          await rootBundle.loadString('assets/data/comparison_schemas.json');
      final all = jsonDecode(raw) as Map<String, dynamic>;
      setState(() {
        _schema = all[widget.categorySlug] as Map<String, dynamic>?;
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final dealsAsync = ref.watch(selectedDealsProvider(widget.dealIds));

    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      endDrawer: const MainMobileDrawer(),
      body: Column(
        children: [
          const MainNavigationBar(),
          Expanded(
            child: dealsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppTheme.accentOrange),
              ),
              error: (e, _) => Center(child: Text('Error loading deals: $e')),
              data: (deals) {
                if (deals.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.compare_arrows,
                            size: 56, color: AppTheme.slate600),
                        const SizedBox(height: 16),
                        const Text('No deals found to compare.',
                            style: TextStyle(fontSize: 18)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => context.go('/'),
                          child: const Text('Back to Home'),
                        ),
                      ],
                    ),
                  );
                }
                return _buildComparison(deals);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparison(List<Deal> deals) {
    final sections = _schema?['sections'] as List<dynamic>? ?? [];
    final isWide = MediaQuery.of(context).size.width > 800;

    return CustomScrollView(
      slivers: [
        // ── Hero ─────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppTheme.deepNavy, AppTheme.primaryBlue],
              ),
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.arrow_back,
                            color: Colors.white, size: 20),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            deals.map((d) => d.providerName).join(' vs '),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Side-by-side ${_categoryLabel(widget.categorySlug)} comparison',
                            style: const TextStyle(
                                color: Colors.white60, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    // Diffs toggle
                    Row(
                      children: [
                        const Text('Differences only',
                            style: TextStyle(color: Colors.white70, fontSize: 13)),
                        const SizedBox(width: 8),
                        Switch(
                          value: _showDiffsOnly,
                          onChanged: (v) => setState(() => _showDiffsOnly = v),
                          activeColor: AppTheme.vibrantEmerald,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // ── Comparison table ──────────────────────────────────────────
        SliverToBoxAdapter(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: isWide
                    ? _buildTable(deals, sections)
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: _buildTable(deals, sections,
                            minWidth: deals.length * 220.0 + 200),
                      ),
              ),
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 80)),
        const SliverToBoxAdapter(child: ModernFooter()),
      ],
    );
  }

  Widget _buildTable(List<Deal> deals, List<dynamic> sections,
      {double? minWidth}) {
    final bestDeal = _bestValueDeal(deals);

    return Container(
      width: minWidth,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Sticky product header ─────────────────────────────────
          _buildProductHeader(deals, bestDeal),

          // ── Feature sections ──────────────────────────────────────
          for (final section in sections)
            _buildSection(deals, section as Map<String, dynamic>),

          // ── Action row ────────────────────────────────────────────
          _buildActionRow(deals, bestDeal),
        ],
      ),
    );
  }

  Widget _buildProductHeader(List<Deal> deals, Deal? bestDeal) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.deepNavy,
      ),
      child: Row(
        children: [
          // Feature label column
          SizedBox(
            width: 200,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Feature',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ),
          // Product columns
          ...deals.map((deal) {
            final isBest = deal == bestDeal;
            return Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(color: Colors.white.withOpacity(0.08)),
                    bottom: isBest
                        ? const BorderSide(
                            color: AppTheme.vibrantEmerald, width: 3)
                        : BorderSide.none,
                  ),
                  color: isBest
                      ? AppTheme.vibrantEmerald.withOpacity(0.12)
                      : Colors.transparent,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: deal.providerColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            deal.providerName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        if (isBest)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.vibrantEmerald,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'BEST',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      deal.planName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _priceLabel(deal),
                      style: const TextStyle(
                        color: AppTheme.vibrantEmerald,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (deal.tagline.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        deal.tagline,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.45),
                          fontSize: 10,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSection(List<Deal> deals, Map<String, dynamic> section) {
    final label = section['label'] as String;
    final rows = section['rows'] as List<dynamic>;

    // Filter to only differing rows when toggle is on
    final visibleRows = _showDiffsOnly
        ? rows.where((r) => _hasDifference(deals, r as Map<String, dynamic>)).toList()
        : rows;

    if (visibleRows.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Section header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: const Color(0xFFF4F6FA),
          child: Row(
            children: [
              SizedBox(
                width: 200,
                child: Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.deepNavy,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              ...deals.map((_) => const Expanded(child: SizedBox())),
            ],
          ),
        ),
        // Rows
        ...visibleRows.asMap().entries.map((entry) {
          final isEven = entry.key.isEven;
          return _buildFeatureRow(
              deals, entry.value as Map<String, dynamic>, isEven);
        }),
      ],
    );
  }

  Widget _buildFeatureRow(
      List<Deal> deals, Map<String, dynamic> rowDef, bool isEven) {
    final key = rowDef['key'] as String;
    final label = rowDef['label'] as String;
    final type = rowDef['type'] as String;

    return Container(
      color: isEven ? Colors.white : const Color(0xFFFAFBFC),
      child: Row(
        children: [
          // Feature label
          SizedBox(
            width: 200,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.deepNavy,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          // Value cells
          ...deals.map((deal) {
            return Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  border: Border(
                    left: BorderSide(color: Color(0xFFEEEFF2), width: 1),
                  ),
                ),
                child: _buildCell(deal, key, type),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCell(Deal deal, String key, String type) {
    switch (type) {
      case 'bool':
        final val = deal.boolFeatures[key];
        if (val == null) {
          return const Text('—',
              style: TextStyle(
                  fontSize: 16, color: Colors.grey, fontWeight: FontWeight.bold));
        }
        return Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: val
                    ? AppTheme.vibrantEmerald.withOpacity(0.12)
                    : Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                val ? Icons.check : Icons.close,
                color: val ? AppTheme.vibrantEmerald : Colors.red,
                size: 14,
              ),
            ),
          ],
        );

      case 'price':
        final price = deal.price;
        final unit = deal.priceUnit;
        return RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: price > 0
                    ? '\$${price % 1 == 0 ? price.toStringAsFixed(0) : price.toStringAsFixed(2)}'
                    : 'Check',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.deepNavy,
                ),
              ),
              TextSpan(
                text: unit,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.slate600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );

      case 'rating':
        return Row(
          children: [
            ...List.generate(5, (i) {
              final filled = i < deal.rating.round();
              return Icon(
                filled ? Icons.star : Icons.star_border,
                color: filled ? Colors.amber : Colors.grey.shade300,
                size: 14,
              );
            }),
            const SizedBox(width: 4),
            Text(
              deal.rating.toStringAsFixed(1),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppTheme.deepNavy,
              ),
            ),
          ],
        );

      case 'spec':
      default:
        final val = deal.specs[key] ?? deal.details[key];
        if (val == null || val == '—' || val.isEmpty) {
          return const Text('—',
              style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold));
        }
        return Text(
          val,
          style: const TextStyle(
            fontSize: 13,
            color: AppTheme.deepNavy,
            fontWeight: FontWeight.w500,
          ),
        );
    }
  }

  Widget _buildActionRow(List<Deal> deals, Deal? bestDeal) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppTheme.deepNavy,
        borderRadius:
            BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 200,
            child: Text(
              'READY TO SWITCH?',
              style: TextStyle(
                color: Colors.white60,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
          ),
          ...deals.map((deal) {
            final isBest = deal == bestDeal;
            final url = deal.affiliateUrl.isNotEmpty
                ? deal.affiliateUrl
                : deal.directUrl;
            return Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton.icon(
                      onPressed: url.isNotEmpty
                          ? () => _launchUrl(url, deal.id)
                          : null,
                      icon: const Icon(Icons.open_in_new, size: 14),
                      label: const Text(
                        'GO TO SITE',
                        style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                            letterSpacing: 0.8),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isBest
                            ? AppTheme.vibrantEmerald
                            : AppTheme.accentOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                        elevation: 0,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextButton(
                      onPressed: () {
                        final slug = deal.providerName
                            .toLowerCase()
                            .replaceAll(' ', '-')
                            .replaceAll('(', '')
                            .replaceAll(')', '');
                        context.push('/provider/$slug');
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white54,
                        padding: const EdgeInsets.symmetric(vertical: 4),
                      ),
                      child: const Text(
                        'View provider details',
                        style: TextStyle(fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────

  Deal? _bestValueDeal(List<Deal> deals) {
    if (deals.isEmpty) return null;
    return deals.reduce(
        (curr, next) => curr.valueScore > next.valueScore ? curr : next);
  }

  bool _hasDifference(List<Deal> deals, Map<String, dynamic> rowDef) {
    final key = rowDef['key'] as String;
    final type = rowDef['type'] as String;
    if (deals.length <= 1) return false;

    if (type == 'bool') {
      final vals = deals.map((d) => d.boolFeatures[key]).toSet();
      return vals.length > 1;
    } else if (type == 'price') {
      final vals = deals.map((d) => d.price).toSet();
      return vals.length > 1;
    } else if (type == 'rating') {
      final vals = deals.map((d) => d.rating).toSet();
      return vals.length > 1;
    } else {
      final vals =
          deals.map((d) => d.specs[key] ?? d.details[key] ?? '').toSet();
      return vals.length > 1;
    }
  }

  String _priceLabel(Deal deal) {
    if (deal.price <= 0) return 'Check price';
    final p = deal.price % 1 == 0
        ? deal.price.toStringAsFixed(0)
        : deal.price.toStringAsFixed(2);
    return '\$$p${deal.priceUnit}';
  }

  String _categoryLabel(String slug) {
    const labels = {
      'electricity': 'Electricity',
      'gas': 'Gas',
      'mobile': 'Mobile',
      'internet': 'Internet',
      'insurance': 'Insurance',
      'solar': 'Solar',
      'creditCards': 'Credit Card',
    };
    return labels[slug] ?? slug;
  }

  Future<void> _launchUrl(String rawUrl, String dealId) async {
    final separator = rawUrl.contains('?') ? '&' : '?';
    final tracked = '$rawUrl${separator}clickRef=compare_${DateTime.now().millisecondsSinceEpoch}';
    final uri = Uri.parse(tracked);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
