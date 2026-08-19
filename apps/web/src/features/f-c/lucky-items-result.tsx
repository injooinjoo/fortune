/**
 * 행운 아이템 결과 + 설문 옵션 정의.
 *
 * 필드 이름은 `supabase/functions/fortune-lucky-items/index.ts` 의 응답 조립부
 * (index.ts:475~522) 에서 그대로 가져왔다. 봉투는 항상 `{ success, data }`.
 *
 * 이 함수는 같은 값을 두 벌로 내려준다 — 정규화된 문자열/배열(`color`,
 * `fashion`, …)과 이유가 붙은 원본 객체(`colorDetail`, `fashionDetail`, …).
 * 화면은 이유가 있는 쪽을 먼저 쓰고, 없으면 정규화본으로 떨어진다.
 */

import {
  CardList,
  Disclaimer,
  KeyValueGrid,
  ScoreHeadline,
  TextSection,
  type CardListItem,
  type KeyValuePair,
} from '@/features/fortune/result';

import type { ChipOption } from '@/features/fortune/fields';

import { asArray, joinParts, percentileNote } from './shared';

/* ------------------------------- 설문 옵션 ------------------------------- */

/**
 * `categoryFocusMap` 의 키 (index.ts:203). 고른 카테고리는 프롬프트에서
 * "3배 더 상세하게" 지시를 받고, 나머지는 간략히 나온다.
 *
 * 서버는 이 값을 `interests[0]` 에서 읽는다 (index.ts:264) — 앱이 보내는
 * `category` 키는 읽지 않아 항상 fashion 으로 떨어진다. 웹은 `interests` 로 보낸다.
 */
export const LUCKY_CATEGORY_OPTIONS: ReadonlyArray<ChipOption> = [
  { value: 'fashion', label: '패션/액세서리' },
  { value: 'color', label: '색상' },
  { value: 'food', label: '음식' },
  { value: 'place', label: '장소/방향' },
  { value: 'number', label: '숫자' },
  { value: 'shopping', label: '쇼핑' },
  { value: 'health', label: '운동/건강' },
  { value: 'lifestyle', label: '라이프스타일' },
];

/* --------------------------------- 타입 --------------------------------- */

/** 카테고리마다 제목 키가 다르다 — item / place / type (index.ts:443~449). */
export interface LuckyDetailItem {
  item?: string;
  place?: string;
  type?: string;
  category?: string;
  reason?: string;
  timing?: string;
}

export interface LuckyColorDetail {
  primary?: string;
  secondary?: string;
  reason?: string;
}

export interface LuckyDirectionDetail {
  primary?: string;
  compass?: string;
  angle?: number;
  reason?: string;
}

export interface LuckyAdviceDetail {
  morning?: string;
  afternoon?: string;
  evening?: string;
  overall?: string;
}

export interface LuckyItemsFortune {
  score?: number;
  content?: string;
  summary?: string;
  advice?: string;
  title?: string;
  selectedCategory?: string;
  selectedCategoryLabel?: string;
  lucky_summary?: string;
  keyword?: string;
  element?: string;
  color?: string;
  colorDetail?: LuckyColorDetail | string;
  numbers?: number[];
  numbersExplanation?: string;
  avoidNumbers?: number[];
  direction?: string;
  directionCompass?: string;
  directionDetail?: LuckyDirectionDetail | string;
  fashion?: string[];
  fashionDetail?: Array<LuckyDetailItem | string>;
  food?: string[];
  foodDetail?: Array<LuckyDetailItem | string>;
  jewelry?: string[];
  jewelryDetail?: Array<LuckyDetailItem | string>;
  material?: string[];
  materialDetail?: Array<LuckyDetailItem | string>;
  places?: string[];
  placesDetail?: Array<LuckyDetailItem | string>;
  relationships?: string[];
  relationshipsDetail?: Array<LuckyDetailItem | string>;
  adviceDetail?: LuckyAdviceDetail | string;
  todayTip?: string;
  percentile?: number | null;
}

/* -------------------------------- 렌더 -------------------------------- */

/** 이유가 붙은 원본 배열을 우선 쓰고, 없으면 정규화된 문자열 배열로. */
function detailItems(
  detail: Array<LuckyDetailItem | string> | undefined,
  plain: string[] | undefined,
): CardListItem[] {
  const entries = asArray<LuckyDetailItem | string>(detail);
  if (entries.length > 0) {
    return entries.map((entry) =>
      typeof entry === 'string'
        ? { title: entry }
        : {
            title: entry?.item ?? entry?.place ?? entry?.type,
            description: joinParts([entry?.category, entry?.reason, entry?.timing]),
          },
    );
  }
  return asArray<string>(plain).map((entry) => ({ title: entry }));
}

function numberList(values: number[] | undefined): string | undefined {
  const entries = asArray<number>(values).filter(
    (value): value is number => typeof value === 'number' && Number.isFinite(value),
  );
  return entries.length > 0 ? entries.join(', ') : undefined;
}

function asObject<T>(value: T | string | undefined): T | undefined {
  return value !== null && typeof value === 'object' ? (value as T) : undefined;
}

export function LuckyItemsResult({ fortune }: { fortune: LuckyItemsFortune }) {
  const color = asObject<LuckyColorDetail>(fortune.colorDetail);
  const direction = asObject<LuckyDirectionDetail>(fortune.directionDetail);
  const advice = asObject<LuckyAdviceDetail>(fortune.adviceDetail);

  const luckyPairs: KeyValuePair[] = [
    { label: '오행', value: fortune.element },
    { label: '행운 색', value: fortune.color ?? joinParts([color?.primary, color?.secondary], ', ') },
    { label: '행운 방향', value: fortune.directionCompass ?? fortune.direction ?? direction?.primary },
    { label: '행운 숫자', value: numberList(fortune.numbers) },
    { label: '피할 숫자', value: numberList(fortune.avoidNumbers) },
  ];

  const timeItems: CardListItem[] = [
    { title: '오전', description: advice?.morning },
    { title: '오후', description: advice?.afternoon },
    { title: '저녁', description: advice?.evening },
  ].filter((item) => item.description !== undefined);

  return (
    <section aria-label="행운 아이템 결과" className="ondo-stack">
      <ScoreHeadline
        kicker={joinParts(['행운 아이템', fortune.selectedCategoryLabel]) ?? '행운 아이템'}
        note={joinParts([fortune.keyword, percentileNote(fortune.percentile)])}
        score={fortune.score}
        summary={fortune.content ?? fortune.lucky_summary}
      />

      <KeyValueGrid label="오늘의 행운" pairs={luckyPairs} />

      <TextSection label="색과 방향" text={[color?.reason, direction?.reason]} />

      <TextSection label="숫자 풀이" text={fortune.numbersExplanation} />

      <CardList items={detailItems(fortune.fashionDetail, fortune.fashion)} label="패션" />

      <CardList items={detailItems(fortune.foodDetail, fortune.food)} label="음식" />

      <CardList items={detailItems(fortune.jewelryDetail, fortune.jewelry)} label="보석·액세서리" />

      <CardList items={detailItems(fortune.materialDetail, fortune.material)} label="소재" />

      <CardList items={detailItems(fortune.placesDetail, fortune.places)} label="장소" />

      <CardList
        items={detailItems(fortune.relationshipsDetail, fortune.relationships)}
        label="오늘의 인연"
      />

      <CardList items={timeItems} label="시간대별 행동" />

      <TextSection label="오늘의 조언" text={[advice?.overall ?? fortune.advice, fortune.todayTip]} />

      <Disclaimer />
    </section>
  );
}
