import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─── Data Models ───────────────────────────────────────────────────────────

class MissionStatus {
  final int daysElapsed;
  final int daysRemaining;
  final int totalDays;
  final double revenueEarned;
  final double revenueTarget;
  final double revenueGap;
  final double dailyRunRateRequired;
  final double currentDailyRunRate;
  final double progressPercent;
  final String phase; // SEED / GROW / HARVEST
  final bool onTrack;

  const MissionStatus({
    required this.daysElapsed,
    required this.daysRemaining,
    required this.totalDays,
    required this.revenueEarned,
    required this.revenueTarget,
    required this.revenueGap,
    required this.dailyRunRateRequired,
    required this.currentDailyRunRate,
    required this.progressPercent,
    required this.phase,
    required this.onTrack,
  });
}

class Competitor {
  final String name;
  final int domainAuthority;
  final int estimatedMonthlyTraffic;
  final int contentPages;
  final List<String> weaknesses;
  final List<String> keywordGaps;
  final String threatLevel;

  const Competitor({
    required this.name,
    required this.domainAuthority,
    required this.estimatedMonthlyTraffic,
    required this.contentPages,
    required this.weaknesses,
    required this.keywordGaps,
    required this.threatLevel,
  });
}

class MarketSignal {
  final String signal;
  final String impact;
  final String action;
  final int windowDays;

  const MarketSignal({
    required this.signal,
    required this.impact,
    required this.action,
    required this.windowDays,
  });
}

class GrowthLever {
  final String id;
  final String name;
  final String status;
  final String currentOutput;
  final String targetOutput;
  final String revenueImpact;
  final String timeToRevenue;
  final String description;
  final bool unlocked;

  const GrowthLever({
    required this.id,
    required this.name,
    required this.status,
    required this.currentOutput,
    required this.targetOutput,
    required this.revenueImpact,
    required this.timeToRevenue,
    required this.description,
    required this.unlocked,
  });
}

class StrategicIdea {
  final String title;
  final String rationale;
  final String agent;
  final String type; // AUTO / HUMAN / AUTOMATE
  final int impactScore; // 1-10
  final int effortScore; // 1-10 (lower = easier)
  final int confidenceScore; // 1-10
  final int priorityScore; // derived: impact * confidence / effort
  final String estimatedRevenue;
  final String timeframe;

  const StrategicIdea({
    required this.title,
    required this.rationale,
    required this.agent,
    required this.type,
    required this.impactScore,
    required this.effortScore,
    required this.confidenceScore,
    required this.estimatedRevenue,
    required this.timeframe,
  }) : priorityScore = (impactScore * confidenceScore) ~/ effortScore;
}

class DailyStrategyBrief {
  final String date;
  final String phase;
  final String primaryFocus;
  final String strategicRationale;
  final String expectedImpact;
  final List<StrategicIdea> rankedIdeas;
  final Map<String, String> agentCommands;
  final List<String> risks;
  final List<MarketSignal> urgentSignals;

  const DailyStrategyBrief({
    required this.date,
    required this.phase,
    required this.primaryFocus,
    required this.strategicRationale,
    required this.expectedImpact,
    required this.rankedIdeas,
    required this.agentCommands,
    required this.risks,
    required this.urgentSignals,
  });
}

// ─── Strategy Engine ───────────────────────────────────────────────────────

class CeoStrategyEngine {
  final Map<String, dynamic> _data;

  CeoStrategyEngine(this._data);

  static Future<CeoStrategyEngine> load() async {
    final json = await rootBundle.loadString('assets/data/ceo_metrics.json');
    return CeoStrategyEngine(jsonDecode(json) as Map<String, dynamic>);
  }

  // ── Mission Math ──────────────────────────────────────────────────────────

  MissionStatus computeMissionStatus() {
    final mission = _data['mission'] as Map<String, dynamic>;
    final metrics = _data['current_metrics'] as Map<String, dynamic>;

    final start = DateTime.parse(mission['start_date'] as String);
    final end = DateTime.parse(mission['end_date'] as String);
    final now = DateTime.now();

    final totalDays = end.difference(start).inDays;
    final daysElapsed = now.difference(start).inDays.clamp(0, totalDays);
    final daysRemaining = (totalDays - daysElapsed).clamp(0, totalDays);

    final target = (mission['target_revenue'] as num).toDouble();
    final earned = (metrics['revenue'] as num).toDouble();
    final gap = target - earned;

    final dailyRequired = daysRemaining > 0 ? gap / daysRemaining : 0.0;
    final currentDailyRate = daysElapsed > 0 ? earned / daysElapsed : 0.0;
    final progress = (earned / target * 100).clamp(0.0, 100.0);

    String phase;
    if (daysElapsed <= 30) {
      phase = 'SEED';
    } else if (daysElapsed <= 60) {
      phase = 'GROW';
    } else {
      phase = 'HARVEST';
    }

    return MissionStatus(
      daysElapsed: daysElapsed,
      daysRemaining: daysRemaining,
      totalDays: totalDays,
      revenueEarned: earned,
      revenueTarget: target,
      revenueGap: gap,
      dailyRunRateRequired: dailyRequired,
      currentDailyRunRate: currentDailyRate,
      progressPercent: progress,
      phase: phase,
      onTrack: currentDailyRate >= dailyRequired * 0.7,
    );
  }

  // ── Competitor Intelligence ───────────────────────────────────────────────

  List<Competitor> getCompetitorIntelligence() {
    final raw = _data['competitors'] as List<dynamic>;
    return raw.map((c) {
      final m = c as Map<String, dynamic>;
      return Competitor(
        name: m['name'] as String,
        domainAuthority: (m['domain_authority'] as num).toInt(),
        estimatedMonthlyTraffic: (m['estimated_monthly_traffic'] as num).toInt(),
        contentPages: (m['content_pages'] as num).toInt(),
        weaknesses: (m['weaknesses'] as List).cast<String>(),
        keywordGaps: (m['keyword_gaps'] as List).cast<String>(),
        threatLevel: m['threat_level'] as String,
      );
    }).toList()
      ..sort((a, b) {
        const order = {'HIGH': 0, 'MEDIUM': 1, 'LOW': 2};
        return (order[a.threatLevel] ?? 3).compareTo(order[b.threatLevel] ?? 3);
      });
  }

  // ── Market Signals ────────────────────────────────────────────────────────

  List<MarketSignal> getUrgentSignals({int withinDays = 30}) {
    final raw = _data['market_signals'] as List<dynamic>;
    return raw
        .map((s) {
          final m = s as Map<String, dynamic>;
          return MarketSignal(
            signal: m['signal'] as String,
            impact: m['impact'] as String,
            action: m['action'] as String,
            windowDays: (m['window_days'] as num).toInt(),
          );
        })
        .where((s) => s.windowDays <= withinDays)
        .toList()
      ..sort((a, b) {
        const order = {'HIGH': 0, 'MEDIUM': 1, 'LOW': 2};
        return (order[a.impact] ?? 3).compareTo(order[b.impact] ?? 3);
      });
  }

  // ── Growth Levers ─────────────────────────────────────────────────────────

  List<GrowthLever> getGrowthLevers() {
    final raw = _data['growth_levers'] as List<dynamic>;
    return raw.map((l) {
      final m = l as Map<String, dynamic>;
      return GrowthLever(
        id: m['id'] as String,
        name: m['name'] as String,
        status: m['status'] as String,
        currentOutput: m['current_output'] as String,
        targetOutput: m['target_output'] as String,
        revenueImpact: m['revenue_impact'] as String,
        timeToRevenue: m['time_to_revenue'] as String,
        description: m['description'] as String,
        unlocked: m['unlocked'] as bool,
      );
    }).toList();
  }

  // ── Idea Engine ───────────────────────────────────────────────────────────

  List<StrategicIdea> generateRankedIdeas(MissionStatus status) {
    final ideas = _buildIdeaPool(status);
    ideas.sort((a, b) => b.priorityScore.compareTo(a.priorityScore));
    return ideas;
  }

  List<StrategicIdea> _buildIdeaPool(MissionStatus status) {
    final metrics = _data['current_metrics'] as Map<String, dynamic>;
    final blogPosts = (metrics['blog_posts'] as num).toInt();
    final suburbPages = (metrics['suburb_pages'] as num).toInt();

    final ideas = <StrategicIdea>[];

    // ── Always-on ideas ───────────────────────────────────────────────────
    ideas.add(const StrategicIdea(
      title: 'Expand Suburb Pages to 500 (Programmatic SEO at Scale)',
      rationale: '15,000+ Australian suburbs exist. Each suburb comparison page targets "electricity [suburb]" — ultra-low competition, high commercial intent. Current 11 pages is <0.1% of the opportunity.',
      agent: 'CMO + Content Agent',
      type: 'AUTO',
      impactScore: 10,
      effortScore: 3,
      confidenceScore: 9,
      estimatedRevenue: '\$50,000–\$200,000 incremental annually',
      timeframe: '14–30 days to index',
    ));

    ideas.add(const StrategicIdea(
      title: 'Build Email Lead Capture — "Free Bill Audit" Lead Magnet',
      rationale: 'Email converts 3–10x better than cold organic traffic. A "Free Bill Audit" offer (upload your bill, get the 3 cheapest providers in 60 seconds) captures high-intent leads and enables a 5-email nurture sequence leading to a switch.',
      agent: 'CRO + Automation Agent',
      type: 'HUMAN',
      impactScore: 9,
      effortScore: 5,
      confidenceScore: 8,
      estimatedRevenue: '\$80,000–\$150,000 from email channel',
      timeframe: '7 days to build, 30 days to monetise',
    ));

    ideas.add(const StrategicIdea(
      title: 'Promote Concierge Service — Drive Leads to High-Value \$250 Commissions',
      rationale: 'The Concierge screen exists and is fully built but gets ZERO traffic. A concierge commission is \$250 vs \$85 standard. Just 400 concierge conversions = \$100,000. Add "Talk to a Switch Expert" CTAs across all high-traffic pages.',
      agent: 'CRO Agent',
      type: 'AUTO',
      impactScore: 9,
      effortScore: 2,
      confidenceScore: 9,
      estimatedRevenue: '\$50,000–\$100,000',
      timeframe: '1–3 days impact',
    ));

    ideas.add(const StrategicIdea(
      title: 'Publish "Electricity Price by Suburb" Original Data Report',
      rationale: 'Original data journalism earns backlinks from news sites (The Guardian, ABC, news.com.au). A report ranking "most expensive suburbs for electricity in Australia" has viral and PR potential. 10 good backlinks = +10 DA = top 3 rankings for primary keywords.',
      agent: 'CMO + Content Agent',
      type: 'HUMAN',
      impactScore: 8,
      effortScore: 6,
      confidenceScore: 7,
      estimatedRevenue: 'Indirect — domain authority boost worth \$200,000+ in organic traffic value',
      timeframe: '14 days to produce, 30 days for coverage',
    ));

    ideas.add(const StrategicIdea(
      title: 'Target "NSW DMO July 2026 Price Change" — Pre-Event Content',
      rationale: 'The NSW Default Market Offer resets on July 1. Search volume for "electricity price increase July 2026" will spike 400% in June. Publishing this content NOW captures early rankings before the spike.',
      agent: 'Content Agent',
      type: 'AUTO',
      impactScore: 8,
      effortScore: 2,
      confidenceScore: 9,
      estimatedRevenue: '\$15,000–\$40,000 from event spike traffic',
      timeframe: 'Publish now, peak impact in 60 days',
    ));

    ideas.add(const StrategicIdea(
      title: 'Add 15 More Provider vs. Provider Comparison Pages',
      rationale: 'AGL vs Origin is the most-searched comparison. But there are 15+ other "vs" queries: Origin vs EnergyAustralia, AGL vs Red Energy, EnergyAustralia vs Alinta, etc. Each is a direct-intent keyword. Competitors have most — we have 2.',
      agent: 'Content Agent',
      type: 'AUTO',
      impactScore: 7,
      effortScore: 3,
      confidenceScore: 9,
      estimatedRevenue: '\$20,000–\$60,000 from comparison traffic',
      timeframe: '7–21 days to rank',
    ));

    ideas.add(const StrategicIdea(
      title: 'Launch Moving House Email Flow — Target AusPost Change-of-Address Data',
      rationale: '200,000+ Australian households move every month. Moving house is the #1 trigger for energy switching. Partner with moving platforms (hipages, ServiceSeeking) or target "connect electricity new address" keywords for high-intent capture.',
      agent: 'Automation Agent',
      type: 'HUMAN',
      impactScore: 8,
      effortScore: 7,
      confidenceScore: 7,
      estimatedRevenue: '\$30,000–\$80,000 from moving segment',
      timeframe: '21 days setup, 45 days to revenue',
    ));

    ideas.add(const StrategicIdea(
      title: 'Affiliate Expansion — Add Amber, Powershop, Simply Energy Programs',
      rationale: 'Amber Electric and Powershop are fast-growing providers offering competitive commissions. They are also underrepresented on competitor comparison sites — first-mover advantage. Adds 3 new revenue streams.',
      agent: 'COO Agent',
      type: 'HUMAN',
      impactScore: 7,
      effortScore: 3,
      confidenceScore: 8,
      estimatedRevenue: '\$25,000–\$60,000 additional revenue',
      timeframe: '7–14 days to go live',
    ));

    if (suburbPages < 100) {
      ideas.add(const StrategicIdea(
        title: 'Auto-Generate 100 Suburb Pages (QLD and WA expansion)',
        rationale: 'QLD and WA are underserved by competitors for suburb-level content. Gold Coast, Sunshine Coast, Cairns, Fremantle, Joondalup — all have search volume with minimal competition. First to publish wins.',
        agent: 'CMO Agent',
        type: 'AUTO',
        impactScore: 9,
        effortScore: 2,
        confidenceScore: 9,
        estimatedRevenue: '\$40,000–\$120,000 incremental',
        timeframe: '7 days to publish, 21–45 days to index',
      ));
    }

    if (blogPosts < 50) {
      ideas.add(const StrategicIdea(
        title: 'Accelerate Content to 10 Posts/Day for 2 Weeks',
        rationale: 'Content velocity compounds. Google rewards sites with sustained publishing momentum. A 2-week sprint to 50 posts creates the critical mass needed for topical authority signals.',
        agent: 'Content Agent',
        type: 'AUTO',
        impactScore: 8,
        effortScore: 4,
        confidenceScore: 8,
        estimatedRevenue: 'Foundation — enables \$500,000+ organic revenue',
        timeframe: 'Ongoing — 2-week sprint',
      ));
    }

    ideas.add(const StrategicIdea(
      title: 'Build "Energy Price Alert" Tool — Email Subscription Trigger',
      rationale: 'A free price alert tool (enter your postcode, we email when a cheaper plan appears) is a legitimate email capture mechanism with high retention. Users who set alerts convert at 12–18% vs 2–3% cold.',
      agent: 'CRO + Automation Agent',
      type: 'HUMAN',
      impactScore: 8,
      effortScore: 6,
      confidenceScore: 7,
      estimatedRevenue: '\$60,000–\$150,000 from alert-triggered switches',
      timeframe: '14 days to build, 30 days to monetise',
    ));

    ideas.add(const StrategicIdea(
      title: 'Reddit & Facebook Energy Groups — Community Authority Building',
      rationale: 'r/AusFinance, r/australia, and "Australian Energy Savers" Facebook groups have 500k+ members actively asking energy questions. Answering questions with SaveNest links (where relevant) drives high-intent referral traffic with zero cost.',
      agent: 'Customer Agent',
      type: 'HUMAN',
      impactScore: 5,
      effortScore: 2,
      confidenceScore: 7,
      estimatedRevenue: '\$5,000–\$20,000 referral traffic',
      timeframe: '0 days start, ongoing',
    ));

    ideas.add(const StrategicIdea(
      title: 'Guest Post on 5 Australian Finance / Lifestyle Blogs',
      rationale: 'Guest posts on Moneysmart-adjacent blogs, personal finance sites (e.g., The Broke Generation, Pearler blog) and news sites earn backlinks + referral traffic. Target DA 40+ sites for maximum domain authority boost.',
      agent: 'CMO Agent',
      type: 'HUMAN',
      impactScore: 6,
      effortScore: 7,
      confidenceScore: 6,
      estimatedRevenue: 'Indirect — each backlink worth \$5,000–\$20,000 in SEO value',
      timeframe: '21–45 days for placement',
    ));

    ideas.sort((a, b) => b.priorityScore.compareTo(a.priorityScore));
    return ideas;
  }

  // ── Daily Brief ───────────────────────────────────────────────────────────

  DailyStrategyBrief generateDailyBrief() {
    final status = computeMissionStatus();
    final ideas = generateRankedIdeas(status);
    final signals = getUrgentSignals(withinDays: 45);
    final metrics = _data['current_metrics'] as Map<String, dynamic>;

    final focus = _deriveStrategicFocus(status, metrics);
    final rationale = _deriveRationale(status, metrics);
    final impact = _deriveExpectedImpact(status, metrics);
    final agentCommands = _deriveAgentCommands(status, metrics);
    final risks = _deriveRisks(status, metrics);

    return DailyStrategyBrief(
      date: _formatDate(DateTime.now()),
      phase: status.phase,
      primaryFocus: focus,
      strategicRationale: rationale,
      expectedImpact: impact,
      rankedIdeas: ideas.take(8).toList(),
      agentCommands: agentCommands,
      risks: risks,
      urgentSignals: signals,
    );
  }

  String _deriveStrategicFocus(MissionStatus status, Map<String, dynamic> metrics) {
    final blogPosts = (metrics['blog_posts'] as num).toInt();
    final suburbPages = (metrics['suburb_pages'] as num).toInt();
    final revenue = (metrics['revenue'] as num).toDouble();

    if (status.phase == 'SEED') {
      if (blogPosts < 50) return 'SEO CONTENT VELOCITY — Build topical authority with 50+ posts before competing pages index';
      if (suburbPages < 100) return 'PROGRAMMATIC SCALE — Deploy 100+ suburb pages to dominate long-tail local keywords';
      return 'CONVERSION FOUNDATION — Activate email capture and concierge CTAs to monetise growing traffic';
    }

    if (status.phase == 'GROW') {
      if (revenue < 50000) return 'CONVERSION ACCELERATION — Maximise revenue from existing traffic before traffic peaks';
      return 'AUTHORITY BUILDING — Data journalism and backlinks to push primary keywords to page 1';
    }

    return 'HARVEST — Focus on conversion rate and affiliate commission maximisation for final sprint';
  }

  String _deriveRationale(MissionStatus status, Map<String, dynamic> metrics) {
    final blogPosts = (metrics['blog_posts'] as num).toInt();
    final suburbPages = (metrics['suburb_pages'] as num).toInt();
    final revenue = (metrics['revenue'] as num).toDouble();
    final dailyRequired = status.dailyRunRateRequired;

    if (status.daysElapsed < 5) {
      return 'Day ${status.daysElapsed + 1} of 90. We are in the SEED phase — the decisions made in the first 30 days determine whether we reach \$1M. At \$${dailyRequired.toStringAsFixed(0)}/day required, every content piece not published today is revenue left on the table. SEO compounds — content published today earns traffic for 3+ years. The priority is velocity.';
    }

    if (revenue == 0) {
      return 'Zero revenue today means SEO content is still indexing. This is expected in days 1–30. The key leading indicator to watch is Google Search Console impressions — any impression means Google has found the page. Publishing more content now ensures we have a large indexed footprint when affiliate traffic arrives.';
    }

    return 'We need \$${dailyRequired.toStringAsFixed(0)}/day to hit \$1M. With ${status.daysRemaining} days left, every decision must be evaluated against this number. Highest-ROI action: maximise the number of high-intent visitors hitting our comparison tool and clicking through to providers.';
  }

  String _deriveExpectedImpact(MissionStatus status, Map<String, dynamic> metrics) {
    final blogPosts = (metrics['blog_posts'] as num).toInt();
    final suburbPages = (metrics['suburb_pages'] as num).toInt();

    if (blogPosts < 30) {
      return 'Each new high-intent blog post: +50–200 monthly organic sessions once indexed (14–30 day lag). At 2.5% CTR to comparison tool × 3% conversion × \$85 commission = ~\$3–\$13 monthly recurring per post. 100 posts = \$300–\$1,300/month passive recurring.';
    }

    if (suburbPages < 200) {
      return 'Each suburb page targets "electricity [suburb]" — avg 80–400 monthly searches, <10 competing pages. At 30% CTR (we\'d be top result) × 3% switch × \$85 = \$6–\$31/month per suburb page. 500 suburb pages = \$3,000–\$15,500/month.';
    }

    return 'With established content base, focus shifts to conversion rate. A 1% improvement in CRO across all traffic multiplies revenue by the same amount as doubling organic sessions — but 10x faster to implement.';
  }

  Map<String, String> _deriveAgentCommands(MissionStatus status, Map<String, dynamic> metrics) {
    final blogPosts = (metrics['blog_posts'] as num).toInt();
    final suburbPages = (metrics['suburb_pages'] as num).toInt();

    return {
      'CMO': blogPosts < 50
          ? 'Target 5 new blog posts today. Priority keywords: "electricity bill calculator [state]", "[provider] review 2026", "cheapest electricity [city] 2026". Use Google Autocomplete for QLD + SA gaps.'
          : 'Keyword gap analysis vs Finder and Canstar Blue. Identify top 20 pages they rank for that we don\'t have yet.',
      'Content': suburbPages < 200
          ? 'Generate suburb guide data for 20 new suburbs: Gold Coast, Geelong, Toowoomba, Cairns, Darwin, Hobart, Townsville, Wollongong, Newcastle, Ballarat, Bendigo, Launceston, Rockhampton, Bundaberg, Mackay, Albury, Shepparton, Tamworth, Coffs Harbour, Wagga Wagga. Add to suburb database.'
          : 'Write 5 blog posts: NSW DMO July price change preview, EOFY energy review checklist, Origin Energy 2026 review, Simply Energy review, best electricity provider Queensland.',
      'CRO': 'Add "Talk to a Switch Expert (Free)" concierge CTA button to the top 5 high-traffic pages. Expected uplift: +0.5–1.5% conversion rate = +\$15,000–\$45,000 annually at current traffic.',
      'COO': 'Verify all existing affiliate links are active and tracking. Identify which providers have the highest commission rates — prioritise their placement in comparison results. Target: add Amber Electric and Powershop affiliate programs.',
      'Automation': 'Design email nurture sequence: 5 emails over 14 days for leads who clicked Compare but didn\'t switch. Subject lines: Day 1 "Your energy comparison results", Day 3 "One more thing about your bill", Day 7 "Last chance: prices may change soon".',
      'Customer': 'Monitor r/AusFinance and r/australia for energy questions. Reply with SaveNest link where genuinely helpful. Also create FAQ content for top 10 questions from Google\'s People Also Ask on energy comparison queries.',
    };
  }

  List<String> _deriveRisks(MissionStatus status, Map<String, dynamic> metrics) {
    final risks = <String>[];
    final blogPosts = (metrics['blog_posts'] as num).toInt();
    final revenue = (metrics['revenue'] as num).toDouble();
    final daysElapsed = status.daysElapsed;

    if (blogPosts < 30) {
      risks.add('LOW CONTENT VELOCITY: At current rate, we will have <100 posts by Day 30. Minimum viable for topical authority is 50+ posts. Risk: Google does not establish us as an authoritative site in the energy comparison niche.');
    }

    if (revenue == 0 && daysElapsed > 14) {
      risks.add('ZERO REVENUE AFTER 2 WEEKS: Suggests no affiliate links are active or tracking is broken. URGENT: Verify all "Go to Site" buttons have working affiliate tracking IDs before another click is lost.');
    }

    if ((metrics['email_subscribers'] as num).toInt() == 0) {
      risks.add('NO EMAIL LIST: 100% traffic-dependent revenue is fragile. One Google algorithm update can eliminate all revenue. Building an email list is the single most important risk mitigation action.');
    }

    if ((metrics['backlinks'] as num).toInt() < 10) {
      risks.add('NO BACKLINKS: Without inbound links, primary keywords (high-volume "energy comparison australia") will not rank. We will only get traffic from long-tail terms. Limit to \$150,000–\$250,000 potential without DA growth.');
    }

    risks.add('COMPETITOR CONTENT GAP: Finder and Canstar Blue have 1,000+ energy pages each. We have 939 total. We need 5x more topical coverage to match their breadth and compete for high-volume head terms.');

    if (daysElapsed > 60 && revenue < 500000) {
      risks.add('PACE ALERT: With ${status.daysRemaining} days left and \$${(status.revenueGap / 1000).toStringAsFixed(0)}k gap remaining, the daily target of \$${status.dailyRunRateRequired.toStringAsFixed(0)} requires aggressive conversion optimisation, not just content publishing.');
    }

    return risks;
  }

  String _formatDate(DateTime dt) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }
}

// ─── Providers ─────────────────────────────────────────────────────────────

final ceoEngineProvider = FutureProvider<CeoStrategyEngine>((ref) async {
  return CeoStrategyEngine.load();
});

final missionStatusProvider = FutureProvider<MissionStatus>((ref) async {
  final engine = await ref.watch(ceoEngineProvider.future);
  return engine.computeMissionStatus();
});

final dailyBriefProvider = FutureProvider<DailyStrategyBrief>((ref) async {
  final engine = await ref.watch(ceoEngineProvider.future);
  return engine.generateDailyBrief();
});

final competitorIntelProvider = FutureProvider<List<Competitor>>((ref) async {
  final engine = await ref.watch(ceoEngineProvider.future);
  return engine.getCompetitorIntelligence();
});

final growthLeversProvider = FutureProvider<List<GrowthLever>>((ref) async {
  final engine = await ref.watch(ceoEngineProvider.future);
  return engine.getGrowthLevers();
});
