import { NextRequest, NextResponse } from 'next/server';
import { withAuth } from '@/middleware/auth';
import { z } from 'zod';
import { logger } from '@/lib/logger';
import { supabase } from '@/lib/supabase';
import { google } from 'googleapis';
import { verifyAppleReceipt } from '@/lib/payment/apple-iap';

// 요청 검증 스키마
const VerifyPurchaseSchema = z.object({
  platform: z.enum(['android', 'ios']),
  productId: z.string(),
  purchaseToken: z.string().optional(), // Android
  receipt: z.string().optional(), // iOS
  orderId: z.string().optional(),
  transactionId: z.string().optional(),
});

// 토큰 수량 매핑
const TOKEN_AMOUNTS: Record<string, number> = {
  'com.fortune.tokens.10': 10,
  'com.fortune.tokens.50': 50,
  'com.fortune.tokens.100': 100,
  'com.fortune.tokens.200': 200,
};

export async function POST(request: NextRequest) {
  return withAuth(request, async (req) => {
    try {
      const body = await req.json();
      const validatedData = VerifyPurchaseSchema.parse(body);
      const userId = req.userId!;

      logger.info('[Payment] Verifying purchase', {
        userId,
        platform: validatedData.platform,
        productId: validatedData.productId,
      });

      let isValid = false;
      let purchaseInfo: any = {};

      // 플랫폼별 검증
      if (validatedData.platform === 'android') {
        const result = await verifyGooglePurchase(
          validatedData.purchaseToken!,
          validatedData.productId
        );
        isValid = result.valid;
        purchaseInfo = result.purchaseInfo;
      } else if (validatedData.platform === 'ios') {
        const result = await verifyAppleReceipt(
          validatedData.receipt!,
          validatedData.productId
        );
        isValid = result.valid;
        purchaseInfo = result.purchaseInfo;
      }

      if (!isValid) {
        logger.warn('[Payment] Invalid purchase detected', {
          userId,
          platform: validatedData.platform,
          productId: validatedData.productId,
        });
        
        return NextResponse.json(
          { valid: false, error: '유효하지 않은 구매입니다.' },
          { status: 400 }
        );
      }

      // 중복 구매 확인
      const existingPurchase = await supabase
        .from('purchases')
        .select('id')
        .eq('transaction_id', purchaseInfo.transactionId)
        .single();

      if (existingPurchase.data) {
        logger.info('[Payment] Duplicate purchase detected', {
          transactionId: purchaseInfo.transactionId,
        });
        
        return NextResponse.json({
          valid: true,
          duplicate: true,
          message: '이미 처리된 구매입니다.',
        });
      }

      // 구매 기록 저장
      const { error: insertError } = await supabase
        .from('purchases')
        .insert({
          user_id: userId,
          platform: validatedData.platform,
          product_id: validatedData.productId,
          transaction_id: purchaseInfo.transactionId,
          order_id: validatedData.orderId,
          purchase_date: purchaseInfo.purchaseDate,
          amount: purchaseInfo.amount,
          currency: purchaseInfo.currency || 'KRW',
          status: 'completed',
          raw_data: purchaseInfo,
        });

      if (insertError) {
        logger.error('[Payment] Failed to save purchase', insertError);
        throw new Error('구매 기록 저장 실패');
      }

      // 토큰 상품인 경우 토큰 추가
      const tokenAmount = TOKEN_AMOUNTS[validatedData.productId];
      if (tokenAmount) {
        const { error: tokenError } = await supabase.rpc('add_user_tokens', {
          p_user_id: userId,
          p_amount: tokenAmount,
          p_reason: `인앱 구매: ${validatedData.productId}`,
          p_reference_id: purchaseInfo.transactionId,
        });

        if (tokenError) {
          logger.error('[Payment] Failed to add tokens', tokenError);
          throw new Error('토큰 추가 실패');
        }

        logger.info('[Payment] Tokens added successfully', {
          userId,
          amount: tokenAmount,
          productId: validatedData.productId,
        });
      }

      // 구독 상품인 경우 구독 활성화
      if (validatedData.productId.includes('subscription')) {
        await activateSubscription(userId, validatedData.productId, purchaseInfo);
      }

      return NextResponse.json({
        valid: true,
        success: true,
        message: '구매가 성공적으로 처리되었습니다.',
        tokenAmount,
      });

    } catch (error) {
      logger.error('[Payment] Error verifying purchase:', error);

      if (error instanceof z.ZodError) {
        return NextResponse.json(
          { error: '잘못된 요청 형식입니다.', details: error.errors },
          { status: 400 }
        );
      }

      return NextResponse.json(
        { error: '구매 검증 중 오류가 발생했습니다.' },
        { status: 500 }
      );
    }
  });
}

// Google Play 구매 검증
async function verifyGooglePurchase(
  purchaseToken: string,
  productId: string
): Promise<{ valid: boolean; purchaseInfo: any }> {
  try {
    const auth = new google.auth.GoogleAuth({
      keyFile: process.env.GOOGLE_SERVICE_ACCOUNT_KEY_PATH,
      scopes: ['https://www.googleapis.com/auth/androidpublisher'],
    });

    const androidPublisher = google.androidpublisher({
      version: 'v3',
      auth,
    });

    // 소모성 상품 검증
    if (productId.includes('tokens')) {
      const response = await androidPublisher.purchases.products.get({
        packageName: 'com.fortune.fortune_flutter',
        productId,
        token: purchaseToken,
      });

      const purchase = response.data;
      const isValid = purchase.purchaseState === 0; // 0 = purchased

      return {
        valid: isValid,
        purchaseInfo: {
          transactionId: purchase.orderId,
          purchaseDate: new Date(parseInt(purchase.purchaseTimeMillis || '0')),
          amount: purchase.priceAmountMicros ? parseInt(purchase.priceAmountMicros) / 1000000 : 0,
          currency: purchase.priceCurrencyCode,
          ...purchase,
        },
      };
    }

    // 구독 상품 검증
    const response = await androidPublisher.purchases.subscriptions.get({
      packageName: 'com.fortune.fortune_flutter',
      subscriptionId: productId,
      token: purchaseToken,
    });

    const subscription = response.data;
    const isValid = subscription.paymentState === 1; // 1 = payment received

    return {
      valid: isValid,
      purchaseInfo: {
        transactionId: subscription.orderId,
        purchaseDate: new Date(parseInt(subscription.startTimeMillis || '0')),
        expiryDate: new Date(parseInt(subscription.expiryTimeMillis || '0')),
        amount: subscription.priceAmountMicros ? parseInt(subscription.priceAmountMicros) / 1000000 : 0,
        currency: subscription.priceCurrencyCode,
        ...subscription,
      },
    };

  } catch (error) {
    logger.error('[Payment] Google purchase verification failed', error);
    return { valid: false, purchaseInfo: {} };
  }
}

// 구독 활성화
async function activateSubscription(
  userId: string,
  productId: string,
  purchaseInfo: any
): Promise<void> {
  const isMonthly = productId.includes('monthly');
  const subscriptionType = isMonthly ? 'monthly' : 'yearly';
  
  const startDate = new Date();
  const endDate = new Date();
  
  if (isMonthly) {
    endDate.setMonth(endDate.getMonth() + 1);
  } else {
    endDate.setFullYear(endDate.getFullYear() + 1);
  }

  const { error } = await supabase
    .from('subscriptions')
    .upsert({
      user_id: userId,
      type: subscriptionType,
      status: 'active',
      start_date: startDate.toISOString(),
      end_date: endDate.toISOString(),
      product_id: productId,
      transaction_id: purchaseInfo.transactionId,
      platform: purchaseInfo.platform,
      auto_renew: true,
      updated_at: new Date().toISOString(),
    }, {
      onConflict: 'user_id',
    });

  if (error) {
    logger.error('[Payment] Failed to activate subscription', error);
    throw new Error('구독 활성화 실패');
  }

  logger.info('[Payment] Subscription activated', {
    userId,
    type: subscriptionType,
    endDate: endDate.toISOString(),
  });
}