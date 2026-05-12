import 'package:flutter/material.dart';

/// Mob Brand Color Palette — locked 2026-04-16
///
/// Primary:   #3D6FFF (Electric Blue)
/// Accent:    #8B2FFF (Deep Purple)
/// Glow/Live: #00C2FF (Cyan)
/// Gradient:  #3D6FFF → #8B2FFF
class AppColors {
  AppColors._();

  // ---------------------------------------------------------------------------
  // Surfaces
  // ---------------------------------------------------------------------------

  static const Color background = Color(0xFF0A0A0F);
  static const Color card       = Color(0xFF12121A);
  static const Color elevated   = Color(0xFF1C1C28);
  static const Color surface    = Color(0xFF252535);

  // ---------------------------------------------------------------------------
  // Brand
  // ---------------------------------------------------------------------------

  /// Primary — Electric Blue
  static const Color primary  = Color(0xFF3D6FFF);

  /// Accent — Deep Purple
  static const Color purple   = Color(0xFF8B2FFF);

  /// Glow / Live indicator — Cyan
  static const Color cyan     = Color(0xFF00C2FF);

  /// Alias kept for backwards-compat — use [primary] in new code
  static const Color magenta  = Color(0xFFEC4899);

  // ---------------------------------------------------------------------------
  // Semantic
  // ---------------------------------------------------------------------------

  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error   = Color(0xFFEF4444);

  // ---------------------------------------------------------------------------
  // Text
  // ---------------------------------------------------------------------------

  static const Color textPrimary   = Color(0xFFF0F0F5);
  static const Color textSecondary = Color(0xFF6B6B80);
  static const Color textTertiary  = Color(0xFF4A4A60);
  static const Color textDisabled  = Color(0xFF333345);

  // ---------------------------------------------------------------------------
  // Borders
  // ---------------------------------------------------------------------------

  static const Color border      = Color(0xFF1C1C28);
  static const Color borderLight = Color(0xFF252535);

  // ---------------------------------------------------------------------------
  // Gradients
  // ---------------------------------------------------------------------------

  /// Primary brand gradient — Electric Blue → Deep Purple
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, purple],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Cyan glow gradient
  static const LinearGradient cyanGradient = LinearGradient(
    colors: [Color(0xFF00C2FF), Color(0xFF0090CC)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Purple → Magenta (for secondary CTAs / highlights)
  static const LinearGradient purpleGradient = LinearGradient(
    colors: [purple, Color(0xFFEC4899)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // ---------------------------------------------------------------------------
  // Category colours
  // ---------------------------------------------------------------------------

  static const Color categoryParty    = Color(0xFFEC4899);
  static const Color categoryFood     = Color(0xFFF59E0B);
  static const Color categoryHangouts = Color(0xFF10B981);
  static const Color categoryMusic    = Color(0xFF8B2FFF);
  static const Color categoryGames    = Color(0xFF3D6FFF);
  static const Color categoryArt      = Color(0xFF00C2FF);
  static const Color categoryStudy    = Color(0xFF6366F1);
  static const Color categoryPopups   = Color(0xFFF97316);

  static Color categoryColor(String category) {
    switch (category) {
      case 'party_nightlife':    return categoryParty;
      case 'food_drinks':        return categoryFood;
      case 'hangouts_social':    return categoryHangouts;
      case 'music_performance':  return categoryMusic;
      case 'games_activities':   return categoryGames;
      case 'art_culture':        return categoryArt;
      case 'study_work':         return categoryStudy;
      case 'popups_street':      return categoryPopups;
      default:                   return primary;
    }
  }

  // ---------------------------------------------------------------------------
  // Activity levels
  // ---------------------------------------------------------------------------

  static const Color activityHigh   = Color(0xFF3D6FFF);
  static const Color activityMedium = Color(0xFF8B2FFF);
  static const Color activityLow    = Color(0xFF6B6B80);

  static Color activityColor(String level) {
    switch (level) {
      case 'high':   return activityHigh;
      case 'medium': return activityMedium;
      default:       return activityLow;
    }
  }

  // ---------------------------------------------------------------------------
  // Escrow / payments
  // ---------------------------------------------------------------------------

  static const Color escrowPaid      = Color(0xFF3D6FFF);
  static const Color escrowHeld      = Color(0xFFF59E0B);
  static const Color escrowConfirmed = Color(0xFF10B981);
  static const Color escrowReleased  = Color(0xFF10B981);
  static const Color escrowRefunded  = Color(0xFFF59E0B);

  // ---------------------------------------------------------------------------
  // Preset accent swatches for the palette picker (Discord-style)
  // ---------------------------------------------------------------------------

  /// Ordered list of selectable accents shown in Settings → Appearance.
  static const List<Color> accentPresets = [
    Color(0xFF3D6FFF), // Electric Blue  (default)
    Color(0xFF8B2FFF), // Deep Purple
    Color(0xFF00C2FF), // Cyan
    Color(0xFF10B981), // Emerald
    Color(0xFFF59E0B), // Amber
    Color(0xFFEC4899), // Pink
    Color(0xFFF97316), // Orange
    Color(0xFF6366F1), // Indigo
  ];

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  static Color withOpacity(Color color, double opacity) =>
      color.withValues(alpha: opacity);
}
