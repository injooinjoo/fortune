import { NextRequest, NextResponse } from 'next/server';
import { withAuth } from '@/middleware/auth';
import Stripe from 'stripe';
import { z } from 'zod';
import { logger } from '@/lib/logger';
import { supabase } from '@/lib/supabase';

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!, {
  apiVersion: '2024-12-18.acacia',
});

// 요청 검증 스키마
const ConfirmSubscriptionSchema = z.object({
  subscriptionId: z.string()
});

export async function POST(request: NextRequest) {
  return withAuth(request, async (req) => {
    try {
      const body = await req.json();
      const validatedData = ConfirmSubscriptionSchema.parse(body);
      
      const userId = req.userId!;
      
      logger.info('[Payment] Confirming subscription', {
        userId,
        subscriptionId: validatedData.subscriptionId
      });
      
      // Stripe에서 구독 상태 확인
      const subscription = await stripe.subscriptions.retrieve(
        validatedData.subscriptionId,
        {
          expand: ['latest_invoice.payment_intent']
        }
      );
      
      // 구독이 활성 상태인지 확인
      if (subscription.status === 'active' || subscription.status === 'trialing') {
        // DB 업데이트
        const { error: updateError } = await supabase
          .from('subscriptions')
          .update({
            status: subscription.status,
            current_period_start: new Date(subscription.current_period_start * 1000).toISOString(),
            current_period_end: new Date(subscription.current_period_end * 1000).toISOString(),
            updated_at: new Date().toISOString()
          })
          .eq('subscription_id', validatedData.subscriptionId)
          .eq('user_id', userId);
        
        if (updateError) {
          logger.error('[Payment] Failed to update subscription in DB', updateError);
        }
        
        // 사용자에게 무제한 토큰 부여
        const { error: tokenError } = await supabase
          .from('user_tokens')
          .update({
            has_unlimited_access: true,
            unlimited_until: new Date(subscription.current_period_end * 1000).toISOString(),
            updated_at: new Date().toISOString()
          })
          .eq('user_id', userId);
        
        if (tokenError) {
          logger.error('[Payment] Failed to grant unlimited access', tokenError);
        }
        
        logger.info('[Payment] Subscription confirmed successfully', {
          subscriptionId: subscription.id,
          status: subscription.status
        });
        
        return NextResponse.json({
          success: true,
          subscription: {
            id: subscription.id,
            status: subscription.status,
            currentPeriodEnd: subscription.current_period_end,
            cancelAtPeriodEnd: subscription.cancel_at_period_end
          }
        });
      } else {
        // 구독이 아직 활성화되지 않음
        logger.warn('[Payment] Subscription not active', {
          subscriptionId: subscription.id,
          status: subscription.status
        });
        
        return NextResponse.json(
          { 
            error: '구독이 아직 활성화되지 않았습니다.',
            status: subscription.status
          },
          { status: 400 }
        );
      }
      
    } catch (error) {
      logger.error('[Payment] Error confirming subscription:', error);
      
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
        action: 'confirm-subscription',
        userId: req.userId || 'unknown'
      });
      
      return NextResponse.json(
        { error: '구독 확인 중 오류가 발생했습니다.' },
        { status: 500 }
      );
    }
  });
}