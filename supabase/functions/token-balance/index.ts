import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

/**
 * 토큰 잔액 조회 Edge Function
 *
 * GET /token-balance
 *
 * Response:
 * {
 *   "balance": 500,
 *   "totalPurchased": 500,
 *   "totalUsed": 0,
 *   "isUnlimited": false
 * }
 */
serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response(null, { headers: corsHeaders })
  }

  // GET 요청만 허용
  if (req.method !== 'GET') {
    return new Response(
      JSON.stringify({
        balance: 0,
        totalPurchased: 0,
        totalUsed: 0,
        isUnlimited: false,
        error: 'Method not allowed'
      }),
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
        JSON.stringify({
          balance: 0,
          totalPurchased: 0,
          totalUsed: 0,
          isUnlimited: false,
          error: 'No authorization'
        }),
        {
          status: 401,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      )
    }

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
        JSON.stringify({
          balance: 0,
          totalPurchased: 0,
          totalUsed: 0,
          isUnlimited: false
        }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    console.log(`🔍 Fetching token balance for user: ${user.id}`)

    // 1. token_balance 테이블에서 잔액 조회
    const { data: tokenData, error: tokenError } = await supabase
      .from('token_balance')
      .select('balance, total_earned, total_spent')
      .eq('user_id', user.id)
      .single()

    if (tokenError && tokenError.code !== 'PGRST116') {
      // PGRST116 = no rows found (정상적인 "잔액 없음" 상태)
      console.error('❌ Token balance query error:', tokenError.message)
    }

    // 2. 구독도 무제한 상태로 보고하지 않는다.
    // 구독 구매/갱신 시 지급된 플랜별 토큰이 token_balance 에 반영되고,
    // 모든 유료 AI 사용은 동일한 잔액에서 차감된다.
    const isUnlimited = false

    // 3. 응답 구성
    const balance = tokenData?.balance ?? 0
    const totalPurchased = tokenData?.total_earned ?? 0
    const totalUsed = tokenData?.total_spent ?? 0

    console.log(`✅ Token balance for ${user.id}:`)
    console.log(`   - balance: ${balance}`)
    console.log(`   - totalPurchased: ${totalPurchased}`)
    console.log(`   - totalUsed: ${totalUsed}`)
    console.log(`   - isUnlimited: ${isUnlimited}`)

    return new Response(
      JSON.stringify({
        balance,
        totalPurchased,
        totalUsed,
        isUnlimited
      }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    console.error('❌ Token balance error:', error)
    return new Response(
      JSON.stringify({
        balance: 0,
        totalPurchased: 0,
        totalUsed: 0,
        isUnlimited: false,
        error: 'Internal server error'
      }),
      {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      }
    )
  }
})
