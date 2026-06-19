import { describe, expect, it } from 'vitest';

import {
  isAuthCallbackUrl,
  normalizeFortuneTypeForChat,
  resolveDeepLink,
} from './deep-links';

describe('deep link contracts', () => {
  it('recognizes auth callbacks', () => {
    expect(
      isAuthCallbackUrl(
        new URL('com.beyond.fortune://auth-callback#access_token=test-token'),
      ),
    ).toBe(true);
  });

  it('routes shared chat intents to chat and preserves fortune type', () => {
    const resolution = resolveDeepLink(
      'com.beyond.fortune://share?screen=chat&fortuneType=love',
    );

    expect(resolution.route).toBe('/chat');
    expect(resolution.fortuneType).toBe('love');
  });

  it('normalizes legacy fortune aliases without overriding valid current types', () => {
    expect(normalizeFortuneTypeForChat('sports-game')).toBe('match-insight');
    expect(normalizeFortuneTypeForChat('investment')).toBe('wealth');
    expect(normalizeFortuneTypeForChat('health')).toBe('health');
    expect(normalizeFortuneTypeForChat('unknown-type')).toBeNull();
  });

  it('routes legacy widget fortune character IDs to the Haneul chat thread', () => {
    const resolution = resolveDeepLink(
      'com.beyond.fortune://widget?screen=chat&characterId=fortune_haneul&fortuneType=daily',
    );

    expect(resolution.route).toBe('/chat?characterId=haneul_oracle');
    expect(resolution.fortuneType).toBe('daily');
    expect(resolution.characterId).toBe('haneul_oracle');
  });

  it('preserves all iOS widget result fortune types when routing to Haneul', () => {
    const widgetLinks = [
      ['daily', 'daily'],
      ['love', 'love'],
      ['tarot', 'tarot'],
      ['constellation', 'constellation'],
      ['dream', 'dream'],
      ['health', 'health'],
      ['lucky-items', 'lucky-items'],
      ['wealth', 'wealth'],
      ['weekly-review', 'weekly-review'],
    ] as const;

    for (const [input, expected] of widgetLinks) {
      const resolution = resolveDeepLink(
        `com.beyond.fortune://widget?screen=chat&characterId=fortune_haneul&fortuneType=${input}`,
      );

      expect(resolution.route).toBe('/chat?characterId=haneul_oracle');
      expect(resolution.fortuneType).toBe(expected);
      expect(resolution.characterId).toBe('haneul_oracle');
    }
  });
});
