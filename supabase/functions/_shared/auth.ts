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

  // Get user's token balance from token_balances table
  const { data: tokenBalance, error } = await supabase
    .from('token_balances')
    .select('balance')
    .eq('user_id', userId)
    .single()

  if (error || !tokenBalance) {
    // If record not found (new user), they should have initial tokens
    if (error?.code === 'PGRST116') {
      console.log(`No token balance record found for user ${userId}, assuming initial balance`)
      return {
        hasBalance: true,
        balance: 100, // Initial token grant for new users
        error: null
      }
    }
    
    console.error('Error fetching token balance:', error)
    return {
      hasBalance: false,
      balance: 0,
      error: 'Failed to fetch token balance'
    }
  }

  const hasBalance = tokenBalance.balance >= requiredTokens

  return {
    hasBalance,
    balance: tokenBalance.balance,
    error: null
  }
}

export async function deductTokens(userId: string, amount: number, description: string) {
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
  )

  // Get current token balance
  const { data: tokenBalance, error: fetchError } = await supabase
    .from('token_balances')
    .select('balance')
    .eq('user_id', userId)
    .single()

  if (fetchError || !tokenBalance) {
    return { success: false, error: 'Failed to fetch token balance' }
  }

  const newBalance = tokenBalance.balance - amount
  if (newBalance < 0) {
    return { success: false, error: 'Insufficient token balance' }
  }

  // Update balance in token_balances table
  const { error: updateError } = await supabase
    .from('token_balances')
    .update({ 
      balance: newBalance,
      updated_at: new Date().toISOString()
    })
    .eq('user_id', userId)

  if (updateError) {
    return { success: false, error: 'Failed to update balance' }
  }

  // Log token usage
  const { error: logError } = await supabase
    .from('token_usage')
    .insert({
      user_id: userId,
      tokens_used: amount,
      fortune_type: description,
      metadata: { balance_after: newBalance }
    })

  if (logError) {
    console.error('Failed to log token usage:', logError)
  }

  return { success: true, newBalance }
}