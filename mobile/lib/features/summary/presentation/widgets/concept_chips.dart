import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gnyaan/core/theme/app_colors.dart';
import 'package:gnyaan/core/theme/app_text_styles.dart';
import 'package:gnyaan/core/constants/app_constants.dart';

class ConceptChipsGrid extends StatefulWidget {
  const ConceptChipsGrid({super.key, required this.concepts});
  final List<String> concepts;

  @override
  State<ConceptChipsGrid> createState() => _ConceptChipsGridState();
}

class _ConceptChipsGridState extends State<ConceptChipsGrid> {
  final Set<int> _selected = {};

  static const List<Color> _palette = [
    AppColors.brand,
    AppColors.accent,
    AppColors.violet,
    AppColors.success,
    AppColors.warning,
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Key Concepts', style: AppTextStyles.h2),
        const SizedBox(height: 6),
        Text(
          'Tap a concept to query it in the AI engine',
          style: AppTextStyles.bodySm,
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: widget.concepts.asMap().entries.map((e) {
            final color = _palette[e.key % _palette.length];
            final isSelected = _selected.contains(e.key);

            return GestureDetector(
              onTap: () => setState(() {
                if (isSelected) {
                  _selected.remove(e.key);
                } else {
                  _selected.add(e.key);
                }
              }),
              child: AnimatedContainer(
                duration: AppDurations.fast,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withOpacity(0.15)
                      : AppColors.bg600,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(
                    color: isSelected
                        ? color.withOpacity(0.5)
                        : AppColors.border200,
                    width: isSelected ? 1.5 : 1.0,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: color.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSelected) ...[
                      Icon(Icons.check_circle_rounded,
                          size: 14, color: color),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      e.value,
                      style: AppTextStyles.labelMd.copyWith(
                        color: isSelected ? color : AppColors.text,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(delay: Duration(milliseconds: 50 * e.key))
                  .scale(
                    begin: const Offset(0.8, 0.8),
                    delay: Duration(milliseconds: 50 * e.key),
                    curve: Curves.elasticOut,
                    duration: 500.ms,
                  ),
            );
          }).toList(),
        ),

        if (_selected.isNotEmpty) ...[
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.brand.withOpacity(0.06),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.brand.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome,
                    size: 16, color: AppColors.brand),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Ask about: ${_selected.map((i) => widget.concepts[i]).join(', ')}',
                    style: AppTextStyles.bodyMd
                        .copyWith(color: AppColors.brand),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn().slideY(begin: 0.3),
        ],
      ],
    );
  }
}
