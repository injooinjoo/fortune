import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { FORTUNE_TOKEN_COSTS } from '../_shared/types.ts'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

/**
 * 토큰 환불 Edge Function
 *
 * POST /soul-refund
 * Body: { fortuneType: string, reason?: string }
 *
 * 운세 생성 실패 시 선차감된 토큰을 환불합니다.
 *
 * Response:
 * {
 *   "balance": {
 *     "totalTokens": 500,
 *     "usedTokens": 14,
 *     "remainingTokens": 486,
 *     "lastUpdated": "2025-12-21T10:00:00Z",
 *     "hasUnlimitedAccess": false
 *   }
 * }
 */
serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response(null, { headers: corsHeaders })
  }

  // POST only
  if (req.method !== 'POST') {
    return new Response(
      JSON.stringify({ error: 'Method not allowed' }),
      {
        status: 405,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      }
    )
  }

  try {
    // Auth
    const authHeader = req.headers.get('Authorization')
    if (!authHeader) {
      return new Response(
        JSON.stringify({ error: 'No authorization' }),
        {
          status: 401,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      )
    }

    // Body
    const body = await req.json()
    const { fortuneType, reason, referenceId } = body

    // /ultrareview BM P0 #2: referenceId 필수.
    // 환불은 1) 같은 user, 2) 같은 referenceId 의 'consume' transaction 이 존재하고,
    // 3) 그 referenceId 로 이미 환불 처리되지 않은 경우에만 허용. 위조/중복 환불 차단.
    if (!fortuneType) {
      return new Response(
        JSON.stringify({ error: 'Missing fortuneType' }),
        {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      )
    }
    if (!referenceId || typeof referenceId !== 'string' || referenceId.length === 0) {
      return new Response(
        JSON.stringify({ error: 'Missing referenceId — soul-consume 호출 시 발급된 id 필요' }),
        {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      )
    }

    console.log(`🔄 Soul refund request: fortuneType=${fortuneType}, reason=${reason}, referenceId=${referenceId}`)

    // Supabase client
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!

    const supabase = createClient(supabaseUrl, supabaseServiceKey, {
      auth: {
        autoRefreshToken: false,
        persistSession: false
      }
    })

    // User
    const token = authHeader.replace('Bearer ', '')
    const { data: { user }, error: userError } = await supabase.auth.getUser(token)

    if (userError || !user) {
      return new Response(
        JSON.stringify({ error: 'Authentication failed' }),
        {
          status: 401,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      )
    }

    console.log(`👤 User: ${user.id}`)

    // 1. 구독 유저는 환불 불필요 (토큰 차감 안됨)
    const { data: subscription } = await supabase
      .from('subscriptions')
      .select('id')
      .eq('user_id', user.id)
      .eq('status', 'active')
      .gt('expires_at', new Date().toISOString())
      .limit(1)
      .maybeSingle()

    if (subscription) {
      console.log(`⏭️ Subscriber — no refund needed`)
      // 현재 잔액 조회하여 반환
      const { data: tokenData } = await supabase
        .from('token_balance')
        .select('balance, total_earned, total_spent')
        .eq('user_id', user.id)
        .single()

      return new Response(
        JSON.stringify({
          balance: {
            totalTokens: tokenData?.total_earned ?? 0,
            usedTokens: tokenData?.total_spent ?? 0,
            remainingTokens: tokenData?.balance ?? 0,
            lastUpdated: new Date().toISOString(),
            hasUnlimitedAccess: true
          }
        }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // /ultrareview BM P0 #2: 원본 consume 트랜잭션 검증.
    // 1) 같은 (user_id, reference_id) 의 'consume' 이 존재하는지.
    // 2) 같은 reference_id 의 'refund' 가 이미 처리되지 않았는지 (idempotency).
    // 3) consume 의 amount 사용 (클라가 보낸 fortuneType 기준 cost 무시).
    const { data: consumeTxn, error: consumeLookupErr } = await supabase
      .from('token_transactions')
      .select('id, amount, transaction_type')
      .eq('user_id', user.id)
      .eq('reference_id', referenceId)
      .eq('transaction_type', 'consume')
      .order('created_at', { ascending: false })
      .limit(1)
      .maybeSingle()
    if (consumeLookupErr) {
      console.error(`❌ consume lookup 실패: ${consumeLookupErr.message}`)
      return new Response(
        JSON.stringify({ error: 'Refund verification failed' }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }
    if (!consumeTxn) {
      console.log(`❌ 원본 consume 없음 — referenceId=${referenceId} user=${user.id}`)
      return new Response(
        JSON.stringify({ error: 'No matching consume transaction for this referenceId' }),
        { status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const { data: existingRefund } = await supabase
      .from('token_transactions')
      .select('id')
      .eq('user_id', user.id)
      .eq('reference_id', referenceId)
      .eq('transaction_type', 'refund')
      .limit(1)
      .maybeSingle()
    if (existingRefund) {
      console.log(`🔁 이미 환불 처리됨 referenceId=${referenceId} — replay 무시`)
      // idempotent: 현재 잔액만 반환 (성공 응답)
      const { data: tokenData } = await supabase
        .from('token_balance')
        .select('balance, total_earned, total_spent')
        .eq('user_id', user.id)
        .single()
      return new Response(
        JSON.stringify({
          balance: {
            totalTokens: tokenData?.total_earned ?? 0,
            usedTokens: tokenData?.total_spent ?? 0,
            remainingTokens: tokenData?.balance ?? 0,
            lastUpdated: new Date().toISOString(),
            hasUnlimitedAccess: false
          }
        }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // 2. 환불할 토큰 수 — 원본 consume 의 amount 사용 (클라 fortuneType 비신뢰).
    // FORTUNE_TOKEN_COSTS lookup 은 fallback 용으로만 보존.
    const refundAmount = (consumeTxn.amount as number | null) ??
      (FORTUNE_TOKEN_COSTS[fortuneType as keyof typeof FORTUNE_TOKEN_COSTS] ?? 1)

    // 3. 현재 잔액 조회
    const { data: tokenData } = await supabase
      .from('token_balance')
      .select('balance, total_earned, total_spent')
      .eq('user_id', user.id)
      .single()

    const currentBalance = tokenData?.balance ?? 0
    const totalEarned = tokenData?.total_earned ?? 0
    const totalSpent = tokenData?.total_spent ?? 0

    // 4. 잔액 복구
    const newBalance = currentBalance + refundAmount
    const newTotalSpent = Math.max(0, totalSpent - refundAmount)

    const { error: updateError } = await supabase
      .from('token_balance')
      .upsert({
        user_id: user.id,
        balance: newBalance,
        total_earned: totalEarned,
        total_spent: newTotalSpent,
        updated_at: new Date().toISOString()
      }, { onConflict: 'user_id' })

    if (updateError) {
      console.error(`❌ Refund balance update failed: ${updateError.message}`)
      return new Response(
        JSON.stringify({ error: 'Failed to refund tokens' }),
        {
          status: 500,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      )
    }

    // 5. 환불 거래 이력 기록 — referenceId 박아서 DB UNIQUE 제약(아래 마이그레이션) 으로
    //    중복 환불 차단. application-level 위에서 이미 막지만 race 보호 안전망.
    const { error: txError } = await supabase
      .from('token_transactions')
      .insert({
        user_id: user.id,
        transaction_type: 'refund',
        amount: refundAmount,
        balance_after: newBalance,
        description: `${fortuneType} 환불 (${reason || 'fortune_generation_failed'})`,
        reference_type: 'fortune_refund',
        reference_id: referenceId,
      })

    if (txError) {
      console.error(`⚠️ Refund transaction record failed: ${txError.message}`)
    }

    console.log(`✅ Token refunded: ${currentBalance} → ${newBalance} (refund: ${refundAmount})`)

    return new Response(
      JSON.stringify({
        balance: {
          totalTokens: totalEarned,
          usedTokens: newTotalSpent,
          remainingTokens: newBalance,
          lastUpdated: new Date().toISOString(),
          hasUnlimitedAccess: false
        }
      }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    console.error('❌ Soul refund error:', error)
    return new Response(
      JSON.stringify({ error: 'Internal server error' }),
      {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      }
    )
  }
})
