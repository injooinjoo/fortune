export const DAILY_ADVICE_VERSION = 'daily-advice-v1';
export const DAILY_ADVICE_TARGET_SIZE = 3;
export const DAILY_ADVICE_CATEGORIES = ['total', 'love', 'money', 'work', 'study', 'health'] as const;
export type DailyAdviceCategory = typeof DAILY_ADVICE_CATEGORIES[number];
export type DailyAdvice = string | { description: string; detail: string };
export type DailyAdviceSource = 'pool' | 'generated' | 'fallback';

interface RpcClient {
  rpc(name: string, args: Record<string, unknown>): PromiseLike<{ data: unknown; error: unknown }>;
}

function isCategory(value: string): value is DailyAdviceCategory {
  return (DAILY_ADVICE_CATEGORIES as readonly string[]).includes(value);
}

/** Only values used by the common prompt enter the key. No user input/identity. */
export async function dailyAdviceHash(category: string, score: number, idiom?: string): Promise<string> {
  if (!isCategory(category) || !Number.isInteger(score) || score < 0 || score > 100) {
    throw new Error('Invalid daily advice condition');
  }
  if (category === 'total' && (!idiom || idiom.length > 40)) {
    throw new Error('Missing daily advice idiom');
  }
  const condition = JSON.stringify([DAILY_ADVICE_VERSION, category, score, category === 'total' ? idiom : null]);
  const digest = await crypto.subtle.digest('SHA-256', new TextEncoder().encode(condition));
  return Array.from(new Uint8Array(digest), (byte) => byte.toString(16).padStart(2, '0')).join('');
}

function validText(value: unknown, min: number, max: number): value is string {
  return typeof value === 'string' && value.trim().length >= min && value.length <= max &&
    !/\{\{|\}\}|https?:\/\/|[\w.+-]+@[\w.-]+\.[a-z]{2,}/i.test(value);
}

export function isDailyAdvice(value: unknown, category: string): value is DailyAdvice {
  if (category === 'total') return validText(value, 60, 2400);
  if (!isCategory(category) || !value || typeof value !== 'object' || Array.isArray(value)) return false;
  const advice = value as Record<string, unknown>;
  return Object.keys(advice).length === 2 && validText(advice.description, 2, 15) && validText(advice.detail, 40, 1800);
}

/** A cache/database failure does not fan out into paid calls for a basic reading. */
export async function resolveDailyAdvice(input: {
  client: RpcClient;
  category: string;
  score: number;
  idiom?: string;
  generate: () => Promise<DailyAdvice>;
  fallback: () => DailyAdvice;
}): Promise<{ advice: DailyAdvice; source: DailyAdviceSource }> {
  let hash: string | undefined;
  let leaseToken: string | undefined;
  try {
    hash = await dailyAdviceHash(input.category, input.score, input.idiom);
    const { data, error } = await input.client.rpc('claim_daily_advice', {
      p_condition_hash: hash, p_prompt_version: DAILY_ADVICE_VERSION,
    });
    if (error) throw new Error('Daily advice pool unavailable', { cause: error });
    if (!data || typeof data !== 'object') throw new Error('Invalid pool claim');
    const claim = data as Record<string, unknown>;
    if (claim.action === 'hit') {
      if (!isDailyAdvice(claim.advice, input.category)) throw new Error('Invalid pooled advice');
      return { advice: claim.advice, source: 'pool' };
    }
    if (claim.action === 'busy') return { advice: input.fallback(), source: 'fallback' };
    if (claim.action !== 'generate' || typeof claim.leaseToken !== 'string') {
      throw new Error('Invalid generation lease');
    }
    leaseToken = claim.leaseToken;
    const advice = await input.generate();
    if (!isDailyAdvice(advice, input.category)) throw new Error('Generated advice failed validation');
    const saved = await input.client.rpc('complete_daily_advice', {
      p_condition_hash: hash, p_prompt_version: DAILY_ADVICE_VERSION,
      p_lease_token: leaseToken, p_advice: advice,
    });
    if (saved.error || saved.data !== true) {
      // The current user may still receive valid advice if persistence failed.
      console.warn('[daily-advice-pool] Generated advice was not persisted');
    }
    return { advice, source: 'generated' };
  } catch (error) {
    console.warn('[daily-advice-pool] Using built-in advice:', error instanceof Error ? error.message : 'unknown error');
    if (hash && leaseToken) {
      try {
        const released = await input.client.rpc('complete_daily_advice', {
          p_condition_hash: hash, p_prompt_version: DAILY_ADVICE_VERSION,
          p_lease_token: leaseToken, p_advice: null,
        });
        if (released.error) console.warn('[daily-advice-pool] Lease release failed; it will expire');
      } catch {
        console.warn('[daily-advice-pool] Lease release unavailable; it will expire');
      }
    }
    return { advice: input.fallback(), source: 'fallback' };
  }
}
