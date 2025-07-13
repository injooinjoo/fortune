import logger from '../utils/logger';
import { supabaseAdmin } from '../config/supabase';
import { calculateZodiacSign, calculateChineseZodiac } from '../utils/zodiac-utils';

export interface UserProfile {
  id: string;
  user_id: string;
  email: string;
  name: string;
  birth_date: string;
  birth_time?: string;
  gender?: string;
  mbti?: string;
  blood_type?: string;
  job?: string;
  location?: string;
  marital_status?: string;
  interests?: string[];
  zodiac_sign?: string;
  chinese_zodiac?: string;
  created_at: string;
  updated_at: string;
  subscription_status?: any;
}

export interface TokenStats {
  totalPurchased: number;
  totalUsed: number;
  totalBonus: number;
}

export interface TokenHistoryQuery {
  page: number;
  limit: number;
  startDate?: string;
  endDate?: string;
  type?: 'usage' | 'purchase' | 'all';
}

export interface TokenHistoryResult {
  transactions: any[];
  page: number;
  limit: number;
  total: number;
  totalPages: number;
  summary: {
    totalUsed: number;
    totalPurchased: number;
    totalBonus: number;
    mostUsedFortuneType?: string;
  };
}

export interface UserSettings {
  notification_enabled: boolean;
  marketing_agreed: boolean;
  push_enabled: boolean;
  email_notifications: boolean;
  daily_fortune_reminder: boolean;
  language: string;
  theme: string;
}

export class UserService {
  private static instance: UserService;

  private constructor() {
    logger.info('UserService initialized');
  }

  public static getInstance(): UserService {
    if (!UserService.instance) {
      UserService.instance = new UserService();
    }
    return UserService.instance;
  }

  // 프로필 조회
  async getProfile(userId: string): Promise<UserProfile | null> {
    try {
      const { data, error } = await supabaseAdmin
        .from('user_profiles')
        .select(`
          *,
          subscription_status (
            plan_type,
            status,
            monthly_token_quota,
            tokens_used_this_period
          )
        `)
        .eq('user_id', userId)
        .single();

      if (error) {
        if (error.code === 'PGRST116') { // No rows found
          return null;
        }
        throw error;
      }

      return data;
    } catch (error) {
      logger.error('[UserService] Failed to get profile:', error);
      throw error;
    }
  }

  // 프로필 업데이트
  async updateProfile(userId: string, email: string, profileData: any): Promise<UserProfile> {
    try {
      // 운세 관련 필드 자동 계산
      const zodiacSign = calculateZodiacSign(profileData.birth_date);
      const chineseZodiac = calculateChineseZodiac(profileData.birth_date);

      const profileWithZodiac = {
        ...profileData,
        user_id: userId,
        email: email,
        zodiac_sign: zodiacSign,
        chinese_zodiac: chineseZodiac,
        updated_at: new Date().toISOString(),
      };

      const { data, error } = await supabaseAdmin
        .from('user_profiles')
        .upsert(profileWithZodiac, {
          onConflict: 'user_id',
        })
        .select()
        .single();

      if (error) throw error;

      // 온보딩 완료 상태 업데이트
      if (profileData.name && profileData.birth_date) {
        await this.updateOnboardingStatus(userId, true);
      }

      return data;
    } catch (error) {
      logger.error('[UserService] Failed to update profile:', error);
      throw error;
    }
  }

  // 토큰 통계 조회
  async getTokenStats(userId: string): Promise<TokenStats> {
    try {
      const { data, error } = await supabaseAdmin
        .from('user_tokens')
        .select('total_purchased, total_used, total_bonus')
        .eq('user_id', userId)
        .single();

      if (error && error.code !== 'PGRST116') {
        throw error;
      }

      return {
        totalPurchased: data?.total_purchased || 0,
        totalUsed: data?.total_used || 0,
        totalBonus: data?.total_bonus || 0,
      };
    } catch (error) {
      logger.error('[UserService] Failed to get token stats:', error);
      return {
        totalPurchased: 0,
        totalUsed: 0,
        totalBonus: 0,
      };
    }
  }

  // 토큰 사용 내역 조회
  async getTokenHistory(userId: string, query: TokenHistoryQuery): Promise<TokenHistoryResult> {
    try {
      const { page, limit, startDate, endDate, type } = query;
      const offset = (page - 1) * limit;

      // Build query
      let queryBuilder = supabaseAdmin
        .from('token_transactions')
        .select('*', { count: 'exact' })
        .eq('user_id', userId);

      // Date range filter
      if (startDate) {
        queryBuilder = queryBuilder.gte('created_at', startDate);
      }
      if (endDate) {
        queryBuilder = queryBuilder.lte('created_at', endDate);
      }

      // Transaction type filter
      if (type && type !== 'all') {
        queryBuilder = queryBuilder.eq('transaction_type', type);
      }

      // Execute query with pagination
      const { data, error, count } = await queryBuilder
        .order('created_at', { ascending: false })
        .range(offset, offset + limit - 1);

      if (error) throw error;

      // Calculate summary
      const summary = await this.calculateTokenSummary(userId, startDate, endDate);

      // Format transactions with running balance
      let runningBalance = 0;
      const formattedTransactions = (data || []).map((transaction, index) => {
        if (index === 0) {
          runningBalance = transaction.balance_after;
        }
        const formatted = {
          ...transaction,
          formatted_date: new Date(transaction.created_at).toLocaleString('ko-KR'),
          running_balance: runningBalance,
        };
        runningBalance -= transaction.amount;
        return formatted;
      });

      return {
        transactions: formattedTransactions,
        page,
        limit,
        total: count || 0,
        totalPages: Math.ceil((count || 0) / limit),
        summary,
      };
    } catch (error) {
      logger.error('[UserService] Failed to get token history:', error);
      throw error;
    }
  }

  // 토큰 요약 계산
  private async calculateTokenSummary(userId: string, startDate?: string, endDate?: string): Promise<any> {
    try {
      // Get aggregated data
      let queryBuilder = supabaseAdmin
        .from('token_transactions')
        .select('transaction_type, amount, fortune_type')
        .eq('user_id', userId);

      if (startDate) {
        queryBuilder = queryBuilder.gte('created_at', startDate);
      }
      if (endDate) {
        queryBuilder = queryBuilder.lte('created_at', endDate);
      }

      const { data, error } = await queryBuilder;
      if (error) throw error;

      // Calculate totals
      const summary = {
        totalUsed: 0,
        totalPurchased: 0,
        totalBonus: 0,
        fortuneTypeUsage: {} as Record<string, number>,
      };

      (data || []).forEach(transaction => {
        const amount = Math.abs(transaction.amount);
        
        if (transaction.transaction_type === 'usage') {
          summary.totalUsed += amount;
          if (transaction.fortune_type) {
            summary.fortuneTypeUsage[transaction.fortune_type] = 
              (summary.fortuneTypeUsage[transaction.fortune_type] || 0) + 1;
          }
        } else if (transaction.transaction_type === 'purchase') {
          summary.totalPurchased += amount;
        } else if (transaction.transaction_type === 'bonus') {
          summary.totalBonus += amount;
        }
      });

      // Find most used fortune type
      const mostUsedEntry = Object.entries(summary.fortuneTypeUsage)
        .sort(([, a], [, b]) => b - a)[0];

      return {
        ...summary,
        mostUsedFortuneType: mostUsedEntry?.[0],
      };
    } catch (error) {
      logger.error('[UserService] Failed to calculate token summary:', error);
      return {
        totalUsed: 0,
        totalPurchased: 0,
        totalBonus: 0,
      };
    }
  }

  // 사용자 설정 조회
  async getSettings(userId: string): Promise<UserSettings> {
    try {
      const { data, error } = await supabaseAdmin
        .from('user_settings')
        .select('*')
        .eq('user_id', userId)
        .single();

      if (error && error.code !== 'PGRST116') {
        throw error;
      }

      // Return default settings if not found
      return data || {
        notification_enabled: true,
        marketing_agreed: false,
        push_enabled: true,
        email_notifications: true,
        daily_fortune_reminder: false,
        language: 'ko',
        theme: 'light',
      };
    } catch (error) {
      logger.error('[UserService] Failed to get settings:', error);
      throw error;
    }
  }

  // 사용자 설정 업데이트
  async updateSettings(userId: string, settings: Partial<UserSettings>): Promise<UserSettings> {
    try {
      const { data, error } = await supabaseAdmin
        .from('user_settings')
        .upsert({
          user_id: userId,
          ...settings,
          updated_at: new Date().toISOString(),
        }, {
          onConflict: 'user_id',
        })
        .select()
        .single();

      if (error) throw error;

      return data;
    } catch (error) {
      logger.error('[UserService] Failed to update settings:', error);
      throw error;
    }
  }

  // 온보딩 상태 업데이트
  private async updateOnboardingStatus(userId: string, completed: boolean): Promise<void> {
    try {
      const { error } = await supabaseAdmin
        .from('user_onboarding')
        .upsert({
          user_id: userId,
          completed,
          completed_at: completed ? new Date().toISOString() : null,
          updated_at: new Date().toISOString(),
        }, {
          onConflict: 'user_id',
        });

      if (error) throw error;
    } catch (error) {
      logger.error('[UserService] Failed to update onboarding status:', error);
    }
  }

  // 사용자 삭제
  async deleteUser(userId: string): Promise<boolean> {
    try {
      // Soft delete - mark as deleted instead of hard delete
      const { error } = await supabaseAdmin
        .from('user_profiles')
        .update({
          deleted_at: new Date().toISOString(),
          updated_at: new Date().toISOString(),
        })
        .eq('user_id', userId);

      if (error) throw error;

      // Also mark auth user as deleted
      const { error: authError } = await supabaseAdmin.auth.admin.deleteUser(userId);
      if (authError) throw authError;

      return true;
    } catch (error) {
      logger.error('[UserService] Failed to delete user:', error);
      return false;
    }
  }

  // 사용자 초기화 (신규 가입 시)
  async initializeNewUser(userId: string, email: string): Promise<void> {
    try {
      // Initialize token balance
      await supabaseAdmin
        .from('user_tokens')
        .insert({
          user_id: userId,
          balance: 10, // Initial free tokens
          total_earned: 10,
          total_purchased: 0,
          total_used: 0,
          total_bonus: 10,
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString(),
        });

      // Record initial bonus transaction
      await supabaseAdmin
        .from('token_transactions')
        .insert({
          user_id: userId,
          transaction_type: 'bonus',
          amount: 10,
          balance_after: 10,
          description: '신규 가입 보너스',
          created_at: new Date().toISOString(),
        });

      logger.info(`Initialized new user: ${userId}`);
    } catch (error) {
      logger.error('[UserService] Failed to initialize new user:', error);
    }
  }
}