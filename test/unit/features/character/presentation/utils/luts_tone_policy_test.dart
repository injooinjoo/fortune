import 'package:flutter_test/flutter_test.dart';
import 'package:fortune/features/character/domain/models/character_affinity.dart';
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

    test('인사 입력 시 greeting intent를 감지한다', () {
      final profile = LutsTonePolicy.fromConversation(
        messages: [CharacterChatMessage.user('반갑습니다')],
      );

      expect(profile.turnIntent, LutsTurnIntent.greeting);
    });

    test('ㅎㅎ 단독 신호로 casual로 떨어지지 않는다', () {
      final profile = LutsTonePolicy.fromConversation(
        messages: [CharacterChatMessage.user('반가워요 ㅎㅎ')],
      );

      expect(profile.speechLevel, isNot(LutsSpeechLevel.casual));
    });
  });

  group('LutsTonePolicy output guard', () {
    test('생성 응답에서 애칭을 제거하고 질문 수를 제한한다', () {
      const profile = LutsToneProfile(
        language: LutsLanguage.ko,
        speechLevel: LutsSpeechLevel.formal,
        nicknameAllowed: false,
        turnIntent: LutsTurnIntent.question,
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
        turnIntent: LutsTurnIntent.sharing,
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

    test('서비스형 문구를 제거한다', () {
      const profile = LutsToneProfile(
        language: LutsLanguage.ko,
        speechLevel: LutsSpeechLevel.formal,
        nicknameAllowed: false,
        turnIntent: LutsTurnIntent.greeting,
      );

      final guarded = LutsTonePolicy.applyGeneratedTone(
        '네, 반갑습니다! 처음 뵙는 만큼 제가 무엇을 도와드릴 수 있을지 궁금하네요.',
        profile,
      );

      expect(guarded.contains('무엇을 도와드릴 수'), isFalse);
      expect(guarded.contains('도움이 필요하시면'), isFalse);
      expect(guarded, isNotEmpty);
    });

    test('"무엇을 도와드릴까요" 문구를 제거한다', () {
      const profile = LutsToneProfile(
        language: LutsLanguage.ko,
        speechLevel: LutsSpeechLevel.formal,
        nicknameAllowed: false,
        turnIntent: LutsTurnIntent.greeting,
      );

      final guarded = LutsTonePolicy.applyGeneratedTone(
        '네, 저도 만나서 반가워요! 😊 무엇을 도와드릴까요?',
        profile,
      );

      expect(guarded.contains('무엇을 도와드릴'), isFalse);
      expect(guarded, isNotEmpty);
    });

    test('초기 턴 continuity 플래그 시 대화 연결 질문을 보강한다', () {
      const profile = LutsToneProfile(
        language: LutsLanguage.ko,
        speechLevel: LutsSpeechLevel.formal,
        nicknameAllowed: false,
        turnIntent: LutsTurnIntent.sharing,
      );

      final bridged = LutsTonePolicy.applyGeneratedTone(
        '김인주 씨, 만나서 반갑습니다!',
        profile,
        encourageContinuity: true,
      );

      expect(bridged.contains('요즘 가장 궁금한 건 뭐예요'), isTrue);
      expect('?'.allMatches(bridged).length <= 1, isTrue);
    });

    test('1단계에서 이름 미확인 시 이름 질문을 1회 유도한다', () {
      const profile = LutsToneProfile(
        language: LutsLanguage.ko,
        speechLevel: LutsSpeechLevel.casual,
        nicknameAllowed: false,
        turnIntent: LutsTurnIntent.shortReply,
      );

      final bridged = LutsTonePolicy.applyGeneratedTone(
        '저도 반가워요.',
        profile,
        encourageContinuity: true,
        affinityPhase: AffinityPhase.stranger,
      );

      expect(bridged.contains('어떻게 불러드리면 될까요'), isTrue);
    });

    test('이름을 이미 물어본 뒤에는 재질문하지 않는다', () {
      const profile = LutsToneProfile(
        language: LutsLanguage.ko,
        speechLevel: LutsSpeechLevel.casual,
        nicknameAllowed: false,
        turnIntent: LutsTurnIntent.shortReply,
        nameAsked: true,
      );

      final bridged = LutsTonePolicy.applyGeneratedTone(
        '저도 반가워요.',
        profile,
        encourageContinuity: true,
        affinityPhase: AffinityPhase.stranger,
      );

      expect(bridged.contains('어떻게 불러드리면 될까요'), isFalse);
      expect(bridged.contains('요즘 가장 궁금한 건 뭐예요'), isTrue);
    });
  });

  group('LutsTonePolicy relationship stage guide', () {
    test('stranger는 1단계 가이드를 반환한다', () {
      const profile = LutsToneProfile(
        language: LutsLanguage.ko,
        speechLevel: LutsSpeechLevel.formal,
        nicknameAllowed: false,
        turnIntent: LutsTurnIntent.sharing,
      );

      final prompt = LutsTonePolicy.buildStyleGuidePrompt(
        profile,
        affinityPhase: AffinityPhase.stranger,
      );

      expect(prompt.contains('1단계: 처음 알고 지내는 단계'), isTrue);
    });

    test('closeFriend는 3단계 가이드를 반환한다', () {
      const profile = LutsToneProfile(
        language: LutsLanguage.ko,
        speechLevel: LutsSpeechLevel.formal,
        nicknameAllowed: false,
        turnIntent: LutsTurnIntent.sharing,
      );

      final prompt = LutsTonePolicy.buildStyleGuidePrompt(
        profile,
        affinityPhase: AffinityPhase.closeFriend,
      );

      expect(prompt.contains('3단계: 속마음을 털고 위로해주는 단계'), isTrue);
    });

    test('romantic은 4단계 가이드를 반환한다', () {
      const profile = LutsToneProfile(
        language: LutsLanguage.ko,
        speechLevel: LutsSpeechLevel.formal,
        nicknameAllowed: true,
        turnIntent: LutsTurnIntent.sharing,
      );

      final prompt = LutsTonePolicy.buildStyleGuidePrompt(
        profile,
        affinityPhase: AffinityPhase.romantic,
      );

      expect(prompt.contains('4단계: 연인 단계'), isTrue);
    });
  });

  group('LutsTonePolicy read-idle icebreaker', () {
    test('1단계에서는 casual 입력이어도 존댓말 질문을 우선한다', () {
      const profile = LutsToneProfile(
        language: LutsLanguage.ko,
        speechLevel: LutsSpeechLevel.casual,
        nicknameAllowed: false,
        turnIntent: LutsTurnIntent.sharing,
      );

      final question = LutsTonePolicy.buildReadIdleIcebreakerQuestion(
        profile,
        affinityPhase: AffinityPhase.stranger,
        now: DateTime(2026, 2, 16, 16, 0),
      );

      expect(question, '지금 뭐 하고 계세요?');
    });

    test('점심 시간에는 점심 질문을 사용한다', () {
      const profile = LutsToneProfile(
        language: LutsLanguage.ko,
        speechLevel: LutsSpeechLevel.formal,
        nicknameAllowed: false,
        turnIntent: LutsTurnIntent.sharing,
      );

      final question = LutsTonePolicy.buildReadIdleIcebreakerQuestion(
        profile,
        affinityPhase: AffinityPhase.friend,
        now: DateTime(2026, 2, 16, 12, 30),
      );

      expect(question, '점심 드셨어요?');
    });

    test('저녁 시간 + casual이면 반말 질문을 사용한다', () {
      const profile = LutsToneProfile(
        language: LutsLanguage.ko,
        speechLevel: LutsSpeechLevel.casual,
        nicknameAllowed: false,
        turnIntent: LutsTurnIntent.sharing,
      );

      final question = LutsTonePolicy.buildReadIdleIcebreakerQuestion(
        profile,
        affinityPhase: AffinityPhase.romantic,
        now: DateTime(2026, 2, 16, 18, 20),
      );

      expect(question, '저녁 먹었어?');
    });
  });
}
