import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Supabase 클라이언트 생성
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      {
        global: {
          headers: { Authorization: req.headers.get('Authorization')! },
        },
      }
    )

    // 사용자 인증 확인
    const {
      data: { user },
      error: authError,
    } = await supabaseClient.auth.getUser()

    if (authError || !user) {
      return new Response(
        JSON.stringify({ error: 'Unauthorized', code: 'AUTH_ERROR' }),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const today = new Date().toISOString().split('T')[0] // YYYY-MM-DD

    // 오늘 이미 체크인했는지 확인
    const { data: existingCheckin } = await supabaseClient
      .from('daily_check_ins')
      .select('*')
      .eq('user_id', user.id)
      .eq('checked_at', today)
      .single()

    if (existingCheckin) {
      // 이미 체크인함 - 현재 잔액 반환
      const { data: balance } = await supabaseClient
        .from('token_balance')
        .select('balance, total_earned, total_spent')
        .eq('user_id', user.id)
        .single()

      return new Response(
        JSON.stringify({
          success: false,
          alreadyCheckedIn: true,
          pointsEarned: 0,
          balance: {
            remainingPoints: balance?.balance ?? 0,
            totalEarned: balance?.total_earned ?? 0,
            totalSpent: balance?.total_spent ?? 0,
          },
          message: '오늘은 이미 출석체크를 완료했어요!',
        }),
        { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const DAILY_POINTS = 100

    // 출석체크 기록 추가
    const { error: checkinError } = await supabaseClient
      .from('daily_check_ins')
      .insert({
        user_id: user.id,
        checked_at: today,
        points_earned: DAILY_POINTS,
      })

    if (checkinError) {
      console.error('Checkin insert error:', checkinError)
      return new Response(
        JSON.stringify({ error: 'Failed to record check-in', code: 'CHECKIN_ERROR' }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // 포인트 추가
    const { data: currentBalance } = await supabaseClient
      .from('token_balance')
      .select('balance, total_earned')
      .eq('user_id', user.id)
      .single()

    if (currentBalance) {
      // 기존 잔액 업데이트
      const { error: updateError } = await supabaseClient
        .from('token_balance')
        .update({
          balance: currentBalance.balance + DAILY_POINTS,
          total_earned: (currentBalance.total_earned ?? 0) + DAILY_POINTS,
          updated_at: new Date().toISOString(),
        })
        .eq('user_id', user.id)

      if (updateError) {
        console.error('Balance update error:', updateError)
      }
    } else {
      // 새 잔액 레코드 생성
      const { error: insertError } = await supabaseClient
        .from('token_balance')
        .insert({
          user_id: user.id,
          balance: DAILY_POINTS,
          total_earned: DAILY_POINTS,
          total_spent: 0,
        })

      if (insertError) {
        console.error('Balance insert error:', insertError)
      }
    }

    // 새 잔액 조회
    const { data: newBalance } = await supabaseClient
      .from('token_balance')
      .select('balance, total_earned, total_spent')
      .eq('user_id', user.id)
      .single()

    // 거래 기록
    await supabaseClient.from('token_transactions').insert({
      user_id: user.id,
      transaction_type: 'earn',
      amount: DAILY_POINTS,
      balance_after: newBalance?.balance ?? DAILY_POINTS,
      description: '출석체크 보상',
      reference_type: 'daily_checkin',
    })

    return new Response(
      JSON.stringify({
        success: true,
        alreadyCheckedIn: false,
        pointsEarned: DAILY_POINTS,
        balance: {
          remainingPoints: newBalance?.balance ?? DAILY_POINTS,
          totalEarned: newBalance?.total_earned ?? DAILY_POINTS,
          totalSpent: newBalance?.total_spent ?? 0,
        },
        message: `출석체크 완료! ${DAILY_POINTS}P 지급되었어요.`,
      }),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  } catch (error) {
    console.error('Daily checkin error:', error)
    return new Response(
      JSON.stringify({ error: 'Internal server error', code: 'SERVER_ERROR' }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})
