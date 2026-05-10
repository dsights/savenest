import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meta_seo/meta_seo.dart';
import '../../theme/app_theme.dart';
import '../../widgets/main_navigation_bar.dart';
import '../../widgets/main_mobile_drawer.dart';
import '../blog/blog_provider.dart';
import '../blog/blog_model.dart';
import '../home/widgets/modern_footer.dart';

class KnowledgeBaseScreen extends ConsumerStatefulWidget {
  const KnowledgeBaseScreen({super.key});

  @override
  ConsumerState<KnowledgeBaseScreen> createState() => _KnowledgeBaseScreenState();
}

class _KnowledgeBaseScreenState extends ConsumerState<KnowledgeBaseScreen> {
  String _selectedCategory = 'All';

  static const _categories = ['All', 'Energy', 'Internet', 'Insurance', 'Savings', 'Solar'];

  static const _categoryIcons = {
    'All': Icons.grid_view_rounded,
    'Energy': Icons.bolt,
    'Internet': Icons.wifi,
    'Insurance': Icons.security,
    'Savings': Icons.savings,
    'Solar': Icons.wb_sunny,
  };

  static const _stateGuides = [
    {'label': 'NSW Electricity Guide', 'route': '/guides/nsw/electricity'},
    {'label': 'VIC Electricity Guide', 'route': '/guides/vic/electricity'},
    {'label': 'QLD Electricity Guide', 'route': '/guides/qld/electricity'},
    {'label': 'SA Electricity Guide', 'route': '/guides/sa/electricity'},
    {'label': 'NSW Gas Guide', 'route': '/guides/nsw/gas'},
    {'label': 'VIC Gas Guide', 'route': '/guides/vic/gas'},
  ];

  static const _comparisonGuides = [
    {'label': 'AGL vs Origin Energy', 'route': '/compare/agl-vs-origin-energy'},
    {'label': 'AGL vs Energy Australia', 'route': '/compare/agl-vs-energy-australia'},
    {'label': 'Origin vs Energy Australia', 'route': '/compare/origin-energy-vs-energy-australia'},
    {'label': 'Provider Directory', 'route': '/providers'},
  ];

  List<BlogPost> _filtered(List<BlogPost> posts) {
    if (_selectedCategory == 'All') return posts;
    return posts.where((p) => p.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    final postsAsync = ref.watch(blogPostsProvider);
    final isMobile = MediaQuery.of(context).size.width < 700;

    if (kIsWeb) {
      MetaSEO meta = MetaSEO();
      const title = 'Knowledge Base | SaveNest — Australian Utility & Finance Guides';
      const description = 'Browse all SaveNest guides, comparison articles, and expert tips on energy, internet, insurance, and saving money in Australia.';
      meta.nameContent(name: 'title', content: title);
      meta.nameContent(name: 'description', content: description);
      meta.ogTitle(ogTitle: title);
      meta.ogDescription(ogDescription: description);
      meta.propertyContent(property: 'og:url', content: 'https://savenest.au/knowledge-base');
    }

    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      endDrawer: const MainMobileDrawer(),
      body: SingleChildScrollView(
        primary: true,
        child: Column(
          children: [
            const MainNavigationBar(),
            _buildHero(context),
            _buildCategoryFilter(context, isMobile),
            postsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 80),
                child: CircularProgressIndicator(),
              ),
              error: (e, _) => const Padding(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: Text('Could not load articles.'),
              ),
              data: (posts) => _buildArticleGrid(context, _filtered(posts), isMobile),
            ),
            _buildGuidesSection(context, isMobile),
            const ModernFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.deepNavy, AppTheme.primaryBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.vibrantEmerald.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.vibrantEmerald.withOpacity(0.3)),
                ),
                child: const Text(
                  'KNOWLEDGE BASE',
                  style: TextStyle(
                    color: AppTheme.vibrantEmerald,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 2,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Guides, Comparisons & Expert Tips',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Everything you need to make smarter decisions on energy, internet, insurance, and more — written by Australian experts.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.75),
                  fontSize: 16,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter(BuildContext context, bool isMobile) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
      child: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _categories.map((cat) {
              final isSelected = _selectedCategory == cat;
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.deepNavy : Colors.transparent,
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: isSelected ? AppTheme.deepNavy : AppTheme.slate300,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _categoryIcons[cat] ?? Icons.article,
                          size: 16,
                          color: isSelected ? Colors.white : AppTheme.slate600,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          cat,
                          style: TextStyle(
                            color: isSelected ? Colors.white : AppTheme.slate600,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildArticleGrid(BuildContext context, List<BlogPost> posts, bool isMobile) {
    if (posts.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 60),
        child: Text('No articles in this category yet.'),
      );
    }

    final crossAxisCount = isMobile ? 1 : (MediaQuery.of(context).size.width < 1100 ? 2 : 3);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _selectedCategory == 'All'
                    ? 'All Articles (${posts.length})'
                    : '$_selectedCategory Articles (${posts.length})',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.deepNavy,
                ),
              ),
              const SizedBox(height: 24),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: isMobile ? 2.8 : 2.2,
                ),
                itemCount: posts.length,
                itemBuilder: (context, index) => _ArticleCard(
                  post: posts[index],
                  onTap: () => context.go('/blog/${posts[index].slug}'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGuidesSection(BuildContext context, bool isMobile) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Quick Reference Guides',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.deepNavy,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'State-specific guides and head-to-head provider comparisons.',
                style: TextStyle(color: AppTheme.slate600, fontSize: 15),
              ),
              const SizedBox(height: 36),
              isMobile
                  ? Column(
                      children: [
                        _buildGuideGroup(context, 'State Energy Guides', Icons.map_outlined, _stateGuides),
                        const SizedBox(height: 32),
                        _buildGuideGroup(context, 'Provider Comparisons', Icons.compare_arrows, _comparisonGuides),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildGuideGroup(context, 'State Energy Guides', Icons.map_outlined, _stateGuides),
                        ),
                        const SizedBox(width: 40),
                        Expanded(
                          child: _buildGuideGroup(context, 'Provider Comparisons', Icons.compare_arrows, _comparisonGuides),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGuideGroup(
    BuildContext context,
    String title,
    IconData icon,
    List<Map<String, String>> items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.vibrantEmerald.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppTheme.vibrantEmerald, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.deepNavy,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ...items.map((item) => _GuideLink(label: item['label']!, route: item['route']!)),
      ],
    );
  }
}

class _ArticleCard extends StatefulWidget {
  final BlogPost post;
  final VoidCallback onTap;

  const _ArticleCard({required this.post, required this.onTap});

  @override
  State<_ArticleCard> createState() => _ArticleCardState();
}

class _ArticleCardState extends State<_ArticleCard> {
  bool _hovered = false;

  static const _categoryColors = {
    'Energy': Color(0xFFFF7900),
    'Internet': Color(0xFF005696),
    'Insurance': Color(0xFF00A3AD),
    'Savings': Color(0xFF2E7D32),
    'Solar': Color(0xFFF9A825),
  };

  @override
  Widget build(BuildContext context) {
    final catColor = _categoryColors[widget.post.category] ?? AppTheme.deepNavy;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _hovered ? catColor.withOpacity(0.4) : AppTheme.slate300,
            ),
            boxShadow: [
              BoxShadow(
                color: _hovered ? catColor.withOpacity(0.08) : Colors.black.withOpacity(0.04),
                blurRadius: _hovered ? 20 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: catColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      widget.post.category.toUpperCase(),
                      style: TextStyle(
                        color: catColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    widget.post.date,
                    style: const TextStyle(color: AppTheme.slate600, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                widget.post.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.deepNavy,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    'Read article',
                    style: TextStyle(
                      color: catColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_forward, color: catColor, size: 14),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GuideLink extends StatefulWidget {
  final String label;
  final String route;

  const _GuideLink({required this.label, required this.route});

  @override
  State<_GuideLink> createState() => _GuideLinkState();
}

class _GuideLinkState extends State<_GuideLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => context.go(widget.route),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: _hovered ? AppTheme.vibrantEmerald.withOpacity(0.05) : AppTheme.offWhite,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _hovered ? AppTheme.vibrantEmerald.withOpacity(0.3) : AppTheme.slate300,
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.article_outlined, size: 16, color: AppTheme.vibrantEmerald),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.label,
                  style: TextStyle(
                    color: _hovered ? AppTheme.deepNavy : AppTheme.slate600,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, size: 18, color: AppTheme.slate600),
            ],
          ),
        ),
      ),
    );
  }
}
