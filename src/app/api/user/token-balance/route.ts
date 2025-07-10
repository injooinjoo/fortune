import { logger } from '@/lib/logger';
import { NextRequest } from 'next/server';
import { withAuth, AuthenticatedRequest } from '@/middleware/auth';
import { createSuccessResponse, createErrorResponse } from '@/lib/api-response-utils';
import { supabase } from '@/lib/supabase';

export async function GET(request: NextRequest) {
  return withAuth(request, async (req: AuthenticatedRequest) => {
    try {
      // Get current balance
      const { data: balanceData, error } = await supabase
        .from('user_tokens')
        .select('balance, total_purchased, total_used')
        .eq('user_id', req.userId!)
        .single();
      
      if (error && error.code !== 'PGRST116') { // PGRST116: Row not found
        logger.error('토큰 잔액 조회 오류:', error);
        return createErrorResponse('토큰 잔액을 조회할 수 없습니다', undefined, undefined, 500);
      }
      
      // Default values for new users
      const balance = balanceData?.balance ?? 100;
      const totalPurchased = balanceData?.total_purchased ?? 100;
      const totalUsed = balanceData?.total_used ?? 0;
      
      // Check subscription status for unlimited tokens
      const { data: subscription } = await supabase
        .from('subscription_status')
        .select('plan_type, status')
        .eq('user_id', req.userId!)
        .eq('status', 'active')
        .single();
      
      const isUnlimited = subscription && 
        (subscription.plan_type === 'premium' || subscription.plan_type === 'enterprise');
      
      return createSuccessResponse({
        balance,
        totalPurchased,
        totalUsed,
        isUnlimited,
        subscriptionPlan: subscription?.plan_type || 'free'
      });
      
    } catch (error) {
      logger.error('토큰 잔액 API 오류:', error);
      return createErrorResponse('토큰 잔액 조회 중 오류가 발생했습니다', undefined, undefined, 500);
    }
  });
}