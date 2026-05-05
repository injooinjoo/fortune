import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { FORTUNE_TOKEN_COSTS, normalizeFortuneType } from '../_shared/types.ts'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

/**
 * 토큰(영혼) 소비 Edge Function
 *
 * POST /soul-consume
 * Body: { fortuneType: string, referenceId?: string, idempotencyKey?: string }
 *
 * idempotencyKey: PR-0a 추가. 같은 키 재전송 시 1회만 차감 + 기존 결과 반환.
 * referenceId: token_transactions.reference_id 에 저장. 환불 시 원본 찾기에 사용.
 *
 * Response:
 * {
 *   "balance": {
 *     "totalTokens": 500,
 *     "usedTokens": 15,
 *     "remainingTokens": 485,
 *     "lastUpdated": "2025-12-21T10:00:00Z",
 *     "hasUnlimitedAccess": false
 *   },
 *   "replayed"?: true   // idempotency 재전송 시
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
      console.log('❌ No authorization header')
      return new Response(
        JSON.stringify({ error: 'No authorization' }),
        {
          status: 401,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      )
    }

    const body = await req.json()
    const {
      fortuneType: rawFortuneType,
      referenceId,
      idempotencyKey,
    } = body as {
      fortuneType?: string
      referenceId?: string | null
      idempotencyKey?: string | null
    }

    if (!rawFortuneType) {
      return new Response(
        JSON.stringify({ error: 'Missing fortuneType' }),
        {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      )
    }

    const fortuneType = normalizeFortuneType(rawFortuneType)

    console.log(
      `🔮 Soul consume: fortuneType=${fortuneType} (raw=${rawFortuneType}), ` +
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
      console.log('❌ User authentication failed:', userError?.message)
      return new Response(
        JSON.stringify({ error: 'Authentication failed' }),
        {
          status: 401,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      )
    }

    console.log(`👤 User: ${user.id}`)

    // 0. 일일 무료 운세 (daily 타입). RPC 밖에서 처리 — 토큰 path 와 분리.
    if (fortuneType === 'daily') {
      const today = new Date().toISOString().split('T')[0]

      const { data: usedToday } = await supabase
        .from('daily_free_fortune')
        .select('id')
        .eq('user_id', user.id)
        .eq('used_at', today)
        .maybeSingle()

      if (!usedToday) {
        const { error: insertError } = await supabase
          .from('daily_free_fortune')
          .insert({
            user_id: user.id,
            used_at: today,
            fortune_type: 'daily'
          })

        if (!insertError) {
          console.log(`🎁 Free daily fortune used for user ${user.id}`)

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
              },
              freeUsed: true,
              message: '오늘의 무료 일일 운세를 사용했습니다.'
            }),
            { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
          )
        }
      }
    }

    // 1. 무제한 구독 체크. RPC 밖 — 구독자는 토큰 차감 자체 skip.
    const { data: subscription } = await supabase
      .from('subscriptions')
      .select('id, product_id, expires_at, status')
      .eq('user_id', user.id)
      .eq('status', 'active')
      .gt('expires_at', new Date().toISOString())
      .order('expires_at', { ascending: false })
      .limit(1)
      .maybeSingle()

    if (subscription) {
      const { data: tokenData } = await supabase
        .from('token_balance')
        .select('balance, total_earned, total_spent')
        .eq('user_id', user.id)
        .single()

      console.log(`✅ Unlimited access — no token consumption`)
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

    // 2. 비용 계산
    const cost = FORTUNE_TOKEN_COSTS[fortuneType as keyof typeof FORTUNE_TOKEN_COSTS] ?? 1

    // 3. atomic RPC 호출
    const { data: rpcResult, error: rpcError } = await supabase.rpc(
      'consume_token_atomic',
      {
        p_user_id: user.id,
        p_cost: cost,
        p_description: `${fortuneType} 운세 이용`,
        p_reference_type: 'fortune',
        p_reference_id: referenceId ?? null,
        p_idempotency_key: idempotencyKey ?? null,
      },
    )

    if (rpcError) {
      // INSUFFICIENT_TOKENS = SQLSTATE P0001
      if (rpcError.code === 'P0001') {
        console.log(`❌ Insufficient tokens (RPC): ${rpcError.details ?? rpcError.message}`)
        // 잔액 안내용 현재 잔액 조회
        const { data: tokenData } = await supabase
          .from('token_balance')
          .select('balance')
          .eq('user_id', user.id)
          .maybeSingle()

        return new Response(
          JSON.stringify({
            code: 'INSUFFICIENT_TOKENS',
            message: '토큰이 부족합니다',
            required: cost,
            available: tokenData?.balance ?? 0,
          }),
          {
            status: 400,
            headers: { ...corsHeaders, 'Content-Type': 'application/json' }
          }
        )
      }

      console.error('❌ consume_token_atomic RPC failed:', rpcError)
      return new Response(
        JSON.stringify({ error: 'Failed to consume token' }),
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
      replayed: boolean
      transaction_id: string
    }

    if (result.replayed) {
      console.log(
        `🔁 Idempotent replay: txn=${result.transaction_id}, balance=${result.balance}`,
      )
    } else {
      console.log(
        `✅ Token consumed: balance=${result.balance}, txn=${result.transaction_id}`,
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
        replayed: result.replayed,
        transactionId: result.transaction_id,
      }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    console.error('❌ Soul consume error:', error)
    return new Response(
      JSON.stringify({ error: 'Internal server error' }),
      {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      }
    )
  }
})
