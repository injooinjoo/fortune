import type { FortuneTypeId } from '@fortune/product-contracts';

import {
  formatSurveyAnswerLabel,
  getChatSurveyDefinition,
} from '../chat-survey/registry';
import type { ChatSurveyStep } from '../chat-survey/types';
import type { ResultKind } from '../fortune-results/types';
import { buildFallbackEmbeddedResultPayload } from './fixtures';
import type {
  EmbeddedResultBuildContext,
  EmbeddedResultPayload,
} from './types';

const contextLabelByStepId: Partial<Record<string, string>> = {
  analysisType: '분석',
  specificQuestion: '포인트',
  customQuestion: '직접 질문',
  calendarSync: '일정 기준',
  targetDate: '날짜',
  mbtiType: 'MBTI',
  category: '카테고리',
  field: '분야',
  position: '포지션',
  concern: '고민',
  status: '관계 상태',
  datingStyle: '연애 스타일',
  currentCondition: '컨디션',
  stressLevel: '스트레스',
  member: '대상',
  curiosity: '궁금한 점',
  eraVibe: '시대감',
  feeling: '감각',
  wishContent: '소원',
  mbti: 'MBTI',
  bloodType: '혈액형',
  zodiac: '별자리',
  goal: '목표',
  interests: '관심',
  interest: '관심 분야',
  workStyle: '작업 스타일',
  challenges: '어려운 점',
  intensity: '강도',
  purpose: '주제',
  questionText: '질문',
  tarotSelection: '선택 카드',
  tpo: '상황',
  lookNote: '룩 설명',
  bokchae: '복채',
};

interface NormalizedSurveyContext {
  tags: string[];
  labels: Partial<Record<string, string>>;
  firstFreeText?: string;
}

export function buildEmbeddedResultPayload(
  fortuneType: FortuneTypeId,
  resultKind: ResultKind,
  context: EmbeddedResultBuildContext = {},
): EmbeddedResultPayload {
  const fallback = buildFallbackEmbeddedResultPayload(fortuneType, resultKind);
  const normalized = normalizeSurveyContext(fortuneType, context);
  const contextualAction = buildContextualAction(fortuneType, normalized);

  return {
    ...fallback,
    score: applyContextualScore(fallback.score, fortuneType, context),
    summary: buildContextualSummary(fortuneType, fallback.summary, normalized),
    contextTags: normalized.tags.length > 0 ? normalized.tags : undefined,
    highlights: mergeUnique(
      buildContextualHighlights(fortuneType, normalized),
      fallback.highlights,
    ),
    recommendations: mergeUnique(
      contextualAction ? [contextualAction] : [],
      fallback.recommendations,
    ),
  };
}

function normalizeSurveyContext(
  fortuneType: FortuneTypeId,
  context: EmbeddedResultBuildContext,
): NormalizedSurveyContext {
  const labels: Partial<Record<string, string>> = {};
  const tags: string[] = [];
  const definition = getChatSurveyDefinition(fortuneType);

  if (definition) {
    for (const step of definition.steps) {
      const rawAnswer = context.answers?.[step.id];

      if (
        rawAnswer == null ||
        rawAnswer === '' ||
        rawAnswer === 'skip' ||
        (Array.isArray(rawAnswer) && rawAnswer.length === 0)
      ) {
        continue;
      }

      const displayValue = formatAnswerValue(step, rawAnswer, context);

      if (!displayValue) {
        continue;
      }

      labels[step.id] = displayValue;

      if (step.id === 'mbtiConfirm') {
        continue;
      }

      tags.push(`${contextLabelForStep(step)}: ${displayValue}`);
    }
  }

  if (
    (fortuneType === 'traditional-saju' || fortuneType === 'daily-calendar') &&
    context.profile?.birthDate
  ) {
    labels.birthDate = context.profile.birthDate;
    tags.push(`생년월일: ${context.profile.birthDate}`);
  }

  if (
    fortuneType === 'traditional-saju' &&
    context.profile?.birthTime &&
    !labels.birthTime
  ) {
    labels.birthTime = context.profile.birthTime;
    tags.push(`출생시간: ${context.profile.birthTime}`);
  }

  if (
    (fortuneType === 'mbti' || fortuneType === 'personality-dna') &&
    context.profile?.mbti &&
    !labels.mbti &&
    !labels.mbtiType
  ) {
    labels.mbti = context.profile.mbti.toUpperCase();
    tags.push(`MBTI: ${context.profile.mbti.toUpperCase()}`);
  }

  if (
    (fortuneType === 'blood-type' || fortuneType === 'personality-dna') &&
    context.profile?.bloodType &&
    !labels.bloodType
  ) {
    labels.bloodType = context.profile.bloodType.toUpperCase();
    tags.push(`혈액형: ${context.profile.bloodType.toUpperCase()}`);
  }

  const freeText =
    labels.customQuestion ??
    labels.questionText ??
    labels.lookNote ??
    labels.wishContent;

  return {
    tags: tags.slice(0, 4),
    labels,
    firstFreeText: freeText,
  };
}

function formatAnswerValue(
  step: ChatSurveyStep,
  answer: unknown,
  context: EmbeddedResultBuildContext,
) {
  if (
    step.id === 'mbtiConfirm' &&
    answer === 'yes' &&
    context.profile?.mbti
  ) {
    return context.profile.mbti.toUpperCase();
  }

  const label = formatSurveyAnswerLabel(step, answer).trim();

  if (!label) {
    return null;
  }

  return trimValue(label, step.inputKind === 'text' ? 36 : 22);
}

function contextLabelForStep(step: ChatSurveyStep) {
  return contextLabelByStepId[step.id] ?? trimQuestion(step.question);
}

function buildContextualSummary(
  fortuneType: FortuneTypeId,
  baseSummary: string,
  context: NormalizedSurveyContext,
) {
  const intro = buildIntroSentence(fortuneType, context);

  if (!intro) {
    return baseSummary;
  }

  return `${intro} ${baseSummary}`;
}

function buildIntroSentence(
  fortuneType: FortuneTypeId,
  context: NormalizedSurveyContext,
) {
  const { labels } = context;

  switch (fortuneType) {
    case 'traditional-saju':
      return joinSentence([
        labels.analysisType ? `${labels.analysisType} 흐름을 기준으로` : null,
        labels.specificQuestion || labels.customQuestion
          ? `${labels.specificQuestion ?? '직접 남긴 질문'} 포인트를 좁혀`
          : '핵심 균형을 먼저 잡아',
        '정리했습니다.',
      ]);
    case 'daily-calendar':
      return joinSentence([
        labels.targetDate ? `${labels.targetDate} 날짜 기준으로` : null,
        labels.calendarSync === '일정과 함께 보기'
          ? '일정 리듬까지 함께 묶어'
          : '날짜 결을 중심으로',
        '읽었습니다.',
      ]);
    case 'mbti':
      return joinSentence([
        labels.mbtiType || labels.mbti
          ? `${labels.mbtiType ?? labels.mbti} 성향을 기준으로`
          : '현재 성향을 기준으로',
        labels.category ? `${labels.category} 인사이트에 초점을 맞춰` : null,
        '정리했습니다.',
      ]);
    case 'career':
      return joinSentence([
        labels.field ? `${labels.field} 분야에서` : null,
        labels.position ? `${labels.position} 포지션 관점으로` : null,
        labels.concern ? `${labels.concern} 고민을 중심으로` : '커리어 흐름을 중심으로',
        '읽었습니다.',
      ]);
    case 'love':
      return joinSentence([
        labels.status ? `${labels.status} 상태에서` : '현재 관계 흐름에서',
        labels.concern ? `${labels.concern} 포인트를 중심으로` : '감정 리듬을 중심으로',
        '풀어봤어요.',
      ]);
    case 'health':
      return joinSentence([
        labels.currentCondition ? `${labels.currentCondition} 컨디션 기준으로` : null,
        labels.concern ? `${labels.concern} 이슈를 먼저 보고` : '회복 리듬을 먼저 보고',
        '정리했습니다.',
      ]);
    case 'family':
      return joinSentence([
        labels.member ? `${labels.member} 중심 관계에서` : '가족 관계에서',
        labels.concern ? `${labels.concern} 흐름을 기준으로` : '대화 톤을 기준으로',
        '읽었습니다.',
      ]);
    case 'past-life':
      return joinSentence([
        labels.curiosity ? `${labels.curiosity} 질문을 중심으로` : null,
        labels.eraVibe ? `${labels.eraVibe} 시대감과 함께` : null,
        '상징을 좁혀봤습니다.',
      ]);
    case 'wish':
      return joinSentence([
        labels.category ? `${labels.category} 소원을 중심으로` : '현재 바람을 중심으로',
        context.firstFreeText
          ? `“${trimValue(context.firstFreeText, 20)}”라는 문장을 기준으로`
          : null,
        '해석했습니다.',
      ]);
    case 'personality-dna':
      return joinSentence([
        labels.mbti ? `${labels.mbti} 성향과` : null,
        labels.bloodType ? `${labels.bloodType} 기질,` : null,
        labels.zodiac ? `${labels.zodiac} 흐름을 함께 묶어` : '강점 축을 중심으로',
        '정리했습니다.',
      ]);
    case 'wealth':
      return joinSentence([
        labels.goal ? `${labels.goal} 목표를 우선으로` : null,
        labels.concern ? `${labels.concern} 고민을 중심으로` : '금전 리듬을 중심으로',
        '읽었습니다.',
      ]);
    case 'talent':
      return joinSentence([
        labels.interest ? `${labels.interest} 관심 분야와` : null,
        labels.workStyle ? `${labels.workStyle} 작업 스타일을 기준으로` : '강점 발현 방식을 기준으로',
        '정리했습니다.',
      ]);
    case 'exercise':
      return joinSentence([
        labels.goal ? `${labels.goal} 목표에 맞춰` : null,
        labels.intensity ? `${labels.intensity} 강도로` : '지속 가능한 강도로',
        '풀었습니다.',
      ]);
    case 'tarot':
      return joinSentence([
        labels.purpose ? `${labels.purpose} 주제에 맞춰` : null,
        context.firstFreeText
          ? `“${trimValue(context.firstFreeText, 18)}”를 질문으로 삼아`
          : null,
        labels.tarotSelection ? `${labels.tarotSelection} 흐름을 기준으로` : '카드 흐름을 기준으로',
        '읽었습니다.',
      ]);
    case 'ootd-evaluation':
      return joinSentence([
        labels.tpo ? `${labels.tpo} 상황 기준으로` : null,
        context.firstFreeText
          ? `“${trimValue(context.firstFreeText, 20)}” 룩 설명을 반영해`
          : '현재 룩 무드를 반영해',
        '정리했습니다.',
      ]);
    case 'blood-type':
      return labels.bloodType
        ? `${labels.bloodType} 기질을 기준으로 포인트를 정리했습니다.`
        : null;
    default:
      if (context.tags.length > 0) {
        return `이번 결과는 ${context.tags.slice(0, 2).join(', ')} 기준으로 정리했습니다.`;
      }

      return null;
  }
}

function buildContextualHighlights(
  fortuneType: FortuneTypeId,
  context: NormalizedSurveyContext,
) {
  if (context.tags.length === 0) {
    return [];
  }

  const highlights = [`입력된 맥락을 기준으로 포인트를 압축했습니다.`];

  switch (fortuneType) {
    case 'tarot':
      if (context.labels.tarotSelection) {
        highlights.push(`선택 카드 ${context.labels.tarotSelection} 흐름을 우선 반영했어요.`);
      }
      break;
    case 'wish':
      if (context.firstFreeText) {
        highlights.push(`직접 적어준 소원 문장을 해석의 중심에 두었습니다.`);
      }
      break;
    case 'ootd-evaluation':
      if (context.firstFreeText) {
        highlights.push(`룩 설명에 적은 포인트를 중심으로 스타일 인상을 읽었습니다.`);
      }
      break;
  }

  return highlights;
}

function buildContextualAction(
  fortuneType: FortuneTypeId,
  context: NormalizedSurveyContext,
) {
  const { labels } = context;

  switch (fortuneType) {
    case 'career':
      if (labels.concern === '이직/전환') {
        return '이직 판단은 기준 세 가지를 먼저 적은 뒤 비교하는 방식이 가장 안전합니다.';
      }
      return null;
    case 'love':
      if (labels.concern === '고백 타이밍') {
        return '확답을 서두르기보다 질문형 대화를 한 번 더 늘려보세요.';
      }
      return null;
    case 'health':
      if (labels.concern === '수면') {
        return '오늘은 취침 시간을 먼저 고정하는 쪽이 가장 효과적입니다.';
      }
      return null;
    case 'wealth':
      if (labels.goal === '저축 늘리기') {
        return '이번 주는 고정지출 한 항목만 바로 줄여도 흐름이 안정됩니다.';
      }
      return null;
    case 'ootd-evaluation':
      if (labels.tpo === '데이트') {
        return '데이트 룩은 포인트 컬러를 한 군데만 남길 때 인상이 가장 또렷합니다.';
      }
      return null;
    default:
      return null;
  }
}

function applyContextualScore(
  baseScore: number | undefined,
  fortuneType: FortuneTypeId,
  context: EmbeddedResultBuildContext,
) {
  if (typeof baseScore !== 'number') {
    return baseScore;
  }

  const seed = JSON.stringify({
    fortuneType,
    answers: context.answers ?? {},
    profile: context.profile ?? {},
    characterName: context.characterName ?? '',
  });
  const variance = (hashString(seed) % 9) - 4;

  return clamp(baseScore + variance, 60, 96);
}

function joinSentence(parts: Array<string | null | undefined>) {
  const content = parts.filter(Boolean).join(' ').trim();
  return content.length > 0 ? content : null;
}

function mergeUnique(
  preferred: string[] | undefined,
  fallback: string[] | undefined,
) {
  const seen = new Set<string>();
  const merged: string[] = [];

  for (const item of [...(preferred ?? []), ...(fallback ?? [])]) {
    const normalized = item.trim();

    if (!normalized || seen.has(normalized)) {
      continue;
    }

    seen.add(normalized);
    merged.push(normalized);
  }

  return merged.length > 0 ? merged : undefined;
}

function trimQuestion(question: string) {
  return question
    .replace(/[?.!？。]+$/u, '')
    .replace(/(해주세요|해주세요\.|있나요|인가요|까요|볼까요)$/u, '')
    .trim();
}

function trimValue(value: string, limit: number) {
  return value.length > limit ? `${value.slice(0, limit - 1)}…` : value;
}

function hashString(value: string) {
  let hash = 0;

  for (let index = 0; index < value.length; index += 1) {
    hash = (hash * 31 + value.charCodeAt(index)) >>> 0;
  }

  return hash;
}

function clamp(value: number, min: number, max: number) {
  return Math.min(max, Math.max(min, value));
}
