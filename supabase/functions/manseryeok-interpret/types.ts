/**
 * manseryeok-interpret Edge Function — 입출력 타입.
 *
 * Deno 환경에서 `@fortune/saju-engine`을 직접 import할 수 없으므로
 * sajuData는 `unknown`으로 받아 런타임에서 필드만 안전하게 추출한다.
 */

export type Section =
  | "personality"
  | "career"
  | "wealth"
  | "love"
  | "health"
  | "daily"
  | "luckCycles";

export interface ManseryeokInterpretRequest {
  userId?: string;
  sajuData: unknown;
  sections?: Section[];
}

export interface PersonalityData {
  summary: string;
  strengths: string[];
  challenges: string[];
}

export interface CareerData {
  summary: string;
  suitableFields: string[];
  advice: string;
}

export interface WealthData {
  summary: string;
  bestPeriods: string[];
  caution: string;
}

export interface LoveData {
  summary: string;
  compatibleTypes: string[];
  advice: string;
}

export interface HealthData {
  summary: string;
  weakPoints: string[];
  advice: string;
}

export interface DailyData {
  oneLiner: string;
  luckyColor: string;
  luckyDirection: string;
}

export interface LuckCycleInterpretation {
  ageRange: string;
  theme: string;
  summary: string;
}

export interface InterpretationData {
  overallSummary: string;
  personality: PersonalityData;
  career: CareerData;
  wealth: WealthData;
  love: LoveData;
  health: HealthData;
  daily: DailyData;
  luckCycles: LuckCycleInterpretation[];
}

export interface ManseryeokInterpretResponse {
  success: boolean;
  data?: InterpretationData;
  error?: string;
  cached?: boolean;
}

/**
 * SajuData 런타임 형상 (LLM 프롬프트 빌더가 기대하는 최소 필드).
 * 엔진 쪽 `SajuResult`와 동기화 되어야 하며 불일치 시 fallback 사용.
 */
export interface SajuDataLite {
  pillars: {
    year: { stem: { korean: string }; branch: { korean: string } };
    month: { stem: { korean: string }; branch: { korean: string } };
    day: { stem: { korean: string }; branch: { korean: string } };
    hour: { stem: { korean: string }; branch: { korean: string } };
  };
  tenGods: {
    year: { stem: string; branch: string };
    month: { stem: string; branch: string };
    day: { stem: string; branch: string };
    hour: { stem: string; branch: string };
  };
  elements: {
    wood: number;
    fire: number;
    earth: number;
    metal: number;
    water: number;
    strongest?: string;
    weakest?: string;
  };
  luckCycles: {
    direction: string;
    cycles: Array<{
      startAge: number;
      stem: { korean: string };
      branch: { korean: string };
      tenGod: string;
    }>;
  };
}
