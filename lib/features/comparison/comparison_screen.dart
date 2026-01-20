import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import 'comparison_model.dart';
import 'comparison_provider.dart';
import 'widgets/deal_card.dart';
import 'widgets/search_bar_widget.dart';

class ComparisonScreen extends ConsumerStatefulWidget {
  final ProductCategory initialCategory;
  
  const ComparisonScreen({
    super.key,
    this.initialCategory = ProductCategory.energy,
  });

  @override
  ConsumerState<ComparisonScreen> createState() => _ComparisonScreenState();
}

class _ComparisonScreenState extends ConsumerState<ComparisonScreen> {
  
  @override
  void initState() {
    super.initState();
    // Load initial category on startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(comparisonProvider.notifier).loadCategory(widget.initialCategory);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(comparisonProvider);
    final controller = ref.read(comparisonProvider.notifier);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Compare & Save'),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.mainBackgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
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
                        backgroundColor: Colors.white10,
                        labelStyle: TextStyle(
                          color: isSelected ? AppTheme.deepNavy : Colors.white,
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
                    if (!state.isLoading)
                    Text(
                      'We found ${state.deals.length} deals for you',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SearchBarWidget(
                      onChanged: (value) => controller.search(value),
                    ),
                  ],
                ),
              ),

              // Content Area
              Expanded(
                child: state.isLoading 
                  ? const Center(child: CircularProgressIndicator(color: AppTheme.vibrantEmerald))
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        if (state.deals.isEmpty) {
                          return const Center(
                            child: Text(
                              'No deals found matching criteria.',
                              style: TextStyle(color: Colors.white54),
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
      ),
    );
  }

  String _formatCategory(ProductCategory cat) {
    switch (cat) {
      case ProductCategory.energy: return 'Energy';
      case ProductCategory.internet: return 'Internet';
      case ProductCategory.mobile: return 'Mobile';
      case ProductCategory.homeInsurance: return 'Home Ins.';
      case ProductCategory.carInsurance: return 'Car Ins.';
      case ProductCategory.creditCards: return 'Credit Cards';
    }
  }
}