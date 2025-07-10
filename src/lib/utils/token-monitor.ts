import { logger } from '@/lib/logger';
import { supabase } from '@/lib/supabase';
import { FORTUNE_PACKAGES } from '@/config/fortune-packages';
import { TokenUsageRecord } from '@/types/batch-fortune';

export class TokenMonitor {
  private dailyUsage: Map<string, number> = new Map();
  private monthlyUsage: Map<string, number> = new Map();

  async recordUsage(record: TokenUsageRecord): Promise<void> {
    // 메모리 캐시 업데이트
    this.updateLocalCache(record);
    
    // 데이터베이스에 기록
    await this.saveToDatabase(record);
    
    // 임계값 확인
    await this.checkThresholds(record.userId);
  }

  async getUsageStats(userId: string): Promise<{
    daily: { tokens: number; cost: number };
    monthly: { tokens: number; cost: number };
  }> {
    const today = new Date().toISOString().split('T')[0];
    const thisMonth = today.substring(0, 7);
    
    try {
      // 데이터베이스에서 집계
      const { data: dailyData } = await supabase
        .from('token_usage')
        .select('total_tokens, cost')
        .eq('user_id', userId)
        .gte('created_at', today)
        .lt('created_at', today + 'T23:59:59');
      
      const { data: monthlyData } = await supabase
        .from('token_usage')
        .select('total_tokens, cost')
        .eq('user_id', userId)
        .gte('created_at', thisMonth + '-01')
        .lt('created_at', thisMonth + '-31T23:59:59');
      
      return {
        daily: this.aggregateUsage(dailyData || []),
        monthly: this.aggregateUsage(monthlyData || [])
      };
    } catch (error) {
      logger.error('사용량 통계 조회 오류:', error);
      return {
        daily: { tokens: 0, cost: 0 },
        monthly: { tokens: 0, cost: 0 }
      };
    }
  }

  async analyzePackageEfficiency(): Promise<{
    [packageName: string]: {
      avgTokensPerRequest: number;
      avgCostPerRequest: number;
      savingsPercent: number;
    };
  }> {
    const analysis: any = {};
    
    try {
      for (const packageName of Object.keys(FORTUNE_PACKAGES)) {
        const { data } = await supabase
          .from('token_usage')
          .select('*')
          .eq('package_name', packageName)
          .gte('created_at', new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString());
        
        if (data && data.length > 0) {
          const avgTokens = data.reduce((sum, r) => sum + r.total_tokens, 0) / data.length;
          const avgCost = data.reduce((sum, r) => sum + r.cost, 0) / data.length;
          
          // 개별 호출 대비 절감률 계산
          const individualCost = this.calculateIndividualCost(packageName);
          const savingsPercent = ((individualCost - avgCost) / individualCost) * 100;
          
          analysis[packageName] = {
            avgTokensPerRequest: Math.round(avgTokens),
            avgCostPerRequest: avgCost,
            savingsPercent: Math.round(savingsPercent)
          };
        }
      }
      
      return analysis;
    } catch (error) {
      logger.error('패키지 효율성 분석 오류:', error);
      return {};
    }
  }

  async getDetailedUsageReport(userId: string, period: 'daily' | 'weekly' | 'monthly' = 'daily'): Promise<{
    totalTokens: number;
    totalCost: number;
    byPackage: { [packageName: string]: { tokens: number; cost: number; count: number } };
    byModel: { [model: string]: { tokens: number; cost: number } };
    timeline: Array<{ date: string; tokens: number; cost: number }>;
  }> {
    const startDate = this.getStartDate(period);
    
    try {
      const { data } = await supabase
        .from('token_usage')
        .select('*')
        .eq('user_id', userId)
        .gte('created_at', startDate.toISOString())
        .order('created_at', { ascending: true });

      if (!data || data.length === 0) {
        return {
          totalTokens: 0,
          totalCost: 0,
          byPackage: {},
          byModel: {},
          timeline: []
        };
      }

      const byPackage: any = {};
      const byModel: any = {};
      const timeline: any = {};

      let totalTokens = 0;
      let totalCost = 0;

      data.forEach(record => {
        totalTokens += record.total_tokens || 0;
        totalCost += record.cost || 0;

        // 패키지별 집계
        if (!byPackage[record.package_name]) {
          byPackage[record.package_name] = { tokens: 0, cost: 0, count: 0 };
        }
        byPackage[record.package_name].tokens += record.total_tokens || 0;
        byPackage[record.package_name].cost += record.cost || 0;
        byPackage[record.package_name].count += 1;

        // 모델별 집계
        const model = record.model || 'gpt-3.5-turbo';
        if (!byModel[model]) {
          byModel[model] = { tokens: 0, cost: 0 };
        }
        byModel[model].tokens += record.total_tokens || 0;
        byModel[model].cost += record.cost || 0;

        // 타임라인 집계
        const date = record.created_at.split('T')[0];
        if (!timeline[date]) {
          timeline[date] = { tokens: 0, cost: 0 };
        }
        timeline[date].tokens += record.total_tokens || 0;
        timeline[date].cost += record.cost || 0;
      });

      return {
        totalTokens,
        totalCost,
        byPackage,
        byModel,
        timeline: Object.entries(timeline).map(([date, stats]) => ({
          date,
          tokens: (stats as any).tokens,
          cost: (stats as any).cost
        }))
      };
    } catch (error) {
      logger.error('상세 사용량 보고서 생성 오류:', error);
      return {
        totalTokens: 0,
        totalCost: 0,
        byPackage: {},
        byModel: {},
        timeline: []
      };
    }
  }

  private updateLocalCache(record: TokenUsageRecord): void {
    const today = new Date().toISOString().split('T')[0];
    const thisMonth = today.substring(0, 7);
    
    // 일일 사용량 업데이트
    const dailyKey = `${record.userId}:${today}`;
    this.dailyUsage.set(dailyKey, (this.dailyUsage.get(dailyKey) || 0) + record.tokens.total_tokens);
    
    // 월간 사용량 업데이트
    const monthlyKey = `${record.userId}:${thisMonth}`;
    this.monthlyUsage.set(monthlyKey, (this.monthlyUsage.get(monthlyKey) || 0) + record.tokens.total_tokens);
  }

  private async saveToDatabase(record: TokenUsageRecord): Promise<void> {
    try {
      const { error } = await supabase.from('token_usage').insert({
        user_id: record.userId,
        package_name: record.packageName,
        prompt_tokens: record.tokens.prompt_tokens,
        completion_tokens: record.tokens.completion_tokens,
        total_tokens: record.tokens.total_tokens,
        duration_ms: record.duration,
        cost: record.cost,
        created_at: new Date().toISOString()
      });

      if (error) {
        logger.error('토큰 사용량 저장 오류:', error);
      }
    } catch (error) {
      logger.error('데이터베이스 저장 실패:', error);
    }
  }

  private async checkThresholds(userId: string): Promise<void> {
    const stats = await this.getUsageStats(userId);
    
    // 일일 한도 확인 (예: 10,000 토큰)
    if (stats.daily.tokens > 10000) {
      logger.warn(`사용자 ${userId}가 일일 토큰 한도에 근접: ${stats.daily.tokens}`);
      // 알림 발송 로직 추가 가능
    }
    
    // 월간 비용 한도 확인 (예: $10)
    if (stats.monthly.cost > 10) {
      logger.warn(`사용자 ${userId}가 월간 비용 한도 초과: $${stats.monthly.cost}`);
      // 서비스 제한 로직 추가 가능
    }
  }

  private aggregateUsage(data: any[]): { tokens: number; cost: number } {
    return data.reduce((acc: { tokens: number; cost: number }, record: any) => ({
      tokens: acc.tokens + (record.total_tokens || 0),
      cost: acc.cost + (record.cost || 0)
    }), { tokens: 0, cost: 0 });
  }

  private calculateIndividualCost(packageName: string): number {
    const config = FORTUNE_PACKAGES[packageName as keyof typeof FORTUNE_PACKAGES];
    if (!config) return 0;
    
    // 각 운세당 평균 500 토큰 가정
    const totalTokens = config.fortunes.length * 500;
    const costPer1k = 0.0005; // GPT-3.5 기준
    
    return (totalTokens / 1000) * costPer1k;
  }

  private getStartDate(period: 'daily' | 'weekly' | 'monthly'): Date {
    const now = new Date();
    switch (period) {
      case 'daily':
        return new Date(now.setHours(0, 0, 0, 0));
      case 'weekly':
        const weekAgo = new Date(now);
        weekAgo.setDate(weekAgo.getDate() - 7);
        return weekAgo;
      case 'monthly':
        return new Date(now.getFullYear(), now.getMonth(), 1);
    }
  }

  // 비용 절감 예측
  async estimateMonthlySavings(userId: string): Promise<{
    currentMonthlyAvg: number;
    projectedWithBatch: number;
    estimatedSavings: number;
    savingsPercentage: number;
  }> {
    const stats = await this.getUsageStats(userId);
    const efficiency = await this.analyzePackageEfficiency();
    
    // 현재 월평균
    const currentMonthlyAvg = stats.monthly.cost;
    
    // 배치 처리 시 예상 비용 (평균 65% 절감 가정)
    const avgSavingsPercent = Object.values(efficiency)
      .reduce((sum, e) => sum + e.savingsPercent, 0) / Object.keys(efficiency).length || 65;
    
    const projectedWithBatch = currentMonthlyAvg * (1 - avgSavingsPercent / 100);
    const estimatedSavings = currentMonthlyAvg - projectedWithBatch;
    
    return {
      currentMonthlyAvg,
      projectedWithBatch,
      estimatedSavings,
      savingsPercentage: avgSavingsPercent
    };
  }
}