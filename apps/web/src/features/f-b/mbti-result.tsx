/**
 * MBTI 운세 결과 — `supabase/functions/fortune-mbti/index.ts` 응답.
 *
 * 봉투는 `{ success, data, error }`.
 *
 * 서버가 같이 내려주는 `loveFortune` / `careerFortune` 은 아래 `dimensions` 의
 * fortune 문자열을 접두어만 붙여 재사용한 값이고, `moneyFortune` /
 * `healthFortune` 은 유형과 무관한 고정 문구다. 같은 내용을 두 번 보여주거나
 * 상수를 운세인 척 보여주지 않으려고 넷 다 그리지 않는다.
 * `categoryInsight` 도 dimensions 를 재조합한 파생값이라 뺐다.
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

export interface MbtiDimension {
  dimension?: string;
  /** '외향형 에너지' 처럼 차원 이름. */
  title?: string;
  fortune?: string;
  tip?: string;
  score?: number;
  warning?: string;
}

export interface MbtiFortune {
  score?: number;
  overallScore?: number;
  content?: string;
  todayFortune?: string;
  todayTrap?: string;
  dimensions?: MbtiDimension[];
  luckyColor?: string;
  luckyNumber?: number | string;
  compatibility?: string[];
  cognitiveStrengths?: string[];
  challenges?: string[];
  mbtiDescription?: string;
  percentile?: number | null;
}

export interface MbtiEnvelope {
  success?: boolean;
  data?: MbtiFortune;
  error?: string;
}

/** '외향형 에너지: 자신을 믿으세요' 형태. 둘 중 하나라도 비면 줄을 통째로 뺀다. */
function labelled(dimensions: MbtiDimension[] | undefined, key: 'tip' | 'warning'): string[] {
  if (!Array.isArray(dimensions)) return [];
  return dimensions
    .map((dimension) => {
      const body = dimension?.[key];
      if (typeof body !== 'string' || body.trim().length === 0) return undefined;
      const title = dimension.title;
      return typeof title === 'string' && title.trim().length > 0 ? `${title}: ${body}` : body;
    })
    .filter((entry): entry is string => entry !== undefined);
}

export function MbtiResult({ fortune, mbti }: { fortune: MbtiFortune; mbti: string }) {
  const dimensions = Array.isArray(fortune.dimensions) ? fortune.dimensions : [];

  const lucky: KeyValuePair[] = [
    { label: '행운의 색', value: fortune.luckyColor },
    { label: '행운의 숫자', value: fortune.luckyNumber },
    {
      label: '잘 맞는 유형',
      value: Array.isArray(fortune.compatibility) ? fortune.compatibility.join(', ') : undefined,
    },
  ];

  return (
    <section aria-label={`${mbti} 오늘의 운세 결과`} className="ondo-stack">
      <ScoreHeadline
        kicker={`${mbti} 오늘의 운세`}
        note={
          typeof fortune.percentile === 'number'
            ? `오늘 본 사람들 중 상위 ${fortune.percentile}%`
            : undefined
        }
        score={fortune.overallScore ?? fortune.score}
        summary={fortune.todayFortune ?? fortune.content}
      />

      <TextSection label="유형" text={fortune.mbtiDescription} />

      <TextSection label="오늘의 함정" text={fortune.todayTrap} />

      {dimensions.length > 0 ? (
        <div className="ondo-grid-2">
          {dimensions.map((dimension, index) => (
            <ScoreSection
              key={dimension.dimension ?? index}
              label={dimension.title ?? dimension.dimension ?? '차원'}
              score={dimension.score}
              text={dimension.fortune}
            />
          ))}
        </div>
      ) : null}

      <BulletList items={labelled(dimensions, 'tip')} label="오늘의 팁" />

      <BulletList items={labelled(dimensions, 'warning')} label="이런 함정을 조심해요" />

      <BulletList items={fortune.cognitiveStrengths} label="강점" />

      <BulletList items={fortune.challenges} label="주의할 점" />

      <KeyValueGrid label="행운 요소" pairs={lucky} />

      <Disclaimer />
    </section>
  );
}
