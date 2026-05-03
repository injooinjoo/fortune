// 공통 토큰 차감 / 환불 / 무제한 구독 체크 헬퍼.
// generate-character-proactive-image, generate-friend-avatar, soul-consume,
// soul-refund 등 4곳에 동일 로직이 흩어져 있어 단가 변경 시 누락 위험. 단일 진실로 통합.

import type { SupabaseClient } from "https://esm.sh/@supabase/supabase-js@2";

export interface ChargeContext {
  /** 차감 사유 (DB description). 예: '캐릭터 선톡 이미지' */
  description: string;
  /** token_transactions.reference_type */
  referenceType: string;
  /** 선택: token_transactions.reference_id */
  referenceId?: string | null;
}

export interface ChargeResult {
  /** 차감 성공 여부. false 면 잔액 부족. */
  charged: boolean;
  /** 무제한 구독자라 차감 자체를 skip 했는지. */
  unlimited: boolean;
  /** 차감 직전 잔액 (환불 시 복원에 사용). */
  balanceBeforeCharge: number;
  /** 차감 후 잔액. */
  balanceAfter: number;
}

export async function hasUnlimitedSubscription(
  supabase: SupabaseClient,
  userId: string,
): Promise<boolean> {
  const { data } = await supabase
    .from("subscriptions")
    .select("id")
    .eq("user_id", userId)
    .eq("status", "active")
    .gt("expires_at", new Date().toISOString())
    .limit(1)
    .maybeSingle();
  return !!data;
}

/**
 * 토큰 차감. 무제한 구독자는 통과. 잔액 부족이면 charged=false.
 * 호출자는 charged=false 일 때 작업 (LLM 호출/이미지생성 등) 을 차단해야 한다.
 *
 * 성공 시 (charged=true || unlimited=true) 작업 수행 후 실패하면 refundTokens()
 * 로 환불해야 한다 — 호출자 책임.
 */
export async function chargeTokens(
  supabase: SupabaseClient,
  userId: string,
  amount: number,
  ctx: ChargeContext,
): Promise<ChargeResult> {
  if (await hasUnlimitedSubscription(supabase, userId)) {
    return {
      charged: false,
      unlimited: true,
      balanceBeforeCharge: 0,
      balanceAfter: 0,
    };
  }

  const { data: tokenData } = await supabase
    .from("token_balance")
    .select("balance, total_spent")
    .eq("user_id", userId)
    .maybeSingle();

  const balanceBeforeCharge = tokenData?.balance ?? 0;
  const totalSpent = tokenData?.total_spent ?? 0;

  if (balanceBeforeCharge < amount) {
    return {
      charged: false,
      unlimited: false,
      balanceBeforeCharge,
      balanceAfter: balanceBeforeCharge,
    };
  }

  const balanceAfter = balanceBeforeCharge - amount;

  await supabase.from("token_balance").upsert(
    {
      user_id: userId,
      balance: balanceAfter,
      total_spent: totalSpent + amount,
      updated_at: new Date().toISOString(),
    },
    { onConflict: "user_id" },
  );

  await supabase.from("token_transactions").insert({
    user_id: userId,
    transaction_type: "consumption",
    amount: -amount,
    balance_after: balanceAfter,
    description: ctx.description,
    reference_type: ctx.referenceType,
    reference_id: ctx.referenceId ?? null,
  });

  return {
    charged: true,
    unlimited: false,
    balanceBeforeCharge,
    balanceAfter,
  };
}

/**
 * 작업 실패 시 차감한 토큰을 원상복원.
 * chargeResult.charged=true 인 경우에만 호출해야 의미 있음.
 */
export async function refundTokens(
  supabase: SupabaseClient,
  userId: string,
  amount: number,
  balanceBeforeCharge: number,
  ctx: ChargeContext,
): Promise<void> {
  await supabase.from("token_balance").upsert(
    {
      user_id: userId,
      balance: balanceBeforeCharge,
      updated_at: new Date().toISOString(),
    },
    { onConflict: "user_id" },
  );

  await supabase.from("token_transactions").insert({
    user_id: userId,
    transaction_type: "refund",
    amount: amount,
    balance_after: balanceBeforeCharge,
    description: `${ctx.description} 실패 환불`,
    reference_type: ctx.referenceType,
    reference_id: ctx.referenceId ?? null,
  });
}
