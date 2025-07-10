import { NextRequest, NextResponse } from 'next/server';
import { withAuth } from '@/middleware/auth';
import { createOrUpdateCustomer, PRICE_CONFIG } from '@/lib/payment/stripe-client';
import Stripe from 'stripe';
import { z } from 'zod';
import { logger } from '@/lib/logger';
import { supabase } from '@/lib/supabase';

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!, {
  apiVersion: '2024-12-18.acacia',
});

// 요청 검증 스키마
const CreateSubscriptionSchema = z.object({
  priceId: z.string(),
  customerEmail: z.string().email().optional(),
  metadata: z.record(z.string()).optional()
});

export async function POST(request: NextRequest) {
  return withAuth(request, async (req) => {
    try {
      const body = await req.json();
      const validatedData = CreateSubscriptionSchema.parse(body);
      
      const userId = req.userId!;
      const userEmail = validatedData.customerEmail || req.userEmail!;
      
      logger.info('[Payment] Creating subscription', {
        userId,
        priceId: validatedData.priceId
      });
      
      // Stripe 고객 생성 또는 업데이트
      const customer = await createOrUpdateCustomer(userEmail, userId);
      
      // Setup Intent 생성 (구독을 위한 카드 등록)
      const setupIntent = await stripe.setupIntents.create({
        customer: customer.id,
        payment_method_types: ['card'],
        metadata: {
          ...validatedData.metadata,
          userId,
          priceId: validatedData.priceId
        }
      });
      
      // 구독 정보 미리 생성 (pending 상태)
      const subscription = await stripe.subscriptions.create({
        customer: customer.id,
        items: [{
          price: validatedData.priceId,
        }],
        payment_behavior: 'default_incomplete',
        payment_settings: { save_default_payment_method: 'on_subscription' },
        expand: ['latest_invoice.payment_intent'],
        metadata: {
          ...validatedData.metadata,
          userId
        }
      });
      
      // DB에 구독 정보 저장
      await supabase
        .from('subscriptions')
        .insert({
          subscription_id: subscription.id,
          user_id: userId,
          price_id: validatedData.priceId,
          status: 'pending',
          created_at: new Date().toISOString()
        });
      
      logger.info('[Payment] Subscription created successfully', {
        subscriptionId: subscription.id,
        setupIntentId: setupIntent.id
      });
      
      return NextResponse.json({
        success: true,
        setupIntentClientSecret: setupIntent.client_secret,
        subscriptionId: subscription.id,
        customer: customer.id,
        ephemeralKey: customer.ephemeralKey
      });
      
    } catch (error) {
      logger.error('[Payment] Error creating subscription:', error);
      
      if (error instanceof z.ZodError) {
        return NextResponse.json(
          { error: '잘못된 요청 형식입니다.', details: error.errors },
          { status: 400 }
        );
      }
      
      // 에러 모니터링
      const { captureException } = await import('@/lib/error-monitor');
      captureException(error, {
        service: 'payment',
        action: 'create-subscription',
        userId: req.userId || 'unknown'
      });
      
      return NextResponse.json(
        { error: '구독 생성 중 오류가 발생했습니다.' },
        { status: 500 }
      );
    }
  });
}