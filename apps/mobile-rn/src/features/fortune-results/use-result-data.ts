import { useMemo } from 'react';

import type { EmbeddedResultPayload } from '../chat-results/types';
import type { MetricTileData } from './types';

export interface ResultData {
  /** Overall score (0-100). `undefined` when the API did not provide one. */
  score: number | undefined;
  /** Plain-text summary paragraph. */
  summary: string;
  /** Metric tiles (e.g. label/value/note triples). */
  metrics: MetricTileData[];
  /** Key insight bullet points. */
  highlights: string[];
  /** Recommended actions. */
  recommendations: string[];
  /** Warning / caution points. */
  warnings: string[];
  /** Lucky items / keywords. */
  luckyItems: string[];
  /** A single special tip quote. */
  specialTip: string | undefined;
  /** Context tags derived from the user's survey answers. */
  contextTags: string[];
  /** Whether real API data is present (vs. fallback placeholder). */
  hasApiData: boolean;
}

const EMPTY_ARRAY: readonly string[] = [];
const EMPTY_METRICS: readonly MetricTileData[] = [];

/**
 * Extract common fields from an `EmbeddedResultPayload` with typed access
 * and safe fallbacks.  Components call this hook and conditionally render
 * API data when `hasApiData` is true, falling back to their existing
 * hardcoded content otherwise.
 *
 * ```ts
 * function MyResult({ payload }: FortuneResultComponentProps) {
 *   const data = useResultData(payload);
 *   // data.hasApiData === true  →  render data.highlights, data.metrics, etc.
 *   // data.hasApiData === false →  render hardcoded placeholder content
 * }
 * ```
 */
export function useResultData(payload?: EmbeddedResultPayload): ResultData {
  return useMemo((): ResultData => {
    if (!payload) {
      return {
        score: undefined,
        summary: '',
        metrics: EMPTY_METRICS as MetricTileData[],
        highlights: EMPTY_ARRAY as string[],
        recommendations: EMPTY_ARRAY as string[],
        warnings: EMPTY_ARRAY as string[],
        luckyItems: EMPTY_ARRAY as string[],
        specialTip: undefined,
        contextTags: EMPTY_ARRAY as string[],
        hasApiData: false,
      };
    }

    return {
      score: payload.score,
      summary: payload.summary ?? '',
      metrics: payload.metrics ?? (EMPTY_METRICS as MetricTileData[]),
      highlights: payload.highlights ?? (EMPTY_ARRAY as string[]),
      recommendations: payload.recommendations ?? (EMPTY_ARRAY as string[]),
      warnings: payload.warnings ?? (EMPTY_ARRAY as string[]),
      luckyItems: payload.luckyItems ?? (EMPTY_ARRAY as string[]),
      specialTip: payload.specialTip,
      contextTags: payload.contextTags ?? (EMPTY_ARRAY as string[]),
      hasApiData: true,
    };
  }, [payload]);
}
