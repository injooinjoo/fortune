import * as AppleAuthentication from 'expo-apple-authentication';
import * as Crypto from 'expo-crypto';
import * as Linking from 'expo-linking';
import * as WebBrowser from 'expo-web-browser';
import { type Provider } from '@supabase/supabase-js';
import { Dimensions, Platform } from 'react-native';

// React Native 의 Platform 객체에는 iOS/Android 이외 하위 구분을 공식 제공하지
// 않는다. `(Platform as any).isPad` 는 undefined 라 이전 P7-B1 fix 가 iPad
// 경로에서 활성화되지 않았음. 화면 최단축 768pt 이상이면 iPad 로 간주.
// (expo-device 의 `Device.deviceType === TABLET` 이 더 정확하지만 이미
// 플러그인 사용 중이고 import 순환 방지 위해 Dimensions 로 충분.)
function isIpad(): boolean {
  if (Platform.OS !== 'ios') return false;
  const { width, height } = Dimensions.get('window');
  return Math.min(width, height) >= 768;
}

import { deepLinkConfig } from '@fortune/product-contracts';

import { exchangeAuthCodeFromUrl } from './auth-session';
import { appEnv } from './env';
import { supabase } from './supabase';

WebBrowser.maybeCompleteAuthSession();

export type SocialAuthProviderId = 'apple' | 'google' | 'kakao' | 'naver';
type SupabaseOAuthProviderId = Exclude<SocialAuthProviderId, 'naver'>;

export const socialAuthProviderIds: SocialAuthProviderId[] = [
  'apple',
  'google',
  'kakao',
  'naver',
];

export const socialAuthProviderLabelById: Record<SocialAuthProviderId, string> = {
  apple: '애플',
  google: '구글',
  kakao: '카카오',
  naver: '네이버',
};

export interface SocialAuthStartResult {
  provider: SocialAuthProviderId;
  status: 'started' | 'unsupported' | 'failed';
  redirectTo: string;
  authorizationUrl?: string;
  errorMessage?: string;
}

async function createAppleRawNonce() {
  return Crypto.randomUUID().replace(/-/g, '') + Crypto.randomUUID().replace(/-/g, '');
}

async function createAppleHashedNonce(rawNonce: string) {
  return Crypto.digestStringAsync(Crypto.CryptoDigestAlgorithm.SHA256, rawNonce, {
    encoding: Crypto.CryptoEncoding.HEX,
  });
}

async function startAppleNativeAuth(
  client: NonNullable<typeof supabase>,
  provider: SocialAuthProviderId,
  redirectTo: string,
): Promise<SocialAuthStartResult> {
  const isAvailable = await AppleAuthentication.isAvailableAsync();

  if (!isAvailable) {
    return {
      provider,
      status: 'unsupported',
      redirectTo,
      errorMessage: '이 기기에서는 애플 로그인을 사용할 수 없습니다.',
    };
  }

  const rawNonce = await createAppleRawNonce();
  const hashedNonce = await createAppleHashedNonce(rawNonce);

  try {
    const credential = await AppleAuthentication.signInAsync({
      nonce: hashedNonce,
      requestedScopes: [
        AppleAuthentication.AppleAuthenticationScope.EMAIL,
        AppleAuthentication.AppleAuthenticationScope.FULL_NAME,
      ],
      ...(isIpad() ? { state: 'apple-auth' } : {}),
    });

    if (!credential.identityToken) {
      return {
        provider,
        status: 'failed',
        redirectTo,
        errorMessage: '애플 인증 토큰을 확인하지 못했습니다.',
      };
    }

    const response = await client.auth.signInWithIdToken({
      nonce: rawNonce,
      provider: 'apple',
      token: credential.identityToken,
    });

    if (response.error) {
      return {
        provider,
        status: 'failed',
        redirectTo,
        errorMessage: response.error.message,
      };
    }

    return {
      provider,
      status: 'started',
      redirectTo,
    };
  } catch (error) {
    const errorCode =
      typeof error === 'object' && error && 'code' in error
        ? String(error.code)
        : null;

    if (errorCode === 'ERR_REQUEST_CANCELED') {
      return {
        provider,
        status: 'failed',
        redirectTo,
        errorMessage: '애플 로그인을 취소했습니다.',
      };
    }

    return {
      provider,
      status: 'failed',
      redirectTo,
      errorMessage:
        error instanceof Error ? error.message : '애플 로그인을 시작하지 못했습니다.',
    };
  }
}

function normalizeReturnTo(value: string | null | undefined) {
  return value && value.startsWith('/') ? value : '/chat';
}

function isSupabaseOAuthProvider(
  provider: SocialAuthProviderId,
): provider is SupabaseOAuthProviderId {
  return provider !== 'naver';
}

function resolveSupabaseFunctionsBaseUrl() {
  return `${appEnv.supabaseUrl.replace(/\/$/, '')}/functions/v1`;
}

function resolveNaverAuthorizationUrl(returnTo?: string) {
  const authorizationUrl = new URL(
    `${resolveSupabaseFunctionsBaseUrl()}/naver-oauth`,
  );
  authorizationUrl.searchParams.set('mode', 'start');
  authorizationUrl.searchParams.set(
    'returnTo',
    normalizeReturnTo(returnTo),
  );

  return authorizationUrl.toString();
}

async function completeInAppAuthSession(
  provider: SocialAuthProviderId,
  authorizationUrl: string,
  redirectTo: string,
): Promise<SocialAuthStartResult> {
  try {
    const result = await WebBrowser.openAuthSessionAsync(
      authorizationUrl,
      redirectTo,
      {
        preferEphemeralSession: true,
        ...(isIpad()
          ? { presentationStyle: WebBrowser.WebBrowserPresentationStyle.FULL_SCREEN }
          : {}),
      },
    );

    if (result.type === 'cancel' || result.type === 'dismiss') {
      return {
        provider,
        status: 'failed',
        redirectTo,
        authorizationUrl,
        errorMessage: `${socialAuthProviderLabelById[provider]} 로그인을 취소했습니다.`,
      };
    }

    if (result.type !== 'success' || !result.url) {
      return {
        provider,
        status: 'failed',
        redirectTo,
        authorizationUrl,
        errorMessage:
          result.type === 'locked'
            ? '이미 다른 로그인 창이 열려 있습니다. 잠시 후 다시 시도해 주세요.'
            : `${socialAuthProviderLabelById[provider]} 로그인 완료 신호를 받지 못했습니다.`,
      };
    }

    const session = await exchangeAuthCodeFromUrl(result.url);

    if (!session) {
      return {
        provider,
        status: 'failed',
        redirectTo,
        authorizationUrl,
        errorMessage: '로그인 세션을 확인하지 못했습니다. 다시 시도해 주세요.',
      };
    }

    return {
      provider,
      status: 'started',
      redirectTo,
      authorizationUrl,
    };
  } catch (error) {
    return {
      provider,
      status: 'failed',
      redirectTo,
      authorizationUrl,
      errorMessage:
        error instanceof Error ? error.message : '소셜 로그인을 시작하지 못했습니다.',
    };
  }
}

export function resolveSocialAuthRedirectTo(
  provider: SocialAuthProviderId,
  returnTo?: string,
) {
  const normalizedReturnTo = normalizeReturnTo(returnTo);

  if (Platform.OS === 'web') {
    const origin =
      typeof window !== 'undefined' && window.location.origin
        ? window.location.origin
        : appEnv.appDomain || 'http://localhost:19006';

    const redirectUrl = new URL(
      `${origin.replace(/\/$/, '')}/auth/callback`,
    );
    redirectUrl.searchParams.set('provider', provider);
    redirectUrl.searchParams.set('screen', 'chat');
    redirectUrl.searchParams.set('returnTo', normalizedReturnTo);

    return redirectUrl.toString();
  }

  const redirectUrl = new URL(
    `${deepLinkConfig.scheme}://${deepLinkConfig.authCallbackHost}`,
  );
  redirectUrl.searchParams.set('provider', provider);
  redirectUrl.searchParams.set('screen', 'chat');
  redirectUrl.searchParams.set('returnTo', normalizedReturnTo);

  return redirectUrl.toString();
}

export function isSocialAuthSupported(provider: SocialAuthProviderId) {
  if (!supabase) {
    return false;
  }

  if (provider === 'naver') {
    return Platform.OS !== 'web';
  }

  return true;
}

export async function startSocialAuth(
  provider: SocialAuthProviderId,
  returnTo?: string,
): Promise<SocialAuthStartResult> {
  const redirectTo = resolveSocialAuthRedirectTo(provider, returnTo);

  if (!supabase) {
    return {
      provider,
      status: 'unsupported',
      redirectTo,
      errorMessage: 'Supabase 환경이 아직 설정되지 않았습니다.',
    };
  }

  if (!isSocialAuthSupported(provider)) {
    return {
      provider,
      status: 'unsupported',
      redirectTo,
      errorMessage: `${socialAuthProviderLabelById[provider]} 로그인이 아직 준비되지 않았습니다.`,
    };
  }

  try {
    const client = supabase;

    if (provider === 'apple' && Platform.OS === 'ios') {
      return startAppleNativeAuth(client, provider, redirectTo);
    }

    if (!isSupabaseOAuthProvider(provider)) {
      const authorizationUrl = resolveNaverAuthorizationUrl(returnTo);

      if (Platform.OS === 'web') {
        await Linking.openURL(authorizationUrl);

        return {
          provider,
          status: 'started',
          redirectTo,
          authorizationUrl,
        };
      }

      return completeInAppAuthSession(provider, authorizationUrl, redirectTo);
    }

    const response = await client.auth.signInWithOAuth({
      provider: provider as Provider,
      options: {
        redirectTo,
        skipBrowserRedirect: true,
      },
    });

    if (response.error) {
      return {
        provider,
        status: 'failed',
        redirectTo,
        errorMessage: response.error.message,
      };
    }

    if (!response.data?.url) {
      return {
        provider,
        status: 'failed',
        redirectTo,
        errorMessage: 'OAuth URL을 생성하지 못했습니다.',
      };
    }

    if (Platform.OS === 'web') {
      await Linking.openURL(response.data.url);

      return {
        provider,
        status: 'started',
        redirectTo,
        authorizationUrl: response.data.url,
      };
    }

    return completeInAppAuthSession(provider, response.data.url, redirectTo);
  } catch (error) {
    return {
      provider,
      status: 'failed',
      redirectTo,
      errorMessage:
        error instanceof Error ? error.message : '소셜 로그인을 시작하지 못했습니다.',
    };
  }
}
