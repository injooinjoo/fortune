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

  // Get user's token balance from token_balance table (NOT user_profiles)
  const { data: tokenData, error } = await supabase
    .from('token_balance')
    .select('balance')
    .eq('user_id', userId)
    .single()

  if (error || !tokenData) {
    console.error('Token balance fetch error:', error)
    return {
      hasBalance: false,
      balance: 0,
      error: 'Failed to fetch token balance'
    }
  }

  const hasBalance = tokenData.balance >= requiredTokens

  return {
    hasBalance,
    balance: tokenData.balance,
    error: null
  }
}

export async function deductTokens(userId: string, amount: number, description: string) {
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
  )

  // Fetch current balance from token_balance table
  const { data: tokenData, error: fetchError } = await supabase
    .from('token_balance')
    .select('balance, total_spent')
    .eq('user_id', userId)
    .single()

  if (fetchError || !tokenData) {
    console.error('Token fetch error:', fetchError)
    return { success: false, error: 'Failed to fetch token balance' }
  }

  const newBalance = tokenData.balance - amount
  if (newBalance < 0) {
    return { success: false, error: 'Insufficient token balance' }
  }

  // Update balance in token_balance table
  const { error: updateError } = await supabase
    .from('token_balance')
    .update({
      balance: newBalance,
      total_spent: (tokenData.total_spent || 0) + amount, // Increment total_spent
      updated_at: new Date().toISOString()
    })
    .eq('user_id', userId)

  if (updateError) {
    console.error('Token update error:', updateError)
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
