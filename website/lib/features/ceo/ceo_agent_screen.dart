import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../widgets/main_navigation_bar.dart';
import '../../widgets/main_mobile_drawer.dart';
import '../home/widgets/modern_footer.dart';
import 'ceo_strategy_engine.dart';

class CeoAgentScreen extends ConsumerStatefulWidget {
  const CeoAgentScreen({super.key});

  @override
  ConsumerState<CeoAgentScreen> createState() => _CeoAgentScreenState();
}

class _CeoAgentScreenState extends ConsumerState<CeoAgentScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final missionAsync = ref.watch(missionStatusProvider);
    final briefAsync = ref.watch(dailyBriefProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF050F1C),
      endDrawer: const MainMobileDrawer(),
      body: Column(
        children: [
          const MainNavigationBar(),
          Expanded(
            child: missionAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.vibrantEmerald)),
              error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.white))),
              data: (mission) => _buildLayout(context, mission, briefAsync),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLayout(BuildContext context, MissionStatus mission, AsyncValue<DailyStrategyBrief> briefAsync) {
    return SingleChildScrollView(
      primary: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMissionControl(context, mission),
          _buildTabBar(),
          _buildTabContent(context, mission, briefAsync),
          const ModernFooter(),
        ],
      ),
    );
  }

  // ── Mission Control Header ────────────────────────────────────────────────

  Widget _buildMissionControl(BuildContext context, MissionStatus mission) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF050F1C), Color(0xFF0A1F38)],
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.vibrantEmerald.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppTheme.vibrantEmerald.withOpacity(0.4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppTheme.vibrantEmerald, shape: BoxShape.circle)),
                          const SizedBox(width: 8),
                          const Text('CEO AGENT — LIVE', style: TextStyle(color: AppTheme.vibrantEmerald, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.4)),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Phase: ${mission.phase}',
                      style: TextStyle(
                        color: mission.phase == 'SEED' ? Colors.blue.shade300 : mission.phase == 'GROW' ? Colors.orange.shade300 : Colors.green.shade300,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                const Text(
                  'SaveNest \$1M Mission',
                  style: TextStyle(color: Colors.white70, fontSize: 14, letterSpacing: 2),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Mission Control',
                  style: TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),

                // KPI Cards Row
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _buildKpiCard(
                      'Days Remaining',
                      '${mission.daysRemaining}',
                      '/ ${mission.totalDays} days',
                      Icons.timer_outlined,
                      mission.daysRemaining < 30 ? Colors.red.shade400 : Colors.orange.shade300,
                    ),
                    _buildKpiCard(
                      'Revenue Gap',
                      '\$${_formatNum(mission.revenueGap)}',
                      'to \$1M target',
                      Icons.trending_up,
                      Colors.white,
                    ),
                    _buildKpiCard(
                      'Daily Target',
                      '\$${_formatNum(mission.dailyRunRateRequired)}',
                      'per day required',
                      Icons.bolt,
                      AppTheme.vibrantEmerald,
                    ),
                    _buildKpiCard(
                      'Current Run Rate',
                      '\$${_formatNum(mission.currentDailyRunRate)}',
                      'per day earned',
                      Icons.show_chart,
                      mission.onTrack ? Colors.green.shade400 : Colors.red.shade400,
                    ),
                    _buildKpiCard(
                      'Revenue Earned',
                      '\$${_formatNum(mission.revenueEarned)}',
                      '${mission.progressPercent.toStringAsFixed(1)}% of target',
                      Icons.account_balance_wallet_outlined,
                      Colors.white70,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Progress Bar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Revenue Progress: ${mission.progressPercent.toStringAsFixed(2)}%',
                          style: const TextStyle(color: Colors.white60, fontSize: 13),
                        ),
                        Text(
                          'Day ${mission.daysElapsed} of ${mission.totalDays}',
                          style: const TextStyle(color: Colors.white60, fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Stack(
                        children: [
                          Container(height: 8, color: Colors.white10),
                          FractionallySizedBox(
                            widthFactor: (mission.progressPercent / 100).clamp(0.0, 1.0),
                            child: Container(
                              height: 8,
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [AppTheme.vibrantEmerald, AppTheme.primaryBlue],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKpiCard(String label, String value, String sub, IconData icon, Color color) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 14),
          Text(value, style: TextStyle(color: color, fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
          Text(sub, style: const TextStyle(color: Colors.white38, fontSize: 11)),
        ],
      ),
    );
  }

  // ── Tab Bar ───────────────────────────────────────────────────────────────

  Widget _buildTabBar() {
    return Container(
      color: const Color(0xFF0A1F38),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: AppTheme.vibrantEmerald,
            unselectedLabelColor: Colors.white38,
            indicatorColor: AppTheme.vibrantEmerald,
            indicatorSize: TabBarIndicatorSize.label,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5),
            tabs: const [
              Tab(text: 'DAILY BRIEF'),
              Tab(text: 'GROWTH IDEAS'),
              Tab(text: 'COMPETITOR INTEL'),
              Tab(text: 'GROWTH LEVERS'),
              Tab(text: 'AGENT COMMANDS'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(BuildContext context, MissionStatus mission, AsyncValue<DailyStrategyBrief> briefAsync) {
    return briefAsync.when(
      loading: () => const SizedBox(height: 300, child: Center(child: CircularProgressIndicator(color: AppTheme.vibrantEmerald))),
      error: (e, _) => SizedBox(height: 300, child: Center(child: Text('Error: $e', style: const TextStyle(color: Colors.white60)))),
      data: (brief) => SizedBox(
        child: [
          _buildDailyBriefTab(context, brief, mission),
          _buildIdeasTab(context, brief),
          _buildCompetitorTab(context),
          _buildLeversTab(context),
          _buildAgentCommandsTab(context, brief),
        ][_tabController.index],
      ),
    );
  }

  // ── Tab 1: Daily Brief ────────────────────────────────────────────────────

  Widget _buildDailyBriefTab(BuildContext context, DailyStrategyBrief brief, MissionStatus mission) {
    return Container(
      color: const Color(0xFF050F1C),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'STRATEGIC BRIEF — ${brief.date.toUpperCase()}',
                            style: const TextStyle(color: Colors.white38, fontSize: 11, letterSpacing: 2),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            brief.primaryFocus,
                            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, height: 1.3),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Rationale
                _buildDarkCard(
                  icon: Icons.psychology_outlined,
                  iconColor: AppTheme.vibrantEmerald,
                  title: 'CEO Rationale',
                  child: Text(brief.strategicRationale, style: const TextStyle(color: Colors.white70, fontSize: 15, height: 1.7)),
                ),
                const SizedBox(height: 16),

                // Expected Impact
                _buildDarkCard(
                  icon: Icons.bolt,
                  iconColor: Colors.orange.shade400,
                  title: 'Expected Revenue Impact',
                  child: Text(brief.expectedImpact, style: const TextStyle(color: Colors.white70, fontSize: 15, height: 1.7)),
                ),
                const SizedBox(height: 24),

                // Urgent Signals
                if (brief.urgentSignals.isNotEmpty) ...[
                  _buildSectionLabel('URGENT MARKET SIGNALS'),
                  const SizedBox(height: 12),
                  ...brief.urgentSignals.map((s) => _buildSignalCard(s)),
                  const SizedBox(height: 24),
                ],

                // Risks
                _buildSectionLabel('RISK RADAR'),
                const SizedBox(height: 12),
                ...brief.risks.map((r) => _buildRiskCard(r)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignalCard(MarketSignal signal) {
    final color = signal.impact == 'HIGH' ? Colors.red.shade400 : Colors.orange.shade400;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
            child: Text(signal.impact, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(signal.signal, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 6),
                Text(signal.action, style: const TextStyle(color: Colors.white60, fontSize: 13, height: 1.5)),
                const SizedBox(height: 4),
                Text('Window: ${signal.windowDays} days', style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskCard(String risk) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 18),
          const SizedBox(width: 12),
          Expanded(child: Text(risk, style: const TextStyle(color: Colors.white60, fontSize: 13, height: 1.6))),
        ],
      ),
    );
  }

  // ── Tab 2: Growth Ideas ───────────────────────────────────────────────────

  Widget _buildIdeasTab(BuildContext context, DailyStrategyBrief brief) {
    return Container(
      color: const Color(0xFF050F1C),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionLabel('RANKED GROWTH IDEAS — SORTED BY PRIORITY SCORE (IMPACT × CONFIDENCE ÷ EFFORT)'),
                const SizedBox(height: 20),
                ...brief.rankedIdeas.asMap().entries.map((entry) => _buildIdeaCard(entry.key + 1, entry.value)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIdeaCard(int rank, StrategicIdea idea) {
    final typeColor = idea.type == 'AUTO' ? AppTheme.vibrantEmerald : idea.type == 'HUMAN' ? Colors.orange.shade400 : Colors.blue.shade400;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Rank badge
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: rank <= 3 ? AppTheme.vibrantEmerald.withOpacity(0.2) : Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text('#$rank', style: TextStyle(color: rank <= 3 ? AppTheme.vibrantEmerald : Colors.white38, fontWeight: FontWeight.bold, fontSize: 14)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(idea.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: typeColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(idea.type, style: TextStyle(color: typeColor, fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(idea.rationale, style: const TextStyle(color: Colors.white54, fontSize: 13, height: 1.6)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _buildScorePill('Priority', '${idea.priorityScore}', Colors.white),
              _buildScorePill('Impact', '${idea.impactScore}/10', AppTheme.vibrantEmerald),
              _buildScorePill('Effort', '${idea.effortScore}/10', Colors.orange.shade400),
              _buildScorePill('Confidence', '${idea.confidenceScore}/10', Colors.blue.shade300),
              _buildScorePill('Agent', idea.agent, Colors.purple.shade300),
              _buildScorePill('Revenue', idea.estimatedRevenue, Colors.green.shade400),
              _buildScorePill('Timeframe', idea.timeframe, Colors.white38),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScorePill(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(text: '$label: ', style: const TextStyle(color: Colors.white38, fontSize: 11)),
            TextSpan(text: value, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // ── Tab 3: Competitor Intel ───────────────────────────────────────────────

  Widget _buildCompetitorTab(BuildContext context) {
    final competitorsAsync = ref.watch(competitorIntelProvider);
    return Container(
      color: const Color(0xFF050F1C),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: competitorsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.vibrantEmerald)),
              error: (e, _) => Text('Error: $e', style: const TextStyle(color: Colors.white60)),
              data: (competitors) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionLabel('COMPETITIVE RADAR — THREAT ASSESSMENT & GAP ANALYSIS'),
                  const SizedBox(height: 8),
                  const Text(
                    'Our edge: out-target (long-tail), out-educate (depth), out-convert (simplicity). We cannot out-spend — so we must out-think.',
                    style: TextStyle(color: Colors.white38, fontSize: 13, height: 1.6),
                  ),
                  const SizedBox(height: 24),
                  ...competitors.map((c) => _buildCompetitorCard(c)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompetitorCard(Competitor c) {
    final threatColor = c.threatLevel == 'HIGH' ? Colors.red.shade400 : c.threatLevel == 'MEDIUM' ? Colors.orange.shade400 : Colors.green.shade400;
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: threatColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(c.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: threatColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('${c.threatLevel} THREAT', style: TextStyle(color: threatColor, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _buildScorePill('DA', '${c.domainAuthority}', Colors.white70),
              _buildScorePill('Monthly Traffic', '${_formatNum(c.estimatedMonthlyTraffic.toDouble())}', Colors.white70),
              _buildScorePill('Content Pages', '${c.contentPages}', Colors.white70),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('WEAKNESSES WE CAN EXPLOIT', style: TextStyle(color: Colors.orange, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    const SizedBox(height: 8),
                    ...c.weaknesses.map((w) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('→ ', style: TextStyle(color: AppTheme.vibrantEmerald)),
                          Expanded(child: Text(w, style: const TextStyle(color: Colors.white54, fontSize: 13))),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('KEYWORD GAPS TO CAPTURE', style: TextStyle(color: AppTheme.vibrantEmerald, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    const SizedBox(height: 8),
                    ...c.keywordGaps.map((k) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('✦ ', style: TextStyle(color: AppTheme.vibrantEmerald, fontSize: 11)),
                          Expanded(child: Text('"$k"', style: const TextStyle(color: Colors.white54, fontSize: 13))),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Tab 4: Growth Levers ──────────────────────────────────────────────────

  Widget _buildLeversTab(BuildContext context) {
    final leversAsync = ref.watch(growthLeversProvider);
    return Container(
      color: const Color(0xFF050F1C),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: leversAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.vibrantEmerald)),
              error: (e, _) => Text('Error: $e', style: const TextStyle(color: Colors.white60)),
              data: (levers) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionLabel('REVENUE GROWTH LEVERS — STATUS DASHBOARD'),
                  const SizedBox(height: 8),
                  const Text(
                    'Each lever is a distinct revenue engine. The CEO Agent activates and scales levers in order of ROI.',
                    style: TextStyle(color: Colors.white38, fontSize: 13),
                  ),
                  const SizedBox(height: 24),
                  ...levers.map((l) => _buildLeverCard(l)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeverCard(GrowthLever lever) {
    Color statusColor;
    IconData statusIcon;
    switch (lever.status) {
      case 'ACTIVE':
        statusColor = AppTheme.vibrantEmerald;
        statusIcon = Icons.check_circle_outline;
        break;
      case 'LAUNCHED':
        statusColor = Colors.blue.shade400;
        statusIcon = Icons.rocket_launch_outlined;
        break;
      case 'PARTIAL':
      case 'BUILT_NOT_PROMOTED':
        statusColor = Colors.orange.shade400;
        statusIcon = Icons.pending_outlined;
        break;
      default:
        statusColor = Colors.white24;
        statusIcon = Icons.lock_outline;
    }

    final impactColor = lever.revenueImpact == 'VERY_HIGH'
        ? Colors.red.shade300
        : lever.revenueImpact == 'HIGH'
            ? Colors.orange.shade300
            : Colors.white54;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: lever.unlocked ? Colors.white.withOpacity(0.04) : Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: statusColor.withOpacity(0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(statusIcon, color: statusColor, size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(lever.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        lever.status.replaceAll('_', ' '),
                        style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(lever.description, style: const TextStyle(color: Colors.white38, fontSize: 13, height: 1.5)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 6,
                  children: [
                    _buildScorePill('Current', lever.currentOutput, Colors.white54),
                    _buildScorePill('Target', lever.targetOutput, Colors.white70),
                    _buildScorePill('Revenue Impact', lever.revenueImpact.replaceAll('_', ' '), impactColor),
                    _buildScorePill('Time to Revenue', lever.timeToRevenue, Colors.blue.shade300),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Tab 5: Agent Commands ─────────────────────────────────────────────────

  Widget _buildAgentCommandsTab(BuildContext context, DailyStrategyBrief brief) {
    final agentColors = {
      'CMO': Colors.blue.shade400,
      'Content': Colors.purple.shade300,
      'CRO': Colors.green.shade400,
      'COO': Colors.orange.shade400,
      'Automation': Colors.cyan.shade400,
      'Customer': Colors.pink.shade300,
    };
    final agentIcons = {
      'CMO': Icons.insights,
      'Content': Icons.edit_note,
      'CRO': Icons.shopping_cart_outlined,
      'COO': Icons.manage_search,
      'Automation': Icons.smart_toy_outlined,
      'Customer': Icons.support_agent,
    };

    return Container(
      color: const Color(0xFF050F1C),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionLabel('AGENT COMMAND BOARD — TODAY\'S ORDERS'),
                const SizedBox(height: 8),
                Text(
                  'Brief date: ${brief.date}  |  Phase: ${brief.phase}',
                  style: const TextStyle(color: Colors.white38, fontSize: 13),
                ),
                const SizedBox(height: 24),
                ...brief.agentCommands.entries.map((entry) {
                  final color = agentColors[entry.key] ?? Colors.white54;
                  final icon = agentIcons[entry.key] ?? Icons.person_outline;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: color.withOpacity(0.2)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(icon, color: color, size: 20),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text('${entry.key} Agent', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppTheme.vibrantEmerald.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text('TODAY', style: TextStyle(color: AppTheme.vibrantEmerald, fontSize: 10, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(entry.value, style: const TextStyle(color: Colors.white60, fontSize: 13, height: 1.6)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Shared Helpers ────────────────────────────────────────────────────────

  Widget _buildDarkCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 18),
              const SizedBox(width: 10),
              Text(title.toUpperCase(), style: const TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5),
    );
  }

  String _formatNum(double n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(0)}k';
    return n.toStringAsFixed(0);
  }
}
