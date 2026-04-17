import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:gnyaan/core/theme/app_colors.dart';
import 'package:gnyaan/core/theme/app_text_styles.dart';
import 'package:gnyaan/core/constants/app_constants.dart';
import 'package:gnyaan/shared/widgets/bounceable.dart';

class UploadDropzone extends StatefulWidget {
  const UploadDropzone({super.key, required this.onUpload});
  final VoidCallback onUpload;

  @override
  State<UploadDropzone> createState() => _UploadDropzoneState();
}

class _UploadDropzoneState extends State<UploadDropzone>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _isDragOver = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding, 0, AppSpacing.screenPadding, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Add to Knowledge Base',
                    style: AppTextStyles.h2,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                _QuickFormatChips(),
              ],
            ),
          ),
          GestureDetector(
            onTap: widget.onUpload,
            onPanStart: (_) => setState(() => _isDragOver = true),
            onPanEnd: (_) => setState(() => _isDragOver = false),
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (_, child) => AnimatedContainer(
                duration: AppDurations.normal,
                height: 150,
                decoration: BoxDecoration(
                  color: _isDragOver
                      ? AppColors.brand.withOpacity(0.08)
                      : AppColors.bg600,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: _isDragOver
                        ? AppColors.brand.withOpacity(0.6)
                        : AppColors.border200,
                    width: _isDragOver ? 2 : 1,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x08000000),
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    )
                  ],
                ),
                child: child,
              ),
              child: Bounceable(
                onTap: widget.onUpload,
                child: Stack(
                alignment: Alignment.center,
                children: [
                  // Glow behind the icon
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (_, __) => Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.brand.withOpacity(
                                0.06 + _pulseController.value * 0.06),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Animated upload icon
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          gradient: AppColors.brandGradient,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.brand.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          LucideIcons.upload,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Add to Knowledge Base',
                            style: AppTextStyles.labelLg,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'PDF, DOCX, TXT  ·  Max 50 MB',
                            style: AppTextStyles.bodySm,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0);
  }
}

class _QuickFormatChips extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      children: ['PDF', 'DOCX', 'TXT'].map((f) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.bg500,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.border200),
          ),
          child: Text(
            f,
            style: AppTextStyles.caption.copyWith(fontSize: 10),
          ),
        );
      }).toList(),
    );
  }
}
