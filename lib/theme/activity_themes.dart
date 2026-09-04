import 'package:flutter/material.dart';
import 'package:Dalem/theme/activity.dart';
import 'package:Dalem/theme/activity_theme.dart';

class ActivityThemes {
  // Multi-color standard category gradients (Blue, Indigo/Royal Blue, Green, Orange)
  static const List<Color> defaultGradientStrategis = [
    Color(0xFF0F172A),
    Color(0xFF1E3A5F),
  ]; // Deep Navy
  static const List<Color> defaultGradientDemografi = [
    Color(0xFF0D3D85),
    Color(0xFF2563EB),
  ]; // Royal Blue
  static const List<Color> defaultGradientLingkungan = [
    Color(0xFF065F46),
    Color(0xFF059669),
  ]; // Forest / Emerald Green
  static const List<Color> defaultGradientEkonomi = [
    Color(0xFFB84C14),
    Color(0xFFE8611A),
  ]; // Sensus Ekonomi Orange

  // 🟠 1. Sensus Ekonomi 2026 Theme
  static const ActivityTheme sensusEkonomi2026 = ActivityTheme(
    activity: BpsActivity.sensusEkonomi2026,
    activityName: 'Sensus Ekonomi 2026',
    shortBadge: 'SE2026',
    primary: Color(0xFFE8611A),
    primaryLight: Color(0xFFF28B2D),
    primaryDark: Color(0xFFA84000),
    secondary: Color(0xFFFFA726),
    cardGradient1: defaultGradientStrategis,
    cardGradient2: defaultGradientDemografi,
    cardGradient3: defaultGradientLingkungan,
    cardGradient4: defaultGradientEkonomi,
  );

  // 🟢 2. Sensus Pertanian 2023 Theme
  static const ActivityTheme sensusPertanian2023 = ActivityTheme(
    activity: BpsActivity.sensusPertanian2023,
    activityName: 'Sensus Pertanian 2023',
    shortBadge: 'ST2023',
    primary: Color(0xFF1B6B2E),
    primaryLight: Color(0xFF2E9E47),
    primaryDark: Color(0xFF145221),
    secondary: Color(0xFF66BB6A),
    cardGradient1: defaultGradientStrategis,
    cardGradient2: defaultGradientDemografi,
    cardGradient3: defaultGradientLingkungan,
    cardGradient4: defaultGradientEkonomi,
  );

  // 🔵 3. Sensus Penduduk 2020 Theme
  static const ActivityTheme sensusPenduduk2020 = ActivityTheme(
    activity: BpsActivity.sensusPenduduk2020,
    activityName: 'Sensus Penduduk 2020',
    shortBadge: 'SP2020',
    primary: Color(0xFF002B6A),
    primaryLight: Color(0xFF1A5FAF),
    primaryDark: Color(0xFF001F4E),
    secondary: Color(0xFF3B82F6),
    cardGradient1: defaultGradientStrategis,
    cardGradient2: defaultGradientDemografi,
    cardGradient3: defaultGradientLingkungan,
    cardGradient4: defaultGradientEkonomi,
  );

  // 🔷 4. Default BPS Demak Theme
  static const ActivityTheme defaultBps = ActivityTheme(
    activity: BpsActivity.defaultBps,
    activityName: 'BPS Kabupaten Demak',
    shortBadge: 'BPS Demak',
    badgeIcon: Icons.verified_rounded,
    primary: Color(0xFF002B6A),
    primaryLight: Color(0xFF1A5FAF),
    primaryDark: Color(0xFF001F4E),
    secondary: Color(0xFFD4A843),
    cardGradient1: defaultGradientStrategis,
    cardGradient2: defaultGradientDemografi,
    cardGradient3: defaultGradientLingkungan,
    cardGradient4: defaultGradientEkonomi,
  );

  static const Map<BpsActivity, ActivityTheme> allThemes = {
    BpsActivity.sensusEkonomi2026: sensusEkonomi2026,
    BpsActivity.sensusPertanian2023: sensusPertanian2023,
    BpsActivity.sensusPenduduk2020: sensusPenduduk2020,
    BpsActivity.defaultBps: defaultBps,
  };

  static ActivityTheme getTheme(BpsActivity activity) {
    return allThemes[activity] ?? defaultBps;
  }
}
