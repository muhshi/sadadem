import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Dalem/about/about_page.dart';
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

  Widget createWidgetUnderTest(ThemeProvider themeProvider) {
    return ChangeNotifierProvider<ThemeProvider>.value(
      value: themeProvider,
      child: const MaterialApp(
        home: AboutPage(),
      ),
    );
  }

  testWidgets('AboutPage renders theme selection section and handles taps',
      (WidgetTester tester) async {
    final themeProvider = ThemeProvider();
    await tester.pumpWidget(createWidgetUnderTest(themeProvider));
    await tester.pumpAndSettle();

    // Verify Theme Section Header
    expect(find.text('Tema Tampilan Aplikasi'), findsOneWidget);
    expect(find.text('Otomatis'), findsOneWidget);
    expect(find.text('Rekomendasi'), findsOneWidget);
    expect(find.text('Atau Pilih Tema Khusus:'), findsOneWidget);

    // Verify 4 manual theme cards are rendered
    expect(find.text('Sensus Pertanian'), findsWidgets);
    expect(find.text('Sensus Ekonomi'), findsWidgets);
    expect(find.text('Sensus Penduduk'), findsWidgets);
    expect(find.text('BPS Kabupaten Demak'), findsWidgets);

    // Initially in auto mode
    expect(themeProvider.isAuto, isTrue);

    // Tap on Sensus Pertanian card
    final pertanianCard = find.text('Sensus Pertanian').last;
    await tester.ensureVisible(pertanianCard);
    await tester.pumpAndSettle();
    await tester.tap(pertanianCard);
    await tester.pumpAndSettle();

    // Verify themeProvider switched to manual ST2023
    expect(themeProvider.isAuto, isFalse);
    expect(themeProvider.manualActivity, equals(BpsActivity.sensusPertanian2023));

    // Tap back on "Otomatis"
    final autoOption = find.text('Otomatis');
    await tester.ensureVisible(autoOption);
    await tester.pumpAndSettle();
    await tester.tap(autoOption);
    await tester.pumpAndSettle();

    // Verify themeProvider switched back to auto
    expect(themeProvider.isAuto, isTrue);
    expect(themeProvider.manualActivity, isNull);
  });
}
