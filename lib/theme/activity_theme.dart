import 'package:flutter/material.dart';
import 'package:Dalem/theme/activity.dart';

class ActivityTheme {
  final BpsActivity activity;
  final String activityName;
  final String shortBadge;
  final Color primary;
  final Color primaryLight;
  final Color primaryDark;
  final Color secondary;
  final String? logo;
  final String? description;
  final IconData badgeIcon;

  // Multi-color category card gradients (Harmonious BPS trio: Blue, Green, Orange)
  final List<Color> cardGradient1; // Data Strategis (Deep Navy/Blue)
  final List<Color> cardGradient2; // Demografi & Sosial (Rich Blue)
  final List<Color> cardGradient3; // Lingkungan Hidup (Forest Green)
  final List<Color> cardGradient4; // Ekonomi (Vibrant Orange)

  const ActivityTheme({
    required this.activity,
    required this.activityName,
    required this.shortBadge,
    required this.primary,
    required this.primaryLight,
    required this.primaryDark,
    required this.secondary,
    required this.cardGradient1,
    required this.cardGradient2,
    required this.cardGradient3,
    required this.cardGradient4,
    this.badgeIcon = Icons.campaign_rounded,
    this.logo,
    this.description,
  });

  LinearGradient get primaryGradient => LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [primary, primaryLight],
      );

  LinearGradient get heroGradient => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [primaryDark, primary, primaryLight],
      );

  /// Nama tampilan kegiatan yang tampil di UI (Appbar Home & About Page).
  /// - Default: tanpa tahun ('Sensus Ekonomi', 'Sensus Pertanian', dsb.)
  /// - Jika ingin menampilkan tahun secara otomatis: panggil dengan [showYear: true]
  /// - Jika ingin hardcode tahun manual: langsung ubah teks return pada case di bawah
  String displayName({bool showYear = false}) {
    if (showYear) return activityName;
    switch (activity) {
      case BpsActivity.sensusEkonomi2026:
        return 'Sensus Ekonomi'; // Ganti ke 'Sensus Ekonomi 2026' jika ingin hardcode tahun
      case BpsActivity.sensusPertanian2023:
        return 'Sensus Pertanian'; // Ganti ke 'Sensus Pertanian 2023' jika ingin hardcode tahun
      case BpsActivity.sensusPenduduk2020:
        return 'Sensus Penduduk'; // Ganti ke 'Sensus Penduduk 2020' jika ingin hardcode tahun
      case BpsActivity.defaultBps:
        return 'BPS Kabupaten Demak';
    }
  }

  /// Badge singkatan kegiatan (misal: 'SE', 'ST', 'SP', 'BPS').
  /// Jika ingin hardcode tahun pada badge, langsung ubah teks di bawah (misal: 'SE2026')
  String displayBadge({bool showYear = false}) {
    if (showYear) return shortBadge;
    switch (activity) {
      case BpsActivity.sensusEkonomi2026:
        return 'SE'; // Ganti ke 'SE2026' jika ingin hardcode tahun
      case BpsActivity.sensusPertanian2023:
        return 'ST'; // Ganti ke 'ST2023' jika ingin hardcode tahun
      case BpsActivity.sensusPenduduk2020:
        return 'SP'; // Ganti ke 'SP2020' jika ingin hardcode tahun
      case BpsActivity.defaultBps:
        return 'BPS';
    }
  }
}
