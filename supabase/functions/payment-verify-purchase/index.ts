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
  'com.beyond.fortune.tokens10': { productId: 'com.beyond.fortune.tokens10', tokens: 10, price: 1000 },
  'com.beyond.fortune.tokens50': { productId: 'com.beyond.fortune.tokens50', tokens: 50, price: 4500 },
  'com.beyond.fortune.tokens100': { productId: 'com.beyond.fortune.tokens100', tokens: 100, price: 8000 },
  'com.beyond.fortune.tokens200': { productId: 'com.beyond.fortune.tokens200', tokens: 200, price: 14000 },
  'com.beyond.fortune.subscription.monthly': { productId: 'com.beyond.fortune.subscription.monthly', tokens: -1, price: 9900 },
  'com.beyond.fortune.subscription.yearly': { productId: 'com.beyond.fortune.subscription.yearly', tokens: -1, price: 99000 },
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

    // Import verification utilities
    const { verifyPurchase } = await import('../_shared/payment-verification.ts')

    // Verify the purchase with Apple/Google servers
    const verificationResult = await verifyPurchase(platform, {
      productId,
      purchaseToken,
      transactionReceipt,
      packageName: platform === 'android' ? 'com.beyond.fortune' : undefined,
    })

    if (!verificationResult.valid) {
      console.error('Purchase verification failed:', verificationResult.error)
      return new Response(
        JSON.stringify({ 
          error: 'Purchase verification failed',
          details: verificationResult.error 
        }),
        { 
          status: 400, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // Additional validation: Check if the verified data matches our request
    if (platform === 'ios' && verificationResult.data) {
      if (verificationResult.data.productId !== productId) {
        return new Response(
          JSON.stringify({ 
            error: 'Product ID mismatch',
            expected: productId,
            received: verificationResult.data.productId
          }),
          { 
            status: 400, 
            headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
          }
        )
      }
    }

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