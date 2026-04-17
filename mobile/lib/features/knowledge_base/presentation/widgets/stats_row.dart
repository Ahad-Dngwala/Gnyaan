import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:gnyaan/core/theme/app_colors.dart';
import 'package:gnyaan/core/theme/app_text_styles.dart';
import 'package:gnyaan/core/constants/app_constants.dart';

class StatsRow extends StatelessWidget {
  const StatsRow({
    super.key,
    required this.totalDocs,
    required this.indexedDocs,
    required this.totalChunks,
  });

  final int totalDocs;
  final int indexedDocs;
  final int totalChunks;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding, 0, AppSpacing.screenPadding, 20),
      child: Row(
        children: [
          _StatPill(
            icon: LucideIcons.files,
            value: '$totalDocs',
            label: 'Total Documents',
            color: AppColors.brand,
          ),
          const SizedBox(width: 12),
          _StatPill(
            icon: LucideIcons.database,
            value: '$totalChunks',
            label: 'Extracted Chunks',
            color: AppColors.accent,
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(height: 6),
            Text(
              value,
              style: AppTextStyles.h3.copyWith(color: color, fontSize: 18),
            ),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConnectionStatusPill extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.success.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
              )
                  .animate(onPlay: (c) => c.repeat())
                  .fade(begin: 0.3, end: 1.0, duration: 1000.ms),
              const SizedBox(width: 4),
              Text(
                'LIVE',
                style: AppTextStyles.overline
                    .copyWith(color: AppColors.success, fontSize: 8),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Claude',
            style: AppTextStyles.labelMd.copyWith(
              color: AppColors.success,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            'API',
            style: AppTextStyles.caption.copyWith(fontSize: 10),
          ),
        ],
      ),
    );
  }
}
