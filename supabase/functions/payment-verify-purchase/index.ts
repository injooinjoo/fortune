import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

/**
 * 결제 검증 Edge Function
 *
 * POST /payment/verify-purchase
 *
 * Request Body:
 * - platform: 'ios' | 'android'
 * - productId: string
 * - purchaseToken?: string (Android)
 * - receipt?: string (iOS)
 * - orderId?: string (Android)
 * - transactionId?: string (iOS)
 *
 * Response:
 * - { valid: boolean, error?: string }
 *
 * TODO: 실제 스토어 API 검증 구현
 * - iOS: App Store Server API v2
 * - Android: Google Play Developer API
 */
serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response(null, { headers: corsHeaders })
  }

  // POST 요청만 허용
  if (req.method !== 'POST') {
    return new Response(
      JSON.stringify({ valid: false, error: 'Method not allowed' }),
      {
        status: 405,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      }
    )
  }

  try {
    // 요청 바디 파싱
    const body = await req.json()
    const {
      platform,
      productId,
      purchaseToken,  // Android
      receipt,        // iOS
      orderId,        // Android
      transactionId   // iOS
    } = body

    // 필수 파라미터 검증
    if (!platform || !productId) {
      console.log('❌ Missing required parameters')
      return new Response(
        JSON.stringify({ valid: false, error: 'Missing required parameters' }),
        {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      )
    }

    // 인증 토큰 추출 (선택적 - 로깅용)
    const authHeader = req.headers.get('Authorization')
    let userId: string | null = null

    if (authHeader) {
      const supabaseUrl = Deno.env.get('SUPABASE_URL')!
      const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!

      const supabase = createClient(supabaseUrl, supabaseServiceKey, {
        auth: {
          autoRefreshToken: false,
          persistSession: false
        }
      })

      const token = authHeader.replace('Bearer ', '')
      const { data: { user } } = await supabase.auth.getUser(token)
      userId = user?.id || null
    }

    console.log(`🔍 Verifying purchase`)
    console.log(`   - Platform: ${platform}`)
    console.log(`   - Product: ${productId}`)
    console.log(`   - User: ${userId || 'anonymous'}`)

    // ============================================================
    // TODO: 실제 스토어 API 검증 구현
    // ============================================================
    //
    // iOS (App Store Server API v2):
    // 1. Apple 인증서로 JWT 생성
    // 2. POST https://api.storekit.itunes.apple.com/inApps/v1/transactions/{transactionId}
    // 3. 응답에서 productId, expiresDate 확인
    //
    // Android (Google Play Developer API):
    // 1. Service Account 인증
    // 2. GET https://androidpublisher.googleapis.com/androidpublisher/v3/applications/{packageName}/purchases/subscriptions/{subscriptionId}/tokens/{token}
    // 3. 응답에서 expiryTimeMillis, orderId 확인
    //
    // 현재는 개발 단계로 기본 통과 처리
    // ============================================================

    let isValid = true
    let verificationDetails: Record<string, unknown> = {}

    if (platform === 'ios') {
      // iOS 검증 로직
      if (!receipt && !transactionId) {
        console.warn('⚠️ iOS: Missing receipt or transactionId')
        // 개발 단계에서는 통과
      }

      verificationDetails = {
        platform: 'ios',
        transactionId,
        hasReceipt: !!receipt,
        verifiedAt: new Date().toISOString(),
        method: 'development_bypass'  // TODO: 'app_store_api_v2'로 변경
      }

      console.log(`✅ iOS purchase verification: PASS (development mode)`)

    } else if (platform === 'android') {
      // Android 검증 로직
      if (!purchaseToken) {
        console.warn('⚠️ Android: Missing purchaseToken')
        // 개발 단계에서는 통과
      }

      verificationDetails = {
        platform: 'android',
        orderId,
        hasPurchaseToken: !!purchaseToken,
        verifiedAt: new Date().toISOString(),
        method: 'development_bypass'  // TODO: 'google_play_api'로 변경
      }

      console.log(`✅ Android purchase verification: PASS (development mode)`)

    } else {
      console.warn(`⚠️ Unknown platform: ${platform}`)
      isValid = false
    }

    // 검증 이벤트 로깅 (사용자가 있는 경우)
    if (userId) {
      const supabaseUrl = Deno.env.get('SUPABASE_URL')!
      const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!

      const supabase = createClient(supabaseUrl, supabaseServiceKey, {
        auth: { autoRefreshToken: false, persistSession: false }
      })

      await supabase.from('subscription_events').insert({
        user_id: userId,
        event_type: 'verified',
        product_id: productId,
        platform,
        purchase_id: transactionId || orderId,
        metadata: {
          valid: isValid,
          verification: verificationDetails
        }
      })
    }

    return new Response(
      JSON.stringify({
        valid: isValid,
        productId,
        platform,
        verifiedAt: new Date().toISOString()
      }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    console.error('❌ Purchase verification error:', error)
    return new Response(
      JSON.stringify({ valid: false, error: 'Verification failed' }),
      {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      }
    )
  }
})
