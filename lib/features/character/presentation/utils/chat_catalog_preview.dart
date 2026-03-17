import '../../../../core/navigation/fortune_chat_route.dart';
import '../../../chat/domain/models/fortune_survey_config.dart';
import '../../data/fortune_characters.dart';
import '../../domain/models/ai_character.dart';
import '../../domain/models/character_chat_message.dart';
import '../../domain/models/character_chat_state.dart';
import '../providers/character_chat_survey_provider.dart';
import '../providers/character_provider.dart';

const _catalogDailySurveyPreviewConfig = FortuneSurveyConfig(
  fortuneType: FortuneSurveyType.daily,
  title: '오늘의 운세',
  description: '오늘 하루에서 가장 궁금한 흐름을 골라주세요.',
  emoji: '🌅',
  steps: [
    SurveyStep(
      id: 'focus',
      question: '오늘 가장 신경 쓰이는 건 뭐예요?',
      inputType: SurveyInputType.chips,
      options: [
        SurveyOption(id: 'work', label: '일과 집중', emoji: '💼'),
        SurveyOption(id: 'relationship', label: '대화와 관계', emoji: '💬'),
        SurveyOption(id: 'timing', label: '운과 타이밍', emoji: '⏰'),
      ],
      isRequired: false,
    ),
  ],
);

CharacterListTab catalogPreviewTab(ChatCatalogPreview preview) {
  return preview.isGeneralHome
      ? CharacterListTab.story
      : CharacterListTab.fortune;
}

AiCharacter? catalogPreviewCharacter(ChatCatalogPreview preview) {
  if (!preview.showsChatOverlay) {
    return null;
  }

  final fortuneType = preview.fortuneType ?? 'daily';
  return findFortuneExpert(fortuneType);
}

CharacterChatState catalogPreviewListState({
  required ChatCatalogPreview preview,
  required AiCharacter character,
  required int index,
}) {
  final timestamp = _previewTimestamp(index + 1);

  if (preview.isGeneralHome) {
    switch (index) {
      case 0:
        return CharacterChatState(
          characterId: character.id,
          isInitialized: true,
          isCharacterTyping: true,
          unreadCount: 1,
          messages: [
            CharacterChatMessage(
              type: CharacterChatMessageType.character,
              text: '오늘 밤은 어디까지 이야기해볼까요?',
              timestamp: timestamp,
              characterId: character.id,
              origin: MessageOrigin.aiReply,
            ),
          ],
        );
      case 1:
        return CharacterChatState(
          characterId: character.id,
          isInitialized: true,
          unreadCount: 1,
          messages: [
            CharacterChatMessage(
              type: CharacterChatMessageType.character,
              text: '방금 떠오른 생각이 있으면 편하게 말해줘요.',
              timestamp: timestamp,
              characterId: character.id,
              origin: MessageOrigin.aiReply,
            ),
          ],
        );
      case 2:
        return CharacterChatState(
          characterId: character.id,
          isInitialized: true,
          messages: [
            CharacterChatMessage(
              type: CharacterChatMessageType.user,
              text: '오늘은 좀 차분하게 이야기하고 싶어요.',
              timestamp: timestamp,
              status: MessageStatus.sent,
              origin: MessageOrigin.userInput,
            ),
          ],
        );
      default:
        return CharacterChatState(
          characterId: character.id,
          isInitialized: true,
        );
    }
  }

  switch (index) {
    case 0:
      return CharacterChatState(
        characterId: character.id,
        isInitialized: true,
        unreadCount: 1,
        messages: [
          CharacterChatMessage(
            type: CharacterChatMessageType.character,
            text: '오늘 가장 궁금한 흐름부터 같이 볼까요? ✨',
            timestamp: timestamp,
            characterId: character.id,
            origin: MessageOrigin.aiReply,
          ),
        ],
      );
    case 1:
      return CharacterChatState(
        characterId: character.id,
        isInitialized: true,
        messages: [
          CharacterChatMessage(
            type: CharacterChatMessageType.character,
            text: '질문 하나만 정하면 바로 인사이트를 시작할 수 있어요.',
            timestamp: timestamp,
            characterId: character.id,
            origin: MessageOrigin.aiReply,
          ),
        ],
      );
    case 2:
      return CharacterChatState(
        characterId: character.id,
        isInitialized: true,
        messages: [
          CharacterChatMessage(
            type: CharacterChatMessageType.user,
            text: '연애운도 나중에 물어보고 싶어요.',
            timestamp: timestamp,
            status: MessageStatus.sent,
            origin: MessageOrigin.userInput,
          ),
        ],
      );
    default:
      return CharacterChatState(
        characterId: character.id,
        isInitialized: true,
      );
  }
}

CharacterChatState catalogPreviewChatState({
  required ChatCatalogPreview preview,
  required AiCharacter character,
}) {
  switch (preview.state) {
    case ChatCatalogPreviewState.curiositySurvey:
      return CharacterChatState(
        characterId: character.id,
        isInitialized: true,
        messages: [
          CharacterChatMessage(
            type: CharacterChatMessageType.character,
            text: '좋아요. 오늘 흐름을 빠르게 정리해볼게요.',
            timestamp: _previewTimestamp(4),
            characterId: character.id,
            origin: MessageOrigin.aiReply,
          ),
          CharacterChatMessage(
            type: CharacterChatMessageType.user,
            text: '오늘 하루 흐름이 궁금해요.',
            timestamp: _previewTimestamp(5),
            status: MessageStatus.sent,
            origin: MessageOrigin.userInput,
          ),
          CharacterChatMessage(
            type: CharacterChatMessageType.character,
            text: '딱 한 가지부터 물어볼게요. 가장 신경 쓰이는 건 뭔가요?',
            timestamp: _previewTimestamp(6),
            characterId: character.id,
            origin: MessageOrigin.aiReply,
          ),
        ],
      );
    case ChatCatalogPreviewState.curiosityResult:
      return CharacterChatState(
        characterId: character.id,
        isInitialized: true,
        messages: [
          CharacterChatMessage(
            type: CharacterChatMessageType.character,
            text: '좋아요. 오늘 흐름을 빠르게 정리해볼게요.',
            timestamp: _previewTimestamp(4),
            characterId: character.id,
            origin: MessageOrigin.aiReply,
          ),
          CharacterChatMessage(
            type: CharacterChatMessageType.user,
            text: '오늘 하루 흐름이 궁금해요.',
            timestamp: _previewTimestamp(5),
            status: MessageStatus.sent,
            origin: MessageOrigin.userInput,
          ),
          CharacterChatMessage(
            type: CharacterChatMessageType.user,
            text: '일과 집중력이 제일 궁금해요.',
            timestamp: _previewTimestamp(6),
            status: MessageStatus.sent,
            origin: MessageOrigin.userInput,
          ),
          CharacterChatMessage(
            type: CharacterChatMessageType.character,
            text: '오늘 흐름을 카드로 정리해봤어요.',
            timestamp: _previewTimestamp(7),
            characterId: character.id,
            origin: MessageOrigin.aiReply,
            embeddedWidgetType: 'fortune_result_card',
            componentData: const {
              'fortuneType': 'daily',
              'title': '오늘의 흐름',
              'summary': '차분하게 우선순위를 정리할수록 작은 성과가 크게 이어지는 날이에요.',
              'score': 86,
              'highlights': ['집중', '대화운', '정리'],
              'luckyItems': ['따뜻한 커피', '메모 앱', '오전 10시'],
              'recommendations': [
                '아침에 가장 중요한 할 일을 세 가지만 적어보세요.',
                '답장이 필요한 대화는 오후 전에 마무리해두는 편이 좋아요.',
              ],
              'warnings': [
                '즉흥적인 소비나 일정 추가는 한 번 더 점검해보세요.',
              ],
            },
          ),
        ],
      );
    case ChatCatalogPreviewState.generalHome:
    case ChatCatalogPreviewState.curiosityHome:
      return CharacterChatState(
        characterId: character.id,
        isInitialized: true,
      );
  }
}

CharacterChatSurveyState catalogPreviewSurveyState(
  ChatCatalogPreview preview,
) {
  if (preview.state != ChatCatalogPreviewState.curiositySurvey) {
    return const CharacterChatSurveyState();
  }

  return CharacterChatSurveyState(
    activeProgress: const SurveyProgress(
      config: _catalogDailySurveyPreviewConfig,
    ),
    fortuneTypeString: preview.fortuneType ?? 'daily',
  );
}

DateTime _previewTimestamp(int dayOffset) {
  return DateTime(2026, 2, dayOffset, 9, 30);
}
