import type { FortuneTypeId } from '@fortune/product-contracts';

export const resultKinds = [
  'traditional-saju',
  'daily-calendar',
  'mbti',
  'blood-type',
  'zodiac-animal',
  'constellation',
  'career',
  'love',
  'health',
  'coaching',
  'family',
  'past-life',
  'wish',
  'personality-dna',
  'wealth',
  'talent',
  'exercise',
  'tarot',
  'game-enhance',
  'ootd-evaluation',
] as const;

export type ResultKind = (typeof resultKinds)[number];

export type ResultRouteSource =
  | 'chat-action'
  | 'deeplink'
  | 'recent-card'
  | 'direct';

export interface ResultRouteParams {
  resultKind: ResultKind;
  characterId?: string;
  source?: ResultRouteSource;
}

export interface ResultMetadata {
  resultKind: ResultKind;
  fortuneCode: string;
  paperNodeId: string;
  title: string;
  subtitle: string;
  eyebrow: string;
}

export interface MetricTileData {
  label: string;
  value: string;
  note?: string;
}

export interface StatRailData {
  label: string;
  value: number;
  highlight?: string;
}

export interface TimelineEntry {
  title: string;
  body: string;
  tag?: string;
}

export interface DoDontData {
  doTitle?: string;
  doItems: string[];
  dontTitle?: string;
  dontItems: string[];
}

export type FortuneTypeToResultKind = Partial<
  Record<FortuneTypeId, ResultKind>
>;

export function isResultKind(value: string): value is ResultKind {
  return (resultKinds as readonly string[]).includes(value);
}
