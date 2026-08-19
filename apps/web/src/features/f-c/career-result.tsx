/**
 * 직업운 결과 + 설문 옵션 정의.
 *
 * 필드 이름은 `supabase/functions/fortune-career/index.ts` 의 응답 조립부
 * (index.ts:822~845) 에서 그대로 가져왔다. 봉투는 항상 `{ success, data }`.
 * 선언은 전부 optional — LLM JSON 을 검증 없이 실어 나르기 때문이다.
 *
 * 주의: `skillAnalysis` 는 요청에 `skills` 를 실을 때만 채워지는데, 그 안의
 * currentLevel/targetLevel 은 서버가 `Math.random()` 으로 만든다
 * (index.ts:456~457). 그래서 웹 폼은 `skills` 를 보내지 않고, 이 화면은
 * 값이 있을 때만(=코호트 풀 응답) 그린다.
 */

import {
  BulletList,
  CardList,
  Disclaimer,
  ScoreHeadline,
  TextSection,
} from '@/features/fortune/result';

import type { ChipOption } from '@/features/fortune/fields';

import { asArray, joinParts, percentileNote } from './shared';

/* ------------------------------- 설문 옵션 ------------------------------- */

/** `timeHorizonWeights` 의 키 (index.ts:175). 다른 문자열은 3년 후로 접힌다. */
export const CAREER_TIME_HORIZON_OPTIONS: ReadonlyArray<ChipOption> = [
  { value: '1년 후', label: '1년 후' },
  { value: '3년 후', label: '3년 후' },
  { value: '5년 후', label: '5년 후' },
  { value: '10년 후', label: '10년 후' },
];

/** `getConcernLabel` 의 키 (index.ts:256). 고민별 프롬프트 섹션이 붙는다. */
export const CAREER_CONCERN_OPTIONS: ReadonlyArray<ChipOption> = [
  { value: '', label: '선택 안 함' },
  { value: 'growth', label: '성장 정체' },
  { value: 'direction', label: '방향성 고민' },
  { value: 'transition', label: '이직/전직' },
  { value: 'balance', label: '워라벨' },
  { value: 'compensation', label: '보상' },
  { value: 'relationship', label: '직장 내 인간관계' },
];

/**
 * `careerPath` 는 서버가 그대로 프롬프트에 넣는 자유 문자열이다 (index.ts:722).
 * 서버 기본값 '전문가 (기술 심화)' 는 IT 색이 강해 비IT 직군에 어색하므로
 * 웹은 직군 중립적인 문구를 쓴다.
 */
export const CAREER_PATH_OPTIONS: ReadonlyArray<ChipOption> = [
  { value: '전문가 (전문성 심화)', label: '전문가' },
  { value: '관리자 (리더십)', label: '관리자' },
  { value: '창업 · 독립', label: '창업/독립' },
];

/* --------------------------------- 타입 --------------------------------- */

export interface CareerPrediction {
  timeframe?: string;
  probability?: number;
  keyMilestones?: string[];
  requiredActions?: string[];
  potentialChallenges?: string[];
  successFactors?: string[];
}

export interface CareerSkillAnalysis {
  skill?: string;
  currentLevel?: number;
  targetLevel?: number;
  developmentPlan?: string;
  timeToMaster?: string;
}

export interface CareerActionPlan {
  immediate?: string[];
  shortTerm?: string[];
  longTerm?: string[];
}

export interface CareerFortune {
  score?: number;
  content?: string;
  summary?: string;
  advice?: string;
  currentRole?: string;
  timeHorizon?: string;
  careerPath?: string;
  /** 코호트 풀 응답에만 있다 (index.ts:637). */
  careerField?: string;
  predictions?: CareerPrediction[];
  skillAnalysis?: CareerSkillAnalysis[];
  strengthsAssessment?: string[];
  improvementAreas?: string[];
  actionPlan?: CareerActionPlan;
  industryInsights?: string;
  networkingAdvice?: string[];
  luckyPeriods?: string[];
  cautionPeriods?: string[];
  careerKeywords?: string[];
  mentorshipAdvice?: string;
  percentile?: number | null;
}

/* -------------------------------- 렌더 -------------------------------- */

export function CareerResult({ fortune, cached }: { fortune: CareerFortune; cached: boolean }) {
  const prediction: CareerPrediction | undefined = asArray<CareerPrediction>(
    fortune.predictions,
  )[0];
  const plan = fortune.actionPlan;

  const keywords = asArray<string>(fortune.careerKeywords)
    .filter((keyword): keyword is string => typeof keyword === 'string')
    .join(' · ');

  return (
    <section aria-label="직업운 결과" className="ondo-stack">
      <ScoreHeadline
        kicker={
          joinParts(['직업운', fortune.timeHorizon, cached ? '저장된 결과' : undefined]) ?? '직업운'
        }
        note={joinParts([fortune.careerField, percentileNote(fortune.percentile)])}
        score={fortune.score}
        summary={fortune.content}
      />

      <TextSection label="업계 인사이트" text={fortune.industryInsights} />

      <BulletList items={asArray<string>(fortune.strengthsAssessment)} label="강점" />

      <BulletList items={asArray<string>(fortune.improvementAreas)} label="보완할 점" />

      <BulletList
        items={asArray<string>(prediction?.keyMilestones)}
        label={joinParts([prediction?.timeframe, '핵심 마일스톤']) ?? '핵심 마일스톤'}
      />

      <BulletList items={asArray<string>(prediction?.potentialChallenges)} label="예상 과제" />

      <BulletList items={asArray<string>(prediction?.successFactors)} label="성공 요인" />

      <BulletList items={asArray<string>(plan?.immediate)} label="지금 바로" />

      <BulletList items={asArray<string>(plan?.shortTerm)} label="단기 목표" />

      <BulletList items={asArray<string>(plan?.longTerm)} label="장기 목표" />

      <BulletList items={asArray<string>(prediction?.requiredActions)} label="필요한 행동" />

      <BulletList items={asArray<string>(fortune.luckyPeriods)} label="행운의 시기" />

      <BulletList items={asArray<string>(fortune.cautionPeriods)} label="주의 시기" />

      <BulletList items={asArray<string>(fortune.networkingAdvice)} label="네트워킹" />

      <CardList
        items={asArray<CareerSkillAnalysis>(fortune.skillAnalysis).map((entry) => ({
          title: joinParts([entry?.skill, entry?.timeToMaster]),
          description: entry?.developmentPlan,
        }))}
        label="역량 개발"
      />

      <TextSection label="멘토링 조언" text={fortune.mentorshipAdvice ?? fortune.advice} />

      <TextSection label="핵심 키워드" text={keywords} />

      <Disclaimer />
    </section>
  );
}
