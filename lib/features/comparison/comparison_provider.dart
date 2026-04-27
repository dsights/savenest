import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'comparison_model.dart';
import 'data/product_repository.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return JsonProductRepository();
});

class ComparisonState {
  final List<Deal> deals;
  final bool isLoading;
  final ProductCategory? selectedCategory;
  final String searchQuery;
  final String? selectedState;
  final Deal? bestValueDeal;
  final Set<String> activeFilters;
  final double? filterPriceMax;
  final SortMode sortMode;
  final String dataLastUpdated;
  final double categoryMaxPrice;
  final Set<String> allProviderNames;

  const ComparisonState({
    required this.deals,
    this.isLoading = false,
    this.selectedCategory,
    this.searchQuery = '',
    this.selectedState,
    this.bestValueDeal,
    this.activeFilters = const {},
    this.filterPriceMax,
    this.sortMode = SortMode.defaultSort,
    this.dataLastUpdated = '',
    this.categoryMaxPrice = 0,
    this.allProviderNames = const {},
  });

  ComparisonState copyWith({
    List<Deal>? deals,
    bool? isLoading,
    ProductCategory? selectedCategory,
    String? searchQuery,
    String? selectedState,
    bool clearSelectedState = false,
    Deal? bestValueDeal,
    bool clearBestValueDeal = false,
    Set<String>? activeFilters,
    double? filterPriceMax,
    bool clearFilterPriceMax = false,
    SortMode? sortMode,
    String? dataLastUpdated,
    double? categoryMaxPrice,
    Set<String>? allProviderNames,
  }) {
    return ComparisonState(
      deals: deals ?? this.deals,
      isLoading: isLoading ?? this.isLoading,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedState: clearSelectedState ? null : (selectedState ?? this.selectedState),
      bestValueDeal: clearBestValueDeal ? null : (bestValueDeal ?? this.bestValueDeal),
      activeFilters: activeFilters ?? this.activeFilters,
      filterPriceMax: clearFilterPriceMax ? null : (filterPriceMax ?? this.filterPriceMax),
      sortMode: sortMode ?? this.sortMode,
      dataLastUpdated: dataLastUpdated ?? this.dataLastUpdated,
      categoryMaxPrice: categoryMaxPrice ?? this.categoryMaxPrice,
      allProviderNames: allProviderNames ?? this.allProviderNames,
    );
  }
}

class ComparisonController extends StateNotifier<ComparisonState> {
  final ProductRepository _repository;
  List<Deal> _allDeals = [];

  // Memoization
  String? _lastQuery;
  String? _lastStateFilter;
  String? _lastFilterKey;
  double? _lastFilterPriceMax;
  SortMode? _lastSortMode;
  List<Deal>? _lastResult;

  ComparisonController(this._repository)
      : super(const ComparisonState(deals: []));

  Future<void> loadCategory(ProductCategory category) async {
    if (state.selectedCategory == category && state.deals.isNotEmpty && !state.isLoading) return;

    state = state.copyWith(isLoading: true, selectedCategory: category);

    try {
      final results = await Future.wait([
        _repository.getDeals(category),
        _repository.getMetadata(),
      ]);

      final allDeals = results[0] as List<Deal>;
      final metadata = results[1] as Map<String, dynamic>?;
      final deals = allDeals.where((d) => d.isEnabled).toList();

      _defaultSort(deals);
      _allDeals = deals;
      _invalidateMemo();

      final maxPrice = deals.isEmpty
          ? 0.0
          : deals.map((d) => d.price).reduce((a, b) => a > b ? a : b);

      state = state.copyWith(
        deals: deals,
        isLoading: false,
        bestValueDeal: _calculateBestValue(deals),
        searchQuery: '',
        activeFilters: {},
        clearFilterPriceMax: true,
        sortMode: SortMode.defaultSort,
        dataLastUpdated: metadata?['lastUpdated']?.toString() ?? '',
        categoryMaxPrice: maxPrice,
        allProviderNames: deals.map((d) => d.providerName).toSet(),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, deals: []);
    }
  }

  void updateStateFilter(String? stateCode) {
    state = state.copyWith(
      selectedState: stateCode,
      clearSelectedState: stateCode == null,
    );
    _invalidateMemo();
    search(state.searchQuery);
  }

  void toggleFilter(String value) {
    final newFilters = Set<String>.from(state.activeFilters);
    if (newFilters.contains(value)) {
      newFilters.remove(value);
    } else {
      newFilters.add(value);
    }
    state = state.copyWith(activeFilters: newFilters);
    _invalidateMemo();
    search(state.searchQuery);
  }

  void clearAllFilters() {
    state = state.copyWith(
      activeFilters: {},
      clearFilterPriceMax: true,
      sortMode: SortMode.defaultSort,
    );
    _invalidateMemo();
    search(state.searchQuery);
  }

  void setPriceMax(double? max) {
    if (max == null) {
      state = state.copyWith(clearFilterPriceMax: true);
    } else {
      state = state.copyWith(filterPriceMax: max);
    }
    _invalidateMemo();
    search(state.searchQuery);
  }

  void setSortMode(SortMode mode) {
    state = state.copyWith(sortMode: mode);
    _invalidateMemo();
    search(state.searchQuery);
  }

  void search(String query) {
    final lowerQuery = query.trim().toLowerCase();
    final filterKey = _setKey(state.activeFilters);

    // Memoization: skip if nothing changed
    if (lowerQuery == _lastQuery &&
        state.selectedState == _lastStateFilter &&
        filterKey == _lastFilterKey &&
        state.filterPriceMax == _lastFilterPriceMax &&
        state.sortMode == _lastSortMode &&
        _lastResult != null) {
      return;
    }

    // ── State detection from query text ───────────────────────────
    const stateAbbrs = ['nsw', 'vic', 'qld', 'sa', 'wa', 'act', 'tas', 'nt'];
    String? queryState;
    for (final s in stateAbbrs) {
      if (lowerQuery.contains(RegExp(r'\b' + s + r'\b'))) {
        queryState = s.toUpperCase();
        break;
      }
    }
    final activeStateFilter = state.selectedState ?? queryState;

    // ── Negation-aware intent detection ───────────────────────────
    final tokens = lowerQuery.split(RegExp(r'\s+'));
    bool sortPriceAsc = false;
    bool sortRatingDesc = false;
    bool filterGreen = false;
    bool intentUnlimited = false;

    const priceWords = {'cheap', 'lowest', 'budget', 'price', 'saver'};
    const ratingWords = {'best', 'top', 'rating', 'premium', 'quality'};
    const greenWords = {'green', 'solar', 'eco', 'renewable'};
    const unlimitedWords = {'unlimited', 'infinite'};

    for (int i = 0; i < tokens.length; i++) {
      final tok = tokens[i];
      final negated = i > 0 && (tokens[i - 1] == 'not' || tokens[i - 1] == 'no');
      if (!negated) {
        if (priceWords.contains(tok)) sortPriceAsc = true;
        if (ratingWords.contains(tok)) sortRatingDesc = true;
        if (greenWords.contains(tok)) filterGreen = true;
        if (unlimitedWords.contains(tok)) intentUnlimited = true;
      }
    }

    // ── Clean query: strip intents + stopwords ─────────────────────
    final intentWords = {
      ...priceWords, ...ratingWords, ...greenWords, ...unlimitedWords, ...stateAbbrs,
    };
    const stopWords = {
      'i', 'want', 'need', 'show', 'me', 'find', 'get', 'the', 'a', 'an',
      'for', 'with', 'in', 'of', 'and', 'plan', 'plans', 'deal', 'deals',
    };
    var cleanQuery = lowerQuery;
    for (final word in {...intentWords, ...stopWords}) {
      cleanQuery = cleanQuery.replaceAll(RegExp(r'\b' + RegExp.escape(word) + r'\b'), '');
    }
    cleanQuery = cleanQuery.replaceAll(RegExp(r'\s+'), ' ').trim();

    // ── Filter ────────────────────────────────────────────────────
    final filtered = _allDeals.where((deal) {
      if (!deal.isEnabled) return false;

      // 1. State
      if (activeStateFilter != null &&
          deal.applicableStates.isNotEmpty &&
          !deal.applicableStates.contains(activeStateFilter)) {
        return false;
      }

      // 2. Structured filter chips
      for (final f in state.activeFilters) {
        if (!_matchesStructuredFilter(deal, f)) return false;
      }

      // 3. Price ceiling
      if (state.filterPriceMax != null && deal.price > state.filterPriceMax!) {
        return false;
      }

      // 4. Green / unlimited intent from text
      if (filterGreen && !deal.isGreen) return false;
      if (intentUnlimited) {
        final hasUnlimited = deal.description.toLowerCase().contains('unlimited') ||
            deal.planName.toLowerCase().contains('unlimited') ||
            deal.keyFeatures.any((f) => f.toLowerCase().contains('unlimited'));
        if (!hasUnlimited) return false;
      }

      // 5. Text match (exact substring, then fuzzy fallback on provider/plan)
      if (cleanQuery.isEmpty) return true;

      if (deal.providerName.toLowerCase().contains(cleanQuery)) return true;
      if (deal.planName.toLowerCase().contains(cleanQuery)) return true;
      if (deal.description.toLowerCase().contains(cleanQuery)) return true;
      if (deal.keyFeatures.any((f) => f.toLowerCase().contains(cleanQuery))) return true;
      if (deal.details.values.any((v) => v.toLowerCase().contains(cleanQuery))) return true;

      if (cleanQuery.length >= 4) {
        if (_fuzzyMatch(deal.providerName.toLowerCase(), cleanQuery)) return true;
        if (_fuzzyMatch(deal.planName.toLowerCase(), cleanQuery)) return true;
      }

      return false;
    }).toList();

    // ── Sort ──────────────────────────────────────────────────────
    // Explicit sortMode overrides text-inferred sort
    final effectiveSort = (state.sortMode != SortMode.defaultSort)
        ? state.sortMode
        : sortPriceAsc
            ? SortMode.priceAsc
            : sortRatingDesc
                ? SortMode.ratingDesc
                : SortMode.defaultSort;

    switch (effectiveSort) {
      case SortMode.priceAsc:
        filtered.sort((a, b) => a.price.compareTo(b.price));
        break;
      case SortMode.priceDesc:
        filtered.sort((a, b) => b.price.compareTo(a.price));
        break;
      case SortMode.ratingDesc:
        filtered.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case SortMode.defaultSort:
        _defaultSort(filtered);
        break;
    }

    // Commit memoization keys
    _lastQuery = lowerQuery;
    _lastStateFilter = state.selectedState;
    _lastFilterKey = filterKey;
    _lastFilterPriceMax = state.filterPriceMax;
    _lastSortMode = state.sortMode;
    _lastResult = filtered;

    state = state.copyWith(
      deals: filtered,
      searchQuery: query,
      bestValueDeal: _calculateBestValue(filtered),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────

  void _defaultSort(List<Deal> deals) {
    deals.sort((a, b) {
      if (a.isSponsored && !b.isSponsored) return -1;
      if (!a.isSponsored && b.isSponsored) return 1;
      return a.price.compareTo(b.price);
    });
  }

  static Deal? _calculateBestValue(List<Deal> deals) {
    if (deals.isEmpty) return null;
    return deals.reduce((curr, next) => curr.valueScore > next.valueScore ? curr : next);
  }

  bool _matchesStructuredFilter(Deal deal, String filterValue) {
    final lv = filterValue.toLowerCase();

    // Green-energy special cases
    if (lv == '100%' || lv.contains('green') || lv.contains('eco') || lv.contains('renewable')) {
      return deal.isGreen;
    }

    return deal.planName.toLowerCase().contains(lv) ||
        deal.description.toLowerCase().contains(lv) ||
        deal.keyFeatures.any((f) => f.toLowerCase().contains(lv)) ||
        deal.details.values.any((v) => v.toLowerCase().contains(lv));
  }

  bool _fuzzyMatch(String text, String query) {
    for (final word in text.split(RegExp(r'\s+'))) {
      if (word.length >= 3 && _levenshtein(word, query) <= 2) return true;
    }
    return false;
  }

  int _levenshtein(String a, String b) {
    if (a == b) return 0;
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;
    var prev = List<int>.generate(b.length + 1, (i) => i);
    var curr = List<int>.filled(b.length + 1, 0);
    for (var i = 1; i <= a.length; i++) {
      curr[0] = i;
      for (var j = 1; j <= b.length; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        curr[j] = min(min(prev[j] + 1, curr[j - 1] + 1), prev[j - 1] + cost);
      }
      final tmp = prev;
      prev = curr;
      curr = tmp;
    }
    return prev[b.length];
  }

  String _setKey(Set<String> s) => (s.toList()..sort()).join(',');

  void _invalidateMemo() {
    _lastResult = null;
  }
}

final comparisonProvider =
    StateNotifierProvider<ComparisonController, ComparisonState>((ref) {
  final repo = ref.watch(productRepositoryProvider);
  return ComparisonController(repo);
});

final dealDetailsProvider = FutureProvider.family<Deal?, String>((ref, id) async {
  final repo = ref.watch(productRepositoryProvider);
  return repo.getDealById(id);
});

final stateGuideProvider =
    FutureProvider.family<Map<String, dynamic>?, String>((ref, stateCode) async {
  try {
    final jsonString = await rootBundle.loadString('assets/data/state_guides.json');
    final Map<String, dynamic> data = jsonDecode(jsonString);
    return data[stateCode] as Map<String, dynamic>?;
  } catch (e) {
    return null;
  }
});
