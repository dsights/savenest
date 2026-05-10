import 'package:flutter_riverpod/flutter_riverpod.dart';

class GamificationState {
  final int xp;
  final int viewCount;
  final int compareCount;
  final int switchCount;
  final Set<String> exploredCategories;
  final Set<String> earnedBadges;

  const GamificationState({
    this.xp = 0,
    this.viewCount = 0,
    this.compareCount = 0,
    this.switchCount = 0,
    this.exploredCategories = const {},
    this.earnedBadges = const {},
  });

  int get level {
    if (xp >= 1000) return 5;
    if (xp >= 600) return 4;
    if (xp >= 300) return 3;
    if (xp >= 100) return 2;
    return 1;
  }

  String get levelName {
    switch (level) {
      case 1: return 'Saver Scout';
      case 2: return 'Deal Hunter';
      case 3: return 'Smart Switcher';
      case 4: return 'Savings Pro';
      case 5: return 'Money Master';
      default: return 'Saver Scout';
    }
  }

  int get _levelMin {
    const mins = [0, 0, 100, 300, 600, 1000];
    return mins[level];
  }

  int get _levelMax {
    const maxs = [100, 100, 300, 600, 1000, 9999];
    return maxs[level];
  }

  double get levelProgress {
    if (level == 5) return 1.0;
    return ((xp - _levelMin) / (_levelMax - _levelMin)).clamp(0.0, 1.0);
  }

  GamificationState copyWith({
    int? xp,
    int? viewCount,
    int? compareCount,
    int? switchCount,
    Set<String>? exploredCategories,
    Set<String>? earnedBadges,
  }) =>
      GamificationState(
        xp: xp ?? this.xp,
        viewCount: viewCount ?? this.viewCount,
        compareCount: compareCount ?? this.compareCount,
        switchCount: switchCount ?? this.switchCount,
        exploredCategories: exploredCategories ?? this.exploredCategories,
        earnedBadges: earnedBadges ?? this.earnedBadges,
      );
}

class GamificationNotifier extends StateNotifier<GamificationState> {
  GamificationNotifier() : super(const GamificationState());

  void recordView() {
    final n = state.viewCount + 1;
    final badges = Set<String>.from(state.earnedBadges);
    if (n == 1) badges.add('first_look');
    state = state.copyWith(xp: state.xp + 5, viewCount: n, earnedBadges: badges);
  }

  void recordCompare() {
    final n = state.compareCount + 1;
    final badges = Set<String>.from(state.earnedBadges);
    if (n == 1) badges.add('first_compare');
    state = state.copyWith(xp: state.xp + 10, compareCount: n, earnedBadges: badges);
  }

  void recordSwitch() {
    final n = state.switchCount + 1;
    final badges = Set<String>.from(state.earnedBadges);
    if (n == 1) badges.add('first_switch');
    if (n >= 3) badges.add('triple_saver');
    state = state.copyWith(xp: state.xp + 50, switchCount: n, earnedBadges: badges);
  }

  void recordCategory(String category) {
    final cats = Set<String>.from(state.exploredCategories)..add(category);
    final badges = Set<String>.from(state.earnedBadges);
    if (cats.length >= 3) badges.add('explorer');
    if (cats.length >= 5) badges.add('power_user');
    state = state.copyWith(exploredCategories: cats, earnedBadges: badges);
  }
}

final gamificationProvider =
    StateNotifierProvider<GamificationNotifier, GamificationState>(
  (ref) => GamificationNotifier(),
);
