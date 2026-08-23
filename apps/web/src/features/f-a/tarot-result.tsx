/**
 * 타로 리딩 결과.
 *
 * 응답 계약은 `supabase/functions/fortune-tarot/index.ts` 의
 * `buildStableTarotData()` + `addPercentileToResult()` 에서 그대로 읽었다.
 * 봉투는 `{ success, data, cohortHit?, tokenCharge? }` 이고 본문은 `data` 안이다.
 *
 * 서버가 대부분의 필드에 fallback 을 채워주지만 cohort pool 히트 경로는
 * 과거에 저장된 payload 를 그대로 돌려주므로 필드 구성이 다를 수 있다.
 * 그래서 전부 optional 로 받고 kit 프리미티브의 "없으면 안 그림" 규칙에 맡긴다.
 */

import {
  BulletList,
  CardList,
  Disclaimer,
  KeyValueGrid,
  ScoreHeadline,
  TextSection,
} from '@/features/fortune/result';

export interface TarotCardReading {
  cardNameKr?: string;
  cardName?: string;
  orientationLabel?: string;
  isReversed?: boolean;
  positionName?: string;
  positionDesc?: string;
  interpretation?: string;
  keywords?: string[];
  element?: string;
}

export interface TarotReading {
  question?: string;
  deckName?: string;
  spreadDisplayName?: string;
  storyTitle?: string;
  overallReading?: string;
  guidance?: string;
  advice?: string;
  keyThemes?: string[];
  luckyElement?: string;
  focusAreas?: string[];
  timeFrame?: string;
  energyLevel?: number;
  cards?: TarotCardReading[];
  /** `addPercentileToResult` 가 붙인다. 표본 10명 미만이면 percentile 은 null. */
  percentile?: number | null;
  isPercentileValid?: boolean;
}

export interface TarotEnvelope {
  success?: boolean;
  data?: TarotReading;
  cohortHit?: boolean;
}

/** 위치 이름 + 카드 이름 + 정/역방향을 한 줄 제목으로. */
function cardTitle(card: TarotCardReading): string | undefined {
  const name = card.cardNameKr ?? card.cardName;
  const orientation = card.orientationLabel ?? (card.isReversed ? '역방향' : undefined);
  const label = [name, orientation].filter(Boolean).join(' · ');
  if (card.positionName && label) return `${card.positionName} — ${label}`;
  return card.positionName ?? (label || undefined);
}

/** 해석이 비면 위치 설명이라도 보여준다 (빈 카드로 남기지 않기). */
function cardBody(card: TarotCardReading): string | undefined {
  return card.interpretation ?? card.positionDesc;
}

export function TarotResult({ reading }: { reading: TarotReading }) {
  const spreadLine = [reading.spreadDisplayName, reading.deckName].filter(Boolean).join(' · ');

  return (
    <section aria-label="타로 리딩 결과" className="ondo-stack">
      <ScoreHeadline
        kicker={spreadLine || '타로 리딩'}
        note={
          reading.isPercentileValid === true && typeof reading.percentile === 'number'
            ? `오늘 타로를 본 사람들 중 상위 ${reading.percentile}%`
            : undefined
        }
        score={reading.energyLevel}
        summary={reading.storyTitle}
        unit=""
      />

      <TextSection label="카드가 들려주는 이야기" text={reading.overallReading} />

      <CardList
        items={reading.cards?.map((card) => ({
          title: cardTitle(card),
          description: cardBody(card),
        }))}
        label="펼쳐진 카드"
      />

      <TextSection label="흐름 안내" text={reading.guidance} />

      <TextSection label="조언" text={reading.advice} />

      <BulletList items={reading.keyThemes} label="핵심 주제" />

      <BulletList items={reading.focusAreas} label="집중할 곳" />

      <KeyValueGrid
        label="리딩 정보"
        pairs={[
          { label: '질문', value: reading.question },
          { label: '행운 원소', value: reading.luckyElement },
          { label: '흐름 시기', value: reading.timeFrame },
        ]}
      />

      <Disclaimer />
    </section>
  );
}
