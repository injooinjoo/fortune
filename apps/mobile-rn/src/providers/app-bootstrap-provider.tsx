import {
  createContext,
  useContext,
  useEffect,
  useMemo,
  useRef,
  useState,
  type PropsWithChildren,
} from "react";

import * as Linking from "expo-linking";
import { router, type Href } from "expo-router";
import {
  emptyUnifiedOnboardingProgress,
  resolveChatOnboardingGate,
  resolveDeepLink,
  type ChatOnboardingGate,
  type FortuneTypeId,
  type UnifiedOnboardingProgress,
} from "@fortune/product-contracts";

import { trackEvent } from "../lib/analytics";
import {
  exchangeAuthCodeFromUrl,
  isAuthCallbackUrl,
} from "../lib/auth-session";
import { appEnv } from "../lib/env";
import { captureError } from "../lib/error-reporting";
import {
  getPendingChatFortuneType,
  getPendingChatFortuneRequest,
  getLastAuthenticatedUserId,
  getUnifiedOnboardingProgress,
  type PendingChatFortuneRequest,
  patchUnifiedOnboardingProgress,
  saveLastAuthenticatedUserId,
  saveUnifiedOnboardingProgress,
  setPendingChatFortuneRequest,
  setPendingChatFortuneType,
} from "../lib/storage";
import { supabase, type SupabaseSession } from "../lib/supabase";

type BootstrapStatus = "loading" | "ready";

interface BootstrapContextValue {
  status: BootstrapStatus;
  session: SupabaseSession;
  hasSupabase: boolean;
  gate: ChatOnboardingGate;
  onboardingProgress: UnifiedOnboardingProgress;
  pendingChatFortuneType: FortuneTypeId | null;
  pendingChatFortuneRequest: PendingChatFortuneRequest | null;
  markGuestBrowse: () => Promise<void>;
  markAuthComplete: () => Promise<void>;
  updateOnboardingProgress: (
    patch: Partial<UnifiedOnboardingProgress>,
  ) => Promise<void>;
  completeOnboarding: () => Promise<void>;
  consumePendingChatFortuneType: () => Promise<FortuneTypeId | null>;
  consumePendingChatFortuneRequest: () => Promise<PendingChatFortuneRequest | null>;
}

const BootstrapContext = createContext<BootstrapContextValue>({
  status: "loading",
  session: null,
  hasSupabase: false,
  gate: "auth-entry",
  onboardingProgress: emptyUnifiedOnboardingProgress,
  pendingChatFortuneType: null,
  pendingChatFortuneRequest: null,
  markGuestBrowse: async () => undefined,
  markAuthComplete: async () => undefined,
  updateOnboardingProgress: async () => undefined,
  completeOnboarding: async () => undefined,
  consumePendingChatFortuneType: async () => null,
  consumePendingChatFortuneRequest: async () => null,
});

export function AppBootstrapProvider({ children }: PropsWithChildren) {
  const [status, setStatus] = useState<BootstrapStatus>("loading");
  const [session, setSession] = useState<SupabaseSession>(null);
  const [onboardingProgress, setOnboardingProgress] =
    useState<UnifiedOnboardingProgress>(emptyUnifiedOnboardingProgress);
  const [pendingChatFortuneType, setPendingChatFortuneTypeState] =
    useState<FortuneTypeId | null>(null);
  const [pendingChatFortuneRequest, setPendingChatFortuneRequestState] =
    useState<PendingChatFortuneRequest | null>(null);
  const lastAuthenticatedUserIdRef = useRef<string | null>(null);

  useEffect(() => {
    let mounted = true;

    trackEvent("app_open").catch(() => undefined);

    async function syncProgress(
      patch: Partial<UnifiedOnboardingProgress>,
    ): Promise<UnifiedOnboardingProgress> {
      const next = await patchUnifiedOnboardingProgress(patch);

      if (mounted) {
        setOnboardingProgress(next);
      }

      return next;
    }

    async function applyDebugChatOverride(target: string) {
      if (appEnv.environment !== "development") {
        return null;
      }

      const url = new URL(target);
      const debugGate = url.searchParams.get("debugChatGate");
      const debugCharacterId = url.searchParams.get("characterId");

      if (debugGate === "auth-entry") {
        const nextProgress = await syncProgress({
          softGateCompleted: false,
          authCompleted: false,
          birthCompleted: false,
          interestCompleted: false,
          firstRunHandoffSeen: false,
        });

        return {
          nextProgress,
          route: "/chat" as const,
        };
      }

      if (debugGate !== "ready") {
        return null;
      }

      const nextProgress = await syncProgress({
        softGateCompleted: true,
        authCompleted: true,
        birthCompleted: true,
        interestCompleted: true,
        firstRunHandoffSeen: true,
      });

      const route = debugCharacterId
        ? (`/chat?characterId=${encodeURIComponent(debugCharacterId)}` as const)
        : ("/chat" as const);

      return {
        nextProgress,
        route,
      };
    }

    async function handleDeepLink(target: string) {
      const debugOverride = await applyDebugChatOverride(target);

      if (debugOverride) {
        router.replace(debugOverride.route as Href);
        return;
      }

      const resolution = resolveDeepLink(target);

      if (resolution.fortuneType) {
        await Promise.all([
          setPendingChatFortuneType(resolution.fortuneType),
          setPendingChatFortuneRequest({ fortuneType: resolution.fortuneType }),
        ]);

        if (mounted) {
          setPendingChatFortuneTypeState(resolution.fortuneType);
          setPendingChatFortuneRequestState({
            fortuneType: resolution.fortuneType,
          });
        }
      }

      if (resolution.route !== "/chat") {
        router.replace(resolution.route as Href);
      }
    }

    async function bootstrap() {
      try {
        const [
          storedProgress,
          queuedFortuneType,
          queuedFortuneRequest,
          lastAuthenticatedUserId,
        ] = await Promise.all([
          getUnifiedOnboardingProgress(),
          getPendingChatFortuneType(),
          getPendingChatFortuneRequest(),
          getLastAuthenticatedUserId(),
        ]);

        if (!mounted) {
          return;
        }

        lastAuthenticatedUserIdRef.current = lastAuthenticatedUserId;
        setOnboardingProgress(storedProgress);
        setPendingChatFortuneRequestState(
          queuedFortuneRequest ??
            (queuedFortuneType ? { fortuneType: queuedFortuneType } : null),
        );
        setPendingChatFortuneTypeState(
          queuedFortuneRequest?.fortuneType ?? queuedFortuneType,
        );

        const initialUrl = await Linking.getInitialURL();

        if (initialUrl && isAuthCallbackUrl(initialUrl)) {
          await exchangeAuthCodeFromUrl(initialUrl).catch((error) => {
            captureError(error, {
              surface: "bootstrap:auth-code-exchange",
            }).catch(() => undefined);
          });
        }

        if (supabase) {
          const { data } = await supabase.auth.getSession();

          if (!mounted) {
            return;
          }

          setSession(data.session);

          if (data.session) {
            const needsAuthScopedReset =
              lastAuthenticatedUserIdRef.current !== null &&
              lastAuthenticatedUserIdRef.current !== data.session.user.id;

            await saveLastAuthenticatedUserId(data.session.user.id);
            lastAuthenticatedUserIdRef.current = data.session.user.id;
            await syncProgress(
              needsAuthScopedReset
                ? {
                    authCompleted: true,
                    softGateCompleted: true,
                    birthCompleted: false,
                    interestCompleted: false,
                    firstRunHandoffSeen: false,
                  }
                : {
                    authCompleted: true,
                    softGateCompleted: true,
                  },
            );
          } else if (storedProgress.authCompleted) {
            await syncProgress({
              authCompleted: false,
            });
          }
        }

        if (initialUrl) {
          await handleDeepLink(initialUrl);
        }
      } catch (error) {
        await captureError(error, { surface: "bootstrap:init" });
      } finally {
        if (mounted) {
          setStatus("ready");
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
            const needsAuthScopedReset =
              lastAuthenticatedUserIdRef.current !== null &&
              lastAuthenticatedUserIdRef.current !== nextSession.user.id;

            lastAuthenticatedUserIdRef.current = nextSession.user.id;
            saveLastAuthenticatedUserId(nextSession.user.id)
              .then(() =>
                syncProgress(
                  needsAuthScopedReset
                    ? {
                        authCompleted: true,
                        softGateCompleted: true,
                        birthCompleted: false,
                        interestCompleted: false,
                        firstRunHandoffSeen: false,
                      }
                    : {
                        authCompleted: true,
                        softGateCompleted: true,
                      },
                ),
              )
              .catch((error) => {
                captureError(error, {
                  surface: "bootstrap:onAuthStateChange",
                }).catch(() => undefined);
              });
          } else {
            syncProgress({
              authCompleted: false,
            }).catch((error) => {
              captureError(error, {
                surface: "bootstrap:onAuthStateChange",
              }).catch(() => undefined);
            });
          }
        }).data.subscription
      : null;

    const linkSubscription = Linking.addEventListener("url", (event) => {
      const targetUrl = event.url;

      const maybeExchange = isAuthCallbackUrl(targetUrl)
        ? exchangeAuthCodeFromUrl(targetUrl).catch((error) => {
            captureError(error, {
              surface: "bootstrap:auth-code-exchange",
            }).catch(() => undefined);
            return null;
          })
        : Promise.resolve(null);

      maybeExchange
        .then(() => handleDeepLink(targetUrl))
        .catch((error) => {
          captureError(error, { surface: "bootstrap:deep-link" }).catch(
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
      authCompleted: Boolean(session),
    });
    setOnboardingProgress(next);
  }

  async function completeOnboarding() {
    const next = await saveUnifiedOnboardingProgress({
      ...onboardingProgress,
      softGateCompleted: true,
      authCompleted: Boolean(session),
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

  async function consumePendingChatFortuneRequest() {
    const current = pendingChatFortuneRequest;

    await Promise.all([
      setPendingChatFortuneType(null),
      setPendingChatFortuneRequest(null),
    ]);
    setPendingChatFortuneTypeState(null);
    setPendingChatFortuneRequestState(null);

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
      pendingChatFortuneRequest,
      markGuestBrowse,
      markAuthComplete,
      updateOnboardingProgress,
      completeOnboarding,
      consumePendingChatFortuneType,
      consumePendingChatFortuneRequest,
    }),
    [
      completeOnboarding,
      consumePendingChatFortuneType,
      consumePendingChatFortuneRequest,
      gate,
      markAuthComplete,
      markGuestBrowse,
      onboardingProgress,
      pendingChatFortuneRequest,
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
