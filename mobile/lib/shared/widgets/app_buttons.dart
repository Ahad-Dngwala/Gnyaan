import 'package:flutter/material.dart';
import 'package:gnyaan/core/theme/app_colors.dart';
import 'package:gnyaan/core/theme/app_text_styles.dart';
import 'package:gnyaan/core/constants/app_constants.dart';

import 'package:gnyaan/shared/widgets/bounceable.dart';

/// Primary CTA button with gradient fill + glow
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.width,
    this.height = 52,
    this.gradient = AppColors.brandGradient,
    this.glowColor = AppColors.brand,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final double? width;
  final double height;
  final Gradient gradient;
  final Color glowColor;

  @override
  Widget build(BuildContext context) {
    final body = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: onPressed == null
            ? const LinearGradient(colors: [AppColors.bg400, AppColors.bg500])
            : gradient,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: onPressed != null
            ? [
                BoxShadow(
                  color: glowColor.withOpacity(0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: isLoading
          ? Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: AppTextStyles.labelLg.copyWith(color: Colors.white),
                ),
              ],
            ),
    );

    if (onPressed != null) {
      return Bounceable(onTap: onPressed, child: body);
    }
    return body;
  }
}

/// Ghost / secondary button
class GhostButton extends StatelessWidget {
  const GhostButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.color = AppColors.brand,
    this.height = 48,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final body = SizedBox(
      height: height,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: color,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            side: BorderSide(color: color.withOpacity(0.35)),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16),
              const SizedBox(width: 6),
            ],
            Text(label, style: AppTextStyles.labelMd.copyWith(color: color)),
          ],
        ),
      ),
    );
    return onPressed != null ? Bounceable(onTap: () {}, child: body) : body;
  }
}

/// Icon-only button with frosted glass effect
class IconGlassButton extends StatelessWidget {
  const IconGlassButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.size = 44,
    this.iconSize = 20,
    this.color = AppColors.icon,
    this.backgroundColor = AppColors.bg500,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final double iconSize;
  final Color color;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    final body = SizedBox(
      width: size,
      height: size,
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(size / 2),
        child: InkWell(
          borderRadius: BorderRadius.circular(size / 2),
          onTap: onPressed,
          splashColor: AppColors.brand.withOpacity(0.1),
          child: Icon(icon, size: iconSize, color: color),
        ),
      ),
    );

    if (onPressed != null) {
      return Bounceable(onTap: () {}, child: body);
    }
    return body;
  }
}

/// Small status tag / badge chip
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.icon,
  });

  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 10, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label.toUpperCase(),
            style: AppTextStyles.overline.copyWith(
              color: color,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}
