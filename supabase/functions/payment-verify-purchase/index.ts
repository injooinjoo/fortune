import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { corsHeaders, handleCors } from '../_shared/cors.ts'
import { authenticateUser } from '../_shared/auth.ts'

interface PurchaseVerificationRequest {
  platform: 'ios' | 'android'
  productId: string
  purchaseToken?: string // Android
  transactionReceipt?: string // iOS
  transactionId: string
}

interface TokenPackage {
  productId: string
  tokens: number
  price: number
}

const TOKEN_PACKAGES: Record<string, TokenPackage> = {
  'com.fortune.tokens.small': { productId: 'com.fortune.tokens.small', tokens: 10, price: 990 },
  'com.fortune.tokens.medium': { productId: 'com.fortune.tokens.medium', tokens: 30, price: 2990 },
  'com.fortune.tokens.large': { productId: 'com.fortune.tokens.large', tokens: 100, price: 9900 },
  'com.fortune.tokens.mega': { productId: 'com.fortune.tokens.mega', tokens: 200, price: 19900 },
}

serve(async (req: Request) => {
  // Handle CORS
  const corsResponse = handleCors(req)
  if (corsResponse) return corsResponse

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

    // Parse request body
    const body: PurchaseVerificationRequest = await req.json()
    const { platform, productId, purchaseToken, transactionReceipt, transactionId } = body

    // Validate request
    if (!platform || !productId || !transactionId) {
      return new Response(
        JSON.stringify({ error: 'Missing required fields' }),
        { 
          status: 400, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    if (platform === 'android' && !purchaseToken) {
      return new Response(
        JSON.stringify({ error: 'Purchase token required for Android' }),
        { 
          status: 400, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    if (platform === 'ios' && !transactionReceipt) {
      return new Response(
        JSON.stringify({ error: 'Transaction receipt required for iOS' }),
        { 
          status: 400, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    )

    // Check if transaction already processed
    const { data: existingTransaction } = await supabase
      .from('payment_transactions')
      .select('id')
      .eq('transaction_id', transactionId)
      .single()

    if (existingTransaction) {
      return new Response(
        JSON.stringify({ 
          error: 'Transaction already processed',
          transactionId 
        }),
        { 
          status: 400, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // TODO: Verify with Apple/Google servers
    // For now, we'll trust the client (NOT FOR PRODUCTION)
    // In production, implement actual verification:
    // - For iOS: Verify receipt with Apple's verifyReceipt API
    // - For Android: Verify purchase with Google Play API

    // Get token package
    const tokenPackage = TOKEN_PACKAGES[productId]
    if (!tokenPackage) {
      return new Response(
        JSON.stringify({ error: 'Invalid product ID' }),
        { 
          status: 400, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // Get current balance
    const { data: profile } = await supabase
      .from('user_profiles')
      .select('token_balance')
      .eq('id', user!.id)
      .single()

    const currentBalance = profile?.token_balance || 0
    const newBalance = currentBalance + tokenPackage.tokens

    // Update balance
    const { error: updateError } = await supabase
      .from('user_profiles')
      .update({ token_balance: newBalance })
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

    // Record transaction
    const { error: transactionError } = await supabase
      .from('payment_transactions')
      .insert({
        user_id: user!.id,
        transaction_id: transactionId,
        platform,
        product_id: productId,
        amount: tokenPackage.price,
        tokens_purchased: tokenPackage.tokens,
        status: 'completed',
        metadata: {
          purchaseToken,
          transactionReceipt: transactionReceipt ? 'stored' : null
        }
      })

    if (transactionError) {
      console.error('Failed to record transaction:', transactionError)
    }

    // Log token usage
    await supabase
      .from('token_usage')
      .insert({
        user_id: user!.id,
        amount: tokenPackage.tokens,
        balance_after: newBalance,
        description: `Purchased ${tokenPackage.tokens} tokens`,
        transaction_type: 'credit',
        metadata: {
          transactionId,
          productId,
          platform
        }
      })

    return new Response(
      JSON.stringify({
        success: true,
        tokensAdded: tokenPackage.tokens,
        newBalance,
        transactionId
      }),
      { 
        status: 200, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )

  } catch (error) {
    console.error('Payment verification error:', error)
    return new Response(
      JSON.stringify({ error: 'Internal server error' }),
      { 
        status: 500, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )
  }
})