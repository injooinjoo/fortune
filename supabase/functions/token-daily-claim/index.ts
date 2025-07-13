import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { corsHeaders, handleCors } from '../_shared/cors.ts'
import { authenticateUser } from '../_shared/auth.ts'

const DAILY_TOKEN_AMOUNT = 3

serve(async (req: Request) => {
  // Handle CORS
  const corsResponse = handleCors(req)
  if (corsResponse) return corsResponse

  // Only allow POST requests
  if (req.method !== 'POST') {
    return new Response(
      JSON.stringify({ error: 'Method not allowed' }),
      { 
        status: 405, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )
  }

  try {
    // Authenticate user
    const { user, error: authError } = await authenticateUser(req)
    if (authError) return authError

    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    )

    // Get user's profile
    const { data: profile, error: profileError } = await supabase
      .from('user_profiles')
      .select('token_balance, daily_token_claimed_at')
      .eq('id', user!.id)
      .single()

    if (profileError || !profile) {
      return new Response(
        JSON.stringify({ error: 'Profile not found' }),
        { 
          status: 404, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // Check if already claimed today
    const now = new Date()
    const today = new Date(now.getFullYear(), now.getMonth(), now.getDate())
    
    if (profile.daily_token_claimed_at) {
      const lastClaimed = new Date(profile.daily_token_claimed_at)
      const lastClaimedDate = new Date(
        lastClaimed.getFullYear(), 
        lastClaimed.getMonth(), 
        lastClaimed.getDate()
      )
      
      if (lastClaimedDate.getTime() >= today.getTime()) {
        const tomorrow = new Date(today)
        tomorrow.setDate(tomorrow.getDate() + 1)
        
        return new Response(
          JSON.stringify({ 
            error: 'Daily tokens already claimed',
            nextClaimTime: tomorrow.toISOString(),
            lastClaimedAt: profile.daily_token_claimed_at
          }),
          { 
            status: 400, 
            headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
          }
        )
      }
    }

    // Grant daily tokens
    const newBalance = profile.token_balance + DAILY_TOKEN_AMOUNT

    // Update profile
    const { error: updateError } = await supabase
      .from('user_profiles')
      .update({ 
        token_balance: newBalance,
        daily_token_claimed_at: now.toISOString()
      })
      .eq('id', user!.id)

    if (updateError) {
      return new Response(
        JSON.stringify({ error: 'Failed to update balance' }),
        { 
          status: 500, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // Log token transaction
    await supabase
      .from('token_usage')
      .insert({
        user_id: user!.id,
        amount: DAILY_TOKEN_AMOUNT,
        balance_after: newBalance,
        description: 'Daily token reward',
        transaction_type: 'credit'
      })

    // Calculate next claim time
    const nextClaim = new Date(today)
    nextClaim.setDate(nextClaim.getDate() + 1)

    return new Response(
      JSON.stringify({
        success: true,
        tokensGranted: DAILY_TOKEN_AMOUNT,
        newBalance,
        claimedAt: now.toISOString(),
        nextClaimTime: nextClaim.toISOString()
      }),
      { 
        status: 200, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )

  } catch (error) {
    console.error('Daily token claim error:', error)
    return new Response(
      JSON.stringify({ error: 'Internal server error' }),
      { 
        status: 500, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )
  }
})