import 'package:flutter_test/flutter_test.dart';
import 'package:fortune/core/navigation/fortune_chat_route.dart';

void main() {
  group('buildFortuneChatRoute', () {
    test('builds chat query contract with character and fortune type', () {
      final route = buildFortuneChatRoute(
        'traditional-saju',
        characterId: 'fortune_muhyeon',
        entrySource: 'premium',
      );

      final uri = Uri.parse(route);

      expect(uri.path, '/chat');
      expect(uri.queryParameters['openCharacterChat'], 'true');
      expect(uri.queryParameters['characterId'], 'fortune_muhyeon');
      expect(uri.queryParameters['fortuneType'], 'traditional-saju');
      expect(uri.queryParameters['autoStartFortune'], 'true');
      expect(uri.queryParameters['entrySource'], 'premium');
    });

    test('normalizes legacy fortune aliases', () {
      final route = buildFortuneChatRoute('investment');
      final uri = Uri.parse(route);

      expect(uri.queryParameters['fortuneType'], 'wealth');
    });
  });

  group('FortuneChatLaunchRequest', () {
    test('parses query params from chat uri', () {
      final request = FortuneChatLaunchRequest.fromUri(
        Uri.parse(
          '/chat?openCharacterChat=true&characterId=fortune_haneul'
          '&fortuneType=fortune-cookie&autoStartFortune=true&entrySource=chip',
        ),
      );

      expect(request.shouldOpenChat, isTrue);
      expect(request.characterId, 'fortune_haneul');
      expect(request.fortuneType, 'fortune-cookie');
      expect(request.autoStartFortune, isTrue);
      expect(request.entrySource, 'chip');
    });
  });
}
