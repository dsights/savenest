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
  final Deal? bestValueDeal;

  ComparisonState({
    required this.deals,
    this.isLoading = false,
    this.selectedCategory,
    this.searchQuery = '',
    this.bestValueDeal,
  });

  ComparisonState copyWith({
    List<Deal>? deals,
    bool? isLoading,
    ProductCategory? selectedCategory,
    String? searchQuery,
    Deal? bestValueDeal,
  }) {
    return ComparisonState(
      deals: deals ?? this.deals,
      isLoading: isLoading ?? this.isLoading,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
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
      final deals = await _repository.getDeals(category);
      
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

  void search(String query) {
    if (query.isEmpty) {
      // Restore default sort when clearing search
      final defaultSorted = List<Deal>.from(_allDeals);
      _defaultSort(defaultSorted);
      
      state = state.copyWith(
        deals: defaultSorted,
        searchQuery: '',
        bestValueDeal: _calculateBestValue(defaultSorted),
      );
      return;
    }

    final lowerQuery = query.toLowerCase();
    
    // 1. Detect Intent Flags
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
    bool intentFast = lowerQuery.contains('fast') || lowerQuery.contains('speed') || lowerQuery.contains('high speed');
    
    // Detect Location (States)
    final states = ['nsw', 'vic', 'qld', 'sa', 'wa', 'act', 'tas', 'nt'];
    String? targetState;
    for (var s in states) {
      if (lowerQuery.contains(RegExp(r'\b' + s + r'\b'))) {
        targetState = s;
        break;
      }
    }

    // 2. Filter Logic
    List<Deal> filtered = _allDeals.where((deal) {
      // Location Filter (if deal has state info in description or tags - currently checking description)
      if (targetState != null) {
        bool matchesState = deal.description.toLowerCase().contains(targetState!) || 
                           deal.planName.toLowerCase().contains(targetState!) ||
                           deal.keyFeatures.any((f) => f.toLowerCase().contains(targetState!));
        if (!matchesState) return false;
      }

      // Feature Intents
      if (filterGreen && !deal.isGreen) return false;
      if (intentUnlimited && !deal.description.toLowerCase().contains('unlimited') && !deal.planName.toLowerCase().contains('unlimited')) {
        if (!deal.keyFeatures.any((f) => f.toLowerCase().contains('unlimited'))) return false;
      }
      
      // Clean query for text matching
      String tempQuery = lowerQuery;
      
      // Remove intent keywords to avoid matching them as provider names
      final intents = [
        'cheapest', 'cheap', 'lowest', 'budget', 'price', 'saver',
        'best', 'top', 'rating', 'premium', 'quality',
        'green', 'solar', 'eco', 'renewable',
        'unlimited', 'infinite', 'fast', 'speed', 'high speed',
        ...states
      ];
      for (var intent in intents) {
        tempQuery = tempQuery.replaceAll(RegExp(r'\b' + intent + r'\b'), '');
      }

      // Remove stop words
      final stopWords = [
        'i', 'want', 'need', 'show', 'me', 'find', 'get', 
        'the', 'a', 'an', 'for', 'with', 'in', 'of', 'and',
        'plan', 'plans', 'deal', 'deals', 'offer', 'offers', 
        'card', 'cards', 'provider', 'providers'
      ];
      
      for (var word in stopWords) {
        tempQuery = tempQuery.replaceAll(RegExp(r'\b' + RegExp.escape(word) + r'\b'), '');
      }
      
      String cleanQuery = tempQuery.replaceAll(RegExp(r'\s+'), ' ').trim();

      if (cleanQuery.isEmpty) return true; // Matches all intents

      // Direct text matching on remaining specific terms (like provider names)
      return deal.providerName.toLowerCase().contains(cleanQuery) ||
             deal.planName.toLowerCase().contains(cleanQuery) ||
             deal.keyFeatures.any((f) => f.toLowerCase().contains(cleanQuery));
    }).toList();

    // 3. Smart Sorting
    if (sortPriceAsc) {
      filtered.sort((a, b) => a.price.compareTo(b.price));
    } else if (sortRatingDesc) {
      filtered.sort((a, b) => b.rating.compareTo(a.rating));
    } else if (intentFast && state.selectedCategory == ProductCategory.internet) {
      // Sort by assumed speed if internet (this is a heuristic based on price/name for this mockup)
      filtered.sort((a, b) => b.price.compareTo(a.price)); 
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