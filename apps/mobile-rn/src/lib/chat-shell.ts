import { type FortuneTypeId } from '@fortune/product-contracts';

import { buildEmbeddedResultPayload } from '../features/chat-results/adapter';
import {
  type EmbeddedResultBuildContext,
  type EmbeddedResultPayload,
} from '../features/chat-results/types';
import { resolveResultKindFromFortuneType } from '../features/fortune-results/mapping';
import { type ResultKind } from '../features/fortune-results/types';
import { type ChatCharacterSpec, isFortuneChatCharacter } from './chat-characters';

export interface ChatShellTextMessage {
  id: string;
  kind: 'text';
  sender: 'assistant' | 'user' | 'system';
  text: string;
}

export interface ChatShellEmbeddedResultMessage {
  id: string;
  kind: 'embedded-result';
  sender: 'assistant';
  embeddedWidgetType: 'fortune_result_card';
  fortuneType: FortuneTypeId;
  resultKind: ResultKind;
  title: string;
  payload: EmbeddedResultPayload;
}

export interface ChatShellFortuneCookieMessage {
  id: string;
  kind: 'fortune-cookie';
  sender: 'assistant';
}

export interface ChatShellSajuPreviewMessage {
  id: string;
  kind: 'saju-preview';
  sender: 'assistant';
  userName: string;
  sajuData: unknown;
}

export type ChatShellMessage =
  | ChatShellTextMessage
  | ChatShellEmbeddedResultMessage
  | ChatShellFortuneCookieMessage
  | ChatShellSajuPreviewMessage;

export interface ChatShellAction {
  id: string;
  fortuneType: FortuneTypeId;
  label: string;
  prompt: string;
  reply: string;
}

const fortuneTypeLabels: Partial<Record<FortuneTypeId, string>> = {
  daily: '오늘 운세',
  'daily-calendar': '만세력',
  'new-year': '신년 운세',
  'traditional-saju': '전통 사주',
  'face-reading': '관상',
  mbti: 'MBTI 결과',
  'blood-type': '혈액형',
  'zodiac-animal': '띠 운세',
  'personality-dna': '성격운',
  love: '연애 운세',
  compatibility: '궁합',
  'blind-date': '소개팅 운세',
  'ex-lover': '재회 운세',
  'avoid-people': '피해야 할 인연',
  'yearly-encounter': '올해의 인연운',
  career: '커리어 운세',
  wealth: '재물 운세',
  talent: '재능 분석',
  coaching: '코칭운',
  decision: '의사결정',
  'daily-review': '일일 리뷰',
  'weekly-review': '주간 리뷰',
  'chat-insight': '카톡 대화 분석',
  exam: '시험운',
  'lucky-items': '행운 아이템',
  lotto: '로또 운세',
  'match-insight': '경기 인사이트',
  'game-enhance': '게임 컨디션',
  exercise: '운동 운세',
  breathing: '명상 가이드',
  dream: '꿈 해몽',
  tarot: '타로',
  'past-life': '전생 리딩',
  health: '건강 흐름',
  'pet-compatibility': '반려동물 궁합',
  family: '가족 운세',
  naming: '작명',
  moving: '이사 운세',
  celebrity: '연예인 궁합',
  biorhythm: '바이오리듬',
  wish: '소원 리딩',
  talisman: '부적',
  zodiac: '별자리 운세',
  birthstone: '탄생석 가이드',
  'fortune-cookie': '포춘쿠키',
  'ootd-evaluation': 'OOTD 코디',
  'view-all': '전체 보기',
  'profile-creation': '프로필 만들기',
};

export function formatFortuneTypeLabel(type: FortuneTypeId): string {
  return fortuneTypeLabels[type] ?? type;
}

export function buildInitialThread(
  character: ChatCharacterSpec,
): ChatShellMessage[] {
  if (!isFortuneChatCharacter(character)) {
    return [
      {
        id: createMessageId('assistant'),
        kind: 'text',
        sender: 'assistant',
        text: `안녕하세요! ${character.name}예요. 오늘은 어떤 이야기부터 나눠볼까요?`,
      },
      {
        id: createMessageId('user'),
        kind: 'text',
        sender: 'user',
        text: '오늘 하루가 좀 길었어요. 가볍게 이야기부터 시작하고 싶어요.',
      },
      {
        id: createMessageId('assistant'),
        kind: 'text',
        sender: 'assistant',
        text: `${character.shortDescription} 흐름으로 먼저 편하게 대화를 이어가 볼게요.`,
      },
    ];
  }

  const leadFortuneType = character.specialties[0];

  return [
    {
      id: createMessageId('assistant'),
      kind: 'text',
      sender: 'assistant',
      text: `안녕하세요! ${character.name}예요. 오늘은 어떤 흐름이 가장 궁금하세요?`,
    },
    {
      id: createMessageId('user'),
      kind: 'text',
      sender: 'user',
      text: '오늘 좀 피곤했어요. 지금 흐름부터 가볍게 보고 싶어요.',
    },
    {
      id: createMessageId('assistant'),
      kind: 'text',
      sender: 'assistant',
      text: leadFortuneType
        ? `${character.shortDescription} 우선 지금 궁금한 흐름부터 몸과 마음의 결을 가볍게 읽어드릴게요.`
        : `${character.shortDescription} 우선 흐름부터 몸과 마음의 결을 가볍게 읽어드릴게요.`,
    },
    {
      id: createMessageId('assistant'),
      kind: 'text',
      sender: 'assistant',
      text: '아래 주제 중에서 지금 바로 이어갈 흐름을 골라주시면 대화처럼 자연스럽게 풀어볼게요.',
    },
  ];
}

export function buildSuggestedActions(
  character: ChatCharacterSpec,
): ChatShellAction[] {
  if (!isFortuneChatCharacter(character)) {
    return [];
  }

  return character.specialties.map((fortuneType) => ({
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
  character: ChatCharacterSpec,
  fortuneType: FortuneTypeId,
): ChatShellMessage[] {
  const fortuneLabel = formatFortuneTypeLabel(fortuneType);

  return [
    {
      id: createMessageId('assistant'),
      kind: 'text',
      sender: 'assistant',
      text: `${fortuneLabel}부터 같이 볼까요? ${character.name}의 톤으로 흐름을 열어볼게요.`,
    },
    {
      id: createMessageId('user'),
      kind: 'text',
      sender: 'user',
      text: `${fortuneLabel} 먼저 부탁해요.`,
    },
    {
      id: createMessageId('assistant'),
      kind: 'text',
      sender: 'assistant',
      text: `${fortuneLabel}에 필요한 맥락은 제가 짧게 이어서 물어볼게요. 우선 지금 느끼는 분위기부터 함께 짚어봐요.`,
    },
  ];
}

type FallbackTemplate = (name: string, draft: string) => string;

const storyFallbackTemplates: readonly FallbackTemplate[] = [
  (name, draft) =>
    `"${draft}"… 그 말에 ${name}도 잠깐 생각에 잠겼어요.`,
  (name) =>
    `흠, 그렇군요. ${name}은(는) 조금 다른 생각을 하고 있었거든요.`,
  (_name, draft) =>
    `"${draft}"라니… 그 이야기 더 해줄 수 있어요?`,
  (name) =>
    `${name}은(는) 살짝 웃으면서 고개를 끄덕였어요.`,
  (_name, draft) =>
    `"${draft}"… 왠지 오늘따라 그 얘기가 더 와닿네요.`,
  (name) =>
    `그래요? ${name}도 비슷한 적 있었어요. 좀 더 들려주세요.`,
  (name) =>
    `${name}은(는) 잠깐 눈을 감았다가 천천히 말했어요. "계속 해봐요."`,
  (_name, draft) =>
    `"${draft}"… 그 말, 가볍게 넘길 수가 없네요.`,
  (name) =>
    `오, 진심으로요? ${name}은(는) 조금 놀란 눈으로 당신을 바라봤어요.`,
  (name) =>
    `${name}은(는) 고개를 살짝 기울이며 물었어요. "더 있죠?"`,
  (_name, draft) =>
    `"${draft}"… 그 말 속에 뭔가 더 있는 것 같아요.`,
  (name) =>
    `${name}은(는) 미소를 띠며 조용히 귀 기울이고 있어요.`,
];

const fortuneFallbackTemplates: readonly FallbackTemplate[] = [
  (name, draft) =>
    `"${draft}"라고 느끼셨군요. ${name}의 시선으로 보면 지금은 감정의 결을 먼저 정리하고, 필요한 흐름만 바로 이어보는 편이 좋아 보여요.`,
  (name, draft) =>
    `"${draft}"… 그 흐름이 보이네요. ${name}이 함께 짚어볼게요.`,
  (name) =>
    `지금 느끼는 그 감각, ${name}의 눈에도 선명해요. 조금 더 풀어볼까요?`,
  (name, draft) =>
    `"${draft}"… 흥미로운 흐름이에요. ${name}이 읽어드릴게요.`,
  (name) =>
    `그 이야기 속에 오늘의 기운이 담겨 있네요. ${name}이 이어서 볼게요.`,
];

function pickRandomFallbackText(
  templates: readonly FallbackTemplate[],
  name: string,
  draft: string,
): string {
  const index = Math.floor(Math.random() * templates.length);
  return templates[index](name, draft);
}

export function buildDraftReply(
  character: ChatCharacterSpec,
  draft: string,
): ChatShellMessage {
  if (!isFortuneChatCharacter(character)) {
    return {
      id: createMessageId('assistant'),
      kind: 'text',
      sender: 'assistant',
      text: pickRandomFallbackText(storyFallbackTemplates, character.name, draft),
    };
  }

  return {
    id: createMessageId('assistant'),
    kind: 'text',
    sender: 'assistant',
    text: pickRandomFallbackText(fortuneFallbackTemplates, character.name, draft),
  };
}

export function buildUserMessage(text: string): ChatShellMessage {
  return {
    id: createMessageId('user'),
    kind: 'text',
    sender: 'user',
    text,
  };
}

export function buildAssistantTextMessage(text: string): ChatShellMessage {
  return {
    id: createMessageId('assistant'),
    kind: 'text',
    sender: 'assistant',
    text,
  };
}

export function buildSystemTextMessage(text: string): ChatShellMessage {
  return {
    id: createMessageId('system'),
    kind: 'text',
    sender: 'system',
    text,
  };
}

export function buildFortuneCookieMessage(): ChatShellFortuneCookieMessage {
  return {
    id: createMessageId('fortune-cookie'),
    kind: 'fortune-cookie',
    sender: 'assistant',
  };
}

export function buildSajuPreviewMessage(
  userName: string,
  sajuData: unknown,
): ChatShellSajuPreviewMessage {
  return {
    id: createMessageId('saju-preview'),
    kind: 'saju-preview',
    sender: 'assistant',
    userName,
    sajuData,
  };
}

export function buildEmbeddedResultMessage(
  fortuneType: FortuneTypeId,
  context: EmbeddedResultBuildContext = {},
): ChatShellMessage | null {
  const resultKind = resolveResultKindFromFortuneType(fortuneType);

  if (!resultKind) {
    return null;
  }

  return {
    id: createMessageId('result'),
    kind: 'embedded-result',
    sender: 'assistant',
    embeddedWidgetType: 'fortune_result_card',
    fortuneType,
    resultKind,
    title: formatFortuneTypeLabel(fortuneType),
    payload: buildEmbeddedResultPayload(fortuneType, resultKind, context),
  };
}

export function buildEmbeddedResultMessageFromPayload(
  payload: EmbeddedResultPayload,
): ChatShellEmbeddedResultMessage {
  return {
    id: createMessageId('result'),
    kind: 'embedded-result',
    sender: 'assistant',
    embeddedWidgetType: 'fortune_result_card',
    fortuneType: payload.fortuneType,
    resultKind: payload.resultKind,
    title: formatFortuneTypeLabel(payload.fortuneType),
    payload,
  };
}

function createMessageId(prefix: string) {
  return `${prefix}-${Date.now()}-${Math.random().toString(36).slice(2, 8)}`;
}
