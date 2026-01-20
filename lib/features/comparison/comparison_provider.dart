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
      : super(ComparisonState(deals: [], isLoading: true)) {
        // Load default category (Energy) on init
        loadCategory(ProductCategory.energy);
      }

  Future<void> loadCategory(ProductCategory category) async {
    state = state.copyWith(isLoading: true, selectedCategory: category);
    
    try {
      final deals = await _repository.getDeals(category);
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
      state = state.copyWith(
        deals: _allDeals,
        searchQuery: '',
        bestValueDeal: _calculateBestValue(_allDeals),
      );
      return;
    }

    final filtered = _allDeals.where((deal) {
      final q = query.toLowerCase();
      return deal.providerName.toLowerCase().contains(q) ||
             deal.planName.toLowerCase().contains(q) ||
             deal.keyFeatures.any((f) => f.toLowerCase().contains(q));
    }).toList();

    state = state.copyWith(
      deals: filtered,
      searchQuery: query,
      bestValueDeal: _calculateBestValue(filtered),
    );
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