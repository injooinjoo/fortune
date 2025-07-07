import { NextRequest, NextResponse } from 'next/server';
import { withAuth } from '@/middleware/auth';
import { createOrUpdateCustomer, createPaymentIntent, PRICE_CONFIG } from '@/lib/payment/stripe-client';
import { generateOrderId, TOSS_PRICE_CONFIG } from '@/lib/payment/toss-client';
import { z } from 'zod';
import { logger } from '@/lib/logger';

// 요청 검증 스키마
const CheckoutRequestSchema = z.object({
  provider: z.enum(['stripe', 'toss']),
  productType: z.enum(['subscription', 'tokens', 'coins']),
  productId: z.string(),
  returnUrl: z.string().url().optional(),
  cancelUrl: z.string().url().optional()
});

export async function POST(request: NextRequest) {
  return withAuth(request, async (req) => {
    try {
      const body = await req.json();
      const validatedData = CheckoutRequestSchema.parse(body);
      
      const userId = req.userId!;
      const userEmail = req.userEmail!;
      
      logger.info('[Payment] Creating checkout session', {
        userId,
        provider: validatedData.provider,
        productType: validatedData.productType,
        productId: validatedData.productId
      });
      
      if (validatedData.provider === 'stripe') {
        // Stripe 결제 처리
        logger.info('[Payment] Creating/updating Stripe customer', { userId, userEmail });
        const customer = await createOrUpdateCustomer(userEmail, userId);
        
        let clientSecret: string;
        let checkoutUrl: string;
        
        if (validatedData.productType === 'subscription') {
          // 구독 상품
          const priceConfig = PRICE_CONFIG.PREMIUM_MONTHLY; // or PREMIUM_YEARLY
          
          // Stripe Checkout 세션 생성
          const stripe = (await import('stripe')).default;
          const stripeClient = new stripe(process.env.STRIPE_SECRET_KEY!);
          
          const session = await stripeClient.checkout.sessions.create({
            customer: customer.id,
            line_items: [{
              price: priceConfig.priceId,
              quantity: 1
            }],
            mode: 'subscription',
            success_url: validatedData.returnUrl || `${process.env.NEXT_PUBLIC_APP_URL}/payment/success?session_id={CHECKOUT_SESSION_ID}`,
            cancel_url: validatedData.cancelUrl || `${process.env.NEXT_PUBLIC_APP_URL}/payment/cancel`,
            metadata: {
              userId,
              productId: validatedData.productId
            }
          });
          
          checkoutUrl = session.url!;
          logger.info('[Payment] Stripe checkout session created', { 
            sessionId: session.id,
            checkoutUrl 
          });
          
        } else {
          // 일회성 결제 (토큰)
          const tokenConfig = PRICE_CONFIG.ONE_TIME_TOKENS.MEDIUM; // 선택된 패키지
          
          const paymentIntent = await createPaymentIntent(
            tokenConfig.amount,
            customer.id,
            {
              userId,
              productType: 'tokens',
              tokens: tokenConfig.tokens.toString()
            }
          );
          
          clientSecret = paymentIntent.client_secret!;
          checkoutUrl = `${process.env.NEXT_PUBLIC_APP_URL}/payment/checkout?client_secret=${clientSecret}`;
          
          logger.info('[Payment] Stripe payment intent created', {
            paymentIntentId: paymentIntent.id,
            amount: tokenConfig.amount
          });
        }
        
        return NextResponse.json({
          success: true,
          provider: 'stripe',
          checkoutUrl,
          customerId: customer.id
        });
        
      } else if (validatedData.provider === 'toss') {
        // 토스페이먼츠 결제 처리
        const orderId = generateOrderId(userId, validatedData.productType);
        
        let amount: number;
        let orderName: string;
        
        if (validatedData.productType === 'subscription') {
          const config = TOSS_PRICE_CONFIG.PREMIUM_MONTHLY;
          amount = config.amount;
          orderName = config.orderName;
        } else {
          const config = TOSS_PRICE_CONFIG.COINS.PACK_550;
          amount = config.amount;
          orderName = config.orderName;
        }
        
        // 토스페이먼츠 결제창 호출을 위한 정보 반환
        logger.info('[Payment] Toss payment info prepared', {
          orderId,
          amount,
          orderName
        });
        
        return NextResponse.json({
          success: true,
          provider: 'toss',
          orderId,
          amount,
          orderName,
          customerKey: userId,
          successUrl: validatedData.returnUrl || `${process.env.NEXT_PUBLIC_APP_URL}/payment/success`,
          failUrl: validatedData.cancelUrl || `${process.env.NEXT_PUBLIC_APP_URL}/payment/fail`
        });
      }
      
      return NextResponse.json(
        { error: '지원하지 않는 결제 방식입니다.' },
        { status: 400 }
      );
      
    } catch (error) {
      logger.error('[Payment] Error creating checkout:', error);
      
      if (error instanceof z.ZodError) {
        logger.warn('[Payment] Invalid request format:', error.errors);
        return NextResponse.json(
          { error: '잘못된 요청 형식입니다.', details: error.errors },
          { status: 400 }
        );
      }
      
      // Sentry에 에러 보고 (선택적)
      if (process.env.SENTRY_DSN && !(error instanceof z.ZodError)) {
        const Sentry = await import('@sentry/nextjs');
        Sentry.captureException(error, {
          tags: {
            service: 'payment',
            action: 'create-checkout'
          },
          user: {
            id: req.userId || 'unknown'
          }
        });
      }
      
      return NextResponse.json(
        { error: '결제 처리 중 오류가 발생했습니다.' },
        { status: 500 }
      );
    }
  });
}