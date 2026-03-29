import 'package:flutter_test/flutter_test.dart';
import 'package:ondo/features/character/domain/models/ai_character.dart';

void main() {
  group('FriendConversationSeed', () {
    test('builds a personalized opening for user-created friends', () {
      const seed = FriendConversationSeed(
        relationshipKey: 'friend',
        relationshipLabel: '친구',
        scenario: '퇴근길에 같이 산책하며 하루를 정리하는 사이',
        memoryNote: '서로 편한 온도로 대화하고, 마음이 복잡할 때 먼저 안부를 묻는다.',
        timeModeKey: 'realTime',
        styleLabel: '따뜻한 분위기',
        personalityTags: ['차분한', '다정한'],
        interestTags: ['영화', '산책'],
      );

      final opening = seed.buildFirstMeetOpening(
        '윤서',
        userName: '민지',
      );

      expect(opening, contains('민지, 반가워요.'));
      expect(opening, contains('"퇴근길에 같이 산책하며 하루를 정리하는 사이"'));
      expect(opening, contains('영화 이야기'));
      expect(opening, contains('지금 이 시간'));
    });

    test('falls back to mood and timeless pacing when no scenario is set', () {
      const seed = FriendConversationSeed(
        relationshipKey: 'colleague',
        relationshipLabel: '동료',
        scenario: '',
        memoryNote: '',
        timeModeKey: 'timeless',
        styleLabel: '차분한 분위기',
        personalityTags: ['차분한'],
        interestTags: [],
      );

      final opening = seed.buildFirstMeetOpening('현우');

      expect(opening, startsWith('반가워요. 잠깐 쉬어가듯 이야기 나눠봐요.'));
      expect(opening, contains('차분한 분위기'));
      expect(opening, contains('시간은 잠깐 잊고'));
    });
  });
}
