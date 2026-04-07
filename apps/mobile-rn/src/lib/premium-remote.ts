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

interface PurchaseVerificationResponse {
  valid?: boolean;
  productId?: string;
  transactionId?: string;
  tokensAdded?: number;
  error?: string;
}

interface SubscriptionActivationResponse {
  success?: boolean;
  expiresAt?: string;
  productId?: string;
  error?: string;
}

export interface RemotePremiumSnapshot {
  activeSubscriptionProductId: ProductId | null;
  subscriptionExpiresAt: string | null;
  tokenBalance: number | null;
  isUnlimited: boolean;
  syncedAt: string;
}

export interface RemotePurchaseVerificationPayload {
  platform: 'ios' | 'android';
  productId: ProductId;
  purchaseToken?: string | null;
  receipt?: string | null;
  orderId?: string | null;
  packageName?: string | null;
  transactionId?: string | null;
}

export interface RemotePurchaseVerificationResult {
  productId: ProductId;
  tokensAdded: number;
  transactionId: string | null;
  valid: boolean;
}

export interface RemoteSubscriptionActivationPayload {
  platform: 'ios' | 'android';
  productId: ProductId;
  purchaseId?: string | null;
}

function isProductId(value: unknown): value is ProductId {
  return typeof value === 'string' && value in productCatalog;
}

async function callPremiumFunction<TResponse>(
  session: Session,
  functionName: string,
  body: Record<string, unknown>,
): Promise<TResponse> {
  const response = await fetch(
    `${appEnv.supabaseUrl}/functions/v1/${functionName}`,
    {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${session.access_token}`,
        apikey: appEnv.supabaseAnonKey,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(body),
    },
  );

  const payload = (await response.json()) as TResponse & { error?: string };

  if (!response.ok) {
    throw new Error(payload.error ?? `${functionName}:${response.status}`);
  }

  return payload;
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

export async function verifyRemotePurchase(
  session: Session,
  payload: RemotePurchaseVerificationPayload,
): Promise<RemotePurchaseVerificationResult> {
  if (!appEnv.isSupabaseConfigured) {
    throw new Error('Supabase 설정이 없어 구매 검증을 진행할 수 없습니다.');
  }

  const result = await callPremiumFunction<PurchaseVerificationResponse>(
    session,
    'payment-verify-purchase',
    { ...payload },
  );

  if (!result.valid) {
    throw new Error(result.error ?? '구매 검증에 실패했습니다.');
  }

  const verifiedProductId = isProductId(result.productId)
    ? result.productId
    : payload.productId;

  return {
    valid: true,
    productId: verifiedProductId,
    tokensAdded:
      typeof result.tokensAdded === 'number' && Number.isFinite(result.tokensAdded)
        ? result.tokensAdded
        : 0,
    transactionId:
      typeof result.transactionId === 'string' && result.transactionId.length > 0
        ? result.transactionId
        : payload.transactionId ?? null,
  };
}

export async function activateRemoteSubscription(
  session: Session,
  payload: RemoteSubscriptionActivationPayload,
): Promise<void> {
  if (!appEnv.isSupabaseConfigured) {
    throw new Error('Supabase 설정이 없어 구독 활성화를 진행할 수 없습니다.');
  }

  const result = await callPremiumFunction<SubscriptionActivationResponse>(
    session,
    'subscription-activate',
    {
      platform: payload.platform,
      productId: payload.productId,
      purchaseId: payload.purchaseId ?? null,
    },
  );

  if (!result.success) {
    throw new Error(result.error ?? '구독 활성화에 실패했습니다.');
  }
}
