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
            text: '좋아요. 오늘 흐름만 빠르게 볼게요.',
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
            text: '가장 궁금한 흐름 하나만 골라주세요.',
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
            text: '좋아요. 오늘 흐름만 빠르게 볼게요.',
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
            text: '',
            timestamp: _previewTimestamp(7),
            characterId: character.id,
            origin: MessageOrigin.aiReply,
            embeddedWidgetType: 'fortune_result_card',
            componentData: const {
              'fortuneType': 'daily',
              'title': '오늘의 흐름',
              'summary':
                  '차분하게 우선순위를 정리할수록 작은 성과가 크게 이어지는 날이에요. 오늘은 급하게 넓히기보다 리듬을 정교하게 다듬는 편이 훨씬 유리해요.',
              'description': '작은 정리 하나가 큰 흐름을 바꾸는 날',
              'score': 86,
              'highlights': ['집중', '정리', '타이밍'],
              'specialMessage':
                  '지금은 더 많이 벌이기보다, 중요한 두세 가지에 빛을 모아두면 운이 빠르게 붙어요.',
              'luckyItems': {
                'color': '문라이트 블루',
                'number': '7',
                'time': '오전 9:30',
                'direction': '동남',
                'item': '메모 앱',
              },
              'recommendations': ['답장이 필요한 대화는 오후 전에 마무리해두세요.'],
              'warnings': [
                '즉흥적인 소비나 일정 추가는 한 번 더 점검해보세요.',
              ],
              'categories': {
                'love': {
                  'score': 82,
                  'message': '부드럽게 말할수록 분위기가 좋아져요.',
                },
                'money': {
                  'score': 79,
                  'message': '작은 누수만 막아도 체감이 커지는 날이에요.',
                },
                'work': {
                  'score': 88,
                  'message': '우선순위를 재배치하면 집중력이 크게 오릅니다.',
                },
                'health': {
                  'score': 77,
                  'message': '짧은 휴식이 오히려 속도를 지켜줘요.',
                },
              },
              'timeSpecificFortunes': [
                {
                  'time': '오전',
                  'title': '집중 시동',
                  'score': 87,
                  'description': '가장 중요한 할 일을 한 번에 밀어붙이기 좋은 시간이에요.',
                  'recommendation': '회의 전에 핵심 메모를 먼저 정리하세요.',
                },
                {
                  'time': '오후',
                  'title': '대화 회복',
                  'score': 83,
                  'description': '미뤄둔 답장이나 협업 조율이 부드럽게 풀립니다.',
                  'recommendation': '애매한 일정은 오후 초반에 확정해두세요.',
                },
                {
                  'time': '저녁',
                  'title': '정리와 충전',
                  'score': 79,
                  'description': '과열된 에너지를 가볍게 식히고 내일 흐름을 준비하기 좋아요.',
                  'recommendation': '짧은 산책이나 스트레칭으로 텐션을 정리하세요.',
                },
              ],
              'personalActions': [
                {
                  'title': '우선순위 3개만 남기기',
                  'description': '할 일을 줄여야 집중운이 살아나요.',
                  'timing': '오전 초반',
                },
                {
                  'title': '답장 정리 타임 확보',
                  'description': '관계운은 빠른 반응보다 정확한 정리에서 좋아져요.',
                  'timing': '오후',
                },
              ],
              'godlife': {
                'summary': '오늘은 크게 달리기보다, 정리 잘한 사람이 결국 이기는 날이에요.',
                'cheatkeys': [
                  {'icon': '⚡', 'key': '한 번에 하나만'},
                  {'icon': '🗂️', 'key': '정리 먼저, 실행 다음'},
                ],
                'talisman': '작은 체크리스트',
                'lucky_music': '잔잔한 lo-fi',
              },
              'fortuneSummary': {
                'byZodiacAnimal': {
                  'title': '띠 흐름',
                  'content': '익숙한 리듬을 지키는 쪽이 운을 더 안정적으로 끌어옵니다.',
                },
                'byMBTI': {
                  'title': '성향 흐름',
                  'content': '오늘은 즉흥성보다 구조화가 훨씬 유리하게 작동해요.',
                },
              },
              'storySegments': [
                {
                  'text':
                      '오늘은 번쩍이는 한 방보다 조용한 정리가 힘을 쓰는 날이에요. 작은 메모 하나, 일정 하나의 재배치가 전체 흐름을 다시 편안하게 만들어줍니다.',
                },
                {
                  'text':
                      '특히 일과 관계가 동시에 겹치는 구간에서는 모든 걸 다 잘하려 하기보다, 먼저 처리할 순서를 정한 사람이 가장 여유롭게 마무리하게 됩니다.',
                },
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
