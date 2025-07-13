import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { corsHeaders, handleCors } from '../_shared/cors.ts'
import { authenticateUser } from '../_shared/auth.ts'

serve(async (req: Request) => {
  // Handle CORS
  const corsResponse = handleCors(req)
  if (corsResponse) return corsResponse

  try {
    // Authenticate user
    const { user, error: authError } = await authenticateUser(req)
    if (authError) return authError

    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    )

    // Get user's token balance and profile
    const { data: profile, error } = await supabase
      .from('user_profiles')
      .select('token_balance, daily_token_claimed_at')
      .eq('id', user!.id)
      .single()

    if (error || !profile) {
      return new Response(
        JSON.stringify({ error: 'Profile not found' }),
        { 
          status: 404, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // Check if daily tokens can be claimed
    const now = new Date()
    const lastClaimed = profile.daily_token_claimed_at 
      ? new Date(profile.daily_token_claimed_at) 
      : null
    
    let canClaimDaily = true
    let nextClaimTime = null

    if (lastClaimed) {
      const nextClaim = new Date(lastClaimed)
      nextClaim.setDate(nextClaim.getDate() + 1)
      nextClaim.setHours(0, 0, 0, 0)
      
      canClaimDaily = now >= nextClaim
      if (!canClaimDaily) {
        nextClaimTime = nextClaim.toISOString()
      }
    }

    // Get recent token history
    const { data: history } = await supabase
      .from('token_usage')
      .select('*')
      .eq('user_id', user!.id)
      .order('created_at', { ascending: false })
      .limit(10)

    return new Response(
      JSON.stringify({
        balance: profile.token_balance,
        canClaimDaily,
        nextClaimTime,
        lastClaimedAt: profile.daily_token_claimed_at,
        recentHistory: history || []
      }),
      { 
        status: 200, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )

  } catch (error) {
    console.error('Token balance error:', error)
    return new Response(
      JSON.stringify({ error: 'Internal server error' }),
      { 
        status: 500, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )
  }
})