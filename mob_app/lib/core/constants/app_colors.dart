import 'package:flutter/material.dart';


class AppColors {
  AppColors._();


  static const Color background = Color(0xFF0A0E1A);
  static const Color card = Color(0xFF111827);
  static const Color elevated = Color(0xFF1F2937);
  static const Color surface = Color(0xFF374151);


  static const Color cyan = Color(0xFF00F0FF);
  static const Color purple = Color(0xFFA855F7);
  static const Color magenta = Color(0xFFEC4899);


  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);


  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color textTertiary = Color(0xFF6B7280);
  static const Color textDisabled = Color(0xFF4B5563);


  static const Color border = Color(0xFF1F2937);
  static const Color borderLight = Color(0xFF374151);


  static const LinearGradient primaryGradient = LinearGradient(
    colors: [cyan, purple],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient cyanGradient = LinearGradient(
    colors: [Color(0xFF00F0FF), Color(0xFF00C4CC)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient magentaGradient = LinearGradient(
    colors: [Color(0xFFEC4899), Color(0xFFA855F7)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );


  static const Color categoryParty = Color(0xFFEC4899);
  static const Color categoryFood = Color(0xFFF59E0B);
  static const Color categoryHangouts = Color(0xFF10B981);
  static const Color categoryMusic = Color(0xFFA855F7);
  static const Color categoryGames = Color(0xFF3B82F6);
  static const Color categoryArt = Color(0xFF00F0FF);
  static const Color categoryStudy = Color(0xFF6366F1);
  static const Color categoryPopups = Color(0xFFF97316);


  static Color categoryColor(String category) {
    switch (category) {
      case 'party_nightlife':
        return categoryParty;
      case 'food_drinks':
        return categoryFood;
      case 'hangouts_social':
        return categoryHangouts;
      case 'music_performance':
        return categoryMusic;
      case 'games_activities':
        return categoryGames;
      case 'art_culture':
        return categoryArt;
      case 'study_work':
        return categoryStudy;
      case 'popups_street':
        return categoryPopups;
      default:
        return cyan;
    }
  }


  static const Color activityHigh = Color(0xFF00F0FF);
  static const Color activityMedium = Color(0xFFA855F7);
  static const Color activityLow = Color(0xFF6B7280);


  static Color activityColor(String level) {
    switch (level) {
      case 'high':
        return activityHigh;
      case 'medium':
        return activityMedium;
      case 'low':
      default:
        return activityLow;
    }
  }


  static const Color escrowPaid = Color(0xFF00F0FF);
  static const Color escrowHeld = Color(0xFFF59E0B);
  static const Color escrowConfirmed = Color(0xFF10B981);
  static const Color escrowReleased = Color(0xFF10B981);
  static const Color escrowRefunded = Color(0xFFF59E0B);


  static Color withValues(Color color, double opacity) =>
      color.withValues(alpha: opacity);
}
