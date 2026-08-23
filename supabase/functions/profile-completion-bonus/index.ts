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

    // 4. 원자 지급 (잔액 증분 + 거래 이력 + 플래그를 한 트랜잭션에서)
    //
    // 이전 구현은 잔액을 읽고 → 절대값으로 upsert → 플래그 update → 거래 insert 를
    // 각각 별도 문장으로 처리했다. 읽기와 쓰기 사이에 결제 지급(grant_purchase_tokens_atomic)
    // 이 끼면 고객이 구매한 토큰이 통째로 덮어써진다.
    // 20260818000600_profile_completion_bonus_atomic.sql 참고.
    const { data: grantResult, error: grantError } = await supabase.rpc(
      'grant_profile_completion_bonus_atomic',
      { p_user_id: user.id, p_bonus: PROFILE_COMPLETION_BONUS },
    )

    if (grantError) {
      console.error('❌ grant_profile_completion_bonus_atomic failed:', grantError.message)
      return new Response(
        JSON.stringify({ error: 'Failed to grant bonus' }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const result = (grantResult ?? {}) as {
      granted?: boolean
      reason?: string
      balance?: number
      total_earned?: number
      total_spent?: number
    }

    if (!result.granted) {
      // RPC 가 최종 판정자다. 위 1~3 단계의 사전 조회는 안내 문구용이며,
      // 동시 호출로 그 사이에 상태가 바뀌었으면 여기서 걸린다.
      if (result.reason === 'PROFILE_NOT_FOUND') {
        return new Response(
          JSON.stringify({ error: 'Profile not found' }),
          { status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
      }

      const message = result.reason === 'ALREADY_GRANTED'
        ? '이미 프로필 완성 보너스를 받으셨습니다.'
        : '프로필을 완성해주세요. (생년월일과 출생시간 모두 필요)'

      console.log(`📌 Bonus not granted: ${result.reason}`)
      return new Response(
        JSON.stringify({ success: false, message, bonusGranted: false }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    console.log(`🎁 Profile completion bonus granted: ${PROFILE_COMPLETION_BONUS} tokens to user ${user.id}`)

    return new Response(
      JSON.stringify({
        success: true,
        message: `프로필 완성 보너스 ${PROFILE_COMPLETION_BONUS}토큰이 지급되었습니다!`,
        bonusGranted: true,
        bonusAmount: PROFILE_COMPLETION_BONUS,
        balance: {
          totalTokens: result.total_earned ?? 0,
          usedTokens: result.total_spent ?? 0,
          remainingTokens: result.balance ?? 0,
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
