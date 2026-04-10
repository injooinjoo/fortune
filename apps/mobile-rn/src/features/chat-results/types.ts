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
}
