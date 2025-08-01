import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { corsHeaders } from '../_shared/cors.ts'

interface AddTokensRequest {
  tokens: number
}

serve(async (req) => {
  // Handle CORS
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { tokens }: AddTokensRequest = await req.json()
    
    if (!tokens || tokens <= 0) {
      throw new Error('Invalid token amount')
    }

    // Initialize Supabase Admin Client
    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
      {
        auth: {
          autoRefreshToken: false,
          persistSession: false,
        },
      }
    )

    // Get the authenticated user from the Authorization header
    const authHeader = req.headers.get('Authorization')
    if (!authHeader) {
      throw new Error('No authorization header')
    }

    const token = authHeader.replace('Bearer ', '')
    const { data: { user }, error: userError } = await supabaseAdmin.auth.getUser(token)
    
    if (userError || !user) {
      throw new Error('Invalid user token')
    }

    // Get current token balance
    const { data: profile, error: profileError } = await supabaseAdmin
      .from('user_profiles')
      .select('total_tokens')
      .eq('id', user.id)
      .single()

    if (profileError) {
      throw new Error('Failed to get user profile')
    }

    const currentTokens = profile?.total_tokens || 0
    const newTokens = currentTokens + tokens

    // Update user tokens
    const { error: updateError } = await supabaseAdmin
      .from('user_profiles')
      .update({
        total_tokens: newTokens,
        updated_at: new Date().toISOString(),
      })
      .eq('id', user.id)

    if (updateError) {
      throw new Error('Failed to update user tokens')
    }

    // Record token transaction
    const { error: transactionError } = await supabaseAdmin
      .from('token_transactions')
      .insert({
        user_id: user.id,
        amount: tokens,
        type: 'purchase',
        description: `Added ${tokens} tokens`,
        created_at: new Date().toISOString(),
      })

    if (transactionError) {
      console.error('Error recording transaction:', transactionError)
      // Don't throw error here, tokens were already added
    }

    return new Response(
      JSON.stringify({
        success: true,
        currentTokens: currentTokens,
        newTokens: newTokens,
        tokensAdded: tokens,
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      }
    )
  } catch (error) {
    console.error('Add tokens error:', error)
    return new Response(
      JSON.stringify({ error: error.message }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 400,
      }
    )
  }
})