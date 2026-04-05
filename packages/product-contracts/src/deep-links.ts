import type { FortuneTypeId } from './fortunes';

export const deepLinkConfig = {
  scheme: 'com.beyond.fortune',
  authCallbackHost: 'auth-callback',
  screenParam: 'screen',
  fortuneTypeParam: 'fortuneType',
  pendingFortuneTypeStorageKey: 'pending_deep_link_fortune_type',
} as const;

export interface DeepLinkResolution {
  route: string;
  fortuneType?: FortuneTypeId;
  authCallbackUrl?: string;
}

export function isAuthCallbackUrl(url: URL): boolean {
  if (
    url.protocol.replace(':', '') === deepLinkConfig.scheme &&
    url.hostname === deepLinkConfig.authCallbackHost
  ) {
    return true;
  }

  if (url.protocol.replace(':', '') === 'io.supabase.flutter') {
    return (
      url.hostname.includes('callback') ||
      url.pathname.includes('callback') ||
      url.toString().includes('access_token')
    );
  }

  return false;
}

export function resolveDeepLink(target: string): DeepLinkResolution {
  const url = new URL(target);

  if (isAuthCallbackUrl(url)) {
    return {
      route: `/auth/callback?authCallbackUrl=${encodeURIComponent(url.toString())}`,
      authCallbackUrl: url.toString(),
    };
  }

  const screen = url.searchParams.get(deepLinkConfig.screenParam);
  const fortuneType = url.searchParams.get(
    deepLinkConfig.fortuneTypeParam,
  ) as FortuneTypeId | null;

  if (screen === 'chat' && fortuneType) {
    return {
      route: '/chat',
      fortuneType,
    };
  }

  if (screen) {
    return {
      route: `/${screen}`,
      fortuneType: fortuneType ?? undefined,
    };
  }

  return {
    route: '/chat',
    fortuneType: fortuneType ?? undefined,
  };
}
