/**
 * 띠별 운세 결과 — `supabase/functions/fortune-zodiac-animal/index.ts` 응답.
 *
 * 봉투는 `{ success, data, error }`. 서버가 LLM JSON 파싱에 실패해도 정적
 * fallback 으로 같은 모양을 채워 주지만, LLM 이 키를 빠뜨리면 개별 필드는 빌 수
 * 있어 전부 optional 로 받는다.
 *
 * `birthYear` 는 일부러 그리지 않는다 — 웹은 사용자가 띠를 직접 고르고 서버에는
 * 그 띠의 대표 연도를 보내므로 (zodiac-animals.ts 참고) 실제 출생 연도가 아니다.
 */

import {
  BulletList,
  Disclaimer,
  KeyValueGrid,
  ScoreHeadline,
  ScoreSection,
  TextSection,
  type KeyValuePair,
} from '@/features/fortune/result';

export interface ZodiacCategory {
  score?: number;
  description?: string;
}

export interface ZodiacFortune {
  score?: number;
  content?: string;
  summary?: string;
  advice?: string;
  zodiacAnimal?: string;
  zodiacEmoji?: string;
  zodiacBranch?: string;
  zodiacElement?: string;
  categories?: {
    interpersonal?: ZodiacCategory;
    action?: ZodiacCategory;
    emotion?: ZodiacCategory;
    timing?: ZodiacCategory;
  };
  compatibility?: {
    best?: string[];
    caution?: string[];
  };
  luckyItems?: {
    time?: string;
    color?: string;
    direction?: string;
    /** 서버 기본값은 문자열이지만 LLM 이 숫자를 줄 때가 있다. */
    number?: string | number;
  };
  highlights?: string[];
  timingTip?: string;
  specialNote?: string;
}

export interface ZodiacEnvelope {
  success?: boolean;
  data?: ZodiacFortune;
  error?: string;
}

type CategoryKey = keyof NonNullable<ZodiacFortune['categories']>;

const CATEGORY_LABELS: Array<{ key: CategoryKey; label: string }> = [
  { key: 'interpersonal', label: '대인운' },
  { key: 'action', label: '실행운' },
  { key: 'emotion', label: '감정운' },
  { key: 'timing', label: '타이밍운' },
];

/** 띠 이름 배열 → "원숭이, 용" 한 줄. 빈 배열이면 undefined 라 카드가 접힌다. */
function joinAnimals(names: string[] | undefined): string | undefined {
  if (!Array.isArray(names)) return undefined;
  const cleaned = names.filter((name) => typeof name === 'string' && name.trim().length > 0);
  return cleaned.length > 0 ? cleaned.join(', ') : undefined;
}

export function ZodiacResult({ fortune }: { fortune: ZodiacFortune }) {
  const animalLabel = fortune.zodiacAnimal ? `${fortune.zodiacAnimal}띠` : '띠별 운세';

  const info: KeyValuePair[] = [
    { label: '지지', value: fortune.zodiacBranch },
    { label: '오행', value: fortune.zodiacElement },
  ];

  const lucky: KeyValuePair[] = [
    { label: '시간', value: fortune.luckyItems?.time },
    { label: '색', value: fortune.luckyItems?.color },
    { label: '방향', value: fortune.luckyItems?.direction },
    { label: '숫자', value: fortune.luckyItems?.number },
  ];

  const compatibility: KeyValuePair[] = [
    { label: '잘 맞는 띠', value: joinAnimals(fortune.compatibility?.best) },
    { label: '조심할 띠', value: joinAnimals(fortune.compatibility?.caution) },
  ];

  return (
    <section aria-label="띠별 운세 결과" className="ondo-stack">
      <ScoreHeadline
        kicker={
          fortune.zodiacEmoji ? `${fortune.zodiacEmoji} ${animalLabel}` : animalLabel
        }
        score={fortune.score}
        summary={fortune.summary ?? fortune.content}
      />

      <KeyValueGrid label="띠 정보" pairs={info} />

      <div className="ondo-grid-2">
        {CATEGORY_LABELS.map(({ key, label }) => (
          <ScoreSection
            key={key}
            label={label}
            score={fortune.categories?.[key]?.score}
            text={fortune.categories?.[key]?.description}
          />
        ))}
      </div>

      <TextSection label="조언" text={fortune.advice} />

      <BulletList items={fortune.highlights} label="오늘의 포인트" />

      <KeyValueGrid label="행운 요소" pairs={lucky} />

      <KeyValueGrid label="궁합" pairs={compatibility} />

      <TextSection label="타이밍" text={fortune.timingTip} />

      <TextSection label={`${animalLabel}에게`} text={fortune.specialNote} />

      <Disclaimer />
    </section>
  );
}
