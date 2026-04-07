import type { FortuneTypeId } from '@fortune/product-contracts';

import { extractCohort, generateCohortHash, type CohortData } from './cohort-helpers';
import { supabase } from './supabase';

/**
 * Fortune service - mirrors Flutter's UnifiedFortuneService.
 *
 * Optimization pipeline (72-90% API cost reduction):
 * 1. Personal cache check → fortune_history table
 * 2. Cohort pool lookup → cohort_fortune_pool table
 * 3. Edge Function call (only if 1 & 2 miss)
 * 4. Save result to DB
 */

export interface FortuneResultData {
  id?: string;
  fortuneType: FortuneTypeId;
  title: string;
  summary: string;
  score?: number;
  data: Record<string, unknown>;
  source: 'personal-cache' | 'cohort-pool' | 'api' | 'fixture';
}

export interface FortuneRequestContext {
  userId?: string;
  birthDate?: string;
  birthTime?: string;
  mbti?: string;
  bloodType?: string;
  gender?: string;
  answers: Record<string, unknown>;
}

// ─── Main entry point ────────────────────────────────────────────

export async function getFortuneResult(
  fortuneType: FortuneTypeId,
  context: FortuneRequestContext,
): Promise<FortuneResultData> {
  const userId = context.userId ?? null;

  // Step 1: Check personal cache
  if (userId && supabase) {
    const cached = await checkPersonalCache(userId, fortuneType, context);
    if (cached) {
      return { ...cached, source: 'personal-cache' };
    }
  }

  // Step 2: Check cohort pool
  if (supabase) {
    const cohortResult = await checkCohortPool(fortuneType, context);
    if (cohortResult) {
      // Save to personal cache for next time
      if (userId) {
        void saveFortuneResult(userId, fortuneType, cohortResult, context).catch(
          () => undefined,
        );
      }
      return { ...cohortResult, source: 'cohort-pool' };
    }
  }

  // Step 3: Call Edge Function
  if (supabase) {
    const apiResult = await callEdgeFunction(fortuneType, context);
    if (apiResult) {
      // Save to DB
      if (userId) {
        void saveFortuneResult(userId, fortuneType, apiResult, context).catch(
          () => undefined,
        );
      }
      return { ...apiResult, source: 'api' };
    }
  }

  // Step 4: Fallback to fixture (no Supabase connection)
  return buildFixtureFallback(fortuneType, context);
}

// ─── Step 1: Personal cache ──────────────────────────────────────

async function checkPersonalCache(
  userId: string,
  fortuneType: FortuneTypeId,
  context: FortuneRequestContext,
): Promise<FortuneResultData | null> {
  if (!supabase) return null;

  try {
    const today = new Date().toISOString().slice(0, 10);

    const { data, error } = await supabase
      .from('fortune_history')
      .select('result_data, title, score')
      .eq('user_id', userId)
      .eq('fortune_type', fortuneType)
      .gte('created_at', `${today}T00:00:00`)
      .order('created_at', { ascending: false })
      .limit(1)
      .maybeSingle();

    if (error || !data) return null;

    const resultData = (data.result_data ?? {}) as Record<string, unknown>;

    return {
      fortuneType,
      title: (data.title as string) ?? '결과',
      summary: (resultData['summary'] as string) ?? '',
      score: typeof data.score === 'number' ? data.score : undefined,
      data: resultData,
    };
  } catch {
    return null;
  }
}

// ─── Step 2: Cohort pool ─────────────────────────────────────────

async function checkCohortPool(
  fortuneType: FortuneTypeId,
  context: FortuneRequestContext,
): Promise<FortuneResultData | null> {
  if (!supabase) return null;

  try {
    const cohortData = extractCohort(fortuneType, {
      birthDate: context.birthDate,
      birthTime: context.birthTime,
      mbti: context.mbti,
      bloodType: context.bloodType,
      gender: context.gender,
      answers: context.answers,
    });

    if (Object.keys(cohortData).length === 0) return null;

    const cohortHash = generateCohortHash(cohortData);

    const { data, error } = await supabase.rpc('get_random_cohort_result', {
      p_fortune_type: fortuneType,
      p_cohort_hash: cohortHash,
    });

    if (error || !data) return null;

    const result = data as Record<string, unknown>;

    // Personalize placeholders
    const personalized = personalizeCohortResult(result, context);

    return {
      fortuneType,
      title: (personalized['title'] as string) ?? '결과',
      summary: (personalized['summary'] as string) ?? '',
      score: typeof personalized['score'] === 'number'
        ? personalized['score']
        : undefined,
      data: personalized,
    };
  } catch {
    return null;
  }
}

function personalizeCohortResult(
  template: Record<string, unknown>,
  context: FortuneRequestContext,
): Record<string, unknown> {
  const displayName = context.answers['userName'] as string | undefined;
  const result: Record<string, unknown> = {};

  for (const [key, value] of Object.entries(template)) {
    if (typeof value === 'string' && displayName) {
      result[key] = value.replace(/\{\{userName\}\}/g, displayName);
    } else {
      result[key] = value;
    }
  }

  return result;
}

// ─── Step 3: Edge Function ───────────────────────────────────────

async function callEdgeFunction(
  fortuneType: FortuneTypeId,
  context: FortuneRequestContext,
): Promise<FortuneResultData | null> {
  if (!supabase) return null;

  try {
    const payload = {
      fortuneType,
      birthDate: context.birthDate,
      birthTime: context.birthTime,
      mbti: context.mbti,
      bloodType: context.bloodType,
      ...context.answers,
    };

    const { data, error } = await supabase.functions.invoke(
      `generate-${fortuneType}`,
      { body: payload },
    );

    if (error || !data) {
      // Try generic fortune endpoint
      const fallback = await supabase.functions.invoke('generate-fortune', {
        body: payload,
      });

      if (fallback.error || !fallback.data) return null;

      const result = fallback.data as Record<string, unknown>;
      return {
        fortuneType,
        title: (result['title'] as string) ?? '결과',
        summary: (result['summary'] as string) ?? '',
        score: typeof result['score'] === 'number' ? result['score'] : undefined,
        data: result,
      };
    }

    const result = data as Record<string, unknown>;
    return {
      fortuneType,
      title: (result['title'] as string) ?? '결과',
      summary: (result['summary'] as string) ?? '',
      score: typeof result['score'] === 'number' ? result['score'] : undefined,
      data: result,
    };
  } catch {
    return null;
  }
}

// ─── Step 4: Save to DB ──────────────────────────────────────────

async function saveFortuneResult(
  userId: string,
  fortuneType: FortuneTypeId,
  result: FortuneResultData,
  context: FortuneRequestContext,
): Promise<void> {
  if (!supabase) return;

  try {
    // Save to fortune_history
    await supabase.from('fortune_history').insert({
      user_id: userId,
      fortune_type: fortuneType,
      title: result.title,
      score: result.score ?? null,
      result_data: result.data,
      conditions: {
        birthDate: context.birthDate,
        birthTime: context.birthTime,
        mbti: context.mbti,
        bloodType: context.bloodType,
        ...context.answers,
      },
      source: result.source,
    });

    // Also save to fortune_results for optimization service
    const cohortData = extractCohort(fortuneType, {
      birthDate: context.birthDate,
      answers: context.answers,
    });
    const conditionsHash = generateCohortHash(cohortData);

    await supabase.from('fortune_results').upsert(
      {
        fortune_type: fortuneType,
        conditions_hash: conditionsHash,
        result_data: result.data,
        user_id: userId,
      },
      { onConflict: 'fortune_type,conditions_hash,user_id' },
    );
  } catch {
    // Silently fail - result is already returned to user
  }
}

// ─── Fixture fallback ────────────────────────────────────────────

function buildFixtureFallback(
  fortuneType: FortuneTypeId,
  context: FortuneRequestContext,
): FortuneResultData {
  return {
    fortuneType,
    title: '결과',
    summary: '',
    data: {},
    source: 'fixture',
  };
}
