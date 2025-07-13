import logger from '../utils/logger';
import { supabaseAdmin } from '../config/supabase';
import { FortuneCategory } from './fortune.service';

export interface TokenBalance {
  balance: number;
  isUnlimited: boolean;
  subscriptionPlan?: string;
}

export interface TokenDeductionResult {
  success: boolean;
  newBalance: number;
  error?: string;
}

export interface TokenTransaction {
  user_id: string;
  transaction_type: 'usage' | 'purchase' | 'refund' | 'bonus';
  amount: number;
  balance_after: number;
  fortune_type?: string;
  description: string;
  created_at: string;
}

export class TokenService {
  private static instance: TokenService;

  private constructor() {
    logger.info('TokenService initialized');
  }

  public static getInstance(): TokenService {
    if (!TokenService.instance) {
      TokenService.instance = new TokenService();
    }
    return TokenService.instance;
  }

  /**
   * Get user's token balance
   */
  async getTokenBalance(userId: string): Promise<TokenBalance> {
    try {
      // 1. Check subscription status
      const { data: subscription } = await supabaseAdmin
        .from('subscription_status')
        .select('plan_type, status, monthly_token_quota, tokens_used_this_period')
        .eq('user_id', userId)
        .eq('status', 'active')
        .single();

      // Premium/Enterprise subscribers have unlimited tokens
      if (subscription && (subscription.plan_type === 'premium' || subscription.plan_type === 'enterprise')) {
        return {
          balance: 999999, // For UI display
          isUnlimited: true,
          subscriptionPlan: subscription.plan_type
        };
      }

      // 2. Check token balance
      const { data: userTokens } = await supabaseAdmin
        .from('user_tokens')
        .select('balance')
        .eq('user_id', userId)
        .single();

      const balance = userTokens?.balance || 0;

      // Basic subscribers have monthly quota + purchased tokens
      if (subscription && subscription.plan_type === 'basic') {
        const remainingMonthlyTokens = subscription.monthly_token_quota - subscription.tokens_used_this_period;
        return {
          balance: balance + Math.max(0, remainingMonthlyTokens),
          isUnlimited: false,
          subscriptionPlan: subscription.plan_type
        };
      }

      // Free users only have purchased tokens
      return {
        balance: balance,
        isUnlimited: false,
        subscriptionPlan: 'free'
      };

    } catch (error) {
      logger.error('Failed to get token balance:', error);
      return {
        balance: 0,
        isUnlimited: false,
        subscriptionPlan: 'free'
      };
    }
  }

  /**
   * Deduct tokens for fortune generation
   */
  async deductTokens(
    userId: string, 
    fortuneCategory: FortuneCategory,
    amount?: number
  ): Promise<TokenDeductionResult> {
    try {
      // Determine token cost
      const tokenCost = amount || this.getTokenCostForCategory(fortuneCategory);
      
      // Get current balance
      const balance = await this.getTokenBalance(userId);
      
      // Unlimited users pass through without deduction
      if (balance.isUnlimited) {
        // Record usage only
        await this.recordTokenUsage(userId, fortuneCategory, 0);
        return {
          success: true,
          newBalance: balance.balance
        };
      }

      // Check insufficient balance
      if (balance.balance < tokenCost) {
        return {
          success: false,
          newBalance: balance.balance,
          error: `토큰이 부족합니다. 필요: ${tokenCost}, 보유: ${balance.balance}`
        };
      }

      // For basic subscribers, deduct from monthly quota first
      if (balance.subscriptionPlan === 'basic') {
        const { data: subscription } = await supabaseAdmin
          .from('subscription_status')
          .select('monthly_token_quota, tokens_used_this_period')
          .eq('user_id', userId)
          .eq('status', 'active')
          .single();

        if (subscription) {
          const remainingMonthly = subscription.monthly_token_quota - subscription.tokens_used_this_period;
          
          if (remainingMonthly >= tokenCost) {
            // Deduct from monthly quota
            await supabaseAdmin
              .from('subscription_status')
              .update({
                tokens_used_this_period: subscription.tokens_used_this_period + tokenCost,
                updated_at: new Date().toISOString()
              })
              .eq('user_id', userId);

            await this.recordTokenUsage(userId, fortuneCategory, tokenCost);
            
            return {
              success: true,
              newBalance: balance.balance - tokenCost
            };
          }
        }
      }

      // Deduct from regular tokens
      const { data: userTokens } = await supabaseAdmin
        .from('user_tokens')
        .select('balance, total_used')
        .eq('user_id', userId)
        .single();

      const currentBalance = userTokens?.balance || 0;
      const newBalance = currentBalance - tokenCost;

      // Update token balance
      const { error } = await supabaseAdmin
        .from('user_tokens')
        .update({
          balance: newBalance,
          total_used: (userTokens?.total_used || 0) + tokenCost,
          updated_at: new Date().toISOString()
        })
        .eq('user_id', userId);

      if (error) throw error;

      // Record transaction
      await supabaseAdmin.from('token_transactions').insert({
        user_id: userId,
        transaction_type: 'usage',
        amount: -tokenCost,
        balance_after: newBalance,
        fortune_type: fortuneCategory,
        description: `${fortuneCategory} 운세 생성`,
        created_at: new Date().toISOString()
      });

      await this.recordTokenUsage(userId, fortuneCategory, tokenCost);

      return {
        success: true,
        newBalance: newBalance
      };

    } catch (error) {
      logger.error('Failed to deduct tokens:', error);
      return {
        success: false,
        newBalance: 0,
        error: '토큰 차감 중 오류가 발생했습니다.'
      };
    }
  }

  /**
   * Add tokens (for purchases, bonuses, etc.)
   */
  async addTokens(
    userId: string,
    amount: number,
    description: string,
    referenceId?: string
  ): Promise<{ success: boolean; newBalance: number }> {
    try {
      // Get current balance
      const { data: userTokens } = await supabaseAdmin
        .from('user_tokens')
        .select('balance, total_earned')
        .eq('user_id', userId)
        .single();

      const currentBalance = userTokens?.balance || 0;
      const newBalance = currentBalance + amount;

      // Update balance
      const { error } = await supabaseAdmin
        .from('user_tokens')
        .upsert({
          user_id: userId,
          balance: newBalance,
          total_earned: (userTokens?.total_earned || 0) + amount,
          updated_at: new Date().toISOString()
        });

      if (error) throw error;

      // Determine transaction type based on description
      let transactionType: 'purchase' | 'bonus' | 'refund' = 'purchase';
      if (description.includes('보너스') || description.includes('bonus')) {
        transactionType = 'bonus';
      } else if (description.includes('환불') || description.includes('refund')) {
        transactionType = 'refund';
      }

      // Record transaction
      await supabaseAdmin.from('token_transactions').insert({
        user_id: userId,
        transaction_type: transactionType,
        amount: amount,
        balance_after: newBalance,
        description: description,
        reference_id: referenceId,
        created_at: new Date().toISOString()
      });

      logger.info(`Added ${amount} tokens to user ${userId}. New balance: ${newBalance}`);

      return {
        success: true,
        newBalance: newBalance
      };

    } catch (error) {
      logger.error('Failed to add tokens:', error);
      return {
        success: false,
        newBalance: 0
      };
    }
  }

  /**
   * Get token transaction history
   */
  async getTokenHistory(userId: string, limit: number = 50): Promise<TokenTransaction[]> {
    try {
      const { data, error } = await supabaseAdmin
        .from('token_transactions')
        .select('*')
        .eq('user_id', userId)
        .order('created_at', { ascending: false })
        .limit(limit);

      if (error) throw error;

      return data || [];
    } catch (error) {
      logger.error('Failed to get token history:', error);
      return [];
    }
  }

  /**
   * Record token usage for analytics
   */
  private async recordTokenUsage(
    userId: string,
    fortuneCategory: FortuneCategory,
    tokenCost: number
  ): Promise<void> {
    try {
      // Record in token_usage table for analytics
      await supabaseAdmin.from('token_usage').insert({
        user_id: userId,
        package_name: fortuneCategory,
        prompt_tokens: 0, // To be filled by AI service
        completion_tokens: 0, // To be filled by AI service
        total_tokens: tokenCost,
        cost: tokenCost * 0.001, // Example cost calculation
        duration: 0, // To be updated with actual processing time
        model: 'gpt-4',
        created_at: new Date().toISOString()
      });
    } catch (error) {
      logger.error('Failed to record token usage:', error);
      // Non-critical error, continue
    }
  }

  /**
   * Check if user has unlimited tokens
   */
  async hasUnlimitedTokens(userId: string): Promise<boolean> {
    const balance = await this.getTokenBalance(userId);
    return balance.isUnlimited;
  }

  /**
   * Get user's token balance (alias for getTokenBalance)
   */
  async getBalance(userId: string): Promise<number> {
    const balance = await this.getTokenBalance(userId);
    return balance.balance;
  }

  /**
   * Grant daily free tokens to all users
   */
  async grantDailyFreeTokens(): Promise<{ usersGranted: number; totalTokensGranted: number }> {
    try {
      const DAILY_FREE_TOKENS = 3;
      
      // Get all active users
      const { data: users, error: usersError } = await supabaseAdmin
        .from('user_profiles')
        .select('user_id')
        .is('deleted_at', null);

      if (usersError) throw usersError;

      let usersGranted = 0;
      let totalTokensGranted = 0;

      // Grant tokens to each user
      for (const user of users || []) {
        try {
          const result = await this.addTokens(
            user.user_id,
            DAILY_FREE_TOKENS,
            '일일 무료 토큰'
          );

          if (result.success) {
            usersGranted++;
            totalTokensGranted += DAILY_FREE_TOKENS;
          }
        } catch (error) {
          logger.error(`Failed to grant daily tokens to user ${user.user_id}:`, error);
        }
      }

      logger.info(`Granted daily tokens: ${usersGranted} users, ${totalTokensGranted} tokens total`);

      return {
        usersGranted,
        totalTokensGranted
      };

    } catch (error) {
      logger.error('Failed to grant daily free tokens:', error);
      return {
        usersGranted: 0,
        totalTokensGranted: 0
      };
    }
  }

  /**
   * Get token cost for fortune category
   */
  private getTokenCostForCategory(fortuneCategory: FortuneCategory): number {
    const tokenCosts: Partial<Record<FortuneCategory, number>> = {
      // Simple fortunes (1 token)
      'daily': 1,
      'today': 1,
      'tomorrow': 1,
      'lucky-color': 1,
      'lucky-number': 1,
      'lucky-food': 1,
      'lucky-outfit': 1,
      'birthstone': 1,
      'blood-type': 1,
      'zodiac': 1,
      'zodiac-animal': 1,
      
      // Medium complexity (2 tokens)
      'love': 2,
      'career': 2,
      'wealth': 2,
      'compatibility': 2,
      'tarot': 2,
      'dream-interpretation': 2,
      'biorhythm': 2,
      'mbti': 2,
      
      // Complex fortunes (3 tokens)
      'saju': 3,
      'traditional-saju': 3,
      'saju-psychology': 3,
      'tojeong': 3,
      'past-life': 3,
      'destiny': 3,
      'marriage': 3,
      'couple-match': 3,
      'chemistry': 3,
      
      // Premium fortunes (5 tokens)
      'startup': 5,
      'business': 5,
      'lucky-investment': 5,
      'lucky-realestate': 5,
      'celebrity-match': 5,
      'network-report': 5,
      'five-blessings': 5
    };
    
    return tokenCosts[fortuneCategory] || 1;
  }

  /**
   * Check if user has enough tokens
   */
  async hasEnoughTokens(userId: string, fortuneCategory: FortuneCategory): Promise<boolean> {
    const balance = await this.getTokenBalance(userId);
    const cost = this.getTokenCostForCategory(fortuneCategory);
    
    return balance.isUnlimited || balance.balance >= cost;
  }

  /**
   * Initialize user tokens (for new users)
   */
  async initializeUserTokens(userId: string, initialBalance: number = 10): Promise<void> {
    try {
      // Check if user already has token record
      const { data: existing } = await supabaseAdmin
        .from('user_tokens')
        .select('user_id')
        .eq('user_id', userId)
        .single();

      if (!existing) {
        // Create new token record
        await supabaseAdmin
          .from('user_tokens')
          .insert({
            user_id: userId,
            balance: initialBalance,
            total_earned: initialBalance,
            total_used: 0,
            created_at: new Date().toISOString(),
            updated_at: new Date().toISOString()
          });

        // Record initial bonus
        await supabaseAdmin.from('token_transactions').insert({
          user_id: userId,
          transaction_type: 'bonus',
          amount: initialBalance,
          balance_after: initialBalance,
          description: '신규 가입 보너스',
          created_at: new Date().toISOString()
        });

        logger.info(`Initialized tokens for new user ${userId} with ${initialBalance} tokens`);
      }
    } catch (error) {
      logger.error('Failed to initialize user tokens:', error);
    }
  }
}

// Export singleton instance
export const tokenService = TokenService.getInstance();