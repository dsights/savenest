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
import 'widgets/comparison_tray.dart';
import 'credit_card_model.dart';
import 'data/credit_card_repository.dart';
import 'widgets/credit_card_table.dart';
import '../../widgets/main_navigation_bar.dart';
import '../../widgets/main_mobile_drawer.dart';
import '../home/widgets/modern_footer.dart';
import '../gamification/gamification_provider.dart';
import '../gamification/widgets/quest_banner.dart';
import '../gamification/widgets/live_ticker.dart';

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
  bool _popupShown = false;
  bool _isMatrixView = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(comparisonProvider.notifier).loadCategory(widget.initialCategory);
      ref.read(gamificationProvider.notifier).recordCategory(
        widget.initialCategory.name,
      );
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_popupShown &&
        _scrollController.hasClients &&
        _scrollController.offset > 350) {
      _popupShown = true;
      // Fire 3 s after the user has scrolled down and seen deals
      _popupTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) _showSavingsPopup();
      });
    }
  }

  @override
  void dispose() {
    _popupTimer?.cancel();
    _scrollController.dispose();
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
              const Icon(Icons.savings_outlined,
                  color: AppTheme.vibrantEmerald, size: 48),
              const SizedBox(height: 16),
              const Text(
                'Want to calculate your exact savings?',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'Our smart calculator can analyse your usage and find hidden savings in seconds.',
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
                    textStyle: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  child: const Text('Open Savings Calculator'),
                ),
              ),
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('No thanks',
                    style: TextStyle(color: Colors.white54)),
              ),
              const SizedBox(height: 4),
              TextButton(
                onPressed: () {
                  context.pop();
                  context.push('/contact');
                },
                child: const Text('Or get a personalised quote',
                    style: TextStyle(color: Colors.white54)),
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

    String searchHint = 'Search plans, providers, features...';
    switch (selectedCat) {
      case ProductCategory.electricity:
        searchHint = 'Try "AGL NSW", "green energy", "no exit fees"…';
        break;
      case ProductCategory.gas:
        searchHint = 'Try "Origin", "no exit fees", "pay on time"…';
        break;
      case ProductCategory.internet:
        searchHint = 'Try "fast unlimited", "nbn 100", "Telstra"…';
        break;
      case ProductCategory.creditCards:
        searchHint = 'Try "no fee", "Qantas", "business"…';
        break;
      default:
        break;
    }

    final bool showStateSelector = selectedCat == ProductCategory.electricity ||
        selectedCat == ProductCategory.gas;

    // Autocomplete: provider names from the full unfiltered set + category intent phrases
    final suggestions = [
      ...state.allProviderNames.toList()..sort(),
      ..._categoryIntents(selectedCat),
    ];

    // Compute responsive grid column count once in build (avoids shrinkWrap)
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 1200
        ? 6
        : screenWidth > 900
            ? 4
            : screenWidth > 600
                ? 3
                : 2;

    // Data freshness label (shows the actual last-updated date from the JSON metadata)
    final freshnessLabel = state.dataLastUpdated.isNotEmpty
        ? 'Plan data last verified: ${state.dataLastUpdated}.'
        : 'Plan data verified regularly.';

    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      endDrawer: const MainMobileDrawer(),
      body: Stack(
        children: [
          Column(
        children: [
          const MainNavigationBar(),
          const QuestBanner(),
          Expanded(
            child: CustomScrollView(
              controller: _scrollController,
              primary: false,
              physics:
                  const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              slivers: [
                // ── Header + search bar ────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 40.0),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1200),
                        child: Column(
                          children: [
                            Text(
                              'Best $categoryTitle Comparison in Australia',
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .displaySmall
                                  ?.copyWith(
                                    color: AppTheme.deepNavy,
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            if (!state.isLoading &&
                                selectedCat != ProductCategory.creditCards)
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
                                    ? (stateCode) =>
                                        controller.updateStateFilter(stateCode)
                                    : null,
                                selectedState: state.selectedState,
                                hintText: searchHint,
                                filters: categoryFilters,
                                activeFilters: state.activeFilters,
                                onFilterToggle: (value) =>
                                    controller.toggleFilter(value),
                                onClearAllFilters: controller.clearAllFilters,
                                sortMode: state.sortMode,
                                onSortChanged: (mode) =>
                                    controller.setSortMode(mode),
                                categoryMaxPrice: state.categoryMaxPrice,
                                filterPriceMax: state.filterPriceMax,
                                onPriceMaxChanged: (val) =>
                                    controller.setPriceMax(val),
                                suggestions: suggestions,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Ranking methodology + data freshness notice ────
                SliverToBoxAdapter(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.vibrantEmerald.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppTheme.vibrantEmerald.withOpacity(0.2)),
                        ),
                        child: Column(
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.verified_user,
                                    color: AppTheme.vibrantEmerald, size: 20),
                                SizedBox(width: 8),
                                Text('How we rank plans',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.deepNavy)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Rankings use a weighted score: price (60%), features (20%), customer satisfaction (20%). $freshnessLabel',
                              style: const TextStyle(
                                  fontSize: 13, color: AppTheme.slate600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Live activity ticker ──────────────────────────
                const SliverToBoxAdapter(child: LiveActivityTicker()),

                // ── Credit cards table ─────────────────────────────
                if (selectedCat == ProductCategory.creditCards)
                  SliverToBoxAdapter(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1200),
                        child: creditCardsAsync.when(
                          data: (deals) => CreditCardTable(
                              deals: _filterCreditCards(
                                  deals, state.searchQuery)),
                          loading: () => const Center(
                              child: Padding(
                            padding: EdgeInsets.all(100.0),
                            child: CircularProgressIndicator(
                                color: AppTheme.accentOrange),
                          )),
                          error: (err, stack) => Center(
                              child: Text('Error: $err',
                                  style: const TextStyle(
                                      color: AppTheme.deepNavy))),
                        ),
                      ),
                    ),
                  )

                // ── Loading ────────────────────────────────────────
                else if (state.isLoading)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: CircularProgressIndicator(
                          color: AppTheme.accentOrange),
                    ),
                  )

                // ── No results ────────────────────────────────────
                else if (state.deals.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.search_off,
                                size: 64,
                                color: AppTheme.deepNavy.withOpacity(0.3)),
                            const SizedBox(height: 16),
                            Text(
                              'No deals match your criteria',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.deepNavy.withOpacity(0.7)),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try clearing your filters or removing words from the search field.',
                              style: TextStyle(
                                  color: AppTheme.slate600.withOpacity(0.8)),
                            ),
                            const SizedBox(height: 24),
                            OutlinedButton.icon(
                              // clearAllFilters already calls search(state.searchQuery) internally.
                              // The text field has its own clear button (×) for the text query.
                              onPressed: controller.clearAllFilters,
                              icon: const Icon(Icons.filter_alt_off),
                              label: const Text('Clear all filters'),
                              style: OutlinedButton.styleFrom(
                                  foregroundColor: AppTheme.vibrantEmerald),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )

                // ── Deal grid ────────────────────────────────────
                else ...[
                  // Matrix view toggle
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1400),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const Text('Matrix View',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.deepNavy)),
                              Switch(
                                value: _isMatrixView,
                                onChanged: (val) =>
                                    setState(() => _isMatrixView = val),
                                activeColor: AppTheme.vibrantEmerald,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Matrix view
                  if (_isMatrixView)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1400),
                            child: ComparisonMatrixView(deals: state.deals),
                          ),
                        ),
                      ),
                    )

                  // Virtualized deal grid (no shrinkWrap)
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                      sliver: SliverGrid.builder(
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: 1.05,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                        ),
                        itemCount: state.deals.length,
                        itemBuilder: (context, index) {
                          final deal = state.deals[index];
                          return DealCard(
                            deal: deal,
                            isBestValue: deal == state.bestValueDeal,
                            isSelectedForComparison:
                                state.selectedForComparison.contains(deal.id),
                            onToggleCompare: () =>
                                controller.toggleComparison(deal.id),
                          );
                        },
                      ),
                    ),
                ],

                const SliverToBoxAdapter(child: SizedBox(height: 100)),
                const SliverToBoxAdapter(child: ModernFooter()),
              ],
            ),
          ),
        ],
      ),
          // Comparison tray — floats above content at the bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ComparisonTray(category: selectedCat),
          ),
        ],
      ),
    );
  }

  List<String> _categoryIntents(ProductCategory category) {
    switch (category) {
      case ProductCategory.electricity:
        return [
          'cheapest electricity NSW',
          'cheapest electricity VIC',
          'green energy 100%',
          'no exit fees',
          'pay on time discount',
          'solar feed-in tariff',
          'flat rate electricity',
          'time of use electricity',
        ];
      case ProductCategory.gas:
        return [
          'cheapest gas NSW',
          'cheapest gas VIC',
          'no exit fees',
          'pay on time discount',
          'gas and electricity bundle',
        ];
      case ProductCategory.internet:
        return [
          'NBN 25', 'NBN 50', 'NBN 100', 'NBN 250', 'NBN 1000',
          'no lock-in contract',
          'unlimited data',
          'fast gaming internet',
          'cheap nbn',
          'home office internet',
        ];
      case ProductCategory.mobile:
        return [
          'prepaid SIM',
          'unlimited calls and text',
          'international roaming',
          'family plan',
          'cheap mobile plan',
          '5G network',
        ];
      case ProductCategory.solar:
        return [
          'solar panels 6.6kW',
          'battery storage',
          'solar and battery bundle',
          'best solar feed-in tariff',
        ];
      case ProductCategory.insurance:
        return [
          'comprehensive car insurance',
          'home and contents',
          'no claim bonus',
          'cheap car insurance',
        ];
      default:
        return [];
    }
  }

  List<CreditCardDeal> _filterCreditCards(
      List<CreditCardDeal> deals, String query) {
    if (query.isEmpty) return deals;

    final lowerQuery = query.toLowerCase();

    bool noFee = lowerQuery.contains('no fee') ||
        lowerQuery.contains('free') ||
        lowerQuery.contains('cheapest');
    bool business = lowerQuery.contains('business');
    bool personal = lowerQuery.contains('personal');
    bool rewards =
        lowerQuery.contains('rewards') || lowerQuery.contains('points');
    bool lowRate =
        lowerQuery.contains('low rate') || lowerQuery.contains('interest');
    bool frequentFlyer = lowerQuery.contains('frequent flyer') ||
        lowerQuery.contains('qantas') ||
        lowerQuery.contains('velocity');

    return deals.where((deal) {
      if (noFee) {
        if (!deal.annualFee.contains('0') &&
            !deal.annualFee.toLowerCase().contains('free')) return false;
      }
      if (business &&
          !deal.customerSegment.toLowerCase().contains('business')) {
        return false;
      }
      if (personal &&
          !deal.customerSegment.toLowerCase().contains('personal')) {
        return false;
      }
      if (rewards &&
          !deal.cardType.toLowerCase().contains('rewards') &&
          (deal.rewardsProgram.isEmpty || deal.rewardsProgram == '—')) {
        return false;
      }
      if (lowRate && !deal.cardType.toLowerCase().contains('low rate')) {
        return false;
      }
      if (frequentFlyer &&
          !deal.cardType.toLowerCase().contains('frequent flyer')) {
        return false;
      }

      var cleanQuery = lowerQuery;
      for (final intent in [
        'no fee', 'free', 'cheapest', 'business', 'personal', 'rewards',
        'points', 'low rate', 'interest', 'frequent flyer', 'qantas', 'velocity'
      ]) {
        cleanQuery = cleanQuery.replaceAll(intent, '');
      }
      for (final stop in [
        'i', 'want', 'need', 'show', 'me', 'find', 'get', 'the', 'a', 'an',
        'for', 'with', 'in', 'of', 'card', 'cards'
      ]) {
        cleanQuery =
            cleanQuery.replaceAll(RegExp(r'\b' + RegExp.escape(stop) + r'\b'), '');
      }
      cleanQuery = cleanQuery.replaceAll(RegExp(r'\s+'), ' ').trim();

      if (cleanQuery.isEmpty) return true;

      return deal.issuer.toLowerCase().contains(cleanQuery) ||
          deal.cardName.toLowerCase().contains(cleanQuery);
    }).toList();
  }
}
