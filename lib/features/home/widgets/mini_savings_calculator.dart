import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      borderRadius: 24,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Quick Savings Estimate',
            style: TextStyle(
              color: AppTheme.deepNavy,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'See how much you could save annually.',
            style: TextStyle(
              color: AppTheme.slate600,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 24),
          
          _miniSlider(
            context,
            label: 'Electricity',
            icon: Icons.bolt,
            value: utilityCosts.electricity,
            max: 600,
            onChanged: (val) => controller.updateCost(UtilityType.electricity, val),
          ),
          _miniSlider(
            context,
            label: 'Gas',
            icon: Icons.local_fire_department,
            value: utilityCosts.gas,
            max: 400,
            onChanged: (val) => controller.updateCost(UtilityType.gas, val),
          ),
          _miniSlider(
            context,
            label: 'NBN',
            icon: Icons.wifi,
            value: utilityCosts.nbn,
            max: 200,
            onChanged: (val) => controller.updateCost(UtilityType.nbn, val),
          ),

          const Divider(height: 32),

          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            runSpacing: 8,
            children: [
              const Text(
                'Estimated Savings:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.deepNavy,
                ),
              ),
              AnimatedCounter(
                value: totalSavings,
                prefix: '\$',
                style: const TextStyle(
                  color: AppTheme.vibrantEmerald,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, size: 14, color: AppTheme.primaryBlue),
                  const SizedBox(width: 4),
                  Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
              Text('\$${value.toInt()}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.vibrantEmerald)),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 2,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
              activeTrackColor: AppTheme.primaryBlue,
              thumbColor: AppTheme.deepNavy,
            ),
            child: Slider(
              value: value,
              max: max,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
