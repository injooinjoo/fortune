import { assert, assertRejects } from 'https://deno.land/std@0.224.0/assert/mod.ts';
import { GeminiProvider } from './gemini.ts';
import { OpenRouterProvider } from './openrouter.ts';

for (const Provider of [GeminiProvider, OpenRouterProvider]) {
  Deno.test(`${Provider.name} aborts a stalled response body before the pool lease expires`, async () => {
    const originalFetch = globalThis.fetch;
    let aborted = false;
    // No external request: headers arrive immediately, but the body hangs.
    globalThis.fetch = (_input, init) => {
      const signal = init?.signal;
      assert(signal, 'The provider must pass a request deadline');
      const body = new ReadableStream<Uint8Array>({
        start(controller) {
          signal.addEventListener('abort', () => {
            aborted = true;
            controller.error(signal.reason);
          }, { once: true });
        },
      });
      return Promise.resolve(new Response(body, { headers: { 'Content-Type': 'application/json' } }));
    };
    try {
      const provider = new Provider({
        apiKey: 'test-only', model: 'gemini-2.5-flash-lite',
        featureName: 'daily', billingOwner: 'user',
      });
      await assertRejects(() => provider.generate([{ role: 'user', content: 'test' }], { timeout: 1_000 }));
      assert(aborted, 'A stalled body must not keep generating after the lease');
    } finally {
      globalThis.fetch = originalFetch;
    }
  });
}
