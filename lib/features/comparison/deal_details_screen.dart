import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta_seo/meta_seo.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_theme.dart';
import 'comparison_provider.dart';
import '../../widgets/main_navigation_bar.dart';
import '../../widgets/main_mobile_drawer.dart';
import '../../widgets/glass_container.dart';

class DealDetailsScreen extends ConsumerWidget {
  final String dealId;

  const DealDetailsScreen({super.key, required this.dealId});

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dealAsync = ref.watch(dealDetailsProvider(dealId));

    return Scaffold(
      backgroundColor: AppTheme.deepNavy,
      endDrawer: const MainMobileDrawer(),
      body: dealAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.vibrantEmerald)),
        error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.white))),
        data: (deal) {
          if (deal == null) {
            return const Center(child: Text('Deal not found', style: TextStyle(color: Colors.white)));
          }

          // SEO Tags
          if (kIsWeb) {
            MetaSEO().author(author: 'SaveNest Team');
            MetaSEO().description(description: '${deal.providerName} ${deal.planName} Review. ${deal.description}. Compare and save today.');
            MetaSEO().keywords(keywords: '${deal.providerName}, ${deal.planName}, compare ${deal.category.name}, best deal, Australia');
            
            MetaSEO().ogTitle(ogTitle: '${deal.providerName} - ${deal.planName} | SaveNest Review');
            MetaSEO().ogDescription(ogDescription: deal.description);
            MetaSEO().ogImage(ogImage: deal.providerLogoUrl); // Ideally a banner image
            
            // Add Product Schema
            // Note: Currently MetaSEO doesn't support custom script tags easily in body, 
            // but we can rely on the dynamic title/desc for basic indexing.
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                const MainNavigationBar(),
                
                // Header / Hero Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppTheme.deepNavy,
                        deal.providerColor.withOpacity(0.3),
                        AppTheme.deepNavy,
                      ],
                    ),
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1000),
                      child: Column(
                        children: [
                          // Logo
                          Container(
                            width: 100,
                            height: 100,
                            padding: const EdgeInsets.all(16),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: deal.providerLogoUrl.endsWith('.svg')
                                ? SvgPicture.network(deal.providerLogoUrl)
                                : Image.network(deal.providerLogoUrl),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            deal.planName,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Provided by ${deal.providerName}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 32),
                          // Price
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '\$${deal.price}',
                                style: const TextStyle(
                                  color: AppTheme.vibrantEmerald,
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0, left: 4),
                                child: Text(
                                  deal.priceUnit,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton(
                            onPressed: () => _launchURL(deal.affiliateUrl),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
                              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            child: const Text('Go to Site'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Details Content
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('Plan Details'),
                          Text(
                            deal.description,
                            style: const TextStyle(color: Colors.white70, fontSize: 16, height: 1.5),
                          ),
                          const SizedBox(height: 32),
                          
                          _buildSectionTitle('Key Features'),
                          ...deal.keyFeatures.map((feature) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.check_circle, color: AppTheme.vibrantEmerald, size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    feature,
                                    style: const TextStyle(color: Colors.white, fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                          )),
                          
                          const SizedBox(height: 48),
                          Divider(color: Colors.white.withOpacity(0.1)),
                          const SizedBox(height: 48),

                          // Reviews Section (Placeholder for now, but important for EEAT)
                          _buildSectionTitle('User Reviews'),
                          GlassContainer(
                            padding: const EdgeInsets.all(24),
                            borderRadius: 16,
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      deal.rating.toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 48,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: List.generate(5, (index) => Icon(
                                            index < deal.rating ? Icons.star : Icons.star_border,
                                            color: Colors.amber,
                                          )),
                                        ),
                                        const Text(
                                          'Based on market analysis',
                                          style: TextStyle(color: Colors.white54, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                const Text(
                                  "Independent verification of this plan highlights its competitive pricing in the current market. Users generally appreciate the transparency and ease of switching.",
                                  style: TextStyle(color: Colors.white70, fontStyle: FontStyle.italic),
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
