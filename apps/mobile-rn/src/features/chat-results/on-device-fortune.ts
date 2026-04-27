/**
 * On-Device Fortune — Gemma 4 E2B 로 운세 결과를 로컬 생성.
 *
 * 엣지 함수와 동일한 EmbeddedResultPayload 를 반환해 렌더 레이어와 호환.
 * 실패(파싱 에러, JSON 불완전 등) 시 throw → 호출자에서 cloud 폴백.
 */

import { type FortuneTypeId } from '@fortune/product-contracts';

import { onDeviceLLMEngine, type OnDeviceMessage } from '../../lib/on-device-llm';
import { resolveResultKindFromFortuneType } from '../fortune-results/mapping';
import type {
  EmbeddedResultBuildContext,
  EmbeddedResultPayload,
} from './types';

// ---------------------------------------------------------------------------
// 설정: fortune_type 별 프롬프트 + 이미지 필드 + 선택적 힌트
// ---------------------------------------------------------------------------

interface FortunePromptSpec {
  /** LLM 에 전달될 system prompt. */
  systemPrompt: string;
  /** context.answers 에서 이미지로 사용할 필드 이름 (있으면 multimodal 로 라우팅). */
  imageAnswerKey?: string;
  /** 답변 레이블 조립 힌트 (없으면 기본값). */
  eyebrow?: string;
  /** 응답 생성 온도. */
  temperature?: number;
  /** 생성 최대 토큰 (Gemma 4 E2B 안정 범위: 512-1024). */
  maxTokens?: number;
}

/**
 * 모든 fortune 이 공유하는 JSON 출력 규약. Gemma 4 E2B 는 2B 모델이라 복잡한
 * 스키마를 안정적으로 못 내므로, EmbeddedResultPayload 핵심 6개 필드만 요구.
 * 나머지 hero-card 전용 필드(pillars, palette 등)는 rawApiResponse 가 비어있어
 * 기본값 렌더로 폴백. 완벽한 품질 재현이 아니라 "프라이버시 + 오프라인"에 가치.
 */
const COMMON_OUTPUT_SCHEMA_HINT = `
응답은 **반드시 아래 JSON 스키마** 로만 출력해라. 다른 텍스트 일절 없이 JSON 만:
{
  "title": "제목 (10자 이내)",
  "subtitle": "부제 (20자 이내)",
  "score": 0-100 사이 정수,
  "summary": "2-3문장 요약 (120자 이내)",
  "highlights": ["핵심 포인트 1", "핵심 포인트 2", "핵심 포인트 3"],
  "recommendations": ["추천 액션 1", "추천 액션 2"],
  "warnings": ["주의할 점 1"],
  "luckyItems": ["행운 색상", "행운 숫자", "행운 방향"],
  "specialTip": "한 줄 특별 조언 (50자 이내)"
}
`;

/**
 * 공통 fortune 지시 프롬프트 — 모든 fortune_type 에 prepend.
 */
const FORTUNE_BASE_INSTRUCTIONS = `
너는 따뜻하고 구체적인 한국 운세 상담가다.
사용자가 제공한 정보를 바탕으로, 위로가 되는 한편 실용적인 조언을 해라.
절대 금지: 건강 진단, 법률/투자 확정 조언, 사용자에게 공포를 주는 표현.
${COMMON_OUTPUT_SCHEMA_HINT}
`;

const FORTUNE_PROMPTS: Partial<Record<FortuneTypeId, FortunePromptSpec>> = {
  'face-reading': {
    systemPrompt: `${FORTUNE_BASE_INSTRUCTIONS}
[관상 전문] 첨부된 사진의 얼굴 인상을 마의상법 관점에서 따뜻하게 분석해라.
오관(눈/코/입/눈썹/귀)의 느낌, 전체 인상, 장점을 강조하고 소소한 개선 팁을 포함.
점수는 80-95 범위.`,
    imageAnswerKey: 'faceImage',
    eyebrow: '관상',
    temperature: 0.8,
    maxTokens: 1024,
  },
  'ootd-evaluation': {
    systemPrompt: `${FORTUNE_BASE_INSTRUCTIONS}
[OOTD 평가] 첨부된 옷차림 사진을 경력 10년 스타일리스트 톤으로 분석해라.
3가지 이상 칭찬 포인트 먼저, 그 후 부드러운 제안. TPO(때/장소/상황) 정보가 있으면 반영.
highlights 에 색/실루엣/트렌드 칭찬, recommendations 에 구체적 아이템/스타일링 제안.`,
    imageAnswerKey: 'ootdImage',
    eyebrow: 'OOTD',
    temperature: 0.85,
    maxTokens: 1024,
  },
  'blind-date': {
    systemPrompt: `${FORTUNE_BASE_INSTRUCTIONS}
[소개팅 코칭] 사용자 기본 정보(이름/생년/MBTI)와 만남 맥락으로 첫 만남 성공 조언을 생성.
highlights 에 매력 포인트, recommendations 에 대화 주제/행동 팁, warnings 에 피할 것.`,
    eyebrow: '소개팅',
    temperature: 0.7,
    maxTokens: 768,
  },
  daily: {
    systemPrompt: `${FORTUNE_BASE_INSTRUCTIONS}
[오늘의 운세] 생년/성별/띠 기반으로 오늘의 전반운, 연애/금전/업무/건강 한 줄씩, 행운 아이템을 담아라.`,
    eyebrow: '오늘의 운세',
    temperature: 0.8,
    maxTokens: 768,
  },
  love: {
    systemPrompt: `${FORTUNE_BASE_INSTRUCTIONS}
[연애운] 사용자 MBTI/성별/연애 스타일/가치관으로 연애 매력 포인트와 현 관계 조언.`,
    eyebrow: '연애운',
    temperature: 0.85,
    maxTokens: 1024,
  },
  career: {
    systemPrompt: `${FORTUNE_BASE_INSTRUCTIONS}
[직업운] 사주/직업/목표로 커리어 강점/타이밍/추천 액션. highlights 에 적성, recommendations 에 실행 단계.`,
    eyebrow: '직업운',
    temperature: 0.8,
    maxTokens: 1024,
  },
  health: {
    systemPrompt: `${FORTUNE_BASE_INSTRUCTIONS}
[건강운] 수면/운동/스트레스 지표로 약한 기관과 한방 관점 조언. 진단 아닌 일반론 톤.`,
    eyebrow: '건강운',
    temperature: 0.8,
    maxTokens: 768,
  },
  compatibility: {
    systemPrompt: `${FORTUNE_BASE_INSTRUCTIONS}
[궁합] 두 사람 정보로 성격/애정/결혼 궁합과 강점을 생성.`,
    eyebrow: '궁합',
    temperature: 0.85,
    maxTokens: 1024,
  },
  mbti: {
    systemPrompt: `${FORTUNE_BASE_INSTRUCTIONS}
[MBTI 운세] 사용자 MBTI 기반 오늘의 운세 + 차원별(E/I, N/S, T/F, J/P) 간단 코멘트.`,
    eyebrow: 'MBTI',
    temperature: 0.8,
    maxTokens: 768,
  },
  'blood-type': {
    systemPrompt: `${FORTUNE_BASE_INSTRUCTIONS}
[혈액형 운세] 혈액형 성격 특성 기반 오늘의 운세 + 연애/업무/금전/건강 요약.`,
    eyebrow: '혈액형',
    temperature: 0.85,
    maxTokens: 768,
  },
  'zodiac-animal': {
    systemPrompt: `${FORTUNE_BASE_INSTRUCTIONS}
[띠별 운세] 12지 띠 기반 오늘의 운세 + 추천/주의 + 행운 방향.`,
    eyebrow: '띠별 운세',
    temperature: 0.85,
    maxTokens: 768,
  },
  birthstone: {
    systemPrompt: `${FORTUNE_BASE_INSTRUCTIONS}
[탄생석] 월 탄생석 의미 + 오늘의 에너지 조언 + 행운 컬러/방향.`,
    eyebrow: '탄생석',
    temperature: 0.8,
    maxTokens: 640,
  },
  tarot: {
    systemPrompt: `${FORTUNE_BASE_INSTRUCTIONS}
[타로] 뽑힌 카드와 스프레드 위치 기반 리딩. highlights 에 카드 의미, recommendations 에 통합 조언.`,
    eyebrow: '타로',
    temperature: 0.9,
    maxTokens: 1024,
  },
  dream: {
    systemPrompt: `${FORTUNE_BASE_INSTRUCTIONS}
[꿈해몽] 꿈 내용 + 감정 기반 심리학/전통 해석 병행. 위협적인 단어 완화 톤.`,
    eyebrow: '꿈해몽',
    temperature: 0.85,
    maxTokens: 1024,
  },
  'new-year': {
    systemPrompt: `${FORTUNE_BASE_INSTRUCTIONS}
[새해 인사이트] 목표 + 사주 기반 한 해 흐름, 주의 시기, 행동 계획.`,
    eyebrow: '새해 인사이트',
    temperature: 0.85,
    maxTokens: 1024,
  },
  'lucky-items': {
    systemPrompt: `${FORTUNE_BASE_INSTRUCTIONS}
[행운 아이템] 관심사/상황/예산으로 오늘의 행운 아이템과 활용 팁. luckyItems 에 5개 항목.`,
    eyebrow: '행운 아이템',
    temperature: 0.85,
    maxTokens: 768,
  },
  moving: {
    systemPrompt: `${FORTUNE_BASE_INSTRUCTIONS}
[이사 운] 현재/목표 지역과 시기로 방위 길흉 + 이사 팁.`,
    eyebrow: '이사 운',
    temperature: 0.8,
    maxTokens: 768,
  },
  wish: {
    systemPrompt: `${FORTUNE_BASE_INSTRUCTIONS}
[소원 성취] 소원 유형과 사용자 상태로 성취 가능성 + 마인드셋 조언.`,
    eyebrow: '소원 성취',
    temperature: 0.85,
    maxTokens: 768,
  },
  exam: {
    systemPrompt: `${FORTUNE_BASE_INSTRUCTIONS}
[시험운] D-day, 시험 종류, 준비 상태로 멘탈 코칭 + 전략 제시.`,
    eyebrow: '시험운',
    temperature: 0.8,
    maxTokens: 1024,
  },
  exercise: {
    systemPrompt: `${FORTUNE_BASE_INSTRUCTIONS}
[운동 가이드] 종목/목표/경험으로 오늘의 운동 가이드 + 폼 팁 + 안전 주의.`,
    eyebrow: '운동',
    temperature: 0.8,
    maxTokens: 768,
  },
  wealth: {
    systemPrompt: `${FORTUNE_BASE_INSTRUCTIONS}
[재물운] 목표/우려/리스크로 현 재물운 + 단기/장기 액션 플랜.`,
    eyebrow: '재물운',
    temperature: 0.8,
    maxTokens: 1024,
  },
  talent: {
    systemPrompt: `${FORTUNE_BASE_INSTRUCTIONS}
[재능] 현재 스킬/관심 분야/학습 스타일로 타고난 재능과 성장 전략.`,
    eyebrow: '재능',
    temperature: 0.85,
    maxTokens: 1024,
  },
  coaching: {
    systemPrompt: `${FORTUNE_BASE_INSTRUCTIONS}
[라이프 코칭] 현재 목표/장애물/시간으로 구체적 3단계 행동 계획.`,
    eyebrow: '라이프 코칭',
    temperature: 0.8,
    maxTokens: 1024,
  },
  decision: {
    systemPrompt: `${FORTUNE_BASE_INSTRUCTIONS}
[결정] 질문 + 옵션들로 각 옵션의 장단점 + 종합 추천 + 다음 단계.`,
    eyebrow: '결정',
    temperature: 0.75,
    maxTokens: 1024,
  },
  'daily-review': {
    systemPrompt: `${FORTUNE_BASE_INSTRUCTIONS}
[하루 돌아보기] 오늘의 경험/감정 정리 + 내일을 위한 한 문장.`,
    eyebrow: '하루 돌아보기',
    temperature: 0.85,
    maxTokens: 640,
  },
  'avoid-people': {
    systemPrompt: `${FORTUNE_BASE_INSTRUCTIONS}
[오늘 경계] 환경/기분/스트레스로 오늘 조심할 사람 타입/색상/방향/시간.`,
    eyebrow: '오늘 경계',
    temperature: 0.85,
    maxTokens: 1024,
  },
  'ex-lover': {
    systemPrompt: `${FORTUNE_BASE_INSTRUCTIONS}
[전애인] 이별 배경과 현 상태로 재회 가능성/감정 치유/새 시작 조언. 집착/자해 유발 금지.`,
    eyebrow: '전애인',
    temperature: 0.85,
    maxTokens: 1024,
  },
  'yearly-encounter': {
    systemPrompt: `${FORTUNE_BASE_INSTRUCTIONS}
[연간 만남] 선호도 기반 한 해 만날 인연의 특징 + 만남 장소/시그널/궁합.`,
    eyebrow: '연간 만남',
    temperature: 0.85,
    maxTokens: 1024,
  },
  celebrity: {
    systemPrompt: `${FORTUNE_BASE_INSTRUCTIONS}
[연예인 궁합] 사용자와 연예인의 사주 기반 궁합 재미 요소 + 매력 포인트.`,
    eyebrow: '연예인 궁합',
    temperature: 0.85,
    maxTokens: 1024,
  },
  naming: {
    systemPrompt: `${FORTUNE_BASE_INSTRUCTIONS}
[작명] 성/부모 사주/원하는 느낌으로 추천 이름 3개 + 의미/오행 균형 설명.
highlights 에 추천 이름 3개, recommendations 에 작명 철학 팁.`,
    eyebrow: '작명',
    temperature: 0.8,
    maxTokens: 1024,
  },
  'past-life': {
    systemPrompt: `${FORTUNE_BASE_INSTRUCTIONS}
[전생] 사주 + 성향으로 전생의 스토리 + 현생 과제 연결.`,
    eyebrow: '전생',
    temperature: 0.9,
    maxTokens: 1024,
  },
  'traditional-saju': {
    systemPrompt: `${FORTUNE_BASE_INSTRUCTIONS}
[전통 사주] 생년월일시로 천간/지지/오행 요약 + 성격/운세/조언.`,
    eyebrow: '전통 사주',
    temperature: 0.8,
    maxTokens: 1024,
  },
  biorhythm: {
    systemPrompt: `${FORTUNE_BASE_INSTRUCTIONS}
[바이오리듬] 생년월일로 오늘의 신체/감성/지성 에너지 레벨 + 활동 추천.`,
    eyebrow: '바이오리듬',
    temperature: 0.8,
    maxTokens: 768,
  },
  'pet-compatibility': {
    systemPrompt: `${FORTUNE_BASE_INSTRUCTIONS}
[반려동물 궁합] 사용자와 반려동물 정보로 케미/교감 방식/주의점.`,
    eyebrow: '반려동물 궁합',
    temperature: 0.85,
    maxTokens: 1024,
  },
  'game-enhance': {
    systemPrompt: `${FORTUNE_BASE_INSTRUCTIONS}
[게임 강화운] 게임/아이템/강화 단계로 성공 확률 느낌 조언 (플라시보 톤, 점수 80+).`,
    eyebrow: '게임 강화운',
    temperature: 0.9,
    maxTokens: 640,
  },
  'match-insight': {
    systemPrompt: `${FORTUNE_BASE_INSTRUCTIONS}
[매치 인사이트] 두 팀 정보로 경기 분위기 예측 + 관전 포인트.`,
    eyebrow: '매치 인사이트',
    temperature: 0.85,
    maxTokens: 768,
  },
  'chat-insight': {
    systemPrompt: `${FORTUNE_BASE_INSTRUCTIONS}
[채팅 인사이트] 대화 텍스트로 감정 톤/친밀도/개선 팁.`,
    eyebrow: '채팅 인사이트',
    temperature: 0.8,
    maxTokens: 1024,
  },
  family: {
    systemPrompt: `${FORTUNE_BASE_INSTRUCTIONS}
[가족 운세] 가족 구성/관심 이슈(화목/변화/자녀/건강/관계/재물)를 종합적으로 다뤄 조언.
highlights 에 강점, recommendations 에 실행 팁, warnings 에 조심할 부분.`,
    eyebrow: '가족 운세',
    temperature: 0.85,
    maxTokens: 1024,
  },
};

/**
 * 지원 여부 (Phase 2/3 에서 지원하는 fortune_type 만 true).
 */
export function isOnDeviceFortuneSupported(fortuneType: FortuneTypeId): boolean {
  return Object.prototype.hasOwnProperty.call(FORTUNE_PROMPTS, fortuneType);
}

// ---------------------------------------------------------------------------
// 핵심 함수
// ---------------------------------------------------------------------------

/**
 * On-device 로 fortune 결과 생성. 성공 시 EmbeddedResultPayload 반환, 실패 시 throw.
 */
export async function resolveOnDeviceFortunePayload(
  fortuneType: FortuneTypeId,
  context: EmbeddedResultBuildContext,
): Promise<EmbeddedResultPayload> {
  const spec = FORTUNE_PROMPTS[fortuneType];
  if (!spec) {
    throw new Error(`[on-device-fortune] unsupported fortuneType: ${fortuneType}`);
  }
  if (!onDeviceLLMEngine.isDeviceCapable()) {
    throw new Error('[on-device-fortune] device not capable');
  }
  if (onDeviceLLMEngine.getStatus() !== 'ready') {
    throw new Error('[on-device-fortune] model not ready');
  }

  // 사용자 프롬프트 조립: context.answers + profile.
  const userPrompt = buildUserPromptFromContext(fortuneType, context);

  // 이미지 입력 (multimodal) — spec 의 imageAnswerKey 가 있고, context.answers 에
  // 실제 base64 가 있으면 content parts 로 전달.
  const messages: OnDeviceMessage[] = [];
  const imageBase64 = spec.imageAnswerKey
    ? readImageBase64(context.answers?.[spec.imageAnswerKey])
    : null;
  if (imageBase64) {
    messages.push({
      role: 'user',
      content: [
        { type: 'image_url', image_url: { url: imageBase64 } },
        { type: 'text', text: userPrompt },
      ],
    });
  } else {
    messages.push({ role: 'user', content: userPrompt });
  }

  const rawOutput = await onDeviceLLMEngine.generate(
    spec.systemPrompt,
    messages,
    {
      temperature: spec.temperature ?? 0.8,
      maxTokens: spec.maxTokens ?? 1024,
    },
  );

  const parsed = tryParseFortuneJson(rawOutput);
  if (!parsed) {
    throw new Error('[on-device-fortune] JSON parse failed');
  }

  return assembleEmbeddedPayload(fortuneType, spec, parsed, context);
}

// ---------------------------------------------------------------------------
// 내부 유틸
// ---------------------------------------------------------------------------

function buildUserPromptFromContext(
  fortuneType: FortuneTypeId,
  context: EmbeddedResultBuildContext,
): string {
  const parts: string[] = [];
  const answers = context.answers ?? {};
  const profile = context.profile ?? {};

  // 프로필 정보 (있으면).
  if (profile.displayName) parts.push(`이름: ${profile.displayName}`);
  if (profile.birthDate) parts.push(`생년월일: ${profile.birthDate}`);
  if (profile.birthTime) parts.push(`생시: ${profile.birthTime}`);
  if (profile.mbti) parts.push(`MBTI: ${profile.mbti}`);
  if (profile.bloodType) parts.push(`혈액형: ${profile.bloodType}`);

  // answers — base64 이미지 필드는 제외 (이미 multimodal 로 전달됨).
  const spec = FORTUNE_PROMPTS[fortuneType];
  for (const [key, value] of Object.entries(answers)) {
    if (spec?.imageAnswerKey && key === spec.imageAnswerKey) continue;
    if (value == null) continue;
    if (typeof value === 'string' && value.startsWith('data:')) continue;
    parts.push(`${key}: ${stringifyAnswer(value)}`);
  }

  parts.push(''); // 빈 줄.
  parts.push(`[Fortune Type] ${fortuneType}`);
  parts.push('위 정보를 바탕으로 스키마에 맞는 JSON 하나만 출력해라.');
  return parts.join('\n');
}

function stringifyAnswer(value: unknown): string {
  if (value == null) return '';
  if (typeof value === 'string') return value;
  if (typeof value === 'number' || typeof value === 'boolean') return String(value);
  try {
    return JSON.stringify(value).slice(0, 400);
  } catch {
    return String(value).slice(0, 400);
  }
}

function readImageBase64(value: unknown): string | null {
  if (typeof value !== 'string' || value.length === 0) return null;
  // 이미 data URL 이면 그대로.
  if (value.startsWith('data:')) return value;
  // 길이가 매우 긴 base64 로 보이면 JPEG 로 감싸서 반환.
  if (value.length > 500 && !/\s/.test(value.slice(0, 100))) {
    return `data:image/jpeg;base64,${value}`;
  }
  return null;
}

function tryParseFortuneJson(raw: string): Record<string, unknown> | null {
  if (!raw) return null;
  // markdown fence 제거.
  const stripped = raw
    .replace(/^```(?:json)?\s*/i, '')
    .replace(/```\s*$/i, '')
    .trim();
  // 첫 { 부터 마지막 } 까지 추출.
  const firstBrace = stripped.indexOf('{');
  const lastBrace = stripped.lastIndexOf('}');
  if (firstBrace === -1 || lastBrace <= firstBrace) return null;
  const jsonSlice = stripped.slice(firstBrace, lastBrace + 1);
  try {
    const parsed = JSON.parse(jsonSlice);
    return typeof parsed === 'object' && parsed !== null
      ? (parsed as Record<string, unknown>)
      : null;
  } catch {
    return null;
  }
}

function assembleEmbeddedPayload(
  fortuneType: FortuneTypeId,
  spec: FortunePromptSpec,
  parsed: Record<string, unknown>,
  context: EmbeddedResultBuildContext,
): EmbeddedResultPayload {
  const asString = (v: unknown, fallback = ''): string =>
    typeof v === 'string' ? v : fallback;
  const asNumber = (v: unknown, fallback: number): number =>
    typeof v === 'number' && Number.isFinite(v) ? v : fallback;
  const asStringArray = (v: unknown): string[] =>
    Array.isArray(v)
      ? v.filter((x): x is string => typeof x === 'string' && x.length > 0)
      : [];

  const title = asString(parsed.title, '오늘의 운세');
  const subtitle = asString(parsed.subtitle) || (spec.eyebrow ?? 'Ondo');
  const summary = asString(parsed.summary) || title;
  const score = asNumber(parsed.score, 72);
  const highlights = asStringArray(parsed.highlights);
  const recommendations = asStringArray(parsed.recommendations);
  const warnings = asStringArray(parsed.warnings);
  const luckyItems = asStringArray(parsed.luckyItems);
  const specialTip = asString(parsed.specialTip);

  const resultKind = resolveResultKindFromFortuneType(fortuneType);
  if (!resultKind) {
    throw new Error(
      `[on-device-fortune] no resultKind mapping for ${fortuneType}`,
    );
  }

  const payload: EmbeddedResultPayload = {
    widgetType: 'fortune_result_card',
    fortuneType,
    resultKind,
    eyebrow: spec.eyebrow ?? 'Ondo',
    title,
    subtitle,
    score,
    summary,
    highlights,
    recommendations,
    warnings,
    luckyItems,
    specialTip: specialTip || undefined,
    metrics: [],
    contextTags: context.answers
      ? Object.entries(context.answers)
          .filter(
            ([, v]) =>
              typeof v === 'string' &&
              v.length > 0 &&
              v.length < 40 &&
              !v.startsWith('data:'),
          )
          .map(([, v]) => v as string)
          .slice(0, 4)
      : [],
    // rawApiResponse 는 on-device 결과의 raw JSON 을 그대로 노출. Hero 카드가
    // 특화 필드(pillars/palette 등) 를 못 찾으면 기본값으로 fallback 됨.
    rawApiResponse: parsed,
  };

  return payload;
}
