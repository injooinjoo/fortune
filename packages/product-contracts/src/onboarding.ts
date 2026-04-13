export interface UnifiedOnboardingProgress {
  softGateCompleted: boolean;
  authCompleted: boolean;
  birthCompleted: boolean;
  interestCompleted: boolean;
  firstRunHandoffSeen: boolean;
}

export const unifiedOnboardingProgressStorageKey =
  'unified_onboarding_progress_v1';

export const emptyUnifiedOnboardingProgress: UnifiedOnboardingProgress = {
  softGateCompleted: false,
  authCompleted: false,
  birthCompleted: false,
  interestCompleted: false,
  firstRunHandoffSeen: false,
};

export type ChatOnboardingGate = 'auth-entry' | 'profile-flow' | 'ready';

export function normalizeUnifiedOnboardingProgress(
  value: unknown,
): UnifiedOnboardingProgress {
  if (!value || typeof value !== 'object') {
    return emptyUnifiedOnboardingProgress;
  }

  const raw = value as Record<string, unknown>;

  return {
    softGateCompleted: raw.softGateCompleted === true,
    authCompleted: raw.authCompleted === true,
    birthCompleted: raw.birthCompleted === true,
    interestCompleted: raw.interestCompleted === true,
    firstRunHandoffSeen: raw.firstRunHandoffSeen === true,
  };
}

export function resolveChatOnboardingGate(args: {
  hasAuthenticatedUser: boolean;
  progress: UnifiedOnboardingProgress;
}): ChatOnboardingGate {
  const { hasAuthenticatedUser, progress } = args;

  if (!hasAuthenticatedUser) {
    // Apple Guideline 5.1.1(v): non-account-based features must be freely
    // accessible. Skip the auth gate entirely for guests — show login as an
    // opt-in prompt inside the app instead of a blocking gate.
    return 'ready';
  }

  const needsBirthStep = !progress.birthCompleted;
  const needsInterestStep = !progress.interestCompleted;
  const needsHandoff = !progress.firstRunHandoffSeen;

  if (needsBirthStep || needsInterestStep || needsHandoff) {
    return 'profile-flow';
  }

  return 'ready';
}

export function mergeUnifiedOnboardingProgress(
  current: UnifiedOnboardingProgress,
  patch: Partial<UnifiedOnboardingProgress>,
): UnifiedOnboardingProgress {
  return {
    ...current,
    ...patch,
  };
}
