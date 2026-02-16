import 'package:flutter_test/flutter_test.dart';
import 'package:fortune/features/character/domain/models/character_chat_message.dart';
import 'package:fortune/features/character/presentation/utils/luts_tone_policy.dart';

void main() {
  group('LutsTonePolicy.detectLanguage', () {
    test('한국어를 감지한다', () {
      expect(LutsTonePolicy.detectLanguage('안녕하세요 오늘 뭐해요?'), LutsLanguage.ko);
    });

    test('영어를 감지한다', () {
      expect(LutsTonePolicy.detectLanguage('Hello, what are you doing?'),
          LutsLanguage.en);
    });

    test('일본어를 감지한다', () {
      expect(LutsTonePolicy.detectLanguage('こんにちは、今日は何してるの？'), LutsLanguage.ja);
    });
  });

  group('LutsTonePolicy.fromConversation', () {
    test('사용자 애칭 선사용 시 nicknameAllowed=true', () {
      final profile = LutsTonePolicy.fromConversation(
        messages: [CharacterChatMessage.user('자기야 지금 뭐해?')],
      );

      expect(profile.nicknameAllowed, isTrue);
      expect(profile.language, LutsLanguage.ko);
    });

    test('존댓말 입력 시 formal을 감지한다', () {
      final profile = LutsTonePolicy.fromConversation(
        messages: [
          CharacterChatMessage.user('안녕하세요.'),
          CharacterChatMessage.user('지금 괜찮으세요?'),
        ],
      );

      expect(profile.speechLevel, LutsSpeechLevel.formal);
    });
  });

  group('LutsTonePolicy output guard', () {
    test('생성 응답에서 애칭을 제거하고 질문 수를 제한한다', () {
      const profile = LutsToneProfile(
        language: LutsLanguage.ko,
        speechLevel: LutsSpeechLevel.formal,
        nicknameAllowed: false,
      );

      final guarded = LutsTonePolicy.applyGeneratedTone(
        '여보, 지금 뭐해? 자기야 오늘 어땠어? 오늘 어땠어?',
        profile,
      );

      expect(guarded.contains('여보'), isFalse);
      expect(guarded.contains('자기'), isFalse);
      expect('?'.allMatches(guarded).length <= 1, isTrue);
    });

    test('템플릿 톤은 1~2문장으로 정규화된다', () {
      const profile = LutsToneProfile(
        language: LutsLanguage.ko,
        speechLevel: LutsSpeechLevel.formal,
        nicknameAllowed: false,
      );

      final normalized = LutsTonePolicy.applyTemplateTone(
        '안녕, 뭐해? 안녕, 뭐해? 기다릴게. 추가 문장입니다.',
        profile,
      );

      final sentenceCount = RegExp(r'[^.!?。！？]+[.!?。！？]?')
          .allMatches(normalized)
          .where((m) => m.group(0)!.trim().isNotEmpty)
          .length;

      expect(sentenceCount <= 2, isTrue);
    });
  });
}
