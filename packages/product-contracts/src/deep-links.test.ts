import { describe, expect, it } from 'vitest';

import { isAuthCallbackUrl, resolveDeepLink } from './deep-links';

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
});
