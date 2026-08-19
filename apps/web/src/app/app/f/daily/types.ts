/**
 * `supabase/functions/fortune-daily/index.ts` 응답 중 웹이 실제로 그리는 부분만.
 *
 * 원본 `DailyFortuneResponse` 는 20개 넘는 필수 필드를 선언하지만, LLM 응답이라
 * 누락 가능성이 있어 여기서는 전부 optional 로 받고 렌더 시점에 가드한다.
 * 서버 응답 봉투는 `{ fortune, storySegments, cached, tokensUsed }`.
 */

export type DailyCategoryKey = 'total' | 'love' | 'money' | 'work' | 'study' | 'health';

export interface DailyCategory {
  score?: number;
  advice?: {
    idiom?: string;
    description?: string;
    detail?: string;
  };
}

export interface DailyFortune {
  overall_score?: number;
  summary?: string;
  greeting?: string;
  advice?: string;
  caution?: string;
  categories?: Partial<Record<DailyCategoryKey, DailyCategory>>;
  lucky_items?: {
    time?: string;
    color?: string;
    number?: string;
    direction?: string;
    food?: string;
    item?: string;
  };
  lucky_numbers?: string[];
  personalActions?: Array<{ title?: string; why?: string; priority?: number }>;
  percentile?: number;
}

export interface DailyFortuneEnvelope {
  fortune?: DailyFortune;
  cached?: boolean;
}

export const CATEGORY_LABELS: Record<DailyCategoryKey, string> = {
  total: '종합',
  love: '애정',
  money: '재물',
  work: '일',
  study: '학업',
  health: '건강',
};

export const LUCKY_ITEM_LABELS: Record<string, string> = {
  time: '시간',
  color: '색',
  number: '숫자',
  direction: '방향',
  food: '음식',
  item: '물건',
};
