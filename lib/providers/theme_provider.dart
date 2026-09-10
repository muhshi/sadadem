import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Dalem/components/bps_theme.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themePrefKey = 'app_theme_override';
  SharedPreferences? _prefs;

  bool _isAuto = true;
  BpsActivity? _manualActivity;
  bool _isLoaded = false;

  bool get isAuto => _isAuto;
  bool get isLoaded => _isLoaded;
  BpsActivity? get manualActivity => _manualActivity;
  ActivityTheme get currentTheme => BpsTheme.current();
  ActivityTheme get autoTheme => BpsTheme.autoScheduledTheme();

  ThemeProvider({SharedPreferences? prefs}) {
    if (prefs != null) {
      _prefs = prefs;
      _applySavedPref(prefs.getString(_themePrefKey));
      _isLoaded = true;
    } else {
      _loadFromPrefs();
    }
  }

  void _applySavedPref(String? saved) {
    if (saved == null || saved.isEmpty || saved == 'auto') {
      _isAuto = true;
      _manualActivity = null;
      BpsTheme.resetToAuto();
    } else {
      try {
        final matched = BpsActivity.values.firstWhere(
          (e) => e.name == saved,
        );
        _isAuto = false;
        _manualActivity = matched;
        BpsTheme.activeActivity = matched;
      } catch (_) {
        _isAuto = true;
        _manualActivity = null;
        BpsTheme.resetToAuto();
      }
    }
  }

  Future<void> _loadFromPrefs() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _applySavedPref(_prefs?.getString(_themePrefKey));
    } catch (e) {
      debugPrint('Error loading theme preference: $e');
    } finally {
      _isLoaded = true;
      notifyListeners();
    }
  }

  Future<void> setManualTheme(BpsActivity activity) async {
    _isAuto = false;
    _manualActivity = activity;
    BpsTheme.activeActivity = activity;
    notifyListeners();

    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      await prefs.setString(_themePrefKey, activity.name);
    } catch (e) {
      debugPrint('Error saving manual theme preference: $e');
    }
  }

  Future<void> resetToAuto() async {
    _isAuto = true;
    _manualActivity = null;
    BpsTheme.resetToAuto();
    notifyListeners();

    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      await prefs.setString(_themePrefKey, 'auto');
    } catch (e) {
      debugPrint('Error saving auto theme preference: $e');
    }
  }
}
