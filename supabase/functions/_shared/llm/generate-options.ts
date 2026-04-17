/**
 * Normalizes GenerateOptions for provider calls.
 *
 * Why this file exists:
 *   53 call sites currently invoke `llm.generate(messages, options)` without
 *   setting `maxTokens`. Each provider then silently falls back to a provider-
 *   specific default (2_048 → 16_000). A malformed prompt under concurrency
 *   can burn thousands of dollars in minutes against an unbounded max.
 *
 * Near-term: log every missing-maxTokens call so the audit trail exists
 * before we tighten caller contracts.
 * Long-term: once every caller passes maxTokens explicitly, change this file
 * to throw on missing + delete the warning.
 */

import type { GenerateOptions } from './types.ts';

const HARD_UPPER_BOUND = 16_000;

export interface NormalizedGenerateOptions extends GenerateOptions {
  maxTokens: number;
}

export function normalizeGenerateOptions(
  options: GenerateOptions | undefined,
  opts: {
    providerDefault: number;
    featureName: string;
    providerName: string;
  },
): NormalizedGenerateOptions {
  const explicit = options?.maxTokens;
  let resolved = typeof explicit === 'number' && Number.isFinite(explicit)
    ? Math.round(explicit)
    : opts.providerDefault;

  // Clamp to a hard upper bound so a typo (e.g. 160000) can't blow up cost.
  if (resolved > HARD_UPPER_BOUND) {
    console.warn(
      `[llm:maxTokens] ${opts.providerName}/${opts.featureName} clamped ${resolved} → ${HARD_UPPER_BOUND}`,
    );
    resolved = HARD_UPPER_BOUND;
  }

  if (resolved < 1) {
    resolved = opts.providerDefault;
  }

  if (explicit == null) {
    console.warn(
      `[llm:maxTokens] ${opts.providerName}/${opts.featureName} missing explicit maxTokens, using default ${resolved}`,
    );
  }

  return {
    ...(options ?? {}),
    maxTokens: resolved,
  };
}
