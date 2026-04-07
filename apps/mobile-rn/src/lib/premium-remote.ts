import { productCatalog, type ProductId } from '@fortune/product-contracts';
import { type Session } from '@supabase/supabase-js';

import { appEnv } from './env';
import { supabase } from './supabase';

interface RemoteSubscriptionRow {
  product_id: string;
  expires_at: string | null;
}

interface TokenBalanceResponse {
  balance?: number;
  isUnlimited?: boolean;
  error?: string;
}

export interface RemotePremiumSnapshot {
  activeSubscriptionProductId: ProductId | null;
  subscriptionExpiresAt: string | null;
  tokenBalance: number | null;
  isUnlimited: boolean;
  syncedAt: string;
}

function isProductId(value: unknown): value is ProductId {
  return typeof value === 'string' && value in productCatalog;
}

async function fetchActiveSubscription(session: Session) {
  if (!supabase) {
    return null;
  }

  const { data, error } = await supabase
    .from('subscriptions')
    .select('product_id, expires_at')
    .eq('user_id', session.user.id)
    .eq('status', 'active')
    .gt('expires_at', new Date().toISOString())
    .order('expires_at', { ascending: false })
    .limit(1)
    .maybeSingle<RemoteSubscriptionRow>();

  if (error) {
    throw error;
  }

  if (!data || !isProductId(data.product_id)) {
    return null;
  }

  return {
    productId: data.product_id,
    expiresAt: data.expires_at ?? null,
  };
}

async function fetchTokenBalance(session: Session) {
  if (!appEnv.isSupabaseConfigured) {
    return null;
  }

  const response = await fetch(`${appEnv.supabaseUrl}/functions/v1/token-balance`, {
    method: 'GET',
    headers: {
      Authorization: `Bearer ${session.access_token}`,
      apikey: appEnv.supabaseAnonKey,
      'Content-Type': 'application/json',
    },
  });

  const payload = (await response.json()) as TokenBalanceResponse;

  if (!response.ok) {
    throw new Error(payload.error ?? `token-balance:${response.status}`);
  }

  return {
    balance:
      typeof payload.balance === 'number' && Number.isFinite(payload.balance)
        ? payload.balance
        : null,
    isUnlimited: payload.isUnlimited === true,
  };
}

export async function fetchRemotePremiumSnapshot(
  session: Session,
): Promise<RemotePremiumSnapshot | null> {
  if (!supabase || !appEnv.isSupabaseConfigured) {
    return null;
  }

  const [subscription, tokenBalance] = await Promise.all([
    fetchActiveSubscription(session),
    fetchTokenBalance(session).catch(() => null),
  ]);

  return {
    activeSubscriptionProductId: subscription?.productId ?? null,
    subscriptionExpiresAt: subscription?.expiresAt ?? null,
    tokenBalance: tokenBalance?.balance ?? null,
    isUnlimited: tokenBalance?.isUnlimited === true,
    syncedAt: new Date().toISOString(),
  };
}
