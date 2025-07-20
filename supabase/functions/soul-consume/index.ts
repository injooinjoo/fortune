import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { corsHeaders, handleCors } from '../_shared/cors.ts'
import { authenticateUser } from '../_shared/auth.ts'
import { getSoulAmount, isPremiumFortune } from '../_shared/soul-rates.ts'

serve(async (req: Request) => {
  // Handle CORS
  const corsResponse = handleCors(req)
  if (corsResponse) return corsResponse

  try {
    // Authenticate user
    const { user, error: authError } = await authenticateUser(req)
    if (authError) return authError

    // Parse request body
    const { fortuneType, referenceId } = await req.json()
    
    if (!fortuneType) {
      return new Response(
        JSON.stringify({ error: 'Fortune type is required' }),
        { 
          status: 400, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // Check if this is a premium fortune
    if (!isPremiumFortune(fortuneType)) {
      return new Response(
        JSON.stringify({ error: 'This fortune type does not consume souls' }),
        { 
          status: 400, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // Get soul amount to consume (negative number)
    const soulAmount = getSoulAmount(fortuneType)
    const consumeAmount = Math.abs(soulAmount) // Convert to positive for calculations
    
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    )

    // Check if user has unlimited access
    const { data: subscription } = await supabase
      .from('subscriptions')
      .select('status, ends_at')
      .eq('user_id', user!.id)
      .eq('status', 'active')
      .single()

    const hasUnlimitedAccess = subscription !== null

    // If user has unlimited access, don't consume souls
    if (hasUnlimitedAccess) {
      // Still record the transaction for analytics
      await supabase
        .from('token_usage')
        .insert({
          user_id: user!.id,
          fortune_type: fortuneType,
          tokens_used: 0, // No actual consumption
          metadata: {
            type: 'soul_consume_unlimited',
            reference_id: referenceId
          }
        })

      // Get current balance for response
      const { data: currentBalance } = await supabase
        .from('token_balances')
        .select('*')
        .eq('user_id', user!.id)
        .single()

      return new Response(
        JSON.stringify({
          balance: {
            totalTokens: currentBalance?.total_purchased || 0,
            usedTokens: currentBalance?.total_used || 0,
            remainingTokens: currentBalance?.balance || 0,
            lastUpdated: currentBalance?.updated_at || new Date().toISOString(),
            hasUnlimitedAccess: true
          },
          consumedAmount: 0,
          fortuneType
        }),
        { 
          status: 200, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // Get current balance
    const { data: currentBalance, error: balanceError } = await supabase
      .from('token_balances')
      .select('*')
      .eq('user_id', user!.id)
      .single()

    if (balanceError) {
      if (balanceError.code === 'PGRST116') {
        // No balance record exists
        return new Response(
          JSON.stringify({ 
            error: 'Insufficient souls',
            code: 'INSUFFICIENT_TOKENS',
            required: consumeAmount,
            available: 0
          }),
          { 
            status: 400, 
            headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
          }
        )
      }
      throw balanceError
    }

    // Check if user has enough souls
    if (currentBalance.balance < consumeAmount) {
      return new Response(
        JSON.stringify({ 
          error: 'Insufficient souls',
          code: 'INSUFFICIENT_TOKENS',
          required: consumeAmount,
          available: currentBalance.balance
        }),
        { 
          status: 400, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // Update balance
    const newBalance = {
      balance: currentBalance.balance - consumeAmount,
      total_used: currentBalance.total_used + consumeAmount,
      updated_at: new Date().toISOString()
    }

    const { data: updatedBalance, error: updateError } = await supabase
      .from('token_balances')
      .update(newBalance)
      .eq('user_id', user!.id)
      .select()
      .single()

    if (updateError) {
      console.error('Error updating balance:', updateError)
      throw updateError
    }

    // Record the transaction
    const { error: txError } = await supabase
      .from('token_usage')
      .insert({
        user_id: user!.id,
        fortune_type: fortuneType,
        tokens_used: consumeAmount,
        metadata: {
          type: 'soul_consume',
          reference_id: referenceId
        }
      })

    if (txError) {
      console.error('Error recording transaction:', txError)
      // Don't throw - transaction logging is not critical
    }

    return new Response(
      JSON.stringify({
        balance: {
          totalTokens: updatedBalance.total_purchased,
          usedTokens: updatedBalance.total_used,
          remainingTokens: updatedBalance.balance,
          lastUpdated: updatedBalance.updated_at,
          hasUnlimitedAccess: false
        },
        consumedAmount: consumeAmount,
        fortuneType
      }),
      { 
        status: 200, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )

  } catch (error) {
    console.error('Soul consume error:', error)
    return new Response(
      JSON.stringify({ 
        error: 'Internal server error',
        details: error.message
      }),
      { 
        status: 500, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )
  }
})