import { assertEquals } from 'https://deno.land/std@0.224.0/assert/mod.ts';
import { economyRoute } from './economy.ts';
import { resolvePlatformLlmRoute } from './routing.ts';

Deno.test('basic names and deployed aliases select the bounded text model', () => {
  for (const feature of ['daily', 'fortune-biorhythm', 'fortune-lucky-items', 'tarot', 'wealth']) {
    assertEquals(economyRoute(feature, 'openrouter')?.model, 'google/gemini-2.5-flash-lite');
    assertEquals(economyRoute(feature, 'gemini')?.model, 'gemini-2.5-flash-lite');
    assertEquals(economyRoute(feature, 'openrouter')?.fallbackModel, 'gemini-2.5-flash-lite');
  }
});

Deno.test('premium, vision, conversation and unknown features retain configured routes', () => {
  for (const feature of ['traditional-saju', 'face-reading', 'past-life', 'talisman', 'character-chat', 'unknown']) {
    assertEquals(economyRoute(feature, 'openrouter'), null);
  }
});

Deno.test('economy respects shadow and missing-key routes while bounding expensive defaults', () => {
  for (const mode of ['legacy', 'shadow', 'openrouter'] as const) {
    for (const hasOpenRouterKey of [false, true]) {
      const route = resolvePlatformLlmRoute({
        featureName: 'daily', requestedProvider: 'anthropic', requestedModel: 'claude-opus-4',
        mode, hasOpenRouterKey,
      });
      const economy = economyRoute('daily', route.provider);
      assertEquals(economy?.provider, mode === 'openrouter' && hasOpenRouterKey ? 'openrouter' : 'gemini');
      assertEquals(economy?.model.includes('gemini-2.5-flash-lite'), true);
    }
  }
});
