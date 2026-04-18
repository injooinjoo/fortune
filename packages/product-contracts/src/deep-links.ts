import { fortuneTypesById, type FortuneTypeId } from './fortunes';

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

const fortuneTypeAliases: Record<string, FortuneTypeId> = {
  time: 'daily',
  'daily-calendar': 'daily',
  health: 'daily',
  saju: 'traditional-saju',
  traditional: 'traditional-saju',
  yearly: 'new-year',
  investment: 'wealth',
  'sports-game': 'match-insight',
  'lucky-lottery': 'lotto',
  pet: 'pet-compatibility',
  'ex-lover-simple': 'ex-lover',
  'baby-nickname': 'naming',
};

export function isAuthCallbackUrl(url: URL): boolean {
  if (
    url.protocol.replace(':', '') === deepLinkConfig.scheme &&
    url.hostname === deepLinkConfig.authCallbackHost
  ) {
    return true;
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
  const fortuneType = normalizeFortuneTypeForChat(
    url.searchParams.get(deepLinkConfig.fortuneTypeParam),
  );

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

export function normalizeFortuneTypeForChat(
  input: string | null | undefined,
): FortuneTypeId | null {
  if (!input) {
    return null;
  }

  const normalizedInput = input.trim().toLowerCase();
  const resolvedType = fortuneTypeAliases[normalizedInput] ?? normalizedInput;

  return resolvedType in fortuneTypesById
    ? (resolvedType as FortuneTypeId)
    : null;
}
