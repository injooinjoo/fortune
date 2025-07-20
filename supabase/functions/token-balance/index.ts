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

    // Get user's token balance
    const { data: tokenBalance, error: balanceError } = await supabase
      .from('token_balances')
      .select('balance, total_purchased, total_used')
      .eq('user_id', user!.id)
      .single()

    // If no token balance record exists (PGRST116), continue with defaults
    // For other errors, log them but still continue
    if (balanceError) {
      if (balanceError.code !== 'PGRST116') {
        console.error('Error fetching token balance:', balanceError)
      }
      // Continue with default values instead of failing
    }

    // Get user's profile for daily claim info - but don't fail if not found
    const { data: profile, error: profileError } = await supabase
      .from('user_profiles')
      .select('id')
      .eq('id', user!.id)
      .single()

    // If profile doesn't exist, continue with default values
    // This allows new users to still see their token balance
    if (profileError && profileError.code !== 'PGRST116') {
      console.error('Error fetching profile:', profileError)
    }

    // For now, we'll skip daily claim checks since we don't have that field in token_balances
    // TODO: Add daily claim tracking to token_balances table
    
    const balance = tokenBalance?.balance || 0
    const totalPurchased = tokenBalance?.total_purchased || 0
    const totalUsed = tokenBalance?.total_used || 0

    // Check if user has unlimited access (e.g., subscription)
    const { data: subscription } = await supabase
      .from('subscriptions')
      .select('status, ends_at')
      .eq('user_id', user!.id)
      .eq('status', 'active')
      .single()

    const isUnlimited = subscription !== null

    return new Response(
      JSON.stringify({
        balance,
        totalPurchased,
        totalUsed,
        isUnlimited
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