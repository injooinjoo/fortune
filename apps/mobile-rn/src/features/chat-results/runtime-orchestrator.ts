import * as Crypto from 'expo-crypto';
import {
  fortuneTypesById,
  type FortuneTypeId,
} from '@fortune/product-contracts';
import type { Session } from '@supabase/supabase-js';

import type { MobileAppState } from '../../lib/mobile-app-state';
import {
  consumeRemoteTokens,
  refundRemoteTokens,
  RemoteTokenConsumeError,
} from '../../lib/premium-remote';
import { supabase } from '../../lib/supabase';
import {
  fetchEmbeddedEdgeResult,
  prepareEmbeddedEdgeInvocation,
} from './edge-runtime';
import type {
  EmbeddedResultBuildContext,
  EmbeddedResultPayload,
} from './types';

type UnknownRecord = Record<string, unknown>;

const DEFAULT_REUSE_WINDOW_HOURS = 24;

const reuseWindowHoursByFortuneType: Partial<Record<FortuneTypeId, number>> = {
  dream: 12,
  tarot: 12,
  wish: 12,
  talisman: 12,
  'face-reading': 72,
  'ootd-evaluation': 72,
};

type FortuneRuntimeBlockedReason =
  | 'login-required'
  | 'insufficient-tokens'
  | 'missing-input';

export type FortuneRuntimeOutcome =
  | {
      kind: 'success';
      source: 'personal-cache' | 'edge';
      payload: EmbeddedResultPayload;
      cacheHit: boolean;
    }
  | {
      kind: 'blocked';
      reason: FortuneRuntimeBlockedReason;
      message: string;
      routeToPremium?: boolean;
    }
  | {
      kind: 'failed';
      message: string;
      error?: unknown;
    };

interface FortuneResultsRow {
  result_data?: unknown;
  created_at?: string | null;
}

interface ResolveFortuneRuntimeParams {
  fortuneType: FortuneTypeId;
  context: EmbeddedResultBuildContext;
  session: Session | null;
  premiumState: MobileAppState['premium'];
  syncRemoteProfile?: () => Promise<MobileAppState | null>;
}

export async function resolveFortuneRuntimeOutcome(
  params: ResolveFortuneRuntimeParams,
): Promise<FortuneRuntimeOutcome> {
  const spec = fortuneTypesById[params.fortuneType];
  if (spec.isLocalOnly || !spec.endpoint) {
    return {
      kind: 'failed',
      message: '이 운세는 아직 원격 결과 연결 대상이 아니에요.',
    };
  }

  if (!params.session) {
    return {
      kind: 'blocked',
      reason: 'login-required',
      message:
        '로그인이 필요해요. 결과 저장과 재호출 재사용까지 묶어서 처리하려면 먼저 로그인해주세요.',
    };
  }

  const prepared = prepareEmbeddedEdgeInvocation(
    params.fortuneType,
    params.context,
    {
      userId: params.session.user.id,
    },
  );

  if (!prepared) {
    return {
      kind: 'blocked',
      reason: 'missing-input',
      message:
        '이 결과를 만들 정보가 아직 부족해요. 프로필이나 질문 답변을 먼저 확인해주세요.',
    };
  }

  const conditionsData = buildConditionsData(prepared.body);
  const conditionsHash = await buildConditionsHash(conditionsData);

  const persistedResult = await readPersistedFortuneResult({
    userId: params.session.user.id,
    fortuneType: params.fortuneType,
    conditionsHash,
  });

  if (persistedResult) {
    return {
      kind: 'success',
      source: 'personal-cache',
      payload: persistedResult,
      cacheHit: true,
    };
  }

  const referenceId = buildReferenceId(params.fortuneType, conditionsHash);
  const premiumState = await ensureAvailablePremiumState(
    params.fortuneType,
    params.premiumState,
    params.syncRemoteProfile,
  );

  if (!premiumState.isUnlimited && premiumState.tokenBalance <= 0 && params.fortuneType !== 'daily') {
    return {
      kind: 'blocked',
      reason: 'insufficient-tokens',
      message: '토큰이 부족해요. 이용권을 충전한 뒤 다시 이어서 볼 수 있어요.',
      routeToPremium: true,
    };
  }

  try {
    await consumeRemoteTokens(params.session, {
      fortuneType: params.fortuneType,
      referenceId,
    });

    await params.syncRemoteProfile?.().catch(() => null);
  } catch (error) {
    await params.syncRemoteProfile?.().catch(() => null);

    if (error instanceof RemoteTokenConsumeError) {
      if (error.code === 'UNAUTHORIZED') {
        return {
          kind: 'blocked',
          reason: 'login-required',
          message:
            '로그인 세션을 다시 확인해야 해요. 다시 로그인한 뒤 이어서 요청해주세요.',
        };
      }

      if (error.code === 'INSUFFICIENT_TOKENS') {
        return {
          kind: 'blocked',
          reason: 'insufficient-tokens',
          message: '토큰이 부족해요. 이용권을 충전한 뒤 다시 이어서 볼 수 있어요.',
          routeToPremium: true,
        };
      }
    }

    return {
      kind: 'failed',
      message: '토큰 확인 중 문제가 생겼어요. 잠시 후 다시 시도해주세요.',
      error,
    };
  }

  try {
    const edgeResult = await fetchEmbeddedEdgeResult(
      params.fortuneType,
      params.context,
      {
        userId: params.session.user.id,
      },
    );

    if (!edgeResult) {
      return {
        kind: 'failed',
        message: '실제 운세 결과를 준비하지 못했어요. 잠시 후 다시 시도해주세요.',
      };
    }

    await persistFortuneResult({
      userId: params.session.user.id,
      fortuneType: params.fortuneType,
      conditionsHash,
      conditionsData,
      resultData: edgeResult.payload as unknown as UnknownRecord,
      source: deriveStoredSource(edgeResult.rawResult),
      apiCall: deriveApiCall(edgeResult.rawResult),
    });

    return {
      kind: 'success',
      source: 'edge',
      payload: edgeResult.payload,
      cacheHit: false,
    };
  } catch (error) {
    await refundConsumedTokens(params.session, params.fortuneType);
    await params.syncRemoteProfile?.().catch(() => null);

    return {
      kind: 'failed',
      message:
        '실제 운세 결과를 불러오지 못했어요. 토큰은 다시 복구했고 잠시 후 다시 시도해주세요.',
      error,
    };
  }
}

async function ensureAvailablePremiumState(
  fortuneType: FortuneTypeId,
  premiumState: MobileAppState['premium'],
  syncRemoteProfile?: () => Promise<MobileAppState | null>,
) {
  if (premiumState.isUnlimited || fortuneType === 'daily' || premiumState.tokenBalance > 0) {
    return premiumState;
  }

  const refreshedState = await syncRemoteProfile?.().catch(() => null);
  return refreshedState?.premium ?? premiumState;
}

async function readPersistedFortuneResult(input: {
  userId: string;
  fortuneType: FortuneTypeId;
  conditionsHash: string;
}): Promise<EmbeddedResultPayload | null> {
  if (!supabase) {
    return null;
  }

  const reuseWindowStart = new Date(
    Date.now() - getReuseWindowHours(input.fortuneType) * 60 * 60 * 1000,
  ).toISOString();

  const { data, error } = await supabase
    .from('fortune_results')
    .select('result_data, created_at')
    .eq('user_id', input.userId)
    .eq('fortune_type', input.fortuneType)
    .eq('conditions_hash', input.conditionsHash)
    .gte('created_at', reuseWindowStart)
    .order('created_at', { ascending: false })
    .limit(1)
    .maybeSingle<FortuneResultsRow>();

  if (error || !data) {
    return null;
  }

  const payload = asEmbeddedResultPayload(data.result_data);
  return payload?.fortuneType === input.fortuneType ? payload : null;
}

async function persistFortuneResult(input: {
  userId: string;
  fortuneType: FortuneTypeId;
  conditionsHash: string;
  conditionsData: UnknownRecord;
  resultData: UnknownRecord;
  source: 'api' | 'personal_cache' | 'db_pool' | 'random_selection';
  apiCall: boolean;
}) {
  if (!supabase) {
    return;
  }

  const now = new Date();

  await supabase
    .from('fortune_results')
    .upsert(
      {
        user_id: input.userId,
        fortune_type: input.fortuneType,
        result_data: input.resultData,
        conditions_hash: input.conditionsHash,
        conditions_data: input.conditionsData,
        date: formatLocalDate(now),
        api_call: input.apiCall,
        source: input.source,
      },
      {
        onConflict: 'user_id,fortune_type,date,conditions_hash',
      },
    );
}

async function refundConsumedTokens(session: Session, fortuneType: FortuneTypeId) {
  try {
    await refundRemoteTokens(session, {
      fortuneType,
      reason: 'fortune_runtime_failed_after_consume',
    });
  } catch {
    return;
  }
}

function buildReferenceId(fortuneType: FortuneTypeId, conditionsHash: string) {
  return `${fortuneType}:${formatLocalDate(new Date())}:${conditionsHash}`;
}

async function buildConditionsHash(conditionsData: UnknownRecord) {
  const stableText = stableStringify(conditionsData);
  const digest = await Crypto.digestStringAsync(
    Crypto.CryptoDigestAlgorithm.SHA256,
    stableText,
    { encoding: Crypto.CryptoEncoding.HEX },
  );

  return digest.slice(0, 16);
}

function buildConditionsData(body: UnknownRecord) {
  const normalized = { ...body };
  delete normalized.userId;
  delete normalized.user_id;

  return sanitizeConditionValue(normalized) as UnknownRecord;
}

function getReuseWindowHours(fortuneType: FortuneTypeId) {
  return reuseWindowHoursByFortuneType[fortuneType] ?? DEFAULT_REUSE_WINDOW_HOURS;
}

function deriveStoredSource(value: unknown) {
  const record = asRecord(value);
  if (record.cohortHit === true) {
    return 'db_pool' as const;
  }
  if (record.cached === true) {
    return 'personal_cache' as const;
  }
  return 'api' as const;
}

function deriveApiCall(value: unknown) {
  const record = asRecord(value);
  return record.cohortHit !== true && record.cached !== true;
}

function asEmbeddedResultPayload(value: unknown): EmbeddedResultPayload | null {
  const payload = asRecord(value);
  if (
    payload.widgetType !== 'fortune_result_card' ||
    typeof payload.fortuneType !== 'string' ||
    typeof payload.resultKind !== 'string'
  ) {
    return null;
  }

  return payload as unknown as EmbeddedResultPayload;
}

function stableStringify(value: unknown): string {
  return JSON.stringify(sortValue(value));
}

function sortValue(value: unknown): unknown {
  if (Array.isArray(value)) {
    return value.map((item) => sortValue(item));
  }

  if (!isPlainObject(value)) {
    return value;
  }

  return Object.keys(value)
    .sort()
    .reduce<Record<string, unknown>>((accumulator, key) => {
      accumulator[key] = sortValue((value as UnknownRecord)[key]);
      return accumulator;
    }, {});
}

function sanitizeConditionValue(value: unknown): unknown {
  if (Array.isArray(value)) {
    return value.map((item) => sanitizeConditionValue(item));
  }

  if (typeof value === 'string') {
    return sanitizeLargeString(value);
  }

  if (!isPlainObject(value)) {
    return value;
  }

  return Object.keys(value).reduce<Record<string, unknown>>((accumulator, key) => {
    accumulator[key] = sanitizeConditionValue((value as UnknownRecord)[key]);
    return accumulator;
  }, {});
}

function sanitizeLargeString(value: string) {
  if (value.length < 256) {
    return value;
  }

  return `[sha256:${simpleHash(value)}|len:${value.length}]`;
}

function isPlainObject(value: unknown): value is UnknownRecord {
  return typeof value === 'object' && value !== null && !Array.isArray(value);
}

function asRecord(value: unknown): UnknownRecord {
  return isPlainObject(value) ? value : {};
}

function formatLocalDate(date: Date) {
  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, '0');
  const day = String(date.getDate()).padStart(2, '0');
  return `${year}-${month}-${day}`;
}

function simpleHash(value: string) {
  let hash = 0;
  for (let index = 0; index < value.length; index += 1) {
    hash = (hash * 31 + value.charCodeAt(index)) >>> 0;
  }

  return hash.toString(16).padStart(8, '0');
}
