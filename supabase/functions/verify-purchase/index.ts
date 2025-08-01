import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { corsHeaders } from '../_shared/cors.ts'

interface PurchaseVerificationRequest {
  productId: string
  purchaseToken: string
  platform: 'ios' | 'android' | 'web'
}

serve(async (req) => {
  // Handle CORS
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { productId, purchaseToken, platform }: PurchaseVerificationRequest = await req.json()
    
    if (!productId || !purchaseToken || !platform) {
      throw new Error('Missing required fields')
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

    // TODO: Verify purchase with Apple/Google servers
    // For now, we'll trust the client and just record the purchase
    
    // Record the purchase in the database
    const { error: purchaseError } = await supabaseAdmin
      .from('purchase_history')
      .insert({
        user_id: user.id,
        product_id: productId,
        platform: platform,
        purchase_token: purchaseToken,
        status: 'completed',
        created_at: new Date().toISOString(),
      })

    if (purchaseError) {
      console.error('Error recording purchase:', purchaseError)
      // Don't throw error here, continue with token addition
    }

    // Get product details
    const productTokens = getProductTokens(productId)
    const isSubscription = isSubscriptionProduct(productId)

    if (isSubscription) {
      // Update user subscription status
      const { error: subError } = await supabaseAdmin
        .from('user_profiles')
        .update({
          subscription_status: 'premium',
          subscription_start_date: new Date().toISOString(),
          subscription_end_date: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString(), // 30 days
          updated_at: new Date().toISOString(),
        })
        .eq('id', user.id)

      if (subError) {
        throw new Error('Failed to update subscription status')
      }
    } else {
      // Add tokens to user account
      const { data: profile, error: profileError } = await supabaseAdmin
        .from('user_profiles')
        .select('total_tokens')
        .eq('id', user.id)
        .single()

      if (profileError) {
        throw new Error('Failed to get user profile')
      }

      const currentTokens = profile?.total_tokens || 0
      const newTokens = currentTokens + productTokens

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
          amount: productTokens,
          type: 'purchase',
          description: `Purchased ${productTokens} tokens`,
          created_at: new Date().toISOString(),
        })

      if (transactionError) {
        console.error('Error recording transaction:', transactionError)
        // Don't throw error here, tokens were already added
      }
    }

    return new Response(
      JSON.stringify({
        success: true,
        productId: productId,
        tokens: productTokens,
        isSubscription: isSubscription,
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      }
    )
  } catch (error) {
    console.error('Purchase verification error:', error)
    return new Response(
      JSON.stringify({ error: error.message }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 400,
      }
    )
  }
})

function getProductTokens(productId: string): number {
  const tokenMap: Record<string, number> = {
    'com.beyond.fortune.tokens10': 10,
    'com.beyond.fortune.tokens30': 30,
    'com.beyond.fortune.tokens50': 50,
    'com.beyond.fortune.tokens100': 100,
    'com.beyond.fortune.tokens300': 300,
  }
  return tokenMap[productId] || 0
}

function isSubscriptionProduct(productId: string): boolean {
  return productId === 'com.beyond.fortune.subscription.monthly'
}