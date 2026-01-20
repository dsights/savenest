import 'package:flutter_riverpod/flutter_riverpod.dart';

// 1. Utility Types
enum UtilityType {
  nbn,
  electricity,
  gas,
  mobile,
  homeInsurance,
  carInsurance,
}

// 2. Market Average Constants (Monthly)
class MarketAverages {
  static const double nbn = 90.0;
  static const double electricity = 150.0; // Estimated
  static const double gas = 120.0;
  static const double mobile = 40.0; // Estimated
  static const double homeInsurance = 100.0; // Estimated
  static const double carInsurance = 80.0; // Estimated
}

// 3. State Model
class UtilityCosts {
  final double nbn;
  final double electricity;
  final double gas;
  final double mobile;
  final double homeInsurance;
  final double carInsurance;

  const UtilityCosts({
    this.nbn = 0.0,
    this.electricity = 0.0,
    this.gas = 0.0,
    this.mobile = 0.0,
    this.homeInsurance = 0.0,
    this.carInsurance = 0.0,
  });

  UtilityCosts copyWith({
    double? nbn,
    double? electricity,
    double? gas,
    double? mobile,
    double? homeInsurance,
    double? carInsurance,
  }) {
    return UtilityCosts(
      nbn: nbn ?? this.nbn,
      electricity: electricity ?? this.electricity,
      gas: gas ?? this.gas,
      mobile: mobile ?? this.mobile,
      homeInsurance: homeInsurance ?? this.homeInsurance,
      carInsurance: carInsurance ?? this.carInsurance,
    );
  }
  
  double getCost(UtilityType type) {
    switch (type) {
      case UtilityType.nbn: return nbn;
      case UtilityType.electricity: return electricity;
      case UtilityType.gas: return gas;
      case UtilityType.mobile: return mobile;
      case UtilityType.homeInsurance: return homeInsurance;
      case UtilityType.carInsurance: return carInsurance;
    }
  }
}

// 4. Controller (StateNotifier)
class SavingsController extends StateNotifier<UtilityCosts> {
  SavingsController() : super(const UtilityCosts());

  void updateCost(UtilityType type, double amount) {
    switch (type) {
      case UtilityType.nbn:
        state = state.copyWith(nbn: amount);
        break;
      case UtilityType.electricity:
        state = state.copyWith(electricity: amount);
        break;
      case UtilityType.gas:
        state = state.copyWith(gas: amount);
        break;
      case UtilityType.mobile:
        state = state.copyWith(mobile: amount);
        break;
      case UtilityType.homeInsurance:
        state = state.copyWith(homeInsurance: amount);
        break;
      case UtilityType.carInsurance:
        state = state.copyWith(carInsurance: amount);
        break;
    }
  }
}

// 5. Providers
final savingsControllerProvider = StateNotifierProvider<SavingsController, UtilityCosts>((ref) {
  return SavingsController();
});

final totalAnnualSavingsProvider = Provider<double>((ref) {
  final costs = ref.watch(savingsControllerProvider);
  
  double calculateSavings(double current, double average) {
    // If current spend is 0 (not entered), assume no savings to avoid skewing data
    // Or we could calculate it anyway. Let's calculate only if > 0.
    if (current == 0) return 0.0;
    
    // Logic: (Current Spend - Market Average) * 12
    // If negative, it means they are already saving compared to market, 
    // but the prompt implies this formula specifically. 
    // If result is negative, it technically means "Loss" or "Already Efficient".
    // We will sum pure values.
    return (current - average) * 12;
  }

  double total = 0.0;
  
  total += calculateSavings(costs.nbn, MarketAverages.nbn);
  total += calculateSavings(costs.electricity, MarketAverages.electricity);
  total += calculateSavings(costs.gas, MarketAverages.gas);
  total += calculateSavings(costs.mobile, MarketAverages.mobile);
  total += calculateSavings(costs.homeInsurance, MarketAverages.homeInsurance);
  total += calculateSavings(costs.carInsurance, MarketAverages.carInsurance);

  return total;
});
