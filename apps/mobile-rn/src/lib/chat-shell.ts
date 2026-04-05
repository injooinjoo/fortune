import {
  type FortuneCharacterSpec,
  type FortuneTypeId,
} from '@fortune/product-contracts';

export interface ChatShellMessage {
  id: string;
  sender: 'assistant' | 'user' | 'system';
  text: string;
}

export interface ChatShellAction {
  id: string;
  fortuneType: FortuneTypeId;
  label: string;
  prompt: string;
  reply: string;
}

const fortuneTypeLabels: Partial<Record<FortuneTypeId, string>> = {
  daily: '오늘 운세',
  'new-year': '신년 운세',
  'traditional-saju': '전통 사주',
  'face-reading': '관상',
  love: '연애 운세',
  compatibility: '궁합',
  'blind-date': '소개팅 운세',
  'ex-lover': '재회 운세',
  career: '커리어 운세',
  wealth: '재물 운세',
  talent: '재능 분석',
  'lucky-items': '행운 아이템',
  lotto: '로또 운세',
  'match-insight': '경기 인사이트',
  'game-enhance': '게임 컨디션',
  exercise: '운동 운세',
  dream: '꿈 해몽',
  tarot: '타로',
  health: '건강 흐름',
  'pet-compatibility': '반려동물 궁합',
  family: '가족 운세',
  naming: '작명',
  moving: '이사 운세',
  celebrity: '연예인 궁합',
  biorhythm: '바이오리듬',
  wish: '소원 리딩',
  talisman: '부적',
};

export function formatFortuneTypeLabel(type: FortuneTypeId): string {
  return fortuneTypeLabels[type] ?? type;
}

export function buildInitialThread(
  character: FortuneCharacterSpec,
): ChatShellMessage[] {
  return [
    {
      id: createMessageId('system'),
      sender: 'system',
      text: `${character.name} 채팅방이 준비됐어요.`,
    },
    {
      id: createMessageId('assistant'),
      sender: 'assistant',
      text: `${character.shortDescription} 지금 궁금한 주제를 골라 주시면 바로 이어서 볼게요.`,
    },
  ];
}

export function buildSuggestedActions(
  character: FortuneCharacterSpec,
): ChatShellAction[] {
  return character.specialties.slice(0, 4).map((fortuneType) => ({
    id: `${character.id}:${fortuneType}`,
    fortuneType,
    label: formatFortuneTypeLabel(fortuneType),
    prompt: `${formatFortuneTypeLabel(fortuneType)}부터 볼래요.`,
    reply: `${character.name}의 톤으로 ${formatFortuneTypeLabel(
      fortuneType,
    )} 흐름을 먼저 풀어볼게요. 필요한 정보가 있으면 다음 질문으로 바로 이어갈 수 있어요.`,
  }));
}

export function buildLaunchMessages(
  character: FortuneCharacterSpec,
  fortuneType: FortuneTypeId,
): ChatShellMessage[] {
  return [
    {
      id: createMessageId('system'),
      sender: 'system',
      text: `딥링크 요청을 감지했어요. ${formatFortuneTypeLabel(
        fortuneType,
      )}를 ${character.name}에게 연결합니다.`,
    },
    {
      id: createMessageId('assistant'),
      sender: 'assistant',
      text: `${formatFortuneTypeLabel(
        fortuneType,
      )} 요청이 들어왔네요. 필요한 맥락을 짧게 알려주시면 바로 채팅 흐름으로 이어가겠습니다.`,
    },
  ];
}

export function buildDraftReply(
  character: FortuneCharacterSpec,
  draft: string,
): ChatShellMessage {
  return {
    id: createMessageId('assistant'),
    sender: 'assistant',
    text: `${character.name}: "${draft}"에 대한 실전형 응답은 다음 단계에서 서버 운세 결과와 연결되지만, RN 셸 기준으로는 이렇게 대화 흐름을 이어받을 수 있습니다.`,
  };
}

export function buildUserMessage(text: string): ChatShellMessage {
  return {
    id: createMessageId('user'),
    sender: 'user',
    text,
  };
}

function createMessageId(prefix: string) {
  return `${prefix}-${Date.now()}-${Math.random().toString(36).slice(2, 8)}`;
}
