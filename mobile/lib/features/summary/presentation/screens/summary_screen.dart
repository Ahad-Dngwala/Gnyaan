import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:gnyaan/core/theme/app_colors.dart';
import 'package:gnyaan/core/theme/app_text_styles.dart';
import 'package:gnyaan/core/constants/app_constants.dart';
import 'package:gnyaan/shared/widgets/glass_card.dart';
import 'package:gnyaan/shared/widgets/app_buttons.dart';
import '../widgets/tldr_card.dart';
import '../widgets/concept_chips.dart';
import '../widgets/insight_tile.dart';

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const _tabs = ['Summary', 'Concepts', 'Glossary', 'Insights'];

  // Demo data
  static const String _tldr =
      'The System Architecture v3 document defines a cloud-native microservices platform with a PostgreSQL + pgvector backend for semantic search, a Redis caching layer, and a React frontend served via CDN. The RAG pipeline processes documents using sliding-window chunking and cosine similarity retrieval.';

  static const List<String> _concepts = [
    'Microservices',
    'pgvector',
    'RAG Pipeline',
    'Redis Cache',
    'Cosine Similarity',
    'REST API',
    'Docker',
    'CI/CD',
    'Semantic Search',
    'CDN',
  ];

  static const List<_GlossaryItem> _glossary = [
    _GlossaryItem(
      term: 'RAG',
      definition:
          'Retrieval-Augmented Generation — a technique where relevant document chunks are retrieved and injected into an LLM prompt to ground responses in source material.',
    ),
    _GlossaryItem(
      term: 'pgvector',
      definition:
          'A PostgreSQL extension that enables storing and querying high-dimensional float vectors, used here for semantic similarity search.',
    ),
    _GlossaryItem(
      term: 'Embedding',
      definition:
          'A dense numerical vector representation of text, capturing semantic meaning so that similar texts have similar vectors.',
    ),
    _GlossaryItem(
      term: 'Cosine Similarity',
      definition:
          'A geometric measure of similarity between two vectors, computed as the cosine of the angle between them. Ranges from -1 to 1.',
    ),
  ];

  static const List<InsightModel> _insights = [
    InsightModel(
      icon: LucideIcons.zap,
      title: 'Performance Bottleneck',
      body: 'The embedding generation step is the slowest part (~2.3s / chunk). Consider batching API calls.',
      color: AppColors.warning,
    ),
    InsightModel(
      icon: LucideIcons.shieldCheck,
      title: 'Security Note',
      body: 'API keys are loaded from environment variables, which is correct. Ensure secrets are rotated every 90 days.',
      color: AppColors.success,
    ),
    InsightModel(
      icon: LucideIcons.lightbulb,
      title: 'Suggested Improvement',
      body: 'Adding a reranker model can increase retrieval precision from ~82% to ~94%.',
      color: AppColors.brand,
    ),
    InsightModel(
      icon: LucideIcons.alertTriangle,
      title: 'Missing Documentation',
      body: 'Section 4.3 references a "failover strategy" but provides no implementation details.',
      color: AppColors.error,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg800,
      body: NestedScrollView(
        physics: const BouncingScrollPhysics(),
        headerSliverBuilder: (_, __) => [
          // ── Header ──────────────────────────────────────────────────────
          SliverToBoxAdapter(child: _SummaryHeader()),
          // ── Tab bar ──────────────────────────────────────────────────────
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickyTabBarDelegate(
              TabBar(
                controller: _tabController,
                tabs: _tabs.map((t) => Tab(text: t)).toList(),
                isScrollable: false,
                labelStyle: AppTextStyles.labelLg,
                unselectedLabelStyle: AppTextStyles.labelMd,
                labelColor: AppColors.brand,
                unselectedLabelColor: AppColors.textSubtle,
                indicatorColor: AppColors.brand,
                indicatorWeight: 2,
                indicatorSize: TabBarIndicatorSize.label,
                dividerColor: AppColors.border200,
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            // ── Summary Tab ──────────────────────────────────────────────
            _SummaryTab(tldr: _tldr),
            // ── Concepts Tab ─────────────────────────────────────────────
            _ConceptsTab(concepts: _concepts),
            // ── Glossary Tab ─────────────────────────────────────────────
            _GlossaryTab(items: _glossary),
            // ── Insights Tab ─────────────────────────────────────────────
            _InsightsTab(insights: _insights),
          ],
        ),
      ),

      // ── FAB Export ───────────────────────────────────────────────────────
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: PrimaryButton(
          label: 'Export PDF',
          icon: LucideIcons.download,
          onPressed: _exportPdf,
          width: 160,
        ),
      ),
    );
  }

  void _exportPdf() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(LucideIcons.checkCircle2,
                size: 16, color: AppColors.success),
            const SizedBox(width: 10),
            Text('Export started!', style: AppTextStyles.labelMd),
          ],
        ),
        backgroundColor: AppColors.bg600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md)),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ── Summary Header ────────────────────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════════

class _SummaryHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.bg700, AppColors.bg800],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconGlassButton(
                    icon: LucideIcons.arrowLeft,
                    onPressed: () => Navigator.maybePop(context),
                    size: 40,
                    iconSize: 18,
                  ),
                  const Spacer(),
                  IconGlassButton(
                    icon: LucideIcons.share2,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Share Document (Demo)')),
                      );
                    },
                    size: 40,
                    iconSize: 18,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: AppColors.brandGradient,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.brand.withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(LucideIcons.fileText,
                    color: Colors.white, size: 24),
              )
                  .animate()
                  .scale(begin: const Offset(0.7, 0.7), curve: Curves.elasticOut),
              const SizedBox(height: 16),
              Text('System Architecture v3',
                  style: AppTextStyles.h1),
              const SizedBox(height: 4),
              Row(
                children: [
                  _MetaChip(icon: LucideIcons.fileType2, label: 'PDF'),
                  const SizedBox(width: 8),
                  _MetaChip(icon: LucideIcons.book, label: '42 pages'),
                  const SizedBox(width: 8),
                  _MetaChip(icon: LucideIcons.database, label: '186 chunks'),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.bg500,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: AppColors.iconSubtle),
          const SizedBox(width: 4),
          Text(label, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ── Tabs ─────────────────────────────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════════

class _SummaryTab extends StatelessWidget {
  const _SummaryTab({required this.tldr});
  final String tldr;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TldrCard(text: tldr),
          const SizedBox(height: 20),
          _ReadingStats(),
        ],
      ),
    );
  }
}

class _ConceptsTab extends StatelessWidget {
  const _ConceptsTab({required this.concepts});
  final List<String> concepts;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: ConceptChipsGrid(concepts: concepts),
    );
  }
}

class _GlossaryTab extends StatelessWidget {
  const _GlossaryTab({required this.items});
  final List<_GlossaryItem> items;

  @override
  Widget build(BuildContext context) {
    return AnimationLimiter(
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        itemCount: items.length,
        itemBuilder: (_, i) => AnimationConfiguration.staggeredList(
          position: i,
          duration: const Duration(milliseconds: 400),
          child: SlideAnimation(
            verticalOffset: 30,
            child: FadeInAnimation(
              child: _GlossaryTile(item: items[i]),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlossaryTile extends StatefulWidget {
  const _GlossaryTile({required this.item});
  final _GlossaryItem item;

  @override
  State<_GlossaryTile> createState() => _GlossaryTileState();
}

class _GlossaryTileState extends State<_GlossaryTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppColors.bg600,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: _expanded
                ? AppColors.brand.withOpacity(0.3)
                : AppColors.border200,
          ),
        ),
        child: AnimatedSize(
          duration: AppDurations.normal,
          curve: Curves.easeInOut,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: AppColors.brandGradient,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        widget.item.term,
                        style: AppTextStyles.labelMd.copyWith(
                            color: Colors.white, fontSize: 12),
                      ),
                    ),
                    const Spacer(),
                    AnimatedRotation(
                      turns: _expanded ? 0.5 : 0,
                      duration: AppDurations.normal,
                      child: Icon(LucideIcons.chevronDown,
                          size: 16, color: AppColors.iconSubtle),
                    ),
                  ],
                ),
                if (_expanded) ...[
                  const SizedBox(height: 10),
                  Text(
                    widget.item.definition,
                    style: AppTextStyles.bodyMd
                        .copyWith(color: AppColors.textMuted, height: 1.6),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InsightsTab extends StatelessWidget {
  const _InsightsTab({required this.insights});
  final List<InsightModel> insights;

  @override
  Widget build(BuildContext context) {
    return AnimationLimiter(
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        itemCount: insights.length,
        itemBuilder: (_, i) => AnimationConfiguration.staggeredList(
          position: i,
          duration: const Duration(milliseconds: 400),
          child: SlideAnimation(
            horizontalOffset: 30,
            child: FadeInAnimation(
              child: InsightTile(insight: insights[i]),
            ),
          ),
        ),
      ),
    );
  }
}

class _ReadingStats extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bg600,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Document Stats', style: AppTextStyles.h3),
          const SizedBox(height: 16),
          Row(
            children: [
              _StatItem(label: 'Words', value: '12,420', icon: LucideIcons.type),
              _StatItem(label: 'Read Time', value: '47 min', icon: LucideIcons.clock),
              _StatItem(label: 'Complexity', value: 'Advanced', icon: LucideIcons.graduationCap),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.label, required this.value, required this.icon});
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 18, color: AppColors.brand),
          const SizedBox(height: 6),
          Text(value,
              style: AppTextStyles.h3.copyWith(color: AppColors.text)),
          Text(label, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

// ── Sticky tab bar helper delegate ─────────────────────────────────────────────

class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  const _StickyTabBarDelegate(this.tabBar);
  final TabBar tabBar;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
          BuildContext context, double shrinkOffset, bool overlapsContent) =>
      Container(color: AppColors.bg800, child: tabBar);

  @override
  bool shouldRebuild(_StickyTabBarDelegate old) => tabBar != old.tabBar;
}

// ── Data models ────────────────────────────────────────────────────────────────

class _GlossaryItem {
  const _GlossaryItem({required this.term, required this.definition});
  final String term;
  final String definition;
}

class InsightModel {
  const InsightModel({
    required this.icon,
    required this.title,
    required this.body,
    required this.color,
  });
  final IconData icon;
  final String title;
  final String body;
  final Color color;
}
