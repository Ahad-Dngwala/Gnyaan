import 'package:flutter/material.dart';

/// Gnyaan Design System — Desert Gold (Soft Sand & Deep Navy)
/// Luxury boutique vibe with warm tones and massive appeal.
class AppColors {
  AppColors._();

  // ── Backgrounds ─────────────────────────────────────────────────────────
  static const Color bg800 = Color(0xFFF9F7F2);        // Soft Sand
  static const Color bg700 = Color(0xFFF0EBE0);        // Off-white sand
  static const Color bg600 = Color(0xFFFFFFFF);        // Pure White cards
  static const Color bg500 = Color(0xFFE8E2D2);        // Warm borders / backgrounds
  static const Color bg400 = Color(0xFFD6CDBB);        // Deep beige

  // ── Brand — Muted Gold (#C5A059) ────────────────────────────────────────
  static const Color brand = Color(0xFFC5A059);         // Gold
  static const Color brandLight = Color(0xFFD8B97C);    // Lighter Gold
  static const Color brandDark = Color(0xFF9E7E3C);     // Deep Gold
  static const Color brandGlow = Color(0x33C5A059);     // Gold glow
  static const Color brandSurface = Color(0xFFFBF8F1);  // Gold tinted surface

  static const LinearGradient brandGradient = LinearGradient(
    colors: [Color(0xFFD8B97C), Color(0xFFC5A059), Color(0xFF9E7E3C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Accent — Deep Midnight Navy (#1B263B) ───────────────────────────────
  static const Color accent = Color(0xFF1B263B);        // Navy
  static const Color accentLight = Color(0xFF324A6D);   // Lighter Navy
  static const Color accentDark = Color(0xFF0F1626);    // Deepest Navy

  static const Color violet = Color(0xFF8B5CF6);        // (Keep for some visual variety)

  // ── Text ────────────────────────────────────────────────────────────────
  static const Color text = Color(0xFF1B263B);           // Deep Navy instead of black
  static const Color textMuted = Color(0xFF4A5568);      // Slate grey
  static const Color textSubtle = Color(0xFF8E95A1);     // Light grey
  static const Color textPlaceholder = Color(0xFFB5BAC1); // Faint

  // ── Icons ───────────────────────────────────────────────────────────────
  static const Color icon = Color(0xFF1B263B);           // Deep Navy
  static const Color iconSubtle = Color(0xFF8E95A1);     // Muted

  // ── Borders ─────────────────────────────────────────────────────────────
  static const Color border300 = Color(0xFFD6CDBB);      
  static const Color border200 = Color(0xFFE8E2D2);      // Faint sand border
  static const Color border100 = Color(0xFFF9F7F2);      

  // ── Semantic ────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF7CB342);        // Soft green
  static const Color warning = Color(0xFFD8B97C);        // Gold/Amber
  static const Color error = Color(0xFFD86B5D);          // Muted Terra-cotta
  static const Color info = Color(0xFF6B8FAD);           // Slate blue

  // ── Chat-specific ───────────────────────────────────────────────────────
  static const Color userBubble = Color(0xFFC5A059);     // Gold user bubble
  static const Color aiBubble = Color(0xFFFFFFFF);       // White AI bubble
  static const Color aiAvatar = Color(0xFF1B263B);       // Navy bot avatar
}
