import 'package:flutter_test/flutter_test.dart';
import 'package:fortune/core/theme/font_size_system.dart';
import 'package:fortune/core/theme/typography_unified.dart';

void main() {
  group('FontSizeSystem Tests', () {
    tearDown(() {
      FontSizeSystem.resetScaleFactor();
    });

    test('Default scale factor is 1.0', () {
      expect(FontSizeSystem.scaleFactor, 1.0);
    });

    test('Setting scale factor updates scaled sizes', () {
      FontSizeSystem.setScaleFactor(1.5);
      expect(FontSizeSystem.scaleFactor, 1.5);
      expect(
          FontSizeSystem.displayLargeScaled, FontSizeSystem.displayLarge * 1.5);
      expect(FontSizeSystem.bodyMediumScaled, FontSizeSystem.bodyMedium * 1.5);
    });

    test('Scale factor is clamped', () {
      FontSizeSystem.setScaleFactor(0.1); // Too small
      expect(FontSizeSystem.scaleFactor, 0.5); // Min clamp

      FontSizeSystem.setScaleFactor(3.0); // Too large
      expect(FontSizeSystem.scaleFactor, 2.0); // Max clamp
    });
  });

  group('TypographyUnified Tests', () {
    tearDown(() {
      FontSizeSystem.resetScaleFactor();
    });

    test('TypographyUnified uses scaled sizes', () {
      FontSizeSystem.setScaleFactor(1.2);

      final style = TypographyUnified.heading1;
      expect(style.fontSize, FontSizeSystem.heading1 * 1.2);
    });
  });
}
