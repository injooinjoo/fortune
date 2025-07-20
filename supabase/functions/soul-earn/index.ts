import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { corsHeaders, handleCors } from '../_shared/cors.ts'
import { authenticateUser } from '../_shared/auth.ts'
import { getSoulAmount, isFreeFortune } from '../_shared/soul-rates.ts'

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

    // Check if this is a free fortune
    if (!isFreeFortune(fortuneType)) {
      return new Response(
        JSON.stringify({ error: 'This fortune type does not earn souls' }),
        { 
          status: 400, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // Get soul amount to earn
    const soulAmount = getSoulAmount(fortuneType)
    
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    )

    // Begin transaction
    const { data: currentBalance, error: balanceError } = await supabase
      .from('token_balances')
      .select('*')
      .eq('user_id', user!.id)
      .single()

    if (balanceError && balanceError.code !== 'PGRST116') {
      console.error('Error fetching balance:', balanceError)
      throw balanceError
    }

    // Create or update balance
    const newBalance = currentBalance 
      ? {
          balance: currentBalance.balance + soulAmount,
          total_purchased: currentBalance.total_purchased + soulAmount,
          updated_at: new Date().toISOString()
        }
      : {
          user_id: user!.id,
          balance: soulAmount,
          total_purchased: soulAmount,
          total_used: 0,
          updated_at: new Date().toISOString()
        }

    const { data: updatedBalance, error: updateError } = currentBalance
      ? await supabase
          .from('token_balances')
          .update(newBalance)
          .eq('user_id', user!.id)
          .select()
          .single()
      : await supabase
          .from('token_balances')
          .insert(newBalance)
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
        tokens_used: -soulAmount, // Negative because it's earned, not used
        metadata: {
          type: 'soul_earn',
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
        earnedAmount: soulAmount,
        fortuneType
      }),
      { 
        status: 200, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )

  } catch (error) {
    console.error('Soul earn error:', error)
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