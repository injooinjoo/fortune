import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

// Apple Receipt Validation URLs
const APPLE_PRODUCTION_URL = 'https://buy.itunes.apple.com/verifyReceipt'
const APPLE_SANDBOX_URL = 'https://sandbox.itunes.apple.com/verifyReceipt'

// Apple Receipt Status Codes
const APPLE_STATUS = {
  SUCCESS: 0,
  SANDBOX_RECEIPT_IN_PRODUCTION: 21007,
  PRODUCTION_RECEIPT_IN_SANDBOX: 21008,
}

/**
 * iOS 영수증 검증 (Apple 권장 방식)
 * 1. Production 서버에서 먼저 검증 시도
 * 2. 21007 에러 시 Sandbox 서버로 재시도
 */
async function verifyAppleReceipt(receipt: string, sharedSecret?: string): Promise<{
  isValid: boolean
  productId?: string
  transactionId?: string
  environment?: string
  error?: string
}> {
  const requestBody = {
    'receipt-data': receipt,
    ...(sharedSecret && { 'password': sharedSecret }),
    'exclude-old-transactions': true,
  }

  console.log('🍎 Apple 영수증 검증 시작...')

  // 1. Production 서버에서 먼저 시도
  console.log('🍎 [1/2] Production 서버 검증 시도...')
  try {
    const productionResponse = await fetch(APPLE_PRODUCTION_URL, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(requestBody),
    })

    const productionResult = await productionResponse.json()
    console.log(`🍎 Production 응답 status: ${productionResult.status}`)

    // 성공
    if (productionResult.status === APPLE_STATUS.SUCCESS) {
      console.log('✅ Production 서버 검증 성공!')
      const latestReceipt = productionResult.latest_receipt_info?.[0] ||
                           productionResult.receipt?.in_app?.[0]
      return {
        isValid: true,
        productId: latestReceipt?.product_id,
        transactionId: latestReceipt?.transaction_id,
        environment: 'production',
      }
    }

    // 2. Sandbox 영수증인 경우 (21007) → Sandbox 서버로 재시도
    if (productionResult.status === APPLE_STATUS.SANDBOX_RECEIPT_IN_PRODUCTION) {
      console.log('🍎 [2/2] Sandbox 영수증 감지 → Sandbox 서버로 재시도...')

      const sandboxResponse = await fetch(APPLE_SANDBOX_URL, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(requestBody),
      })

      const sandboxResult = await sandboxResponse.json()
      console.log(`🍎 Sandbox 응답 status: ${sandboxResult.status}`)

      if (sandboxResult.status === APPLE_STATUS.SUCCESS) {
        console.log('✅ Sandbox 서버 검증 성공!')
        const latestReceipt = sandboxResult.latest_receipt_info?.[0] ||
                             sandboxResult.receipt?.in_app?.[0]
        return {
          isValid: true,
          productId: latestReceipt?.product_id,
          transactionId: latestReceipt?.transaction_id,
          environment: 'sandbox',
        }
      }

      console.log(`❌ Sandbox 검증 실패: status=${sandboxResult.status}`)
      return {
        isValid: false,
        error: `Sandbox validation failed: ${sandboxResult.status}`,
      }
    }

    // 기타 에러
    console.log(`❌ Production 검증 실패: status=${productionResult.status}`)
    return {
      isValid: false,
      error: `Apple validation failed: ${productionResult.status}`,
    }

  } catch (error) {
    console.error('❌ Apple 서버 통신 오류:', error)
    return {
      isValid: false,
      error: `Network error: ${error.message}`,
    }
  }
}

/**
 * ============================================================
 * 테이블 참조 (중요!)
 * ============================================================
 * - token_balance (단수!): 토큰 잔액 (balance, total_earned, total_spent)
 * - token_transactions: 토큰 거래 이력 (구매/사용)
 * - subscription_events: 결제 이벤트 로그
 * ============================================================
 */

// 상품별 토큰 수량 매핑
const PRODUCT_TOKENS: Record<string, number> = {
  'com.beyond.fortune.tokens10': 10,
  'com.beyond.fortune.tokens50': 50,
  'com.beyond.fortune.tokens100': 100,
  'com.beyond.fortune.tokens200': 200,
}

serve(async (req) => {
  console.log('========================================')
  console.log('🚀 payment-verify-purchase v18 시작')
  console.log('🍎 Apple 영수증 검증: Production → Sandbox fallback 지원')
  console.log('========================================')

  // CORS preflight
  if (req.method === 'OPTIONS') {
    console.log('📌 OPTIONS preflight 요청')
    return new Response(null, { headers: corsHeaders })
  }

  if (req.method !== 'POST') {
    console.log(`❌ 잘못된 메소드: ${req.method}`)
    return new Response(
      JSON.stringify({ valid: false, error: 'Method not allowed' }),
      { status: 405, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }

  try {
    console.log('📥 요청 body 파싱 시작...')
    const body = await req.json()
    console.log('📥 받은 body:', JSON.stringify(body, null, 2))

    const { platform, productId, purchaseToken, receipt, orderId, transactionId } = body
    console.log(`📦 platform: ${platform}`)
    console.log(`📦 productId: ${productId}`)
    console.log(`📦 purchaseToken: ${purchaseToken ? '있음' : '없음'}`)
    console.log(`📦 receipt: ${receipt ? '있음 (길이:' + String(receipt).length + ')' : '없음'}`)
    console.log(`📦 orderId: ${orderId}`)
    console.log(`📦 transactionId: ${transactionId}`)

    // 필수 파라미터 검증
    if (!platform || !productId) {
      console.log('❌ 필수 파라미터 누락!')
      return new Response(
        JSON.stringify({ valid: false, error: 'Missing required parameters' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Supabase 클라이언트 생성
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    console.log(`🔌 Supabase URL: ${supabaseUrl}`)
    console.log(`🔌 Service Key 존재: ${supabaseServiceKey ? '예' : '아니오'}`)

    const supabase = createClient(supabaseUrl, supabaseServiceKey, {
      auth: { autoRefreshToken: false, persistSession: false }
    })
    console.log('✅ Supabase 클라이언트 생성 완료')

    // 사용자 인증
    let userId: string | null = null
    const authHeader = req.headers.get('Authorization')
    console.log(`🔐 Authorization 헤더: ${authHeader ? '있음' : '없음'}`)

    if (authHeader) {
      const token = authHeader.replace('Bearer ', '')
      console.log(`🔐 토큰 길이: ${token.length}`)
      console.log(`🔐 토큰 앞 50자: ${token.substring(0, 50)}...`)

      const { data: { user }, error: authError } = await supabase.auth.getUser(token)

      if (authError) {
        console.log(`❌ 인증 에러: ${JSON.stringify(authError)}`)
      }

      userId = user?.id || null
      console.log(`👤 인증된 userId: ${userId}`)
      console.log(`👤 user 객체: ${user ? JSON.stringify({ id: user.id, email: user.email }) : 'null'}`)
    } else {
      console.log('⚠️ Authorization 헤더 없음 - 익명 요청')
    }

    console.log(`🔍 검증 시작: ${platform}/${productId} for user ${userId || 'anonymous'}`)

    // 플랫폼별 영수증 검증
    let isValid = false
    let verifiedProductId = productId
    let verifiedTransactionId = transactionId || orderId
    let environment = 'unknown'

    if (platform === 'ios') {
      console.log('📱 iOS 플랫폼 검증')

      if (!receipt) {
        console.error('❌ iOS: receipt 없음 - 검증 불가')
        return new Response(
          JSON.stringify({ valid: false, error: 'Missing iOS receipt' }),
          { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
      }

      // Apple App Store 공유 시크릿 (환경 변수에서 로드)
      const appleSharedSecret = Deno.env.get('APPLE_SHARED_SECRET')

      // Apple 영수증 검증 (Production → Sandbox fallback)
      const appleResult = await verifyAppleReceipt(receipt, appleSharedSecret)

      isValid = appleResult.isValid
      environment = appleResult.environment || 'unknown'

      if (appleResult.isValid) {
        verifiedProductId = appleResult.productId || productId
        verifiedTransactionId = appleResult.transactionId || transactionId
        console.log(`✅ iOS 검증 성공 (${environment}): ${verifiedProductId}`)
      } else {
        console.error(`❌ iOS 검증 실패: ${appleResult.error}`)
      }

    } else if (platform === 'android') {
      console.log('🤖 Android 플랫폼 검증')

      if (!purchaseToken) {
        console.error('❌ Android: purchaseToken 없음 - 검증 불가')
        return new Response(
          JSON.stringify({ valid: false, error: 'Missing Android purchase token' }),
          { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
      }

      // TODO: Google Play 영수증 검증 구현
      // 현재는 purchaseToken 존재 여부만 확인 (추후 Google Play Developer API 연동 필요)
      console.log('⚠️ Android: Google Play 검증은 아직 미구현 - purchaseToken 존재로 통과')
      isValid = true
      environment = 'android'

    } else {
      console.warn(`⚠️ 알 수 없는 플랫폼: ${platform}`)
      isValid = false
    }

    console.log(`✅ 플랫폼 검증 결과: isValid = ${isValid}, environment = ${environment}`)

    // 검증 성공 시 토큰 추가
    const tokensToAdd = PRODUCT_TOKENS[productId] || 0
    console.log(`💰 추가할 토큰 수: ${tokensToAdd} (productId: ${productId})`)
    console.log(`💰 PRODUCT_TOKENS 매핑: ${JSON.stringify(PRODUCT_TOKENS)}`)

    if (!userId) {
      console.log('⚠️ userId가 없어서 토큰 추가 건너뜀')
    }
    if (!isValid) {
      console.log('⚠️ isValid=false 라서 토큰 추가 건너뜀')
    }
    if (tokensToAdd <= 0) {
      console.log(`⚠️ tokensToAdd=${tokensToAdd} 라서 토큰 추가 건너뜀`)
    }

    if (userId && isValid && tokensToAdd > 0) {
      console.log('========================================')
      console.log('💰 토큰 추가 프로세스 시작')
      console.log('========================================')

      // 현재 잔액 조회 (token_balance - 단수!)
      console.log('📊 [STEP 1] 현재 잔액 조회 시작...')
      console.log(`📊 쿼리: SELECT balance, total_earned FROM token_balance WHERE user_id = '${userId}'`)

      const { data: currentBalance, error: selectError } = await supabase
        .from('token_balance')
        .select('balance, total_earned')
        .eq('user_id', userId)
        .single()

      console.log(`📊 [STEP 1] 조회 결과:`)
      console.log(`   - data: ${JSON.stringify(currentBalance)}`)
      console.log(`   - error: ${selectError ? JSON.stringify(selectError) : 'null'}`)

      const oldBalance = currentBalance?.balance || 0
      const oldTotalEarned = currentBalance?.total_earned || 0
      const newBalance = oldBalance + tokensToAdd

      console.log(`📊 계산:`)
      console.log(`   - 기존 balance: ${oldBalance}`)
      console.log(`   - 기존 total_earned: ${oldTotalEarned}`)
      console.log(`   - 추가할 토큰: ${tokensToAdd}`)
      console.log(`   - 새 balance: ${newBalance}`)
      console.log(`   - 새 total_earned: ${oldTotalEarned + tokensToAdd}`)

      // 잔액 업데이트 (token_balance - 단수!)
      console.log('📊 [STEP 2] 잔액 업데이트 시작...')
      const upsertData = {
        user_id: userId,
        balance: newBalance,
        total_earned: oldTotalEarned + tokensToAdd,
        updated_at: new Date().toISOString()
      }
      console.log(`📊 UPSERT 데이터: ${JSON.stringify(upsertData, null, 2)}`)

      const { data: upsertResult, error: balanceError } = await supabase
        .from('token_balance')
        .upsert(upsertData, { onConflict: 'user_id' })
        .select()

      console.log(`📊 [STEP 2] UPSERT 결과:`)
      console.log(`   - data: ${JSON.stringify(upsertResult)}`)
      console.log(`   - error: ${balanceError ? JSON.stringify(balanceError) : 'null'}`)

      if (balanceError) {
        console.error('❌ 토큰 잔액 업데이트 실패!')
        console.error(`❌ 에러 상세: ${JSON.stringify(balanceError, null, 2)}`)
      } else {
        console.log(`✅ 토큰 잔액 업데이트 성공: ${oldBalance} → ${newBalance}`)

        // 구매 이력 기록 (token_transactions 사용)
        console.log('📊 [STEP 3] 거래 이력 기록 시작...')
        const transactionData = {
          user_id: userId,
          transaction_type: 'purchase',
          amount: tokensToAdd,
          balance_after: newBalance,
          description: `토큰 ${tokensToAdd}개 구매`,
          reference_type: 'in_app_purchase',
          reference_id: transactionId || orderId
        }
        console.log(`📊 INSERT 데이터: ${JSON.stringify(transactionData, null, 2)}`)

        const { data: txResult, error: txError } = await supabase
          .from('token_transactions')
          .insert(transactionData)
          .select()

        console.log(`📊 [STEP 3] INSERT 결과:`)
        console.log(`   - data: ${JSON.stringify(txResult)}`)
        console.log(`   - error: ${txError ? JSON.stringify(txError) : 'null'}`)
      }

      // 이벤트 로깅
      console.log('📊 [STEP 4] 이벤트 로깅 시작...')
      const eventData = {
        user_id: userId,
        event_type: 'purchase_verified',
        product_id: productId,
        platform,
        purchase_id: transactionId || orderId,
        metadata: { tokens_added: tokensToAdd, new_balance: newBalance }
      }
      console.log(`📊 INSERT 데이터: ${JSON.stringify(eventData, null, 2)}`)

      const { error: eventError } = await supabase
        .from('subscription_events')
        .insert(eventData)

      console.log(`📊 [STEP 4] 이벤트 로깅 결과: ${eventError ? JSON.stringify(eventError) : '성공'}`)

      console.log('========================================')
      console.log('✅ 토큰 추가 프로세스 완료')
      console.log('========================================')
    }

    const responseData = {
      valid: isValid,
      productId: verifiedProductId,
      platform,
      environment,
      tokensAdded: isValid ? tokensToAdd : 0,
      verifiedAt: new Date().toISOString()
    }
    console.log('📤 응답 데이터:', JSON.stringify(responseData, null, 2))
    console.log('========================================')
    console.log('🏁 payment-verify-purchase 종료')
    console.log('========================================')

    return new Response(
      JSON.stringify(responseData),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    console.error('========================================')
    console.error('❌ 치명적 오류 발생!')
    console.error('========================================')
    console.error('❌ 에러:', error)
    console.error('❌ 에러 메시지:', error.message)
    console.error('❌ 에러 스택:', error.stack)
    return new Response(
      JSON.stringify({ valid: false, error: 'Verification failed', details: error.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})
