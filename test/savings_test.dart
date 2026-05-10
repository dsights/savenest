import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:savenest/features/savings/savings_provider.dart';

void main() {
  test('Savings calculation logic is correct', () {
    final container = ProviderContainer();
    final controller = container.read(savingsControllerProvider.notifier);

    // 1. Initial State should be 0 savings
    expect(container.read(totalAnnualSavingsProvider), 0.0);

    // 2. Set NBN Cost: $100 (Market Avg is $90)
    // Savings = (100 - 90) * 12 = $120
    controller.updateCost(UtilityType.nbn, 100.0);
    expect(container.read(totalAnnualSavingsProvider), 120.0);

    // 3. Set Gas Cost: $140 (Market Avg is $120)
    // New Savings = (140 - 120) * 12 = $240
    // Total = 120 + 240 = $360
    controller.updateCost(UtilityType.gas, 140.0);
    expect(container.read(totalAnnualSavingsProvider), 360.0);
  });
}
