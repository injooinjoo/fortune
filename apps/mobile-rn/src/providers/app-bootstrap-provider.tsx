import {
  createContext,
  useContext,
  useEffect,
  useMemo,
  useRef,
  useState,
  type PropsWithChildren,
} from 'react';

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
import { exchangeAuthCodeFromUrl, isAuthCallbackUrl } from '../lib/auth-session';
import { chatCharacters } from '../lib/chat-characters';
import type { ChatShellMessage } from '../lib/chat-shell';
import { loadCachedCharacterMessagesBatch } from '../lib/character-conversation-cache';
import { appEnv } from '../lib/env';
import { captureError } from '../lib/error-reporting';
import {
  installPushNotificationHandlers,
  registerPushTokenForSignedInUser,
} from '../lib/push-notifications';
import {
  getChatLastSeenByCharacterId,
  getPendingChatFortuneType,
  getLastAuthenticatedUserId,
  getUnifiedOnboardingProgress,
  patchUnifiedOnboardingProgress,
  saveLastAuthenticatedUserId,
  saveUnifiedOnboardingProgress,
  setPendingChatFortuneType,
} from '../lib/storage';
import { supabase, type SupabaseSession } from '../lib/supabase';
import type { ChatShellMySajuContextMessage } from '../lib/chat-shell';

type BootstrapStatus = 'loading' | 'ready';

interface BootstrapContextValue {
  status: BootstrapStatus;
  session: SupabaseSession;
  hasSupabase: boolean;
  gate: ChatOnboardingGate;
  onboardingProgress: UnifiedOnboardingProgress;
  pendingChatFortuneType: FortuneTypeId | null;
  pendingMySajuContext: ChatShellMySajuContextMessage | null;
  /**
   * 앱 부트스트랩 시점에 SecureStore에서 사전 로드한 캐릭터별 최신 대화.
   * chat-screen이 `useState` 초기값으로 사용하여 하드코딩 인트로 → 원격 로드
   * 간의 플래시를 제거한다. 키는 캐릭터 id, 값은 최신 메시지 배열.
   */
  cachedCharacterConversations: Record<string, ChatShellMessage[]>;
  /**
   * 캐릭터별 "마지막으로 본 메시지 id" 의 부트스트랩 사전 로드본.
   * 비동기 SecureStore 읽기를 chat-screen mount 후로 미루면 첫 렌더링 시
   * 빈 객체로 unread 가 계산되어 cold-start 직후 모든 캐릭터가 unread 닷
   * 상태로 깜빡인다. 메시지 캐시와 동일한 시점에 preload 하여 race 제거.
   */
  cachedLastSeenByCharacterId: Record<string, string>;
  markGuestBrowse: () => Promise<void>;
  markAuthComplete: () => Promise<void>;
  updateOnboardingProgress: (
    patch: Partial<UnifiedOnboardingProgress>,
  ) => Promise<void>;
  completeOnboarding: () => Promise<void>;
  consumePendingChatFortuneType: () => Promise<FortuneTypeId | null>;
  setPendingMySajuContext: (message: ChatShellMySajuContextMessage) => void;
  consumePendingMySajuContext: () => ChatShellMySajuContextMessage | null;
}

const BootstrapContext = createContext<BootstrapContextValue>({
  status: 'loading',
  session: null,
  hasSupabase: false,
  gate: 'auth-entry',
  onboardingProgress: emptyUnifiedOnboardingProgress,
  pendingChatFortuneType: null,
  pendingMySajuContext: null,
  cachedCharacterConversations: {},
  cachedLastSeenByCharacterId: {},
  markGuestBrowse: async () => undefined,
  markAuthComplete: async () => undefined,
  updateOnboardingProgress: async () => undefined,
  completeOnboarding: async () => undefined,
  consumePendingChatFortuneType: async () => null,
  setPendingMySajuContext: () => undefined,
  consumePendingMySajuContext: () => null,
});

export function AppBootstrapProvider({ children }: PropsWithChildren) {
  const [status, setStatus] = useState<BootstrapStatus>('loading');
  const [session, setSession] = useState<SupabaseSession>(null);
  const [onboardingProgress, setOnboardingProgress] = useState<UnifiedOnboardingProgress>(
    emptyUnifiedOnboardingProgress,
  );
  const [pendingChatFortuneType, setPendingChatFortuneTypeState] =
    useState<FortuneTypeId | null>(null);
  const [pendingMySajuContext, setPendingMySajuContextState] =
    useState<ChatShellMySajuContextMessage | null>(null);
  const [cachedCharacterConversations, setCachedCharacterConversations] =
    useState<Record<string, ChatShellMessage[]>>({});
  const [cachedLastSeenByCharacterId, setCachedLastSeenByCharacterId] =
    useState<Record<string, string>>({});
  const lastAuthenticatedUserIdRef = useRef<string | null>(null);

  useEffect(() => {
    let mounted = true;

    // iPad Sign in with Apple fallback 등 드물게 iOS가 동일 OAuth 콜백 URL을
    // getInitialURL() + 'url' 이벤트로 이중 전달하는 케이스가 있다. PKCE 코드는
    // 단회용이라 두 번째 교환은 반드시 실패(invalid_grant)한다. 기능상 문제는
    // 없지만 Sentry noise 제거 + 불필요 네트워크 호출 방지를 위해 URL 단위 dedup.
    const exchangedAuthUrls = new Set<string>();

    async function exchangeOnce(url: string) {
      if (exchangedAuthUrls.has(url)) {
        return;
      }
      exchangedAuthUrls.add(url);
      try {
        await exchangeAuthCodeFromUrl(url);
      } catch (error) {
        await captureError(error, {
          surface: 'bootstrap:auth-code-exchange',
        }).catch(() => undefined);
      }
    }

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

    async function applyDebugChatOverride(target: string) {
      if (appEnv.environment !== 'development') {
        return null;
      }

      const url = new URL(target);
      const debugGate = url.searchParams.get('debugChatGate');
      const debugCharacterId = url.searchParams.get('characterId');

      if (debugGate === 'auth-entry') {
        const nextProgress = await syncProgress({
          softGateCompleted: false,
          authCompleted: false,
          birthCompleted: false,
          interestCompleted: false,
          firstRunHandoffSeen: false,
        });

        return {
          nextProgress,
          route: '/chat' as const,
        };
      }

      if (debugGate !== 'ready') {
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
        : ('/chat' as const);

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
        const characterIds = chatCharacters.map((c) => c.id);
        const [
          storedProgress,
          queuedFortuneType,
          lastAuthenticatedUserId,
          cachedConversations,
          cachedLastSeen,
        ] = await Promise.all([
          getUnifiedOnboardingProgress(),
          getPendingChatFortuneType(),
          getLastAuthenticatedUserId(),
          loadCachedCharacterMessagesBatch(characterIds),
          getChatLastSeenByCharacterId(),
        ]);

        if (mounted) {
          setCachedCharacterConversations(cachedConversations);
          setCachedLastSeenByCharacterId(cachedLastSeen);
        }

        if (!mounted) {
          return;
        }

        lastAuthenticatedUserIdRef.current = lastAuthenticatedUserId;
        setOnboardingProgress(storedProgress);
        setPendingChatFortuneTypeState(queuedFortuneType);

        const initialUrl = await Linking.getInitialURL();

        if (initialUrl && isAuthCallbackUrl(initialUrl)) {
          await exchangeOnce(initialUrl);
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
            // 앱 재시작 시에도 토큰 갱신 요청 — rotate 된 경우 서버 업데이트.
            registerPushTokenForSignedInUser().catch((error) => {
              console.warn('[bootstrap] push token 등록 실패:', error);
            });
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
        await captureError(error, { surface: 'bootstrap:init' });
      } finally {
        if (mounted) {
          setStatus('ready');
        }
      }
    }

    // Deep-link URL listener는 bootstrap 시작보다 먼저 부착한다.
    // iPad Sign in with Apple이 OAuth fallback으로 전환될 때 콜백 URL이
    // cold-start 직후 도착하면, listener가 async bootstrap 뒤에 붙어 있을
    // 경우 이벤트가 누락돼 silent fail로 이어진다 (이전 2.1 리젝 사유).
    // 함수 선언(handleDeepLink 등)은 useEffect 내 hoisted되어 여기서 참조 가능.
    const linkSubscription = Linking.addEventListener('url', (event) => {
      const targetUrl = event.url;

      const maybeExchange = isAuthCallbackUrl(targetUrl)
        ? exchangeOnce(targetUrl)
        : Promise.resolve();

      maybeExchange
        .then(() => handleDeepLink(targetUrl))
        .catch((error) => {
          captureError(error, { surface: 'bootstrap:deep-link' }).catch(
            () => undefined,
          );
        });
    });

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
                  surface: 'bootstrap:onAuthStateChange',
                }).catch(() => undefined);
              });
            // Expo push token 등록 — Supabase 에 업로드해서 서버가 Character DM
            // 푸시를 보낼 수 있게 한다. 권한 미허용/시뮬레이터에선 silent skip.
            registerPushTokenForSignedInUser().catch((error) => {
              console.warn('[bootstrap] push token 등록 실패:', error);
            });
          } else {
            syncProgress({
              authCompleted: false,
            }).catch((error) => {
              captureError(error, {
                surface: 'bootstrap:onAuthStateChange',
              }).catch(() => undefined);
            });
          }
        }).data.subscription
      : null;

    // Push 알림 리스너 설치 — 탭 시 해당 캐릭터 채팅 스크린으로 라우팅.
    // 앱 콜드 스타트 시 getLastNotificationResponseAsync 가 내부에서 fallback
    // 으로 한 번 더 호출되므로 종료 상태에서 탭으로 열린 경우도 커버.
    const removePushHandlers = installPushNotificationHandlers({
      onTap: (payload) => {
        const target = payload.route
          ? payload.route
          : payload.characterId
            ? `/chat?characterId=${encodeURIComponent(payload.characterId)}`
            : null;
        if (!target) return;
        // 초기 라우팅이 아직 안 끝났을 수 있어 약간 지연 후 replace.
        setTimeout(() => {
          try {
            router.push(target as Href);
          } catch (e) {
            console.warn('[bootstrap] push route 실패:', e);
          }
        }, 300);
      },
    });

    return () => {
      mounted = false;
      authSubscription?.unsubscribe();
      linkSubscription.remove();
      removePushHandlers();
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

  function setPendingMySajuContext(message: ChatShellMySajuContextMessage) {
    setPendingMySajuContextState(message);
  }

  function consumePendingMySajuContext() {
    const current = pendingMySajuContext;
    setPendingMySajuContextState(null);
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
      pendingMySajuContext,
      cachedCharacterConversations,
      cachedLastSeenByCharacterId,
      markGuestBrowse,
      markAuthComplete,
      updateOnboardingProgress,
      completeOnboarding,
      consumePendingChatFortuneType,
      setPendingMySajuContext,
      consumePendingMySajuContext,
    }),
    [
      cachedCharacterConversations,
      cachedLastSeenByCharacterId,
      completeOnboarding,
      consumePendingChatFortuneType,
      consumePendingMySajuContext,
      gate,
      markAuthComplete,
      markGuestBrowse,
      onboardingProgress,
      pendingChatFortuneType,
      pendingMySajuContext,
      session,
      setPendingMySajuContext,
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
