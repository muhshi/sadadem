import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Dalem/components/bps_theme.dart';
import 'package:Dalem/providers/theme_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    BpsTheme.resetToAuto();
  });

  tearDown(() {
    BpsTheme.resetToAuto();
  });

  group('ThemeProvider Tests', () {
    test('Initial state defaults to auto schedule mode', () async {
      final provider = ThemeProvider();
      await Future.delayed(Duration.zero); // Allow async prefs to load

      expect(provider.isAuto, isTrue);
      expect(provider.manualActivity, isNull);
      expect(BpsTheme.isAutoSchedule, isTrue);
      expect(provider.currentTheme.activity, equals(BpsTheme.current().activity));
      expect(provider.autoTheme.activity, equals(BpsTheme.autoScheduledTheme().activity));
    });

    test('Setting manual theme updates state, BpsTheme, and persists to prefs', () async {
      final provider = ThemeProvider();
      await Future.delayed(Duration.zero);

      var notified = false;
      provider.addListener(() {
        notified = true;
      });

      await provider.setManualTheme(BpsActivity.sensusPertanian2023);

      expect(notified, isTrue);
      expect(provider.isAuto, isFalse);
      expect(provider.manualActivity, equals(BpsActivity.sensusPertanian2023));
      expect(BpsTheme.isAutoSchedule, isFalse);
      expect(BpsTheme.activeActivity, equals(BpsActivity.sensusPertanian2023));
      expect(provider.currentTheme.activity, equals(BpsActivity.sensusPertanian2023));

      // Verify preference saved
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('app_theme_override'), equals('sensusPertanian2023'));
    });

    test('Resetting to auto restores auto schedule and updates prefs', () async {
      final provider = ThemeProvider();
      await Future.delayed(Duration.zero);

      await provider.setManualTheme(BpsActivity.sensusEkonomi2026);
      expect(provider.isAuto, isFalse);

      await provider.resetToAuto();
      expect(provider.isAuto, isTrue);
      expect(provider.manualActivity, isNull);
      expect(BpsTheme.isAutoSchedule, isTrue);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('app_theme_override'), equals('auto'));
    });

    test('Loads pre-existing manual theme override from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({
        'app_theme_override': 'sensusPenduduk2020',
      });

      final provider = ThemeProvider();
      // Wait for async _loadFromPrefs
      await Future.delayed(const Duration(milliseconds: 50));

      expect(provider.isAuto, isFalse);
      expect(provider.manualActivity, equals(BpsActivity.sensusPenduduk2020));
      expect(BpsTheme.activeActivity, equals(BpsActivity.sensusPenduduk2020));
      expect(provider.currentTheme.activity, equals(BpsActivity.sensusPenduduk2020));
    });

    test('autoTheme reflects calendar schedule even when manual override is active', () async {
      final provider = ThemeProvider();
      await Future.delayed(Duration.zero);

      await provider.setManualTheme(BpsActivity.defaultBps);
      expect(provider.currentTheme.activity, equals(BpsActivity.defaultBps));

      // autoTheme should still report the auto-scheduled theme
      expect(provider.autoTheme.activity, equals(BpsTheme.autoScheduledTheme().activity));
    });
  });
}
