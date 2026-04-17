import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:gnyaan/core/theme/app_colors.dart';
import 'package:gnyaan/shared/widgets/bounceable.dart';

/// Glassmorphic container — Frosted glass card used across the app.
/// Supports custom blur, border opacity, background tint.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 24,
    this.blurStrength = 20,
    this.backgroundOpacity = 0.06,
    this.borderOpacity = 0.12,
    this.gradient,
    this.glowColor,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double blurStrength;
  final double backgroundOpacity;
  final double borderOpacity;
  final Gradient? gradient;
  final Color? glowColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    Widget card = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: blurStrength,
          sigmaY: blurStrength,
        ),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            gradient: gradient ??
                LinearGradient(
                  colors: [
                    Colors.white.withOpacity(backgroundOpacity),
                    Colors.white.withOpacity(backgroundOpacity * 0.5),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
            border: Border.all(
              color: Colors.white.withOpacity(borderOpacity),
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );

    if (glowColor != null) {
      card = Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: glowColor!.withOpacity(0.25),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: card,
      );
    }

    if (margin != null) {
      card = Padding(padding: margin!, child: card);
    }

    if (onTap != null) {
      card = Bounceable(onTap: onTap, child: card);
    }

    return card;
  }
}

/// Solid dark card with a subtle border and optional glow
class DarkCard extends StatelessWidget {
  const DarkCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 24,
    this.color = AppColors.bg600,
    this.borderColor = AppColors.border200,
    this.glowColor,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color color;
  final Color borderColor;
  final Color? glowColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor),
        boxShadow: glowColor != null
            ? [
                BoxShadow(
                  color: glowColor!.withOpacity(0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : [
                BoxShadow(
                  color: const Color(0x08000000),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(0),
        child: child,
      ),
    );

    if (onTap != null) {
      return Bounceable(onTap: onTap, child: card);
    }
    return card;
  }
}
