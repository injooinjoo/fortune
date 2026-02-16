import 'package:flutter_test/flutter_test.dart';
import 'package:fortune/features/character/domain/models/character_affinity.dart';
import 'package:fortune/features/character/domain/models/character_chat_message.dart';
import 'package:fortune/features/character/presentation/utils/character_tone_policy.dart';
import 'package:fortune/features/character/presentation/utils/character_voice_profile_registry.dart';

void main() {
  final voice = CharacterVoiceProfileRegistry.profileFor('luts');

  group('CharacterTonePolicy.detectLanguage', () {
    test('한국어를 감지한다', () {
      expect(CharacterTonePolicy.detectLanguage('안녕하세요 오늘 뭐해요?'),
          CharacterLanguage.ko);
    });

    test('영어를 감지한다', () {
      expect(CharacterTonePolicy.detectLanguage('Hello, what are you doing?'),
          CharacterLanguage.en);
    });

    test('일본어를 감지한다', () {
      expect(CharacterTonePolicy.detectLanguage('こんにちは、今日は何してるの？'),
          CharacterLanguage.ja);
    });
  });

  group('CharacterTonePolicy.fromConversation', () {
    test('사용자 애칭 선사용 시 nicknameAllowed=true', () {
      final profile = CharacterTonePolicy.fromConversation(
        messages: [CharacterChatMessage.user('자기야 지금 뭐해?')],
      );

      expect(profile.nicknameAllowed, isTrue);
      expect(profile.language, CharacterLanguage.ko);
    });

    test('존댓말 입력 시 formal을 감지한다', () {
      final profile = CharacterTonePolicy.fromConversation(
        messages: [
          CharacterChatMessage.user('안녕하세요.'),
          CharacterChatMessage.user('지금 괜찮으세요?'),
        ],
      );

      expect(profile.speechLevel, CharacterSpeechLevel.formal);
    });
  });

  group('CharacterTonePolicy output guard', () {
    test('생성 응답에서 애칭을 제거하고 질문 수를 제한한다', () {
      const profile = CharacterToneProfile(
        language: CharacterLanguage.ko,
        speechLevel: CharacterSpeechLevel.formal,
        nicknameAllowed: false,
        turnIntent: CharacterTurnIntent.question,
      );

      final guarded = CharacterTonePolicy.applyGeneratedTone(
        '여보, 지금 뭐해? 자기야 오늘 어땠어? 오늘 어땠어?',
        profile,
        voiceProfile: voice,
      );

      expect(guarded.contains('여보'), isFalse);
      expect(guarded.contains('자기'), isFalse);
      expect('?'.allMatches(guarded).length <= 1, isTrue);
    });

    test('서비스형 문구를 제거한다', () {
      const profile = CharacterToneProfile(
        language: CharacterLanguage.ko,
        speechLevel: CharacterSpeechLevel.formal,
        nicknameAllowed: false,
        turnIntent: CharacterTurnIntent.greeting,
      );

      final guarded = CharacterTonePolicy.applyGeneratedTone(
        '네, 반갑습니다! 처음 뵙는 만큼 제가 무엇을 도와드릴 수 있을지 궁금하네요.',
        profile,
        voiceProfile: voice,
      );

      expect(guarded.contains('무엇을 도와드릴 수'), isFalse);
      expect(guarded, isNotEmpty);
    });

    test('AI 정체성 메타 문구를 제거한다', () {
      const profile = CharacterToneProfile(
        language: CharacterLanguage.ko,
        speechLevel: CharacterSpeechLevel.formal,
        nicknameAllowed: false,
        turnIntent: CharacterTurnIntent.sharing,
      );

      final guarded = CharacterTonePolicy.applyGeneratedTone(
        '흥미로운 주제네요! 저는 인공지능이라 직접적인 피부 관리는 할 수 없어요.',
        profile,
        voiceProfile: voice,
      );

      expect(guarded.contains('인공지능'), isFalse);
      expect(guarded.toLowerCase().contains('as an ai'), isFalse);
      expect(guarded, isNotEmpty);
    });
  });

  group('CharacterTonePolicy relationship stage guide', () {
    test('stranger는 1단계 가이드를 반환한다', () {
      const profile = CharacterToneProfile(
        language: CharacterLanguage.ko,
        speechLevel: CharacterSpeechLevel.formal,
        nicknameAllowed: false,
        turnIntent: CharacterTurnIntent.sharing,
      );

      final prompt = CharacterTonePolicy.buildStyleGuidePrompt(
        profile,
        voiceProfile: voice,
        affinityPhase: AffinityPhase.stranger,
      );

      expect(prompt.contains('1단계: 처음 알고 지내는 단계'), isTrue);
    });

    test('romantic은 4단계 가이드를 반환한다', () {
      const profile = CharacterToneProfile(
        language: CharacterLanguage.ko,
        speechLevel: CharacterSpeechLevel.formal,
        nicknameAllowed: true,
        turnIntent: CharacterTurnIntent.sharing,
      );

      final prompt = CharacterTonePolicy.buildStyleGuidePrompt(
        profile,
        voiceProfile: voice,
        affinityPhase: AffinityPhase.romantic,
      );

      expect(prompt.contains('4단계: 연인 단계'), isTrue);
    });
  });

  group('CharacterTonePolicy read-idle icebreaker', () {
    test('1단계에서는 casual 입력이어도 존댓말 질문을 우선한다', () {
      const profile = CharacterToneProfile(
        language: CharacterLanguage.ko,
        speechLevel: CharacterSpeechLevel.casual,
        nicknameAllowed: false,
        turnIntent: CharacterTurnIntent.sharing,
      );

      final question = CharacterTonePolicy.buildReadIdleIcebreakerQuestion(
        profile,
        voiceProfile: voice,
        affinityPhase: AffinityPhase.stranger,
        now: DateTime(2026, 2, 16, 16, 0),
      );

      expect(question, '지금 뭐 하고 계세요?');
    });

    test('점심 시간에는 점심 질문을 사용한다', () {
      const profile = CharacterToneProfile(
        language: CharacterLanguage.ko,
        speechLevel: CharacterSpeechLevel.formal,
        nicknameAllowed: false,
        turnIntent: CharacterTurnIntent.sharing,
      );

      final question = CharacterTonePolicy.buildReadIdleIcebreakerQuestion(
        profile,
        voiceProfile: voice,
        affinityPhase: AffinityPhase.friend,
        now: DateTime(2026, 2, 16, 12, 30),
      );

      expect(question, '점심 드셨어요?');
    });
  });
}
