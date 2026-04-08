import type { FortuneTypeId } from '@fortune/product-contracts';

import type {
  MetricTileData,
  ResultKind,
  TimelineEntry,
} from '../fortune-results/types';

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

export interface EmbeddedResultDetailSection {
  title: string;
  body: string;
  score?: number;
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
  timeline?: TimelineEntry[];
  highlights?: string[];
  recommendations?: string[];
  warnings?: string[];
  luckyItems?: string[];
  specialTip?: string;
  detailSections?: EmbeddedResultDetailSection[];
}
