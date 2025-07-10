import { logger } from '@/lib/logger';
import { NextRequest } from 'next/server';
import { withAuth, AuthenticatedRequest } from '@/middleware/auth';
import { createSuccessResponse, createErrorResponse } from '@/lib/api-response-utils';
import { TokenService } from '@/lib/services/token-service';
import { FortuneCategory } from '@/lib/types/fortune-system';

export async function POST(request: NextRequest) {
  return withAuth(request, async (req: AuthenticatedRequest) => {
    try {
      const body = await req.json();
      const { fortuneType, amount, referenceId } = body;
      
      if (!fortuneType) {
        return createErrorResponse('fortuneType is required', undefined, undefined, 400);
      }
      
      const tokenService = TokenService.getInstance();
      const result = await tokenService.deductTokens(
        req.userId!,
        fortuneType as FortuneCategory,
        amount
      );
      
      if (!result.success) {
        return createErrorResponse(
          result.error || 'Insufficient tokens',
          'INSUFFICIENT_TOKENS',
          undefined,
          400
        );
      }
      
      // Get updated balance
      const balance = await tokenService.getTokenBalance(req.userId!);
      
      return createSuccessResponse({
        balance: {
          totalTokens: balance.balance,
          usedTokens: 0, // TODO: Track this properly
          remainingTokens: balance.balance,
          lastUpdated: new Date().toISOString(),
          hasUnlimitedAccess: balance.isUnlimited
        }
      });
      
    } catch (error) {
      logger.error('Token consume API error:', error);
      return createErrorResponse('Failed to consume tokens', undefined, undefined, 500);
    }
  });
}