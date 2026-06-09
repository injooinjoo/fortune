// 공통 토큰 차감 / 환불 헬퍼.
// generate-character-proactive-image, generate-friend-avatar, soul-consume,
// soul-refund 등에 동일 로직 산재 → 단일 진실로 통합.
//
// PR-0a: atomic RPC (consume_token_atomic / refund_token_atomic) 위임.
// 잔액 update + 거래 insert 가 동일 트랜잭션 안에서 이루어져 부분 실패/race 차단.
// idempotency_key 옵션 추가 — 같은 키 재전송 시 1회만 차감.

import type { SupabaseClient } from "https://esm.sh/@supabase/supabase-js@2";

export interface ChargeContext {
  /** 차감 사유 (DB description). 예: '캐릭터 선톡 이미지' */
  description: string;
  /** token_transactions.reference_type */
  referenceType: string;
  /** 선택: token_transactions.reference_id */
  referenceId?: string | null;
  /** PR-0a: 같은 키 재전송 시 1회만 차감. 클라가 생성. */
  idempotencyKey?: string | null;
}

export interface ChargeResult {
  /** 차감 성공 여부. false 면 잔액 부족. */
  charged: boolean;
  /** Legacy 호환 필드. 구독도 유한 토큰 할당권이므로 항상 false. */
  unlimited: boolean;
  /** 차감 직전 잔액. 환불 시 복원에 사용 (legacy). */
  balanceBeforeCharge: number;
  /** 차감 후 잔액. */
  balanceAfter: number;
  /** PR-0a: 같은 idempotency_key 가 이미 처리됨 — 새 차감 안 함. */
  replayed: boolean;
  /** PR-0a: 거래 ID. 환불 호출 시 reference 로 활용 가능. */
  transactionId: string | null;
}

/**
 * 토큰 차감. 잔액 부족이면 charged=false.
 * 호출자는 charged=false 일 때 작업 (LLM 호출/이미지생성 등) 을 차단해야 한다.
 *
 * 성공 시 charged=true 후 작업 수행, 실패하면 refundTokens()
 * 로 환불해야 한다 — 호출자 책임.
 *
 * PR-0a: ctx.idempotencyKey 가 있으면 같은 키 재전송 시 1회만 차감.
 */
export async function chargeTokens(
  supabase: SupabaseClient,
  userId: string,
  amount: number,
  ctx: ChargeContext,
): Promise<ChargeResult> {
  const { data: rpcResult, error: rpcError } = await supabase.rpc(
    "consume_token_atomic",
    {
      p_user_id: userId,
      p_cost: amount,
      p_description: ctx.description,
      p_reference_type: ctx.referenceType,
      p_reference_id: ctx.referenceId ?? null,
      p_idempotency_key: ctx.idempotencyKey ?? null,
    },
  );

  if (rpcError) {
    // INSUFFICIENT_TOKENS = P0001
    if ((rpcError as { code?: string }).code === "P0001") {
      const { data: tokenData } = await supabase
        .from("token_balance")
        .select("balance")
        .eq("user_id", userId)
        .maybeSingle();
      const currentBalance = tokenData?.balance ?? 0;
      return {
        charged: false,
        unlimited: false,
        balanceBeforeCharge: currentBalance,
        balanceAfter: currentBalance,
        replayed: false,
        transactionId: null,
      };
    }
    throw rpcError;
  }

  const result = rpcResult as {
    balance: number;
    total_earned: number;
    total_spent: number;
    replayed: boolean;
    transaction_id: string;
  };

  return {
    charged: true,
    unlimited: false,
    balanceBeforeCharge: result.balance + amount,
    balanceAfter: result.balance,
    replayed: result.replayed,
    transactionId: result.transaction_id,
  };
}

/**
 * 작업 실패 시 차감한 토큰을 원상복원.
 * chargeResult.charged=true 인 경우에만 호출해야 의미 있음.
 *
 * PR-0a: atomic RPC 위임. 같은 reference_id 로 이미 환불됐으면 idempotent 처리.
 *
 * 호환성:
 * - 기존 호출자가 amount/balanceBeforeCharge 를 넘기지만 RPC 는 원본 consume 의
 *   amount 를 사용. 기존 인자는 무시 (legacy 시그니처 유지).
 * - referenceId 가 없으면 환불 불가 (이전엔 referenceId 무시하고 환불 가능했음).
 *   → 이 헬퍼를 쓰는 호출자는 chargeTokens 호출 시 referenceId 항상 전달해야 함.
 */
export async function refundTokens(
  supabase: SupabaseClient,
  userId: string,
  _amount: number,
  _balanceBeforeCharge: number,
  ctx: ChargeContext,
): Promise<void> {
  if (!ctx.referenceId) {
    console.warn(
      "[token_charge.refundTokens] referenceId 없음 — 환불 skip (legacy fallback 미지원).",
    );
    return;
  }

  // /codex review P2: ctx.idempotencyKey 는 consume row 가 이미 사용 중. 같은 키
  // 그대로 환불 INSERT 하면 partial unique index (idempotency_key) 충돌로 환불
  // 누락. consume key 에 ':refund' suffix 붙여 같은 ctx 재사용 안전하게.
  const refundIdempotencyKey = ctx.idempotencyKey
    ? `${ctx.idempotencyKey}:refund`
    : null;

  const { error: rpcError } = await supabase.rpc("refund_token_atomic", {
    p_user_id: userId,
    p_consume_reference_id: ctx.referenceId,
    p_description: `${ctx.description} 실패 환불`,
    p_reference_type: ctx.referenceType,
    p_idempotency_key: refundIdempotencyKey,
  });

  if (rpcError) {
    // NO_MATCHING_CONSUME = P0002 — 차감이 RPC 도입 전이거나 referenceId 누락.
    // 무한 루프/잘못된 환불 방지로 throw 보다 로깅.
    if ((rpcError as { code?: string }).code === "P0002") {
      console.warn(
        `[token_charge.refundTokens] 원본 consume 없음 — referenceId=${ctx.referenceId}, user=${userId}. legacy 데이터일 수 있음.`,
      );
      return;
    }
    console.error(
      `[token_charge.refundTokens] RPC 실패 — userId=${userId}, ref=${ctx.referenceId}:`,
      rpcError,
    );
  }
}
