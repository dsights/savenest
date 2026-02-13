import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:go_router/go_router.dart';
import 'package:meta_seo/meta_seo.dart';
import '../../theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../blog/blog_provider.dart';
import '../../widgets/main_navigation_bar.dart';
import '../../widgets/main_mobile_drawer.dart';

import 'widgets/blog_multi_carousel.dart';
import 'widgets/hero_carousel_section.dart';
import 'widgets/partner_logo_slider.dart';
import 'widgets/animated_value_props.dart';
import 'widgets/modern_footer.dart';

class LandingScreen extends ConsumerStatefulWidget {
  const LandingScreen({super.key});

  @override
  ConsumerState<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends ConsumerState<LandingScreen> {
  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      MetaSEO meta = MetaSEO();
      const String title = 'SaveNest | Compare & Save on Australian Utilities';
      const String description = 'Stop overpaying on your bills. SaveNest helps you compare electricity, gas, internet, and mobile plans from top Australian providers. Find a better deal in seconds.';
      const String imageUrl = 'https://savenest.au/assets/assets/images/hero_energy.jpg';

      meta.nameContent(name: 'title', content: title);
      meta.nameContent(name: 'description', content: description);
      meta.ogTitle(ogTitle: title);
      meta.ogDescription(ogDescription: description);
      meta.propertyContent(property: 'og:url', content: 'https://savenest.au/');
      meta.ogImage(ogImage: imageUrl);
      meta.propertyContent(property: 'og:type', content: 'website');
      meta.nameContent(name: 'twitter:card', content: 'summary_large_image');
      meta.nameContent(name: 'twitter:title', content: title);
      meta.nameContent(name: 'twitter:description', content: description);
      meta.nameContent(name: 'twitter:image', content: imageUrl);
    }

    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      endDrawer: const MainMobileDrawer(),
      body: SingleChildScrollView(
        primary: true,
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        child: Column(
          children: [
            const MainNavigationBar(),
            const HeroCarouselSection(),
            const PartnerLogoSlider(),
            const AnimatedValueProps(),
            _buildBlogSection(context),
            _buildTestimonialsSection(context),
            const ModernFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildBlogSection(BuildContext context) {
    final postsAsync = ref.watch(blogPostsProvider);

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Expert Insights & Tips',
                        style: TextStyle(
                          color: AppTheme.accentOrange,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Latest from our Blog',
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                              color: AppTheme.deepNavy,
                            ),
                      ),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: () => context.go('/blog'),
                    icon: const Text("View All", style: TextStyle(fontWeight: FontWeight.bold)),
                    label: const Icon(Icons.arrow_forward, size: 16),
                  ),
                ],
              ),
              const SizedBox(height: 60),
              postsAsync.when(
                data: (posts) => BlogMultiCarousel(posts: posts),
                loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.accentOrange)),
                error: (err, stack) => const Text('Failed to load insights', style: TextStyle(color: Colors.black54)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTestimonialsSection(BuildContext context) {
    return Container(
      color: AppTheme.offWhite,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              const Text(
                "TESTIMONIALS",
                style: TextStyle(color: AppTheme.accentOrange, fontWeight: FontWeight.bold, letterSpacing: 2),
              ),
              const SizedBox(height: 12),
              const Text(
                "Trusted by thousands of Aussies",
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.deepNavy, fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              SizedBox(
                height: 280,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _testimonials.length,
                  itemBuilder: (context, index) {
                    final t = _testimonials[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 32.0, bottom: 20),
                      child: Container(
                        width: 380,
                        padding: const EdgeInsets.all(40),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: List.generate(5, (i) => const Icon(Icons.star, color: Colors.amber, size: 20)),
                            ),
                            const SizedBox(height: 24),
                            Expanded(
                              child: Text(
                                '"${t.quote}"',
                                style: const TextStyle(
                                  color: AppTheme.slate600,
                                  fontSize: 18,
                                  height: 1.6,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: AppTheme.primaryBlue,
                                  radius: 20,
                                  child: Text(t.author[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                ),
                                const SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(t.author, style: const TextStyle(color: AppTheme.deepNavy, fontWeight: FontWeight.bold, fontSize: 16)),
                                    const Text("Verified Customer", style: TextStyle(color: AppTheme.vibrantEmerald, fontSize: 12, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Testimonial {
  final String quote;
  final String author;

  _Testimonial({required this.quote, required this.author});
}

final List<_Testimonial> _testimonials = [
  _Testimonial(
    quote: "SaveNest made comparing electricity plans so easy! I saved so much time and found a better deal instantly.",
    author: "Sarah P.",
  ),
  _Testimonial(
    quote: "I was dreading switching internet providers, but SaveNest streamlined the whole process. Highly recommend!",
    author: "David L.",
  ),
  _Testimonial(
    quote: "Honest, transparent, and incredibly helpful. SaveNest delivered on their promise to find me the best value.",
    author: "Jessica R.",
  ),
  _Testimonial(
    quote: "The savings calculator helped me understand my potential savings before even comparing. Brilliant tool!",
    author: "Mark T.",
  ),
  _Testimonial(
    quote: "Finally, a comparison site that puts the customer first. No hidden fees, just great deals.",
    author: "Emily C.",
  ),
];