import { createContext, useContext, useEffect, useMemo, useState, type PropsWithChildren } from 'react';

import * as Linking from 'expo-linking';
import { router, type Href } from 'expo-router';
import {
  emptyUnifiedOnboardingProgress,
  resolveChatOnboardingGate,
  resolveDeepLink,
  type ChatOnboardingGate,
  type FortuneTypeId,
  type UnifiedOnboardingProgress,
} from '@fortune/product-contracts';

import { trackEvent } from '../lib/analytics';
import { captureError } from '../lib/error-reporting';
import {
  getPendingChatFortuneType,
  getUnifiedOnboardingProgress,
  patchUnifiedOnboardingProgress,
  saveUnifiedOnboardingProgress,
  setPendingChatFortuneType,
} from '../lib/storage';
import { supabase, type SupabaseSession } from '../lib/supabase';

type BootstrapStatus = 'loading' | 'ready';

interface BootstrapContextValue {
  status: BootstrapStatus;
  session: SupabaseSession;
  hasSupabase: boolean;
  gate: ChatOnboardingGate;
  onboardingProgress: UnifiedOnboardingProgress;
  pendingChatFortuneType: FortuneTypeId | null;
  markGuestBrowse: () => Promise<void>;
  markAuthComplete: () => Promise<void>;
  updateOnboardingProgress: (
    patch: Partial<UnifiedOnboardingProgress>,
  ) => Promise<void>;
  completeOnboarding: () => Promise<void>;
  consumePendingChatFortuneType: () => Promise<FortuneTypeId | null>;
}

const BootstrapContext = createContext<BootstrapContextValue>({
  status: 'loading',
  session: null,
  hasSupabase: false,
  gate: 'auth-entry',
  onboardingProgress: emptyUnifiedOnboardingProgress,
  pendingChatFortuneType: null,
  markGuestBrowse: async () => undefined,
  markAuthComplete: async () => undefined,
  updateOnboardingProgress: async () => undefined,
  completeOnboarding: async () => undefined,
  consumePendingChatFortuneType: async () => null,
});

export function AppBootstrapProvider({ children }: PropsWithChildren) {
  const [status, setStatus] = useState<BootstrapStatus>('loading');
  const [session, setSession] = useState<SupabaseSession>(null);
  const [onboardingProgress, setOnboardingProgress] = useState<UnifiedOnboardingProgress>(
    emptyUnifiedOnboardingProgress,
  );
  const [pendingChatFortuneType, setPendingChatFortuneTypeState] =
    useState<FortuneTypeId | null>(null);

  useEffect(() => {
    let mounted = true;

    trackEvent('app_open').catch(() => undefined);

    async function syncProgress(
      patch: Partial<UnifiedOnboardingProgress>,
    ): Promise<UnifiedOnboardingProgress> {
      const next = await patchUnifiedOnboardingProgress(patch);

      if (mounted) {
        setOnboardingProgress(next);
      }

      return next;
    }

    async function handleDeepLink(target: string) {
      const resolution = resolveDeepLink(target);

      if (resolution.fortuneType) {
        await setPendingChatFortuneType(resolution.fortuneType);

        if (mounted) {
          setPendingChatFortuneTypeState(resolution.fortuneType);
        }
      }

      if (resolution.route !== '/chat') {
        router.replace(resolution.route as Href);
      }
    }

    async function bootstrap() {
      try {
        const [storedProgress, queuedFortuneType] = await Promise.all([
          getUnifiedOnboardingProgress(),
          getPendingChatFortuneType(),
        ]);

        if (!mounted) {
          return;
        }

        setOnboardingProgress(storedProgress);
        setPendingChatFortuneTypeState(queuedFortuneType);

        if (supabase) {
          const { data } = await supabase.auth.getSession();

          if (!mounted) {
            return;
          }

          setSession(data.session);

          if (data.session) {
            await syncProgress({
              authCompleted: true,
              softGateCompleted: true,
            });
          }
        }

        const initialUrl = await Linking.getInitialURL();

        if (initialUrl) {
          await handleDeepLink(initialUrl);
        }
      } catch (error) {
        await captureError(error, { surface: 'bootstrap:init' });
      } finally {
        if (mounted) {
          setStatus('ready');
        }
      }
    }

    void bootstrap();

    const authSubscription = supabase
      ? supabase.auth.onAuthStateChange((_event, nextSession) => {
          if (mounted) {
            setSession(nextSession);
          }

          if (nextSession) {
            syncProgress({
              authCompleted: true,
              softGateCompleted: true,
            }).catch((error) => {
              captureError(error, {
                surface: 'bootstrap:onAuthStateChange',
              }).catch(() => undefined);
            });
          }
        }).data.subscription
      : null;

    const linkSubscription = Linking.addEventListener('url', (event) => {
      handleDeepLink(event.url).catch((error) => {
        captureError(error, { surface: 'bootstrap:deep-link' }).catch(
          () => undefined,
        );
      });
    });

    return () => {
      mounted = false;
      authSubscription?.unsubscribe();
      linkSubscription.remove();
    };
  }, []);

  async function markGuestBrowse() {
    const next = await patchUnifiedOnboardingProgress({
      softGateCompleted: true,
    });
    setOnboardingProgress(next);
  }

  async function markAuthComplete() {
    const next = await patchUnifiedOnboardingProgress({
      softGateCompleted: true,
      authCompleted: true,
    });
    setOnboardingProgress(next);
  }

  async function completeOnboarding() {
    const next = await saveUnifiedOnboardingProgress({
      ...onboardingProgress,
      softGateCompleted: true,
      authCompleted: true,
      birthCompleted: true,
      interestCompleted: true,
      firstRunHandoffSeen: true,
    });
    setOnboardingProgress(next);
  }

  async function updateOnboardingProgress(
    patch: Partial<UnifiedOnboardingProgress>,
  ) {
    const next = await patchUnifiedOnboardingProgress(patch);
    setOnboardingProgress(next);
  }

  async function consumePendingChatFortuneType() {
    const current = pendingChatFortuneType;

    await setPendingChatFortuneType(null);
    setPendingChatFortuneTypeState(null);

    return current;
  }

  const gate = resolveChatOnboardingGate({
    hasAuthenticatedUser: Boolean(session),
    progress: onboardingProgress,
  });

  const value = useMemo(
    () => ({
      status,
      session,
      hasSupabase: Boolean(supabase),
      gate,
      onboardingProgress,
      pendingChatFortuneType,
      markGuestBrowse,
      markAuthComplete,
      updateOnboardingProgress,
      completeOnboarding,
      consumePendingChatFortuneType,
    }),
    [
      completeOnboarding,
      consumePendingChatFortuneType,
      gate,
      markAuthComplete,
      markGuestBrowse,
      onboardingProgress,
      pendingChatFortuneType,
      session,
      status,
      updateOnboardingProgress,
    ],
  );

  return (
    <BootstrapContext.Provider value={value}>
      {children}
    </BootstrapContext.Provider>
  );
}

export function useAppBootstrap() {
  return useContext(BootstrapContext);
}
