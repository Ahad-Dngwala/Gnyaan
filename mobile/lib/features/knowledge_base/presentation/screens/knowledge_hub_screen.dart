import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:gnyaan/core/theme/app_colors.dart';
import 'package:gnyaan/core/theme/app_text_styles.dart';
import 'package:gnyaan/core/constants/app_constants.dart';
import 'package:gnyaan/shared/widgets/glass_card.dart';
import 'package:gnyaan/shared/widgets/app_buttons.dart';
import 'package:gnyaan/shared/widgets/skeleton_loaders.dart';
import '../widgets/upload_dropzone.dart';
import '../widgets/document_card.dart';
import '../widgets/stats_row.dart';

class KnowledgeHubScreen extends StatefulWidget {
  const KnowledgeHubScreen({super.key});

  @override
  State<KnowledgeHubScreen> createState() => _KnowledgeHubScreenState();
}

class _KnowledgeHubScreenState extends State<KnowledgeHubScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerGlowController;
  late ScrollController _scrollController;
  final TextEditingController _searchController = TextEditingController();
  bool _headerCompacted = false;
  bool _isSearchFocused = false;

  // Demo data
  final List<DocModel> _docs = [
    DocModel(
      id: '1',
      name: 'System Architecture v3.pdf',
      type: 'PDF',
      size: '4.2 MB',
      pages: 42,
      status: DocStatus.indexed,
      progress: 1.0,
      addedDate: '2 hours ago',
      chunks: 186,
      color: AppColors.brand,
    ),
    DocModel(
      id: '2',
      name: 'Q3 Financial Report.docx',
      type: 'DOCX',
      size: '1.8 MB',
      pages: 18,
      status: DocStatus.summarizing,
      progress: 0.62,
      addedDate: 'Just now',
      chunks: 73,
      color: AppColors.warning,
    ),
    DocModel(
      id: '3',
      name: 'Research Paper — LLMs.pdf',
      type: 'PDF',
      size: '7.1 MB',
      pages: 64,
      status: DocStatus.indexed,
      progress: 1.0,
      addedDate: 'Yesterday',
      chunks: 312,
      color: AppColors.success,
    ),
    DocModel(
      id: '4',
      name: 'Product Roadmap 2026.txt',
      type: 'TXT',
      size: '0.3 MB',
      pages: 5,
      status: DocStatus.indexed,
      progress: 1.0,
      addedDate: '3 days ago',
      chunks: 28,
      color: AppColors.accent,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _headerGlowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _scrollController = ScrollController()
      ..addListener(() {
        final compact = _scrollController.offset > 60;
        if (compact != _headerCompacted) {
          setState(() => _headerCompacted = compact);
        }
      });
  }

  @override
  void dispose() {
    _headerGlowController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.bg800,
      body: Stack(
        children: [
          // ── Background gradient nebula ──────────────────────────────────
          Positioned(
            top: -100,
            right: -60,
            child: AnimatedBuilder(
              animation: _headerGlowController,
              builder: (_, __) => Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.brand.withOpacity(
                          0.06 + _headerGlowController.value * 0.04),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 200,
            left: -80,
            child: Container(
              width: 200,
              height: 200,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Color(0x1422D3EE),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── Main scroll body ────────────────────────────────────────────
          CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── 1. Floating App Bar ────────────────────────────────────
              SliverToBoxAdapter(
                child: _AppBarSection(
                  isCompacted: _headerCompacted,
                  glowController: _headerGlowController,
                ),
              ),

              // ── 2. Search Bar ──────────────────────────────────────────
              SliverToBoxAdapter(
                child: _SearchBar(
                  controller: _searchController,
                  onFocusChange: (v) => setState(() => _isSearchFocused = v),
                  onSearch: _handleSearch,
                ),
              ),

              // ── 3. Stats Row ───────────────────────────────────────────
              SliverToBoxAdapter(
                child: StatsRow(
                  totalDocs: _docs.length,
                  indexedDocs: _docs.where((d) => d.status == DocStatus.indexed).length,
                  totalChunks: _docs.fold(0, (sum, d) => sum + d.chunks),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3, end: 0),
              ),

              // ── 4. Upload Dropzone ─────────────────────────────────────
              SliverToBoxAdapter(
                child: UploadDropzone(
                  onUpload: _handleUpload,
                ).animate().fadeIn(delay: 300.ms),
              ),

              // ── 5. Active Processing Banner ────────────────────────────
              if (_docs.any((d) => d.status == DocStatus.summarizing))
                SliverToBoxAdapter(
                  child: _ProcessingBanner(
                    doc: _docs.firstWhere((d) => d.status == DocStatus.summarizing),
                  ).animate().fadeIn(delay: 350.ms),
                ),

              // ── 6. Document Grid header ────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screenPadding, 24, AppSpacing.screenPadding, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Knowledge Vault', style: AppTextStyles.h2),
                          Text(
                            '${_docs.length} documents',
                            style: AppTextStyles.bodySm,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconGlassButton(
                            icon: LucideIcons.grid,
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Switched to Grid View (Demo)')),
                              );
                            },
                            size: 38,
                            iconSize: 16,
                          ),
                          const SizedBox(width: 8),
                          IconGlassButton(
                            icon: LucideIcons.listFilter,
                            onPressed: _showFilterSheet,
                            size: 38,
                            iconSize: 16,
                          ),
                        ],
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 400.ms),
              ),

              // ── 7. Document Cards Grid (or Empty State) ───────────────
              if (_docs.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: _EmptyState(onUpload: _handleUpload).animate().fadeIn(delay: 500.ms),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenPadding),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.78,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return AnimationConfiguration.staggeredGrid(
                          position: index,
                          duration: const Duration(milliseconds: 400),
                          columnCount: 2,
                          child: ScaleAnimation(
                            scale: 0.92,
                            child: FadeInAnimation(
                              child: DocumentCard(
                                doc: _docs[index],
                                onTap: () => _openDocument(_docs[index]),
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: _docs.length,
                    ),
                  ),
                ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          ),

          // ── Floating search sheet overlay ───────────────────────────────
          if (_isSearchFocused)
            _SearchResultsSheet(query: _searchController.text),
        ],
      ),
    );
  }

  void _handleSearch(String query) {
    if (query.trim().isEmpty) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Searching for "$query" across indexed documents...')),
    );
  }

  void _handleUpload() {
    // TODO: file_picker integration
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const _UploadProgressSheet(),
    );
  }

  void _openDocument(DocModel doc) {
    Navigator.of(context).pushNamed('/document', arguments: doc.id);
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const _FilterSheet(),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ── App Bar Section ─────────────────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════════

class _AppBarSection extends StatelessWidget {
  const _AppBarSection({
    required this.isCompacted,
    required this.glowController,
  });
  final bool isCompacted;
  final AnimationController glowController;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppDurations.normal,
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        MediaQuery.of(context).padding.top + (isCompacted ? 12 : 20),
        AppSpacing.screenPadding,
        isCompacted ? 12 : 20,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Logo
          AnimatedContainer(
            duration: AppDurations.normal,
            width: isCompacted ? 34 : 44,
            height: isCompacted ? 34 : 44,
            decoration: BoxDecoration(
              gradient: AppColors.brandGradient,
              borderRadius: BorderRadius.circular(isCompacted ? 10 : 14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.brand.withOpacity(0.4),
                  blurRadius: isCompacted ? 10 : 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              LucideIcons.brain,
              color: Colors.white,
              size: isCompacted ? 16 : 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isCompacted)
                  Text(
                    'Good morning!',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                AnimatedDefaultTextStyle(
                  duration: AppDurations.normal,
                  style: isCompacted ? AppTextStyles.h2 : AppTextStyles.h1,
                  child: Text(AppConstants.appName),
                ),
              ],
            ),
          ),

          // Notification + Settings
          IconGlassButton(
            icon: LucideIcons.bell,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No new notifications')),
              );
            },
            size: 40,
            iconSize: 18,
          ),
          const SizedBox(width: 8),
          // Avatar
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile Settings (Demo)')),
              );
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: AppColors.brandGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  'A',
                  style: AppTextStyles.labelLg.copyWith(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ── Search Bar ───────────────────────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════════

class _SearchBar extends StatefulWidget {
  const _SearchBar({
    required this.controller,
    required this.onFocusChange,
    required this.onSearch,
  });
  final TextEditingController controller;
  final ValueChanged<bool> onFocusChange;
  final ValueChanged<String> onSearch;

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      widget.onFocusChange(_focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding, 0, AppSpacing.screenPadding, 20),
      child: GestureDetector(
        onTap: () => _focusNode.requestFocus(),
        child: AnimatedContainer(
          duration: AppDurations.normal,
          height: 54,
          decoration: BoxDecoration(
            color: _focusNode.hasFocus ? AppColors.bg500 : AppColors.bg600,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _focusNode.hasFocus
                  ? AppColors.brand.withOpacity(0.5)
                  : AppColors.border200,
              width: _focusNode.hasFocus ? 1.5 : 1.0,
            ),
            boxShadow: _focusNode.hasFocus
                ? [
                    BoxShadow(
                      color: AppColors.brand.withOpacity(0.15),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              const SizedBox(width: 16),
              Icon(
                LucideIcons.sparkles,
                size: 18,
                color: _focusNode.hasFocus
                    ? AppColors.brand
                    : AppColors.iconSubtle,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  style: AppTextStyles.bodyMd,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Ask anything about your documents...',
                    hintStyle: AppTextStyles.bodyMd
                        .copyWith(color: AppColors.textPlaceholder),
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                  onSubmitted: widget.onSearch,
                ),
              ),
              if (widget.controller.text.isNotEmpty)
                IconGlassButton(
                  icon: LucideIcons.x,
                  onPressed: () {
                    widget.controller.clear();
                    setState(() {});
                  },
                  size: 32,
                  iconSize: 14,
                  backgroundColor: Colors.transparent,
                ),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.brand.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: AppColors.brand.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.search,
                          size: 12, color: AppColors.brand),
                      const SizedBox(width: 4),
                      Text(
                        'RAG',
                        style: AppTextStyles.overline
                            .copyWith(color: AppColors.brand),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2, end: 0);
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ── Processing Banner ────────────────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════════

class _ProcessingBanner extends StatelessWidget {
  const _ProcessingBanner({required this.doc});
  final DocModel doc;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding, 0, AppSpacing.screenPadding, 16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.brandSurface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.brand.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 36,
              height: 36,
              child: CircularPercentIndicator(
                radius: 18,
                lineWidth: 3,
                percent: doc.progress,
                progressColor: AppColors.brand,
                backgroundColor: AppColors.brand.withOpacity(0.15),
                circularStrokeCap: CircularStrokeCap.round,
                center: Text(
                  '${(doc.progress * 100).toInt()}%',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.brand,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Building knowledge graph...',
                    style: AppTextStyles.labelMd.copyWith(
                      color: AppColors.brand,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    doc.name,
                    style: AppTextStyles.bodySm,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              LucideIcons.loader2,
              size: 16,
              color: AppColors.brand,
            )
                .animate(onPlay: (c) => c.repeat())
                .rotate(duration: 1000.ms, curve: Curves.linear),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ── Search Results Overlay ────────────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════════

class _SearchResultsSheet extends StatelessWidget {
  const _SearchResultsSheet({required this.query});
  final String query;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        color: Colors.transparent,
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 120,
              left: AppSpacing.screenPadding,
              right: AppSpacing.screenPadding,
            ),
            child: DarkCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(LucideIcons.clock,
                          size: 14, color: AppColors.iconSubtle),
                      const SizedBox(width: 8),
                      Text('Recent searches',
                          style: AppTextStyles.labelMd),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...['What is the architecture?', 'Key financial metrics', 'LLM training data']
                      .map((s) => _RecentSearchTile(query: s)),
                ],
              ),
            ).animate().fadeIn(duration: 200.ms).slideY(begin: -0.1, end: 0),
          ),
        ),
      ),
    );
  }
}

class _RecentSearchTile extends StatelessWidget {
  const _RecentSearchTile({required this.query});
  final String query;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(LucideIcons.search, size: 14, color: AppColors.iconSubtle),
          const SizedBox(width: 10),
          Expanded(child: Text(query, style: AppTextStyles.bodyMd)),
          Icon(LucideIcons.arrowUpLeft,
              size: 14, color: AppColors.iconSubtle),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ── Filter Sheet ─────────────────────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════════

class _FilterSheet extends StatelessWidget {
  const _FilterSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bg700,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: AppColors.border200)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Filter Documents', style: AppTextStyles.h2),
          const SizedBox(height: 20),
          Text('File Type', style: AppTextStyles.labelLg),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: ['All', 'PDF', 'DOCX', 'TXT'].map((t) {
              final isSelected = t == 'All';
              return FilterChip(
                label: Text(t,
                    style: AppTextStyles.labelMd.copyWith(
                      color: isSelected ? Colors.white : AppColors.textMuted,
                    )),
                selected: isSelected,
                onSelected: (_) {},
                backgroundColor: AppColors.bg500,
                selectedColor: AppColors.brand.withOpacity(0.2),
                side: BorderSide(
                  color: isSelected
                      ? AppColors.brand.withOpacity(0.5)
                      : AppColors.border200,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          Text('Status', style: AppTextStyles.labelLg),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: ['All', 'Indexed', 'Processing', 'Error'].map((t) {
              return FilterChip(
                label: Text(t, style: AppTextStyles.labelMd),
                selected: t == 'All',
                onSelected: (_) {},
                backgroundColor: AppColors.bg500,
                selectedColor: AppColors.brand.withOpacity(0.2),
                side: const BorderSide(color: AppColors.border200),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: 'Apply Filters',
            onPressed: () => Navigator.pop(context),
            width: double.infinity,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ── Upload Progress Sheet ─────────────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════════

class _UploadProgressSheet extends StatelessWidget {
  const _UploadProgressSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bg700,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: AppColors.brandGradient,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: AppColors.brand.withOpacity(0.4),
                  blurRadius: 20,
                ),
              ],
            ),
            child: const Icon(LucideIcons.upload, color: Colors.white, size: 28),
          )
              .animate(onPlay: (c) => c.repeat())
              .shimmer(
                duration: 1500.ms,
                color: Colors.white.withOpacity(0.3),
              ),
          const SizedBox(height: 20),
          Text('Uploading & Processing', style: AppTextStyles.h2),
          const SizedBox(height: 8),
          Text(
            'Extracting text, chunking, and creating embeddings...',
            style: AppTextStyles.bodySm,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          LinearProgressIndicator(
            value: 0.45,
            backgroundColor: AppColors.bg400,
            valueColor: const AlwaysStoppedAnimation(AppColors.brand),
            borderRadius: BorderRadius.circular(4),
            minHeight: 6,
          )
              .animate(onPlay: (c) => c.repeat())
              .shimmer(duration: 1000.ms),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Parsing pages...', style: AppTextStyles.bodySm),
              Text('45%',
                  style: AppTextStyles.labelMd
                      .copyWith(color: AppColors.brand)),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ── Empty State ─────────────────────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════════

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onUpload});
  final VoidCallback onUpload;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding, vertical: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Ghost box
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.bg700,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: AppColors.border200, width: 2),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x05000000),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                )
              ],
            ),
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(LucideIcons.fileQuestion, size: 52, color: AppColors.border300),
                  Positioned(
                    bottom: 24,
                    right: 24,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: AppColors.brand,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(LucideIcons.plus, size: 14, color: Colors.white),
                    ).animate(onPlay: (c) => c.repeat(reverse: true)).scaleXY(end: 1.1, duration: 800.ms),
                  )
                ],
              ),
            ),
          ).animate().scale(delay: 200.ms, begin: const Offset(0.8, 0.8), curve: Curves.easeOutBack),
          const SizedBox(height: 32),
          Text(
            'Your knowledge base is empty',
            style: AppTextStyles.h2.copyWith(color: AppColors.text),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
          const SizedBox(height: 12),
          Text(
            'Add a document to start building your private AI',
            style: AppTextStyles.bodyMd.copyWith(color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
          const SizedBox(height: 32),
          PrimaryButton(
            label: 'Add to Knowledge Base',
            icon: LucideIcons.plus,
            onPressed: onUpload,
            width: 240,
          ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ── Data model ────────────────────────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════════

enum DocStatus { queued, parsing, chunking, embedding, summarizing, indexed, error }

class DocModel {
  const DocModel({
    required this.id,
    required this.name,
    required this.type,
    required this.size,
    required this.pages,
    required this.status,
    required this.progress,
    required this.addedDate,
    required this.chunks,
    required this.color,
  });

  final String id;
  final String name;
  final String type;
  final String size;
  final int pages;
  final DocStatus status;
  final double progress;
  final String addedDate;
  final int chunks;
  final Color color;
}
