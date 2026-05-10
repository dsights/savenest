import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/glass_container.dart';
import '../../savings/savings_provider.dart';
import '../../savings/widgets/animated_counter.dart';

class MiniSavingsCalculator extends ConsumerWidget {
  const MiniSavingsCalculator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalSavings = ref.watch(totalAnnualSavingsProvider);
    final utilityCosts = ref.watch(savingsControllerProvider);
    final controller = ref.read(savingsControllerProvider.notifier);

    return GlassContainer(
      borderRadius: 12,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Savings Estimate',
            style: TextStyle(
              color: AppTheme.deepNavy,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          
          // Scenarios
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _scenarioChip(
                  label: 'Light',
                  onTap: () {
                    controller.updateCost(UtilityType.electricity, 80);
                    controller.updateCost(UtilityType.gas, 50);
                    controller.updateCost(UtilityType.nbn, 60);
                    controller.updateCost(UtilityType.mobile, 20);
                  },
                ),
                const SizedBox(width: 6),
                _scenarioChip(
                  label: 'Average',
                  onTap: () {
                    controller.updateCost(UtilityType.electricity, 150);
                    controller.updateCost(UtilityType.gas, 120);
                    controller.updateCost(UtilityType.nbn, 90);
                    controller.updateCost(UtilityType.mobile, 40);
                  },
                ),
                const SizedBox(width: 6),
                _scenarioChip(
                  label: 'Heavy',
                  onTap: () {
                    controller.updateCost(UtilityType.electricity, 300);
                    controller.updateCost(UtilityType.gas, 200);
                    controller.updateCost(UtilityType.nbn, 120);
                    controller.updateCost(UtilityType.mobile, 80);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          
          _miniSlider(
            context,
            label: 'Electricity',
            icon: Icons.bolt,
            value: utilityCosts.electricity,
            max: 1000,
            onChanged: (val) => controller.updateCost(UtilityType.electricity, val),
          ),
          _miniSlider(
            context,
            label: 'Gas',
            icon: Icons.local_fire_department,
            value: utilityCosts.gas,
            max: 600,
            onChanged: (val) => controller.updateCost(UtilityType.gas, val),
          ),
          _miniSlider(
            context,
            label: 'Internet (NBN)',
            icon: Icons.wifi,
            value: utilityCosts.nbn,
            max: 300,
            onChanged: (val) => controller.updateCost(UtilityType.nbn, val),
          ),
          _miniSlider(
            context,
            label: 'Mobile',
            icon: Icons.phone_iphone,
            value: utilityCosts.mobile,
            max: 200,
            onChanged: (val) => controller.updateCost(UtilityType.mobile, val),
          ),

          const Divider(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Est. Savings:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: AppTheme.deepNavy,
                ),
              ),
              AnimatedCounter(
                value: totalSavings,
                prefix: '\$',
                style: const TextStyle(
                  color: AppTheme.vibrantEmerald,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 36,
            child: ElevatedButton(
              onPressed: () => context.push('/register'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                backgroundColor: AppTheme.accentOrange,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              child: const Text('START SAVING', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniSlider(
    BuildContext context, {
    required String label,
    required IconData icon,
    required double value,
    required double max,
    required Function(double) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, size: 11, color: AppTheme.primaryBlue),
                const SizedBox(width: 4),
                Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
              ],
            ),
            Text('\$${value.toInt()}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.vibrantEmerald)),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 2.0,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 4),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 8),
            activeTrackColor: AppTheme.vibrantEmerald,
            inactiveTrackColor: AppTheme.deepNavy.withOpacity(0.1),
            thumbColor: AppTheme.accentOrange,
          ),
          child: Slider(
            value: value,
            max: max,
            onChanged: onChanged,
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  Widget _scenarioChip({required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppTheme.primaryBlue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.3)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryBlue,
          ),
        ),
      ),
    );
  }
}