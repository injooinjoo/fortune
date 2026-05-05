import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

/**
 * 토큰 환불 Edge Function
 *
 * POST /soul-refund
 * Body: {
 *   fortuneType: string,
 *   referenceId: string (필수 — 원본 consume 의 reference_id),
 *   reason?: string,
 *   idempotencyKey?: string (PR-0a — 환불 자체의 키. 없으면 reference_id 만으로 중복 방지)
 * }
 *
 * Response:
 * {
 *   "balance": { ... },
 *   "refunded": bool,    -- 신규 환불 수행 여부
 *   "replayed": bool     -- 이미 환불됨 (idempotent 응답)
 * }
 */
serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response(null, { headers: corsHeaders })
  }

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

    const body = await req.json()
    const { fortuneType, reason, referenceId, idempotencyKey } = body as {
      fortuneType?: string
      reason?: string
      referenceId?: string
      idempotencyKey?: string | null
    }

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

    console.log(
      `🔄 Soul refund: fortuneType=${fortuneType}, reason=${reason}, ` +
      `referenceId=${referenceId}, hasIdempotencyKey=${!!idempotencyKey}`,
    )

    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!

    const supabase = createClient(supabaseUrl, supabaseServiceKey, {
      auth: {
        autoRefreshToken: false,
        persistSession: false
      }
    })

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

    // 1. 무제한 구독자는 환불 불필요. RPC 밖 — 토큰 차감 자체가 없었음.
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
          },
          refunded: false,
          replayed: false,
        }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // 2. atomic RPC 호출
    const { data: rpcResult, error: rpcError } = await supabase.rpc(
      'refund_token_atomic',
      {
        p_user_id: user.id,
        p_consume_reference_id: referenceId,
        p_description: `${fortuneType} 환불 (${reason || 'fortune_generation_failed'})`,
        p_reference_type: 'fortune_refund',
        p_idempotency_key: idempotencyKey ?? null,
      },
    )

    if (rpcError) {
      // NO_MATCHING_CONSUME = SQLSTATE P0002
      if (rpcError.code === 'P0002') {
        console.log(`❌ No matching consume: ${rpcError.details ?? rpcError.message}`)
        return new Response(
          JSON.stringify({ error: 'No matching consume transaction for this referenceId' }),
          { status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
      }

      console.error('❌ refund_token_atomic RPC failed:', rpcError)
      return new Response(
        JSON.stringify({ error: 'Failed to refund tokens' }),
        {
          status: 500,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      )
    }

    const result = rpcResult as {
      balance: number
      total_earned: number
      total_spent: number
      refunded: boolean
      replayed: boolean
      refund_transaction_id: string
      original_transaction_id?: string
      refund_amount?: number
    }

    if (result.replayed) {
      console.log(
        `🔁 Already refunded: txn=${result.refund_transaction_id}, balance=${result.balance}`,
      )
    } else {
      console.log(
        `✅ Token refunded: amount=${result.refund_amount}, ` +
        `balance=${result.balance}, txn=${result.refund_transaction_id}`,
      )
    }

    return new Response(
      JSON.stringify({
        balance: {
          totalTokens: result.total_earned,
          usedTokens: result.total_spent,
          remainingTokens: result.balance,
          lastUpdated: new Date().toISOString(),
          hasUnlimitedAccess: false
        },
        refunded: result.refunded,
        replayed: result.replayed,
        refundTransactionId: result.refund_transaction_id,
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
