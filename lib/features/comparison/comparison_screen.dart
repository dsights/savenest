import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meta_seo/meta_seo.dart';
import '../../theme/app_theme.dart';
import 'comparison_model.dart';
import 'comparison_provider.dart';
import 'widgets/deal_card.dart';
import 'widgets/search_bar_widget.dart';
import 'package:flutter/foundation.dart'; // Import for kIsWeb
import 'credit_card_model.dart';
import 'data/credit_card_repository.dart';
import 'widgets/credit_card_table.dart';
import '../../widgets/main_navigation_bar.dart';
import '../../widgets/main_mobile_drawer.dart';

class ComparisonScreen extends ConsumerStatefulWidget {
  final ProductCategory initialCategory;
  
  const ComparisonScreen({
    super.key,
    this.initialCategory = ProductCategory.electricity,
  });

  @override
  ConsumerState<ComparisonScreen> createState() => _ComparisonScreenState();
}

class _ComparisonScreenState extends ConsumerState<ComparisonScreen> {
  Timer? _popupTimer;

  @override
  void initState() {
    super.initState();
    // Load initial category on startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(comparisonProvider.notifier).loadCategory(widget.initialCategory);
    });

    // Start 10-second timer for popup
    _popupTimer = Timer(const Duration(seconds: 10), () {
      if (mounted) {
        _showSavingsPopup();
      }
    });
  }

  @override
  void dispose() {
    _popupTimer?.cancel();
    super.dispose();
  }

  void _showSavingsPopup() {
    showDialog(
      context: context,
      barrierDismissible: true, // Allow clicking outside to close
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.deepNavy,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.vibrantEmerald, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.savings_outlined, color: AppTheme.vibrantEmerald, size: 48),
              const SizedBox(height: 16),
              const Text(
                "Want to calculate your exact savings?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Our smart calculator can analyze your usage and find hidden savings in seconds.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    context.pop(); // Close dialog
                    context.go('/savings');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.vibrantEmerald,
                    foregroundColor: AppTheme.deepNavy,
                    textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  child: const Text("Open Savings Calculator"),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  context.pop();
                  context.push('/contact');
                },
                child: const Text("Or get a Personalised Quote", style: TextStyle(color: Colors.white54)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getCategoryTitle(ProductCategory category) {
    switch (category) {
      case ProductCategory.electricity:
        return 'Electricity';
      case ProductCategory.gas:
        return 'Gas';
      case ProductCategory.internet:
        return 'Internet';
      case ProductCategory.mobile:
        return 'Mobile';
      case ProductCategory.insurance:
        return 'Insurance';
      default:
        return 'Deals';
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(comparisonProvider);
    final creditCardsAsync = ref.watch(creditCardsProvider);
    final controller = ref.read(comparisonProvider.notifier);
    final categoryTitle = _getCategoryTitle(widget.initialCategory);

    String searchHint;
    switch (state.selectedCategory) {
      case ProductCategory.electricity:
      case ProductCategory.gas:
        searchHint = 'Try "cheapest", "green energy", "Origin"...';
        break;
      case ProductCategory.internet:
      case ProductCategory.mobile:
        searchHint = 'Try "unlimited data", "cheapest", "Telstra"...';
        break;
      case ProductCategory.creditCards:
        searchHint = 'Try "no fee", "Qantas", "business cards"...';
        break;
      default:
        searchHint = 'Search providers, features...';
    }

    // Update meta tags for SEO
      if (kIsWeb) {
        MetaSEO meta = MetaSEO();
        final String title = 'Compare $categoryTitle Plans & Prices in Australia | SaveNest';
        final String description = 'Find the best $categoryTitle deals from top Australian providers. Compare plans, prices, and features to save money on your bills.';
        const String imageUrl = 'https://savenest.au/assets/assets/images/hero_energy.jpg';

        meta.nameContent(name: 'title', content: title);
        meta.nameContent(name: 'description', content: description);
        
        // Open Graph
        meta.ogTitle(ogTitle: title);
        meta.ogDescription(ogDescription: description);
        meta.propertyContent(property: 'og:url', content: 'https://savenest.au/deals/${widget.initialCategory.name}');
        meta.ogImage(ogImage: imageUrl);

        // Twitter
        meta.nameContent(name: 'twitter:card', content: 'summary_large_image');
        meta.nameContent(name: 'twitter:title', content: title);
        meta.nameContent(name: 'twitter:description', content: description);
        meta.nameContent(name: 'twitter:image', content: imageUrl);
      }

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
              // Category Tabs
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Row(
                    children: ProductCategory.values.map((cat) {
                      final isSelected = cat == state.selectedCategory;
                      return Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: ChoiceChip(
                          label: Text(_formatCategory(cat)),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              controller.loadCategory(cat);
                            }
                          },
                          selectedColor: AppTheme.vibrantEmerald,
                          backgroundColor: Colors.black12,
                          labelStyle: TextStyle(
                            color: AppTheme.deepNavy,
                            fontWeight: FontWeight.bold,
                          ),
                          side: BorderSide.none,
                        ),
                      );
                    }).toList(),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                  child: Column(
                    children: [
                      if (!state.isLoading && state.selectedCategory != ProductCategory.creditCards)
                      Text(
                        'We found ${state.deals.length} deals for you',
                        style: TextStyle(
                          color: AppTheme.deepNavy.withOpacity(0.7),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SearchBarWidget(
                        onChanged: (value) => controller.search(value),
                        hintText: searchHint,
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),

                // Content Area
                Expanded(
                  child: state.selectedCategory == ProductCategory.creditCards
                      ? creditCardsAsync.when(
                          data: (deals) => CreditCardTable(deals: _filterCreditCards(deals, state.searchQuery)),
                          loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.vibrantEmerald)),
                          error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: AppTheme.deepNavy))),
                        )
                      : state.isLoading
                          ? const Center(child: CircularProgressIndicator(color: AppTheme.vibrantEmerald))
                          : LayoutBuilder(
                          builder: (context, constraints) {
                            if (state.deals.isEmpty) {
                              return Center(
                                child: Text(
                                  'No deals found matching criteria.',
                                  style: TextStyle(color: AppTheme.deepNavy.withOpacity(0.5)),
                                ),
                              );
                            }
                            
                            // Responsive Breakpoint
                            if (constraints.maxWidth > 600) {
                              // WEB / TABLET: Grid Layout
                              return GridView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 5, // 5 columns for web
                                  childAspectRatio: 1.0, // Square ratio
                                  mainAxisSpacing: 16,
                                  crossAxisSpacing: 16,
                                ),
                                itemCount: state.deals.length,
                                itemBuilder: (context, index) {
                                  final deal = state.deals[index];
                                  final isBest = deal == state.bestValueDeal;
                                  return DealCard(deal: deal, isBestValue: isBest);
                                },
                              );
                            } else {
                              // MOBILE: List Layout
                              return ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                itemCount: state.deals.length,
                                itemBuilder: (context, index) {
                                  final deal = state.deals[index];
                                  final isBest = deal == state.bestValueDeal;
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 20.0),
                                    child: SizedBox(
                                      height: 240, // Compact height
                                      child: DealCard(deal: deal, isBestValue: isBest),
                                    ),
                                  );
                                },
                              );
                            }
                          },
                        ),
                ),
            ],
          ),
        ),
    );
  }

  String _formatCategory(ProductCategory cat) {
    switch (cat) {
      case ProductCategory.electricity:
        return 'Electricity';
      case ProductCategory.gas:
        return 'Gas';
      case ProductCategory.internet:
        return 'Internet';
      case ProductCategory.mobile:
        return 'Mobile';
      case ProductCategory.insurance:
        return 'Insurance';
      case ProductCategory.creditCards:
        return 'Credit Cards';
    }
  }

  List<CreditCardDeal> _filterCreditCards(List<CreditCardDeal> deals, String query) {
    if (query.isEmpty) return deals;

    final lowerQuery = query.toLowerCase();
    
    // Intents
    bool noFee = lowerQuery.contains('no fee') || lowerQuery.contains('free') || lowerQuery.contains('cheapest');
    bool business = lowerQuery.contains('business');
    bool personal = lowerQuery.contains('personal');
    bool rewards = lowerQuery.contains('rewards') || lowerQuery.contains('points');
    bool lowRate = lowerQuery.contains('low rate') || lowerQuery.contains('interest');
    bool frequentFlyer = lowerQuery.contains('frequent flyer') || lowerQuery.contains('qantas') || lowerQuery.contains('velocity');

    return deals.where((deal) {
      if (noFee) {
        if (!deal.annualFee.contains('0') && !deal.annualFee.toLowerCase().contains('free')) return false;
      }
      if (business && !deal.customerSegment.toLowerCase().contains('business')) return false;
      if (personal && !deal.customerSegment.toLowerCase().contains('personal')) return false;
      if (rewards && !deal.cardType.toLowerCase().contains('rewards') && (!deal.rewardsProgram.isNotEmpty || deal.rewardsProgram == '—')) return false;
      if (lowRate && !deal.cardType.toLowerCase().contains('low rate')) return false;
      if (frequentFlyer && !deal.cardType.toLowerCase().contains('frequent flyer')) return false;

      // Text Match
      String tempQuery = lowerQuery;
      final intents = ['no fee', 'free', 'cheapest', 'business', 'personal', 'rewards', 'points', 'low rate', 'interest', 'frequent flyer', 'qantas', 'velocity'];
      for (var intent in intents) {
        tempQuery = tempQuery.replaceAll(intent, '');
      }
      
      final stopWords = ['i', 'want', 'need', 'show', 'me', 'find', 'get', 'the', 'a', 'an', 'for', 'with', 'in', 'of', 'card', 'cards'];
      for (var word in stopWords) {
        tempQuery = tempQuery.replaceAll(RegExp(r'\b' + RegExp.escape(word) + r'\b'), '');
      }
      
      String cleanQuery = tempQuery.replaceAll(RegExp(r'\s+'), ' ').trim();

      if (cleanQuery.isEmpty) return true;

      return deal.issuer.toLowerCase().contains(cleanQuery) ||
             deal.cardName.toLowerCase().contains(cleanQuery);
    }).toList();
  }
}
