import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle get _base => GoogleFonts.outfit();

  // ── Display ──────────────────────────────────────────────────────────────
  static TextStyle get displayXL => _base.copyWith(
        fontSize: 40,
        fontWeight: FontWeight.w800,
        color: AppColors.text,
        height: 1.1,
        letterSpacing: -1.5,
      );

  static TextStyle get displayLg => _base.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: AppColors.text,
        height: 1.15,
        letterSpacing: -1.2,
      );

  static TextStyle get displayMd => _base.copyWith(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: AppColors.text,
        height: 1.2,
        letterSpacing: -0.8,
      );

  // ── Headings ─────────────────────────────────────────────────────────────
  static TextStyle get h1 => _base.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.text,
        height: 1.25,
        letterSpacing: -0.5,
      );

  static TextStyle get h2 => _base.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.text,
        height: 1.3,
        letterSpacing: -0.4,
      );

  static TextStyle get h3 => _base.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.text,
        height: 1.35,
        letterSpacing: -0.2,
      );

  // ── Body ─────────────────────────────────────────────────────────────────
  static TextStyle get bodyLg => _base.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.textMuted,
        height: 1.6,
      );

  static TextStyle get bodyMd => _base.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textMuted,
        height: 1.5,
      );

  static TextStyle get bodySm => _base.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.textSubtle,
        height: 1.5,
      );

  // ── Labels ───────────────────────────────────────────────────────────────
  static TextStyle get labelLg => _base.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.text,
        height: 1.3,
      );

  static TextStyle get labelMd => _base.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.text,
        height: 1.3,
      );

  static TextStyle get labelSm => _base.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.textSubtle,
        height: 1.3,
      );

  // ── Captions & Overlines ─────────────────────────────────────────────────
  static TextStyle get caption => _base.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textSubtle,
        height: 1.4,
      );

  static TextStyle get overline => _base.copyWith(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: AppColors.textSubtle,
        height: 1.4,
        letterSpacing: 1.2,
      );
}
