import { logger } from '@/lib/logger';
import { NextRequest } from 'next/server';
import { withAuth, AuthenticatedRequest } from '@/middleware/auth';
import { createSuccessResponse, createErrorResponse } from '@/lib/api-response-utils';
import { supabase } from '@/lib/supabase';

const DAILY_TOKEN_AMOUNT = 3;

export async function POST(request: NextRequest) {
  return withAuth(request, async (req: AuthenticatedRequest) => {
    try {
      // Check last claim date
      const { data: lastClaim } = await supabase
        .from('daily_token_claims')
        .select('claimed_at')
        .eq('user_id', req.userId!)
        .order('claimed_at', { ascending: false })
        .limit(1)
        .single();
      
      if (lastClaim) {
        const lastClaimDate = new Date(lastClaim.claimed_at);
        const today = new Date();
        today.setHours(0, 0, 0, 0);
        lastClaimDate.setHours(0, 0, 0, 0);
        
        if (lastClaimDate.getTime() === today.getTime()) {
          return createErrorResponse(
            'Already claimed today\'s free tokens',
            'ALREADY_CLAIMED',
            undefined,
            400
          );
        }
      }
      
      // Get current balance
      const { data: userTokens } = await supabase
        .from('user_tokens')
        .select('balance, total_purchased')
        .eq('user_id', req.userId!)
        .single();
      
      const currentBalance = userTokens?.balance || 0;
      const newBalance = currentBalance + DAILY_TOKEN_AMOUNT;
      
      // Update balance
      const { error: updateError } = await supabase
        .from('user_tokens')
        .upsert({
          user_id: req.userId!,
          balance: newBalance,
          total_purchased: (userTokens?.total_purchased || 0) + DAILY_TOKEN_AMOUNT,
          updated_at: new Date().toISOString()
        });
      
      if (updateError) throw updateError;
      
      // Record claim
      const { error: claimError } = await supabase
        .from('daily_token_claims')
        .insert({
          user_id: req.userId!,
          amount: DAILY_TOKEN_AMOUNT,
          claimed_at: new Date().toISOString()
        });
      
      if (claimError) throw claimError;
      
      // Record transaction
      await supabase
        .from('token_transactions')
        .insert({
          user_id: req.userId!,
          transaction_type: 'bonus',
          amount: DAILY_TOKEN_AMOUNT,
          balance_after: newBalance,
          description: '일일 무료 토큰',
          created_at: new Date().toISOString()
        });
      
      return createSuccessResponse({
        balance: {
          totalTokens: newBalance,
          usedTokens: 0,
          remainingTokens: newBalance,
          lastUpdated: new Date().toISOString(),
          hasUnlimitedAccess: false
        }
      });
      
    } catch (error) {
      logger.error('Daily token claim API error:', error);
      return createErrorResponse('Failed to claim daily tokens', undefined, undefined, 500);
    }
  });
}