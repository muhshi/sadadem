import 'package:Dalem/theme/activity.dart';
import 'package:Dalem/theme/activity_theme.dart';
import 'package:Dalem/theme/activity_themes.dart';

// Export for backward compatibility & easy access
export 'package:Dalem/theme/activity.dart';
export 'package:Dalem/theme/activity_theme.dart';
export 'package:Dalem/theme/activity_themes.dart';

typedef BpsThemeData = ActivityTheme;

class BpsTheme {
  /// Override manual jika ingin mengunci tema tertentu secara paksa (misal untuk testing).
  /// Bernilai null secara default agar tema berjalan otomatis mengikuti kalender agenda BPS.
  static BpsActivity? _manualOverride;

  // Preset shortcut themes
  static const ActivityTheme orangeTheme = ActivityThemes.sensusEkonomi2026;
  static const ActivityTheme greenTheme = ActivityThemes.sensusPertanian2023;
  static const ActivityTheme blueTheme = ActivityThemes.sensusPenduduk2020;
  static const ActivityTheme defaultTheme = ActivityThemes.defaultBps;

  /// Batas akhir masa sweeping & pemeriksaan kualitas data Sensus Ekonomi 2026:
  /// 15 September 2026 pukul 23:59:59 WIB.
  /// Mulai 16 September 2026, tema otomatis kembali ke Default BPS Demak (Navy & Gold).
  static final DateTime se2026SweepingEnd = DateTime(2026, 9, 15, 23, 59, 59);

  /// Mengambil tema aktif berbasis kegiatan & kalender agenda BPS (Auto-Schedule)
  static ActivityTheme current({BpsActivity? activity, DateTime? customDate}) {
    if (activity != null) {
      return ActivityThemes.getTheme(activity);
    }

    if (_manualOverride != null) {
      return ActivityThemes.getTheme(_manualOverride!);
    }

    final date = customDate ?? DateTime.now();

    // 1. Tahun 2026: Sensus Ekonomi 2026 (Aktif hingga akhir sweeping 15 September 2026)
    if (date.year == 2026) {
      if (date.isBefore(se2026SweepingEnd) || date.isAtSameMomentAs(se2026SweepingEnd)) {
        return ActivityThemes.sensusEkonomi2026;
      }
      // Mulai 16 September 2026: Kembali ke tema resmi BPS Kabupaten Demak
      return ActivityThemes.defaultBps;
    }

    // 2. Siklus Sensus 10 Tahunan BPS Berikutnya:
    final lastDigit = date.year % 10;
    if (lastDigit == 0) return ActivityThemes.sensusPenduduk2020;  // Sensus Penduduk (e.g. 2030)
    if (lastDigit == 3) return ActivityThemes.sensusPertanian2023; // Sensus Pertanian (e.g. 2033)
    if (lastDigit == 6) return ActivityThemes.sensusEkonomi2026;   // Sensus Ekonomi (e.g. 2036)

    // 3. Tahun reguler di luar siklus sensus besar:
    return ActivityThemes.defaultBps;
  }

  /// Getter & setter untuk kompatibilitas kode yang memanggil atau mengubah activeActivity
  static BpsActivity get activeActivity => current().activity;

  static set activeActivity(BpsActivity activity) {
    _manualOverride = activity;
  }

  /// Reset override manual agar kembali ke jadwal kalender otomatis
  static void resetToAuto() {
    _manualOverride = null;
  }

  /// Mengecek apakah tema saat ini berjalan dalam mode otomatis
  static bool get isAutoSchedule => _manualOverride == null;
}
