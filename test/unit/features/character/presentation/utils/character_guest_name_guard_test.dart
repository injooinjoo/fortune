import 'package:flutter_test/flutter_test.dart';
import 'package:fortune/features/character/presentation/utils/character_guest_name_guard.dart';

void main() {
  group('buildUnknownUserNameGuard', () {
    test('returns a strict guard when user name is missing', () {
      final guard = buildUnknownUserNameGuard(
        characterName: '하늘',
        knownUserName: null,
      );

      expect(guard, contains('사용자 이름은 제공되지 않았습니다'));
      expect(guard, contains('절대 캐릭터 이름 "하늘"을 사용자 호칭으로 쓰지 마세요'));
      expect(guard, contains('회원님'));
    });

    test('returns empty string when user name is already known', () {
      final guard = buildUnknownUserNameGuard(
        characterName: '하늘',
        knownUserName: '인주',
      );

      expect(guard, isEmpty);
    });
  });
}
