import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:gnyaan/core/theme/app_colors.dart';
import 'package:gnyaan/core/theme/app_text_styles.dart';
import 'package:gnyaan/core/constants/app_constants.dart';
import 'package:gnyaan/shared/widgets/glass_card.dart';
import '../screens/knowledge_hub_screen.dart';

class DocumentCard extends StatefulWidget {
  const DocumentCard({
    super.key,
    required this.doc,
    required this.onTap,
  });

  final DocModel doc;
  final VoidCallback onTap;

  @override
  State<DocumentCard> createState() => _DocumentCardState();
}

class _DocumentCardState extends State<DocumentCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      vsync: this,
      duration: AppDurations.normal,
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final doc = widget.doc;

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isHovered = true);
        _hoverController.forward();
      },
      onTapUp: (_) {
        setState(() => _isHovered = false);
        _hoverController.reverse();
        widget.onTap();
      },
      onTapCancel: () {
        setState(() => _isHovered = false);
        _hoverController.reverse();
      },
      child: AnimatedBuilder(
        animation: _hoverController,
        builder: (_, child) => Transform.scale(
          scale: 1.0 - _hoverController.value * 0.03,
          child: child,
        ),
        child: AnimatedContainer(
          duration: AppDurations.normal,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _isHovered ? AppColors.bg500 : AppColors.bg600,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: _isHovered
                  ? doc.color.withOpacity(0.4)
                  : AppColors.border200,
            ),
            boxShadow: [
              if (_isHovered)
                BoxShadow(
                  color: doc.color.withOpacity(0.18),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                )
              else
                const BoxShadow(
                  color: Color(0x22000000),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── File icon + type chip ─────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: doc.color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: doc.color.withOpacity(0.25)),
                    ),
                    child: Icon(
                      _iconForType(doc.type),
                      color: doc.color,
                      size: 20,
                    ),
                  ),
                  _TypeChip(type: doc.type, color: doc.color),
                ],
              ),

              const SizedBox(height: 14),

              // ── Document name ─────────────────────────────────────────
              Text(
                doc.name.replaceAll(RegExp(r'\.(pdf|docx|txt)$', caseSensitive: false), ''),
                style: AppTextStyles.h3.copyWith(fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 6),

              // ── Meta info ─────────────────────────────────────────────
              Row(
                children: [
                  Icon(LucideIcons.fileText,
                      size: 11, color: AppColors.iconSubtle),
                  const SizedBox(width: 4),
                  Text('${doc.pages}p', style: AppTextStyles.caption),
                  const SizedBox(width: 8),
                  Icon(LucideIcons.hardDrive,
                      size: 11, color: AppColors.iconSubtle),
                  const SizedBox(width: 4),
                  Text(doc.size, style: AppTextStyles.caption),
                ],
              ),

              const Spacer(),

              // ── Status indicator ──────────────────────────────────────
              _StatusSection(doc: doc),

              const SizedBox(height: 10),

              // ── Added date + chunks ───────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      doc.addedDate,
                      style: AppTextStyles.caption,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.database,
                          size: 9, color: AppColors.iconSubtle),
                      const SizedBox(width: 3),
                      Flexible(
                        child: Text(
                          '${doc.chunks}',
                          style: AppTextStyles.caption,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'PDF':
        return LucideIcons.fileText;
      case 'DOCX':
        return LucideIcons.fileType2;
      case 'TXT':
        return LucideIcons.fileCode;
      default:
        return LucideIcons.file;
    }
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({required this.type, required this.color});
  final String type;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text(
        type,
        style: AppTextStyles.overline.copyWith(
          color: color,
          fontSize: 9,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _StatusSection extends StatelessWidget {
  const _StatusSection({required this.doc});
  final DocModel doc;

  @override
  Widget build(BuildContext context) {
    if (doc.status == DocStatus.indexed) {
      return Row(
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
          )
              .animate(onPlay: (c) => c.repeat())
              .fade(
                begin: 0.4,
                end: 1.0,
                duration: 1500.ms,
              ),
          const SizedBox(width: 6),
          Text(
            'Indexed',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.success,
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Text(
                _label(doc.status),
                style: AppTextStyles.caption.copyWith(color: AppColors.warning),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '${(doc.progress * 100).toInt()}%',
              style: AppTextStyles.caption.copyWith(color: AppColors.warning),
            ),
          ],
        ),
        const SizedBox(height: 5),
        LinearProgressIndicator(
          value: doc.progress,
          backgroundColor: AppColors.bg400,
          valueColor:
              const AlwaysStoppedAnimation(AppColors.warning),
          borderRadius: BorderRadius.circular(3),
          minHeight: 3,
        ),
      ],
    );
  }

  String _label(DocStatus s) {
    switch (s) {
      case DocStatus.parsing:
        return 'Extracting text...';
      case DocStatus.chunking:
        return 'Chunking document...';
      case DocStatus.embedding:
        return 'Generating embeddings...';
      case DocStatus.summarizing:
        return 'Building knowledge graph...';
      case DocStatus.error:
        return 'Error';
      default:
        return 'Queued';
    }
  }
}
