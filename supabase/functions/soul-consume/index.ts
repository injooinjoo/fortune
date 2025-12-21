import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { FORTUNE_TOKEN_COSTS } from '../_shared/types.ts'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

/**
 * 토큰(영혼) 소비 Edge Function
 *
 * POST /soul-consume
 * Body: { fortuneType: string, referenceId?: string }
 *
 * Response:
 * {
 *   "balance": {
 *     "totalTokens": 500,
 *     "usedTokens": 15,
 *     "remainingTokens": 485,
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

  // POST 요청만 허용
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
    // 인증 토큰 추출
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

    // 요청 Body 파싱
    const body = await req.json()
    const { fortuneType, referenceId } = body

    if (!fortuneType) {
      return new Response(
        JSON.stringify({ error: 'Missing fortuneType' }),
        {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      )
    }

    console.log(`🔮 Soul consume request: fortuneType=${fortuneType}, referenceId=${referenceId}`)

    // Supabase 클라이언트 생성
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!

    const supabase = createClient(supabaseUrl, supabaseServiceKey, {
      auth: {
        autoRefreshToken: false,
        persistSession: false
      }
    })

    // JWT에서 사용자 ID 추출
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

    // 1. 활성 구독 확인 (무제한 이용권)
    const { data: subscription } = await supabase
      .from('subscriptions')
      .select('id, product_id, expires_at, status')
      .eq('user_id', user.id)
      .eq('status', 'active')
      .gt('expires_at', new Date().toISOString())
      .order('expires_at', { ascending: false })
      .limit(1)
      .single()

    const hasUnlimitedAccess = !!subscription

    // 2. 현재 토큰 잔액 조회
    const { data: tokenData, error: tokenError } = await supabase
      .from('token_balance')
      .select('balance, total_earned, total_spent')
      .eq('user_id', user.id)
      .single()

    const currentBalance = tokenData?.balance ?? 0
    const totalEarned = tokenData?.total_earned ?? 0
    const totalSpent = tokenData?.total_spent ?? 0

    // 3. 필요한 토큰 수 계산
    const cost = FORTUNE_TOKEN_COSTS[fortuneType as keyof typeof FORTUNE_TOKEN_COSTS] ?? 1

    console.log(`💰 Current balance: ${currentBalance}, Cost: ${cost}, Unlimited: ${hasUnlimitedAccess}`)

    // 무제한 이용권이 있으면 토큰 소비 없이 성공
    if (hasUnlimitedAccess) {
      console.log(`✅ Unlimited access - no token consumption`)
      return new Response(
        JSON.stringify({
          balance: {
            totalTokens: totalEarned,
            usedTokens: totalSpent,
            remainingTokens: currentBalance,
            lastUpdated: new Date().toISOString(),
            hasUnlimitedAccess: true
          }
        }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // 4. 토큰 부족 체크
    if (currentBalance < cost) {
      console.log(`❌ Insufficient tokens: have ${currentBalance}, need ${cost}`)
      return new Response(
        JSON.stringify({
          code: 'INSUFFICIENT_TOKENS',
          message: '복주머니가 부족합니다',
          required: cost,
          available: currentBalance
        }),
        {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      )
    }

    // 5. 토큰 차감
    const newBalance = currentBalance - cost
    const newTotalSpent = totalSpent + cost

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
      console.error('❌ Token update failed:', updateError.message)
      return new Response(
        JSON.stringify({ error: 'Failed to update token balance' }),
        {
          status: 500,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      )
    }

    // 6. 거래 이력 기록
    await supabase
      .from('token_transactions')
      .insert({
        user_id: user.id,
        transaction_type: 'consumption',
        amount: -cost,
        balance_after: newBalance,
        description: `${fortuneType} 운세 이용`,
        reference_type: 'fortune',
        reference_id: referenceId || null
      })

    console.log(`✅ Token consumed: ${currentBalance} → ${newBalance} (cost: ${cost})`)

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
