import type { Ref } from 'react';

import { AppLink as Link } from '@/components/app-link';

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

export function DailyResult({
  fortune,
  cached,
  onReset,
  resultRef,
}: {
  fortune: DailyFortune;
  cached: boolean;
  /** 저장된 기록을 다시 볼 때는 되돌릴 입력이 없어서 툴바를 통째로 뺀다. */
  onReset?: () => void;
  resultRef?: Ref<HTMLElement>;
}) {
  const luckyItems: KeyValuePair[] = Object.entries(fortune.lucky_items ?? {}).map(
    ([key, value]) => ({ label: LUCKY_ITEM_LABELS[key] ?? key, value }),
  );

  return (
    <section
      ref={resultRef}
      aria-label="오늘의 운세 결과"
      className="ondo-daily-result"
      tabIndex={-1}
    >
      {onReset ? (
        <div className="ondo-daily-result-toolbar">
          <button className="ondo-button ondo-button--secondary" onClick={onReset} type="button">
            정보 다시 입력
          </button>
        </div>
      ) : null}
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
        <div className="ondo-daily-result-categories">
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

      <div className="ondo-daily-result-body">
        <div className="ondo-stack">
          <TextSection label="조언" text={fortune.advice} />
          <TextSection label="주의" text={fortune.caution} />
        </div>
        <div className="ondo-stack">
          <KeyValueGrid label="행운 요소" pairs={luckyItems} />
          <CardList
            items={fortune.personalActions?.map((action) => ({
              title: action.title,
              description: action.why,
            }))}
            label="오늘 해볼 것"
          />
        </div>
      </div>

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
