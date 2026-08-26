import 'package:Dalem/theme/activity.dart';
import 'package:Dalem/theme/activity_theme.dart';
import 'package:Dalem/theme/activity_themes.dart';

// Export for backward compatibility & easy access
export 'package:Dalem/theme/activity.dart';
export 'package:Dalem/theme/activity_theme.dart';
export 'package:Dalem/theme/activity_themes.dart';

typedef BpsThemeData = ActivityTheme;

class BpsTheme {
  /// Kegiatan BPS yang sedang aktif (bisa diubah kapan saja tanpa menunggu tahun berubah)
  static BpsActivity activeActivity = BpsActivity.sensusEkonomi2026;

  // Preset shortcut themes
  static const ActivityTheme orangeTheme = ActivityThemes.sensusEkonomi2026;
  static const ActivityTheme greenTheme = ActivityThemes.sensusPertanian2023;
  static const ActivityTheme blueTheme = ActivityThemes.sensusPenduduk2020;
  static const ActivityTheme defaultTheme = ActivityThemes.defaultBps;

  /// Mengambil tema aktif berbasis kegiatan (Activity-Based Theme)
  static ActivityTheme current({BpsActivity? activity, DateTime? customDate}) {
    if (activity != null) {
      return ActivityThemes.getTheme(activity);
    }

    // Jika customDate disediakan (misal untuk testing transisi historis)
    if (customDate != null) {
      final lastDigit = customDate.year % 10;
      if (lastDigit == 6) return ActivityThemes.sensusEkonomi2026;
      if (lastDigit == 3) return ActivityThemes.sensusPertanian2023;
      if (lastDigit == 0) return ActivityThemes.sensusPenduduk2020;
      return ActivityThemes.defaultBps;
    }

    // Menggunakan kegiatan aktif saat ini
    return ActivityThemes.getTheme(activeActivity);
  }
}
