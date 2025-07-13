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

  // Get user's token balance
  const { data: profile, error } = await supabase
    .from('user_profiles')
    .select('token_balance')
    .eq('id', userId)
    .single()

  if (error || !profile) {
    return {
      hasBalance: false,
      balance: 0,
      error: 'Failed to fetch token balance'
    }
  }

  const hasBalance = profile.token_balance >= requiredTokens

  return {
    hasBalance,
    balance: profile.token_balance,
    error: null
  }
}

export async function deductTokens(userId: string, amount: number, description: string) {
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
  )

  // Start a transaction
  const { data: profile, error: fetchError } = await supabase
    .from('user_profiles')
    .select('token_balance')
    .eq('id', userId)
    .single()

  if (fetchError || !profile) {
    return { success: false, error: 'Failed to fetch profile' }
  }

  const newBalance = profile.token_balance - amount
  if (newBalance < 0) {
    return { success: false, error: 'Insufficient token balance' }
  }

  // Update balance
  const { error: updateError } = await supabase
    .from('user_profiles')
    .update({ token_balance: newBalance })
    .eq('id', userId)

  if (updateError) {
    return { success: false, error: 'Failed to update balance' }
  }

  // Log token usage
  const { error: logError } = await supabase
    .from('token_usage')
    .insert({
      user_id: userId,
      amount: -amount,
      balance_after: newBalance,
      description,
      transaction_type: 'debit'
    })

  if (logError) {
    console.error('Failed to log token usage:', logError)
  }

  return { success: true, newBalance }
}