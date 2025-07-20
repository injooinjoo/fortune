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

    // Get query parameters
    const url = new URL(req.url)
    const limit = parseInt(url.searchParams.get('limit') || '20')
    const offset = parseInt(url.searchParams.get('offset') || '0')

    // Get user's token usage history
    const { data: usageHistory, error: usageError, count } = await supabase
      .from('token_usage')
      .select('*', { count: 'exact' })
      .eq('user_id', user!.id)
      .order('created_at', { ascending: false })
      .range(offset, offset + limit - 1)

    if (usageError) {
      console.error('Error fetching token usage history:', usageError)
      return new Response(
        JSON.stringify({ error: 'Failed to fetch token history' }),
        { 
          status: 500, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // Get user's token purchase history
    const { data: purchaseHistory, error: purchaseError } = await supabase
      .from('token_purchases')
      .select('*')
      .eq('user_id', user!.id)
      .eq('status', 'completed')
      .order('created_at', { ascending: false })
      .range(offset, offset + limit - 1)

    if (purchaseError) {
      console.error('Error fetching token purchase history:', purchaseError)
    }

    // Combine and format transactions
    const transactions = []
    
    // Add usage transactions
    if (usageHistory) {
      usageHistory.forEach(usage => {
        transactions.push({
          id: usage.id,
          type: 'usage',
          amount: -usage.tokens_used,
          description: `${usage.fortune_type} fortune`,
          fortuneType: usage.fortune_type,
          createdAt: usage.created_at,
          balanceAfter: null // We don't track this currently
        })
      })
    }

    // Add purchase transactions
    if (purchaseHistory) {
      purchaseHistory.forEach(purchase => {
        transactions.push({
          id: purchase.id,
          type: 'purchase',
          amount: purchase.tokens,
          description: `Token purchase`,
          referenceId: purchase.payment_id,
          createdAt: purchase.created_at,
          balanceAfter: null // We don't track this currently
        })
      })
    }

    // Sort by date descending
    transactions.sort((a, b) => 
      new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime()
    )

    // Return paginated results
    return new Response(
      JSON.stringify({
        transactions: transactions.slice(0, limit),
        total: count || 0,
        limit,
        offset
      }),
      { 
        status: 200, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )

  } catch (error) {
    console.error('Token history error:', error)
    return new Response(
      JSON.stringify({ error: 'Internal server error' }),
      { 
        status: 500, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )
  }
})