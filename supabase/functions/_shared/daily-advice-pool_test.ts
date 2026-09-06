import { assertEquals, assertNotEquals, assertRejects } from 'https://deno.land/std@0.224.0/assert/mod.ts';
import { dailyAdviceHash, isDailyAdvice, resolveDailyAdvice, type DailyAdvice } from './daily-advice-pool.ts';

const advice = { description: '차분히 시작해요', detail: '오늘은 서두르기보다 한 가지 일부터 차분히 정리해 보세요. 할 일을 작게 나누면 부담을 줄이고 집중하기 좋습니다.' };
const fallback = () => ({ description: '잠시 쉬어가요', detail: '지금은 천천히 호흡하며 가장 작은 일부터 시작해 보세요. 물 한 잔을 마시고 오늘 꼭 필요한 한 가지를 골라보세요.' });

Deno.test('keys distinguish every prompt condition without accepting identities', async () => {
  const key = await dailyAdviceHash('love', 80);
  assertEquals(key, await dailyAdviceHash('love', 80));
  assertNotEquals(key, await dailyAdviceHash('money', 80));
  assertNotEquals(key, await dailyAdviceHash('love', 81));
  assertNotEquals(await dailyAdviceHash('total', 80, '유유자적'), await dailyAdviceHash('total', 80, '일취월장'));
  await assertRejects(() => dailyAdviceHash('private-name', 80));
  await assertRejects(() => dailyAdviceHash('love', NaN));
  await assertRejects(() => dailyAdviceHash('total', 80));
});

Deno.test('only bounded advice fragments pass validation, never a personal fortune object', () => {
  assertEquals(isDailyAdvice(advice, 'love'), true);
  assertEquals(isDailyAdvice({ ...advice, userId: 'someone' }, 'love'), false);
  assertEquals(isDailyAdvice({ ...advice, detail: '{{userName}}님' }, 'love'), false);
  assertEquals(isDailyAdvice({ ...advice, detail: advice.detail + ' person@example.com' }, 'love'), false);
  assertEquals(isDailyAdvice('too short', 'total'), false);
});

Deno.test('three completed samples warm the pool; all subsequent reads make zero model calls', async () => {
  const variants: DailyAdvice[] = [];
  let generations = 0;
  const client = { rpc: async (name: string, args: Record<string, unknown>) => {
    if (name === 'claim_daily_advice') return { error: null, data: variants.length < 3 ? { action: 'generate', leaseToken: 'lease' } : { action: 'hit', advice: variants[0] } };
    variants.push(args.p_advice as DailyAdvice);
    return { error: null, data: true };
  } };
  const run = () => resolveDailyAdvice({ client, category: 'love', score: 80, fallback, generate: async () => { generations++; return advice; } });
  for (let index = 0; index < 3; index++) assertEquals((await run()).source, 'generated');
  for (let index = 0; index < 10; index++) assertEquals((await run()).source, 'pool');
  assertEquals(generations, 3);
  assertEquals(variants.length, 3);
});

Deno.test('busy, missing migration, corrupt cached data and database exceptions do not call the model', async () => {
  for (const response of [
    { data: { action: 'busy' }, error: null },
    { data: null, error: { code: 'PGRST202' } },
    { data: { action: 'hit', advice: { ...advice, name: 'other user' } }, error: null },
    { data: null, error: null },
  ]) {
    let calls = 0;
    const result = await resolveDailyAdvice({ client: { rpc: async () => response }, category: 'love', score: 80, fallback, generate: async () => { calls++; return advice; } });
    assertEquals(result.source, 'fallback');
    assertEquals(calls, 0);
  }
  const result = await resolveDailyAdvice({ client: { rpc: () => { throw new Error('offline'); } }, category: 'love', score: 80, fallback, generate: () => { throw new Error('must not run'); } });
  assertEquals(result.source, 'fallback');
});

Deno.test('failed or invalid generation releases its lease and never stores the fallback', async () => {
  for (const generate of [async () => { throw new Error('provider offline'); }, async () => 'invalid']) {
    const completions: unknown[] = [];
    const client = { rpc: async (name: string, args: Record<string, unknown>) => {
      if (name === 'claim_daily_advice') return { data: { action: 'generate', leaseToken: 'lease' }, error: null };
      completions.push(args.p_advice);
      return { data: true, error: null };
    } };
    const result = await resolveDailyAdvice({ client, category: 'love', score: 80, fallback, generate });
    assertEquals(result.source, 'fallback');
    assertEquals(completions, [null]);
  }
});

Deno.test('lost persistence returns validated advice to the current user', async () => {
  const client = { rpc: async (name: string) => name === 'claim_daily_advice'
    ? { data: { action: 'generate', leaseToken: 'lease' }, error: null }
    : { data: false, error: null } };
  const result = await resolveDailyAdvice({ client, category: 'love', score: 80, fallback, generate: async () => advice });
  assertEquals(result, { advice, source: 'generated' });
});
