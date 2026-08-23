/**
 * 12지 카탈로그 — `/운세/띠별` 과 `/운세/띠별/<띠>` 가 공유하는 단일 소스.
 *
 * 이름/지지/오행/순서는 `supabase/functions/fortune-zodiac-animal/index.ts` 의
 * `ZODIAC_ANIMALS` 를 그대로 옮긴 것이다. 서버가 이 순서로 띠를 도출하므로
 * (`((year - 4) % 12 + 12) % 12`) 순서가 어긋나면 대표 연도가 틀어진다.
 */

export interface ZodiacAnimal {
  /** URL 경로 조각이자 화면 라벨. `/운세/띠별/호랑이`. */
  name: string;
  emoji: string;
  /** 지지 (자·축·인…). */
  branch: string;
  element: string;
  /**
   * 이 띠를 서버에 알리는 대표 연도.
   *
   * Edge Function 은 `birthDate` 에서 **연도만** 읽어 띠를 도출하고
   * (`new Date(birthDateStr).getFullYear()`), 응답 내용은 도출된 띠에만 의존한다.
   * 그래서 사용자가 띠를 직접 고르는 웹에서는 그 띠에 해당하는 연도 하나를
   * 보내면 된다. 응답의 `birthYear` 는 이 대표 연도라서 화면에 그리지 않는다.
   */
  canonicalYear: number;
}

const ORDER: ReadonlyArray<Omit<ZodiacAnimal, 'canonicalYear'>> = [
  { name: '쥐', emoji: '🐭', branch: '자', element: '수(水)' },
  { name: '소', emoji: '🐄', branch: '축', element: '토(土)' },
  { name: '호랑이', emoji: '🐯', branch: '인', element: '목(木)' },
  { name: '토끼', emoji: '🐰', branch: '묘', element: '목(木)' },
  { name: '용', emoji: '🐉', branch: '진', element: '토(土)' },
  { name: '뱀', emoji: '🐍', branch: '사', element: '화(火)' },
  { name: '말', emoji: '🐴', branch: '오', element: '화(火)' },
  { name: '양', emoji: '🐑', branch: '미', element: '토(土)' },
  { name: '원숭이', emoji: '🐵', branch: '신', element: '금(金)' },
  { name: '닭', emoji: '🐓', branch: '유', element: '금(金)' },
  { name: '개', emoji: '🐶', branch: '술', element: '토(土)' },
  { name: '돼지', emoji: '🐷', branch: '해', element: '수(水)' },
];

/** 2008년은 쥐띠 — `(2008 - 4) % 12 === 0` 이라 index 0 과 맞는다. */
const ANCHOR_YEAR = 2008;

export const ZODIAC_ANIMALS: ReadonlyArray<ZodiacAnimal> = ORDER.map((animal, index) => ({
  ...animal,
  canonicalYear: ANCHOR_YEAR + index,
}));

export function findZodiacAnimal(name: string): ZodiacAnimal | undefined {
  return ZODIAC_ANIMALS.find((animal) => animal.name === name);
}

const FIRST_LISTED_YEAR = 1936;
const LAST_LISTED_YEAR = 2020;

/** "몇 년생이 이 띠인지" 안내용. 12년 간격이라 계산으로 낸다. */
export function birthYearsOf(animal: ZodiacAnimal): number[] {
  let start = animal.canonicalYear;
  while (start - 12 >= FIRST_LISTED_YEAR) start -= 12;

  const years: number[] = [];
  for (let year = start; year <= LAST_LISTED_YEAR; year += 12) {
    years.push(year);
  }
  return years;
}

/**
 * 대표 연도를 Edge Function 이 받는 `birthDate` 문자열로 바꾼다.
 *
 * 연중(6월 15일)을 쓰는 이유: 서버가 `new Date('YYYY-MM-DD')` 로 UTC 자정을
 * 만든 뒤 로컬 `getFullYear()` 를 부르기 때문에, 1월 1일을 쓰면 런타임 타임존이
 * UTC 보다 뒤일 때 연도가 하나 밀린다.
 */
export function birthDateForAnimal(animal: ZodiacAnimal): string {
  return `${animal.canonicalYear}-06-15`;
}
