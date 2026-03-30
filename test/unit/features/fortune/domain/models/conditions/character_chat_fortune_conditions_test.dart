import 'package:flutter_test/flutter_test.dart';
import 'package:ondo/features/fortune/domain/models/conditions/character_chat_fortune_conditions.dart';

void main() {
  group('CharacterChatFortuneConditions', () {
    test('same payload with different key order generates same hash', () {
      final first = CharacterChatFortuneConditions(
        fortuneType: 'dream',
        answers: {
          'question': 'test',
          'mood': 'good',
        },
        userProfileMergedParams: {
          'z': 'last',
          'a': 'first',
          'nested': {
            'b': 2,
            'a': 1,
          },
        },
      );

      final second = CharacterChatFortuneConditions(
        fortuneType: 'dream',
        answers: {
          'mood': 'good',
          'question': 'test',
        },
        userProfileMergedParams: {
          'a': 'first',
          'nested': {
            'a': 1,
            'b': 2,
          },
          'z': 'last',
        },
      );

      expect(first.generateHash(), second.generateHash());
    });

    test('hash changes when payload value changes', () {
      final base = CharacterChatFortuneConditions(
        fortuneType: 'love',
        answers: const {'relationshipGoal': 'serious'},
        userProfileMergedParams: const {
          'relationshipGoal': 'serious',
          'age': 29,
        },
      );

      final changed = CharacterChatFortuneConditions(
        fortuneType: 'love',
        answers: const {'relationshipGoal': 'casual'},
        userProfileMergedParams: const {
          'relationshipGoal': 'casual',
          'age': 29,
        },
      );

      expect(base.generateHash(), isNot(changed.generateHash()));
    });

    test('mbti hash ignores unrelated profile fields', () {
      final first = CharacterChatFortuneConditions(
        fortuneType: 'mbti',
        answers: const {'mbti': 'ENTJ'},
        userProfileMergedParams: const {
          'mbti': 'ENTJ',
          'name': '김인주',
          'birthDate': '1988-09-05',
          'zodiacSign': '처녀자리',
        },
      );

      final second = CharacterChatFortuneConditions(
        fortuneType: 'mbti',
        answers: const {'mbti': 'ENTJ'},
        userProfileMergedParams: const {
          'mbti': 'ENTJ',
          'name': '다른이름',
          'birthDate': '1991-01-01',
          'zodiacSign': '염소자리',
        },
      );

      expect(first.generateHash(), second.generateHash());
    });

    test('mbti hash changes when reusable input changes', () {
      final first = CharacterChatFortuneConditions(
        fortuneType: 'mbti',
        answers: const {'mbti': 'ENTJ'},
        userProfileMergedParams: const {
          'mbti': 'ENTJ',
          'category': 'overall',
        },
      );

      final second = CharacterChatFortuneConditions(
        fortuneType: 'mbti',
        answers: const {'mbti': 'INFP'},
        userProfileMergedParams: const {
          'mbti': 'INFP',
          'category': 'overall',
        },
      );

      expect(first.generateHash(), isNot(second.generateHash()));
    });

    test('image-like fields are hashed and raw content is removed', () {
      final rawImage = 'A' * 4096;
      final conditions = CharacterChatFortuneConditions(
        fortuneType: 'face-reading',
        answers: {
          'photo': rawImage,
          'question': 'analyze',
        },
        userProfileMergedParams: {
          'photo': rawImage,
          'nested': {
            'image': rawImage,
          },
        },
      );

      final payload = conditions.buildAPIPayload();
      final photoField = payload['photo'] as Map<String, dynamic>;
      final nestedImage = (payload['nested'] as Map<String, dynamic>)['image']
          as Map<String, dynamic>;

      expect(photoField['__normalized'], 'hashed');
      expect(photoField['length'], rawImage.length);
      expect(photoField['sha256_16'], isA<String>());
      expect(photoField.values, isNot(contains(rawImage)));

      expect(nestedImage['__normalized'], 'hashed');
      expect(nestedImage.values, isNot(contains(rawImage)));

      final jsonPayload = (conditions.toJson()['payload']
          as Map<String, dynamic>)['photo'] as Map<String, dynamic>;
      expect(jsonPayload['__normalized'], 'hashed');
    });
  });
}
