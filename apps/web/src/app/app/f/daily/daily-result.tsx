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
  const luckyItems = Object.entries(fortune.lucky_items ?? {}).filter(
    (entry): entry is [string, string] => typeof entry[1] === 'string' && entry[1].length > 0,
  );

  return (
    <section aria-label="오늘의 운세 결과" className="ondo-stack">
      <div className="ondo-card ondo-stack" style={{ gap: 'var(--ondo-spacing-xs)' }}>
        <p className="ondo-kicker">오늘의 운세{cached ? ' · 저장된 결과' : ''}</p>
        {typeof fortune.overall_score === 'number' ? (
          <p className="ondo-h1">{fortune.overall_score}점</p>
        ) : null}
        {fortune.summary ? <p>{fortune.summary}</p> : null}
        {typeof fortune.percentile === 'number' ? (
          <p className="ondo-muted">오늘 본 사람들 중 상위 {fortune.percentile}%</p>
        ) : null}
      </div>

      {fortune.categories ? (
        <div className="ondo-grid-2">
          {CATEGORY_ORDER.map((key) => {
            const category = fortune.categories?.[key];
            if (!category) return null;
            const text = categoryText(fortune, key);
            return (
              <div className="ondo-card ondo-stack" key={key} style={{ gap: 'var(--ondo-spacing-xxs)' }}>
                <p className="ondo-kicker">{CATEGORY_LABELS[key]}</p>
                {typeof category.score === 'number' ? (
                  <p className="ondo-h3">{category.score}점</p>
                ) : null}
                {text ? <p className="ondo-muted">{text}</p> : null}
              </div>
            );
          })}
        </div>
      ) : null}

      {fortune.advice ? (
        <div className="ondo-card ondo-stack" style={{ gap: 'var(--ondo-spacing-xs)' }}>
          <p className="ondo-kicker">조언</p>
          <p>{fortune.advice}</p>
        </div>
      ) : null}

      {fortune.caution ? (
        <div className="ondo-card ondo-stack" style={{ gap: 'var(--ondo-spacing-xs)' }}>
          <p className="ondo-kicker">주의</p>
          <p>{fortune.caution}</p>
        </div>
      ) : null}

      {luckyItems.length > 0 ? (
        <div className="ondo-card ondo-stack" style={{ gap: 'var(--ondo-spacing-xs)' }}>
          <p className="ondo-kicker">행운 요소</p>
          <dl className="ondo-grid-2" style={{ margin: 0 }}>
            {luckyItems.map(([key, value]) => (
              <div key={key}>
                <dt className="ondo-muted">{LUCKY_ITEM_LABELS[key] ?? key}</dt>
                <dd style={{ margin: 0 }}>{value}</dd>
              </div>
            ))}
          </dl>
        </div>
      ) : null}

      {fortune.personalActions && fortune.personalActions.length > 0 ? (
        <div className="ondo-card ondo-stack" style={{ gap: 'var(--ondo-spacing-xs)' }}>
          <p className="ondo-kicker">오늘 해볼 것</p>
          <ol className="ondo-stack" style={{ gap: 'var(--ondo-spacing-sm)', margin: 0, paddingLeft: '1.2em' }}>
            {fortune.personalActions.map((action, index) => (
              <li key={action.title ?? index}>
                {action.title ? <p className="ondo-h3">{action.title}</p> : null}
                {action.why ? <p className="ondo-muted">{action.why}</p> : null}
              </li>
            ))}
          </ol>
        </div>
      ) : null}

      <p className="ondo-muted">
        온도의 운세는 엔터테인먼트 목적으로 제공되며, 어떠한 전문적 조언도 대체하지 않습니다.
      </p>
    </section>
  );
}
