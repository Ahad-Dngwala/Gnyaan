import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:gnyaan/core/theme/app_colors.dart';
import 'package:gnyaan/core/theme/app_text_styles.dart';
import 'package:gnyaan/core/constants/app_constants.dart';
import 'package:gnyaan/shared/widgets/app_buttons.dart';
import 'package:gnyaan/features/summary/services/summary_service.dart';
import '../widgets/tldr_card.dart';

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key, this.documentId, this.documentTitle});

  final String? documentId;
  final String? documentTitle;

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  final SummaryService _summaryService = SummaryService();
  bool _isLoading = false;
  String _title = 'Select a document';
  String _tldr = '';
  String _summary = '';
  bool _cached = false;
  int _responseTimeMs = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.documentId != null) {
      _title = widget.documentTitle ?? 'Document';
      _fetchSummary();
    }
  }

  Future<void> _fetchSummary() async {
    if (widget.documentId == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _summaryService.getSummary(widget.documentId!);
      setState(() {
        _isLoading = false;
        _title = data['title'] as String? ?? _title;
        _tldr = data['tldr'] as String? ?? '';
        _summary = data['summary'] as String? ?? '';
        _cached = data['cached'] as bool? ?? false;
        _responseTimeMs = data['responseTimeMs'] as int? ?? 0;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg800,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Header ──────────────────────────────────────────────────────
          SliverToBoxAdapter(child: _SummaryHeader(title: _title)),

          // ── Content ─────────────────────────────────────────────────────
          SliverFillRemaining(
            hasScrollBody: true,
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    // No document selected
    if (widget.documentId == null) {
      return _NoDocumentState();
    }

    // Loading
    if (_isLoading) {
      return _LoadingState();
    }

    // Error
    if (_error != null) {
      return _ErrorState(message: _error!, onRetry: _fetchSummary);
    }

    // Success — show TL;DR and Summary
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cache / time badge
          Row(
            children: [
              if (_cached)
                _Badge(
                  icon: LucideIcons.database,
                  label: 'Cached',
                  color: AppColors.success,
                ),
              if (!_cached && _responseTimeMs > 0)
                _Badge(
                  icon: LucideIcons.zap,
                  label: '${_responseTimeMs}ms',
                  color: AppColors.warning,
                ),
            ],
          ).animate().fadeIn(),

          const SizedBox(height: 16),

          // TL;DR card
          if (_tldr.isNotEmpty) ...[
            TldrCard(text: _tldr),
            const SizedBox(height: 24),
          ],

          // Full Summary
          if (_summary.isNotEmpty) ...[
            Text('Full Summary', style: AppTextStyles.h2)
                .animate()
                .fadeIn(delay: 200.ms),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.bg600,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.border200),
              ),
              child: Text(
                _summary,
                style: AppTextStyles.bodyMd.copyWith(
                  color: AppColors.textMuted,
                  height: 1.7,
                ),
              ),
            ).animate().fadeIn(delay: 300.ms),
          ],

          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ── Summary Header ────────────────────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════════

class _SummaryHeader extends StatelessWidget {
  const _SummaryHeader({required this.title});
  final String title;

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
                        const SnackBar(content: Text('Share (Demo)')),
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
                  .scale(
                      begin: const Offset(0.7, 0.7), curve: Curves.elasticOut),
              const SizedBox(height: 16),
              Text(title, style: AppTextStyles.h1),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ── States ────────────────────────────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════════

class _NoDocumentState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.bg600,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.border200),
            ),
            child: const Icon(LucideIcons.fileQuestion,
                size: 36, color: AppColors.border300),
          ),
          const SizedBox(height: 20),
          Text('No document selected', style: AppTextStyles.h2),
          const SizedBox(height: 8),
          Text(
            'Tap a document in the Knowledge Hub\nto generate its summary.',
            style: AppTextStyles.bodyMd
                .copyWith(color: AppColors.textMuted, height: 1.6),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: AppColors.brandGradient,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(LucideIcons.sparkles,
                color: Colors.white, size: 28),
          )
              .animate(onPlay: (c) => c.repeat())
              .shimmer(
                  duration: 1500.ms,
                  color: Colors.white.withOpacity(0.3)),
          const SizedBox(height: 20),
          Text('Generating summary...', style: AppTextStyles.h3),
          const SizedBox(height: 8),
          Text(
            'Analyzing document content with AI',
            style: AppTextStyles.bodySm
                .copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.alertTriangle,
                size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text('Summary failed', style: AppTextStyles.h2),
            const SizedBox(height: 8),
            Text(
              message,
              style: AppTextStyles.bodyMd
                  .copyWith(color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            PrimaryButton(label: 'Retry', onPressed: onRetry, width: 140),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ── Badge chip ────────────────────────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════════

class _Badge extends StatelessWidget {
  const _Badge(
      {required this.icon, required this.label, required this.color});
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
