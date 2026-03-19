import 'package:flutter/material.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../core/fortune/fortune_type_registry.dart';
import '../../domain/models/ai_character.dart';

const String kCharacterChatDefaultThemeType = 'default';
const String kCharacterChatLightTextureAsset =
    'assets/textures/hanji_light.webp';
const String kCharacterChatDarkTextureAsset = 'assets/textures/hanji_dark.webp';

@immutable
class CharacterChatThemeSpec {
  const CharacterChatThemeSpec({
    required this.themeKey,
    required this.fortuneType,
    required this.gradientColors,
    required this.scrimOpacity,
    this.backgroundAsset,
    this.textureAsset,
    this.gradientBegin = Alignment.topCenter,
    this.gradientEnd = Alignment.bottomCenter,
    this.accentTint,
    this.imageOpacity = 1,
    this.textureOpacity = 0,
  });

  final String themeKey;
  final String fortuneType;
  final String? backgroundAsset;
  final String? textureAsset;
  final List<Color> gradientColors;
  final Alignment gradientBegin;
  final Alignment gradientEnd;
  final Color? accentTint;
  final double imageOpacity;
  final double textureOpacity;
  final double scrimOpacity;

  bool get hasBackgroundAsset => backgroundAsset != null;
  bool get usesTextureFallback => textureAsset != null;
}

CharacterChatThemeSpec resolveCharacterChatTheme({
  required Brightness brightness,
  required AiCharacter character,
  String? fortuneType,
}) {
  final palette = _ThemePalette.fromBrightness(brightness);
  final normalizedType = _normalizedFortuneType(
    fortuneType: fortuneType,
    character: character,
  );

  switch (normalizedType) {
    case 'daily':
      return _assetTheme(
        palette: palette,
        character: character,
        fortuneType: normalizedType,
        assetName: 'bg_daily.webp',
        tint: _tone(
          palette.info,
          hueShift: -18,
          saturationShift: 0.06,
        ),
      );
    case 'daily-calendar':
      return _assetTheme(
        palette: palette,
        character: character,
        fortuneType: normalizedType,
        assetName: 'bg_time.webp',
        tint: _tone(
          palette.info,
          hueShift: 10,
          saturationShift: 0.08,
        ),
      );
    case 'fortune-cookie':
      return _assetTheme(
        palette: palette,
        character: character,
        fortuneType: normalizedType,
        assetName: 'bg_fortune_cookie.webp',
        tint: _tone(
          palette.warning,
          lightnessShift: 0.04,
          saturationShift: 0.06,
        ),
      );
    case 'traditional-saju':
      return _assetTheme(
        palette: palette,
        character: character,
        fortuneType: normalizedType,
        assetName: 'bg_traditional.webp',
        tint: _mix(
          _tone(palette.warning, lightnessShift: -0.04),
          _tone(palette.accentTertiary, lightnessShift: -0.08),
          0.45,
        ),
      );
    case 'face-reading':
      return _assetTheme(
        palette: palette,
        character: character,
        fortuneType: normalizedType,
        assetName: 'bg_face_reading.webp',
        tint: _tone(
          palette.accentSecondary,
          hueShift: 22,
          saturationShift: 0.08,
        ),
      );
    case 'talent':
      return _assetTheme(
        palette: palette,
        character: character,
        fortuneType: normalizedType,
        assetName: 'bg_talent.webp',
        tint: _tone(
          palette.accentSecondary,
          hueShift: 48,
          saturationShift: 0.12,
        ),
      );
    case 'love':
      return _assetTheme(
        palette: palette,
        character: character,
        fortuneType: normalizedType,
        assetName: 'bg_love.webp',
        tint: _mix(
          _tone(palette.error, hueShift: -8),
          _tone(palette.warning, hueShift: 18),
          0.22,
        ),
      );
    case 'compatibility':
      return _assetTheme(
        palette: palette,
        character: character,
        fortuneType: normalizedType,
        assetName: 'bg_compatibility.webp',
        tint: _mix(
          _tone(palette.accentSecondary, hueShift: 52),
          _tone(palette.error, hueShift: -12, lightnessShift: 0.04),
          0.38,
        ),
      );
    case 'avoid-people':
      return _assetTheme(
        palette: palette,
        character: character,
        fortuneType: normalizedType,
        assetName: 'bg_avoid_people.webp',
        tint: _tone(
          palette.error,
          hueShift: 14,
          lightnessShift: -0.06,
        ),
      );
    case 'career':
      return _assetTheme(
        palette: palette,
        character: character,
        fortuneType: normalizedType,
        assetName: 'bg_career.webp',
        tint: _mix(
          _tone(palette.info, hueShift: -10),
          _tone(palette.success, hueShift: -28),
          0.3,
        ),
      );
    case 'wealth':
      return _assetTheme(
        palette: palette,
        character: character,
        fortuneType: normalizedType,
        assetName: 'bg_money.webp',
        tint: _mix(
          _tone(palette.warning, saturationShift: 0.08),
          _tone(palette.accentTertiary, lightnessShift: -0.04),
          0.48,
        ),
      );
    case 'exam':
      return _assetTheme(
        palette: palette,
        character: character,
        fortuneType: normalizedType,
        assetName: 'bg_exam.webp',
        tint: _mix(
          _tone(palette.info, hueShift: 4),
          _tone(palette.success, hueShift: -12),
          0.45,
        ),
      );
    case 'lucky-items':
      return _assetTheme(
        palette: palette,
        character: character,
        fortuneType: normalizedType,
        assetName: 'bg_lucky_items.webp',
        tint: _mix(
          _tone(palette.warning, lightnessShift: 0.06),
          _tone(palette.success, hueShift: -18),
          0.32,
        ),
      );
    case 'lotto':
      return _assetTheme(
        palette: palette,
        character: character,
        fortuneType: normalizedType,
        assetName: 'bg_lotto.webp',
        tint: _mix(
          _tone(palette.warning, saturationShift: 0.1),
          _tone(palette.accentSecondary, hueShift: 18),
          0.3,
        ),
      );
    case 'match-insight':
      return _assetTheme(
        palette: palette,
        character: character,
        fortuneType: normalizedType,
        assetName: 'bg_sports_game.webp',
        tint: _mix(
          _tone(palette.success, saturationShift: 0.14),
          _tone(palette.info, hueShift: -6),
          0.42,
        ),
      );
    case 'game-enhance':
      return _assetTheme(
        palette: palette,
        character: character,
        fortuneType: normalizedType,
        assetName: 'bg_sports_game.webp',
        tint: _mix(
          _tone(palette.accentSecondary, hueShift: 56, saturationShift: 0.12),
          _tone(palette.info, hueShift: 6),
          0.34,
        ),
      );
    case 'tarot':
      return _assetTheme(
        palette: palette,
        character: character,
        fortuneType: normalizedType,
        assetName: 'bg_tarot.webp',
        tint: _tone(
          palette.accentSecondary,
          hueShift: 62,
          lightnessShift: -0.02,
        ),
      );
    case 'dream':
      return _assetTheme(
        palette: palette,
        character: character,
        fortuneType: normalizedType,
        assetName: 'bg_dream.webp',
        tint: _mix(
          _tone(palette.info, hueShift: 28),
          _tone(palette.accentSecondary, hueShift: 68),
          0.36,
        ),
      );
    case 'health':
      return _assetTheme(
        palette: palette,
        character: character,
        fortuneType: normalizedType,
        assetName: 'bg_health.webp',
        tint: _mix(
          _tone(palette.success, saturationShift: 0.08),
          _tone(palette.info, hueShift: -18),
          0.22,
        ),
      );
    case 'biorhythm':
      return _assetTheme(
        palette: palette,
        character: character,
        fortuneType: normalizedType,
        assetName: 'bg_biorhythm.webp',
        tint: _mix(
          _tone(palette.accentSecondary, hueShift: 34),
          _tone(palette.success, hueShift: -26),
          0.34,
        ),
      );
    case 'family':
      return _assetTheme(
        palette: palette,
        character: character,
        fortuneType: normalizedType,
        assetName: 'bg_family.webp',
        tint: _mix(
          _tone(palette.warning, lightnessShift: 0.02),
          _tone(palette.accentTertiary, hueShift: -6),
          0.4,
        ),
      );
    case 'pet-compatibility':
      return _assetTheme(
        palette: palette,
        character: character,
        fortuneType: normalizedType,
        assetName: 'bg_pet.webp',
        tint: _mix(
          _tone(palette.success, hueShift: -16),
          _tone(palette.warning, lightnessShift: 0.08),
          0.26,
        ),
      );
    case 'talisman':
      return _assetTheme(
        palette: palette,
        character: character,
        fortuneType: normalizedType,
        assetName: 'bg_talisman.webp',
        tint: _mix(
          _tone(palette.warning, saturationShift: 0.12),
          _tone(palette.accentSecondary, hueShift: 22),
          0.28,
        ),
      );
    case 'wish':
      return _assetTheme(
        palette: palette,
        character: character,
        fortuneType: normalizedType,
        assetName: 'bg_wish.webp',
        tint: _mix(
          _tone(palette.accentTertiary, lightnessShift: 0.06),
          _tone(palette.warning, lightnessShift: -0.02),
          0.42,
        ),
      );
    case 'new-year':
      return _fallbackTheme(
        palette: palette,
        character: character,
        fortuneType: normalizedType,
        start: _tone(
          palette.info,
          hueShift: -26,
          saturationShift: 0.1,
          lightnessShift: -0.12,
        ),
        end: _tone(
          palette.warning,
          saturationShift: 0.08,
          lightnessShift: -0.05,
        ),
        tint: _tone(palette.warning, lightnessShift: 0.04),
      );
    case 'naming':
      return _fallbackTheme(
        palette: palette,
        character: character,
        fortuneType: normalizedType,
        start: _tone(
          palette.warning,
          saturationShift: -0.22,
          lightnessShift: 0.28,
        ),
        end: _tone(
          palette.textPrimary,
          saturationShift: -1,
        ),
        tint: _tone(
          palette.warning,
          saturationShift: -0.12,
          lightnessShift: 0.06,
        ),
      );
    case 'zodiac':
      return _fallbackTheme(
        palette: palette,
        character: character,
        fortuneType: normalizedType,
        start: _tone(
          palette.accentSecondary,
          hueShift: 34,
          saturationShift: 0.12,
        ),
        end: _tone(
          palette.info,
          hueShift: 18,
          lightnessShift: -0.18,
        ),
        tint: _tone(palette.accentSecondary, hueShift: 48),
      );
    case 'zodiac-animal':
      return _fallbackTheme(
        palette: palette,
        character: character,
        fortuneType: normalizedType,
        start: _tone(
          palette.error,
          hueShift: -6,
          lightnessShift: -0.04,
        ),
        end: _tone(
          palette.warning,
          lightnessShift: -0.02,
        ),
        tint: _tone(palette.warning, lightnessShift: 0.04),
      );
    case 'birthstone':
      return _fallbackTheme(
        palette: palette,
        character: character,
        fortuneType: normalizedType,
        start: _tone(
          palette.success,
          hueShift: 16,
          saturationShift: 0.12,
        ),
        end: _tone(
          palette.accentSecondary,
          hueShift: 62,
          saturationShift: 0.14,
        ),
        tint: _tone(palette.accentSecondary, hueShift: 42),
      );
    case 'mbti':
      return _fallbackTheme(
        palette: palette,
        character: character,
        fortuneType: normalizedType,
        start: _tone(
          palette.accentSecondary,
          hueShift: 58,
          saturationShift: 0.16,
        ),
        end: _tone(
          palette.info,
          hueShift: 2,
          saturationShift: 0.1,
        ),
        tint: _tone(palette.accentSecondary, hueShift: 46),
      );
    case 'personality-dna':
      return _fallbackTheme(
        palette: palette,
        character: character,
        fortuneType: normalizedType,
        start: _tone(
          palette.error,
          hueShift: 118,
          saturationShift: 0.06,
          lightnessShift: -0.08,
        ),
        end: _tone(
          palette.info,
          hueShift: -8,
          saturationShift: 0.16,
        ),
        tint: _tone(palette.accentSecondary, hueShift: 70),
      );
    case 'past-life':
      return _fallbackTheme(
        palette: palette,
        character: character,
        fortuneType: normalizedType,
        start: _tone(
          palette.accentSecondary,
          hueShift: 74,
          lightnessShift: -0.16,
        ),
        end: _tone(
          palette.accentTertiary,
          saturationShift: -0.12,
          lightnessShift: -0.1,
        ),
        tint: _tone(palette.accentSecondary, hueShift: 82),
      );
    case 'blind-date':
      return _fallbackTheme(
        palette: palette,
        character: character,
        fortuneType: normalizedType,
        start: _tone(
          palette.warning,
          lightnessShift: 0.16,
          saturationShift: 0.02,
        ),
        end: _tone(
          palette.error,
          lightnessShift: 0.18,
          saturationShift: -0.02,
        ),
        tint: _tone(palette.error, lightnessShift: 0.1),
      );
    case 'ex-lover':
      return _fallbackTheme(
        palette: palette,
        character: character,
        fortuneType: normalizedType,
        start: _tone(
          palette.accentSecondary,
          hueShift: 84,
          saturationShift: -0.02,
          lightnessShift: 0.02,
        ),
        end: _mix(
          palette.surface,
          palette.textSecondary,
          0.52,
        ),
        tint: _tone(palette.error, hueShift: 90, lightnessShift: -0.02),
      );
    case 'celebrity':
      return _fallbackTheme(
        palette: palette,
        character: character,
        fortuneType: normalizedType,
        start: _tone(
          palette.warning,
          saturationShift: -0.08,
          lightnessShift: 0.2,
        ),
        end: _tone(
          palette.accentTertiary,
          lightnessShift: 0.1,
          saturationShift: -0.06,
        ),
        tint: _tone(palette.warning, lightnessShift: 0.12),
      );
    case 'yearly-encounter':
      return _fallbackTheme(
        palette: palette,
        character: character,
        fortuneType: normalizedType,
        start: _tone(
          palette.accentSecondary,
          hueShift: 70,
          lightnessShift: -0.12,
        ),
        end: _tone(
          palette.warning,
          lightnessShift: -0.02,
        ),
        tint: _tone(palette.warning, lightnessShift: 0.06),
      );
    case 'ootd-evaluation':
      return _fallbackTheme(
        palette: palette,
        character: character,
        fortuneType: normalizedType,
        start: _tone(
          palette.success,
          hueShift: 34,
          saturationShift: 0.14,
          lightnessShift: 0.04,
        ),
        end: _tone(
          palette.warning,
          hueShift: -8,
          lightnessShift: 0.08,
        ),
        tint: _tone(palette.warning, lightnessShift: 0.1),
      );
    case 'exercise':
      return _fallbackTheme(
        palette: palette,
        character: character,
        fortuneType: normalizedType,
        start: _tone(
          palette.success,
          saturationShift: 0.08,
        ),
        end: _tone(
          palette.info,
          hueShift: 12,
          saturationShift: 0.06,
        ),
        tint: _tone(palette.success, lightnessShift: 0.04),
      );
    case 'moving':
      return _fallbackTheme(
        palette: palette,
        character: character,
        fortuneType: normalizedType,
        start: _tone(
          palette.success,
          hueShift: 8,
          saturationShift: -0.02,
        ),
        end: _tone(
          palette.warning,
          saturationShift: -0.12,
          lightnessShift: 0.08,
        ),
        tint: _tone(palette.success, lightnessShift: 0.04),
      );
    default:
      return _defaultTheme(
        palette: palette,
        character: character,
      );
  }
}

String _normalizedFortuneType({
  required String? fortuneType,
  required AiCharacter character,
}) {
  if (fortuneType == null || fortuneType.isEmpty) {
    return kCharacterChatDefaultThemeType;
  }

  if (!FortuneTypeRegistry.contains(fortuneType)) {
    return kCharacterChatDefaultThemeType;
  }

  if (!character.isFortuneExpert ||
      !character.specialties.contains(fortuneType)) {
    return kCharacterChatDefaultThemeType;
  }

  return fortuneType;
}

CharacterChatThemeSpec _defaultTheme({
  required _ThemePalette palette,
  required AiCharacter character,
}) {
  final accent = _tone(
    character.accentColor,
    saturationShift: 0.04,
  );

  return CharacterChatThemeSpec(
    themeKey: '${character.id}:$kCharacterChatDefaultThemeType',
    fortuneType: kCharacterChatDefaultThemeType,
    textureAsset: _textureAssetForPalette(palette),
    gradientColors: [
      _gradientColor(
        _mix(palette.surface, accent, palette.isDark ? 0.08 : 0.05),
        palette: palette,
        strength: 0.08,
      ),
      _gradientColor(
        _mix(palette.background, palette.surface, palette.isDark ? 0.2 : 0.12),
        palette: palette,
        strength: 0.02,
      ),
    ],
    accentTint: _overlayTint(
      _mix(accent, palette.accentSecondary, 0.1),
      opacity: palette.isDark ? 0.05 : 0.03,
    ),
    textureOpacity: palette.isDark ? 0.16 : 0.1,
    scrimOpacity: palette.isDark ? 0.12 : 0.05,
  );
}

CharacterChatThemeSpec _assetTheme({
  required _ThemePalette palette,
  required AiCharacter character,
  required String fortuneType,
  required String assetName,
  required Color tint,
}) {
  final tonedTint = _tone(tint, saturationShift: 0.02);

  return CharacterChatThemeSpec(
    themeKey: '${character.id}:$fortuneType',
    fortuneType: fortuneType,
    backgroundAsset: _assetPath(assetName),
    textureAsset: _textureAssetForPalette(palette),
    gradientColors: [
      _gradientColor(
        _mix(palette.surface, tonedTint, palette.isDark ? 0.1 : 0.06),
        palette: palette,
        strength: 0.06,
      ),
      _gradientColor(
        _mix(palette.background, palette.surface, palette.isDark ? 0.18 : 0.1),
        palette: palette,
        strength: 0.02,
      ),
    ],
    accentTint: _overlayTint(
      tonedTint,
      opacity: palette.isDark ? 0.07 : 0.04,
    ),
    imageOpacity: palette.isDark ? 0.2 : 0.12,
    textureOpacity: palette.isDark ? 0.16 : 0.1,
    scrimOpacity: palette.isDark ? 0.16 : 0.06,
  );
}

CharacterChatThemeSpec _fallbackTheme({
  required _ThemePalette palette,
  required AiCharacter character,
  required String fortuneType,
  required Color start,
  required Color end,
  required Color tint,
}) {
  return CharacterChatThemeSpec(
    themeKey: '${character.id}:$fortuneType',
    fortuneType: fortuneType,
    textureAsset: _textureAssetForPalette(palette),
    gradientColors: [
      _gradientColor(
        _mix(palette.surface, start, palette.isDark ? 0.1 : 0.06),
        palette: palette,
        strength: 0.06,
      ),
      _gradientColor(
        _mix(palette.background, end, palette.isDark ? 0.08 : 0.05),
        palette: palette,
        strength: 0.02,
      ),
    ],
    accentTint: _overlayTint(
      tint,
      opacity: palette.isDark ? 0.06 : 0.04,
    ),
    textureOpacity: palette.isDark ? 0.16 : 0.1,
    scrimOpacity: palette.isDark ? 0.14 : 0.06,
  );
}

String _assetPath(String fileName) =>
    'assets/images/chat/backgrounds/$fileName';

String _textureAssetForPalette(_ThemePalette palette) => palette.isDark
    ? kCharacterChatDarkTextureAsset
    : kCharacterChatLightTextureAsset;

Color _gradientColor(
  Color color, {
  required _ThemePalette palette,
  required double strength,
}) {
  final amount = palette.isDark ? strength : strength + 0.24;
  return _mix(color, palette.background, amount.clamp(0, 0.82));
}

Color _overlayTint(
  Color color, {
  required double opacity,
}) {
  return color.withValues(alpha: opacity);
}

Color _mix(Color a, Color b, double amount) {
  return Color.lerp(a, b, amount.clamp(0, 1))!;
}

Color _tone(
  Color color, {
  double hueShift = 0,
  double saturationShift = 0,
  double lightnessShift = 0,
}) {
  final hsl = HSLColor.fromColor(color);
  return hsl
      .withHue((hsl.hue + hueShift + 360) % 360)
      .withSaturation((hsl.saturation + saturationShift).clamp(0, 1))
      .withLightness((hsl.lightness + lightnessShift).clamp(0, 1))
      .toColor();
}

class _ThemePalette {
  const _ThemePalette({
    required this.isDark,
    required this.background,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.info,
    required this.warning,
    required this.success,
    required this.error,
    required this.accentSecondary,
    required this.accentTertiary,
  });

  final bool isDark;
  final Color background;
  final Color surface;
  final Color textPrimary;
  final Color textSecondary;
  final Color info;
  final Color warning;
  final Color success;
  final Color error;
  final Color accentSecondary;
  final Color accentTertiary;

  factory _ThemePalette.fromBrightness(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return _ThemePalette(
      isDark: isDark,
      background: isDark ? DSColors.background : DSColors.backgroundDark,
      surface: isDark ? DSColors.surface : DSColors.surfaceDark,
      textPrimary: isDark ? DSColors.textPrimary : DSColors.textPrimaryDark,
      textSecondary:
          isDark ? DSColors.textSecondary : DSColors.textSecondaryDark,
      info: isDark ? DSColors.info : DSColors.infoDark,
      warning: isDark ? DSColors.warning : DSColors.warningDark,
      success: isDark ? DSColors.success : DSColors.successDark,
      error: isDark ? DSColors.error : DSColors.errorDark,
      accentSecondary:
          isDark ? DSColors.accentSecondary : DSColors.accentSecondaryDark,
      accentTertiary:
          isDark ? DSColors.accentTertiary : DSColors.accentTertiaryDark,
    );
  }
}
