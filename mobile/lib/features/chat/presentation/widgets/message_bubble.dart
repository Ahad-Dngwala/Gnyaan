import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:gnyaan/core/theme/app_colors.dart';
import 'package:gnyaan/core/theme/app_text_styles.dart';
import 'package:gnyaan/core/constants/app_constants.dart';
import '../screens/chat_screen.dart';
import 'source_citation.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    this.isLastMessage = false,
  });

  final ChatMessage message;
  final bool isLastMessage;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == MessageRole.user;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: AppColors.brandGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(LucideIcons.brain,
                  size: 16, color: Colors.white),
            ),
            const SizedBox(width: 8),
          ],

          Flexible(
            child: Column(
              crossAxisAlignment: isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                // ── Message bubble ─────────────────────────────────────
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: isUser
                        ? AppColors.brandGradient
                        : null,
                    color: isUser ? null : AppColors.bg600,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(isUser ? 18 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 18),
                    ),
                    border: isUser
                        ? null
                        : Border.all(color: AppColors.border200),
                    boxShadow: isUser
                        ? [
                            BoxShadow(
                              color: AppColors.brand.withOpacity(0.25),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: _RichContent(
                    content: message.content,
                    isUser: isUser,
                  ),
                ),

                const SizedBox(height: 6),

                // ── Timestamp ──────────────────────────────────────────
                Text(
                  _formatTime(message.timestamp),
                  style: AppTextStyles.caption,
                ),

                // ── Explainability UI ──────────────────────────────────
                if (!isUser && message.sources.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const _TransparencyMetadataRow(),
                  const SizedBox(height: 12),
                  _WhyThisAnswerExpander(sources: message.sources),
                ],
              ],
            ),
          ),

          if (isUser) const SizedBox(width: 8),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.2, end: 0, duration: 300.ms);
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

class _RichContent extends StatelessWidget {
  const _RichContent({required this.content, required this.isUser});
  final String content;
  final bool isUser;

  @override
  Widget build(BuildContext context) {
    // Basic bold markdown: **text** → bold
    final spans = <TextSpan>[];
    final pattern = RegExp(r'\*\*(.*?)\*\*');
    int last = 0;

    for (final match in pattern.allMatches(content)) {
      if (match.start > last) {
        spans.add(TextSpan(
          text: content.substring(last, match.start),
          style: AppTextStyles.bodyMd.copyWith(
            color: isUser ? Colors.white : AppColors.text,
            height: 1.6,
          ),
        ));
      }
      spans.add(TextSpan(
        text: match.group(1),
        style: AppTextStyles.bodyMd.copyWith(
          color: isUser ? Colors.white : AppColors.text,
          fontWeight: FontWeight.w700,
          height: 1.6,
        ),
      ));
      last = match.end;
    }

    if (last < content.length) {
      spans.add(TextSpan(
        text: content.substring(last),
        style: AppTextStyles.bodyMd.copyWith(
          color: isUser ? Colors.white : AppColors.text,
          height: 1.6,
        ),
      ));
    }

    return RichText(text: TextSpan(children: spans));
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ── Transparency UI ────────────────────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════════

class _TransparencyMetadataRow extends StatelessWidget {
  const _TransparencyMetadataRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(LucideIcons.layers, size: 12, color: AppColors.textSubtle),
        const SizedBox(width: 4),
        Text(
          'Top matches: 5 chunks',
          style: AppTextStyles.caption.copyWith(color: AppColors.textSubtle),
        ),
        const SizedBox(width: 8),
        Text('|', style: AppTextStyles.caption.copyWith(color: AppColors.border300)),
        const SizedBox(width: 8),
        const Icon(LucideIcons.barChart2, size: 12, color: AppColors.success),
        const SizedBox(width: 4),
        Text(
          'Confidence: 91%',
          style: AppTextStyles.caption.copyWith(
              color: AppColors.success, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _WhyThisAnswerExpander extends StatefulWidget {
  const _WhyThisAnswerExpander({required this.sources});
  final List<ChatSource> sources;

  @override
  State<_WhyThisAnswerExpander> createState() => _WhyThisAnswerExpanderState();
}

class _WhyThisAnswerExpanderState extends State<_WhyThisAnswerExpander> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Why this answer?',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.brand,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                _isExpanded ? LucideIcons.chevronUp : LucideIcons.chevronDown,
                size: 14,
                color: AppColors.brand,
              ),
            ],
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: _isExpanded
              ? Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Column(
                    children: widget.sources
                        .map((s) => SourceCitation(source: s))
                        .toList(),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
