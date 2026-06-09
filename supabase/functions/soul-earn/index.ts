import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

// 운세 타입별 획득 토큰 (무료 운세/광고 시청 보상)
const SOUL_EARN_RATES: Record<string, number> = {
  // 기본 무료 운세
  'daily': 1,
  'today': 1,
  'tomorrow': 1,
  'hourly': 1,

  // 광고 시청 보상
  'ad_reward': 1,
  'ad_view': 1,

  // 기타 무료 활동
  'login_bonus': 1,
  'daily_check': 1,
}

/**
 * 토큰(영혼) 획득 Edge Function
 *
 * POST /soul-earn
 * Body: { fortuneType: string }
 *
 * Response:
 * {
 *   "balance": {
 *     "totalTokens": 503,
 *     "usedTokens": 0,
 *     "remainingTokens": 503,
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
    const { fortuneType } = body

    if (!fortuneType) {
      return new Response(
        JSON.stringify({ error: 'Missing fortuneType' }),
        {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      )
    }

    console.log(`🌟 Soul earn request: fortuneType=${fortuneType}`)

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

    // 1. 현재 토큰 잔액 조회. 구독도 유한 토큰 할당권이므로 무제한 플래그는 항상 false.
    const hasUnlimitedAccess = false
    const { data: tokenData } = await supabase
      .from('token_balance')
      .select('balance, total_earned, total_spent')
      .eq('user_id', user.id)
      .single()

    const currentBalance = tokenData?.balance ?? 0
    const totalEarned = tokenData?.total_earned ?? 0
    const totalSpent = tokenData?.total_spent ?? 0

    // 3. 획득할 토큰 수 계산 (기본 1개)
    const earnAmount = SOUL_EARN_RATES[fortuneType] ?? 1

    console.log(`💰 Current balance: ${currentBalance}, Earn: ${earnAmount}`)

    // 4. 토큰 추가
    const newBalance = currentBalance + earnAmount
    const newTotalEarned = totalEarned + earnAmount

    const { error: updateError } = await supabase
      .from('token_balance')
      .upsert({
        user_id: user.id,
        balance: newBalance,
        total_earned: newTotalEarned,
        total_spent: totalSpent,
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

    // 5. 거래 이력 기록
    await supabase
      .from('token_transactions')
      .insert({
        user_id: user.id,
        transaction_type: 'earn',
        amount: earnAmount,
        balance_after: newBalance,
        description: `${fortuneType} 완료 보상`,
        reference_type: 'fortune',
        reference_id: null
      })

    console.log(`✅ Token earned: ${currentBalance} → ${newBalance} (earned: ${earnAmount})`)

    return new Response(
      JSON.stringify({
        balance: {
          totalTokens: newTotalEarned,
          usedTokens: totalSpent,
          remainingTokens: newBalance,
          lastUpdated: new Date().toISOString(),
          hasUnlimitedAccess
        }
      }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    console.error('❌ Soul earn error:', error)
    return new Response(
      JSON.stringify({ error: 'Internal server error' }),
      {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      }
    )
  }
})
