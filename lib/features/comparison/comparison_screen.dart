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
import '../home/widgets/modern_footer.dart';

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
        body: Column(
          children: [
            const MainNavigationBar(),
            // Category Tabs
            Container(
              color: Colors.white,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
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
                            selectedColor: AppTheme.primaryBlue,
                            backgroundColor: Colors.white,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : AppTheme.deepNavy,
                              fontWeight: FontWeight.bold,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100),
                              side: BorderSide(
                                color: isSelected ? AppTheme.primaryBlue : AppTheme.slate300,
                              ),
                            ),
                            showCheckmark: false,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1200),
                        child: Column(
                          children: [
                            Text(
                              'Compare $categoryTitle Plans',
                              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                color: AppTheme.deepNavy,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (!state.isLoading && state.selectedCategory != ProductCategory.creditCards)
                            Text(
                              'We found ${state.deals.length} deals to help you save',
                              style: const TextStyle(
                                color: AppTheme.slate600,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 32),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 600),
                              child: SearchBarWidget(
                                onChanged: (value) => controller.search(value),
                                hintText: searchHint,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Content Area
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1400),
                      child: state.selectedCategory == ProductCategory.creditCards
                          ? creditCardsAsync.when(
                              data: (deals) => CreditCardTable(deals: _filterCreditCards(deals, state.searchQuery)),
                              loading: () => const Center(child: Padding(
                                padding: EdgeInsets.all(100.0),
                                child: CircularProgressIndicator(color: AppTheme.accentOrange),
                              )),
                              error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: AppTheme.deepNavy))),
                            )
                          : state.isLoading
                              ? const Center(child: Padding(
                                  padding: EdgeInsets.all(100.0),
                                  child: CircularProgressIndicator(color: AppTheme.accentOrange),
                                ))
                              : LayoutBuilder(
                              builder: (context, constraints) {
                                if (state.deals.isEmpty) {
                                  return Container(
                                    height: 300,
                                    alignment: Alignment.center,
                                    child: Text(
                                      'No deals found matching criteria.',
                                      style: TextStyle(color: AppTheme.deepNavy.withOpacity(0.5)),
                                    ),
                                  );
                                }
                                
                                // Responsive Breakpoint
                                if (constraints.maxWidth > 900) {
                                  // WEB: Grid Layout
                                  return GridView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 4,
                                      childAspectRatio: 0.85,
                                      mainAxisSpacing: 32,
                                      crossAxisSpacing: 32,
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
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                    itemCount: state.deals.length,
                                    itemBuilder: (context, index) {
                                      final deal = state.deals[index];
                                      final isBest = deal == state.bestValueDeal;
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 24.0),
                                        child: SizedBox(
                                          height: 420,
                                          child: DealCard(deal: deal, isBestValue: isBest),
                                        ),
                                      );
                                    },
                                  );
                                }
                              },
                            ),
                    ),
                    const SizedBox(height: 100),
                    const ModernFooter(),
                  ],
                ),
              ),
            ),
          ],
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
