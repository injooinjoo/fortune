import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Theme mode state provider
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.dark) {
    _loadThemePreference();
  }

  static const String _themeKey = 'theme_mode';

  // Load saved theme preference
  Future<void> _loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getString(_themeKey);
      
      if (savedTheme != null) {
        switch (savedTheme) {
          case 'light':
            state = ThemeMode.light;
            break;
          case 'dark':
            state = ThemeMode.dark;
            break;
          case 'system':
          default:
            state = ThemeMode.system;
            break;
        }
      } else {
        // If no saved preference, default to dark theme (Neon Dark)
        state = ThemeMode.dark;
      }
      
      // Force a rebuild after loading to ensure correct theme is applied
      WidgetsBinding.instance.addPostFrameCallback((_) {
        state = state; // Trigger state change to force rebuild
      });
    } catch (e) {
      debugPrint('Error loading theme preference: $e');
    }
  }

  // Set theme mode and save preference
  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      String themeString;
      
      switch (mode) {
        case ThemeMode.light:
          themeString = 'light';
          break;
        case ThemeMode.dark:
          themeString = 'dark';
          break;
        case ThemeMode.system:
          themeString = 'system';
          break;
      }
      
      await prefs.setString(_themeKey, themeString);
    } catch (e) {
      debugPrint('Error loading theme preference: $e');
    }
  }

  // Toggle between light and dark theme (ignoring system,
  void toggleTheme() {
    if (state == ThemeMode.dark) {
      setThemeMode(ThemeMode.light);
    } else {
      setThemeMode(ThemeMode.dark);
    }
  }

  // Get the actual theme brightness based on context
  Brightness getActualBrightness(BuildContext context) {
    switch (state) {
      case ThemeMode.light:
        return Brightness.light;
      case ThemeMode.dark:
        return Brightness.dark;
      case ThemeMode.system:
        return MediaQuery.of(context).platformBrightness;
    }
  }

  // Check if currently in dark mode
  bool isDarkMode(BuildContext context) {
    return getActualBrightness(context) == Brightness.dark;
  }
}