import 'package:flutter/material.dart';

/// Character accent colors tuned for readability.
class CharacterAccentPalette {
  final Color accent;
  final Color onAccent;
  final Color softBackground;
  final Color softBorder;

  const CharacterAccentPalette({
    required this.accent,
    required this.onAccent,
    required this.softBackground,
    required this.softBorder,
  });

  static CharacterAccentPalette from({
    required Color source,
    required Brightness brightness,
  }) {
    final baseBackground =
        brightness == Brightness.dark ? const Color(0xFF1A1A1A) : Colors.white;
    final targetContrast = brightness == Brightness.dark ? 3.8 : 4.5;

    final accent =
        _ensureContrast(source, baseBackground, minContrast: targetContrast);
    final onAccent = _bestOnAccent(accent);

    return CharacterAccentPalette(
      accent: accent,
      onAccent: onAccent,
      softBackground:
          accent.withValues(alpha: brightness == Brightness.dark ? 0.22 : 0.14),
      softBorder:
          accent.withValues(alpha: brightness == Brightness.dark ? 0.45 : 0.30),
    );
  }

  static Color _bestOnAccent(Color accent) {
    final whiteContrast = _contrastRatio(accent, Colors.white);
    final blackContrast = _contrastRatio(accent, Colors.black);
    return whiteContrast >= blackContrast ? Colors.white : Colors.black;
  }

  static Color _ensureContrast(
    Color color,
    Color background, {
    required double minContrast,
  }) {
    final currentContrast = _contrastRatio(color, background);
    if (currentContrast >= minContrast) {
      return color;
    }

    final backgroundLuminance = background.computeLuminance();
    final colorLuminance = color.computeLuminance();
    final shouldDarken = colorLuminance > backgroundLuminance;
    final sourceHsl = HSLColor.fromColor(color);

    Color best = color;
    double bestContrast = currentContrast;

    for (int i = 1; i <= 24; i++) {
      final delta = i * 0.03;
      final adjustedLightness = shouldDarken
          ? (sourceHsl.lightness - delta).clamp(0.08, 0.92)
          : (sourceHsl.lightness + delta).clamp(0.08, 0.92);
      final candidate = sourceHsl.withLightness(adjustedLightness).toColor();
      final contrast = _contrastRatio(candidate, background);

      if (contrast > bestContrast) {
        best = candidate;
        bestContrast = contrast;
      }

      if (contrast >= minContrast) {
        return candidate;
      }
    }

    return best;
  }

  static double _contrastRatio(Color a, Color b) {
    final luminanceA = a.computeLuminance();
    final luminanceB = b.computeLuminance();
    final lighter = luminanceA > luminanceB ? luminanceA : luminanceB;
    final darker = luminanceA > luminanceB ? luminanceB : luminanceA;
    return (lighter + 0.05) / (darker + 0.05);
  }
}
