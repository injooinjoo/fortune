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

    test('인사 입력 시 greeting intent를 감지한다', () {
      final profile = LutsTonePolicy.fromConversation(
        messages: [CharacterChatMessage.user('반갑습니다')],
      );

      expect(profile.turnIntent, LutsTurnIntent.greeting);
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
  });
}
