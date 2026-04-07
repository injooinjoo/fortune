import { deepLinkConfig } from '@fortune/product-contracts';

import { supabase } from './supabase';

function readCallbackParam(url: URL, key: string) {
  const hashParams = new URLSearchParams(
    url.hash.startsWith('#') ? url.hash.slice(1) : url.hash,
  );

  return url.searchParams.get(key) ?? hashParams.get(key);
}

export function isAuthCallbackUrl(value: string) {
  try {
    const url = new URL(value);

    return (
      (url.protocol.replace(':', '') === deepLinkConfig.scheme &&
        url.hostname === deepLinkConfig.authCallbackHost) ||
      url.toString().includes('code=')
    );
  } catch {
    return false;
  }
}

export async function exchangeAuthCodeFromUrl(value: string) {
  if (!supabase || !isAuthCallbackUrl(value)) {
    return null;
  }

  const url = new URL(value);
  const code = readCallbackParam(url, 'code');

  if (code) {
    const { data, error } = await supabase.auth.exchangeCodeForSession(code);

    if (error) {
      throw error;
    }

    return data.session ?? null;
  }

  const accessToken = readCallbackParam(url, 'access_token');
  const refreshToken = readCallbackParam(url, 'refresh_token');

  if (!accessToken || !refreshToken) {
    return null;
  }

  const { data, error } = await supabase.auth.setSession({
    access_token: accessToken,
    refresh_token: refreshToken,
  });

  if (error) {
    throw error;
  }

  return data.session ?? null;
}
