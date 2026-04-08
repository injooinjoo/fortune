import type {
  FortuneTypeId,
  NormalizedFortuneResult,
} from "@fortune/product-contracts";

import {
  formatSurveyAnswerLabel,
  getChatSurveyDefinition,
} from "../chat-survey/registry";
import type { ChatSurveyStep } from "../chat-survey/types";
import type {
  MetricTileData,
  ResultKind,
  TimelineEntry,
} from "../fortune-results/types";
import { buildFallbackEmbeddedResultPayload } from "./fixtures";
import type {
  EmbeddedResultBuildContext,
  EmbeddedResultDetailSection,
  EmbeddedResultPayload,
} from "./types";

const contextLabelByStepId: Partial<Record<string, string>> = {
  analysisType: "분석",
  specificQuestion: "포인트",
  customQuestion: "직접 질문",
  calendarSync: "일정 기준",
  targetDate: "날짜",
  mbtiType: "MBTI",
  category: "카테고리",
  field: "분야",
  position: "포지션",
  concern: "고민",
  partnerName: "상대 이름",
  partnerBirth: "상대 생일",
  relationship: "관계",
  dateType: "만남 성격",
  expectation: "기대 포인트",
  meetingTime: "만나는 시간",
  isFirstBlindDate: "첫 소개팅 여부",
  primaryGoal: "바라는 방향",
  breakupTime: "헤어진 시점",
  relationshipDepth: "관계 깊이",
  coreReason: "이별 이유",
  currentState: "현재 상태",
  status: "관계 상태",
  datingStyle: "연애 스타일",
  idealLooks: "이상형 분위기",
  idealPersonality: "이상형 성격",
  targetGender: "상대 성별",
  userAge: "나이대",
  idealMbti: "이상형 MBTI",
  idealStyle: "선호 스타일",
  idealType: "이상형 이미지",
  breakupInitiator: "이별 계기",
  contactStatus: "연락 상태",
  detailedStory: "추가 사연",
  currentCondition: "컨디션",
  stressLevel: "스트레스",
  sleepQuality: "수면 상태",
  exerciseFrequency: "운동 빈도",
  mealRegularity: "식사 규칙성",
  dreamContent: "꿈 장면",
  emotion: "꿈 감정",
  member: "대상",
  relationshipDetails: "관계 포인트",
  wealthDetails: "재물 포인트",
  childrenDetails: "자녀 포인트",
  changeDetails: "변화 포인트",
  healthDetails: "건강 포인트",
  specialQuestion: "추가 질문",
  curiosity: "궁금한 점",
  eraVibe: "시대감",
  feeling: "감각",
  dueDateKnown: "예정일 여부",
  dueDate: "예정일",
  gender: "성별",
  lastName: "성",
  style: "느낌",
  babyDream: "원하는 이미지",
  wishContent: "소원",
  mbti: "MBTI",
  bloodType: "혈액형",
  zodiac: "별자리",
  zodiacAnimal: "띠",
  goal: "목표",
  income: "수입 흐름",
  expense: "지출 흐름",
  risk: "리스크 성향",
  urgency: "변화 시급도",
  generationMode: "부적 스타일",
  situation: "상황",
  interests: "관심",
  interest: "관심 분야",
  workStyle: "작업 스타일",
  problemSolving: "문제 해결 방식",
  experience: "경험 수준",
  timeAvailable: "투자 가능 시간",
  challenges: "어려운 점",
  intensity: "강도",
  examType: "시험 종류",
  examDate: "시험 날짜",
  preparation: "준비 상태",
  purpose: "주제",
  questionText: "질문",
  tarotSelection: "선택 카드",
  tpo: "상황",
  lookNote: "룩 설명",
  photo: "첨부 사진",
  bokchae: "복채",
  currentArea: "현재 지역",
  targetArea: "이사 지역",
  movingPeriod: "이사 시기",
  celebrityName: "유명인",
  connectionType: "관계 관점",
  petName: "반려동물 이름",
  petSpecies: "반려동물 종류",
  petAge: "반려동물 나이",
  petGender: "반려동물 성별",
  petPersonality: "반려동물 성격",
  sport: "종목",
  homeTeam: "홈팀",
  awayTeam: "원정팀",
  gameDate: "경기 날짜",
  favoriteSide: "응원 방향",
  decisionType: "결정 유형",
  question: "고민 질문",
  optionsText: "선택지",
  sportType: "운동 종류",
  weeklyFrequency: "운동 빈도",
  preferredTime: "선호 시간",
  injuryHistory: "주의 부위",
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
  const contextualAction = buildContextualAction(
    fortuneType,
    normalizedContext,
  );
  const payload = asRecord(normalizedResult.payload);
  const summarySource =
    normalizedResult.summary ?? normalizedResult.content ?? fallback.summary;
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
    score:
      normalizedResult.score ??
      applyContextualScore(fallback.score, fortuneType, context),
    summary,
    contextTags:
      normalizedContext.tags.length > 0 ? normalizedContext.tags : undefined,
    metrics: selectMetricTiles(extractedMetrics, fallback.metrics),
    highlights: selectTextItems(
      extractedHighlights,
      mergeUnique(
        buildContextualHighlights(fortuneType, normalizedContext),
        fallback.highlights,
      ),
    ),
    recommendations: selectTextItems(
      extractedRecommendations,
      mergeUnique(
        contextualAction ? [contextualAction] : [],
        fallback.recommendations,
      ),
    ),
    warnings: selectTextItems(extractedWarnings, fallback.warnings),
    luckyItems: selectTextItems(extractedLuckyItems, fallback.luckyItems),
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
    fortuneType === "daily"
      ? sanitizeDailyReadableText(summarySource)
      : trimParagraph(sanitizeReadableText(summarySource), 320);

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
        rawAnswer === "" ||
        rawAnswer === "skip" ||
        (Array.isArray(rawAnswer) && rawAnswer.length === 0)
      ) {
        continue;
      }

      const displayValue = formatAnswerValue(step, rawAnswer, context);

      if (!displayValue) {
        continue;
      }

      labels[step.id] = displayValue;

      if (step.id === "mbtiConfirm") {
        continue;
      }

      if (step.inputKind === "photo") {
        continue;
      }

      tags.push(`${contextLabelForStep(step)}: ${displayValue}`);
    }
  }

  if (
    (fortuneType === "traditional-saju" || fortuneType === "daily-calendar") &&
    context.profile?.birthDate
  ) {
    labels.birthDate = context.profile.birthDate;
    tags.push(`생년월일: ${context.profile.birthDate}`);
  }

  if (
    fortuneType === "traditional-saju" &&
    context.profile?.birthTime &&
    !labels.birthTime
  ) {
    labels.birthTime = context.profile.birthTime;
    tags.push(`출생시간: ${context.profile.birthTime}`);
  }

  if (
    (fortuneType === "mbti" || fortuneType === "personality-dna") &&
    context.profile?.mbti &&
    !labels.mbti &&
    !labels.mbtiType
  ) {
    labels.mbti = context.profile.mbti.toUpperCase();
    tags.push(`MBTI: ${context.profile.mbti.toUpperCase()}`);
  }

  if (
    (fortuneType === "blood-type" || fortuneType === "personality-dna") &&
    context.profile?.bloodType &&
    !labels.bloodType
  ) {
    labels.bloodType = context.profile.bloodType.toUpperCase();
    tags.push(`혈액형: ${context.profile.bloodType.toUpperCase()}`);
  }

  const freeText =
    labels.customQuestion ??
    labels.questionText ??
    labels.specialQuestion ??
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
  if (step.id === "mbtiConfirm" && answer === "yes" && context.profile?.mbti) {
    return context.profile.mbti.toUpperCase();
  }

  const label = formatSurveyAnswerLabel(step, answer).trim();

  if (!label) {
    return null;
  }

  return trimValue(label, step.inputKind === "text" ? 64 : 40);
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
    case "traditional-saju":
      return joinSentence([
        labels.analysisType ? `${labels.analysisType} 흐름을 기준으로` : null,
        labels.specificQuestion || labels.customQuestion
          ? `${labels.specificQuestion ?? "직접 남긴 질문"} 포인트를 좁혀`
          : "핵심 균형을 먼저 잡아",
        "정리했습니다.",
      ]);
    case "daily-calendar":
      return joinSentence([
        labels.targetDate ? `${labels.targetDate} 날짜 기준으로` : null,
        labels.calendarSync === "일정과 함께 보기"
          ? "일정 리듬까지 함께 묶어"
          : "날짜 결을 중심으로",
        "읽었습니다.",
      ]);
    case "mbti":
      return joinSentence([
        labels.mbtiType || labels.mbti
          ? `${labels.mbtiType ?? labels.mbti} 성향을 기준으로`
          : "현재 성향을 기준으로",
        labels.category ? `${labels.category} 인사이트에 초점을 맞춰` : null,
        "정리했습니다.",
      ]);
    case "career":
      return joinSentence([
        labels.field ? `${labels.field} 분야에서` : null,
        labels.position ? `${labels.position} 포지션 관점으로` : null,
        labels.concern
          ? `${labels.concern} 고민을 중심으로`
          : "커리어 흐름을 중심으로",
        "읽었습니다.",
      ]);
    case "love":
      return joinSentence([
        labels.status ? `${labels.status} 상태에서` : "현재 관계 흐름에서",
        labels.concern
          ? `${labels.concern} 포인트를 중심으로`
          : "감정 리듬을 중심으로",
        "풀어봤어요.",
      ]);
    case "health":
      return joinSentence([
        labels.currentCondition
          ? `${labels.currentCondition} 컨디션 기준으로`
          : null,
        labels.concern
          ? `${labels.concern} 이슈를 먼저 보고`
          : "회복 리듬을 먼저 보고",
        "정리했습니다.",
      ]);
    case "family":
      return joinSentence([
        labels.member ? `${labels.member} 중심 관계에서` : "가족 관계에서",
        labels.concern
          ? `${labels.concern} 흐름을 기준으로`
          : "대화 톤을 기준으로",
        context.firstFreeText
          ? `“${trimValue(context.firstFreeText, 32)}” 질문까지 함께 반영해`
          : null,
        "읽었습니다.",
      ]);
    case "past-life":
      return joinSentence([
        labels.curiosity ? `${labels.curiosity} 질문을 중심으로` : null,
        labels.eraVibe ? `${labels.eraVibe} 시대감과 함께` : null,
        "상징을 좁혀봤습니다.",
      ]);
    case "wish":
      return joinSentence([
        labels.category
          ? `${labels.category} 소원을 중심으로`
          : "현재 바람을 중심으로",
        context.firstFreeText
          ? `“${trimValue(context.firstFreeText, 36)}”라는 문장을 기준으로`
          : null,
        "해석했습니다.",
      ]);
    case "personality-dna":
      return joinSentence([
        labels.mbti ? `${labels.mbti} 성향과` : null,
        labels.bloodType ? `${labels.bloodType} 기질,` : null,
        labels.zodiac
          ? `${labels.zodiac} 흐름을 함께 묶어`
          : "강점 축을 중심으로",
        "정리했습니다.",
      ]);
    case "face-reading":
      return joinSentence([
        "첨부한 얼굴 사진을 기준으로",
        "인상과 관상 포인트를 중심으로",
        "정리했습니다.",
      ]);
    case "wealth":
      return joinSentence([
        labels.goal ? `${labels.goal} 목표를 우선으로` : null,
        labels.concern
          ? `${labels.concern} 고민을 중심으로`
          : "금전 리듬을 중심으로",
        "읽었습니다.",
      ]);
    case "talent":
      return joinSentence([
        labels.interest ? `${labels.interest} 관심 분야와` : null,
        labels.workStyle
          ? `${labels.workStyle} 작업 스타일을 기준으로`
          : "강점 발현 방식을 기준으로",
        "정리했습니다.",
      ]);
    case "exercise":
      return joinSentence([
        labels.goal ? `${labels.goal} 목표에 맞춰` : null,
        labels.intensity ? `${labels.intensity} 강도로` : "지속 가능한 강도로",
        "풀었습니다.",
      ]);
    case "tarot":
      return joinSentence([
        labels.purpose ? `${labels.purpose} 주제에 맞춰` : null,
        context.firstFreeText
          ? `“${trimValue(context.firstFreeText, 32)}”를 질문으로 삼아`
          : null,
        labels.tarotSelection
          ? `${labels.tarotSelection} 흐름을 기준으로`
          : "카드 흐름을 기준으로",
        "읽었습니다.",
      ]);
    case "ootd-evaluation":
      return joinSentence([
        labels.tpo ? `${labels.tpo} 상황 기준으로` : null,
        context.firstFreeText
          ? `“${trimValue(context.firstFreeText, 36)}” 룩 설명을 반영해`
          : "현재 룩 무드를 반영해",
        "정리했습니다.",
      ]);
    case "blood-type":
      return labels.bloodType
        ? `${labels.bloodType} 기질을 기준으로 포인트를 정리했습니다.`
        : null;
    default:
      if (context.tags.length > 0) {
        return `이번 결과는 ${context.tags.slice(0, 2).join(", ")} 기준으로 정리했습니다.`;
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
    case "tarot":
      if (context.labels.tarotSelection) {
        highlights.push(
          `선택 카드 ${context.labels.tarotSelection} 흐름을 우선 반영했어요.`,
        );
      }
      break;
    case "wish":
      if (context.firstFreeText) {
        highlights.push(`직접 적어준 소원 문장을 해석의 중심에 두었습니다.`);
      }
      break;
    case "ootd-evaluation":
      if (context.firstFreeText) {
        highlights.push(
          `룩 설명에 적은 포인트를 중심으로 스타일 인상을 읽었습니다.`,
        );
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
    case "career":
      if (labels.concern === "이직/전환") {
        return "이직 판단은 기준 세 가지를 먼저 적은 뒤 비교하는 방식이 가장 안전합니다.";
      }
      return null;
    case "love":
      if (labels.concern === "고백 타이밍") {
        return "확답을 서두르기보다 질문형 대화를 한 번 더 늘려보세요.";
      }
      return null;
    case "health":
      if (labels.concern === "수면") {
        return "오늘은 취침 시간을 먼저 고정하는 쪽이 가장 효과적입니다.";
      }
      return null;
    case "wealth":
      if (labels.goal === "저축 늘리기") {
        return "이번 주는 고정지출 한 항목만 바로 줄여도 흐름이 안정됩니다.";
      }
      return null;
    case "ootd-evaluation":
      if (labels.tpo === "데이트") {
        return "데이트 룩은 포인트 컬러를 한 군데만 남길 때 인상이 가장 또렷합니다.";
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
  if (typeof baseScore !== "number") {
    return baseScore;
  }

  const seed = JSON.stringify({
    fortuneType,
    answers: context.answers ?? {},
    profile: context.profile ?? {},
    characterName: context.characterName ?? "",
  });
  const variance = (hashString(seed) % 9) - 4;

  return clamp(baseScore + variance, 60, 96);
}

function joinSentence(parts: Array<string | null | undefined>) {
  const content = parts.filter(Boolean).join(" ").trim();
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
    .replace(/[?.!？。]+$/u, "")
    .replace(/(해주세요|해주세요\.|있나요|인가요|까요|볼까요)$/u, "")
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
    const key = `${item.label}:${item.value}:${item.note ?? ""}`.trim();

    if (!key || seen.has(key)) {
      continue;
    }

    seen.add(key);
    merged.push(item);
  }

  return merged.length > 0 ? merged.slice(0, 4) : undefined;
}

function selectMetricTiles(
  preferred: MetricTileData[] | undefined,
  fallback: MetricTileData[] | undefined,
) {
  if (preferred && preferred.length > 0) {
    return preferred.slice(0, 4);
  }

  return mergeMetricTiles(preferred, fallback);
}

function selectTextItems(
  preferred: string[] | undefined,
  fallback: string[] | undefined,
) {
  if (preferred && preferred.length > 0) {
    return preferred.slice(0, 5);
  }

  return mergeUnique(preferred, fallback);
}

function extractDetailSections(
  fortuneType: FortuneTypeId,
  payload: UnknownRecord,
): EmbeddedResultDetailSection[] | undefined {
  switch (fortuneType) {
    case "daily":
      return extractDailyDetailSections(payload);
    case "daily-calendar":
      return createRecordSections([
        ["시간대 전략", payload.timeStrategy],
        ["주의 시간대", payload.cautionTimes],
        ["행운 요소", payload.luckyElements],
        ["캘린더 조언", payload.calendarAdvice],
        ["전통 요소", payload.traditionalElements],
      ]);
    case "new-year":
      return createRecordSections([
        ["목표 운세", payload.goalFortune],
        ["사주 분석", payload.sajuAnalysis],
        ["행동 계획", payload.actionPlan],
        ["월별 하이라이트", payload.monthlyHighlights],
      ]);
    case "personality-dna":
      return createRecordSections([
        ["연애 스타일", payload.loveStyle],
        ["업무 스타일", payload.workStyle],
        ["일상 매칭", payload.dailyMatching],
        ["궁합 힌트", payload.compatibility],
      ]);
    case "face-reading":
      return extractFaceReadingDetailSections(payload);
    case "ootd-evaluation":
      return extractOotdDetailSections(payload);
    case "moving":
      return createRecordSections([
        ["방향 분석", payload.direction_analysis],
        ["시기 조언", payload.timing_analysis],
        ["길일 추천", payload.lucky_dates],
        ["풍수 팁", payload.feng_shui_tips],
        ["지형 분석", payload.terrain_analysis],
        ["정착 지수", payload.settlement_index],
      ]);
    case "love":
      return createRecordSections([
        ["연애 프로필", payload.loveProfile],
        ["연애 스타일", asRecord(payload.detailedAnalysis).loveStyle],
        ["매력 포인트", asRecord(payload.detailedAnalysis).charmPoints],
        ["보완 포인트", asRecord(payload.detailedAnalysis).improvementAreas],
        [
          "궁합 인사이트",
          asRecord(payload.detailedAnalysis).compatibilityInsights,
        ],
        ["오늘 조언", payload.todaysAdvice],
      ]);
    case "family":
      return createRecordSections([
        ["관계 카테고리", payload.relationshipCategories],
        ["재물 카테고리", payload.wealthCategories],
        ["자녀 분석", payload.childAnalysis],
        ["변화 분석", payload.changeCategories],
        ["건강 카테고리", payload.healthCategories],
        ["소통 조언", payload.communicationAdvice],
        ["타이밍 조언", payload.timingAdvice],
        ["가족 팁", payload.familyAdvice],
      ]);
    case "wish":
      return createRecordSections([
        ["운의 흐름", payload.fortune_flow],
        ["행운 미션", payload.lucky_mission],
        ["용의 메시지", payload.dragon_message],
      ]);
    case "health":
      return createRecordSections([
        ["오행 균형", payload.element_balance],
        ["추천 루틴", payload.recommendations],
        ["계절 조언", payload.seasonal_advice],
      ]);
    case "wealth":
      return createRecordSections([
        ["오행 재물 분석", payload.elementAnalysis],
        ["목표 가이드", payload.goalAdvice],
        ["투자 인사이트", payload.investmentInsights],
        ["월별 흐름", payload.monthlyFlow],
      ]);
    case "talent":
      return createRecordSections([
        ["재능 프로필", payload.talentProfile],
        ["스킬 추천", payload.skillRecommendations],
        ["성장 로드맵", payload.roadmap],
        ["도전 과제", payload.challenges],
      ]);
    case "exercise":
      return createRecordSections([
        ["추천 운동", payload.recommendedExercise],
        ["오늘 루틴", payload.todayRoutine],
        ["주간 계획", payload.weeklyPlan],
        ["부상 예방", payload.injuryPrevention],
      ]);
    case "talisman":
      return createRecordSections([
        [
          "부적 요약",
          {
            categoryName: payload.categoryName,
            shortDescription: payload.shortDescription,
            imageSource: payload.imageSource,
          },
        ],
      ]);
    case "celebrity":
      return createRecordSections([
        ["사주 분석", payload.saju_analysis],
        ["전생 인연", payload.past_life],
        ["운명의 시기", payload.destined_timing],
      ]);
    case "pet-compatibility":
      return createRecordSections([
        ["오늘 스토리", payload.today_story],
        ["품종 포인트", payload.breed_specific],
        ["교감 흐름", payload.owner_bond],
        ["오늘의 미션", payload.bonding_mission],
      ]);
    case "match-insight":
      return createRecordSections([
        ["승부 예측", payload.prediction],
        ["응원팀 분석", payload.favoriteTeamAnalysis],
        ["상대팀 분석", payload.opponentAnalysis],
        ["행운 요소", payload.fortuneElements],
      ]);
    case "decision":
      return createDecisionDetailSections(payload.options);
    default:
      return undefined;
  }
}

function extractTimelineEntries(
  fortuneType: FortuneTypeId,
  payload: UnknownRecord,
): TimelineEntry[] | undefined {
  if (fortuneType !== "daily") {
    return undefined;
  }

  const predictions = asRecord(payload.daily_predictions);
  const directEntries = [
    createTimelineEntry("오전", predictions.morning),
    createTimelineEntry("오후", predictions.afternoon),
    createTimelineEntry("저녁", predictions.evening),
  ].filter(Boolean) as TimelineEntry[];

  if (directEntries.length > 0) {
    return directEntries;
  }

  const legacyEntries = Array.isArray(payload.timeSpecificFortunes)
    ? (payload.timeSpecificFortunes
        .map((entry) => createLegacyTimelineEntry(entry))
        .filter(Boolean) as TimelineEntry[])
    : [];

  return legacyEntries.length > 0 ? legacyEntries : undefined;
}

function extractDailyMetricTiles(
  payload: UnknownRecord,
): MetricTileData[] | undefined {
  const categories = asRecord(payload.categories);
  const entries = [
    toDailyCategoryMetric("종합운", categories.total),
    toDailyCategoryMetric("연애", categories.love),
    toDailyCategoryMetric("재물", categories.money),
    toDailyCategoryMetric("일/학업", categories.work ?? categories.study),
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
    const content = [title, why].filter(Boolean).join(": ");

    return content ? [content] : [];
  });
}

function extractDailyLowestCategoryAdvice(payload: UnknownRecord) {
  const categories = asRecord(payload.categories);
  const candidates = [
    { label: "연애", value: categories.love },
    { label: "재물", value: categories.money },
    { label: "일", value: categories.work },
    { label: "공부", value: categories.study },
    { label: "건강", value: categories.health },
  ];

  let lowest: { label: string; score: number; advice: string | null } | null =
    null;

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
    createDailyDetailSection("종합 흐름", categories.total),
    createDailyDetailSection("연애 흐름", categories.love),
    createDailyDetailSection("재물 흐름", categories.money),
    createDailyDetailSection("일과 학업", categories.work ?? categories.study),
    createDailyDetailSection("건강 흐름", categories.health),
  ].filter(Boolean) as EmbeddedResultDetailSection[];

  return sections.length > 0 ? sections : undefined;
}

function createRecordSections(
  entries: Array<[string, unknown]>,
): EmbeddedResultDetailSection[] | undefined {
  const sections = entries
    .map(([title, value]) => createRecordSection(title, value))
    .filter(Boolean) as EmbeddedResultDetailSection[];

  return sections.length > 0 ? sections : undefined;
}

function createRecordSection(
  title: string,
  value: unknown,
): EmbeddedResultDetailSection | null {
  const body = summarizeSectionValue(value);
  if (!body) {
    return null;
  }

  const record = asRecord(value);
  const score =
    readScore(record.score) ??
    readScore(record.overall_score) ??
    readScore(record.overallScore) ??
    undefined;

  return {
    title,
    body,
    score,
  };
}

function createDecisionDetailSections(
  value: unknown,
): EmbeddedResultDetailSection[] | undefined {
  if (!Array.isArray(value)) {
    return undefined;
  }

  const sections = value
    .map((entry) => {
      const record = asRecord(entry);
      const option = firstReadableText(record.option);
      const pros = toReadableTextItems(record.pros).slice(0, 2);
      const cons = toReadableTextItems(record.cons).slice(0, 2);
      const body = [
        pros.length > 0 ? `장점: ${pros.join(" / ")}` : null,
        cons.length > 0 ? `주의: ${cons.join(" / ")}` : null,
      ]
        .filter(Boolean)
        .join("\n");

      if (!option || !body) {
        return null;
      }

      return {
        title: option,
        body,
      };
    })
    .filter(Boolean) as EmbeddedResultDetailSection[];

  return sections.length > 0 ? sections : undefined;
}

function summarizeSectionValue(value: unknown) {
  const direct = firstReadableText(value);
  if (direct) {
    return direct;
  }

  const record = asRecord(value);
  const summary = firstReadableText(
    record.description,
    record.analysis,
    record.interpretation,
    record.summary,
    record.content,
    record.reason,
    record.tip,
    record.advice,
    record.opening,
    record.story,
    record.title,
    record.text,
  );

  if (summary) {
    return summary;
  }

  const items = toReadableTextItems(value).slice(0, 3);
  return items.length > 0 ? items.join(" / ") : null;
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

function createLegacyTimelineEntry(value: unknown): TimelineEntry | null {
  const entry = asRecord(value);
  const title = firstDailyReadableText(entry.time, entry.label, entry.title);
  const body = firstDailyReadableText(
    entry.description,
    entry.recommendation,
    entry.body,
  );

  if (!title || !body) {
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

  if (typeof advice === "string") {
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
    .split("\n")
    .map((line) => line.trim())
    .filter(Boolean)
    .filter((line) => !isDailyHeadingLine(line));

  const firstParagraph = lines.find((line) => !line.startsWith("- "));
  if (firstParagraph) {
    return firstParagraph;
  }

  return lines[0] ?? null;
}

function isDailyHeadingLine(line: string) {
  return (
    line === "종합 흐름" ||
    line === "애정 흐름" ||
    line === "금전 흐름" ||
    line === "직장 흐름" ||
    line === "학업 흐름" ||
    line === "건강 흐름" ||
    line === "실천 팁" ||
    line === "주의할 점" ||
    line === "마무리 한마디"
  );
}

function readScore(value: unknown) {
  if (typeof value === "number" && Number.isFinite(value)) {
    return value;
  }

  if (typeof value === "string" && value.trim()) {
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
    case "daily":
      return extractDailyMetricTiles(payload);
    case "daily-calendar":
      return [
        toMetricTile("날짜 점수", payload.overall_score ?? payload.score),
        toMetricTile("최고 시간", asRecord(payload.bestTime).period),
        toMetricTile("주의 시간", asRecord(payload.worstTime).period),
        toMetricTile("행운 방향", asRecord(payload.luckyElements).direction),
      ].filter(Boolean) as MetricTileData[];
    case "new-year":
      return [
        toMetricTile("연간 점수", payload.overall_score ?? payload.score),
        toMetricTile("집중 목표", asRecord(payload.goalFortune).goalLabel),
        toMetricTile(
          "최고의 달",
          toTextItems(asRecord(payload.goalFortune).bestMonths)[0],
        ),
        toMetricTile(
          "주의 달",
          toTextItems(asRecord(payload.goalFortune).cautionMonths)[0],
        ),
      ].filter(Boolean) as MetricTileData[];
    case "compatibility":
      return mergeMetricTiles(
        [
          toMetricTile(
            "궁합 점수",
            payload.overall_compatibility ?? payload.overall_score,
          ),
          toMetricTile("궁합 등급", payload.compatibility_grade),
        ].filter(Boolean) as MetricTileData[],
        mapRecordToMetricTiles(asRecord(payload.personality_match)),
      );
    case "blind-date":
      return mergeMetricTiles(
        [
          toMetricTile("성공 확률", payload.successRate),
          toMetricTile("분위기 점수", payload.score),
        ].filter(Boolean) as MetricTileData[],
        undefined,
      );
    case "exam":
      return mergeMetricTiles(
        mapRecordToMetricTiles(asRecord(payload.examStats)),
        [
          toMetricTile("합격 감각", payload.passGrade),
          toMetricTile("집중 흐름", payload.score),
        ].filter(Boolean) as MetricTileData[],
      );
    case "mbti":
      return [
        toMetricTile("종합 점수", payload.overallScore),
        toMetricTile("에너지 레벨", payload.energyLevel),
      ].filter(Boolean) as MetricTileData[];
    case "biorhythm":
      return [
        toMetricTile("신체 리듬", payload.physical),
        toMetricTile("감정 리듬", payload.emotional),
      ].filter(Boolean) as MetricTileData[];
    case "personality-dna":
      return [
        toMetricTile("DNA 코드", payload.dnaCode),
        toMetricTile("에너지 레벨", asRecord(payload.dailyFortune).energyLevel),
        toMetricTile("소셜 랭킹", payload.socialRanking),
      ].filter(Boolean) as MetricTileData[];
    case "health":
      return mergeMetricTiles(
        mapRecordToMetricTiles(asRecord(payload.element_balance)),
        [
          toMetricTile("건강 점수", payload.healthScore ?? payload.score),
        ].filter(Boolean) as MetricTileData[],
      );
    case "love":
      return [
        toMetricTile("연애 점수", payload.score ?? payload.overall_score),
        toMetricTile(
          "현재 상태",
          asRecord(payload.personalInfo).relationshipStatus,
        ),
        toMetricTile(
          "주요 스타일",
          asRecord(payload.loveProfile).dominantStyle,
        ),
        toMetricTile(
          "소통 톤",
          asRecord(payload.loveProfile).communicationStyle,
        ),
      ].filter(Boolean) as MetricTileData[];
    case "moving":
      return [
        toMetricTile("이사 점수", payload.moving_score ?? payload.overallScore),
        toMetricTile(
          "방향 궁합",
          asRecord(payload.direction_analysis).compatibility ??
            asRecord(payload.directionAnalysis).compatibility,
        ),
        toMetricTile("정착 지수", asRecord(payload.settlement_index).score),
      ].filter(Boolean) as MetricTileData[];
    case "family":
      return mergeMetricTiles(
        [
          toMetricTile(
            "가족 점수",
            payload.overallScore ?? payload.overall_score ?? payload.score,
          ),
        ].filter(Boolean) as MetricTileData[],
        [
          toScoredMetricTile(
            "관계 흐름",
            asRecord(payload.relationshipCategories).harmony,
          ),
          toScoredMetricTile(
            "재물 흐름",
            asRecord(payload.wealthCategories).stability,
          ),
          toScoredMetricTile(
            "건강 흐름",
            asRecord(payload.healthCategories).physical,
          ),
          toMetricTile(
            "변화 타이밍",
            asRecord(payload.timingAdvice).best_timing,
          ),
        ].filter(Boolean) as MetricTileData[],
      );
    case "wish":
      return [
        toMetricTile(
          "성취 기운",
          asRecord(payload.fortune_flow).achievement_level,
        ),
        toMetricTile(
          "행운 타이밍",
          asRecord(payload.fortune_flow).lucky_timing,
        ),
        toMetricTile("행운 아이템", asRecord(payload.lucky_mission).item),
      ].filter(Boolean) as MetricTileData[];
    case "celebrity":
      return [
        toMetricTile("궁합 점수", payload.overall_score),
        toMetricTile("궁합 등급", payload.compatibility_grade),
      ].filter(Boolean) as MetricTileData[];
    case "pet-compatibility":
      return [
        toMetricTile(
          "오늘 컨디션",
          asRecord(payload.daily_condition).overall_score,
        ),
        toMetricTile("교감 점수", asRecord(payload.owner_bond).bond_score),
      ].filter(Boolean) as MetricTileData[];
    case "match-insight":
      return [
        toMetricTile("승률 예측", asRecord(payload.prediction).winProbability),
        toMetricTile("확신도", asRecord(payload.prediction).confidence),
      ].filter(Boolean) as MetricTileData[];
    case "game-enhance":
      return mergeMetricTiles(
        [
          toMetricTile("행운 등급", payload.lucky_grade),
          toMetricTile("강화 점수", payload.score),
        ].filter(Boolean) as MetricTileData[],
        mapRecordToMetricTiles(asRecord(payload.enhance_stats)),
      );
    case "face-reading":
      return extractFaceReadingMetricTiles(payload);
    case "ootd-evaluation":
      return extractOotdMetricTiles(payload);
    case "wealth":
      return [
        toMetricTile("재물 잠재력", payload.wealthPotential),
        toMetricTile("전체 점수", payload.overallScore ?? payload.score),
      ].filter(Boolean) as MetricTileData[];
    case "talent":
      return [
        toMetricTile("재능 점수", payload.overallScore ?? payload.score),
        toMetricTile("재능 결", asRecord(payload.talentProfile).type),
        toMetricTile("핵심 강점", asRecord(payload.talentProfile).strength),
      ].filter(Boolean) as MetricTileData[];
    case "exercise":
      return [
        toMetricTile("운동 점수", payload.score ?? payload.overallScore),
        toMetricTile("권장 시간", payload.optimalTime),
        toMetricTile(
          "주요 운동",
          asRecord(asRecord(payload.recommendedExercise).primary).name ??
            asRecord(asRecord(payload.recommendedExercise).primary).exercise,
        ),
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

function extractHighlights(fortuneType: FortuneTypeId, payload: UnknownRecord) {
  switch (fortuneType) {
    case "daily":
      return collectReadableTextItems(
        sanitizeDailyReadableText(readStringValue(payload.ai_insight)),
        extractDailyCategoryBody(asRecord(payload.categories).total),
        asRecord(asRecord(payload.fortuneSummary).byZodiacAnimal).content,
      );
    case "daily-calendar":
      return collectReadableTextItems(
        payload.dayTheme,
        payload.specialMessage,
        payload.timeSlots,
        payload.cautionActivities,
        payload.cautionPeople,
      );
    case "new-year":
      return collectReadableTextItems(
        asRecord(payload.goalFortune).prediction,
        payload.monthlyHighlights,
        payload.sajuAnalysis,
        payload.specialMessage,
      );
    case "compatibility":
      return collectTextItems(
        payload.personality_match,
        payload.communication_match,
        payload.love_match,
      );
    case "blind-date":
      return collectTextItems(
        payload.successPrediction,
        payload.conversationTopics,
      );
    case "avoid-people":
      return collectTextItems(payload.cautionPeople, payload.cautionObjects);
    case "yearly-encounter":
      return collectTextItems(
        payload.appearanceHashtags,
        payload.encounterSpotTitle,
      );
    case "love":
      return collectTextItems(
        payload.loveProfile,
        asRecord(payload.detailedAnalysis).loveStyle,
        asRecord(payload.detailedAnalysis).charmPoints,
        payload.predictions,
      );
    case "ex-lover":
      return collectTextItems(
        payload.karma_analysis,
        payload.future_outlook,
        payload.goalSpecific,
      );
    case "talent":
      return collectTextItems(
        payload.talentProfile,
        payload.strengthAreas,
        payload.growthOpportunities,
      );
    case "health":
      return collectTextItems(
        payload.element_balance,
        payload.weak_organs,
        payload.seasonal_advice,
      );
    case "wealth":
      return collectTextItems(
        payload.cashflowInsight,
        payload.concernResolution,
        payload.goalAdvice,
      );
    case "exercise":
      return collectTextItems(
        payload.recommendedExercise,
        payload.todayRoutine,
        payload.weaknesses,
      );
    case "tarot":
      return collectTextItems(payload.cardInterpretations, payload.storyTitle);
    case "wish":
      return collectTextItems(
        payload.empathy_message,
        payload.hope_message,
        asRecord(payload.fortune_flow).keywords,
        asRecord(payload.dragon_message).wisdom,
      );
    case "past-life":
      return collectTextItems(payload.story, payload.chapters);
    case "family":
      return collectTextItems(
        payload.relationshipCategories,
        payload.wealthCategories,
        payload.childAnalysis,
        payload.changeCategories,
        payload.healthCategories,
      );
    case "mbti":
      return collectTextItems(
        payload.todayFortune,
        payload.todayTrap,
        payload.cognitiveStrengths,
      );
    case "personality-dna":
      return collectTextItems(
        payload.todayHighlight,
        payload.traits,
        payload.funStats,
      );
    case "face-reading":
      return extractFaceReadingHighlights(payload);
    case "moving":
      return collectTextItems(
        payload.direction_analysis,
        payload.timing_analysis,
        payload.terrain_analysis,
        payload.settlement_index,
        payload.neighborhood_chemistry,
      );
    case "celebrity":
      return collectTextItems(payload.main_message, payload.strengths);
    case "pet-compatibility":
      return collectTextItems(
        asRecord(payload.today_story).opening,
        asRecord(payload.breed_specific).trait_today,
        payload.activity_recommendation,
      );
    case "match-insight":
      return collectTextItems(
        asRecord(payload.prediction).keyFactors,
        payload.favoriteTeamAnalysis,
        payload.opponentAnalysis,
      );
    case "decision":
      return collectTextItems(
        payload.confidenceFactors,
        payload.recommendation,
      );
    case "ootd-evaluation":
      return extractOotdHighlights(payload);
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
    case "daily":
      return collectReadableTextItems(
        extractDailyActionItems(payload.personalActions),
        payload.ai_tips,
        payload.advice,
      );
    case "daily-calendar":
      return collectTextItems(
        payload.timeStrategy,
        payload.calendarAdvice,
        payload.advice,
      );
    case "new-year":
      return collectTextItems(
        payload.recommendations,
        asRecord(payload.goalFortune).actionItems,
        payload.actionPlan,
      );
    case "exam":
      return collectTextItems(
        payload.csatFocus,
        payload.csatChecklist,
        payload.dday_advice,
      );
    case "naming":
      return collectTextItems(payload.namingTips, payload.recommendedNames);
    case "lucky-items":
      return collectTextItems(payload.fashion, payload.color);
    case "biorhythm":
      return collectTextItems(payload.greeting, payload.status_message);
    case "dream":
      return collectTextItems(
        payload.todayGuidance,
        payload.actionAdvice,
        payload.analysis,
      );
    case "talisman":
      return collectTextItems(
        payload.recommendations,
        payload.shortDescription,
        payload.advice,
      );
    case "wish":
      return collectTextItems(
        payload.advice,
        asRecord(payload.lucky_mission).item_reason,
        asRecord(payload.lucky_mission).place_reason,
        asRecord(payload.lucky_mission).color_reason,
        payload.encouragement,
      );
    case "family":
      return collectTextItems(
        payload.communicationAdvice,
        payload.parentingAdvice,
        payload.educationAdvice,
        payload.educationTips,
        payload.relationshipGuide,
        asRecord(payload.familyAdvice).tips,
        payload.recommendations,
      );
    case "love":
      return collectTextItems(
        payload.todaysAdvice,
        payload.actionPlan,
        asRecord(payload.recommendations).dateSpots,
        asRecord(payload.recommendations).conversation,
      );
    case "ex-lover":
      return collectTextItems(
        payload.emotional_healing,
        payload.action_tips,
        payload.advice,
      );
    case "health":
      return collectTextItems(
        payload.recommendations,
        payload.seasonal_advice,
        payload.advice,
      );
    case "wealth":
      return collectTextItems(
        payload.actionItems,
        payload.goalAdvice,
        payload.advice,
      );
    case "talent":
      return collectTextItems(
        payload.skillRecommendations,
        payload.roadmap,
        payload.advice,
      );
    case "personality-dna":
      return collectTextItems(
        payload.todayAdvice,
        asRecord(payload.dailyFortune).recommendedActivity,
      );
    case "face-reading":
      return extractFaceReadingRecommendations(payload);
    case "moving":
      return collectTextItems(
        payload.recommendations,
        asRecord(payload.lucky_dates).reason,
        asRecord(payload.timing_analysis).recommendation,
        payload.feng_shui_tips,
        payload.advice,
      );
    case "celebrity":
      return collectTextItems(payload.recommendations, payload.special_message);
    case "pet-compatibility":
      return collectTextItems(
        asRecord(payload.owner_bond).bonding_tip,
        asRecord(payload.bonding_mission).description,
        payload.special_tips,
      );
    case "match-insight":
      return collectTextItems(
        asRecord(payload.fortuneElements).luckyAction,
        asRecord(payload.fortuneElements).luckySection,
      );
    case "decision":
      return collectTextItems(payload.nextSteps, payload.recommendation);
    case "exercise":
      return collectTextItems(
        payload.todayRoutine,
        payload.weeklyPlan,
        payload.supplementary,
      );
    case "ootd-evaluation":
      return extractOotdRecommendations(payload);
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

function extractWarnings(fortuneType: FortuneTypeId, payload: UnknownRecord) {
  switch (fortuneType) {
    case "daily":
      return collectReadableTextItems(
        sanitizeDailyReadableText(readStringValue(payload.caution)),
        extractDailyLowestCategoryAdvice(payload),
      );
    case "daily-calendar":
      return collectTextItems(
        payload.cautionTimes,
        payload.cautionActivities,
        payload.cautionPeople,
      );
    case "avoid-people":
      return collectTextItems(
        payload.cautionTimes,
        payload.cautionActivities,
        payload.cautionColors,
        payload.cautionNumbers,
      );
    case "health":
      return collectTextItems(payload.weak_organs, payload.cautions);
    case "blind-date":
      return collectTextItems(payload.dontsList);
    case "yearly-encounter":
      return collectTextItems(
        payload.fateSignalWarnings,
        payload.fateSignalRisk,
        payload.fateSignalTitle,
        payload.fateSignalStory,
      );
    case "new-year":
      return collectTextItems(
        asRecord(payload.goalFortune).riskAnalysis,
        asRecord(payload.goalFortune).cautionMonths,
      );
    case "mbti":
      return collectTextItems(payload.todayTrap, payload.challenges);
    case "personality-dna":
      return collectTextItems(asRecord(payload.dailyFortune).caution);
    case "love":
      return collectTextItems(
        asRecord(payload.todaysAdvice).warningArea,
        asRecord(asRecord(payload.detailedAnalysis).improvementAreas).specific,
        asRecord(asRecord(payload.recommendations).fashion).avoidFashion,
        asRecord(asRecord(payload.recommendations).conversation).avoid,
      );
    case "wish":
      return collectTextItems(
        asRecord(payload.fortune_flow).obstacle,
        asRecord(payload.dragon_message).pearl_message,
      );
    case "family":
      return collectTextItems(
        payload.warnings,
        asRecord(payload.monthlyTrend).caution_period,
      );
    case "face-reading":
      return extractFaceReadingWarnings(payload);
    case "moving":
      return collectTextItems(payload.warnings, payload.cautions);
    case "wealth":
      return collectTextItems(payload.risks, payload.cautions);
    case "talent":
      return collectTextItems(payload.challenges);
    case "celebrity":
      return collectTextItems(payload.challenges);
    case "pet-compatibility":
      return collectTextItems(
        asRecord(payload.breed_specific).health_watch,
        payload.health_insight,
      );
    case "match-insight":
      return collectTextItems(
        payload.cautionMessage,
        asRecord(payload.favoriteTeamAnalysis).concerns,
        asRecord(payload.opponentAnalysis).concerns,
      );
    case "exercise":
      return collectTextItems(payload.weaknesses, payload.injuryPrevention);
    case "ootd-evaluation":
      return extractOotdWarnings(payload);
    default:
      return collectTextItems(
        payload.warnings,
        payload.cautions,
        payload.dontsList,
      );
  }
}

function extractLuckyItems(fortuneType: FortuneTypeId, payload: UnknownRecord) {
  switch (fortuneType) {
    case "daily":
      return collectReadableKeywordItems(
        asRecord(payload.lucky_items).time,
        asRecord(payload.lucky_items).color,
        asRecord(payload.lucky_items).number,
        asRecord(payload.lucky_items).direction,
        asRecord(payload.lucky_items).item,
        payload.lucky_numbers,
      );
    case "daily-calendar":
      return collectTextItems(
        asRecord(payload.luckyElements).colors,
        asRecord(payload.luckyElements).numbers,
        asRecord(payload.luckyElements).direction,
        asRecord(payload.luckyElements).items,
      );
    case "new-year":
      return collectTextItems(payload.luckyItems);
    case "lucky-items":
      return collectTextItems(payload.color, payload.fashion, payload.numbers);
    case "yearly-encounter":
      return collectTextItems(payload.encounterSpotTitle);
    case "love":
      return collectTextItems(
        asRecord(asRecord(payload.recommendations).fashion).colors,
        asRecord(asRecord(payload.recommendations).accessories).recommended,
        asRecord(asRecord(payload.recommendations).fragrance).notes,
      );
    case "family":
      return collectTextItems(payload.luckyElements, payload.lucky_elements);
    case "wish":
      return collectTextItems(
        asRecord(payload.lucky_mission).item,
        asRecord(payload.lucky_mission).place,
        asRecord(payload.lucky_mission).color,
        asRecord(payload.fortune_flow).keywords,
      );
    case "personality-dna":
      return collectTextItems(
        asRecord(payload.dailyFortune).luckyColor,
        asRecord(payload.dailyFortune).luckyNumber,
        asRecord(payload.dailyFortune).bestMatchToday,
      );
    case "face-reading":
      return extractFaceReadingLuckyItems(payload);
    case "ootd-evaluation":
      return extractOotdLuckyItems(payload);
    case "moving":
      return collectTextItems(
        asRecord(payload.lucky_items).items,
        asRecord(payload.lucky_items).colors,
        asRecord(payload.lucky_items).plants,
      );
    case "celebrity":
      return collectTextItems(payload.lucky_factors);
    case "pet-compatibility":
      return collectTextItems(payload.lucky_items);
    case "match-insight":
      return collectTextItems(
        asRecord(payload.fortuneElements).luckyColor,
        asRecord(payload.fortuneElements).luckyNumber,
        asRecord(payload.fortuneElements).luckyTime,
        asRecord(payload.fortuneElements).luckyItem,
      );
    case "wealth":
      return collectTextItems(payload.luckyElements, payload.lucky_items);
    case "talent":
      return collectTextItems(payload.luckyItems, payload.lucky_items);
    default:
      return collectTextItems(
        payload.luckyItems,
        payload.lucky_items,
        payload.color,
      );
  }
}

function extractSpecialTip(fortuneType: FortuneTypeId, payload: UnknownRecord) {
  switch (fortuneType) {
    case "daily":
      return firstDailyReadableText(payload.special_tip);
    case "daily-calendar":
      return firstText(
        payload.specialMessage,
        asRecord(asRecord(payload.timeStrategy).morning).advice,
        payload.special_tip,
      );
    case "new-year":
      return firstText(payload.specialMessage, payload.greeting);
    case "exam":
      return firstText(payload.statusMessage, payload.positive_message);
    case "yearly-encounter":
      return firstText(payload.encounterSpotStory);
    case "love":
      return firstText(
        asRecord(payload.todaysAdvice).general,
        asRecord(payload.todaysAdvice).luckyAction,
      );
    case "wish":
      return firstText(
        asRecord(payload.dragon_message).power_line,
        payload.special_words,
        payload.encouragement,
      );
    case "health":
      return firstText(payload.seasonal_advice, payload.advice);
    case "family":
      return firstText(payload.specialAnswer, payload.special_answer);
    case "decision":
      return firstText(payload.recommendation);
    case "face-reading":
      return extractFaceReadingSpecialTip(payload);
    case "personality-dna":
      return firstText(payload.todayAdvice, payload.todayHighlight);
    case "wealth":
      return firstText(payload.cashflowInsight, payload.concernResolution);
    case "talent":
      return firstText(payload.advice);
    case "exercise":
      return firstText(payload.supplementary, payload.optimalTime);
    case "moving":
      return firstText(payload.overall_fortune, payload.advice);
    case "celebrity":
      return firstText(payload.special_message, payload.main_message);
    case "pet-compatibility":
      return firstText(
        asRecord(payload.pets_voice).heartfelt_letter,
        payload.summary,
      );
    case "match-insight":
      return firstText(asRecord(payload.prediction).mvpCandidate);
    case "ootd-evaluation":
      return extractOotdSpecialTip(payload);
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
    .slice(0, 6);
}

function collectReadableTextItems(...values: unknown[]) {
  return values
    .flatMap((value) => toReadableTextItems(value))
    .map((item) => item.trim())
    .filter(Boolean)
    .slice(0, 6);
}

function collectReadableKeywordItems(...values: unknown[]) {
  return values
    .flatMap((value) => toReadableTextItems(value, { keyword: true }))
    .map((item) => item.trim())
    .filter(Boolean)
    .slice(0, 8);
}

function extractFaceReadingDetailSections(
  payload: UnknownRecord,
): EmbeddedResultDetailSection[] | undefined {
  const details = asRecord(payload.details);
  const sections = [
    createTextSection(
      "얼굴형과 첫인상",
      joinReadableParts([
        describeFaceReadingOverview(details),
        firstReadableText(payload.content),
        firstReadableText(details.overall_fortune),
      ]),
    ),
    createTextSection(
      "오관 핵심",
      summarizeNamedItems(details.simplifiedOgwan),
    ),
    createTextSection(
      "삼정 균형",
      joinReadableParts([
        firstReadableText(asRecord(details.samjeong_summary).description),
        firstReadableText(asRecord(details.samjeong_summary).balance)
          ? `균형: ${firstReadableText(asRecord(details.samjeong_summary).balance)}`
          : null,
      ]),
    ),
    createTextSection(
      "십이궁 흐름",
      summarizeNamedItems(details.simplifiedSibigung),
    ),
    createTextSection(
      "명궁과 미간",
      joinReadableParts([
        summarizePreviewInsight("명궁", details.myeonggung_preview),
        summarizePreviewInsight("미간", details.migan_preview),
      ]),
    ),
  ].filter(Boolean) as EmbeddedResultDetailSection[];

  return sections.length > 0 ? sections : undefined;
}

function extractOotdDetailSections(
  payload: UnknownRecord,
): EmbeddedResultDetailSection[] | undefined {
  const details = asRecord(payload.details);
  const categories = asRecord(details.categories);
  const sections = [
    createTextSection("TPO 해석", firstReadableText(details.tpoFeedback)),
    createTextSection(
      "셀럽 무드 참고",
      firstReadableText(asRecord(details.celebrityMatch).reason),
    ),
  ];
  const categorySections = [
    ["색 조합", categories.colorHarmony],
    ["실루엣", categories.silhouette],
    ["스타일 일관성", categories.styleConsistency],
    ["액세서리", categories.accessories],
    ["TPO 핏", categories.tpoFit],
    ["트렌드 감각", categories.trendScore],
  ] as const;

  const scoredSections = categorySections
    .map(([title, value]) => createScoredFeedbackSection(title, value))
    .filter(Boolean) as EmbeddedResultDetailSection[];

  const merged = [...sections, ...scoredSections].filter(
    Boolean,
  ) as EmbeddedResultDetailSection[];

  return merged.length > 0 ? merged : undefined;
}

function describeFaceReadingOverview(details: UnknownRecord) {
  const faceType = firstReadableText(details.face_type);
  const element = firstReadableText(details.face_type_element);

  if (faceType && element) {
    return `${faceType} 얼굴형, ${element} 기운으로 읽혔습니다.`;
  }

  if (faceType) {
    return `${faceType} 얼굴형으로 읽혔습니다.`;
  }

  return element ? `${element} 기운이 두드러집니다.` : null;
}

function summarizePreviewInsight(title: string, value: unknown) {
  const preview = asRecord(value);
  const summary = firstReadableText(
    preview.summary,
    preview.description,
    preview.content,
  );
  const score = readScore(preview.score);

  if (!summary) {
    return null;
  }

  return score == null
    ? `${title}: ${summary}`
    : `${title} ${score}점: ${summary}`;
}

function summarizeNamedItems(value: unknown, limit = 3) {
  if (!Array.isArray(value)) {
    return null;
  }

  const lines = value
    .map((entry) => {
      const record = asRecord(entry);
      const name = firstReadableText(
        record.name,
        record.title,
        record.part,
        record.palace,
      );
      const summary = firstReadableText(
        record.summary,
        record.description,
        record.feedback,
        record.reason,
      );

      if (!name && !summary) {
        return null;
      }

      if (!summary) {
        return name;
      }

      return name ? `${name}: ${summary}` : summary;
    })
    .filter(Boolean)
    .slice(0, limit) as string[];

  return lines.length > 0 ? lines.join("\n") : null;
}

function extractFaceReadingMetricTiles(
  payload: UnknownRecord,
): MetricTileData[] | undefined {
  const details = asRecord(payload.details);
  const breakdown = asRecord(payload.scoreBreakdown);

  return mergeMetricTiles(
    [
      toMetricTile("오관", breakdown.ogwan),
      toMetricTile("삼정", breakdown.samjeong),
      toMetricTile("십이궁", breakdown.sibigung),
      toMetricTile(
        "얼굴 컨디션",
        asRecord(details.faceCondition_preview).overallConditionScore,
      ),
    ].filter(Boolean) as MetricTileData[],
    [
      toMetricTile("얼굴형", details.face_type),
      toMetricTile("오행", details.face_type_element),
    ].filter(Boolean) as MetricTileData[],
  );
}

function extractOotdMetricTiles(
  payload: UnknownRecord,
): MetricTileData[] | undefined {
  const details = asRecord(payload.details);
  const categories = asRecord(details.categories);

  return mergeMetricTiles(
    [
      toMetricTile("전체 등급", details.overallGrade),
      toMetricTile("TPO 점수", details.tpoScore),
      toScoredMetricTile("색 조합", categories.colorHarmony),
      toScoredMetricTile("실루엣", categories.silhouette),
    ].filter(Boolean) as MetricTileData[],
    undefined,
  );
}

function extractFaceReadingHighlights(payload: UnknownRecord) {
  const details = asRecord(payload.details);
  return collectReadableTextItems(
    extractFaceReadingPriorityInsights(details.priorityInsights),
    firstReadableText(asRecord(details.faceCondition_preview).conditionMessage),
    firstReadableText(asRecord(details.emotionAnalysis_preview).emotionMessage),
    summarizeSimilarCelebrities(details.similar_celebrities),
  );
}

function extractOotdHighlights(payload: UnknownRecord) {
  const details = asRecord(payload.details);
  return collectReadableTextItems(
    details.highlights,
    details.styleKeywords,
    firstReadableText(asRecord(details.celebrityMatch).reason),
  );
}

function extractFaceReadingRecommendations(payload: UnknownRecord) {
  const details = asRecord(payload.details);
  return collectReadableTextItems(
    payload.advice,
    asRecord(details.improvements).daily,
    asRecord(details.improvements).appearance,
    firstReadableText(asRecord(details.watchData).dailyReminderMessage),
    firstReadableText(
      asRecord(details.makeupStyleRecommendations).recommendedStyle,
    ),
    firstReadableText(
      asRecord(details.makeupStyleRecommendations).hairStyleTip,
    ),
    firstReadableText(
      asRecord(details.leadershipAnalysis).teamRoleRecommendation,
    ),
    firstReadableText(asRecord(details.leadershipAnalysis).careerAdvice),
  );
}

function extractOotdRecommendations(payload: UnknownRecord) {
  const details = asRecord(payload.details);
  return collectReadableTextItems(
    details.softSuggestions,
    formatRecommendedItems(details.recommendedItems),
  );
}

function extractFaceReadingWarnings(payload: UnknownRecord) {
  const details = asRecord(payload.details);
  return collectReadableTextItems(
    firstReadableText(asRecord(details.faceCondition_preview).conditionMessage),
    firstReadableText(asRecord(details.emotionAnalysis_preview).emotionMessage),
    asRecord(details.personality).growthAreas,
    asRecord(details.myeonggung).weaknesses,
    asRecord(details.migan).weaknesses,
  );
}

function extractOotdWarnings(payload: UnknownRecord) {
  const details = asRecord(payload.details);
  const lowScoreFeedback = summarizeLowScoreFeedback(details.categories);

  return collectReadableTextItems(lowScoreFeedback);
}

function extractFaceReadingLuckyItems(payload: UnknownRecord) {
  const details = asRecord(payload.details);
  const watchData = asRecord(asRecord(payload.details).watchData);
  return collectReadableKeywordItems(
    watchData.luckyColor,
    watchData.luckyDirection,
    watchData.luckyTimePeriods,
    asRecord(details.improvements).luckyColors,
    asRecord(details.improvements).luckyDirections,
  );
}

function extractOotdLuckyItems(payload: UnknownRecord) {
  const details = asRecord(payload.details);
  return collectReadableKeywordItems(
    details.styleKeywords,
    extractRecommendedItemNames(details.recommendedItems),
  );
}

function extractFaceReadingSpecialTip(payload: UnknownRecord) {
  const details = asRecord(payload.details);
  return firstText(
    asRecord(details.watchData).dailyReminderMessage,
    details.overall_fortune,
    payload.advice,
  );
}

function extractOotdSpecialTip(payload: UnknownRecord) {
  const details = asRecord(payload.details);
  return firstText(payload.advice, details.tpoFeedback, details.overallComment);
}

function extractFaceReadingPriorityInsights(value: unknown) {
  if (!Array.isArray(value)) {
    return [];
  }

  return value
    .map((entry) => {
      const record = asRecord(entry);
      const title = firstReadableText(record.title);
      const description = firstReadableText(record.description);
      if (!title && !description) {
        return null;
      }
      return [title, description].filter(Boolean).join(": ");
    })
    .filter(Boolean) as string[];
}

function summarizeSimilarCelebrities(value: unknown) {
  if (!Array.isArray(value)) {
    return null;
  }

  const names = value
    .map((entry) => firstReadableText(asRecord(entry).name))
    .filter(Boolean)
    .slice(0, 3) as string[];

  return names.length > 0 ? `닮은 분위기: ${names.join(", ")}` : null;
}

function extractRecommendedItemNames(value: unknown) {
  if (!Array.isArray(value)) {
    return [];
  }

  return value
    .map((entry) => firstReadableText(asRecord(entry).item))
    .filter(Boolean) as string[];
}

function formatRecommendedItems(value: unknown) {
  if (!Array.isArray(value)) {
    return [];
  }

  return value
    .map((entry) => {
      const record = asRecord(entry);
      const category = firstReadableText(record.category);
      const item = firstReadableText(record.item);
      const reason = firstReadableText(record.reason);
      const label = [category, item].filter(Boolean).join(" · ");

      if (!label && !reason) {
        return null;
      }

      return reason ? `${label}: ${reason}` : label;
    })
    .filter(Boolean) as string[];
}

function summarizeLowScoreFeedback(value: unknown) {
  const categories = asRecord(value);
  const entries = [
    ["색 조합", categories.colorHarmony],
    ["실루엣", categories.silhouette],
    ["스타일 일관성", categories.styleConsistency],
    ["액세서리", categories.accessories],
    ["TPO 핏", categories.tpoFit],
    ["트렌드 감각", categories.trendScore],
  ] as const;

  const candidates: Array<{ label: string; score: number; feedback: string }> =
    [];

  for (const [label, entry] of entries) {
    const record = asRecord(entry);
    const score = readScore(record.score);
    const feedback = firstReadableText(record.feedback);
    if (score == null || !feedback) {
      continue;
    }

    candidates.push({ label, score, feedback });
  }

  const lowest = candidates.sort((left, right) => left.score - right.score)[0];

  return lowest
    ? `${lowest.label} 보완 포인트 ${lowest.score}점: ${lowest.feedback}`
    : null;
}

function createTextSection(
  title: string,
  body: string | null,
  score?: number,
): EmbeddedResultDetailSection | null {
  if (!body) {
    return null;
  }

  return {
    title,
    body,
    score,
  };
}

function createScoredFeedbackSection(
  title: string,
  value: unknown,
): EmbeddedResultDetailSection | null {
  const record = asRecord(value);
  const feedback = firstReadableText(record.feedback, record.description);
  const score = readScore(record.score) ?? undefined;

  if (!feedback) {
    return null;
  }

  return {
    title,
    body: feedback,
    score,
  };
}

function joinReadableParts(
  parts: Array<string | null | undefined>,
  separator = "\n",
) {
  const lines = parts.map((part) => part?.trim()).filter(Boolean) as string[];
  return lines.length > 0 ? lines.join(separator) : null;
}

function toTextItems(value: unknown): string[] {
  if (value == null) {
    return [];
  }

  if (typeof value === "string") {
    return value.trim() ? [trimParagraph(value, 420)] : [];
  }

  if (typeof value === "number" || typeof value === "boolean") {
    return [String(value)];
  }

  if (Array.isArray(value)) {
    return value.flatMap((item) => toTextItems(item));
  }

  const record = asRecord(value);

  if (record.title || record.content || record.description || record.text) {
    return [
      [
        firstText(record.title),
        firstText(record.content, record.description, record.text),
      ]
        .filter(Boolean)
        .join(": "),
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

  if (typeof value === "string") {
    const cleaned = options.keyword
      ? sanitizeKeywordText(value)
      : sanitizeReadableText(value);
    return cleaned ? [cleaned] : [];
  }

  if (typeof value === "number" || typeof value === "boolean") {
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
    return [[title, body].filter(Boolean).join(": ")].filter(
      Boolean,
    ) as string[];
  }

  return Object.values(record).flatMap((item) =>
    toReadableTextItems(item, options),
  );
}

function mapRecordToMetricTiles(
  record: UnknownRecord,
): MetricTileData[] | undefined {
  const entries = Object.entries(record)
    .map(([key, value]) => toMetricTile(formatMetricLabel(key), value))
    .filter(Boolean) as MetricTileData[];

  return entries.length > 0 ? entries.slice(0, 4) : undefined;
}

function toScoredMetricTile(
  label: string,
  value: unknown,
): MetricTileData | null {
  const record = asRecord(value);
  const score = readScore(record.score);
  const feedback = firstReadableText(record.feedback, record.description);

  if (score == null) {
    return null;
  }

  return {
    label,
    value: `${score}%`,
    note: feedback ? trimParagraph(feedback, 120) : undefined,
  };
}

function toMetricTile(label: string, value: unknown): MetricTileData | null {
  if (typeof value === "number" && Number.isFinite(value)) {
    return {
      label,
      value:
        value > 0 && value <= 100
          ? `${Math.trunc(value)}%`
          : String(Math.trunc(value)),
    };
  }

  if (typeof value === "string" && value.trim()) {
    return {
      label,
      value: trimValue(value.trim(), 56),
    };
  }

  return null;
}

function formatMetricLabel(key: string) {
  return key
    .replace(/_/g, " ")
    .replace(/\b\w/g, (char) => char.toUpperCase())
    .replace(/\bTpo\b/g, "TPO");
}

function trimParagraph(value: string, limit: number) {
  const normalized = value.replace(/\s+/g, " ").trim();

  if (normalized.length <= limit) {
    return normalized;
  }

  const window = normalized.slice(0, limit + 24);
  const breakpoints = [
    window.lastIndexOf(". "),
    window.lastIndexOf("! "),
    window.lastIndexOf("? "),
    window.lastIndexOf("。"),
    window.lastIndexOf(" "),
  ];
  const breakpoint = breakpoints.find(
    (index) => index >= Math.floor(limit * 0.7),
  );
  const cutIndex = breakpoint && breakpoint > 0 ? breakpoint : limit;

  return `${window.slice(0, cutIndex).trim()}…`;
}

function firstText(...values: unknown[]) {
  for (const value of values) {
    if (typeof value === "string" && value.trim()) {
      return trimParagraph(sanitizeReadableText(value), 420);
    }
  }

  return null;
}

function firstReadableText(...values: unknown[]) {
  for (const value of values) {
    if (typeof value === "string" && value.trim()) {
      return sanitizeReadableText(value);
    }
  }

  return null;
}

function firstDailyReadableText(...values: unknown[]) {
  for (const value of values) {
    if (typeof value === "string" && value.trim()) {
      return sanitizeDailyReadableText(value);
    }
  }

  return null;
}

function sanitizeReadableText(value: string) {
  const withoutMarkdown = value
    .replace(/\*\*(.*?)\*\*/gu, "$1")
    .replace(/__(.*?)__/gu, "$1")
    .replace(/`([^`]+)`/gu, "$1")
    .replace(/\[([^\]]+)\]\(([^)]+)\)/gu, "$1")
    .replace(/^\s{0,3}#{1,6}\s+/gmu, "")
    .replace(/^\s*>\s?/gmu, "")
    .replace(/^\s*\d+[.)]\s+/gmu, "")
    .replace(/^\s*[-*•]+\s+/gmu, "")
    .replace(/\r\n/gu, "\n");

  const withoutEmoji = withoutMarkdown.replace(
    /[\u{1F600}-\u{1F64F}]|[\u{1F300}-\u{1F5FF}]|[\u{1F680}-\u{1F6FF}]|[\u{1F1E0}-\u{1F1FF}]|[\u{2600}-\u{26FF}]|[\u{2700}-\u{27BF}]|[\u{1F900}-\u{1F9FF}]|[\u{1FA00}-\u{1FAFF}]|[\u{2B50}]|[\u{2B55}]/gu,
    "",
  );

  return withoutEmoji
    .replace(/[ \t]+\n/gu, "\n")
    .replace(/\n{3,}/gu, "\n\n")
    .replace(/[ \t]{2,}/gu, " ")
    .trim();
}

function sanitizeDailyReadableText(value: string | null | undefined) {
  if (!value) {
    return "";
  }

  const sanitized = sanitizeReadableText(value)
    .replace(/\b오늘의 바이브\b/gu, "종합 흐름")
    .replace(/\b애정운 바이브\b/gu, "애정 흐름")
    .replace(/\b금전운 바이브\b/gu, "금전 흐름")
    .replace(/\b직장운 바이브\b/gu, "직장 흐름")
    .replace(/\b학업운 바이브\b/gu, "학업 흐름")
    .replace(/\b건강운 바이브\b/gu, "건강 흐름")
    .replace(/\b갓생 치트키\b/gu, "실천 팁")
    .replace(/\b오늘의 한마디\b/gu, "마무리 한마디")
    .replace(/\b럭키비키\b/gu, "운이 좋은 흐름")
    .replace(/\b갓생\b/gu, "하루")
    .replace(/\b레전드 of 레전드\b/gu, "매우 좋은")
    .replace(/\b레전드\b/gu, "좋은")
    .replace(/\b무지성\b/gu, "망설임 없이")
    .replace(/\b찐으로\b/gu, "정말")
    .replace(/\b심쿵\b/gu, "설렘")
    .replace(/\b순삭\b/gu, "빠르게")
    .replace(/\b칼퇴\b/gu, "일정 마무리")
    .replace(/\bMAX\b/gu, "높은")
    .replace(/\bUP\b/gu, "상승")
    .replace(/완전 핫한데요\??/gu, "분위기가 좋은 편입니다.")
    .replace(/무지성으로 질러봐요/gu, "가볍게 먼저 말을 건네보세요")
    .replace(/탕후루처럼 달콤한/gu, "부드러운")
    .replace(/탕후루/gu, "")
    .replace(/힙한/gu, "새로운")
    .replace(/럭키 찬스/gu, "기회")
    .replace(/뿜뿜/gu, "살아나는")
    .replace(/갓성비/gu, "효율")
    .replace(
      /칭찬은 고래도 춤추게 한다잖아요\??/gu,
      "칭찬 한마디가 분위기를 부드럽게 만듭니다.",
    )
    .replace(/레전드 찍을 각/gu, "좋은 흐름을 기대해볼 만합니다")
    .replace(/기대해도 됨!?/gu, "기대해볼 만합니다.")
    .replace(/기대해도 좋아!?/gu, "기대해볼 만합니다.")
    .replace(/잘 될 거임!?/gu, "잘 풀릴 가능성이 있습니다.")
    .replace(/NewJeans처럼/gu, "")
    .replace(/[“”"]/gu, "")
    .replace(/\(\s*진심\s*\)/gu, "")
    .replace(/[!]{2,}/gu, "!")
    .replace(/[?]{2,}/gu, "?");

  return sanitized
    .replace(/[ \t]+\n/gu, "\n")
    .replace(/\n{3,}/gu, "\n\n")
    .trim();
}

function sanitizeKeywordText(value: string) {
  return sanitizeReadableText(value).replace(/\n+/gu, " ");
}

function readStringValue(value: unknown) {
  return typeof value === "string" ? value : null;
}

function asRecord(value: unknown): UnknownRecord {
  if (typeof value === "object" && value !== null && !Array.isArray(value)) {
    return value as UnknownRecord;
  }

  return {};
}
