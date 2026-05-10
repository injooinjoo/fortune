import { describe, expect, it } from 'vitest';

import {
  emptyUnifiedOnboardingProgress,
  normalizeUnifiedOnboardingProgress,
  resolveChatOnboardingGate,
} from './onboarding';

describe('onboarding contracts', () => {
  it('lets guests without soft gate completion enter chat', () => {
    expect(
      resolveChatOnboardingGate({
        hasAuthenticatedUser: false,
        progress: emptyUnifiedOnboardingProgress,
      }),
    ).toBe('ready');
  });

  it('sends authenticated users with incomplete profile data to profile flow', () => {
    expect(
      resolveChatOnboardingGate({
        hasAuthenticatedUser: true,
        progress: normalizeUnifiedOnboardingProgress({
          softGateCompleted: true,
          authCompleted: true,
          birthCompleted: true,
          interestCompleted: false,
          firstRunHandoffSeen: false,
        }),
      }),
    ).toBe('profile-flow');
  });

  it('keeps chat unlocked once guest soft gate is done', () => {
    expect(
      resolveChatOnboardingGate({
        hasAuthenticatedUser: false,
        progress: normalizeUnifiedOnboardingProgress({
          softGateCompleted: true,
        }),
      }),
    ).toBe('ready');
  });
});
