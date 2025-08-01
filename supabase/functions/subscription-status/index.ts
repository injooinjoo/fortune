import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { corsHeaders } from '../_shared/cors.ts'

serve(async (req) => {
  // Handle CORS
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
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

    if (req.method === 'GET') {
      // Get subscription status
      const { data: profile, error: profileError } = await supabaseAdmin
        .from('user_profiles')
        .select('subscription_status, subscription_start_date, subscription_end_date')
        .eq('id', user.id)
        .single()

      if (profileError) {
        throw new Error('Failed to get user profile')
      }

      const isSubscribed = profile?.subscription_status === 'premium' && 
        profile?.subscription_end_date && 
        new Date(profile.subscription_end_date) > new Date()

      return new Response(
        JSON.stringify({
          isSubscribed: isSubscribed,
          status: profile?.subscription_status || 'free',
          startDate: profile?.subscription_start_date,
          endDate: profile?.subscription_end_date,
        }),
        {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 200,
        }
      )
    } else if (req.method === 'POST') {
      // Update subscription status
      const { isSubscribed } = await req.json()
      
      const updateData: any = {
        subscription_status: isSubscribed ? 'premium' : 'free',
        updated_at: new Date().toISOString(),
      }

      if (isSubscribed) {
        updateData.subscription_start_date = new Date().toISOString()
        updateData.subscription_end_date = new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString() // 30 days
      } else {
        updateData.subscription_end_date = new Date().toISOString()
      }

      const { error: updateError } = await supabaseAdmin
        .from('user_profiles')
        .update(updateData)
        .eq('id', user.id)

      if (updateError) {
        throw new Error('Failed to update subscription status')
      }

      // Record subscription transaction
      const { error: transactionError } = await supabaseAdmin
        .from('token_transactions')
        .insert({
          user_id: user.id,
          amount: 0,
          type: isSubscribed ? 'subscription_start' : 'subscription_cancel',
          description: isSubscribed ? 'Started monthly subscription' : 'Cancelled subscription',
          created_at: new Date().toISOString(),
        })

      if (transactionError) {
        console.error('Error recording transaction:', transactionError)
        // Don't throw error here
      }

      return new Response(
        JSON.stringify({
          success: true,
          isSubscribed: isSubscribed,
        }),
        {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 200,
        }
      )
    } else {
      throw new Error('Method not allowed')
    }
  } catch (error) {
    console.error('Subscription status error:', error)
    return new Response(
      JSON.stringify({ error: error.message }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 400,
      }
    )
  }
})