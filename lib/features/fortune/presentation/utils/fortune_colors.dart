import 'package:flutter/material.dart';
import '../../../../core/design_system/design_system.dart';

/// Utility class for fortune-specific colors that are theme-aware
///
/// **DEPRECATED**: This class is not imported anywhere in the codebase.
/// Use [DSFortuneColors] for fortune-specific color tokens instead.
/// Colors have been delegated to DSFortuneColors where semantic matches exist.
@Deprecated('Use DSFortuneColors instead. This file is unused dead code.')
class FortuneColors {
  FortuneColors._();

  // Love-related colors (replacing pink)
  static const Color love = Color(0xFFE91E63); // Material pink
  static const Color loveDark = Color(0xFFFF6090); // Lighter for dark mode

  // Spiritual/mystical colors - delegates to DSFortuneColors.categoryDaily
  static const Color spiritual = DSFortuneColors.categoryDaily; // Purple 0xFF7C3AED
  static const Color spiritualDark = Color(0xFFA78BFA); // Lighter for dark mode

  // Energy colors - delegates to DSFortuneColors.categoryLotto
  static const Color energy = DSFortuneColors.categoryLotto; // Amber 0xFFF59E0B
  static const Color energyDark = Color(0xFFFBBF24); // Lighter for dark mode

  // Earth/nature colors (replacing brown)
  static const Color earth = Color(0xFF8B6F47); // Brown
  static const Color earthDark = Color(0xFFBCA08E); // Lighter for dark mode

  // Fortune type specific gradients
  static const LinearGradient loveGradient = LinearGradient(
    colors: [Color(0xFFE91E63), Color(0xFFC2185B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient loveGradientDark = LinearGradient(
    colors: [Color(0xFFFF6090), Color(0xFFFF80AB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient spiritualGradient = LinearGradient(
    colors: [DSFortuneColors.categoryDaily, Color(0xFF6D28D9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient spiritualGradientDark = LinearGradient(
    colors: [Color(0xFFA78BFA), Color(0xFFC4B5FD)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient energyGradient = LinearGradient(
    colors: [DSFortuneColors.categoryLotto, Color(0xFFD97706)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient energyGradientDark = LinearGradient(
    colors: [Color(0xFFFBBF24), Color(0xFFFCD34D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient earthGradient = LinearGradient(
    colors: [Color(0xFF8B6F47), Color(0xFF6F5637)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient earthGradientDark = LinearGradient(
    colors: [Color(0xFFBCA08E), Color(0xFFD4B5A0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Sports team colors (theme-aware)
  static const Color sportsRed = Color(0xFFE53E3E);
  static const Color sportsRedDark = Color(0xFFF56565);
  static const Color sportsBlue = Color(0xFF2B6CB0);
  static const Color sportsBlueDark = Color(0xFF63B3ED);
  static const Color sportsGreen = Color(0xFF48BB78);
  static const Color sportsGreenDark = Color(0xFF68D391);

  // Element colors for Saju (Five Elements)
  // Note: DSFortuneColors provides elementFire/Wood/Water/Metal/Earth with
  // Korean traditional values. These use a different (Material) palette.
  static const Map<String, Color> elementColors = {
    '목': Color(0xFF48BB78), // Wood - Green
    '화': Color(0xFFE53E3E), // Fire - Red
    '토': DSFortuneColors.categoryLotto, // Earth - Yellow/Amber 0xFFF59E0B
    '금': Color(0xFF718096), // Metal - Gray
    '수': Color(0xFF3182CE), // Water - Blue
  };

  static const Map<String, Color> elementColorsDark = {
    '목': Color(0xFF68D391), // Wood - Light Green
    '화': Color(0xFFF56565), // Fire - Light Red
    '토': Color(0xFFFBBF24), // Earth - Light Yellow
    '금': Color(0xFFA0AEC0), // Metal - Light Gray
    '수': Color(0xFF63B3ED), // Water - Light Blue
  };

  static bool _isDark(BuildContext context) =>
      context.isDark;

  static Color _themed(BuildContext context, Color light, Color dark) =>
      _isDark(context) ? dark : light;

  // Helper methods for theme-aware colors
  static Color getLove(BuildContext context) {
    return _themed(context, love, loveDark);
  }

  static Color getSpiritual(BuildContext context) {
    return _themed(context, spiritual, spiritualDark);
  }

  static Color getEnergy(BuildContext context) {
    return _themed(context, energy, energyDark);
  }

  static Color getEarth(BuildContext context) {
    return _themed(context, earth, earthDark);
  }

  static LinearGradient getLoveGradient(BuildContext context) {
    return _isDark(context) ? loveGradientDark : loveGradient;
  }

  static LinearGradient getSpiritualGradient(BuildContext context) {
    return _isDark(context) ? spiritualGradientDark : spiritualGradient;
  }

  static LinearGradient getEnergyGradient(BuildContext context) {
    return _isDark(context) ? energyGradientDark : energyGradient;
  }

  static LinearGradient getEarthGradient(BuildContext context) {
    return _isDark(context) ? earthGradientDark : earthGradient;
  }

  static Color getSportsRed(BuildContext context) {
    return _themed(context, sportsRed, sportsRedDark);
  }

  static Color getSportsBlue(BuildContext context) {
    return _themed(context, sportsBlue, sportsBlueDark);
  }

  static Color getSportsGreen(BuildContext context) {
    return _themed(context, sportsGreen, sportsGreenDark);
  }

  static Color getElementColor(BuildContext context, String element) {
    final colors = _isDark(context) ? elementColorsDark : elementColors;
    return colors[element] ?? (_isDark(context) ? const Color(0xFFFFFFFF) : const Color(0xFF000000));
  }

  // Score-based color selection
  static Color getScoreColor(BuildContext context, int score) {
    if (score >= 80) {
      return _themed(context, const Color(0xFF34C759), const Color(0xFF34C759));
    } else if (score >= 60) {
      return _themed(context, const Color(0xFFFFCC00), const Color(0xFFFFCC00));
    } else {
      return _themed(context, const Color(0xFFFF3B30), const Color(0xFFFF3B30));
    }
  }
}
