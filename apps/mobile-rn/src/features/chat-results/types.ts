import type { FortuneTypeId } from '@fortune/product-contracts';

import type { ManseryeokLocalData } from '../../lib/manseryeok-local';
import type { MetricTileData, ResultKind } from '../fortune-results/types';

export type EmbeddedResultWidgetType = 'fortune_result_card';

export interface EmbeddedResultProfileContext {
  displayName?: string;
  birthDate?: string;
  birthTime?: string;
  mbti?: string;
  bloodType?: string;
}

export interface EmbeddedResultBuildContext {
  answers?: Record<string, unknown>;
  characterName?: string;
  profile?: EmbeddedResultProfileContext;
}

// Hero-specific fields consumed by Phase 3b hero components. Each is
// optional; when absent the hero gracefully falls back to placeholder art.
// The adapter (`features/chat-results/adapter.ts`) should populate these
// for the matching fortuneType once each domain's result payload contract
// is finalized — until then the heroes render with sane defaults.

export interface TarotSpreadCard {
  name: string;
  suit?: string;
  meaning?: string;
  position?: string;
  art?: string;
}

export type SajuElementKey = 'wood' | 'fire' | 'earth' | 'metal' | 'water';

export interface SajuPillar {
  label: string;
  sky: string;
  gnd: string;
  skyEl: SajuElementKey;
  gndEl: SajuElementKey;
}

export interface CalendarFace {
  ganji?: string;
  lunar?: string;
  season?: string;
}

export interface TimelinePoint {
  label: string;
  value: number;
}

export interface RadarTrait {
  label: string;
  value: number;
}

export interface CompatMetric {
  label: string;
  score: number;
}

export interface CompatData {
  leftLabel: string;
  rightLabel: string;
  metrics: CompatMetric[];
}

export interface HealthZone {
  region: 'head' | 'chest' | 'belly' | 'lower';
  score: number;
}

export interface EmbeddedResultPayload {
  widgetType: EmbeddedResultWidgetType;
  fortuneType: FortuneTypeId;
  resultKind: ResultKind;
  eyebrow: string;
  title: string;
  subtitle: string;
  summary: string;
  score?: number;
  contextTags?: string[];
  metrics?: MetricTileData[];
  highlights?: string[];
  recommendations?: string[];
  warnings?: string[];
  luckyItems?: string[];
  specialTip?: string;
  /** Local manseryeok data, attached when fortuneType is daily-calendar */
  manseryeok?: ManseryeokLocalData;
  /** Raw API response for fortune types with rich domain-specific data */
  rawApiResponse?: Record<string, unknown>;

  // --- Hero-specific visualization fields (Phase 3b) ---
  /** HeroTarot — 3-card spread. */
  spread?: TarotSpreadCard[];
  /** HeroSaju — 4 pillars (년/월/일/시) for the stamp-in visual. */
  pillars?: SajuPillar[];
  /** HeroSaju — 5-element ratios (0–100). */
  elements?: Partial<Record<SajuElementKey, number>>;
  /** HeroCalendar — Korean calendar face (ganji / lunar / season). */
  cal?: CalendarFace;
  /** HeroCalendar — raw lunar date (redundant w/ cal.lunar). */
  lunar?: string;
  /** HeroCalendar — raw seasonal marker (redundant w/ cal.season). */
  season?: string;
  /** HeroLine — trend timeline for wealth/career/exam etc. */
  timeline?: TimelinePoint[];
  /** HeroRadar — 6 traits for personality-dna / mbti. */
  traits?: RadarTrait[];
  /** HeroCompat — compatibility two-party metrics. */
  compat?: CompatData;
  /** HeroHealth — regional zone scores. */
  zones?: HealthZone[];
}
