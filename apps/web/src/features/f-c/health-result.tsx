/**
 * 건강운 결과 + 설문 옵션 정의.
 *
 * 필드 이름은 `supabase/functions/fortune-health/index.ts` 의 응답 조립부
 * (index.ts:873~920) 에서 그대로 가져왔다. 봉투는 항상 `{ success, data }`.
 *
 * 이 운세만의 두 가지 특수 사정:
 *
 * 1. **본문에 `\n\n` 문단이 들어 있다.** 프롬프트가 이모지 머리말 + 줄바꿈
 *    형식을 강제한다 (index.ts:625~). `<p>` 는 개행을 접으므로 `splitLines`
 *    로 쪼개 문단 배열로 넘긴다.
 * 2. **의료 면책 고지가 필수다.** 서버가 모든 응답에 `disclaimer` 를 붙이지만
 *    (index.ts:919) 코호트 풀 응답처럼 빠질 수 있는 경로가 있어, 같은 문구를
 *    상수로 두고 항상 노출한다.
 */

import {
  BulletList,
  CardList,
  Disclaimer,
  KeyValueGrid,
  ScoreHeadline,
  TextSection,
  type KeyValuePair,
} from '@/features/fortune/result';

import type { ChipOption } from '@/features/fortune/fields';

import { asArray, joinParts, percentileNote, splitLines } from './shared';

/* ------------------------------- 설문 옵션 ------------------------------- */

/**
 * `current_condition` 은 서버가 프롬프트에 그대로 넣는 자유 문자열이고
 * (index.ts:591) 비면 400 이다 (index.ts:398). 그래서 값 자체가 한국어다.
 */
export const HEALTH_CONDITION_OPTIONS: ReadonlyArray<ChipOption> = [
  { value: '컨디션이 좋아요', label: '좋아요' },
  { value: '보통이에요', label: '보통이에요' },
  { value: '자주 피곤해요', label: '자주 피곤해요' },
  { value: '기운이 없어요', label: '기운이 없어요' },
  { value: '불편한 곳이 있어요', label: '불편한 곳이 있어요' },
];

/** `concerned_body_parts` 는 쉼표로 이어져 프롬프트에 들어간다 (index.ts:592). */
export const HEALTH_BODY_PART_OPTIONS: ReadonlyArray<ChipOption> = [
  { value: '머리', label: '머리' },
  { value: '목·어깨', label: '목·어깨' },
  { value: '허리', label: '허리' },
  { value: '소화기', label: '소화기' },
  { value: '눈', label: '눈' },
  { value: '피부', label: '피부' },
  { value: '관절', label: '관절' },
  { value: '호흡기', label: '호흡기' },
];

/**
 * 1~5 척도. 서버가 이 네 값으로 점수를 계산하고 (index.ts:849~853)
 * 라벨 맵으로 프롬프트 문구를 만든다 (index.ts:299~341). 값은 숫자라
 * 폼에서 문자열로 다루다 제출 시 Number 로 바꾼다.
 */
export const HEALTH_SLEEP_OPTIONS: ReadonlyArray<ChipOption> = [
  { value: '1', label: '매우 나쁨' },
  { value: '2', label: '나쁨' },
  { value: '3', label: '보통' },
  { value: '4', label: '좋음' },
  { value: '5', label: '매우 좋음' },
];

export const HEALTH_EXERCISE_OPTIONS: ReadonlyArray<ChipOption> = [
  { value: '1', label: '거의 안 함' },
  { value: '2', label: '주 1회 이하' },
  { value: '3', label: '주 2~3회' },
  { value: '4', label: '주 4~5회' },
  { value: '5', label: '매일' },
];

export const HEALTH_STRESS_OPTIONS: ReadonlyArray<ChipOption> = [
  { value: '1', label: '거의 없음' },
  { value: '2', label: '조금' },
  { value: '3', label: '보통' },
  { value: '4', label: '많음' },
  { value: '5', label: '매우 많음' },
];

export const HEALTH_MEAL_OPTIONS: ReadonlyArray<ChipOption> = [
  { value: '1', label: '매우 불규칙' },
  { value: '2', label: '불규칙' },
  { value: '3', label: '보통' },
  { value: '4', label: '규칙적' },
  { value: '5', label: '매우 규칙적' },
];

/** index.ts:919 의 문구와 동일하게 유지할 것. */
export const HEALTH_MEDICAL_DISCLAIMER =
  '본 건강 조언은 참고·오락 목적으로 제공됩니다. 의학적 진단·치료·예측이 아니며, 증상이 지속되거나 우려가 있다면 반드시 의료 전문가와 상담하세요.';

/* --------------------------------- 타입 --------------------------------- */

export interface HealthElementFood {
  item?: string;
  reason?: string;
  timing?: string;
}

export interface HealthExerciseSlot {
  time?: string;
  title?: string;
  description?: string;
  duration?: string;
  intensity?: string;
  tip?: string;
}

export interface HealthExerciseWeekly {
  summary?: string;
  schedule?: Record<string, string | undefined>;
}

export interface HealthExerciseAdvice {
  morning?: HealthExerciseSlot;
  afternoon?: HealthExerciseSlot;
  weekly?: HealthExerciseWeekly;
  overall_tip?: string;
}

export interface HealthElementAdvice {
  lacking_element?: string;
  dominant_element?: string;
  vulnerable_organs?: string[];
  vulnerable_symptoms?: string[];
  /** LLM 경로는 객체 배열, 코호트 경로는 문자열 배열 (index.ts:463 vs 869). */
  recommended_foods?: Array<HealthElementFood | string>;
}

export interface HealthPersonalizedFeedback {
  improvements?: string[];
  concerns?: string[];
  encouragements?: string[];
}

export interface HealthFortune {
  score?: number;
  content?: string;
  summary?: string;
  advice?: string;
  overall_health?: string;
  body_part_advice?: string;
  cautions?: string[];
  recommended_activities?: string[];
  diet_advice?: string;
  /** 객체가 정상이지만 문자열로 오는 경우도 서버가 허용한다 (index.ts:861). */
  exercise_advice?: HealthExerciseAdvice | string;
  health_keyword?: string;
  element_advice?: HealthElementAdvice | null;
  personalized_feedback?: HealthPersonalizedFeedback;
  disclaimer?: string;
  percentile?: number | null;
}

/* -------------------------------- 렌더 -------------------------------- */

const WEEKDAY_LABELS: ReadonlyArray<readonly [string, string]> = [
  ['mon', '월'],
  ['tue', '화'],
  ['wed', '수'],
  ['thu', '목'],
  ['fri', '금'],
  ['sat', '토'],
  ['sun', '일'],
];

/** 첫 줄을 제목으로, 나머지를 본문으로. `\n\n` 로 나뉜 항목 배열용. */
function blockItems(values: unknown): Array<{ title?: string; description?: string }> {
  return asArray<unknown>(values).map((value) => {
    const lines = splitLines(value);
    return { title: lines[0], description: lines.slice(1).join(' ') };
  });
}

/** 슬롯이 통째로 없으면 빈 항목 — 제목만 남은 껍데기 카드가 생기지 않게 한다. */
function exerciseSlotItem(slot: HealthExerciseSlot | undefined, fallbackTitle: string) {
  if (slot === null || typeof slot !== 'object') {
    return { title: undefined, description: undefined };
  }
  return {
    title: joinParts([slot.time, slot.title ?? fallbackTitle, slot.duration]),
    description: joinParts([slot.description, slot.intensity, slot.tip], ' '),
  };
}

export function HealthResult({ fortune, cached }: { fortune: HealthFortune; cached: boolean }) {
  const element = fortune.element_advice ?? undefined;
  const feedback = fortune.personalized_feedback;

  const exercise =
    typeof fortune.exercise_advice === 'object' && fortune.exercise_advice !== null
      ? fortune.exercise_advice
      : undefined;
  const exerciseText =
    typeof fortune.exercise_advice === 'string' ? fortune.exercise_advice : undefined;

  const schedule = exercise?.weekly?.schedule;
  const schedulePairs: KeyValuePair[] = WEEKDAY_LABELS.map(([key, label]) => ({
    label,
    value: schedule !== null && typeof schedule === 'object' ? schedule[key] : undefined,
  }));

  const elementPairs: KeyValuePair[] = [
    { label: '부족한 기운', value: element?.lacking_element },
    { label: '강한 기운', value: element?.dominant_element },
  ];

  const foodItems = asArray<HealthElementFood | string>(element?.recommended_foods).map((food) =>
    typeof food === 'string'
      ? { title: food, description: undefined }
      : { title: food?.item, description: joinParts([food?.reason, food?.timing]) },
  );

  // 이 함수에는 한 줄 요약 필드가 없다 — `summary` 는 건강 키워드고
  // (index.ts:878) `overall_health` 는 이모지 머리말이 붙은 여러 문단이다.
  // 그래서 헤드라인엔 키워드를 두고 본문은 통째로 아래 카드에 넘긴다.
  const overallLines = splitLines(fortune.overall_health ?? fortune.content);

  const checkpoints = [
    ...asArray<string>(feedback?.improvements),
    ...asArray<string>(feedback?.concerns),
    ...asArray<string>(feedback?.encouragements),
  ];

  return (
    <section aria-label="건강운 결과" className="ondo-stack">
      <ScoreHeadline
        kicker={`건강운${cached ? ' · 저장된 결과' : ''}`}
        note={percentileNote(fortune.percentile)}
        score={fortune.score}
        summary={fortune.health_keyword ?? fortune.summary}
      />

      <TextSection label="전반 분석" text={overallLines} />

      <TextSection label="부위별 조언" text={splitLines(fortune.body_part_advice)} />

      <CardList items={blockItems(fortune.cautions)} label="주의사항" />

      <CardList items={blockItems(fortune.recommended_activities)} label="추천 활동" />

      <TextSection label="식습관" text={splitLines(fortune.diet_advice)} />

      <CardList
        items={[
          exerciseSlotItem(exercise?.morning, '아침 운동'),
          exerciseSlotItem(exercise?.afternoon, '오후 운동'),
        ]}
        label="운동 루틴"
      />

      <KeyValueGrid label="주간 운동 스케줄" pairs={schedulePairs} />

      <TextSection
        label="운동 조언"
        text={[exercise?.weekly?.summary, exercise?.overall_tip ?? fortune.advice, exerciseText]}
      />

      <KeyValueGrid label="오행" pairs={elementPairs} />

      <BulletList items={asArray<string>(element?.vulnerable_organs)} label="살펴볼 부위" />

      <BulletList items={asArray<string>(element?.vulnerable_symptoms)} label="나타나기 쉬운 신호" />

      <CardList items={foodItems} label="추천 음식" />

      <BulletList items={checkpoints} label="체크 포인트" />

      <TextSection label="건강 안내" text={fortune.disclaimer ?? HEALTH_MEDICAL_DISCLAIMER} />

      <Disclaimer />
    </section>
  );
}
