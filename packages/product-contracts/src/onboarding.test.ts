import { describe, expect, it } from 'vitest';

import {
  emptyUnifiedOnboardingProgress,
  normalizeUnifiedOnboardingProgress,
  resolveChatOnboardingGate,
} from './onboarding';

describe('onboarding contracts', () => {
  it('sends guests without soft gate completion to auth entry', () => {
    expect(
      resolveChatOnboardingGate({
        hasAuthenticatedUser: false,
        progress: emptyUnifiedOnboardingProgress,
      }),
    ).toBe('auth-entry');
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

  it('unlocks chat once guest soft gate is done', () => {
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
