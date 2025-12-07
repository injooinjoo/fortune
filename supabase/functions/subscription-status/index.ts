import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

/**
 * 구독 상태 확인 Edge Function
 *
 * GET /subscription/status
 *
 * Response:
 * - { active: boolean, expiresAt?: string, productId?: string }
 */
serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response(null, { headers: corsHeaders })
  }

  // GET 요청만 허용
  if (req.method !== 'GET') {
    return new Response(
      JSON.stringify({ active: false, error: 'Method not allowed' }),
      {
        status: 405,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      }
    )
  }

  try {
    // 인증 토큰 추출
    const authHeader = req.headers.get('Authorization')
    if (!authHeader) {
      console.log('❌ No authorization header')
      return new Response(
        JSON.stringify({ active: false, error: 'No authorization' }),
        {
          status: 401,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      )
    }

    // Supabase 클라이언트 생성
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!

    const supabase = createClient(supabaseUrl, supabaseServiceKey, {
      auth: {
        autoRefreshToken: false,
        persistSession: false
      }
    })

    // JWT에서 사용자 ID 추출
    const token = authHeader.replace('Bearer ', '')
    const { data: { user }, error: userError } = await supabase.auth.getUser(token)

    if (userError || !user) {
      console.log('❌ User authentication failed:', userError?.message)
      return new Response(
        JSON.stringify({ active: false }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    console.log(`🔍 Checking subscription for user: ${user.id}`)

    // 활성 구독 확인 (status = 'active' AND expires_at > NOW())
    const { data: subscription, error: subError } = await supabase
      .from('subscriptions')
      .select('id, product_id, expires_at, started_at, platform, auto_renewing')
      .eq('user_id', user.id)
      .eq('status', 'active')
      .gt('expires_at', new Date().toISOString())
      .order('expires_at', { ascending: false })
      .limit(1)
      .single()

    if (subError && subError.code !== 'PGRST116') {
      // PGRST116 = no rows found (정상적인 "구독 없음" 상태)
      console.error('❌ Database error:', subError.message)
    }

    const isActive = !!subscription

    console.log(`✅ Subscription status for ${user.id}: active=${isActive}`)
    if (subscription) {
      console.log(`   - Product: ${subscription.product_id}`)
      console.log(`   - Expires: ${subscription.expires_at}`)
    }

    return new Response(
      JSON.stringify({
        active: isActive,
        expiresAt: subscription?.expires_at || null,
        productId: subscription?.product_id || null,
        autoRenewing: subscription?.auto_renewing || false
      }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    console.error('❌ Subscription status error:', error)
    return new Response(
      JSON.stringify({ active: false, error: 'Internal server error' }),
      {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      }
    )
  }
})
