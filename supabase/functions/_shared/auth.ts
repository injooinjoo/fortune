import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { corsHeaders } from './cors.ts'

export async function authenticateUser(req: Request) {
  const authHeader = req.headers.get('Authorization')
  if (!authHeader) {
    return {
      user: null,
      error: new Response(
        JSON.stringify({ error: 'Missing authorization header' }),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }
  }

  const token = authHeader.replace('Bearer ', '')

  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_ANON_KEY')!,
    {
      global: {
        headers: { Authorization: authHeader }
      }
    }
  )

  const { data: { user }, error } = await supabase.auth.getUser(token)

  if (error || !user) {
    return {
      user: null,
      error: new Response(
        JSON.stringify({ error: 'Invalid token' }),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }
  }

  return { user, error: null }
}

export async function checkTokenBalance(userId: string, requiredTokens: number) {
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
  )

  // ✅ 구독 상태 먼저 체크 (unlimited/premium 사용자는 토큰 체크 불필요)
  const { data: subData } = await supabase
    .from('subscriptions')
    .select('status, plan_id')
    .eq('user_id', userId)
    .eq('status', 'active')
    .single()

  if (subData?.plan_id === 'unlimited' || subData?.plan_id === 'premium') {
    console.log(`[checkTokenBalance] User ${userId} has unlimited/premium subscription`)
    return {
      hasBalance: true,
      balance: Infinity,
      isUnlimited: true,
      error: null
    }
  }

  // ✅ 토큰 잔액 조회 (에러 무시, nullish coalescing 사용)
  const { data: tokenData } = await supabase
    .from('token_balance')
    .select('balance')
    .eq('user_id', userId)
    .single()

  // ✅ row가 없어도 0으로 처리 (에러 아님 - 신규 사용자)
  const balance = tokenData?.balance ?? 0
  const hasBalance = balance >= requiredTokens

  console.log(`[checkTokenBalance] User ${userId}: balance=${balance}, required=${requiredTokens}, hasBalance=${hasBalance}`)

  return {
    hasBalance,
    balance,
    isUnlimited: false,
    error: null
  }
}

export async function deductTokens(userId: string, amount: number, description: string) {
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
  )

  // ✅ 현재 잔액 조회 (없으면 0으로 처리 - 신규 사용자)
  const { data: tokenData } = await supabase
    .from('token_balance')
    .select('balance, total_spent')
    .eq('user_id', userId)
    .single()

  const currentBalance = tokenData?.balance ?? 0
  const currentSpent = tokenData?.total_spent ?? 0
  const newBalance = currentBalance - amount

  if (newBalance < 0) {
    console.log(`[deductTokens] Insufficient balance: current=${currentBalance}, required=${amount}`)
    return { success: false, error: 'Insufficient token balance' }
  }

  // ✅ upsert로 없으면 생성, 있으면 업데이트
  const { error: updateError } = await supabase
    .from('token_balance')
    .upsert({
      user_id: userId,
      balance: newBalance,
      total_spent: currentSpent + amount,
      updated_at: new Date().toISOString()
    }, { onConflict: 'user_id' })

  if (updateError) {
    console.error('Token update error:', updateError)
    return { success: false, error: 'Failed to update balance' }
  }

  // Log token usage
  await supabase
    .from('token_usage')
    .insert({
      user_id: userId,
      amount: -amount,
      balance_after: newBalance,
      description,
      transaction_type: 'debit'
    })

  console.log(`[deductTokens] User ${userId}: deducted ${amount}, newBalance=${newBalance}`)
  return { success: true, newBalance }
}
