import { deepLinkConfig } from '@fortune/product-contracts';

import { supabase } from './supabase';

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
  const code = url.searchParams.get('code');

  if (!code) {
    return null;
  }

  const { data, error } = await supabase.auth.exchangeCodeForSession(code);

  if (error) {
    throw error;
  }

  return data.session ?? null;
}
