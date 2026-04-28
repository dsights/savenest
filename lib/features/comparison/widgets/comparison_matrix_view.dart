import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../comparison_model.dart';
import 'package:url_launcher/url_launcher.dart';

class ComparisonMatrixView extends StatelessWidget {
  final List<Deal> deals;

  const ComparisonMatrixView({super.key, required this.deals});

  @override
  Widget build(BuildContext context) {
    if (deals.isEmpty) {
      return const Center(child: Text('No deals to compare'));
    }

    final topDeals = deals.take(6).toList();
    final bestDeal = topDeals.isEmpty
        ? null
        : topDeals.reduce(
            (c, n) => c.valueScore > n.valueScore ? c : n);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: MediaQuery.of(context).size.width - 48,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header row
              Container(
                color: AppTheme.deepNavy,
                child: Row(
                  children: [
                    _headerCell('Plan', isLabel: true),
                    ...topDeals.map((d) => Expanded(
                          child: _headerCell(
                            d.providerName,
                            isBest: d == bestDeal,
                            subtext: d.planName,
                          ),
                        )),
                  ],
                ),
              ),

              // Price row
              _row(
                context,
                label: 'Price',
                cells: topDeals.map((d) {
                  final p = d.price > 0
                      ? '\$${d.price % 1 == 0 ? d.price.toStringAsFixed(0) : d.price.toStringAsFixed(2)}${d.priceUnit}'
                      : 'Check';
                  return _priceCell(p, isHighlight: d == bestDeal);
                }).toList(),
                isEven: true,
              ),

              // Rating row
              _row(
                context,
                label: 'Rating',
                cells: topDeals
                    .map((d) => _starsCell(d.rating))
                    .toList(),
                isEven: false,
              ),

              // Bool feature rows
              ..._boolRows(context, topDeals),

              // Action row
              Container(
                color: const Color(0xFFF4F6FA),
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    SizedBox(
                      width: 160,
                      child: Center(
                        child: Text(
                          'SWITCH NOW',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.deepNavy.withOpacity(0.5),
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ),
                    ...topDeals.map((d) => Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8),
                            child: ElevatedButton(
                              onPressed: () => _launch(d),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: d == bestDeal
                                    ? AppTheme.vibrantEmerald
                                    : AppTheme.accentOrange,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10),
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(100)),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Go to Site',
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800),
                              ),
                            ),
                          ),
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Row builders ──────────────────────────────────────────────────

  List<Widget> _boolRows(BuildContext context, List<Deal> deals) {
    // Collect all bool feature keys present across deals
    final keys = <String>{};
    for (final d in deals) {
      keys.addAll(d.boolFeatures.keys);
    }

    // Labels for common keys
    const labelMap = {
      'no_lock_in':            'No Lock-in',
      'green_power':           'Green Power',
      'solar_compatible':      'Solar Compatible',
      'unlimited_data':        'Unlimited Data',
      'five_g':                '5G Access',
      'unlimited_calls':       'Unlimited Calls',
      'comprehensive':         'Comprehensive',
      'roadside_assist':       'Roadside Assist',
      'battery_available':     'Battery Available',
      'pay_on_time_discount':  'Pay-on-Time Discount',
      'australian_support':    'AU Support',
    };

    // Show only keys that have a label and vary across deals
    final rows = <Widget>[];
    bool isEven = true;
    int count = 0;
    for (final key in labelMap.keys) {
      if (!keys.contains(key)) continue;
      if (count >= 6) break;
      rows.add(_row(
        context,
        label: labelMap[key]!,
        cells: deals.map((d) {
          final val = d.boolFeatures[key];
          return _boolCell(val);
        }).toList(),
        isEven: isEven,
      ));
      isEven = !isEven;
      count++;
    }
    return rows;
  }

  Widget _row(BuildContext context,
      {required String label,
      required List<Widget> cells,
      required bool isEven}) {
    return Container(
      color: isEven ? Colors.white : const Color(0xFFFAFBFC),
      child: Row(
        children: [
          SizedBox(
            width: 160,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.deepNavy,
                ),
              ),
            ),
          ),
          ...cells.map((c) => Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 12),
                  decoration: const BoxDecoration(
                    border: Border(
                      left: BorderSide(color: Color(0xFFEEEFF2)),
                    ),
                  ),
                  child: c,
                ),
              )),
        ],
      ),
    );
  }

  // ── Cell builders ─────────────────────────────────────────────────

  Widget _headerCell(String text,
      {bool isLabel = false, bool isBest = false, String? subtext}) {
    if (isLabel) {
      return SizedBox(
        width: 160,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        border: const Border(
            left: BorderSide(color: Colors.white12)),
        color: isBest ? AppTheme.vibrantEmerald.withOpacity(0.15) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (isBest)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.vibrantEmerald,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'BEST',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
            ],
          ),
          if (subtext != null) ...[
            const SizedBox(height: 2),
            Text(
              subtext,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 10,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _priceCell(String text, {bool isHighlight = false}) => Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w900,
          color: isHighlight ? AppTheme.vibrantEmerald : AppTheme.deepNavy,
        ),
      );

  Widget _starsCell(double rating) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...List.generate(
            5,
            (i) => Icon(
              i < rating.round() ? Icons.star : Icons.star_border,
              color: i < rating.round() ? Colors.amber : Colors.grey.shade300,
              size: 12,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
          ),
        ],
      );

  Widget _boolCell(bool? val) {
    if (val == null) {
      return const Text('—',
          style: TextStyle(
              fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold));
    }
    return Container(
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
        size: 13,
      ),
    );
  }

  Future<void> _launch(Deal deal) async {
    final url = deal.affiliateUrl.isNotEmpty ? deal.affiliateUrl : deal.directUrl;
    if (url.isEmpty) return;
    final sep = url.contains('?') ? '&' : '?';
    final uri = Uri.parse('$url${sep}clickRef=matrix_${DateTime.now().millisecondsSinceEpoch}');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }
}
