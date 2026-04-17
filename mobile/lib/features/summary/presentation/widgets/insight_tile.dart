import 'package:flutter/material.dart';
import 'package:gnyaan/core/theme/app_colors.dart';
import 'package:gnyaan/core/theme/app_text_styles.dart';
import 'package:gnyaan/core/constants/app_constants.dart';
import '../screens/summary_screen.dart';

class InsightTile extends StatelessWidget {
  const InsightTile({super.key, required this.insight});
  final InsightModel insight;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bg600,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: insight.color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: insight.color.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: insight.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: insight.color.withOpacity(0.25)),
            ),
            child: Icon(insight.icon, size: 18, color: insight.color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(insight.title, style: AppTextStyles.h3),
                const SizedBox(height: 6),
                Text(
                  insight.body,
                  style: AppTextStyles.bodyMd
                      .copyWith(color: AppColors.textMuted, height: 1.6),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
