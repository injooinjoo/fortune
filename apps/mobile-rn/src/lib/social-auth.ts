import * as Linking from 'expo-linking';
import { type Provider } from '@supabase/supabase-js';
import { Platform } from 'react-native';

import { deepLinkConfig } from '@fortune/product-contracts';

import { appEnv } from './env';
import { supabase } from './supabase';

export type SocialAuthProviderId = 'apple' | 'google' | 'kakao';

export const socialAuthProviderIds: SocialAuthProviderId[] = [
  'apple',
  'google',
  'kakao',
];

export const socialAuthProviderLabelById: Record<SocialAuthProviderId, string> = {
  apple: 'Apple',
  google: 'Google',
  kakao: 'Kakao',
};

export interface SocialAuthStartResult {
  provider: SocialAuthProviderId;
  status: 'started' | 'unsupported' | 'failed';
  redirectTo: string;
  authorizationUrl?: string;
  errorMessage?: string;
}

export function resolveSocialAuthRedirectTo() {
  if (Platform.OS === 'web') {
    const origin =
      typeof window !== 'undefined' && window.location.origin
        ? window.location.origin
        : appEnv.appDomain || 'http://localhost:19006';

    return `${origin.replace(/\/$/, '')}/auth/callback`;
  }

  return `${deepLinkConfig.scheme}://${deepLinkConfig.authCallbackHost}`;
}

export function isSocialAuthSupported(provider: SocialAuthProviderId) {
  void provider;
  return Boolean(supabase);
}

export async function startSocialAuth(
  provider: SocialAuthProviderId,
): Promise<SocialAuthStartResult> {
  const redirectTo = resolveSocialAuthRedirectTo();

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
    const response = await supabase.auth.signInWithOAuth({
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

    await Linking.openURL(response.data.url);

    return {
      provider,
      status: 'started',
      redirectTo,
      authorizationUrl: response.data.url,
    };
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
