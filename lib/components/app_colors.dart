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

  // Structural & Sub-page Colors (30% Rule - Netral & Elegan)
  static const Color slateDark = Color(0xFF0F172A);
  static const Color slateMedium = Color(0xFF1E293B);
  static const Color slateLight = Color(0xFF334155);

  static LinearGradient get subAppBarGradient => const LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [slateDark, slateMedium],
      );

  // Navigation & Interactive States
  static const Color navSelected = Color(0xFF0F172A);
  static const Color navUnselected = Color(0xFF64748B);
  static const Color navIndicator = Color(0xFFF1F5F9);
  static const Color linkAction = Color(0xFF2563EB); // Clean action blue

  // Feature Identifiers & Badges (KBLI & KBJI)
  static const Color kbliPrimary = Color(0xFF1D4ED8);
  static const Color kbliSurface = Color(0xFFEFF6FF);
  static const Color kbliBorder = Color(0xFFBFDBFE);
  static const Color kbliText = Color(0xFF1E40AF);

  static const Color kbjiPrimary = Color(0xFF047857);
  static const Color kbjiSurface = Color(0xFFECFDF5);
  static const Color kbjiBorder = Color(0xFFA7F3D0);
  static const Color kbjiText = Color(0xFF065F46);

  // Status & Connectivity States
  static const Color statusOnline = Color(0xFF059669);
  static const Color statusOnlineGlow = Color(0xFF34D399);
  static const Color statusOnlineSurface = Color(0xFFECFDF5);

  static const Color statusOffline = Color(0xFFD97706);
  static const Color statusOfflineGlow = Color(0xFFFBBF24);
  static const Color statusOfflineSurface = Color(0xFFFFFBEB);

  // Campaign & Sensus Activity Accents
  static const Color campaignOrange = Color(0xFFEA580C);
  static const Color campaignOrangeSurface = Color(0xFFFFF7ED);
  static const Color campaignOrangeBorder = Color(0xFFFFEDD5);

  // Hero Gradients
  static const LinearGradient heroNavyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0F172A),
      Color(0xFF1E293B),
      Color(0xFF1E3A5F),
    ],
  );

  // Shadows
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
