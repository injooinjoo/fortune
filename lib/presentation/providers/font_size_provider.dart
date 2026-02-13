import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../shared/components/app_header.dart';

class FontSizeNotifier extends StateNotifier<FontSize> {
  static const String _fontSizeKey = 'fortune_font_size';
  final SharedPreferences _prefs;

  FontSizeNotifier(this._prefs) : super(FontSize.medium) {
    _loadFontSize();
  }

  void _loadFontSize() {
    final savedSize = _prefs.getString(_fontSizeKey);
    if (savedSize != null) {
      switch (savedSize) {
        case 'small':
          state = FontSize.small;
          break;
        case 'large':
          state = FontSize.large;
          break;
        default:
          state = FontSize.medium;
      }
    }
  }

  void setFontSize(FontSize size) {
    state = size;
    _saveFontSize(size);
  }

  void _saveFontSize(FontSize size) {
    String sizeString;
    switch (size) {
      case FontSize.small:
        sizeString = 'small';
        break;
      case FontSize.large:
        sizeString = 'large';
        break;
      default:
        sizeString = 'medium';
    }
    _prefs.setString(_fontSizeKey, sizeString);
  }
}

// This provider must be overridden in the ProviderScope
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden');
});

final fontSizeProvider =
    StateNotifierProvider<FontSizeNotifier, FontSize>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return FontSizeNotifier(prefs);
});
