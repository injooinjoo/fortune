import { Request, Response, NextFunction } from 'express';
import { ForbiddenError } from '../utils/errors';
import { tokenService } from '../services/token.service';
import logger from '../utils/logger';

export async function tokenGuardMiddleware(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    // Ensure user is authenticated
    if (!req.user) {
      throw new ForbiddenError('Authentication required');
    }

    const userId = req.user.id;
    const endpoint = req.path;

    // Check if user has unlimited tokens (premium subscription)
    const hasUnlimitedTokens = await tokenService.hasUnlimitedTokens(userId);
    if (hasUnlimitedTokens) {
      logger.info(`User ${userId} has unlimited tokens, bypassing token check`);
      return next();
    }

    // Get token cost for this endpoint
    const tokenCost = getTokenCostForEndpoint(endpoint);

    // Check token balance
    const balance = await tokenService.getBalance(userId);
    if (balance < tokenCost) {
      throw new ForbiddenError(`Insufficient tokens. Required: ${tokenCost}, Available: ${balance}`);
    }

    // Deduct tokens
    const fortuneType = endpoint.replace(/^\//, '').replace(/\//g, '-');
    const deductionResult = await tokenService.deductTokens(
      userId, 
      fortuneType as any, // FortuneCategory type
      tokenCost
    );

    if (!deductionResult.success) {
      throw new ForbiddenError('Failed to deduct tokens');
    }

    // Add token info to response headers
    res.setHeader('X-Token-Cost', tokenCost.toString());
    res.setHeader('X-Token-Balance', (balance - tokenCost).toString());

    next();
  } catch (error) {
    next(error);
  }
}

// Helper function to determine token cost based on endpoint
function getTokenCostForEndpoint(endpoint: string): number {
  // Premium fortune types cost more tokens
  const premiumEndpoints = [
    'saju',
    'traditional-saju',
    'tojeong',
    'compatibility',
    'traditional-compatibility',
    'physiognomy',
    'palmistry',
  ];

  const endpointName = endpoint.replace(/^\//, '');
  
  if (premiumEndpoints.includes(endpointName)) {
    return 5; // Premium fortunes cost 5 tokens
  }

  // Special batch endpoints
  if (endpointName === 'generate-batch') {
    return 10; // Batch generation costs 10 tokens
  }

  // Default cost for regular fortunes
  return 3;
}