import 'package:flutter/material.dart';

enum BpsActivity {
  sensusEkonomi,
  sensusPertanian,
  sensusPenduduk,
  defaultBps,
}

class BpsThemeData {
  final BpsActivity activity;
  final String activityName;
  final Color primary;
  final Color primaryLight;
  final Color primaryDark;
  final Color secondary;

  // Kategori card gradients (4 variasi shade: gelap → terang)
  final List<Color> cardGradient1; // Data Strategis (paling gelap)
  final List<Color> cardGradient2; // Demografi & Sosial
  final List<Color> cardGradient3; // Lingkungan Hidup
  final List<Color> cardGradient4; // Ekonomi (paling terang)

  const BpsThemeData({
    required this.activity,
    required this.activityName,
    required this.primary,
    required this.primaryLight,
    required this.primaryDark,
    required this.secondary,
    required this.cardGradient1,
    required this.cardGradient2,
    required this.cardGradient3,
    required this.cardGradient4,
  });

  LinearGradient get primaryGradient => LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [primary, primaryLight],
      );
}

class BpsTheme {
  // 🟠 Tema Sensus Ekonomi (Orange)
  static const BpsThemeData orangeTheme = BpsThemeData(
    activity: BpsActivity.sensusEkonomi,
    activityName: 'Sensus Ekonomi',
    primary: Color(0xFFE8611A),
    primaryLight: Color(0xFFF28B2D),
    primaryDark: Color(0xFFA84000),
    secondary: Color(0xFFFFA726),
    cardGradient1: [Color(0xFF5C2510), Color(0xFF8B3A15)], // Deep burnt
    cardGradient2: [Color(0xFFB84C14), Color(0xFFD4611A)], // Rich orange
    cardGradient3: [Color(0xFFE8611A), Color(0xFFF28B2D)], // Primary vibrant
    cardGradient4: [Color(0xFFF09030), Color(0xFFFFB74D)], // Warm amber
  );

  // 🟢 Tema Sensus Pertanian (Hijau)
  static const BpsThemeData greenTheme = BpsThemeData(
    activity: BpsActivity.sensusPertanian,
    activityName: 'Sensus Pertanian',
    primary: Color(0xFF1B6B2E),
    primaryLight: Color(0xFF2E9E47),
    primaryDark: Color(0xFF145221),
    secondary: Color(0xFF66BB6A),
    cardGradient1: [Color(0xFF0D3818), Color(0xFF145221)], // Deep forest
    cardGradient2: [Color(0xFF1B6B2E), Color(0xFF238636)], // Rich green
    cardGradient3: [Color(0xFF2E9E47), Color(0xFF43A854)], // Primary vibrant
    cardGradient4: [Color(0xFF4CAF50), Color(0xFF66BB6A)], // Fresh lime
  );

  // 🔵 Tema Sensus Penduduk & Default BPS (Biru)
  static const BpsThemeData blueTheme = BpsThemeData(
    activity: BpsActivity.defaultBps,
    activityName: 'BPS Demak',
    primary: Color(0xFF002B6A),
    primaryLight: Color(0xFF1A5FAF),
    primaryDark: Color(0xFF001F4E),
    secondary: Color(0xFFD4A843),
    cardGradient1: [Color(0xFF0A1628), Color(0xFF132040)], // Deep navy
    cardGradient2: [Color(0xFF002B6A), Color(0xFF0D3D85)], // Rich blue
    cardGradient3: [Color(0xFF1A5FAF), Color(0xFF2872C4)], // Primary vibrant
    cardGradient4: [Color(0xFF3B82F6), Color(0xFF60A5FA)], // Sky blue
  );

  /// Menentukan tema aktif secara otomatis berdasarkan tahun berjalan
  static BpsThemeData current({DateTime? customDate}) {
    final date = customDate ?? DateTime.now();
    final year = date.year;
    final lastDigit = year % 10;

    // Tahun berakhiran 6 (misal 2026, 2036) -> Sensus Ekonomi (Orange)
    if (lastDigit == 6) {
      return orangeTheme;
    }
    // Tahun berakhiran 3 (misal 2023, 2033) -> Sensus Pertanian (Hijau)
    if (lastDigit == 3) {
      return greenTheme;
    }
    // Tahun berakhiran 0 (misal 2020, 2030) -> Sensus Penduduk (Biru)
    if (lastDigit == 0) {
      return blueTheme;
    }

    // Default BPS (Biru) untuk tahun-tahun non-sensus
    return blueTheme;
  }
}
