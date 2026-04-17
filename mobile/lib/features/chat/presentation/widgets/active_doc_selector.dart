import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:gnyaan/core/theme/app_colors.dart';
import 'package:gnyaan/core/theme/app_text_styles.dart';
import 'package:gnyaan/core/constants/app_constants.dart';

/// Horizontal scrollable banner showing active document selection in chat
class ActiveDocSelector extends StatelessWidget {
  const ActiveDocSelector({
    super.key,
    required this.activeDoc,
    required this.onTap,
  });

  final String activeDoc;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      margin: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding, 0, AppSpacing.screenPadding, 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.brand.withOpacity(0.08),
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(color: AppColors.brand.withOpacity(0.25)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.database,
                  size: 13, color: AppColors.brand),
              const SizedBox(width: 8),
              Text(
                'Context: ',
                style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSubtle),
              ),
              Text(
                activeDoc.replaceAll(RegExp(r'\.(pdf|docx|txt)$', caseSensitive: false), ''),
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.brand,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(width: 6),
              Icon(LucideIcons.chevronDown,
                  size: 12, color: AppColors.brand),
            ],
          ),
        ),
      ),
    );
  }
}
