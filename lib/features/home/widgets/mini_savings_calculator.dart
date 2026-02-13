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
      borderRadius: 20,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Quick Savings Estimate',
            style: TextStyle(
              color: AppTheme.deepNavy,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
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
          _miniSlider(
            context,
            label: 'Mobile',
            icon: Icons.phone_iphone,
            value: utilityCosts.mobile,
            max: 150,
            onChanged: (val) => controller.updateCost(UtilityType.mobile, val),
          ),
          _miniSlider(
            context,
            label: 'Home Ins.',
            icon: Icons.home,
            value: utilityCosts.homeInsurance,
            max: 500,
            onChanged: (val) => controller.updateCost(UtilityType.homeInsurance, val),
          ),
          _miniSlider(
            context,
            label: 'Car Ins.',
            icon: Icons.directions_car,
            value: utilityCosts.carInsurance,
            max: 400,
            onChanged: (val) => controller.updateCost(UtilityType.carInsurance, val),
          ),

          const Divider(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Savings:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: AppTheme.deepNavy,
                ),
              ),
              AnimatedCounter(
                value: totalSavings,
                prefix: '\$',
                style: const TextStyle(
                  color: AppTheme.vibrantEmerald,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton(
              onPressed: () => context.push('/register'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                backgroundColor: AppTheme.accentOrange,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('START SAVING', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, size: 12, color: AppTheme.primaryBlue),
                  const SizedBox(width: 4),
                  Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                ],
              ),
              Text('\$${value.toInt()}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.vibrantEmerald)),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
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
        ],
      ),
    );
  }
}