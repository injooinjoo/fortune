import type { FortuneTypeId } from '@fortune/product-contracts';

import type { MetricTileData, ResultKind } from '../fortune-results/types';

export type EmbeddedResultWidgetType = 'fortune_result_card';

export interface EmbeddedResultProfileContext {
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
}
