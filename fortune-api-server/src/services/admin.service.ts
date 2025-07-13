import logger from '../utils/logger';
import { supabaseAdmin } from '../config/supabase';

export interface TokenStats {
  summary: {
    totalUsed: number;
    totalRemaining: number;
    totalPurchased: number;
    dailyAverage: number;
    trend: 'up' | 'down' | 'stable';
  };
  usage: {
    daily: Array<{
      date: string;
      tokens: number;
      cost: number;
    }>;
    hourly: Array<{
      hour: number;
      tokens: number;
    }>;
    byType: Array<{
      name: string;
      tokens: number;
      count: number;
    }>;
  };
  users: {
    topUsers: Array<{
      userId: string;
      name: string;
      email: string;
      tokensUsed: number;
      lastActive: string;
    }>;
    activeCount: number;
    premiumCount: number;
  };
  predictions: {
    estimatedDaysRemaining: number;
    projectedMonthlyUsage: number;
    recommendedPurchase: number;
  };
}

export interface UserListQuery {
  page: number;
  limit: number;
  search?: string;
  filter?: string;
}

export interface UserListResult {
  data: any[];
  page: number;
  limit: number;
  total: number;
  totalPages: number;
}

export interface SystemStatus {
  database: {
    connected: boolean;
    latency: number;
  };
  redis: {
    connected: boolean;
    memory: string;
  };
  openai: {
    available: boolean;
    quota: string;
  };
  uptime: number;
  version: string;
}

export class AdminService {
  private static instance: AdminService;

  private constructor() {
    logger.info('AdminService initialized');
  }

  public static getInstance(): AdminService {
    if (!AdminService.instance) {
      AdminService.instance = new AdminService();
    }
    return AdminService.instance;
  }

  // 토큰 통계 조회
  async getTokenStats(range: '7d' | '30d' | '90d'): Promise<TokenStats> {
    try {
      const days = range === '7d' ? 7 : range === '30d' ? 30 : 90;
      const startDate = new Date();
      startDate.setDate(startDate.getDate() - days);

      // Get token usage data
      const { data: usageData, error: usageError } = await supabaseAdmin
        .from('token_usage')
        .select('*')
        .gte('created_at', startDate.toISOString())
        .order('created_at', { ascending: false });

      if (usageError) throw usageError;

      // Get user token data
      const { data: tokenData, error: tokenError } = await supabaseAdmin
        .from('user_tokens')
        .select('balance, total_purchased, total_used');

      if (tokenError) throw tokenError;

      // Calculate summary
      const totalUsed = tokenData?.reduce((sum, user) => sum + (user.total_used || 0), 0) || 0;
      const totalRemaining = tokenData?.reduce((sum, user) => sum + (user.balance || 0), 0) || 0;
      const totalPurchased = tokenData?.reduce((sum, user) => sum + (user.total_purchased || 0), 0) || 0;
      const dailyAverage = totalUsed / days;

      // Calculate daily usage
      const dailyUsage = this.aggregateDailyUsage(usageData || [], days);
      
      // Calculate hourly distribution
      const hourlyDistribution = this.calculateHourlyDistribution(usageData || []);
      
      // Calculate usage by type
      const usageByType = this.aggregateUsageByType(usageData || []);

      // Get top users
      const topUsers = await this.getTopTokenUsers(10);

      // Get user counts
      const { activeCount, premiumCount } = await this.getUserCounts();

      // Calculate predictions
      const predictions = this.calculatePredictions(totalRemaining, dailyAverage);

      return {
        summary: {
          totalUsed,
          totalRemaining,
          totalPurchased,
          dailyAverage: Math.round(dailyAverage),
          trend: this.calculateTrend(dailyUsage),
        },
        usage: {
          daily: dailyUsage,
          hourly: hourlyDistribution,
          byType: usageByType,
        },
        users: {
          topUsers,
          activeCount,
          premiumCount,
        },
        predictions,
      };

    } catch (error) {
      logger.error('[AdminService] Failed to get token stats:', error);
      throw error;
    }
  }

  // 사용자 목록 조회
  async getUserList(query: UserListQuery): Promise<UserListResult> {
    try {
      const { page, limit, search, filter } = query;
      const offset = (page - 1) * limit;

      let queryBuilder = supabaseAdmin
        .from('user_profiles')
        .select(`
          *,
          user_tokens (balance, total_purchased, total_used),
          subscription_status (plan_type, status)
        `, { count: 'exact' });

      // Apply search filter
      if (search) {
        queryBuilder = queryBuilder.or(`name.ilike.%${search}%,email.ilike.%${search}%`);
      }

      // Apply status filter
      if (filter === 'premium') {
        queryBuilder = queryBuilder.eq('subscription_status.status', 'active');
      } else if (filter === 'active') {
        queryBuilder = queryBuilder.gte('last_active', new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString());
      }

      // Execute query with pagination
      const { data, error, count } = await queryBuilder
        .order('created_at', { ascending: false })
        .range(offset, offset + limit - 1);

      if (error) throw error;

      return {
        data: data || [],
        page,
        limit,
        total: count || 0,
        totalPages: Math.ceil((count || 0) / limit),
      };

    } catch (error) {
      logger.error('[AdminService] Failed to get user list:', error);
      throw error;
    }
  }

  // 시스템 상태 조회
  async getSystemStatus(): Promise<SystemStatus> {
    try {
      // Test database connection
      const dbStart = Date.now();
      const { error: dbError } = await supabaseAdmin
        .from('user_profiles')
        .select('count')
        .limit(1);
      const dbLatency = Date.now() - dbStart;

      // Get Redis status (would be implemented in RedisService)
      const redisStatus = {
        connected: true, // Placeholder
        memory: '256MB', // Placeholder
      };

      // Get OpenAI status (would check API availability)
      const openaiStatus = {
        available: true, // Placeholder
        quota: 'Unlimited', // Placeholder
      };

      return {
        database: {
          connected: !dbError,
          latency: dbLatency,
        },
        redis: redisStatus,
        openai: openaiStatus,
        uptime: process.uptime(),
        version: process.env.API_VERSION || '1.0.0',
      };

    } catch (error) {
      logger.error('[AdminService] Failed to get system status:', error);
      throw error;
    }
  }

  // 운세 생성 통계
  async getFortuneGenerationStats(days: number) {
    try {
      const startDate = new Date();
      startDate.setDate(startDate.getDate() - days);

      const { data, error } = await supabaseAdmin
        .from('fortune_history')
        .select('fortune_type, created_at')
        .gte('created_at', startDate.toISOString());

      if (error) throw error;

      // Aggregate by type
      const statsByType = (data || []).reduce((acc, item) => {
        acc[item.fortune_type] = (acc[item.fortune_type] || 0) + 1;
        return acc;
      }, {} as Record<string, number>);

      // Calculate daily counts
      const dailyCounts = this.aggregateDailyCounts(data || [], days);

      return {
        total: data?.length || 0,
        byType: Object.entries(statsByType).map(([type, count]) => ({
          type,
          count,
          percentage: ((count / (data?.length || 1)) * 100).toFixed(1),
        })),
        daily: dailyCounts,
        averagePerDay: Math.round((data?.length || 0) / days),
      };

    } catch (error) {
      logger.error('[AdminService] Failed to get fortune stats:', error);
      throw error;
    }
  }

  // 수익 통계
  async getRevenueStats(startDate?: string, endDate?: string) {
    try {
      let queryBuilder = supabaseAdmin
        .from('purchases')
        .select('amount, currency, created_at, product_id, platform');

      if (startDate) {
        queryBuilder = queryBuilder.gte('created_at', startDate);
      }
      if (endDate) {
        queryBuilder = queryBuilder.lte('created_at', endDate);
      }

      const { data, error } = await queryBuilder;

      if (error) throw error;

      // Calculate total revenue
      const totalRevenue = (data || []).reduce((sum, purchase) => sum + (purchase.amount || 0), 0);

      // Group by platform
      const revenueByPlatform = this.groupByField(data || [], 'platform', 'amount');

      // Group by product
      const revenueByProduct = this.groupByField(data || [], 'product_id', 'amount');

      // Calculate monthly revenue
      const monthlyRevenue = this.calculateMonthlyRevenue(data || []);

      return {
        total: totalRevenue,
        byPlatform: revenueByPlatform,
        byProduct: revenueByProduct,
        monthly: monthlyRevenue,
        transactionCount: data?.length || 0,
        averageTransactionValue: totalRevenue / (data?.length || 1),
      };

    } catch (error) {
      logger.error('[AdminService] Failed to get revenue stats:', error);
      throw error;
    }
  }

  // 사용자 상세 정보
  async getUserDetail(userId: string) {
    try {
      const { data: profile, error: profileError } = await supabaseAdmin
        .from('user_profiles')
        .select(`
          *,
          user_tokens (balance, total_purchased, total_used, total_bonus),
          subscription_status (plan_type, status, start_date, end_date)
        `)
        .eq('user_id', userId)
        .single();

      if (profileError) throw profileError;

      // Get recent fortune history
      const { data: fortunes } = await supabaseAdmin
        .from('fortune_history')
        .select('*')
        .eq('user_id', userId)
        .order('created_at', { ascending: false })
        .limit(10);

      // Get recent transactions
      const { data: transactions } = await supabaseAdmin
        .from('token_transactions')
        .select('*')
        .eq('user_id', userId)
        .order('created_at', { ascending: false })
        .limit(10);

      // Get purchase history
      const { data: purchases } = await supabaseAdmin
        .from('purchases')
        .select('*')
        .eq('user_id', userId)
        .order('created_at', { ascending: false });

      return {
        profile,
        recentFortunes: fortunes || [],
        recentTransactions: transactions || [],
        purchaseHistory: purchases || [],
        stats: {
          totalSpent: (purchases || []).reduce((sum, p) => sum + (p.amount || 0), 0),
          fortuneCount: fortunes?.length || 0,
          memberSince: profile?.created_at,
        },
      };

    } catch (error) {
      logger.error('[AdminService] Failed to get user detail:', error);
      return null;
    }
  }

  // 관리자 액션 로그
  async logAdminAction(action: {
    adminId: string;
    action: string;
    targetUserId?: string;
    details?: any;
  }): Promise<void> {
    try {
      await supabaseAdmin.from('admin_logs').insert({
        admin_id: action.adminId,
        action: action.action,
        target_user_id: action.targetUserId,
        details: action.details,
        created_at: new Date().toISOString(),
      });

      logger.info('[AdminService] Admin action logged:', action);
    } catch (error) {
      logger.error('[AdminService] Failed to log admin action:', error);
    }
  }

  // Helper methods
  private aggregateDailyUsage(data: any[], days: number) {
    const dailyMap = new Map<string, { tokens: number; cost: number }>();
    
    // Initialize all days
    for (let i = 0; i < days; i++) {
      const date = new Date();
      date.setDate(date.getDate() - i);
      const dateStr = date.toISOString().split('T')[0];
      dailyMap.set(dateStr, { tokens: 0, cost: 0 });
    }

    // Aggregate data
    data.forEach(item => {
      const dateStr = item.created_at.split('T')[0];
      if (dailyMap.has(dateStr)) {
        const current = dailyMap.get(dateStr)!;
        current.tokens += item.total_tokens || 0;
        current.cost += item.cost || 0;
      }
    });

    return Array.from(dailyMap.entries())
      .map(([date, data]) => ({
        date,
        tokens: data.tokens,
        cost: data.cost,
      }))
      .reverse();
  }

  private calculateHourlyDistribution(data: any[]) {
    const hourlyMap = new Map<number, number>();
    
    // Initialize all hours
    for (let i = 0; i < 24; i++) {
      hourlyMap.set(i, 0);
    }

    // Count by hour
    data.forEach(item => {
      const hour = new Date(item.created_at).getHours();
      hourlyMap.set(hour, (hourlyMap.get(hour) || 0) + (item.total_tokens || 0));
    });

    return Array.from(hourlyMap.entries()).map(([hour, tokens]) => ({
      hour,
      tokens,
    }));
  }

  private aggregateUsageByType(data: any[]) {
    const typeMap = new Map<string, { tokens: number; count: number }>();

    data.forEach(item => {
      const type = item.package_name || 'unknown';
      if (!typeMap.has(type)) {
        typeMap.set(type, { tokens: 0, count: 0 });
      }
      const current = typeMap.get(type)!;
      current.tokens += item.total_tokens || 0;
      current.count += 1;
    });

    return Array.from(typeMap.entries())
      .map(([name, data]) => ({
        name,
        tokens: data.tokens,
        count: data.count,
      }))
      .sort((a, b) => b.tokens - a.tokens)
      .slice(0, 10);
  }

  private async getTopTokenUsers(limit: number) {
    try {
      const { data, error } = await supabaseAdmin
        .from('user_tokens')
        .select(`
          user_id,
          total_used,
          user_profiles!inner (name, email)
        `)
        .order('total_used', { ascending: false })
        .limit(limit);

      if (error) throw error;

      return (data || []).map(user => ({
        userId: user.user_id,
        name: (user as any).user_profiles?.name || 'Unknown',
        email: (user as any).user_profiles?.email || '',
        tokensUsed: user.total_used || 0,
        lastActive: new Date().toISOString(), // Would need to track this
      }));

    } catch (error) {
      logger.error('[AdminService] Failed to get top users:', error);
      return [];
    }
  }

  private async getUserCounts() {
    try {
      // Active users (logged in within 7 days)
      const activeDate = new Date();
      activeDate.setDate(activeDate.getDate() - 7);

      const { count: activeCount } = await supabaseAdmin
        .from('user_profiles')
        .select('*', { count: 'exact', head: true })
        .gte('updated_at', activeDate.toISOString());

      // Premium users
      const { count: premiumCount } = await supabaseAdmin
        .from('subscription_status')
        .select('*', { count: 'exact', head: true })
        .eq('status', 'active');

      return {
        activeCount: activeCount || 0,
        premiumCount: premiumCount || 0,
      };

    } catch (error) {
      logger.error('[AdminService] Failed to get user counts:', error);
      return { activeCount: 0, premiumCount: 0 };
    }
  }

  private calculatePredictions(remaining: number, dailyAverage: number) {
    const estimatedDaysRemaining = dailyAverage > 0 ? Math.floor(remaining / dailyAverage) : 999;
    const projectedMonthlyUsage = Math.round(dailyAverage * 30);
    const recommendedPurchase = projectedMonthlyUsage > remaining ? projectedMonthlyUsage - remaining : 0;

    return {
      estimatedDaysRemaining,
      projectedMonthlyUsage,
      recommendedPurchase: Math.ceil(recommendedPurchase / 100) * 100, // Round up to nearest 100
    };
  }

  private calculateTrend(dailyUsage: any[]): 'up' | 'down' | 'stable' {
    if (dailyUsage.length < 3) return 'stable';

    const recent = dailyUsage.slice(-3).reduce((sum, d) => sum + d.tokens, 0) / 3;
    const previous = dailyUsage.slice(-6, -3).reduce((sum, d) => sum + d.tokens, 0) / 3;

    if (recent > previous * 1.1) return 'up';
    if (recent < previous * 0.9) return 'down';
    return 'stable';
  }

  private groupByField(data: any[], field: string, valueField: string) {
    const grouped = data.reduce((acc, item) => {
      const key = item[field] || 'unknown';
      acc[key] = (acc[key] || 0) + (item[valueField] || 0);
      return acc;
    }, {} as Record<string, number>);

    return Object.entries(grouped).map(([key, value]) => ({
      name: key,
      value,
    }));
  }

  private calculateMonthlyRevenue(data: any[]) {
    const monthlyMap = new Map<string, number>();

    data.forEach(item => {
      const date = new Date(item.created_at);
      const monthKey = `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}`;
      monthlyMap.set(monthKey, (monthlyMap.get(monthKey) || 0) + (item.amount || 0));
    });

    return Array.from(monthlyMap.entries())
      .map(([month, revenue]) => ({ month, revenue }))
      .sort((a, b) => a.month.localeCompare(b.month));
  }

  private aggregateDailyCounts(data: any[], days: number) {
    const dailyMap = new Map<string, number>();
    
    // Initialize all days
    for (let i = 0; i < days; i++) {
      const date = new Date();
      date.setDate(date.getDate() - i);
      const dateStr = date.toISOString().split('T')[0];
      dailyMap.set(dateStr, 0);
    }

    // Count by day
    data.forEach(item => {
      const dateStr = item.created_at.split('T')[0];
      if (dailyMap.has(dateStr)) {
        dailyMap.set(dateStr, (dailyMap.get(dateStr) || 0) + 1);
      }
    });

    return Array.from(dailyMap.entries())
      .map(([date, count]) => ({ date, count }))
      .reverse();
  }
}