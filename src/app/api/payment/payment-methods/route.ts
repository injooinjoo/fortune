import { NextRequest, NextResponse } from 'next/server';
import { withAuth } from '@/middleware/auth';
import Stripe from 'stripe';
import { z } from 'zod';
import { logger } from '@/lib/logger';

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!, {
  apiVersion: '2024-12-18.acacia',
});

// 쿼리 파라미터 스키마
const QuerySchema = z.object({
  customerId: z.string()
});

export async function GET(request: NextRequest) {
  return withAuth(request, async (req) => {
    try {
      const { searchParams } = new URL(request.url);
      const validatedQuery = QuerySchema.parse({
        customerId: searchParams.get('customerId')
      });
      
      const userId = req.userId!;
      
      logger.info('[Payment] Fetching payment methods', {
        userId,
        customerId: validatedQuery.customerId
      });
      
      // Stripe에서 저장된 결제 수단 조회
      const paymentMethods = await stripe.paymentMethods.list({
        customer: validatedQuery.customerId,
        type: 'card',
        limit: 10
      });
      
      // 민감한 정보 필터링
      const sanitizedMethods = paymentMethods.data.map(method => ({
        id: method.id,
        type: method.type,
        card: method.card ? {
          brand: method.card.brand,
          last4: method.card.last4,
          expMonth: method.card.exp_month,
          expYear: method.card.exp_year,
          funding: method.card.funding
        } : null,
        created: method.created,
        livemode: method.livemode
      }));
      
      logger.info('[Payment] Payment methods retrieved', {
        count: sanitizedMethods.length
      });
      
      return NextResponse.json({
        success: true,
        paymentMethods: sanitizedMethods
      });
      
    } catch (error) {
      logger.error('[Payment] Error fetching payment methods:', error);
      
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
        action: 'get-payment-methods',
        userId: req.userId || 'unknown'
      });
      
      return NextResponse.json(
        { error: '결제 수단 조회 중 오류가 발생했습니다.' },
        { status: 500 }
      );
    }
  });
}

// 결제 수단 삭제
export async function DELETE(request: NextRequest) {
  return withAuth(request, async (req) => {
    try {
      const body = await req.json();
      const { paymentMethodId } = z.object({
        paymentMethodId: z.string()
      }).parse(body);
      
      const userId = req.userId!;
      
      logger.info('[Payment] Detaching payment method', {
        userId,
        paymentMethodId
      });
      
      // Stripe에서 결제 수단 분리
      const paymentMethod = await stripe.paymentMethods.detach(paymentMethodId);
      
      logger.info('[Payment] Payment method detached successfully', {
        paymentMethodId: paymentMethod.id
      });
      
      return NextResponse.json({
        success: true,
        message: '결제 수단이 삭제되었습니다.'
      });
      
    } catch (error) {
      logger.error('[Payment] Error detaching payment method:', error);
      
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
        action: 'delete-payment-method',
        userId: req.userId || 'unknown'
      });
      
      return NextResponse.json(
        { error: '결제 수단 삭제 중 오류가 발생했습니다.' },
        { status: 500 }
      );
    }
  });
}