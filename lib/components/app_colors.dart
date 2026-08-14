import 'package:flutter/material.dart';

import 'package:Dalem/components/bps_theme.dart';

class AppColors {
  // Brand Colors (Dinamis sesuai kegiatan sensus aktif BPS)
  static Color get primaryNavy => BpsTheme.current().primary;
  static Color get primaryLight => BpsTheme.current().primaryLight;
  static Color get primaryDark => BpsTheme.current().primaryDark;
  static Color get secondaryGold => BpsTheme.current().secondary;
  static LinearGradient get primaryGradient => BpsTheme.current().primaryGradient;

  // Section Accent Colors
  static const Color accentTeal = Color(0xFF14B8A6); // Infografis
  static const Color accentRose = Color(0xFFE11D48); // Berita
  static const Color accentBlue = Color(0xFF2563EB); // Demografi
  static const Color accentPurple = Color(0xFF7C3AED); // Ekonomi

  // Background & Surfaces
  static const Color backgroundScaffold = Color(0xFFF8F9FB);
  static const Color surfaceCard = Colors.white;
  static const Color borderDefault = Color(0xFFE2E8F0);

  // Typography Colors
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);

  // Shadow
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 12,
          offset: const Offset(0, 3),
        ),
      ];

  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];
}
