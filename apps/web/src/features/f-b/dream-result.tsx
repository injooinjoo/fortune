/**
 * 꿈해몽 결과 — `supabase/functions/fortune-dream/index.ts` 응답 중 웹이 그리는 부분.
 *
 * 봉투는 `{ success, data, error }` 이고 실제 페이로드는 `data` 안에 있다.
 * 서버가 두 경로로 응답을 만든다 (LLM 경로 / cohort pool 경로) 는 점이 중요하다 —
 * cohort 경로는 템플릿을 개인화해 돌려주므로 `todayGuidance` 같은 필드가 통째로
 * 빌 수 있다. 그래서 여기 타입은 전부 optional 이고, 렌더는 kit 프리미티브의
 * "값 없으면 null" 규칙에 맡긴다.
 */

import {
  BulletList,
  Disclaimer,
  KeyValueGrid,
  ScoreHeadline,
  TextSection,
  type KeyValuePair,
} from '@/features/fortune/result';

/**
 * `analyzeDreamContent` 가 만든 상징. `symbol` 은 영어 키('flying', 'snake')라
 * 화면에 내보내지 않는다. `category` / `meaning` 은 한국어라 그대로 쓴다.
 */
export interface DreamSymbol {
  symbol?: string;
  category?: string;
  meaning?: string;
}

export interface DreamAnalysis {
  mainTheme?: string;
  psychologicalInsight?: string;
  emotionalPattern?: string;
  symbolAnalysis?: DreamSymbol[];
}

export interface DreamFortune {
  score?: number;
  content?: string;
  summary?: string;
  /** 서버가 분류한 꿈 유형 키. 한국어 라벨은 아래 DREAM_TYPE_LABELS 로 바꾼다. */
  dreamType?: string;
  interpretation?: string;
  todayGuidance?: string;
  psychologicalState?: string;
  actionAdvice?: string[];
  affirmations?: string[];
  analysis?: DreamAnalysis;
  percentile?: number | null;
}

export interface DreamEnvelope {
  success?: boolean;
  data?: DreamFortune;
  error?: string;
}

/** Edge Function 의 `dreamTypes` 맵과 같은 키/이름. */
const DREAM_TYPE_LABELS: Record<string, string> = {
  prophetic: '예지몽',
  anxiety: '불안몽',
  'wish-fulfillment': '소망충족몽',
  processing: '처리몽',
  symbolic: '상징몽',
};

function kicker(dreamType: string | undefined): string {
  const label = dreamType ? DREAM_TYPE_LABELS[dreamType] : undefined;
  return label ? `꿈해몽 · ${label}` : '꿈해몽';
}

/**
 * 상징 목록을 "카테고리 → 의미" 쌍으로 바꾼다.
 *
 * 서버가 같이 내려주는 `relatedSymbols` / `luckyKeywords` 는 영어 키가 섞인
 * 문자열("bird: 자유, 영감, 메시지")이라 쓰지 않고, 한국어만 들어 있는
 * `analysis.symbolAnalysis` 를 직접 읽는다.
 */
function symbolPairs(symbols: DreamSymbol[] | undefined): KeyValuePair[] {
  if (!Array.isArray(symbols)) return [];
  return symbols
    .filter((entry) => typeof entry?.category === 'string' && entry.category.length > 0)
    .map((entry) => ({ label: entry.category as string, value: entry.meaning }));
}

export function DreamResult({ fortune }: { fortune: DreamFortune }) {
  return (
    <section aria-label="꿈해몽 결과" className="ondo-stack">
      <ScoreHeadline
        kicker={kicker(fortune.dreamType)}
        note={
          typeof fortune.percentile === 'number'
            ? `오늘 본 사람들 중 상위 ${fortune.percentile}%`
            : undefined
        }
        score={fortune.score}
        summary={fortune.summary}
      />

      <TextSection label="해몽" text={fortune.interpretation ?? fortune.content} />

      <TextSection label="오늘의 지침" text={fortune.todayGuidance} />

      <TextSection
        label="지금 마음 상태"
        text={fortune.psychologicalState ?? fortune.analysis?.psychologicalInsight}
      />

      <TextSection label="감정의 흐름" text={fortune.analysis?.emotionalPattern} />

      <BulletList items={fortune.actionAdvice} label="오늘 해볼 것" />

      <BulletList items={fortune.affirmations} label="나에게 해줄 말" />

      <KeyValueGrid label="꿈에서 읽은 신호" pairs={symbolPairs(fortune.analysis?.symbolAnalysis)} />

      <Disclaimer />
    </section>
  );
}
