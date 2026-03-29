import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ondo/features/character/data/fortune_characters.dart';
import 'package:ondo/features/character/presentation/utils/character_chat_theme.dart';

void main() {
  group('resolveCharacterChatTheme', () {
    test('maps asset-backed chip themes to their dedicated background asset',
        () {
      final spec = resolveCharacterChatTheme(
        brightness: Brightness.dark,
        character: haneulCharacter,
        fortuneType: 'daily',
      );

      expect(spec.fortuneType, 'daily');
      expect(
        spec.backgroundAsset,
        'assets/images/chat/backgrounds/bg_daily.webp',
      );
      expect(spec.textureAsset, kCharacterChatDarkTextureAsset);
      expect(spec.themeKey, '${haneulCharacter.id}:daily');
    });

    test('maps fallback chip themes to gradient plus default texture', () {
      final spec = resolveCharacterChatTheme(
        brightness: Brightness.light,
        character: haneulCharacter,
        fortuneType: 'new-year',
      );

      expect(spec.fortuneType, 'new-year');
      expect(spec.backgroundAsset, isNull);
      expect(spec.textureAsset, kCharacterChatLightTextureAsset);
      expect(spec.gradientColors, hasLength(2));
      expect(spec.gradientColors.first, isNot(spec.gradientColors.last));
      expect(spec.scrimOpacity, greaterThan(0));
    });

    test('falls back to the neutral session theme for unsupported chip ids',
        () {
      final spec = resolveCharacterChatTheme(
        brightness: Brightness.dark,
        character: haneulCharacter,
        fortuneType: 'not-a-real-chip',
      );

      expect(spec.fortuneType, kCharacterChatDefaultThemeType);
      expect(spec.backgroundAsset, isNull);
      expect(spec.textureAsset, kCharacterChatDarkTextureAsset);
      expect(spec.themeKey, '${haneulCharacter.id}:default');
    });
  });
}
