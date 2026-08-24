import Link from 'next/link';

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

      <section aria-labelledby="next-reading-title" className="ondo-card ondo-stack">
        <div className="ondo-stack" style={{ gap: 'var(--ondo-spacing-xxs)' }}>
          <p className="ondo-kicker">이어 읽기</p>
          <h2 className="ondo-h3" id="next-reading-title">
            오늘의 흐름에서 한 가지를 더 골라볼까요?
          </h2>
        </div>
        <p className="ondo-muted">결과를 본 뒤 지금 마음에 남는 주제를 골라 더 자세히 읽어보세요.</p>
        <nav aria-label="오늘의 운세 다음 읽기" className="ondo-row">
          <Link className="ondo-button ondo-button--secondary" href="/운세/연애">
            연애운 보기
          </Link>
          <Link className="ondo-button ondo-button--secondary" href="/운세/재물">
            재물운 보기
          </Link>
          <Link className="ondo-button ondo-button--secondary" href="/대화">
            캐릭터와 이야기하기
          </Link>
        </nav>
      </section>

      <Disclaimer />
    </section>
  );
}
