import { NextRequest, NextResponse } from 'next/server';
import { withAuth } from '@/middleware/auth';
import { createOrUpdateCustomer, createPaymentIntent } from '@/lib/payment/stripe-client';
import { z } from 'zod';
import { logger } from '@/lib/logger';
import { supabase } from '@/lib/supabase';

// 요청 검증 스키마
const CreatePaymentIntentSchema = z.object({
  amount: z.number().int().positive(),
  currency: z.string().default('krw'),
  metadata: z.record(z.string()).optional()
});

export async function POST(request: NextRequest) {
  return withAuth(request, async (req) => {
    try {
      const body = await req.json();
      const validatedData = CreatePaymentIntentSchema.parse(body);
      
      const userId = req.userId!;
      const userEmail = req.userEmail!;
      
      logger.info('[Payment] Creating payment intent', {
        userId,
        amount: validatedData.amount,
        currency: validatedData.currency
      });
      
      // Stripe 고객 생성 또는 업데이트
      const customer = await createOrUpdateCustomer(userEmail, userId);
      
      // Payment Intent 생성
      const paymentIntent = await createPaymentIntent(
        validatedData.amount,
        customer.id,
        {
          ...validatedData.metadata,
          userId,
          timestamp: new Date().toISOString()
        }
      );
      
      // 결제 시도 기록
      await supabase
        .from('payment_intents')
        .insert({
          payment_intent_id: paymentIntent.id,
          user_id: userId,
          amount: validatedData.amount,
          currency: validatedData.currency,
          status: 'pending',
          metadata: validatedData.metadata,
          created_at: new Date().toISOString()
        });
      
      logger.info('[Payment] Payment intent created successfully', {
        paymentIntentId: paymentIntent.id,
        customerId: customer.id
      });
      
      return NextResponse.json({
        success: true,
        clientSecret: paymentIntent.client_secret,
        paymentIntentId: paymentIntent.id,
        customer: customer.id,
        ephemeralKey: customer.ephemeralKey
      });
      
    } catch (error) {
      logger.error('[Payment] Error creating payment intent:', error);
      
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
        action: 'create-payment-intent',
        userId: req.userId || 'unknown'
      });
      
      return NextResponse.json(
        { error: '결제 준비 중 오류가 발생했습니다.' },
        { status: 500 }
      );
    }
  });
}