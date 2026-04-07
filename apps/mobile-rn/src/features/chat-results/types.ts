import type { FortuneTypeId } from '@fortune/product-contracts';

import type { MetricTileData, ResultKind } from '../fortune-results/types';

export type EmbeddedResultWidgetType = 'fortune_result_card';

export interface EmbeddedResultPayload {
  widgetType: EmbeddedResultWidgetType;
  fortuneType: FortuneTypeId;
  resultKind: ResultKind;
  eyebrow: string;
  title: string;
  subtitle: string;
  summary: string;
  score?: number;
  metrics?: MetricTileData[];
  highlights?: string[];
  recommendations?: string[];
  warnings?: string[];
  luckyItems?: string[];
  specialTip?: string;
}
