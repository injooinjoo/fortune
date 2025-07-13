import { supabaseAdmin } from '../config/supabase';
import logger from './logger';

export interface TokenUsageReport {
  daily: {
    total: number;
    cost: number;
  };
  monthly: {
    total: number;
    cost: number;
  };
  packages: Array<{
    packageName: string;
    averageTokens: number;
    averageCost: number;
    totalRequests: number;
    savingsPercentage: number;
  }>;
  timeline: Array<{
    date: string;
    total: number;
    cost: number;
  }>;
  topUsers: Array<{
    userId: string;
    name: string;
    email: string;
    totalTokens: number;
    totalCost: number;
    requestCount: number;
  }>;
}

export class TokenMonitor {
  private static instance: TokenMonitor;

  private constructor() {
    logger.info('TokenMonitor initialized');
  }

  public static getInstance(): TokenMonitor {
    if (!TokenMonitor.instance) {
      TokenMonitor.instance = new TokenMonitor();
    }
    return TokenMonitor.instance;
  }

  async getTokenUsageReport(days: number = 7): Promise<TokenUsageReport> {
    try {
      const startDate = new Date();
      startDate.setDate(startDate.getDate() - days);

      // Fetch token usage data
      const { data: usageData, error } = await supabaseAdmin
        .from('token_usage')
        .select(`
          *,
          user_profiles!inner (name, email)
        `)
        .gte('created_at', startDate.toISOString())
        .order('created_at', { ascending: false });

      if (error) throw error;

      // Calculate aggregations
      const daily = this.calculateDailyTotal(usageData || []);
      const monthly = this.calculateMonthlyTotal(usageData || []);
      const packages = this.analyzePackages(usageData || []);
      const timeline = this.generateTimeline(usageData || [], days);
      const topUsers = await this.getTopUsers(usageData || []);

      return {
        daily,
        monthly,
        packages,
        timeline,
        topUsers,
      };

    } catch (error) {
      logger.error('[TokenMonitor] Failed to generate usage report:', error);
      throw error;
    }
  }

  private calculateDailyTotal(data: any[]): { total: number; cost: number } {
    const today = new Date().toISOString().split('T')[0];
    const todayData = data.filter(item => 
      item.created_at.startsWith(today)
    );

    return {
      total: todayData.reduce((sum, item) => sum + (item.total_tokens || 0), 0),
      cost: todayData.reduce((sum, item) => sum + (item.cost || 0), 0),
    };
  }

  private calculateMonthlyTotal(data: any[]): { total: number; cost: number } {
    const startOfMonth = new Date();
    startOfMonth.setDate(1);
    startOfMonth.setHours(0, 0, 0, 0);

    const monthData = data.filter(item => 
      new Date(item.created_at) >= startOfMonth
    );

    return {
      total: monthData.reduce((sum, item) => sum + (item.total_tokens || 0), 0),
      cost: monthData.reduce((sum, item) => sum + (item.cost || 0), 0),
    };
  }

  private analyzePackages(data: any[]): any[] {
    const packageMap = new Map<string, {
      totalTokens: number;
      totalCost: number;
      count: number;
      estimatedSavings: number;
    }>();

    // Group by package name
    data.forEach(item => {
      const packageName = item.package_name || 'unknown';
      if (!packageMap.has(packageName)) {
        packageMap.set(packageName, {
          totalTokens: 0,
          totalCost: 0,
          count: 0,
          estimatedSavings: 0,
        });
      }

      const pkg = packageMap.get(packageName)!;
      pkg.totalTokens += item.total_tokens || 0;
      pkg.totalCost += item.cost || 0;
      pkg.count += 1;

      // Calculate estimated savings based on token efficiency
      const baselineTokenCost = 0.003; // Example baseline cost per token
      const actualCostPerToken = pkg.totalCost / pkg.totalTokens;
      pkg.estimatedSavings += (baselineTokenCost - actualCostPerToken) * pkg.totalTokens;
    });

    // Convert to array and calculate averages
    return Array.from(packageMap.entries()).map(([packageName, stats]) => ({
      packageName,
      averageTokens: Math.round(stats.totalTokens / stats.count),
      averageCost: stats.totalCost / stats.count,
      totalRequests: stats.count,
      savingsPercentage: stats.totalCost > 0 
        ? Math.round((stats.estimatedSavings / stats.totalCost) * 100)
        : 0,
    })).sort((a, b) => b.totalRequests - a.totalRequests);
  }

  private generateTimeline(data: any[], days: number): any[] {
    const timeline = new Map<string, { total: number; cost: number }>();

    // Initialize all days
    for (let i = 0; i < days; i++) {
      const date = new Date();
      date.setDate(date.getDate() - i);
      const dateStr = date.toISOString().split('T')[0];
      timeline.set(dateStr, { total: 0, cost: 0 });
    }

    // Aggregate data by date
    data.forEach(item => {
      const dateStr = item.created_at.split('T')[0];
      if (timeline.has(dateStr)) {
        const day = timeline.get(dateStr)!;
        day.total += item.total_tokens || 0;
        day.cost += item.cost || 0;
      }
    });

    // Convert to array and sort chronologically
    return Array.from(timeline.entries())
      .map(([date, stats]) => ({
        date,
        total: stats.total,
        cost: stats.cost,
      }))
      .sort((a, b) => a.date.localeCompare(b.date));
  }

  private async getTopUsers(data: any[]): Promise<any[]> {
    // Group by user
    const userMap = new Map<string, {
      name: string;
      email: string;
      totalTokens: number;
      totalCost: number;
      requestCount: number;
    }>();

    data.forEach(item => {
      const userId = item.user_id;
      if (!userMap.has(userId)) {
        userMap.set(userId, {
          name: item.user_profiles?.name || 'Unknown',
          email: item.user_profiles?.email || '',
          totalTokens: 0,
          totalCost: 0,
          requestCount: 0,
        });
      }

      const user = userMap.get(userId)!;
      user.totalTokens += item.total_tokens || 0;
      user.totalCost += item.cost || 0;
      user.requestCount += 1;
    });

    // Convert to array and get top 10
    return Array.from(userMap.entries())
      .map(([userId, stats]) => ({
        userId,
        ...stats,
      }))
      .sort((a, b) => b.totalTokens - a.totalTokens)
      .slice(0, 10);
  }

  // Record token usage for a specific request
  async recordUsage(params: {
    userId: string;
    packageName: string;
    promptTokens: number;
    completionTokens: number;
    model: string;
    duration: number;
  }): Promise<void> {
    try {
      const totalTokens = params.promptTokens + params.completionTokens;
      const cost = this.calculateCost(totalTokens, params.model);

      await supabaseAdmin.from('token_usage').insert({
        user_id: params.userId,
        package_name: params.packageName,
        prompt_tokens: params.promptTokens,
        completion_tokens: params.completionTokens,
        total_tokens: totalTokens,
        cost,
        model: params.model,
        duration: params.duration,
        created_at: new Date().toISOString(),
      });

    } catch (error) {
      logger.error('[TokenMonitor] Failed to record usage:', error);
    }
  }

  private calculateCost(tokens: number, model: string): number {
    // Token pricing per model (example values)
    const pricing: Record<string, number> = {
      'gpt-4': 0.003,
      'gpt-4-turbo': 0.002,
      'gpt-3.5-turbo': 0.001,
    };

    const pricePerToken = pricing[model] || 0.002;
    return tokens * pricePerToken;
  }
}