import {
  CardList,
  Disclaimer,
  KeyValueGrid,
  ScoreHeadline,
  ScoreSection,
  TextSection,
  type KeyValuePair,
} from '@/features/fortune/result';

import {
  CATEGORY_LABELS,
  LUCKY_ITEM_LABELS,
  type DailyCategoryKey,
  type DailyFortune,
} from './types';

const CATEGORY_ORDER: DailyCategoryKey[] = ['total', 'love', 'money', 'work', 'study', 'health'];

function categoryText(fortune: DailyFortune, key: DailyCategoryKey): string | undefined {
  const advice = fortune.categories?.[key]?.advice;
  if (!advice) return undefined;
  return advice.detail ?? advice.description ?? advice.idiom;
}

export function DailyResult({ fortune, cached }: { fortune: DailyFortune; cached: boolean }) {
  const luckyItems: KeyValuePair[] = Object.entries(fortune.lucky_items ?? {}).map(
    ([key, value]) => ({ label: LUCKY_ITEM_LABELS[key] ?? key, value }),
  );

  return (
    <section aria-label="오늘의 운세 결과" className="ondo-stack">
      <ScoreHeadline
        kicker={`오늘의 운세${cached ? ' · 저장된 결과' : ''}`}
        note={
          typeof fortune.percentile === 'number'
            ? `오늘 본 사람들 중 상위 ${fortune.percentile}%`
            : undefined
        }
        score={fortune.overall_score}
        summary={fortune.summary}
      />

      {fortune.categories ? (
        <div className="ondo-grid-2">
          {CATEGORY_ORDER.map((key) => (
            <ScoreSection
              key={key}
              label={CATEGORY_LABELS[key]}
              score={fortune.categories?.[key]?.score}
              text={categoryText(fortune, key)}
            />
          ))}
        </div>
      ) : null}

      <TextSection label="조언" text={fortune.advice} />

      <TextSection label="주의" text={fortune.caution} />

      <KeyValueGrid label="행운 요소" pairs={luckyItems} />

      <CardList
        items={fortune.personalActions?.map((action) => ({
          title: action.title,
          description: action.why,
        }))}
        label="오늘 해볼 것"
      />

      <Disclaimer />
    </section>
  );
}
