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

  it('normalizes legacy fortune aliases used by Flutter deep links', () => {
    expect(normalizeFortuneTypeForChat('sports-game')).toBe('match-insight');
    expect(normalizeFortuneTypeForChat('investment')).toBe('wealth');
    expect(normalizeFortuneTypeForChat('unknown-type')).toBeNull();
  });

  it('routes widget intents with characterId into the right chat thread', () => {
    const resolution = resolveDeepLink(
      'com.beyond.fortune://widget?screen=chat&characterId=fortune_haneul&fortuneType=daily',
    );

    expect(resolution.route).toBe('/chat?characterId=fortune_haneul');
    expect(resolution.fortuneType).toBe('daily');
    expect(resolution.characterId).toBe('fortune_haneul');
  });
});
