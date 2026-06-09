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
  alreadyGranted?: boolean;
  balance?: number;
  error?: string;
}

interface SubscriptionActivationResponse {
  success?: boolean;
  expiresAt?: string;
  productId?: string;
  error?: string;
}

interface TokenConsumeBalancePayload {
  remainingTokens?: number;
  hasUnlimitedAccess?: boolean;
}

interface TokenConsumeResponse {
  balance?: TokenConsumeBalancePayload;
  code?: string;
  message?: string;
  required?: number;
  available?: number;
  error?: string;
  /** PR-0a: idempotency 재전송 시 true. */
  replayed?: boolean;
  /** PR-0a: 거래 ID. */
  transactionId?: string;
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
  alreadyGranted: boolean;
  balance: number | null;
  transactionId: string | null;
  valid: boolean;
}

export type RemoteTokenConsumeErrorCode =
  | 'UNAUTHORIZED'
  | 'INSUFFICIENT_TOKENS'
  | 'UNKNOWN';

export class RemoteTokenConsumeError extends Error {
  readonly code: RemoteTokenConsumeErrorCode;
  readonly required: number | null;
  readonly available: number | null;

  constructor(
    code: RemoteTokenConsumeErrorCode,
    message: string,
    options?: {
      required?: number | null;
      available?: number | null;
    },
  ) {
    super(message);
    this.code = code;
    this.required = options?.required ?? null;
    this.available = options?.available ?? null;
  }
}

export interface RemoteTokenConsumePayload {
  fortuneType: string;
  referenceId?: string | null;
  /** PR-0a: 같은 키 재전송 시 1회만 차감. 클라가 호출 단위 unique 값으로 생성. */
  idempotencyKey?: string | null;
}

export interface RemoteTokenConsumeResult {
  balance: number | null;
  isUnlimited: boolean;
  /** PR-0a: idempotency_key 가 이미 처리됐는지. UI 로직에 활용 가능. */
  replayed?: boolean;
  /** PR-0a: 거래 ID. 환불 호출 시 reference 로 활용 가능. */
  transactionId?: string | null;
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

const TOKEN_BALANCE_CACHE_TTL_MS = 5 * 60 * 1000; // 5 minutes

let tokenBalanceCache: {
  userId: string;
  result: { balance: number | null; isUnlimited: boolean };
  fetchedAt: number;
} | null = null;

async function fetchTokenBalance(session: Session) {
  if (!appEnv.isSupabaseConfigured) {
    return null;
  }

  // Return cached result if still fresh and same user
  const now = Date.now();
  if (
    tokenBalanceCache &&
    tokenBalanceCache.userId === session.user.id &&
    now - tokenBalanceCache.fetchedAt < TOKEN_BALANCE_CACHE_TTL_MS
  ) {
    return tokenBalanceCache.result;
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

  const result = {
    balance:
      typeof payload.balance === 'number' && Number.isFinite(payload.balance)
        ? payload.balance
        : null,
    isUnlimited: payload.isUnlimited === true,
  };

  tokenBalanceCache = {
    userId: session.user.id,
    result,
    fetchedAt: now,
  };

  return result;
}

/**
 * Invalidate the token balance cache so the next fetch hits the server.
 * Call after token-consuming operations (purchases, fortune consumption).
 */
export function invalidateTokenBalanceCache() {
  tokenBalanceCache = null;
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
  // Invalidate cached balance — purchase adds tokens
  invalidateTokenBalanceCache();

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
    alreadyGranted: result.alreadyGranted === true,
    balance:
      typeof result.balance === 'number' && Number.isFinite(result.balance)
        ? result.balance
        : null,
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

export async function consumeRemoteTokens(
  session: Session,
  payload: RemoteTokenConsumePayload,
  options: { signal?: AbortSignal } = {},
): Promise<RemoteTokenConsumeResult> {
  // Invalidate cached balance — consumption changes it
  invalidateTokenBalanceCache();

  if (!appEnv.isSupabaseConfigured) {
    throw new RemoteTokenConsumeError(
      'UNKNOWN',
      'Supabase 설정이 없어 토큰 차감을 진행할 수 없습니다.',
    );
  }

  const response = await fetch(`${appEnv.supabaseUrl}/functions/v1/soul-consume`, {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${session.access_token}`,
      apikey: appEnv.supabaseAnonKey,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      fortuneType: payload.fortuneType,
      referenceId: payload.referenceId ?? null,
      idempotencyKey: payload.idempotencyKey ?? null,
    }),
    signal: options.signal,
  });

  const result = (await response.json()) as TokenConsumeResponse;

  if (!response.ok) {
    if (response.status === 401) {
      throw new RemoteTokenConsumeError(
        'UNAUTHORIZED',
        result.error ?? '로그인이 필요합니다.',
      );
    }

    if (result.code === 'INSUFFICIENT_TOKENS') {
      throw new RemoteTokenConsumeError(
        'INSUFFICIENT_TOKENS',
        result.message ?? '토큰이 부족합니다.',
        {
          required:
            typeof result.required === 'number' && Number.isFinite(result.required)
              ? result.required
              : null,
          available:
            typeof result.available === 'number' && Number.isFinite(result.available)
              ? result.available
              : null,
        },
      );
    }

    throw new RemoteTokenConsumeError(
      'UNKNOWN',
      result.error ?? result.message ?? `soul-consume:${response.status}`,
    );
  }

  return {
    balance:
      typeof result.balance?.remainingTokens === 'number' &&
      Number.isFinite(result.balance.remainingTokens)
        ? result.balance.remainingTokens
        : null,
    isUnlimited: result.balance?.hasUnlimitedAccess === true,
    replayed: result.replayed === true,
    transactionId: result.transactionId ?? null,
  };
}

/**
 * PR-0a: 토큰 환불 호출. 운세 결과 생성이 차감 후 실패한 경우 호출.
 *
 * referenceId 는 차감 시 보낸 referenceId 와 동일해야 한다 — 서버가 그 reference 로
 * 원본 consume 을 찾는다. idempotencyKey 는 환불 자체의 unique key (다른 키 권장).
 *
 * 실패해도 throw 하지 않음 — 환불 누락이 사용자 흐름을 막아선 안 됨. 호출자는
 * 실패 시 captureError 같은 운영 채널로 보고만 한다.
 */
export async function refundRemoteTokens(
  session: Session,
  payload: {
    fortuneType: string;
    referenceId: string;
    reason?: string;
    idempotencyKey?: string | null;
  },
): Promise<{
  success: boolean;
  refunded?: boolean;
  replayed?: boolean;
  balance?: number | null;
}> {
  if (!appEnv.isSupabaseConfigured) {
    return { success: false };
  }

  try {
    invalidateTokenBalanceCache();

    const response = await fetch(
      `${appEnv.supabaseUrl}/functions/v1/soul-refund`,
      {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${session.access_token}`,
          apikey: appEnv.supabaseAnonKey,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          fortuneType: payload.fortuneType,
          referenceId: payload.referenceId,
          reason: payload.reason ?? 'fortune_generation_failed',
          idempotencyKey: payload.idempotencyKey ?? null,
        }),
      },
    );

    const result = (await response.json()) as {
      balance?: TokenConsumeBalancePayload;
      refunded?: boolean;
      replayed?: boolean;
      error?: string;
    };

    if (!response.ok) {
      return { success: false };
    }

    return {
      success: true,
      refunded: result.refunded === true,
      replayed: result.replayed === true,
      balance:
        typeof result.balance?.remainingTokens === 'number' &&
        Number.isFinite(result.balance.remainingTokens)
          ? result.balance.remainingTokens
          : null,
    };
  } catch {
    return { success: false };
  }
}
