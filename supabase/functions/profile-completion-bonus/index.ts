import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

// 프로필 완성 보너스 토큰 수
const PROFILE_COMPLETION_BONUS = 5

/**
 * 프로필 완성 보너스 Edge Function
 *
 * POST /profile-completion-bonus
 *
 * 프로필에 birth_date와 birth_time이 모두 입력되면 5토큰 보너스 지급
 * 한 번만 지급됨 (profile_completion_bonus_granted 플래그로 추적)
 */
serve(async (req) => {
  // CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response(null, { headers: corsHeaders })
  }

  if (req.method !== 'POST') {
    return new Response(
      JSON.stringify({ error: 'Method not allowed' }),
      { status: 405, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }

  try {
    // 인증 토큰 추출
    const authHeader = req.headers.get('Authorization')
    if (!authHeader) {
      return new Response(
        JSON.stringify({ error: 'No authorization' }),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Supabase 클라이언트 생성
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!

    const supabase = createClient(supabaseUrl, supabaseServiceKey, {
      auth: { autoRefreshToken: false, persistSession: false }
    })

    // JWT에서 사용자 ID 추출
    const token = authHeader.replace('Bearer ', '')
    const { data: { user }, error: userError } = await supabase.auth.getUser(token)

    if (userError || !user) {
      console.log('❌ User authentication failed:', userError?.message)
      return new Response(
        JSON.stringify({ error: 'Authentication failed' }),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    console.log(`👤 User: ${user.id}`)

    // 1. 프로필 조회 (완성 여부 + 보너스 지급 여부)
    const { data: profile, error: profileError } = await supabase
      .from('user_profiles')
      .select('birth_date, birth_time, profile_completion_bonus_granted')
      .eq('id', user.id)
      .single()

    if (profileError || !profile) {
      console.log('❌ Profile not found:', profileError?.message)
      return new Response(
        JSON.stringify({ error: 'Profile not found' }),
        { status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // 2. 이미 보너스 지급된 경우
    if (profile.profile_completion_bonus_granted) {
      console.log('📌 Bonus already granted')
      return new Response(
        JSON.stringify({
          success: false,
          message: '이미 프로필 완성 보너스를 받으셨습니다.',
          bonusGranted: false
        }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // 3. 프로필 완성 여부 확인 (birth_date + birth_time 모두 필요)
    if (!profile.birth_date || !profile.birth_time) {
      console.log(`📌 Profile incomplete: birth_date=${profile.birth_date}, birth_time=${profile.birth_time}`)
      return new Response(
        JSON.stringify({
          success: false,
          message: '프로필을 완성해주세요. (생년월일과 출생시간 모두 필요)',
          bonusGranted: false
        }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // 4. 현재 토큰 잔액 조회
    const { data: tokenData } = await supabase
      .from('token_balance')
      .select('balance, total_earned, total_spent')
      .eq('user_id', user.id)
      .single()

    const currentBalance = tokenData?.balance ?? 0
    const totalEarned = tokenData?.total_earned ?? 0
    const totalSpent = tokenData?.total_spent ?? 0

    // 5. 토큰 추가 + 보너스 플래그 업데이트 (트랜잭션)
    const newBalance = currentBalance + PROFILE_COMPLETION_BONUS
    const newTotalEarned = totalEarned + PROFILE_COMPLETION_BONUS

    // 토큰 잔액 업데이트
    const { error: balanceError } = await supabase
      .from('token_balance')
      .upsert({
        user_id: user.id,
        balance: newBalance,
        total_earned: newTotalEarned,
        total_spent: totalSpent,
        updated_at: new Date().toISOString()
      }, { onConflict: 'user_id' })

    if (balanceError) {
      console.error('❌ Token balance update failed:', balanceError.message)
      return new Response(
        JSON.stringify({ error: 'Failed to grant bonus' }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // 보너스 지급 플래그 업데이트
    const { error: profileUpdateError } = await supabase
      .from('user_profiles')
      .update({ profile_completion_bonus_granted: true })
      .eq('id', user.id)

    if (profileUpdateError) {
      console.error('❌ Profile update failed:', profileUpdateError.message)
      // 토큰은 이미 지급됨 - 로깅만 하고 성공 처리
    }

    // 6. 거래 이력 기록
    await supabase
      .from('token_transactions')
      .insert({
        user_id: user.id,
        transaction_type: 'earn',
        amount: PROFILE_COMPLETION_BONUS,
        balance_after: newBalance,
        description: '프로필 완성 보너스',
        reference_type: 'bonus',
        reference_id: 'profile_completion'
      })

    console.log(`🎁 Profile completion bonus granted: ${PROFILE_COMPLETION_BONUS} tokens to user ${user.id}`)

    return new Response(
      JSON.stringify({
        success: true,
        message: `프로필 완성 보너스 ${PROFILE_COMPLETION_BONUS}토큰이 지급되었습니다!`,
        bonusGranted: true,
        bonusAmount: PROFILE_COMPLETION_BONUS,
        balance: {
          totalTokens: newTotalEarned,
          usedTokens: totalSpent,
          remainingTokens: newBalance,
          lastUpdated: new Date().toISOString()
        }
      }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    console.error('❌ Profile completion bonus error:', error)
    return new Response(
      JSON.stringify({ error: 'Internal server error' }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})
