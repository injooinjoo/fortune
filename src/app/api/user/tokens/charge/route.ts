import { NextRequest } from 'next/server';
import { withAuth, AuthenticatedRequest } from '@/middleware/auth';
import { createSuccessResponse, createErrorResponse } from '@/lib/api-response-utils';
import { logger } from '@/lib/logger';
import { supabase } from '@/lib/supabase';

export async function POST(request: NextRequest) {
  return withAuth(request, async (req: AuthenticatedRequest) => {
    try {
      const body = await req.json();
      const { userId, tokenAmount, paymentId } = body;
      
      if (!tokenAmount || tokenAmount <= 0) {
        return createErrorResponse('Invalid token amount', undefined, undefined, 400);
      }
      
      // Get current balance
      const { data: userTokens } = await supabase
        .from('user_tokens')
        .select('balance, total_purchased')
        .eq('user_id', req.userId!)
        .single();
      
      const currentBalance = userTokens?.balance || 0;
      const newBalance = currentBalance + tokenAmount;
      const totalPurchased = (userTokens?.total_purchased || 0) + tokenAmount;
      
      // Update token balance
      const { error: updateError } = await supabase
        .from('user_tokens')
        .upsert({
          user_id: req.userId!,
          balance: newBalance,
          total_purchased: totalPurchased,
          updated_at: new Date().toISOString()
        });
      
      if (updateError) {
        throw updateError;
      }
      
      // Record token transaction
      const { error: transactionError } = await supabase
        .from('token_transactions')
        .insert({
          user_id: req.userId!,
          transaction_type: 'purchase',
          amount: tokenAmount,
          balance_after: newBalance,
          description: `${tokenAmount} 토큰 구매`,
          reference_id: paymentId,
          created_at: new Date().toISOString()
        });
      
      if (transactionError) {
        logger.error('Failed to record token transaction', transactionError);
      }
      
      logger.info('Tokens charged successfully', {
        userId: req.userId,
        tokenAmount,
        newBalance,
        paymentId
      });
      
      return createSuccessResponse({
        success: true,
        balance: newBalance,
        tokenAmount,
        totalPurchased
      });
      
    } catch (error) {
      logger.error('Failed to charge tokens', error);
      return createErrorResponse('Failed to charge tokens', undefined, undefined, 500);
    }
  });
}