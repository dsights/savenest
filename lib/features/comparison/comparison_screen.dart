import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:meta_seo/meta_seo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import 'comparison_model.dart';
import 'comparison_provider.dart';
import 'widgets/deal_card.dart';
import 'widgets/search_bar_widget.dart';
import 'widgets/comparison_matrix_view.dart';
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
  bool _isMatrixView = false;

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
      barrierDismissible: true, 
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
                    context.pop(); 
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
              TextButton(
                onPressed: () => context.pop(),
                child: const Text("No, thanks", style: TextStyle(color: Colors.white54)),
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
        return 'Internet & NBN';
      case ProductCategory.mobile:
        return 'Mobile';
      case ProductCategory.insurance:
        return 'Insurance';
      case ProductCategory.solar:
        return 'Solar';
      default:
        return 'Deals';
    }
  }

  Map<String, List<String>> _getFiltersForCategory(ProductCategory category) {
    switch (category) {
      case ProductCategory.internet:
        return {
          'Speed Tiers': ['NBN 25', 'NBN 50', 'NBN 100', 'NBN 250', 'NBN 1000'],
          'Contract Length': ['No Lock-in', '12 Months', '24 Months'],
          'Discounts': ['New Customer', 'Bundle Discount'],
          'Best For': ['Budget', 'Family', 'Gaming', 'Streaming'],
          'Deal Type': ['Cheap', 'Balanced', 'Premium'],
        };
      case ProductCategory.mobile:
        return {
          'Network Provider': ['Telstra', 'Optus', 'Vodafone'],
          'Contract Length': ['Prepaid', 'Postpaid', '12 Months'],
          'Best For': ['Budget', 'Value', 'Heavy Use'],
          'Deal Type': ['Cheap', 'Balanced', 'Premium'],
        };
      case ProductCategory.electricity:
      case ProductCategory.gas:
        return {
          'Green Energy %': ['0%', '10%', '20%', '100%'],
          'Exit Fees': ['No Exit Fees', 'Standard'],
          'Payment Methods': ['Direct Debit', 'Credit Card', 'BPay'],
          'Discounts': ['Pay On Time', 'Guaranteed'],
          'Best For': ['Budget', 'Everyday', 'Solar', 'Green'],
          'Deal Type': ['Cheap', 'Value', 'Premium'],
        };
      case ProductCategory.solar:
        return {
          'Solar Size (kW)': ['6.6', '10', '13'],
          'Battery Size (kWh)': ['5', '10', '13.5'],
          'Deal Type': ['Cheap', 'Value', 'Premium'],
        };
      case ProductCategory.insurance:
        return {
          'Insurance Type': ['Car', 'Home', 'Pet', 'Health'],
          'Provider': ['AAMI', 'Bupa', 'Allianz', 'NRMA', 'Youi'],
        };
      default:
        return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(comparisonProvider);
    final creditCardsAsync = ref.watch(creditCardsProvider);
    final controller = ref.read(comparisonProvider.notifier);
    final selectedCat = state.selectedCategory ?? widget.initialCategory;
    final categoryTitle = _getCategoryTitle(selectedCat);
    final categoryFilters = _getFiltersForCategory(selectedCat);

    // SEO Optimization
    if (kIsWeb) {
      final title = 'Best $categoryTitle Comparison Australia | Save with SaveNest';
      final description =
          'Compare $categoryTitle plans from top Australian providers. Find the cheapest rates and best value deals for your household or business.';
      MetaSEO().author(author: 'SaveNest Team');
      MetaSEO().description(description: description);
      MetaSEO().keywords(
          keywords:
              'compare $categoryTitle Australia, cheapest $categoryTitle plans, best $categoryTitle provider 2026');
      MetaSEO().ogTitle(ogTitle: title);
      MetaSEO().ogDescription(ogDescription: description);
    }

    String searchHint = 'Search providers, features...';
    if (selectedCat == ProductCategory.internet) {
      searchHint = 'Try "fast unlimited", "nbn 100", "Telstra"...';
    } else if (selectedCat == ProductCategory.creditCards) {
      searchHint = 'Try "no fee", "Qantas", "business"...';
    }
    
    final bool showStateSelector = selectedCat == ProductCategory.electricity || selectedCat == ProductCategory.gas;

    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      endDrawer: const MainMobileDrawer(),
      body: Column(
        children: [
          const MainNavigationBar(),
          Expanded(
            child: CustomScrollView(
              primary: true,
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1200),
                        child: Column(
                          children: [
                            Text(
                              'Best $categoryTitle Comparison in Australia',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                    color: AppTheme.deepNavy,
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            if (!state.isLoading && selectedCat != ProductCategory.creditCards)
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
                              constraints: const BoxConstraints(maxWidth: 800),
                              child: SearchBarWidget(
                                onChanged: (value) => controller.search(value),
                                onStateChanged: showStateSelector
                                    ? (stateCode) => controller.updateStateFilter(stateCode)
                                    : null,
                                selectedState: state.selectedState,
                                hintText: searchHint,
                                filters: categoryFilters,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.vibrantEmerald.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.vibrantEmerald.withOpacity(0.2)),
                        ),
                        child: const Column(
                          children: [
                            Row(
                              children: [
                                Icon(Icons.verified_user, color: AppTheme.vibrantEmerald, size: 20),
                                SizedBox(width: 8),
                                Text('How we calculate your savings', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.deepNavy)),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Our rankings are based on a weighted average of price (60%), features (20%), and customer satisfaction scores (20%). We update our database every 2 hours to ensure you get the most accurate rates.',
                              style: TextStyle(fontSize: 13, color: AppTheme.slate600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                
                if (selectedCat == ProductCategory.creditCards)
                  SliverToBoxAdapter(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1200),
                        child: creditCardsAsync.when(
                          data: (deals) => CreditCardTable(deals: _filterCreditCards(deals, state.searchQuery)),
                          loading: () => const Center(child: Padding(
                            padding: EdgeInsets.all(100.0),
                            child: CircularProgressIndicator(color: AppTheme.accentOrange),
                          )),
                          error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: AppTheme.deepNavy))),
                        ),
                      ),
                    ),
                  )
                else if (state.isLoading)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: CircularProgressIndicator(color: AppTheme.accentOrange),
                    ),
                  )
                else if (state.deals.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Text(
                        'No deals found matching criteria.',
                        style: TextStyle(color: AppTheme.deepNavy.withOpacity(0.5)),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                    sliver: SliverToBoxAdapter(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1400),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  const Text('Matrix View', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.deepNavy)),
                                  Switch(
                                    value: _isMatrixView,
                                    onChanged: (val) => setState(() => _isMatrixView = val),
                                    activeColor: AppTheme.vibrantEmerald,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              if (_isMatrixView)
                                ComparisonMatrixView(deals: state.deals)
                              else
                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    final crossAxisCount = constraints.maxWidth > 1200
                                        ? 4
                                        : constraints.maxWidth > 800
                                            ? 3
                                            : constraints.maxWidth > 600
                                                ? 2
                                                : 1;
                                    
                                    return GridView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: crossAxisCount,
                                        childAspectRatio: 1.0, 
                                        mainAxisSpacing: 24,
                                        crossAxisSpacing: 24,
                                      ),
                                      itemCount: state.deals.length,
                                      itemBuilder: (context, index) {
                                        final deal = state.deals[index];
                                        final isBest = deal == state.bestValueDeal;
                                        return DealCard(deal: deal, isBestValue: isBest);
                                      },
                                    );
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
                const SliverToBoxAdapter(child: ModernFooter()),
              ],
            ),
          ),
        ],
      ),
    );
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
