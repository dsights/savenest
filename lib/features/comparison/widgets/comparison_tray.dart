import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_theme.dart';
import '../comparison_model.dart';
import '../comparison_provider.dart';

class ComparisonTray extends ConsumerWidget {
  final ProductCategory category;

  const ComparisonTray({super.key, required this.category});

  String _categorySlug(ProductCategory cat) {
    switch (cat) {
      case ProductCategory.electricity: return 'electricity';
      case ProductCategory.gas:         return 'gas';
      case ProductCategory.mobile:      return 'mobile';
      case ProductCategory.internet:    return 'internet';
      case ProductCategory.insurance:   return 'insurance';
      case ProductCategory.solar:       return 'solar';
      case ProductCategory.creditCards: return 'creditCards';
      default:                          return 'electricity';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(comparisonProvider);
    final controller = ref.read(comparisonProvider.notifier);
    final selected = state.selectedDeals;
    final count = selected.length;

    return AnimatedSlide(
      offset: count == 0 ? const Offset(0, 1) : Offset.zero,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        opacity: count == 0 ? 0 : 1,
        duration: const Duration(milliseconds: 250),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppTheme.deepNavy,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Row(
                children: [
                  // Label
                  Text(
                    'Comparing $count of 3',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Product slots
                  Expanded(
                    child: Row(
                      children: List.generate(3, (i) {
                        final deal = i < selected.length ? selected[i] : null;
                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: _TraySlot(
                            deal: deal,
                            onRemove: deal != null
                                ? () => controller.toggleComparison(deal.id)
                                : null,
                          ),
                        );
                      }),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Clear
                  TextButton(
                    onPressed: controller.clearComparison,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white54,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    child: const Text('Clear', style: TextStyle(fontSize: 13)),
                  ),

                  const SizedBox(width: 8),

                  // Compare Now CTA
                  AnimatedOpacity(
                    opacity: count >= 2 ? 1.0 : 0.4,
                    duration: const Duration(milliseconds: 200),
                    child: ElevatedButton.icon(
                      onPressed: count >= 2
                          ? () {
                              final ids = selected.map((d) => d.id).join(',');
                              final cat = _categorySlug(category);
                              context.push('/compare-deals?ids=$ids&cat=$cat');
                            }
                          : null,
                      icon: const Icon(Icons.compare_arrows, size: 16),
                      label: Text(
                        count >= 2 ? 'Compare Now' : 'Select 2+',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentOrange,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: AppTheme.accentOrange.withOpacity(0.5),
                        disabledForegroundColor: Colors.white70,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TraySlot extends StatelessWidget {
  final Deal? deal;
  final VoidCallback? onRemove;

  const _TraySlot({this.deal, this.onRemove});

  @override
  Widget build(BuildContext context) {
    if (deal == null) {
      return Container(
        width: 140,
        height: 40,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white24, width: 1.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text(
            '+ Add product',
            style: TextStyle(color: Colors.white38, fontSize: 11),
          ),
        ),
      );
    }

    final d = deal!;
    return Container(
      width: 140,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: d.providerColor.withOpacity(0.6), width: 1.5),
      ),
      child: Row(
        children: [
          const SizedBox(width: 8),
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: d.providerColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  d.providerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  d.planName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white60, fontSize: 9),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onRemove,
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: Icon(Icons.close, color: Colors.white54, size: 12),
            ),
          ),
        ],
      ),
    );
  }
}
