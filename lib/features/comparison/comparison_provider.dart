import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'comparison_model.dart';
import 'data/product_repository.dart';

// Dependency Injection
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return JsonProductRepository();
});

// State Definition
class ComparisonState {
  final List<Deal> deals;
  final bool isLoading;
  final ProductCategory? selectedCategory;
  final String searchQuery;
  final String? selectedState;
  final Deal? bestValueDeal;

  ComparisonState({
    required this.deals,
    this.isLoading = false,
    this.selectedCategory,
    this.searchQuery = '',
    this.selectedState,
    this.bestValueDeal,
  });

  ComparisonState copyWith({
    List<Deal>? deals,
    bool? isLoading,
    ProductCategory? selectedCategory,
    String? searchQuery,
    String? selectedState,
    Deal? bestValueDeal,
  }) {
    return ComparisonState(
      deals: deals ?? this.deals,
      isLoading: isLoading ?? this.isLoading,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedState: selectedState ?? this.selectedState,
      bestValueDeal: bestValueDeal ?? this.bestValueDeal,
    );
  }
}

// Controller
class ComparisonController extends StateNotifier<ComparisonState> {
  final ProductRepository _repository;
  // Cache original list for local filtering
  List<Deal> _allDeals = [];

  ComparisonController(this._repository)
      : super(ComparisonState(deals: [], isLoading: false));

  Future<void> loadCategory(ProductCategory category) async {
    // If already selected and loaded, skip unless loading specifically requested
    if (state.selectedCategory == category && state.deals.isNotEmpty && !state.isLoading) return;

    state = state.copyWith(isLoading: true, selectedCategory: category);
    
    try {
      final allDeals = await _repository.getDeals(category);
      // Filter out disabled deals (e.g. price is 0)
      final deals = allDeals.where((d) => d.isEnabled).toList();
      
      // Sort deals: sponsored first, then by price
      deals.sort((a, b) {
        if (a.isSponsored && !b.isSponsored) {
          return -1; // a comes first
        } else if (!a.isSponsored && b.isSponsored) {
          return 1; // b comes first
        } else {
          // If both are sponsored or not sponsored, sort by price
          return a.price.compareTo(b.price);
        }
      });

      _allDeals = deals;
      
      state = state.copyWith(
        deals: deals,
        isLoading: false,
        bestValueDeal: _calculateBestValue(deals),
        searchQuery: '',
      );
    } catch (e) {
      // Handle error state in a real app
      state = state.copyWith(isLoading: false, deals: []);
    }
  }

  void updateStateFilter(String? stateCode) {
    state = state.copyWith(selectedState: stateCode);
    search(state.searchQuery); // Re-run search with new state filter
  }

  void search(String query) {
    final lowerQuery = query.toLowerCase();
    
    // Detect State in Query if not already selected via dropdown
    final states = ['nsw', 'vic', 'qld', 'sa', 'wa', 'act', 'tas', 'nt'];
    String? queryState;
    for (var s in states) {
      if (lowerQuery.contains(RegExp(r'\b' + s + r'\b'))) {
        queryState = s.toUpperCase();
        break;
      }
    }

    final activeStateFilter = state.selectedState ?? queryState;

    // Detect Intent Flags
    bool sortPriceAsc = lowerQuery.contains('cheap') || 
                        lowerQuery.contains('lowest') || 
                        lowerQuery.contains('budget') ||
                        lowerQuery.contains('price') ||
                        lowerQuery.contains('saver');
                        
    bool sortRatingDesc = lowerQuery.contains('best') || 
                          lowerQuery.contains('top') || 
                          lowerQuery.contains('rating') || 
                          lowerQuery.contains('premium') ||
                          lowerQuery.contains('quality');

    bool filterGreen = lowerQuery.contains('green') || 
                       lowerQuery.contains('solar') || 
                       lowerQuery.contains('eco') ||
                       lowerQuery.contains('renewable');

    bool intentUnlimited = lowerQuery.contains('unlimited') || lowerQuery.contains('infinite');
    
    // Filter Logic
    List<Deal> filtered = _allDeals.where((deal) {
      if (!deal.isEnabled) return false;

      // 1. Regional Filter (State)
      if (activeStateFilter != null) {
        // If deal has specific states, it MUST match one of them
        if (deal.applicableStates.isNotEmpty && !deal.applicableStates.contains(activeStateFilter)) {
          return false;
        }
      }

      // 2. Feature Intents
      if (filterGreen && !deal.isGreen) return false;
      if (intentUnlimited && !deal.description.toLowerCase().contains('unlimited') && !deal.planName.toLowerCase().contains('unlimited')) {
        if (!deal.keyFeatures.any((f) => f.toLowerCase().contains('unlimited'))) return false;
      }
      
      // 3. Text Match (Cleaned)
      if (query.isEmpty) return true;

      String tempQuery = lowerQuery;
      final intents = ['cheapest', 'cheap', 'lowest', 'budget', 'price', 'saver', 'best', 'top', 'rating', 'premium', 'quality', 'green', 'solar', 'eco', 'renewable', 'unlimited', 'infinite', ...states];
      for (var intent in intents) {
        tempQuery = tempQuery.replaceAll(RegExp(r'\b' + intent + r'\b'), '');
      }
      final stopWords = ['i', 'want', 'need', 'show', 'me', 'find', 'get', 'the', 'a', 'an', 'for', 'with', 'in', 'of', 'and', 'plan', 'plans', 'deal', 'deals'];
      for (var word in stopWords) {
        tempQuery = tempQuery.replaceAll(RegExp(r'\b' + RegExp.escape(word) + r'\b'), '');
      }
      String cleanQuery = tempQuery.replaceAll(RegExp(r'\s+'), ' ').trim();

      if (cleanQuery.isEmpty) return true;

      return deal.providerName.toLowerCase().contains(cleanQuery) ||
             deal.planName.toLowerCase().contains(cleanQuery) ||
             deal.keyFeatures.any((f) => f.toLowerCase().contains(cleanQuery));
    }).toList();

    // Smart Sorting
    if (sortPriceAsc) {
      filtered.sort((a, b) => a.price.compareTo(b.price));
    } else if (sortRatingDesc) {
      filtered.sort((a, b) => b.rating.compareTo(a.rating));
    } else {
      _defaultSort(filtered);
    }

    state = state.copyWith(
      deals: filtered,
      searchQuery: query,
      bestValueDeal: _calculateBestValue(filtered),
    );
  }

  void _defaultSort(List<Deal> deals) {
    deals.sort((a, b) {
      if (a.isSponsored && !b.isSponsored) return -1;
      if (!a.isSponsored && b.isSponsored) return 1;
      return a.price.compareTo(b.price);
    });
  }

  static Deal? _calculateBestValue(List<Deal> deals) {
    if (deals.isEmpty) return null;
    // Simple logic: Lowest price. 
    // In production, this would be a weighted score (Price / Features).
    return deals.reduce((curr, next) => curr.price < next.price ? curr : next);
  }
}

final comparisonProvider = StateNotifierProvider<ComparisonController, ComparisonState>((ref) {
  final repo = ref.watch(productRepositoryProvider);
  return ComparisonController(repo);
});

final dealDetailsProvider = FutureProvider.family<Deal?, String>((ref, id) async {
  final repo = ref.watch(productRepositoryProvider);
  return repo.getDealById(id);
});