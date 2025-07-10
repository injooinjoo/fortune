import { logger } from '@/lib/logger';
import { createClient, SupabaseClient } from '@supabase/supabase-js';
import { FortuneCategory } from '../types/fortune-system';

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

export class TokenService {
  private static instance: TokenService;
  private supabase: SupabaseClient | null = null;

  private constructor() {}

  public static getInstance(): TokenService {
    if (!TokenService.instance) {
      TokenService.instance = new TokenService();
    }
    return TokenService.instance;
  }

  private getSupabase(): SupabaseClient {
    if (!this.supabase) {
      // Only initialize when needed (server-side only)
      if (!process.env.NEXT_PUBLIC_SUPABASE_URL || !process.env.SUPABASE_SERVICE_ROLE_KEY) {
        throw new Error('Supabase configuration missing');
      }
      this.supabase = createClient(
        process.env.NEXT_PUBLIC_SUPABASE_URL,
        process.env.SUPABASE_SERVICE_ROLE_KEY
      );
    }
    return this.supabase;
  }

  /**
   * 사용자의 토큰 잔액 확인
   */
  async getTokenBalance(userId: string): Promise<TokenBalance> {
    try {
      // 1. 구독 상태 확인
      const { data: subscription } = await this.getSupabase()
        .from('subscription_status')
        .select('plan_type, status, monthly_token_quota, tokens_used_this_period')
        .eq('user_id', userId)
        .eq('status', 'active')
        .single();

      // 프리미엄/엔터프라이즈 구독자는 무제한
      if (subscription && (subscription.plan_type === 'premium' || subscription.plan_type === 'enterprise')) {
        return {
          balance: 999999, // UI 표시용
          isUnlimited: true,
          subscriptionPlan: subscription.plan_type
        };
      }

      // 2. 토큰 잔액 확인
      const { data: userTokens } = await this.getSupabase()
        .from('user_tokens')
        .select('balance')
        .eq('user_id', userId)
        .single();

      const balance = userTokens?.balance || 0;

      // 베이직 구독자는 월간 할당량 + 추가 구매 토큰
      if (subscription && subscription.plan_type === 'basic') {
        const remainingMonthlyTokens = subscription.monthly_token_quota - subscription.tokens_used_this_period;
        return {
          balance: balance + Math.max(0, remainingMonthlyTokens),
          isUnlimited: false,
          subscriptionPlan: subscription.plan_type
        };
      }

      // 무료 사용자는 구매한 토큰만
      return {
        balance: balance,
        isUnlimited: false,
        subscriptionPlan: 'free'
      };

    } catch (error) {
      logger.error('토큰 잔액 조회 실패:', error);
      return {
        balance: 0,
        isUnlimited: false,
        subscriptionPlan: 'free'
      };
    }
  }

  /**
   * 토큰 차감
   */
  async deductTokens(
    userId: string, 
    fortuneCategory: FortuneCategory,
    amount?: number
  ): Promise<TokenDeductionResult> {
    try {
      // 토큰 비용 결정
      const tokenCost = amount || this.getTokenCostForCategory(fortuneCategory);
      
      // 현재 잔액 확인
      const balance = await this.getTokenBalance(userId);
      
      // 무제한 사용자는 차감 없이 통과
      if (balance.isUnlimited) {
        // 사용 기록만 남김
        await this.recordTokenUsage(userId, fortuneCategory, 0);
        return {
          success: true,
          newBalance: balance.balance
        };
      }

      // 잔액 부족 체크
      if (balance.balance < tokenCost) {
        return {
          success: false,
          newBalance: balance.balance,
          error: `토큰이 부족합니다. 필요: ${tokenCost}, 보유: ${balance.balance}`
        };
      }

      // 구독자의 경우 월간 할당량에서 먼저 차감
      if (balance.subscriptionPlan === 'basic') {
        const { data: subscription } = await this.getSupabase()
          .from('subscription_status')
          .select('monthly_token_quota, tokens_used_this_period')
          .eq('user_id', userId)
          .eq('status', 'active')
          .single();

        if (subscription) {
          const remainingMonthly = subscription.monthly_token_quota - subscription.tokens_used_this_period;
          
          if (remainingMonthly >= tokenCost) {
            // 월간 할당량에서 차감
            await this.getSupabase()
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

      // 일반 토큰에서 차감
      const { data: userTokens } = await this.getSupabase()
        .from('user_tokens')
        .select('balance, total_used')
        .eq('user_id', userId)
        .single();

      const currentBalance = userTokens?.balance || 0;
      const newBalance = currentBalance - tokenCost;

      // 토큰 차감
      const { error } = await this.getSupabase()
        .from('user_tokens')
        .update({
          balance: newBalance,
          total_used: (userTokens?.total_used || 0) + tokenCost,
          updated_at: new Date().toISOString()
        })
        .eq('user_id', userId);

      if (error) throw error;

      // 토큰 거래 기록
      await this.getSupabase().from('token_transactions').insert({
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
      logger.error('토큰 차감 실패:', error);
      return {
        success: false,
        newBalance: 0,
        error: '토큰 차감 중 오류가 발생했습니다.'
      };
    }
  }

  /**
   * 토큰 사용 기록
   */
  private async recordTokenUsage(
    userId: string,
    fortuneCategory: FortuneCategory,
    tokenCost: number
  ): Promise<void> {
    try {
      // token_usage 테이블에 기록 (분석용)
      await this.getSupabase().from('token_usage').insert({
        user_id: userId,
        package_name: fortuneCategory,
        prompt_tokens: 0, // AI 서비스에서 채워짐
        completion_tokens: 0, // AI 서비스에서 채워짐
        total_tokens: tokenCost,
        cost: tokenCost * 0.001, // 예시 비용 계산
        duration: 0, // 실제 처리 시간으로 업데이트 필요
        model: 'gpt-4',
        created_at: new Date().toISOString()
      });
    } catch (error) {
      logger.error('토큰 사용 기록 실패:', error);
      // 기록 실패는 치명적이지 않으므로 계속 진행
    }
  }

  /**
   * 운세 카테고리별 토큰 비용
   */
  private getTokenCostForCategory(fortuneCategory: FortuneCategory): number {
    const tokenCosts: Partial<Record<FortuneCategory, number>> = {
      // 간단한 운세 (1 토큰)
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
      
      // 중간 복잡도 운세 (2 토큰)
      'love': 2,
      'career': 2,
      'wealth': 2,
      'health': 2,
      'compatibility': 2,
      'tarot': 2,
      'dream-interpretation': 2,
      'biorhythm': 2,
      'mbti': 2,
      
      // 복잡한 운세 (3 토큰)
      'saju': 3,
      'traditional-saju': 3,
      'saju-psychology': 3,
      'tojeong': 3,
      'past-life': 3,
      'destiny': 3,
      'marriage': 3,
      'couple-match': 3,
      'chemistry': 3,
      
      // 프리미엄 운세 (5 토큰)
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
   * 토큰 환불 (관리자용)
   */
  async refundTokens(
    userId: string,
    amount: number,
    reason: string
  ): Promise<boolean> {
    try {
      const { data: userTokens } = await this.getSupabase()
        .from('user_tokens')
        .select('balance')
        .eq('user_id', userId)
        .single();

      const currentBalance = userTokens?.balance || 0;
      const newBalance = currentBalance + amount;

      await this.getSupabase()
        .from('user_tokens')
        .update({
          balance: newBalance,
          updated_at: new Date().toISOString()
        })
        .eq('user_id', userId);

      await this.getSupabase().from('token_transactions').insert({
        user_id: userId,
        transaction_type: 'refund',
        amount: amount,
        balance_after: newBalance,
        description: `환불: ${reason}`,
        created_at: new Date().toISOString()
      });

      return true;
    } catch (error) {
      logger.error('토큰 환불 실패:', error);
      return false;
    }
  }
}

export const tokenService = TokenService.getInstance();