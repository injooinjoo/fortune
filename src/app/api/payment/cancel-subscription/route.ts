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
const CancelSubscriptionSchema = z.object({
  subscriptionId: z.string(),
  immediately: z.boolean().default(false) // true면 즉시 취소, false면 기간 만료 시 취소
});

export async function POST(request: NextRequest) {
  return withAuth(request, async (req) => {
    try {
      const body = await req.json();
      const validatedData = CancelSubscriptionSchema.parse(body);
      
      const userId = req.userId!;
      
      logger.info('[Payment] Cancelling subscription', {
        userId,
        subscriptionId: validatedData.subscriptionId,
        immediately: validatedData.immediately
      });
      
      // 구독 소유권 확인
      const { data: subscriptionData, error: fetchError } = await supabase
        .from('subscriptions')
        .select('user_id')
        .eq('subscription_id', validatedData.subscriptionId)
        .single();
      
      if (fetchError || !subscriptionData) {
        return NextResponse.json(
          { error: '구독 정보를 찾을 수 없습니다.' },
          { status: 404 }
        );
      }
      
      if (subscriptionData.user_id !== userId) {
        return NextResponse.json(
          { error: '구독 취소 권한이 없습니다.' },
          { status: 403 }
        );
      }
      
      // Stripe에서 구독 취소
      let subscription;
      if (validatedData.immediately) {
        // 즉시 취소
        subscription = await stripe.subscriptions.cancel(validatedData.subscriptionId);
      } else {
        // 기간 만료 시 취소
        subscription = await stripe.subscriptions.update(
          validatedData.subscriptionId,
          { cancel_at_period_end: true }
        );
      }
      
      // DB 업데이트
      const { error: updateError } = await supabase
        .from('subscriptions')
        .update({
          status: subscription.status,
          cancel_at_period_end: subscription.cancel_at_period_end,
          canceled_at: subscription.canceled_at ? new Date(subscription.canceled_at * 1000).toISOString() : null,
          updated_at: new Date().toISOString()
        })
        .eq('subscription_id', validatedData.subscriptionId);
      
      if (updateError) {
        logger.error('[Payment] Failed to update subscription in DB', updateError);
      }
      
      // 즉시 취소인 경우 무제한 액세스 제거
      if (validatedData.immediately) {
        const { error: tokenError } = await supabase
          .from('user_tokens')
          .update({
            has_unlimited_access: false,
            unlimited_until: null,
            updated_at: new Date().toISOString()
          })
          .eq('user_id', userId);
        
        if (tokenError) {
          logger.error('[Payment] Failed to revoke unlimited access', tokenError);
        }
      }
      
      logger.info('[Payment] Subscription cancelled successfully', {
        subscriptionId: subscription.id,
        status: subscription.status,
        cancelAtPeriodEnd: subscription.cancel_at_period_end
      });
      
      return NextResponse.json({
        success: true,
        subscription: {
          id: subscription.id,
          status: subscription.status,
          cancelAtPeriodEnd: subscription.cancel_at_period_end,
          currentPeriodEnd: subscription.current_period_end,
          canceledAt: subscription.canceled_at
        },
        message: validatedData.immediately 
          ? '구독이 즉시 취소되었습니다.' 
          : '구독이 현재 결제 기간 종료 시 취소됩니다.'
      });
      
    } catch (error) {
      logger.error('[Payment] Error cancelling subscription:', error);
      
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
        action: 'cancel-subscription',
        userId: req.userId || 'unknown'
      });
      
      return NextResponse.json(
        { error: '구독 취소 중 오류가 발생했습니다.' },
        { status: 500 }
      );
    }
  });
}