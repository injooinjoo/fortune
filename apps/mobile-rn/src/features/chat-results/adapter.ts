import type {
  FortuneTypeId,
  NormalizedFortuneResult,
} from '@fortune/product-contracts';

import {
  formatSurveyAnswerLabel,
  getChatSurveyDefinition,
} from '../chat-survey/registry';
import type { ChatSurveyStep } from '../chat-survey/types';
import type {
  MetricTileData,
  ResultKind,
  TimelineEntry,
} from '../fortune-results/types';
import { buildFallbackEmbeddedResultPayload } from './fixtures';
import type {
  EmbeddedResultBuildContext,
  EmbeddedResultDetailSection,
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
  partnerName: '상대 이름',
  partnerBirth: '상대 생일',
  relationship: '관계',
  dateType: '만남 성격',
  expectation: '기대 포인트',
  meetingTime: '만나는 시간',
  isFirstBlindDate: '첫 소개팅 여부',
  primaryGoal: '바라는 방향',
  breakupTime: '헤어진 시점',
  relationshipDepth: '관계 깊이',
  coreReason: '이별 이유',
  currentState: '현재 상태',
  status: '관계 상태',
  datingStyle: '연애 스타일',
  targetGender: '상대 성별',
  userAge: '나이대',
  idealMbti: '이상형 MBTI',
  idealType: '이상형 이미지',
  currentCondition: '컨디션',
  stressLevel: '스트레스',
  dreamContent: '꿈 장면',
  emotion: '꿈 감정',
  member: '대상',
  curiosity: '궁금한 점',
  eraVibe: '시대감',
  feeling: '감각',
  dueDateKnown: '예정일 여부',
  dueDate: '예정일',
  gender: '성별',
  lastName: '성',
  style: '느낌',
  babyDream: '원하는 이미지',
  wishContent: '소원',
  mbti: 'MBTI',
  bloodType: '혈액형',
  zodiac: '별자리',
  goal: '목표',
  generationMode: '부적 스타일',
  situation: '상황',
  interests: '관심',
  interest: '관심 분야',
  workStyle: '작업 스타일',
  challenges: '어려운 점',
  intensity: '강도',
  examType: '시험 종류',
  examDate: '시험 날짜',
  preparation: '준비 상태',
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

export function buildEmbeddedResultPayloadFromNormalizedResult(
  fortuneType: FortuneTypeId,
  resultKind: ResultKind,
  normalizedResult: NormalizedFortuneResult,
  context: EmbeddedResultBuildContext = {},
): EmbeddedResultPayload {
  const fallback = buildFallbackEmbeddedResultPayload(fortuneType, resultKind);
  const normalizedContext = normalizeSurveyContext(fortuneType, context);
  const contextualAction = buildContextualAction(fortuneType, normalizedContext);
  const payload = asRecord(normalizedResult.payload);
  const summarySource =
    normalizedResult.summary ??
    normalizedResult.content ??
    fallback.summary;
  const extractedMetrics = extractMetricTiles(fortuneType, payload);
  const extractedHighlights = extractHighlights(fortuneType, payload);
  const extractedRecommendations = extractRecommendations(fortuneType, payload);
  const extractedWarnings = extractWarnings(fortuneType, payload);
  const extractedLuckyItems = extractLuckyItems(fortuneType, payload);
  const extractedDetailSections = extractDetailSections(fortuneType, payload);
  const extractedTimeline = extractTimelineEntries(fortuneType, payload);
  const summary = formatSummaryForDisplay(
    fortuneType,
    summarySource,
    normalizedContext,
  );

  return {
    ...fallback,
    score: normalizedResult.score ?? applyContextualScore(fallback.score, fortuneType, context),
    summary,
    contextTags:
      normalizedContext.tags.length > 0 ? normalizedContext.tags : undefined,
    metrics: selectMetricTiles(
      fortuneType,
      extractedMetrics,
      fallback.metrics,
    ),
    highlights: selectTextItems(
      fortuneType,
      extractedHighlights,
      mergeUnique(
        buildContextualHighlights(fortuneType, normalizedContext),
        fallback.highlights,
      ),
    ),
    recommendations: selectTextItems(
      fortuneType,
      extractedRecommendations,
      mergeUnique(
        contextualAction ? [contextualAction] : [],
        fallback.recommendations,
      ),
    ),
    warnings: selectTextItems(
      fortuneType,
      extractedWarnings,
      fallback.warnings,
    ),
    luckyItems: selectTextItems(
      fortuneType,
      extractedLuckyItems,
      fallback.luckyItems,
    ),
    timeline: extractedTimeline,
    specialTip:
      extractSpecialTip(fortuneType, payload) ??
      normalizedResult.summary ??
      fallback.specialTip,
    detailSections: extractedDetailSections,
  };
}

function formatSummaryForDisplay(
  fortuneType: FortuneTypeId,
  summarySource: string,
  context: NormalizedSurveyContext,
) {
  const baseSummary =
    fortuneType === 'daily'
      ? sanitizeDailyReadableText(summarySource)
      : trimParagraph(summarySource, 220);

  return buildContextualSummary(fortuneType, baseSummary, context);
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

type UnknownRecord = Record<string, unknown>;

function mergeMetricTiles(
  preferred: MetricTileData[] | undefined,
  fallback: MetricTileData[] | undefined,
) {
  const seen = new Set<string>();
  const merged: MetricTileData[] = [];

  for (const item of [...(preferred ?? []), ...(fallback ?? [])]) {
    const key = `${item.label}:${item.value}:${item.note ?? ''}`.trim();

    if (!key || seen.has(key)) {
      continue;
    }

    seen.add(key);
    merged.push(item);
  }

  return merged.length > 0 ? merged.slice(0, 4) : undefined;
}

function selectMetricTiles(
  fortuneType: FortuneTypeId,
  preferred: MetricTileData[] | undefined,
  fallback: MetricTileData[] | undefined,
) {
  if (fortuneType === 'daily' && preferred && preferred.length > 0) {
    return preferred.slice(0, 4);
  }

  return mergeMetricTiles(preferred, fallback);
}

function selectTextItems(
  fortuneType: FortuneTypeId,
  preferred: string[] | undefined,
  fallback: string[] | undefined,
) {
  if (fortuneType === 'daily' && preferred && preferred.length > 0) {
    return preferred.slice(0, 5);
  }

  return mergeUnique(preferred, fallback);
}

function extractDetailSections(
  fortuneType: FortuneTypeId,
  payload: UnknownRecord,
): EmbeddedResultDetailSection[] | undefined {
  if (fortuneType !== 'daily') {
    return undefined;
  }

  return extractDailyDetailSections(payload);
}

function extractTimelineEntries(
  fortuneType: FortuneTypeId,
  payload: UnknownRecord,
): TimelineEntry[] | undefined {
  if (fortuneType !== 'daily') {
    return undefined;
  }

  const predictions = asRecord(payload.daily_predictions);
  const entries = [
    createTimelineEntry('오전', predictions.morning),
    createTimelineEntry('오후', predictions.afternoon),
    createTimelineEntry('저녁', predictions.evening),
  ].filter(Boolean) as TimelineEntry[];

  return entries.length > 0 ? entries : undefined;
}

function extractDailyMetricTiles(payload: UnknownRecord): MetricTileData[] | undefined {
  const categories = asRecord(payload.categories);
  const entries = [
    toDailyCategoryMetric('종합운', categories.total),
    toDailyCategoryMetric('연애', categories.love),
    toDailyCategoryMetric('재물', categories.money),
    toDailyCategoryMetric('일/학업', categories.work ?? categories.study),
  ].filter(Boolean) as MetricTileData[];

  return entries.length > 0 ? entries : undefined;
}

function toDailyCategoryMetric(
  label: string,
  categoryValue: unknown,
): MetricTileData | null {
  const category = asRecord(categoryValue);
  const base = toMetricTile(label, category.score);

  if (!base) {
    return null;
  }

  return base;
}

function extractDailyActionItems(value: unknown) {
  if (!Array.isArray(value)) {
    return [];
  }

  return value.flatMap((item) => {
    const action = asRecord(item);
    const title = firstReadableText(action.title);
    const why = firstReadableText(action.why);
    const content = [title, why].filter(Boolean).join(': ');

    return content ? [content] : [];
  });
}

function extractDailyLowestCategoryAdvice(payload: UnknownRecord) {
  const categories = asRecord(payload.categories);
  const candidates = [
    { label: '연애', value: categories.love },
    { label: '재물', value: categories.money },
    { label: '일', value: categories.work },
    { label: '공부', value: categories.study },
    { label: '건강', value: categories.health },
  ];

  let lowest: { label: string; score: number; advice: string | null } | null = null;

  for (const candidate of candidates) {
    const category = asRecord(candidate.value);
    const score = readScore(category.score);

    if (score == null) {
      continue;
    }

    const advice = extractDailyCategoryBody(candidate.value);
    if (!advice) {
      continue;
    }

    if (!lowest || score < lowest.score) {
      lowest = { label: candidate.label, score, advice };
    }
  }

  return lowest ? `${lowest.label} 흐름: ${lowest.advice}` : null;
}

function extractDailyDetailSections(
  payload: UnknownRecord,
): EmbeddedResultDetailSection[] | undefined {
  const categories = asRecord(payload.categories);
  const sections = [
    createDailyDetailSection('종합 흐름', categories.total),
    createDailyDetailSection('연애 흐름', categories.love),
    createDailyDetailSection('재물 흐름', categories.money),
    createDailyDetailSection('일과 학업', categories.work ?? categories.study),
    createDailyDetailSection('건강 흐름', categories.health),
  ].filter(Boolean) as EmbeddedResultDetailSection[];

  return sections.length > 0 ? sections : undefined;
}

function createDailyDetailSection(
  title: string,
  categoryValue: unknown,
): EmbeddedResultDetailSection | null {
  const category = asRecord(categoryValue);
  const body = extractDailyCategoryBody(categoryValue);

  if (!body) {
    return null;
  }

  const score = readScore(category.score) ?? undefined;

  return {
    title,
    body,
    score,
  };
}

function createTimelineEntry(
  title: string,
  value: unknown,
): TimelineEntry | null {
  const body = firstDailyReadableText(value);

  if (!body) {
    return null;
  }

  return {
    title,
    body,
  };
}

function extractDailyCategoryBody(categoryValue: unknown) {
  const category = asRecord(categoryValue);
  const advice = category.advice;

  if (typeof advice === 'string') {
    return summarizeDailyAdviceBlock(advice);
  }

  const adviceRecord = asRecord(advice);
  return firstDailyReadableText(
    adviceRecord.description,
    adviceRecord.idiom,
    advice,
  );
}

function summarizeDailyAdviceBlock(value: string) {
  const cleaned = sanitizeDailyReadableText(value);

  if (!cleaned) {
    return null;
  }

  const lines = cleaned
    .split('\n')
    .map((line) => line.trim())
    .filter(Boolean)
    .filter((line) => !isDailyHeadingLine(line));

  const firstParagraph = lines.find((line) => !line.startsWith('- '));
  if (firstParagraph) {
    return firstParagraph;
  }

  return lines[0] ?? null;
}

function isDailyHeadingLine(line: string) {
  return (
    line === '종합 흐름' ||
    line === '애정 흐름' ||
    line === '금전 흐름' ||
    line === '직장 흐름' ||
    line === '학업 흐름' ||
    line === '건강 흐름' ||
    line === '실천 팁' ||
    line === '주의할 점' ||
    line === '마무리 한마디'
  );
}

function readScore(value: unknown) {
  if (typeof value === 'number' && Number.isFinite(value)) {
    return value;
  }

  if (typeof value === 'string' && value.trim()) {
    const parsed = Number(value);
    if (Number.isFinite(parsed)) {
      return parsed;
    }
  }

  return null;
}

function extractMetricTiles(
  fortuneType: FortuneTypeId,
  payload: UnknownRecord,
): MetricTileData[] | undefined {
  switch (fortuneType) {
    case 'daily':
      return extractDailyMetricTiles(payload);
    case 'compatibility':
      return mergeMetricTiles(
        [
          toMetricTile('궁합 점수', payload.overall_compatibility ?? payload.overall_score),
          toMetricTile('궁합 등급', payload.compatibility_grade),
        ].filter(Boolean) as MetricTileData[],
        mapRecordToMetricTiles(asRecord(payload.personality_match)),
      );
    case 'blind-date':
      return mergeMetricTiles(
        [
          toMetricTile('성공 확률', payload.successRate),
          toMetricTile('분위기 점수', payload.score),
        ].filter(Boolean) as MetricTileData[],
        undefined,
      );
    case 'exam':
      return mergeMetricTiles(
        mapRecordToMetricTiles(asRecord(payload.examStats)),
        [
          toMetricTile('합격 감각', payload.passGrade),
          toMetricTile('집중 흐름', payload.score),
        ].filter(Boolean) as MetricTileData[],
      );
    case 'biorhythm':
      return [
        toMetricTile('신체 리듬', payload.physical),
        toMetricTile('감정 리듬', payload.emotional),
      ].filter(Boolean) as MetricTileData[];
    case 'health':
      return mergeMetricTiles(
        mapRecordToMetricTiles(asRecord(payload.element_balance)),
        [toMetricTile('건강 점수', payload.healthScore ?? payload.score)].filter(
          Boolean,
        ) as MetricTileData[],
      );
    case 'game-enhance':
      return mergeMetricTiles(
        [
          toMetricTile('행운 등급', payload.lucky_grade),
          toMetricTile('강화 점수', payload.score),
        ].filter(Boolean) as MetricTileData[],
        mapRecordToMetricTiles(asRecord(payload.enhance_stats)),
      );
    case 'ootd-evaluation':
      return [
        toMetricTile('전체 등급', payload.overallGrade),
        toMetricTile('TPO 점수', payload.tpoScore),
      ].filter(Boolean) as MetricTileData[];
    case 'wealth':
      return [
        toMetricTile('재물 잠재력', payload.wealthPotential),
        toMetricTile('전체 점수', payload.overallScore ?? payload.score),
      ].filter(Boolean) as MetricTileData[];
    default:
      return mergeMetricTiles(
        mapRecordToMetricTiles(asRecord(payload.fortuneScores)),
        mapRecordToMetricTiles(
          asRecord(
            payload.examStats ??
              payload.enhance_stats ??
              payload.personality_match ??
              payload.element_balance,
          ),
        ),
      );
  }
}

function extractHighlights(
  fortuneType: FortuneTypeId,
  payload: UnknownRecord,
) {
  switch (fortuneType) {
    case 'daily':
      return collectReadableTextItems(
        sanitizeDailyReadableText(readStringValue(payload.ai_insight)),
        extractDailyCategoryBody(asRecord(payload.categories).total),
        asRecord(asRecord(payload.fortuneSummary).byZodiacAnimal).content,
      );
    case 'compatibility':
      return collectTextItems(
        payload.personality_match,
        payload.communication_match,
        payload.love_match,
      );
    case 'blind-date':
      return collectTextItems(payload.successPrediction, payload.conversationTopics);
    case 'avoid-people':
      return collectTextItems(payload.cautionPeople, payload.cautionObjects);
    case 'yearly-encounter':
      return collectTextItems(payload.appearanceHashtags, payload.encounterSpotTitle);
    case 'talent':
      return collectTextItems(payload.talentProfile, payload.strengthAreas);
    case 'exercise':
      return collectTextItems(payload.recommendedExercise, payload.weaknesses);
    case 'tarot':
      return collectTextItems(payload.cardInterpretations, payload.storyTitle);
    case 'past-life':
      return collectTextItems(payload.story, payload.chapters);
    default:
      return collectTextItems(
        payload.highlights,
        payload.keyPoints,
        payload.sections,
      );
  }
}

function extractRecommendations(
  fortuneType: FortuneTypeId,
  payload: UnknownRecord,
) {
  switch (fortuneType) {
    case 'daily':
      return collectReadableTextItems(
        extractDailyActionItems(payload.personalActions),
        payload.ai_tips,
        payload.advice,
      );
    case 'exam':
      return collectTextItems(payload.csatFocus, payload.csatChecklist, payload.dday_advice);
    case 'naming':
      return collectTextItems(payload.namingTips, payload.recommendedNames);
    case 'lucky-items':
      return collectTextItems(payload.fashion, payload.color);
    case 'biorhythm':
      return collectTextItems(payload.greeting, payload.status_message);
    case 'dream':
      return collectTextItems(payload.todayGuidance, payload.actionAdvice, payload.analysis);
    case 'talisman':
      return collectTextItems(payload.recommendations);
    case 'family':
      return collectTextItems(
        payload.communicationAdvice,
        payload.parentingAdvice,
        payload.educationTips,
        payload.relationshipGuide,
        payload.recommendations,
      );
    default:
      return collectTextItems(
        payload.advice,
        payload.recommendations,
        payload.guidance,
        payload.goalAdvice,
        payload.seasonal_advice,
        payload.todayRoutine,
      );
  }
}

function extractWarnings(
  fortuneType: FortuneTypeId,
  payload: UnknownRecord,
) {
  switch (fortuneType) {
    case 'daily':
      return collectReadableTextItems(
        sanitizeDailyReadableText(readStringValue(payload.caution)),
        extractDailyLowestCategoryAdvice(payload),
      );
    case 'avoid-people':
      return collectTextItems(
        payload.cautionTimes,
        payload.cautionActivities,
        payload.cautionColors,
        payload.cautionNumbers,
      );
    case 'health':
      return collectTextItems(payload.weak_organs);
    case 'blind-date':
      return collectTextItems(payload.dontsList);
    case 'yearly-encounter':
      return collectTextItems(payload.fateSignalWarnings, payload.fateSignalRisk);
    default:
      return collectTextItems(payload.warnings, payload.cautions, payload.dontsList);
  }
}

function extractLuckyItems(
  fortuneType: FortuneTypeId,
  payload: UnknownRecord,
) {
  switch (fortuneType) {
    case 'daily':
      return collectReadableKeywordItems(
        asRecord(payload.lucky_items).time,
        asRecord(payload.lucky_items).color,
        asRecord(payload.lucky_items).number,
        asRecord(payload.lucky_items).direction,
        asRecord(payload.lucky_items).item,
        payload.lucky_numbers,
      );
    case 'lucky-items':
      return collectTextItems(payload.color, payload.fashion, payload.numbers);
    case 'yearly-encounter':
      return collectTextItems(payload.encounterSpotTitle);
    default:
      return collectTextItems(payload.luckyItems, payload.lucky_items, payload.color);
  }
}

function extractSpecialTip(
  fortuneType: FortuneTypeId,
  payload: UnknownRecord,
) {
  switch (fortuneType) {
    case 'daily':
      return firstDailyReadableText(payload.special_tip);
    case 'exam':
      return firstText(payload.statusMessage, payload.positive_message);
    case 'yearly-encounter':
      return firstText(payload.encounterSpotStory);
    case 'decision':
      return firstText(payload.recommendation);
    default:
      return firstText(
        payload.specialTip,
        payload.special_tip,
        payload.main_message,
        payload.mainMessage,
        payload.greeting,
      );
  }
}

function collectTextItems(...values: unknown[]) {
  return values
    .flatMap((value) => toTextItems(value))
    .map((item) => item.trim())
    .filter(Boolean)
    .slice(0, 5);
}

function collectReadableTextItems(...values: unknown[]) {
  return values
    .flatMap((value) => toReadableTextItems(value))
    .map((item) => item.trim())
    .filter(Boolean)
    .slice(0, 5);
}

function collectReadableKeywordItems(...values: unknown[]) {
  return values
    .flatMap((value) => toReadableTextItems(value, { keyword: true }))
    .map((item) => item.trim())
    .filter(Boolean)
    .slice(0, 8);
}

function toTextItems(value: unknown): string[] {
  if (value == null) {
    return [];
  }

  if (typeof value === 'string') {
    return value.trim() ? [trimParagraph(value, 200)] : [];
  }

  if (typeof value === 'number' || typeof value === 'boolean') {
    return [String(value)];
  }

  if (Array.isArray(value)) {
    return value.flatMap((item) => toTextItems(item));
  }

  const record = asRecord(value);

  if (record.title || record.content || record.description || record.text) {
    return [
      [firstText(record.title), firstText(record.content, record.description, record.text)]
        .filter(Boolean)
        .join(': '),
    ].filter(Boolean) as string[];
  }

  return Object.values(record).flatMap((item) => toTextItems(item));
}

function toReadableTextItems(
  value: unknown,
  options: { keyword?: boolean } = {},
): string[] {
  if (value == null) {
    return [];
  }

  if (typeof value === 'string') {
    const cleaned = options.keyword
      ? sanitizeKeywordText(value)
      : sanitizeReadableText(value);
    return cleaned ? [cleaned] : [];
  }

  if (typeof value === 'number' || typeof value === 'boolean') {
    return [String(value)];
  }

  if (Array.isArray(value)) {
    return value.flatMap((item) => toReadableTextItems(item, options));
  }

  const record = asRecord(value);

  if (record.title || record.content || record.description || record.text) {
    const title = firstReadableText(record.title);
    const body = firstReadableText(
      record.content,
      record.description,
      record.text,
    );
    return [[title, body].filter(Boolean).join(': ')].filter(Boolean) as string[];
  }

  return Object.values(record).flatMap((item) => toReadableTextItems(item, options));
}

function mapRecordToMetricTiles(record: UnknownRecord): MetricTileData[] | undefined {
  const entries = Object.entries(record)
    .map(([key, value]) => toMetricTile(formatMetricLabel(key), value))
    .filter(Boolean) as MetricTileData[];

  return entries.length > 0 ? entries.slice(0, 4) : undefined;
}

function toMetricTile(label: string, value: unknown): MetricTileData | null {
  if (typeof value === 'number' && Number.isFinite(value)) {
    return {
      label,
      value: value > 0 && value <= 100 ? `${Math.trunc(value)}%` : String(Math.trunc(value)),
    };
  }

  if (typeof value === 'string' && value.trim()) {
    return {
      label,
      value: trimValue(value.trim(), 24),
    };
  }

  return null;
}

function formatMetricLabel(key: string) {
  return key
    .replace(/_/g, ' ')
    .replace(/\b\w/g, (char) => char.toUpperCase())
    .replace(/\bTpo\b/g, 'TPO');
}

function trimParagraph(value: string, limit: number) {
  const normalized = value.replace(/\s+/g, ' ').trim();
  return normalized.length > limit
    ? `${normalized.slice(0, limit - 1)}…`
    : normalized;
}

function firstText(...values: unknown[]) {
  for (const value of values) {
    if (typeof value === 'string' && value.trim()) {
      return trimParagraph(value, 200);
    }
  }

  return null;
}

function firstReadableText(...values: unknown[]) {
  for (const value of values) {
    if (typeof value === 'string' && value.trim()) {
      return sanitizeReadableText(value);
    }
  }

  return null;
}

function firstDailyReadableText(...values: unknown[]) {
  for (const value of values) {
    if (typeof value === 'string' && value.trim()) {
      return sanitizeDailyReadableText(value);
    }
  }

  return null;
}

function sanitizeReadableText(value: string) {
  const withoutMarkdown = value
    .replace(/\*\*(.*?)\*\*/gu, '$1')
    .replace(/__(.*?)__/gu, '$1')
    .replace(/`([^`]+)`/gu, '$1')
    .replace(/\[([^\]]+)\]\(([^)]+)\)/gu, '$1')
    .replace(/^\s{0,3}#{1,6}\s+/gmu, '')
    .replace(/^\s*>\s?/gmu, '')
    .replace(/^\s*\d+[.)]\s+/gmu, '')
    .replace(/^\s*[-*•]+\s+/gmu, '')
    .replace(/\r\n/gu, '\n');

  const withoutEmoji = withoutMarkdown.replace(
    /[\u{1F600}-\u{1F64F}]|[\u{1F300}-\u{1F5FF}]|[\u{1F680}-\u{1F6FF}]|[\u{1F1E0}-\u{1F1FF}]|[\u{2600}-\u{26FF}]|[\u{2700}-\u{27BF}]|[\u{1F900}-\u{1F9FF}]|[\u{1FA00}-\u{1FAFF}]|[\u{2B50}]|[\u{2B55}]/gu,
    '',
  );

  return withoutEmoji
    .replace(/[ \t]+\n/gu, '\n')
    .replace(/\n{3,}/gu, '\n\n')
    .replace(/[ \t]{2,}/gu, ' ')
    .trim();
}

function sanitizeDailyReadableText(value: string | null | undefined) {
  if (!value) {
    return '';
  }

  const sanitized = sanitizeReadableText(value)
    .replace(/\b오늘의 바이브\b/gu, '종합 흐름')
    .replace(/\b애정운 바이브\b/gu, '애정 흐름')
    .replace(/\b금전운 바이브\b/gu, '금전 흐름')
    .replace(/\b직장운 바이브\b/gu, '직장 흐름')
    .replace(/\b학업운 바이브\b/gu, '학업 흐름')
    .replace(/\b건강운 바이브\b/gu, '건강 흐름')
    .replace(/\b갓생 치트키\b/gu, '실천 팁')
    .replace(/\b오늘의 한마디\b/gu, '마무리 한마디')
    .replace(/\b럭키비키\b/gu, '운이 좋은 흐름')
    .replace(/\b갓생\b/gu, '하루')
    .replace(/\b레전드 of 레전드\b/gu, '매우 좋은')
    .replace(/\b레전드\b/gu, '좋은')
    .replace(/\b무지성\b/gu, '망설임 없이')
    .replace(/\b찐으로\b/gu, '정말')
    .replace(/\b심쿵\b/gu, '설렘')
    .replace(/\b순삭\b/gu, '빠르게')
    .replace(/\b칼퇴\b/gu, '일정 마무리')
    .replace(/\bMAX\b/gu, '높은')
    .replace(/\bUP\b/gu, '상승')
    .replace(/[“”"]/gu, '')
    .replace(/\(\s*진심\s*\)/gu, '')
    .replace(/[!]{2,}/gu, '!')
    .replace(/[?]{2,}/gu, '?');

  return sanitized
    .replace(/[ \t]+\n/gu, '\n')
    .replace(/\n{3,}/gu, '\n\n')
    .trim();
}

function sanitizeKeywordText(value: string) {
  return sanitizeReadableText(value).replace(/\n+/gu, ' ');
}

function readStringValue(value: unknown) {
  return typeof value === 'string' ? value : null;
}

function asRecord(value: unknown): UnknownRecord {
  if (typeof value === 'object' && value !== null && !Array.isArray(value)) {
    return value as UnknownRecord;
  }

  return {};
}
