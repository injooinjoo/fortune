import { createClient } from '@/lib/supabase/server';

interface TokenUsageParams {
  userId: string;
  fortuneType: string;
  tokensUsed: number;
  model?: string;
  endpoint?: string;
  responseTime?: number;
  error?: string;
  metadata?: Record<string, any>;
}

/**
 * 토큰 사용 기록
 */
export async function trackTokenUsage(params: TokenUsageParams) {
  const supabase = createClient();
  
  try {
    // 토큰 사용 기록 저장
    const { error: usageError } = await supabase
      .from('token_usage')
      .insert({
        user_id: params.userId,
        fortune_type: params.fortuneType,
        tokens_used: params.tokensUsed,
        cost: calculateCost(params.tokensUsed, params.model),
        model: params.model || 'gpt-4',
        endpoint: params.endpoint,
        response_time: params.responseTime,
        error: params.error,
        metadata: params.metadata || {}
      });

    if (usageError) {
      console.error('Failed to track token usage:', usageError);
      return { success: false, error: usageError };
    }

    return { success: true };
  } catch (error) {
    console.error('Token tracking error:', error);
    return { success: false, error };
  }
}

/**
 * 사용자 토큰 잔액 조회
 */
export async function getUserTokenBalance(userId: string) {
  const supabase = createClient();
  
  try {
    const { data, error } = await supabase
      .from('token_balances')
      .select('balance, total_purchased, total_used')
      .eq('user_id', userId)
      .single();

    if (error && error.code !== 'PGRST116') { // PGRST116: Row not found
      console.error('Failed to get token balance:', error);
      return null;
    }

    // 잔액이 없으면 기본값 반환 (신규 사용자)
    if (!data) {
      return {
        balance: 100, // 신규 사용자 기본 토큰
        total_purchased: 100,
        total_used: 0
      };
    }

    return data;
  } catch (error) {
    console.error('Token balance error:', error);
    return null;
  }
}

/**
 * 토큰 잔액 확인 및 차감
 */
export async function deductTokens(userId: string, amount: number) {
  const supabase = createClient();
  
  try {
    // 현재 잔액 확인
    const balance = await getUserTokenBalance(userId);
    if (!balance || balance.balance < amount) {
      return { 
        success: false, 
        error: 'Insufficient tokens',
        balance: balance?.balance || 0 
      };
    }

    // 잔액 차감 (트리거가 자동으로 처리)
    return { 
      success: true, 
      balance: balance.balance - amount 
    };
  } catch (error) {
    console.error('Token deduction error:', error);
    return { success: false, error: 'Failed to deduct tokens' };
  }
}

/**
 * 토큰 비용 계산
 */
function calculateCost(tokens: number, model?: string): number {
  // 모델별 토큰당 비용 (원화)
  const costs: Record<string, number> = {
    'gpt-4': 0.03,      // $0.03 per 1K tokens ≈ 40원
    'gpt-4-turbo': 0.01, // $0.01 per 1K tokens ≈ 13원
    'gpt-3.5-turbo': 0.002, // $0.002 per 1K tokens ≈ 2.6원
    'claude-3': 0.015,   // 예시 비용
  };

  const costPerToken = costs[model || 'gpt-4'] || costs['gpt-4'];
  return Math.round(tokens * costPerToken);
}

/**
 * 토큰 사용 통계 조회
 */
export async function getTokenUsageStats(userId: string, days: number = 30) {
  const supabase = createClient();
  
  const startDate = new Date();
  startDate.setDate(startDate.getDate() - days);

  try {
    const { data, error } = await supabase
      .from('token_usage')
      .select('fortune_type, tokens_used, cost, created_at')
      .eq('user_id', userId)
      .gte('created_at', startDate.toISOString())
      .order('created_at', { ascending: false });

    if (error) {
      console.error('Failed to get usage stats:', error);
      return null;
    }

    // 통계 계산
    const stats = {
      total_tokens: 0,
      total_cost: 0,
      by_fortune: {} as Record<string, { tokens: number; count: number }>,
      daily: {} as Record<string, { tokens: number; cost: number }>,
    };

    data.forEach((record) => {
      stats.total_tokens += record.tokens_used;
      stats.total_cost += record.cost || 0;

      // 운세별 통계
      if (!stats.by_fortune[record.fortune_type]) {
        stats.by_fortune[record.fortune_type] = { tokens: 0, count: 0 };
      }
      stats.by_fortune[record.fortune_type].tokens += record.tokens_used;
      stats.by_fortune[record.fortune_type].count += 1;

      // 일별 통계
      const date = new Date(record.created_at).toISOString().split('T')[0];
      if (!stats.daily[date]) {
        stats.daily[date] = { tokens: 0, cost: 0 };
      }
      stats.daily[date].tokens += record.tokens_used;
      stats.daily[date].cost += record.cost || 0;
    });

    return stats;
  } catch (error) {
    console.error('Usage stats error:', error);
    return null;
  }
}

/**
 * 토큰 구매 기록
 */
export async function recordTokenPurchase(
  userId: string,
  tokens: number,
  amount: number,
  paymentMethod: string,
  paymentId?: string,
  metadata?: Record<string, any>
) {
  const supabase = createClient();
  
  try {
    const { data, error } = await supabase
      .from('token_purchases')
      .insert({
        user_id: userId,
        tokens,
        amount,
        payment_method: paymentMethod,
        payment_id: paymentId,
        status: 'pending',
        metadata: metadata || {}
      })
      .select()
      .single();

    if (error) {
      console.error('Failed to record purchase:', error);
      return { success: false, error };
    }

    return { success: true, purchaseId: data.id };
  } catch (error) {
    console.error('Purchase record error:', error);
    return { success: false, error };
  }
}

/**
 * 토큰 구매 완료 처리
 */
export async function completePurchase(purchaseId: string) {
  const supabase = createClient();
  
  try {
    const { error } = await supabase
      .from('token_purchases')
      .update({ status: 'completed' })
      .eq('id', purchaseId);

    if (error) {
      console.error('Failed to complete purchase:', error);
      return { success: false, error };
    }

    return { success: true };
  } catch (error) {
    console.error('Purchase completion error:', error);
    return { success: false, error };
  }
}