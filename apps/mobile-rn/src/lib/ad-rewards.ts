// AdMob Rewarded Video 광고 시청 + 토큰 보상 지급 훅.
//
// 흐름:
// 1. RewardedAd.createForAdRequest() → 광고 로드
// 2. 사용자가 "광고 보기" 버튼 누름 → ad.show()
// 3. EARNED_REWARD 이벤트 → grant-ad-reward edge function POST 호출
// 4. 토큰 잔액 갱신 + 사용자에게 결과 알림
//
// SSV 가 활성화되면 (3) 의 POST 는 fallback 이고 실제 토큰은 AdMob 서버 →
// grant-ad-reward GET 콜백 경로로 지급된다. 이 훅은 두 경로 모두 호환.

import { useCallback, useEffect, useRef, useState } from 'react';
import { Platform } from 'react-native';
import { type Session } from '@supabase/supabase-js';

import { appEnv } from './env';

// react-native-google-mobile-ads 는 native module 로 simulator/web 에서 동작 X.
// 동적 import 로 native runtime 에서만 로드 — type-check 는 통과시키되 런타임
// 분기로 web/jest 에서 안전.
type RewardedAdInstance = {
  load: () => void;
  show: () => Promise<void>;
  addAdEventListener: (
    type: string,
    handler: (data?: unknown) => void,
  ) => () => void;
  loaded: boolean;
};

type RewardedAdModule = {
  RewardedAd: {
    createForAdRequest: (
      adUnitId: string,
      requestOptions?: {
        requestNonPersonalizedAdsOnly?: boolean;
        keywords?: string[];
        serverSideVerificationOptions?: { customData?: string; userId?: string };
      },
    ) => RewardedAdInstance;
  };
  RewardedAdEventType: { LOADED: string; EARNED_REWARD: string };
  AdEventType: { ERROR: string; CLOSED: string };
};

let cachedAdsModule: RewardedAdModule | null = null;
async function loadAdsModule(): Promise<RewardedAdModule | null> {
  if (cachedAdsModule) return cachedAdsModule;
  if (Platform.OS === 'web') return null;
  try {
    // dynamic import (avoid bundler include in test/web)
    const mod = (await import(
      'react-native-google-mobile-ads'
    )) as unknown as RewardedAdModule;
    cachedAdsModule = mod;
    return mod;
  } catch (error) {
    console.warn('[ad-rewards] react-native-google-mobile-ads load failed:', error);
    return null;
  }
}

function pickRewardedUnitId(): string {
  if (Platform.OS === 'ios') return appEnv.admob.rewardedUnitIos;
  if (Platform.OS === 'android') return appEnv.admob.rewardedUnitAndroid;
  return '';
}

export interface AdRewardOutcome {
  success: boolean;
  tokensGranted?: number;
  newBalance?: number;
  remainingToday?: number;
  error?: string;
  errorCode?: 'limit_reached' | 'unauthorized' | 'unknown';
}

/**
 * Edge Function 직접 호출 (POST self-attestation 경로).
 * SSV 가 활성화된 환경에서는 보상이 중복으로 지급되지 않도록 server-side 에서
 * idempotency 체크가 필요할 수 있으나, 현재는 ad_reward_log 의 일일 한도 (5)
 * 와 row 단위 insert 로 자연스럽게 cap 됨.
 */
async function notifyEdgeFunction(
  session: Session,
  payload: { adUnit?: string; ssvSignature?: string },
): Promise<AdRewardOutcome> {
  if (!appEnv.isSupabaseConfigured) {
    return { success: false, error: 'Supabase not configured' };
  }
  try {
    const res = await fetch(
      `${appEnv.supabaseUrl}/functions/v1/grant-ad-reward`,
      {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${session.access_token}`,
          apikey: appEnv.supabaseAnonKey,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          adUnit: payload.adUnit ?? null,
          ssvSignature: payload.ssvSignature ?? null,
        }),
      },
    );
    const json = (await res.json()) as AdRewardOutcome;
    return json;
  } catch (error) {
    return {
      success: false,
      error: error instanceof Error ? error.message : 'unknown',
    };
  }
}

export interface UseRewardedAdOptions {
  session: Session | null;
  /** 광고 시청 + 토큰 지급 성공 시 호출. 잔액 갱신 등 후속 작업에 사용. */
  onReward?: (outcome: AdRewardOutcome) => void;
  /** 사용자 ID — AdMob SSV 의 customData 로 전달되어 GET 콜백에서 사용됨. */
  userId?: string | null;
}

export interface UseRewardedAdResult {
  isReady: boolean;
  isShowing: boolean;
  /** 광고 단위 / 환경변수 미설정 시 true. UI 에서 버튼 자체를 숨길 때 사용. */
  isUnavailable: boolean;
  showAd: () => Promise<AdRewardOutcome>;
}

/**
 * Rewarded video ad 를 1개 미리 로드해두고 호출 시 즉시 보여주는 훅.
 * 한 번 사용 후 자동으로 다음 광고 prefetch.
 */
export function useRewardedAd(
  options: UseRewardedAdOptions,
): UseRewardedAdResult {
  const { session, onReward, userId } = options;
  const [isReady, setIsReady] = useState(false);
  const [isShowing, setIsShowing] = useState(false);
  const adRef = useRef<RewardedAdInstance | null>(null);
  const moduleRef = useRef<RewardedAdModule | null>(null);

  const adUnitId = pickRewardedUnitId();
  const isUnavailable = !adUnitId || Platform.OS === 'web';

  const prefetch = useCallback(async () => {
    if (isUnavailable) return;
    const mod = moduleRef.current ?? (await loadAdsModule());
    if (!mod) return;
    moduleRef.current = mod;

    const ad = mod.RewardedAd.createForAdRequest(adUnitId, {
      requestNonPersonalizedAdsOnly: true,
      keywords: ['fortune', 'tarot', 'horoscope', 'lifestyle'],
      serverSideVerificationOptions: userId
        ? { customData: userId, userId }
        : undefined,
    });

    const offLoaded = ad.addAdEventListener(mod.RewardedAdEventType.LOADED, () => {
      setIsReady(true);
    });
    const offError = ad.addAdEventListener(mod.AdEventType.ERROR, (data) => {
      console.warn('[ad-rewards] ad load error:', data);
      setIsReady(false);
    });

    adRef.current = ad;
    ad.load();

    return () => {
      offLoaded();
      offError();
    };
  }, [adUnitId, isUnavailable, userId]);

  useEffect(() => {
    let cleanup: (() => void) | undefined;
    void (async () => {
      cleanup = await prefetch();
    })();
    return () => {
      cleanup?.();
    };
  }, [prefetch]);

  const showAd = useCallback(async (): Promise<AdRewardOutcome> => {
    if (isUnavailable) {
      return { success: false, error: 'ads_unavailable_on_platform' };
    }
    if (!session) {
      return { success: false, error: 'login_required' };
    }
    const ad = adRef.current;
    const mod = moduleRef.current;
    if (!ad || !mod || !ad.loaded) {
      return { success: false, error: 'ad_not_ready' };
    }

    setIsShowing(true);
    try {
      const earned = await new Promise<boolean>((resolve) => {
        const offEarned = ad.addAdEventListener(
          mod.RewardedAdEventType.EARNED_REWARD,
          () => {
            offEarned();
            resolve(true);
          },
        );
        const offClosed = ad.addAdEventListener(mod.AdEventType.CLOSED, () => {
          offClosed();
          resolve(false);
        });
        ad.show().catch(() => resolve(false));
      });

      setIsShowing(false);

      if (!earned) {
        // 즉시 다음 광고 prefetch
        void prefetch();
        return { success: false, error: 'ad_dismissed_before_reward' };
      }

      const outcome = await notifyEdgeFunction(session, {
        adUnit: adUnitId,
      });
      onReward?.(outcome);

      // 다음 시청을 위해 새 광고 prefetch
      void prefetch();
      return outcome;
    } catch (error) {
      setIsShowing(false);
      void prefetch();
      return {
        success: false,
        error: error instanceof Error ? error.message : 'unknown',
      };
    }
  }, [adUnitId, isUnavailable, onReward, prefetch, session]);

  return { isReady, isShowing, isUnavailable, showAd };
}
