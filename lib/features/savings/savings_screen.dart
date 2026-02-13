import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_container.dart';
import 'savings_provider.dart';
import 'widgets/animated_counter.dart';
import 'widgets/pulsing_button.dart';

import '../../widgets/main_navigation_bar.dart';
import '../../widgets/main_mobile_drawer.dart';

class SavingsScreen extends ConsumerWidget {
  const SavingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalSavings = ref.watch(totalAnnualSavingsProvider);
    final utilityCosts = ref.watch(savingsControllerProvider);
    final controller = ref.read(savingsControllerProvider.notifier);

    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      endDrawer: const MainMobileDrawer(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.mainBackgroundGradient,
        ),
        child: Column(
          children: [
            const MainNavigationBar(),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Column(
                    children: [
                      // 1. Floating Savings Bubble
                      Expanded(
                        flex: 1, // Reduced flex to take less vertical space
                        child: Center(
                          child: GlassContainer(
                            width: 260, // Wider for big numbers
                            height: 150, // Oval shape
                            borderRadius: 100, // Pill shape
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Annual Savings', // Shorter text
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: AppTheme.deepNavy.withOpacity(0.7),
                                    fontSize: 13, // Smaller font
                                  ),
                                ),
                                const SizedBox(height: 4),
                                AnimatedCounter(
                                  value: totalSavings,
                                  prefix: '\$',
                                  style: const TextStyle(
                                    color: AppTheme.vibrantEmerald,
                                    fontSize: 32, // Smaller font
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (totalSavings > 0) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'Great start!',
                                    style: TextStyle(
                                      color: AppTheme.deepNavy.withOpacity(0.5),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),

                      // 2. Sliders List
                      Expanded(
                        flex: 3, // Increased relative space for the list
                        child: ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                            children: [
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 16.0),
                                  child: Text(
                                    "What's your monthly spend?",
                                    style: TextStyle(
                                      color: AppTheme.deepNavy.withOpacity(0.7),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                              _buildUtilitySlider(
                                context,
                                label: 'NBN (Internet)',
                                value: utilityCosts.nbn,
                                max: 200,
                                onChanged: (val) => controller.updateCost(UtilityType.nbn, val),
                              ),
                              _buildUtilitySlider(
                                context,
                                label: 'Electricity',
                                value: utilityCosts.electricity,
                                max: 600,
                                onChanged: (val) => controller.updateCost(UtilityType.electricity, val),
                              ),
                              _buildUtilitySlider(
                                context,
                                label: 'Gas',
                                value: utilityCosts.gas,
                                max: 400,
                                onChanged: (val) => controller.updateCost(UtilityType.gas, val),
                              ),
                              _buildUtilitySlider(
                                context,
                                label: 'Mobile SIM',
                                value: utilityCosts.mobile,
                                max: 150,
                                onChanged: (val) => controller.updateCost(UtilityType.mobile, val),
                              ),
                              _buildUtilitySlider(
                                context,
                                label: 'Home Insurance',
                                value: utilityCosts.homeInsurance,
                                max: 500,
                                onChanged: (val) => controller.updateCost(UtilityType.homeInsurance, val),
                              ),
                              _buildUtilitySlider(
                                context,
                                label: 'Car Insurance',
                                value: utilityCosts.carInsurance,
                                max: 400,
                                onChanged: (val) => controller.updateCost(UtilityType.carInsurance, val),
                              ),
                            const SizedBox(height: 80), // Space for FAB
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: SizedBox(
            width: double.infinity,
            child: PulsingButton(
              label: 'SWITCH & SAVE',
              onPressed: () {
                context.push('/register');
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUtilitySlider(
    BuildContext context, {
    required String label,
    required double value,
    required double max,
    required Function(double) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0), // Reduced from 16
      child: GlassContainer(
        borderRadius: 12,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4), // Reduced vertical from 12 to 4
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14), // Smaller font
                ),
                Text(
                  '\$${value.toInt()}',
                  style: const TextStyle(
                    color: AppTheme.vibrantEmerald,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: AppTheme.vibrantEmerald,
                inactiveTrackColor: AppTheme.deepNavy.withOpacity(0.1),
                thumbColor: AppTheme.accentOrange,
                overlayColor: AppTheme.accentOrange.withOpacity(0.2),
                trackHeight: 4.0, 
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10.0),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 20.0),
                valueIndicatorColor: AppTheme.accentOrange,
                valueIndicatorTextStyle: const TextStyle(color: Colors.white),
              ),
              child: Slider(
                value: value,
                min: 0,
                max: max,
                divisions: max.toInt(),
                label: '\$${value.toInt()}',
                onChanged: onChanged,
              ),
            ),
          ],
        ),
      ),
    );
  }
}