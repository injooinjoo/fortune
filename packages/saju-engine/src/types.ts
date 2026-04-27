/**
 * Saju Engine — Core types
 *
 * 모든 계산 결과 및 입력 타입을 이 파일에서 단일 소스로 관리.
 */

/** 오행 (Five Elements) */
export type Element = '목' | '화' | '토' | '금' | '수';

/** 서양 별자리 (12 signs, tropical zodiac) */
export type ZodiacSign =
  | 'aries'       | 'taurus'  | 'gemini'   | 'cancer'
  | 'leo'         | 'virgo'   | 'libra'    | 'scorpio'
  | 'sagittarius' | 'capricorn' | 'aquarius' | 'pisces';

/** 별자리 정보 */
export interface ZodiacInfo {
  id: ZodiacSign;
  /** 한글 이름, 예: "쌍둥이자리" */
  ko: string;
  /** 영문 이름, 예: "Gemini" */
  en: string;
  /** 유니코드 심볼, 예: "♊" */
  symbol: string;
  /** 양력 구간 문자열, 예: "5.21 — 6.21" */
  dateRange: string;
}

/** 음양 */
export type YinYang = '양' | '음';

/** 성별 */
export type Gender = 'male' | 'female';

/** 12지지 한글 */
export type BranchKr =
  | '자' | '축' | '인' | '묘' | '진' | '사'
  | '오' | '미' | '신' | '유' | '술' | '해';

/** 10천간 한글 */
export type StemKr =
  | '갑' | '을' | '병' | '정' | '무'
  | '기' | '경' | '신' | '임' | '계';

/** 십성 (Ten Gods) */
export type TenGod =
  | '비견' | '겁재'
  | '식신' | '상관'
  | '편재' | '정재'
  | '편관' | '정관'
  | '편인' | '정인'
  | '일간';

/** 12운성 */
export type TwelveStage =
  | '장생' | '목욕' | '관대' | '건록' | '제왕'
  | '쇠'   | '병'   | '사'   | '묘'   | '절'
  | '태'   | '양';

/** 지장간 타입 */
export type JiJangGanType = 'main' | 'middle' | 'remnant';

/** 지장간 엔트리 */
export interface JiJangGanEntry {
  stem: StemKr;
  hanja: string;
  type: JiJangGanType;
  ratio: number;
  element: Element;
}

/** 천간 정의 */
export interface Stem {
  hanja: string;
  korean: StemKr;
  element: Element;
  yin: boolean; // true = 음, false = 양
}

/** 지지 정의 */
export interface Branch {
  hanja: string;
  korean: BranchKr;
  element: Element;
  animal: string;
  yin: boolean;
  /** 대응되는 월령 (인=1, 묘=2, ..., 축=12) */
  lunarMonth: number;
}

/** 개별 주(柱) */
export interface PillarData {
  stem: Stem;
  branch: Branch;
  /** 간지 한글, e.g. "계해" */
  korean: string;
  /** 간지 한자, e.g. "癸亥" */
  hanja: string;
}

/** 4주 */
export interface FourPillars {
  year: PillarData;
  month: PillarData;
  day: PillarData;
  hour: PillarData;
}

/** 각 주의 십성 (천간 + 지지 본기 기준) */
export interface PillarTenGods {
  stem: TenGod;
  branch: TenGod;
}

/** 4주별 십성 */
export interface TenGodsResult {
  year: PillarTenGods;
  month: PillarTenGods;
  day: PillarTenGods;  // 일간은 '일간'
  hour: PillarTenGods;
}

/** 4주별 12운성 */
export interface TwelveStagesResult {
  year: TwelveStage;
  month: TwelveStage;
  day: TwelveStage;
  hour: TwelveStage;
}

/** 12운성 이중표기 (primary = 일간 vs 지지 / jiJangGanMain = 지장간 본기 stem vs 지지) */
export interface TwelveStageDual {
  primary: TwelveStage;
  jiJangGanMain: TwelveStage;
}

/** 4주별 12운성 이중표기 */
export interface TwelveStagesDualResult {
  year: TwelveStageDual;
  month: TwelveStageDual;
  day: TwelveStageDual;
  hour: TwelveStageDual;
}

/** 4주별 납음오행 */
export interface NapEumResult {
  year: string;
  month: string;
  day: string;
  hour: string;
}

/** 4주별 지장간 */
export interface JiJangGanResult {
  year: JiJangGanEntry[];
  month: JiJangGanEntry[];
  day: JiJangGanEntry[];
  hour: JiJangGanEntry[];
}

/** 주 이름 */
export type PillarName = 'year' | 'month' | 'day' | 'hour';

/** 지지 관계 타입 */
export type InteractionType =
  | '삼합' | '육합' | '방합'
  | '육충' | '삼형' | '자형'
  | '육파' | '육해'
  | '원진' | '귀문';

/** 지지 관계 엔트리 */
export interface InteractionEntry {
  pair: [PillarName, PillarName];
  branches: [BranchKr, BranchKr];
  type: InteractionType;
  /** 결과 오행 (합일 때만) */
  resultElement?: Element;
}

/** 공망 */
export interface VoidResult {
  /** 년주 기준 공망 2지지 */
  year: [BranchKr, BranchKr];
  /** 일주 기준 공망 2지지 */
  day: [BranchKr, BranchKr];
}

/** 신살 이름 (20종) */
export type StarName =
  | '천을귀인' | '천덕귀인' | '월덕귀인' | '태극귀인'
  | '문창귀인' | '암록'     | '협록'     | '관귀학관'
  | '양인살'   | '백호살'   | '괴강살'   | '홍염살'
  | '현침살'   | '화개살'   | '역마살'   | '도화살'
  | '망신살'   | '겁살'     | '지살'     | '반안살';

/** 4주별 신살 */
export interface StarsResult {
  year: StarName[];
  month: StarName[];
  day: StarName[];
  hour: StarName[];
}

/** 12신살 (년지 기준 지지 고정 매핑) */
export type TwelveSpirit =
  | '겁살' | '재살' | '천살' | '지살'
  | '연살' | '월살' | '망신' | '장성'
  | '반안' | '역마' | '육해' | '화개';

/** 4주별 12신살 */
export interface TwelveSpiritsResult {
  year: TwelveSpirit;
  month: TwelveSpirit;
  day: TwelveSpirit;
  hour: TwelveSpirit;
}

/** 기둥별 상세 합충형파해 관계 */
export interface BranchRelation {
  /** 상대방 기둥 */
  target: PillarName;
  /** 상대방 지지 한글 */
  targetBranchKr: BranchKr;
  /** 관계 타입 */
  type: InteractionType;
  /** UI 짧은 라벨 (예: 합/충/형/파/해/방합/원진,귀문) */
  shortLabel: string;
}

/** 4주별 상세 관계 리스트 */
export interface BranchRelationsResult {
  year: BranchRelation[];
  month: BranchRelation[];
  day: BranchRelation[];
  hour: BranchRelation[];
}

/** 기둥별 공망 플래그 */
export interface VoidFlag {
  /** 해당 기둥 지지가 년주 공망에 포함 */
  yearVoid: boolean;
  /** 해당 기둥 지지가 일주 공망에 포함 */
  dayVoid: boolean;
}

/** 4주별 공망 플래그 */
export interface VoidFlagsResult {
  year: VoidFlag;
  month: VoidFlag;
  day: VoidFlag;
  hour: VoidFlag;
}

/** 귀인(Noble) — 천을귀인 지지 + 월령(월주 천간) */
export interface NobleStarsResult {
  /** 천을귀인 지지(일간 기준) — 2개 */
  cheoneul: BranchKr[];
  /** 월령 — 월주 천간 */
  wollyeong: StemKr;
}

/** 대운 1개 */
export interface LuckCycle {
  startAge: number;
  stem: StemKr;
  branch: BranchKr;
  korean: string;
  hanja: string;
  tenGod: TenGod;
  twelveStage: TwelveStage;
  /** 지지 십성 (일간 vs 대운 지지 본기) — 벤치마크 parity */
  branchTenGod?: TenGod;
  /** 년지 기준 12신살 */
  twelveSpirit?: TwelveSpirit;
  /** 일지 기준 12신살 */
  twelveSpiritByDay?: TwelveSpirit;
}

/** 세운 1개 (1년) */
export interface YearlyLuck {
  year: number;
  stem: StemKr;
  branch: BranchKr;
  korean: string;
  hanja: string;
  tenGod: TenGod;
  /** 지지 십성 (일간 vs 세운 지지 본기) */
  branchTenGod?: TenGod;
  /** 12운성 (일간 vs 세운 지지) */
  twelveStage?: TwelveStage;
  /** 년지 기준 12신살 */
  twelveSpirit?: TwelveSpirit;
  /** 일지 기준 12신살 */
  twelveSpiritByDay?: TwelveSpirit;
}

/** 월운 1개 */
export interface MonthlyLuck {
  month: number; // 1-12
  stem: StemKr;
  branch: BranchKr;
  korean: string;
  hanja: string;
  tenGod: TenGod;
  /** 지지 십성 */
  branchTenGod?: TenGod;
  /** 12운성 */
  twelveStage?: TwelveStage;
  /** 년지 기준 12신살 */
  twelveSpirit?: TwelveSpirit;
  /** 일지 기준 12신살 */
  twelveSpiritByDay?: TwelveSpirit;
}

/** 대운 전체 */
export interface LuckCyclesResult {
  startAge: number;
  direction: '순행' | '역행';
  cycles: LuckCycle[];        // 10개 (10년 단위)
  yearlyLucks: YearlyLuck[];  // 현재 ±5년 (11개)
  monthlyLucks: MonthlyLuck[]; // 해당 년 12개월
  currentYear: number;
}

/** 오행 분포 */
export interface ElementsResult {
  wood: number;
  fire: number;
  earth: number;
  metal: number;
  water: number;
  strongest: Element;
  weakest: Element;
  /** 밸런스 점수 0~100 */
  balanceScore: number;
}

/** 입력 */
export interface SajuInput {
  /** YYYY-MM-DD */
  birthDate: string;
  /** HH:mm, 선택 — 생략시 '00:00' */
  birthTime?: string;
  /** 음력 여부 */
  isLunar?: boolean;
  /** 성별 */
  gender: Gender;
  /** 현재 연도 (세운 계산용) — 생략시 birthDate의 년도 + 30세 */
  referenceYear?: number;
}

/** 메인 결과 */
export interface SajuResult {
  input: SajuInput;
  dayMaster: Stem;
  pillars: FourPillars;
  tenGods: TenGodsResult;
  twelveStages: TwelveStagesResult;
  /** 12운성 이중표기 (primary + jiJangGanMain) — 벤치마크 parity */
  twelveStagesDual?: TwelveStagesDualResult;
  napEum: NapEumResult;
  jiJangGan: JiJangGanResult;
  interactions: InteractionEntry[];
  /** 기둥별 상세 관계 리스트 — 벤치마크 parity */
  branchRelations?: BranchRelationsResult;
  voids: VoidResult;
  /** 기둥별 공망 플래그 — 벤치마크 parity */
  voidFlags?: VoidFlagsResult;
  stars: StarsResult;
  twelveSpirits: TwelveSpiritsResult;
  /** 일지 기준 12신살 — 벤치마크 parity */
  twelveSpiritsByDay?: TwelveSpiritsResult;
  nobleStars: NobleStarsResult;
  luckCycles: LuckCyclesResult;
  elements: ElementsResult;
}
