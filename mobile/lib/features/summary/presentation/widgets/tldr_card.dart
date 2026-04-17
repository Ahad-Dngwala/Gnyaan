import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:gnyaan/core/theme/app_colors.dart';
import 'package:gnyaan/core/theme/app_text_styles.dart';
import 'package:gnyaan/core/constants/app_constants.dart';

/// The large TL;DR hero card on the summary screen
class TldrCard extends StatelessWidget {
  const TldrCard({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.bg800, AppColors.bg600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.brand.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.brand.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border200)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: AppColors.brandGradient,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.brand.withOpacity(0.3),
                          blurRadius: 10),
                    ],
                  ),
                  child: const Icon(LucideIcons.zap,
                      color: Colors.white, size: 14),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('TL;DR', style: AppTextStyles.h3),
                    Text('AI-generated summary',
                        style: AppTextStyles.caption),
                  ],
                ),
                const Spacer(),
                Tooltip(
                  message: 'Derived from 186 indexed chunks.\nSimilarity > 0.85',
                  triggerMode: TooltipTriggerMode.tap,
                  decoration: BoxDecoration(
                    color: AppColors.bg700,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.success.withOpacity(0.5)),
                  ),
                  textStyle: AppTextStyles.caption.copyWith(color: AppColors.success),
                  padding: const EdgeInsets.all(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                          color: AppColors.success.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(LucideIcons.checkCircle2,
                            size: 11, color: AppColors.success),
                        const SizedBox(width: 4),
                        Text('Grounded',
                            style: AppTextStyles.caption
                                .copyWith(color: AppColors.success)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Content ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              text,
              style: AppTextStyles.bodyLg.copyWith(
                color: AppColors.text,
                height: 1.85,
              ),
            ).animate().fadeIn(delay: 200.ms),
          ),

          // ── Actions ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                _ActionChip(
                  icon: LucideIcons.copy,
                  label: 'Copy',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Copied to clipboard (Demo)')),
                    );
                  },
                ),
                const SizedBox(width: 8),
                _ActionChip(
                  icon: LucideIcons.share2,
                  label: 'Share',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Share menu (Demo)')),
                    );
                  },
                ),
                const SizedBox(width: 8),
                _ActionChip(
                  icon: LucideIcons.messageSquare,
                  label: 'Ask AI',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Opening Chat... (Demo)')),
                    );
                  },
                  isPrimary: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isPrimary = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isPrimary
              ? AppColors.brand.withOpacity(0.12)
              : AppColors.bg500,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(
            color: isPrimary
                ? AppColors.brand.withOpacity(0.3)
                : AppColors.border200,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 13,
                color: isPrimary ? AppColors.brand : AppColors.icon),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.labelMd.copyWith(
                color: isPrimary ? AppColors.brand : AppColors.textMuted,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
