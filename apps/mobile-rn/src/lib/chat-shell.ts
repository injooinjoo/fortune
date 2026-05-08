import { type FortuneTypeId } from '@fortune/product-contracts';
import type { SajuResult } from '@fortune/saju-engine';

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
  /**
   * 카톡식 읽음 표시용. ISO8601.
   * - `sender: 'user'`일 때만 의미: undefined → "1" 배지 표시, 값 있으면 배지 숨김.
   * - 서버 응답 수신 또는 랜덤 지연 타이머 만료 시 현재 시각으로 세팅.
   * - Phase 2에서 서버 저장으로 승격 (현재는 클라 로컬 전용).
   */
  readAt?: string;
  /**
   * 새로 도착한 메시지일 때 true — MessageBubble이 한 글자씩 타이핑 애니메이션.
   * storage에서 재로드된 과거 메시지는 undefined/false여서 즉시 전체 표시.
   */
  animate?: boolean;
  /**
   * 캐릭터가 먼저 보낸 선톡(proactive)이면 채워짐. 일반 응답이면 undefined.
   * 채팅 리스트 미리보기에 작은 라벨, LLM 컨텍스트에 "방금 내가 보낸 선톡임" 인지용.
   * 설계 문서: docs/features/PROACTIVE_MESSAGING_PLAN.md (4.3)
   */
  proactive?: ProactiveMessageMeta;
  /**
   * `character-chat` Edge Function 응답의 emotionTag (일상/애정/기쁨/고민/분노/당황).
   * TTS 재생 시 inline style instruction (`[warmly, softly]` 등) 으로 변환되어
   * Gemini TTS API 에 전달된다. assistant 메시지에만 의미 있고, 한 메시지당
   * 1개의 감정만 가진다 (멀티-세그먼트 응답이어도 같은 감정 공유).
   */
  emotionTag?: string;
}

/**
 * 선톡(proactive) 메시지 메타. assistant가 사용자 입력 없이 먼저 보낸 메시지에만 붙음.
 *
 * - `slotKey`: 트리거 슬롯 (lunch_share, morning_greet, absence_6h, ...)
 * - `category`: 콘텐츠 카테고리 (greeting, meal, cafe, ...) — UI 라벨용
 * - `generatedAt`: 서버에서 LLM이 생성한 시점 (ISO8601). 발송 시각이 아니라 생성 시각.
 */
export interface ProactiveMessageMeta {
  slotKey: string;
  category: string;
  generatedAt: string;
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

export interface ChatShellImageMessage {
  id: string;
  kind: 'image';
  sender: 'assistant' | 'user';
  imageUrl: string;
  caption?: string;
  /** 캐릭터가 먼저 보낸 사진 메시지면 채워짐. ChatShellTextMessage.proactive 와 동일 의미. */
  proactive?: ProactiveMessageMeta;
}

// Story-reveal payloads — drive the 6 cinematic scenes ported from the Ondo
// Design System's story_chat prototype. Each variant maps 1:1 to a component
// in `features/story-chat-animations/`. The message itself is a normal chat
// entry: persisted in the thread snapshot and re-rendered on reload.
export type StoryRevealPayload =
  | {
      type: 'memory';
      title?: string;
      quote?: string;
      daysAgo?: number;
    }
  | {
      type: 'emotion';
      scoreLabel: string;
      percent: number;
      tags: string[];
    }
  | {
      type: 'poem';
      lines: string[];
    }
  | {
      type: 'pep';
      items: [string, string, string];
    }
  | {
      type: 'photo';
      dateLabel: string;
      caption: string;
    }
  | {
      type: 'resonance';
      percent: number;
      userTag: string;
      charTag: string;
    };

export interface ChatShellStoryRevealMessage {
  id: string;
  kind: 'story-reveal';
  sender: 'assistant';
  reveal: StoryRevealPayload;
  /** Override the scene's character palette if different from thread head. */
  characterId?: string;
}

/**
 * 30초+ 비동기 작업이 진행 중일 때 채팅 흐름에 끼어드는 진행상황 카드.
 *
 * 손금/타로/사주처럼 결과가 늦게 도착하는 운세에서 사용자가 "막히지 않았다"고
 * 인지할 수 있게 phase 텍스트 + 경과시간 + 단계 인디케이터를 보여준다.
 *
 * - `jobId`: Phase B에서 Supabase realtime 구독 키로 사용. 없어도 fake-phase 로 동작 가능.
 * - `fortuneType`: 라벨/아이콘/색상 결정용 (없으면 generic "분석 중").
 * - `phase`: 현재 표시할 단계 텍스트. 서버 phase 도착 시 in-place 갱신.
 * - `phaseSteps`: 시각적 진행 도트용 라벨 시퀀스. 없으면 도트 미표시.
 * - `currentStepIndex`: phaseSteps 중 active 인덱스.
 * - `startedAt`: epoch ms — 경과시간 계산용.
 * - `estimatedSeconds`: 서버가 예상한 총 소요시간 — 남은시간 표시용.
 *
 * 완료되면 이 메시지는 결과 카드로 교체되거나 그대로 둘 수 있음 (replace 정책은 호출 측 결정).
 */
export interface ChatShellProgressMessage {
  id: string;
  kind: 'progress';
  sender: 'assistant';
  jobId?: string;
  fortuneType?: FortuneTypeId;
  phase: string;
  phaseSteps?: string[];
  currentStepIndex?: number;
  startedAt: number;
  estimatedSeconds?: number;
  /**
   * 에러 발생 시 채워지는 사용자 메시지. 값이 있으면 진행카드가 실패 상태로
   * 렌더 (스피너 정지 + 빨간 인디케이터). 보통 진행카드는 결과카드/에러텍스트로
   * 교체되지만, 짧은 에러를 카드 안에 표시하고 싶을 때 사용.
   */
  error?: string;
}

/**
 * System-role card that pins the user's own Saju context into the chat.
 * Injected when user taps "사주로 대화하기" on the Manseryeok screen — acts as
 * a visual reminder that the following conversation is grounded in this chart.
 * (Prompt-level injection is deferred; this is UI-only for now.)
 */
export interface ChatShellMySajuContextMessage {
  id: string;
  kind: 'my-saju-context';
  sender: 'system';
  sajuSummary: {
    pillars: {
      year: string;
      month: string;
      day: string;
      hour: string;
    };
    dayMaster: string;
    elements: {
      wood: number;
      fire: number;
      earth: number;
      metal: number;
      water: number;
    };
    dominantTenGods: string[];
  };
  timestamp: number;
}

/**
 * PR-A: 하늘이 운세 메뉴 카드. 클라이언트 정적 카탈로그 (FORTUNE_CATALOG) 를
 * 그룹 단위로 펼쳐 보여주는 카드. LLM 이 생성하지 않음 — UI 가 직접 렌더.
 *
 * 사용자가 "내가 뭘 할 수 있는지 알려줘" 류 chip 또는 "메뉴" 류 의도 → 채팅에
 * 본 메시지 1개 추가됨. 각 카탈로그 entry 탭 → cost confirmation modal → 운세 결과.
 */
export interface ChatShellFortuneMenuMessage {
  id: string;
  kind: 'fortune-menu';
  sender: 'assistant';
  /** 본 메뉴 카드를 발행한 캐릭터 (현재는 항상 'haneul_oracle'). */
  characterId: string;
  /** 캐릭터 멘트 (메뉴 카드 위 짧은 한 줄). 빈 문자열도 허용. */
  intro?: string;
  /** 선택적으로 특정 카테고리 highlight (deep link redirect intent 보존용). */
  highlightGroupId?: string;
  /** 선택적으로 특정 fortune-type 미리선택 (cost modal 즉시 띄움). */
  preselectedFortuneTypeId?: string;
  timestamp: number;
}

export type ChatShellMessage =
  | ChatShellTextMessage
  | ChatShellEmbeddedResultMessage
  | ChatShellFortuneCookieMessage
  | ChatShellSajuPreviewMessage
  | ChatShellImageMessage
  | ChatShellStoryRevealMessage
  | ChatShellMySajuContextMessage
  | ChatShellProgressMessage;

export interface ChatShellAction {
  id: string;
  fortuneType: FortuneTypeId;
  label: string;
  prompt: string;
  reply: string;
}

const fortuneTypeLabels: Partial<Record<FortuneTypeId, string>> = {
  daily: '오늘의 흐름',
  'daily-calendar': '만세력',
  'new-year': '새해 인사이트',
  'traditional-saju': '전통 사주',
  'face-reading': '관상',
  'palm-reading': '손금가이드',
  'beauty-simulation': '뷰티 시뮬레이션',
  'hair-style-guide': '헤어스타일 가이드',
  'face-reading-guide': '얼굴 인상 리포트',
  'ootd-guide': 'OOTD 가이드',
  'blind-date-guide': '소개팅 가이드',
  'past-life-guide': '전생 리포트',
  mbti: 'MBTI 결과',
  'blood-type': '혈액형',
  'zodiac-animal': '띠별 분석',
  'personality-dna': '성격 분석',
  love: '연애 인사이트',
  compatibility: '궁합',
  'blind-date': '소개팅 분석',
  'ex-lover': '재회 분석',
  'avoid-people': '피해야 할 인연',
  'yearly-encounter': '올해의 인연',
  career: '커리어 인사이트',
  wealth: '재물 인사이트',
  talent: '재능 분석',
  coaching: '코칭 분석',
  decision: '의사결정',
  'daily-review': '일일 리뷰',
  'weekly-review': '주간 리뷰',
  'chat-insight': '카톡 대화 분석',
  exam: '시험 분석',
  'lucky-items': '행운 아이템',
  lotto: '로또 분석',
  'match-insight': '경기 인사이트',
  'game-enhance': '게임 컨디션',
  exercise: '운동 인사이트',
  breathing: '명상 가이드',
  dream: '꿈 해몽',
  tarot: '타로',
  'past-life': '전생 리딩',
  health: '건강 흐름',
  'pet-compatibility': '반려동물 궁합',
  family: '가족 인사이트',
  naming: '작명',
  moving: '이사 인사이트',
  celebrity: '연예인 궁합',
  biorhythm: '바이오리듬',
  wish: '소원 리딩',
  talisman: '부적',
  zodiac: '별자리 인사이트',
  birthstone: '탄생석 가이드',
  'fortune-cookie': '포춘쿠키',
  'ootd-evaluation': 'OOTD 코디',
  'view-all': '전체 보기',
  'profile-creation': '프로필 만들기',
};

export function formatFortuneTypeLabel(type: FortuneTypeId): string {
  return fortuneTypeLabels[type] ?? type;
}

// 신규 캐릭터 초기 thread — greeting 한 줄만.
// 과거에는 fake user + fake assistant 페어를 하드코딩했지만, 이로 인해
// 1) 대화한 적 없는 캐릭터가 리스트 preview 에 "마지막 메시지 있음" 으로 보였고
// 2) 메시지 싱크 비교 (shouldAcceptRemoteMessages) 에서 로컬 fake 3개가 실서버
//    메시지 1~2개보다 길어 "원격이 짧음 → reject" 규칙이 잘못 작동해 원격
//    실데이터 반영을 막는 부작용이 있었다. greeting 한 줄만 남겨서 두 문제 모두 해소.
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
    ];
  }

  return [
    {
      id: createMessageId('assistant'),
      kind: 'text',
      sender: 'assistant',
      text: `안녕하세요! ${character.name}예요. 오늘은 어떤 흐름이 가장 궁금하세요?`,
    },
    {
      id: createMessageId('assistant'),
      kind: 'text',
      sender: 'assistant',
      text: '아래 주제 중에서 편하게 골라주시면 그 결로 바로 이어갈게요.',
    },
  ];
}

export function buildSuggestedActions(
  character: ChatCharacterSpec,
): ChatShellAction[] {
  if (!isFortuneChatCharacter(character)) {
    return [];
  }

  // 하늘이 통합: FORTUNE_CATALOG 가 메뉴 SoT 라 specialties 가 비어있음.
  // 빈 리스트가 아니라 cold-start 추천 칩 4개 (메타 1 + direct 3) 노출.
  if (character.id === 'haneul_oracle') {
    return [
      {
        // 메타 칩 — view-all 은 chat-screen 이 fortune-menu 카드 발행으로 분기
        id: 'haneul_oracle:menu',
        fortuneType: 'view-all' as const,
        label: '하늘이가 뭘 보는지 보여줘',
        prompt: '하늘이가 뭘 볼 수 있어?',
        reply: '내가 같이 봐줄 수 있는 거 펼쳐 볼게.',
      },
      {
        id: 'haneul_oracle:tarot',
        fortuneType: 'tarot' as const,
        label: '오늘 타로 한 장',
        prompt: '오늘 타로 한 장만 봐줘.',
        reply: '한 장 뽑아볼게.',
      },
      {
        id: 'haneul_oracle:traditional-saju',
        fortuneType: 'traditional-saju' as const,
        label: '사주 한 줄',
        prompt: '내 사주 한 줄로 정리해줘.',
        reply: '사주 흐름 짚어볼게.',
      },
      {
        id: 'haneul_oracle:health',
        fortuneType: 'health' as const,
        label: '요즘 컨디션 흐름',
        prompt: '요즘 컨디션 흐름 어때?',
        reply: '몸·마음 흐름 같이 봐줄게.',
      },
    ];
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
  // readAt 은 의도적으로 비워둠. 진짜 사람 흐름:
  //   send (1 유지) → 답장 직전 10~30초 전 markRead (1 사라짐 = 캐릭터 "읽음")
  //   → 타이핑 5~15초 → 답장 도착.
  // chat-screen.tsx send 핸들러가 단계별 sleep + markRead/setTyping 으로 처리.
  return {
    id: createMessageId('user'),
    kind: 'text',
    sender: 'user',
    text,
  };
}

export function buildAssistantTextMessage(
  text: string,
  options?: { animate?: boolean; emotionTag?: string },
): ChatShellTextMessage {
  return {
    id: createMessageId('assistant'),
    kind: 'text',
    sender: 'assistant',
    text,
    animate: options?.animate ?? false,
    ...(options?.emotionTag ? { emotionTag: options.emotionTag } : {}),
  };
}

export function buildProactiveAssistantTextMessage(
  text: string,
  meta: ProactiveMessageMeta,
  options?: { animate?: boolean },
): ChatShellTextMessage {
  return {
    id: createMessageId('assistant'),
    kind: 'text',
    sender: 'assistant',
    text,
    animate: options?.animate ?? false,
    proactive: meta,
  };
}

export function buildProactiveAssistantImageMessage(
  imageUrl: string,
  meta: ProactiveMessageMeta,
  caption?: string,
): ChatShellImageMessage {
  return {
    id: createMessageId('assistant'),
    kind: 'image',
    sender: 'assistant',
    imageUrl,
    caption,
    proactive: meta,
  };
}

export function buildUserImageMessage(
  imageUrl: string,
  caption?: string,
): ChatShellImageMessage {
  return {
    id: createMessageId('user'),
    kind: 'image',
    sender: 'user',
    imageUrl,
    caption,
  };
}

export function buildAssistantImageMessage(
  imageUrl: string,
  caption?: string,
): ChatShellImageMessage {
  return {
    id: createMessageId('assistant'),
    kind: 'image',
    sender: 'assistant',
    imageUrl,
    caption,
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

/**
 * PR-A: 하늘이 운세 메뉴 카드 빌더.
 */
export function buildFortuneMenuMessage(opts: {
  characterId: string;
  intro?: string;
  highlightGroupId?: string;
  preselectedFortuneTypeId?: string;
}): ChatShellFortuneMenuMessage {
  return {
    id: createMessageId('fortune-menu'),
    kind: 'fortune-menu',
    sender: 'assistant',
    characterId: opts.characterId,
    intro: opts.intro,
    highlightGroupId: opts.highlightGroupId,
    preselectedFortuneTypeId: opts.preselectedFortuneTypeId,
    timestamp: Date.now(),
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

/**
 * Build the "my-saju-context" card payload from an engine SajuResult.
 * - `pillars.*.korean` is already a combined string like "계해" → reuse directly.
 * - `dominantTenGods`: top 2 frequencies across 7 positions (stems year/month/hour
 *   + branches year/month/day/hour); day-stem is "일간" by definition so skipped.
 */
export function buildMySajuContextMessage(
  saju: SajuResult,
): ChatShellMySajuContextMessage {
  const allGods: string[] = [
    saju.tenGods.year.stem,
    saju.tenGods.month.stem,
    saju.tenGods.hour.stem,
    saju.tenGods.year.branch,
    saju.tenGods.month.branch,
    saju.tenGods.day.branch,
    saju.tenGods.hour.branch,
  ];

  const counts: Record<string, number> = {};
  for (const god of allGods) {
    if (god === '일간') continue;
    counts[god] = (counts[god] ?? 0) + 1;
  }

  const dominantTenGods = Object.entries(counts)
    .sort((a, b) => b[1] - a[1])
    .slice(0, 2)
    .map(([god]) => god);

  return {
    id: createMessageId('my-saju-context'),
    kind: 'my-saju-context',
    sender: 'system',
    sajuSummary: {
      pillars: {
        year: saju.pillars.year.korean,
        month: saju.pillars.month.korean,
        day: saju.pillars.day.korean,
        hour: saju.pillars.hour.korean,
      },
      dayMaster: saju.dayMaster.korean,
      elements: {
        wood: saju.elements.wood,
        fire: saju.elements.fire,
        earth: saju.elements.earth,
        metal: saju.elements.metal,
        water: saju.elements.water,
      },
      dominantTenGods,
    },
    timestamp: Date.now(),
  };
}

export interface BuildProgressMessageOptions {
  jobId?: string;
  fortuneType?: FortuneTypeId;
  /** 시작 phase 텍스트. 미지정 시 fortuneType 라벨 기반 기본값. */
  phase?: string;
  phaseSteps?: string[];
  currentStepIndex?: number;
  /** epoch ms. 미지정 시 Date.now(). */
  startedAt?: number;
  estimatedSeconds?: number;
}

export function buildProgressMessage(
  options: BuildProgressMessageOptions = {},
): ChatShellProgressMessage {
  const fortuneLabel = options.fortuneType
    ? formatFortuneTypeLabel(options.fortuneType)
    : null;
  const defaultPhase = fortuneLabel ? `${fortuneLabel} 분석 중` : '분석 중';
  return {
    id: createMessageId('progress'),
    kind: 'progress',
    sender: 'assistant',
    phase: options.phase ?? defaultPhase,
    startedAt: options.startedAt ?? Date.now(),
    ...(options.jobId !== undefined ? { jobId: options.jobId } : {}),
    ...(options.fortuneType !== undefined
      ? { fortuneType: options.fortuneType }
      : {}),
    ...(options.phaseSteps !== undefined
      ? { phaseSteps: options.phaseSteps }
      : {}),
    ...(options.currentStepIndex !== undefined
      ? { currentStepIndex: options.currentStepIndex }
      : {}),
    ...(options.estimatedSeconds !== undefined
      ? { estimatedSeconds: options.estimatedSeconds }
      : {}),
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
