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
                        flex: 2,
                        child: Center(
                          child: GlassContainer(
                            width: 280,
                            height: 160,
                            borderRadius: 100,
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Annual Savings',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: AppTheme.deepNavy.withOpacity(0.7),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                AnimatedCounter(
                                  value: totalSavings,
                                  prefix: '\$',
                                  style: const TextStyle(
                                    color: AppTheme.vibrantEmerald,
                                    fontSize: 42,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (totalSavings > 0) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    _getSavingsEquivalent(totalSavings),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: AppTheme.deepNavy.withOpacity(0.6),
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic,
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
                        flex: 4,
                        child: ListView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                          children: [
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 24.0),
                                child: Text(
                                  "Adjust your monthly spend:",
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
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: PulsingButton(
              label: 'SWITCH & SAVE',
              onPressed: () => context.go('/register'),
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
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: AppTheme.deepNavy),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.vibrantEmerald.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '\$${value.toInt()}',
                    style: const TextStyle(
                      color: AppTheme.vibrantEmerald,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppTheme.vibrantEmerald,
              inactiveTrackColor: Colors.grey.withOpacity(0.2),
              thumbColor: Colors.white,
              overlayColor: AppTheme.vibrantEmerald.withOpacity(0.1),
              trackHeight: 6.0,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12.0, elevation: 4),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 24.0),
            ),
            child: Slider(
              value: value,
              min: 0,
              max: max,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  String _getSavingsEquivalent(double savings) {
    if (savings <= 0) return 'Start sliding to see savings!';
    if (savings < 300) return 'That\'s a nice dinner out!';
    if (savings < 600) return 'That\'s a years worth of coffee!';
    if (savings < 1000) return 'That\'s a weekend getaway!';
    if (savings < 2000) return 'That\'s a new smartphone!';
    return 'That\'s a dream holiday!';
  }

  Widget _buildBoostCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.glassBorder),
          boxShadow: [
            BoxShadow(
              color: AppTheme.deepNavy.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.vibrantEmerald.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppTheme.vibrantEmerald),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppTheme.deepNavy,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.deepNavy.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppTheme.deepNavy.withOpacity(0.3),
            ),
          ],
        ),
      ),
    );
  }
}