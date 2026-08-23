/**
 * 재물운 결과 + 설문 옵션 정의.
 *
 * 필드 이름은 전부 `supabase/functions/fortune-wealth/index.ts` 에서 그대로
 * 가져왔다 (응답 조립부 index.ts:539~599). 선언은 모두 optional 이다 —
 * 서버가 LLM JSON 을 검증 없이 그대로 실어 나르기 때문에 어떤 필드든 빌 수 있다.
 *
 * 설문 옵션(GOAL/CONCERN/...)도 여기 둔다. Edge Function 의 라벨 맵
 * (index.ts:84~133) 이 곧 계약이라 id 를 하나라도 다르게 보내면 프롬프트에
 * 원문 id 가 그대로 박히고, 그 라벨을 결과 화면에서도 다시 써야 해서
 * 폼/결과가 같은 상수를 봐야 한다. import 방향은 form → result 한 방향.
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

import { asArray, joinParts, labeledValue, percentileNote } from './shared';

/* ------------------------------- 설문 옵션 ------------------------------- */

/** `GOAL_LABELS` (fortune-wealth/index.ts:84). */
export const WEALTH_GOAL_OPTIONS: ReadonlyArray<ChipOption> = [
  { value: 'saving', label: '목돈 마련' },
  { value: 'house', label: '내집 마련' },
  { value: 'expense', label: '큰 지출 예정' },
  { value: 'investment', label: '투자 수익' },
  { value: 'income', label: '안정적 수입' },
];

/** `CONCERN_LABELS` (index.ts:92). */
export const WEALTH_CONCERN_OPTIONS: ReadonlyArray<ChipOption> = [
  { value: 'spending', label: '지출 관리' },
  { value: 'loss', label: '투자 손실' },
  { value: 'debt', label: '빚/대출' },
  { value: 'returns', label: '수익률' },
  { value: 'savings', label: '저축' },
];

/** `INCOME_LABELS` (index.ts:100). */
export const WEALTH_INCOME_OPTIONS: ReadonlyArray<ChipOption> = [
  { value: 'increasing', label: '늘어나는 중' },
  { value: 'stable', label: '안정적' },
  { value: 'decreasing', label: '줄어드는 중' },
  { value: 'irregular', label: '불규칙' },
];

/** `EXPENSE_LABELS` (index.ts:107). */
export const WEALTH_EXPENSE_OPTIONS: ReadonlyArray<ChipOption> = [
  { value: 'frugal', label: '절약형' },
  { value: 'balanced', label: '균형형' },
  { value: 'spender', label: '소비 즐김' },
  { value: 'variable', label: '기복 있음' },
];

/** `RISK_LABELS` (index.ts:114). */
export const WEALTH_RISK_OPTIONS: ReadonlyArray<ChipOption> = [
  { value: 'safe', label: '안전 최우선' },
  { value: 'balanced', label: '균형 추구' },
  { value: 'aggressive', label: '공격적' },
];

/** `URGENCY_LABELS` (index.ts:129). */
export const WEALTH_URGENCY_OPTIONS: ReadonlyArray<ChipOption> = [
  { value: 'urgent', label: '급함' },
  { value: 'thisYear', label: '올해 안에' },
  { value: 'longTerm', label: '장기적으로' },
];

/** `INTEREST_LABELS` (index.ts:120). `investmentInsights` 의 키와 같다. */
export const WEALTH_INTEREST_OPTIONS: ReadonlyArray<ChipOption> = [
  { value: 'stock', label: '주식' },
  { value: 'crypto', label: '코인' },
  { value: 'realestate', label: '부동산' },
  { value: 'saving', label: '저축/예금' },
  { value: 'business', label: '사업' },
  { value: 'side', label: '부업/N잡' },
];

const INTEREST_LABEL_BY_ID = new Map(
  WEALTH_INTEREST_OPTIONS.map((option) => [option.value, option.label]),
);

/* --------------------------------- 타입 --------------------------------- */

export interface WealthElementAnalysis {
  dominantElement?: string;
  wealthElement?: string;
  compatibility?: number;
  insight?: string;
  advice?: string;
}

export interface WealthGoalAdvice {
  primaryGoal?: string;
  timeline?: string;
  strategy?: string;
  monthlyTarget?: string;
  luckyTiming?: string;
  cautionPeriod?: string;
  sajuAnalysis?: string;
}

export interface WealthCashflowInsight {
  incomeEnergy?: string;
  incomeDetail?: string;
  expenseWarning?: string;
  savingTip?: string;
}

export interface WealthConcernResolution {
  primaryConcern?: string;
  analysis?: string;
  /** 프롬프트가 "3가지" 를 요구해 배열로 오지만 한 문장으로 뭉쳐 오기도 한다. */
  solution?: string | string[];
  mindset?: string;
  sajuPerspective?: string;
}

/**
 * 관심 분야별 블록. 분야마다 스키마가 달라서 (index.ts:429~437)
 * 공통 필드 + 분야 전용 필드를 모두 optional 로 모아둔다.
 */
export interface WealthInvestmentInsight {
  score?: number;
  analysis?: string;
  timing?: string;
  startTiming?: string;
  caution?: string;
  sajuMatch?: string;
  recommendedType?: string;
  recommendedAreas?: string;
  recommendedProduct?: string;
  recommendedField?: string;
  style?: string;
  riskLevel?: string;
  monthlyAmount?: string;
  incomeExpectation?: string;
  direction?: string;
}

export interface WealthLuckyElements {
  color?: string;
  number?: number | string;
  direction?: string;
  day?: string;
  time?: string;
  item?: string;
  avoid?: string;
}

export interface WealthMonthlyFlowWeek {
  week?: number;
  energy?: string;
  advice?: string;
}

export interface WealthFortune {
  /** LLM 경로는 `overallScore`, 표준화 필드는 `score`. 둘 다 같은 값. */
  overallScore?: number;
  score?: number;
  content?: string;
  summary?: string;
  advice?: string;
  wealthPotential?: string;
  elementAnalysis?: WealthElementAnalysis;
  goalAdvice?: WealthGoalAdvice;
  cashflowInsight?: WealthCashflowInsight;
  concernResolution?: WealthConcernResolution;
  investmentInsights?: Record<string, WealthInvestmentInsight | undefined>;
  luckyElements?: WealthLuckyElements;
  monthlyFlow?: WealthMonthlyFlowWeek[];
  actionItems?: string[];
  /** 서버가 붙이는 금융 면책 문구. 없으면 kit 공용 고지만 남는다. */
  disclaimer?: string;
  percentile?: number | null;
}

/* -------------------------------- 렌더 -------------------------------- */

/** 분야 전용 필드 → 라벨. 여기 없는 키는 그리지 않는다 (원문 키 노출 방지). */
const INSIGHT_DETAIL_FIELDS: ReadonlyArray<readonly [keyof WealthInvestmentInsight, string]> = [
  ['timing', '유리한 시기'],
  ['startTiming', '시작 시기'],
  ['style', '추천 스타일'],
  ['recommendedType', '추천 유형'],
  ['recommendedProduct', '추천 상품'],
  ['recommendedField', '추천 분야'],
  ['recommendedAreas', '추천 분야'],
  ['riskLevel', '적정 비중'],
  ['monthlyAmount', '권장 월 저축액'],
  ['incomeExpectation', '예상 수입'],
  ['direction', '추천 방향'],
];

function solutionItems(solution: WealthConcernResolution['solution']): string[] {
  if (Array.isArray(solution)) return solution;
  return typeof solution === 'string' ? [solution] : [];
}

export function WealthResult({ fortune, cached }: { fortune: WealthFortune; cached: boolean }) {
  const element = fortune.elementAnalysis;
  const goal = fortune.goalAdvice;
  const cashflow = fortune.cashflowInsight;
  const concern = fortune.concernResolution;
  const lucky = fortune.luckyElements;

  const elementPairs: KeyValuePair[] = [
    { label: '강한 오행', value: element?.dominantElement },
    { label: '재물 오행', value: element?.wealthElement },
    {
      label: '재물 궁합',
      value: typeof element?.compatibility === 'number' ? `${element.compatibility}점` : undefined,
    },
  ];

  const goalPairs: KeyValuePair[] = [
    { label: '목표', value: goal?.primaryGoal },
    { label: '권장 기간', value: goal?.timeline },
    { label: '월 목표', value: goal?.monthlyTarget },
    { label: '유리한 시기', value: goal?.luckyTiming },
    { label: '주의 시기', value: goal?.cautionPeriod },
  ];

  const luckyPairs: KeyValuePair[] = [
    { label: '색', value: lucky?.color },
    { label: '숫자', value: lucky?.number },
    { label: '방향', value: lucky?.direction },
    { label: '요일', value: lucky?.day },
    { label: '시간', value: lucky?.time },
    { label: '아이템', value: lucky?.item },
    { label: '피할 것', value: lucky?.avoid },
  ];

  // 런타임에 객체가 아닐 수도 있어 Object.entries 앞에서 한 번 거른다.
  const insights = fortune.investmentInsights;
  const insightEntries =
    insights !== null && typeof insights === 'object' && !Array.isArray(insights)
      ? Object.entries(insights)
      : [];

  return (
    <section aria-label="재물운 결과" className="ondo-stack">
      <ScoreHeadline
        kicker={`재물운${cached ? ' · 저장된 결과' : ''}`}
        note={joinParts([fortune.wealthPotential, percentileNote(fortune.percentile)])}
        score={fortune.overallScore ?? fortune.score}
        summary={fortune.content ?? fortune.summary}
      />

      <KeyValueGrid label="오행 분석" pairs={elementPairs} />

      <TextSection label="오행 인사이트" text={[element?.insight, element?.advice]} />

      <KeyValueGrid label="목표 요약" pairs={goalPairs} />

      <TextSection label="목표 전략" text={[goal?.strategy, goal?.sajuAnalysis]} />

      <TextSection
        label={joinParts(['현금 흐름', cashflow?.incomeEnergy]) ?? '현금 흐름'}
        text={[cashflow?.incomeDetail, cashflow?.expenseWarning, cashflow?.savingTip]}
      />

      <TextSection
        label={joinParts(['고민', concern?.primaryConcern]) ?? '고민'}
        text={[concern?.analysis, concern?.mindset, concern?.sajuPerspective]}
      />

      <BulletList items={solutionItems(concern?.solution)} label="해결 방안" />

      {insightEntries.map(([key, insight]) => (
        <TextSection
          key={key}
          label={
            joinParts([
              INTEREST_LABEL_BY_ID.get(key) ?? key,
              typeof insight?.score === 'number' ? `${insight.score}점` : undefined,
            ]) ?? key
          }
          text={[
            insight?.analysis,
            ...INSIGHT_DETAIL_FIELDS.map(([field, fieldLabel]) =>
              labeledValue(fieldLabel, insight?.[field]),
            ),
            labeledValue('주의', insight?.caution),
            insight?.sajuMatch,
          ]}
        />
      ))}

      <KeyValueGrid label="행운 요소" pairs={luckyPairs} />

      <CardList
        items={asArray<WealthMonthlyFlowWeek>(fortune.monthlyFlow).map((week) => ({
          title: joinParts([
            typeof week?.week === 'number' ? `${week.week}주차` : undefined,
            week?.energy,
          ]),
          description: week?.advice,
        }))}
        label="이번 달 흐름"
      />

      <BulletList items={asArray<string>(fortune.actionItems)} label="실천 항목" />

      <TextSection label="투자 유의" text={fortune.disclaimer} />

      <Disclaimer />
    </section>
  );
}
