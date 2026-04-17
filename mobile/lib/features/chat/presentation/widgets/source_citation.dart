import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:gnyaan/core/theme/app_colors.dart';
import 'package:gnyaan/core/theme/app_text_styles.dart';
import 'package:gnyaan/core/constants/app_constants.dart';
import '../screens/chat_screen.dart';
import 'package:gnyaan/shared/widgets/app_buttons.dart';

/// Compact expandable card showing source document passage + similarity score
class SourceCitation extends StatefulWidget {
  const SourceCitation({super.key, required this.source});
  final ChatSource source;

  @override
  State<SourceCitation> createState() => ChatSourceCitationState();
}

class ChatSourceCitationState extends State<SourceCitation> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final s = widget.source;
    final pct = (s.similarity * 100).toInt();
    final scoreColor = pct >= 90
        ? AppColors.success
        : pct >= 70
            ? AppColors.warning
            : AppColors.error;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: GestureDetector(
        onTap: () => setState(() => _expanded = !_expanded),
        child: AnimatedContainer(
          duration: AppDurations.normal,
          decoration: BoxDecoration(
            color: AppColors.bg600,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: _expanded
                  ? AppColors.brand.withOpacity(0.3)
                  : AppColors.border200,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header row ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.brand.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(LucideIcons.quote,
                          size: 12, color: AppColors.brand),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.docName.replaceAll(RegExp(r'\.(pdf|docx|txt)$', caseSensitive: false), ''),
                            style: AppTextStyles.labelMd.copyWith(
                              color: AppColors.brand,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Page ${s.page}',
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                    ),

                    // Similarity badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: scoreColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                        border:
                            Border.all(color: scoreColor.withOpacity(0.3)),
                      ),
                      child: Text(
                        '$pct%',
                        style: AppTextStyles.overline.copyWith(
                          color: scoreColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    AnimatedRotation(
                      turns: _expanded ? 0.5 : 0.0,
                      duration: AppDurations.normal,
                      child: Icon(
                        LucideIcons.chevronDown,
                        size: 14,
                        color: AppColors.iconSubtle,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Expanded snippet ────────────────────────────────────────
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Divider(height: 1, color: AppColors.border200),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        '"${s.snippet}"',
                        style: AppTextStyles.bodySm.copyWith(
                          color: AppColors.textMuted,
                          fontStyle: FontStyle.italic,
                          height: 1.6,
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.fromLTRB(10, 0, 10, 10),
                      child: GhostButton(
                        label: 'View in Document',
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Opening Document... (Demo)')),
                          );
                        },
                        icon: LucideIcons.externalLink,
                        color: AppColors.brand,
                        height: 36,
                      ),
                    ),
                  ],
                ),
                crossFadeState: _expanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: AppDurations.normal,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


