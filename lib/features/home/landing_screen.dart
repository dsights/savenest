import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // For web check
import 'package:url_launcher/url_launcher.dart'; // For launching app store links
import '../../theme/app_theme.dart';
import '../../widgets/glass_container.dart';
import '../savings/savings_screen.dart';
import '../comparison/comparison_screen.dart';
import '../comparison/comparison_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Add Riverpod
import '../blog/blog_provider.dart'; // Import Blog Provider
import '../blog/widgets/blog_card.dart'; // Import Blog Card
import '../blog/blog_post_screen.dart'; // Import Blog Screen

import 'widgets/blog_hero_scroller.dart'; // Import New Scroller

class LandingScreen extends ConsumerWidget { // Change to ConsumerWidget
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) { // Add ref
    return Scaffold(
      backgroundColor: AppTheme.deepNavy,
      endDrawer: _buildMobileDrawer(context),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildNavBar(context),
            _buildHeroSection(context),
            if (kIsWeb) _buildDownloadAppSection(context), // New Section
            _buildCategorySection(context),
            _buildBlogSection(context, ref), // Add Blog Section
            _buildHowItWorksSection(context),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }
// ...
  Widget _buildDownloadAppSection(BuildContext context) {
    return Container(
      color: AppTheme.deepNavy,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              const Text(
                'Get the Full Experience on Mobile',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 20,
                runSpacing: 20,
                alignment: WrapAlignment.center,
                children: [
                  _storeButton(
                    context,
                    'Get it on',
                    'Google Play',
                    Icons.android,
                    'https://play.google.com/store/apps/details?id=com.example.savenest', // Update with real ID
                  ),
                  _storeButton(
                    context,
                    'Download on the',
                    'App Store',
                    Icons.apple,
                    'https://apps.apple.com/app/id123456789', // Update with real ID
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _storeButton(BuildContext context, String sub, String title, IconData icon, String url) {
    return InkWell(
      onTap: () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        }
      },
      child: Container(
        width: 180,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sub,
                  style: const TextStyle(color: Colors.white70, fontSize: 10),
                ),
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlogSection(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(blogPostsProvider);

    return Container(
      color: const Color(0xFF0F1530),
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Featured Insights',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              const BlogHeroScroller(), // Add the new Hero Scroller here
              const SizedBox(height: 60),
              const Text(
                'Latest Insights',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              
              postsAsync.when(
// ...
                data: (posts) => SizedBox(
                  height: 380, // Fixed height for cards
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: posts.length,
                    separatorBuilder: (c, i) => const SizedBox(width: 20),
                    itemBuilder: (context, index) {
                      return SizedBox(
                        width: 300, // Fixed width card
                        child: BlogCard(
                          post: posts[index],
                          onTap: () {
                             Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => BlogPostScreen(post: posts[index])),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
                loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.vibrantEmerald)),
                error: (err, stack) => const Text('Failed to load insights', style: TextStyle(color: Colors.white54)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      color: AppTheme.deepNavy,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.shield_moon, color: AppTheme.vibrantEmerald, size: 28),
                  const SizedBox(width: 8),
                  Text(
                    'SaveNest',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.0,
                        ),
                  ),
                ],
              ),
              if (MediaQuery.of(context).size.width > 600)
                Row(
                  children: [
                    _navLink('Energy'),
                    _navLink('Broadband'),
                    _navLink('Insurance'),
                    const SizedBox(width: 24),
                    _loginButton(context),
                  ],
                )
              else
                // Mobile Menu Button
                Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white),
                    onPressed: () => Scaffold.of(context).openEndDrawer(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildMobileDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: AppTheme.deepNavy,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        children: [
          Row(
            children: [
              const Icon(Icons.shield_moon, color: AppTheme.vibrantEmerald, size: 28),
              const SizedBox(width: 8),
              Text(
                'SaveNest',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          ListTile(
            title: const Text('Energy', style: TextStyle(color: Colors.white, fontSize: 18)),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Broadband', style: TextStyle(color: Colors.white, fontSize: 18)),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Insurance', style: TextStyle(color: Colors.white, fontSize: 18)),
            onTap: () {},
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close drawer
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SavingsScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.vibrantEmerald,
              foregroundColor: AppTheme.deepNavy,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('CALCULATE SAVINGS'),
          ),
        ],
      ),
    );
  }

  Widget _loginButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
         Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const SavingsScreen()),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white10,
        foregroundColor: Colors.white,
      ),
      child: const Text('Log In'),
    );
  }

  Widget _navLink(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white70,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: AppTheme.mainBackgroundGradient,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.vibrantEmerald.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.vibrantEmerald.withOpacity(0.3)),
                ),
                child: const Text(
                  'TRUSTED BY 50,000+ AUSTRALIANS',
                  style: TextStyle(
                    color: AppTheme.vibrantEmerald,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "Stop paying the 'lazy tax'.\nCompare utilities in seconds.",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.1,
                    ),
              ),
              const SizedBox(height: 24),
              const Text(
                'We analyse your bills against thousands of market offers to find you the absolute best value for Energy, Internet, and Insurance.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const SavingsScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.vibrantEmerald,
                  foregroundColor: AppTheme.deepNavy,
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                child: const Text('CALCULATE MY SAVINGS'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySection(BuildContext context) {
    return Container(
      color: AppTheme.deepNavy,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'What would you like to compare?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              LayoutBuilder(
                builder: (context, constraints) {
                  return Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    children: [
                      _categoryCard(context, 'Electricity & Gas', Icons.bolt, Colors.orange, ProductCategory.energy),
                      _categoryCard(context, 'Internet & Mobile', Icons.wifi, Colors.blue, ProductCategory.internet),
                      _categoryCard(context, 'Home Loans', Icons.home, Colors.purple, ProductCategory.creditCards), // Placeholder
                      _categoryCard(context, 'Health Insurance', Icons.favorite, Colors.red, ProductCategory.homeInsurance), // Placeholder
                      _categoryCard(context, 'Car Insurance', Icons.directions_car, Colors.green, ProductCategory.carInsurance),
                      _categoryCard(context, 'Credit Cards', Icons.credit_card, Colors.amber, ProductCategory.creditCards),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _categoryCard(BuildContext context, String title, IconData icon, Color color, ProductCategory category) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => ComparisonScreen(initialCategory: category)),
        );
      },
      child: GlassContainer(
        width: 150,
        height: 170,
        borderRadius: 16,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHowItWorksSection(BuildContext context) {
    return Container(
      color: const Color(0xFF0F1530), // Slightly lighter navy
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            children: [
              const Text(
                'How SaveNest Works',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 60),
              Wrap(
                spacing: 40,
                runSpacing: 40,
                alignment: WrapAlignment.center,
                children: [
                  _stepItem(
                    '1. Enter Details',
                    'Tell us a bit about your current spend and usage habits.',
                    Icons.edit_note,
                  ),
                  _stepItem(
                    '2. We Compare',
                    'Our engine scans 50+ providers to find better deals.',
                    Icons.analytics_outlined,
                  ),
                  _stepItem(
                    '3. Switch & Save',
                    'Switch in clicks. We handle the paperwork for you.',
                    Icons.savings_outlined,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stepItem(String title, String desc, IconData icon) {
    return SizedBox(
      width: 280,
      child: Column(
        children: [
          Icon(icon, color: AppTheme.vibrantEmerald, size: 48),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            desc,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      color: Colors.black26,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shield_moon, color: Colors.white30, size: 24),
                  SizedBox(width: 8),
                  Text(
                    'SaveNest © 2026',
                    style: TextStyle(color: Colors.white30),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _footerLink('Privacy Policy'),
                  _footerLink('Terms of Service'),
                  _footerLink('Contact Us'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _footerLink(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white30, fontSize: 12),
      ),
    );
  }
}
