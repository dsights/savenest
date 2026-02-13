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
      borderRadius: 16,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Savings Estimate',
            style: TextStyle(
              color: AppTheme.deepNavy,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
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

          const Divider(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Estimated Savings:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
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
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: () => context.push('/register'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                backgroundColor: AppTheme.accentOrange,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('START SAVING TODAY', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
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
                Icon(icon, size: 14, color: AppTheme.primaryBlue),
                const SizedBox(width: 6),
                Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              ],
            ),
            Text('\$${value.toInt()}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.vibrantEmerald)),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4.0,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
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
        const SizedBox(height: 8),
      ],
    );
  }
}