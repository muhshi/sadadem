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
}
