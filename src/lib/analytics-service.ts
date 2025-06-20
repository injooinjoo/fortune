import { supabase } from './supabase';
import { FORTUNE_TYPES } from './fortune-data';

interface FortuneUsageStats {
  total_fortunes: number;
  popular_types: Array<{
    fortune_type: string;
    count: number;
    percentage: number;
  }>;
  daily_trend: Array<{
    date: string;
    count: number;
  }>;
  user_activity: {
    total_users: number;
    active_users_today: number;
    return_users: number;
  };
}

interface UserFortuneStats {
  total_fortunes: number;
  favorite_types: string[];
  streak_days: number;
  last_fortune_date: string;
  fortune_distribution: Record<string, number>;
}

export class AnalyticsService {
  /**
   * 전체 운세 사용 통계 조회
   */
  static async getFortuneUsageStats(days: number = 30): Promise<FortuneUsageStats> {
    try {
      const endDate = new Date();
      const startDate = new Date();
      startDate.setDate(endDate.getDate() - days);

      // 전체 운세 수
      const { count: totalFortunes } = await supabase
        .from('daily_fortunes')
        .select('*', { count: 'exact', head: true })
        .gte('created_date', startDate.toISOString().split('T')[0])
        .lte('created_date', endDate.toISOString().split('T')[0]);

      // 인기 운세 타입
      const { data: popularTypes } = await supabase
        .from('daily_fortunes')
        .select('fortune_type')
        .gte('created_date', startDate.toISOString().split('T')[0])
        .lte('created_date', endDate.toISOString().split('T')[0]);

      const typeCount = popularTypes?.reduce((acc, { fortune_type }) => {
        acc[fortune_type] = (acc[fortune_type] || 0) + 1;
        return acc;
      }, {} as Record<string, number>) || {};

      const popularTypesArray = Object.entries(typeCount)
        .sort(([,a], [,b]) => b - a)
        .slice(0, 10)
        .map(([type, count]) => ({
          fortune_type: type,
          count,
          percentage: totalFortunes ? Math.round((count / totalFortunes) * 100) : 0
        }));

      // 일별 트렌드
      const { data: dailyData } = await supabase
        .from('daily_fortunes')
        .select('created_date')
        .gte('created_date', startDate.toISOString().split('T')[0])
        .lte('created_date', endDate.toISOString().split('T')[0]);

      const dailyCount = dailyData?.reduce((acc, { created_date }) => {
        acc[created_date] = (acc[created_date] || 0) + 1;
        return acc;
      }, {} as Record<string, number>) || {};

      const dailyTrend = Object.entries(dailyCount)
        .sort(([a], [b]) => a.localeCompare(b))
        .map(([date, count]) => ({ date, count }));

      // 사용자 활동 통계
      const { data: allUsers } = await supabase
        .from('daily_fortunes')
        .select('user_id')
        .gte('created_date', startDate.toISOString().split('T')[0]);

      const uniqueUsers = new Set(allUsers?.map(u => u.user_id) || []).size;

      const today = new Date().toISOString().split('T')[0];
      const { data: todayUsers } = await supabase
        .from('daily_fortunes')
        .select('user_id')
        .eq('created_date', today);

      const activeTodayUsers = new Set(todayUsers?.map(u => u.user_id) || []).size;

      return {
        total_fortunes: totalFortunes || 0,
        popular_types: popularTypesArray,
        daily_trend: dailyTrend,
        user_activity: {
          total_users: uniqueUsers,
          active_users_today: activeTodayUsers,
          return_users: 0 // 추후 구현
        }
      };

    } catch (error) {
      console.error('운세 사용 통계 조회 실패:', error);
      return {
        total_fortunes: 0,
        popular_types: [],
        daily_trend: [],
        user_activity: {
          total_users: 0,
          active_users_today: 0,
          return_users: 0
        }
      };
    }
  }

  /**
   * 사용자별 운세 통계 조회
   */
  static async getUserFortuneStats(userId: string): Promise<UserFortuneStats> {
    try {
      // 사용자의 모든 운세 조회
      const { data: userFortunes } = await supabase
        .from('daily_fortunes')
        .select('fortune_type, created_date')
        .eq('user_id', userId)
        .order('created_date', { ascending: false });

      if (!userFortunes || userFortunes.length === 0) {
        return {
          total_fortunes: 0,
          favorite_types: [],
          streak_days: 0,
          last_fortune_date: '',
          fortune_distribution: {}
        };
      }

      // 운세 타입별 분포
      const distribution = userFortunes.reduce((acc, { fortune_type }) => {
        acc[fortune_type] = (acc[fortune_type] || 0) + 1;
        return acc;
      }, {} as Record<string, number>);

      // 선호 운세 타입 (상위 3개)
      const favoriteTypes = Object.entries(distribution)
        .sort(([,a], [,b]) => b - a)
        .slice(0, 3)
        .map(([type]) => type);

      // 연속 접속일 계산
      const dates = [...new Set(userFortunes.map(f => f.created_date))].sort();
      let streakDays = 0;
      const today = new Date();
      
      for (let i = 0; i < dates.length; i++) {
        const date = new Date(dates[dates.length - 1 - i]);
        const expectedDate = new Date(today);
        expectedDate.setDate(today.getDate() - i);
        
        if (date.toDateString() === expectedDate.toDateString()) {
          streakDays++;
        } else {
          break;
        }
      }

      return {
        total_fortunes: userFortunes.length,
        favorite_types: favoriteTypes,
                 streak_days: streakDays,
        last_fortune_date: userFortunes[0].created_date,
        fortune_distribution: distribution
      };

    } catch (error) {
      console.error('사용자 운세 통계 조회 실패:', error);
      return {
        total_fortunes: 0,
        favorite_types: [],
        streak_days: 0,
        last_fortune_date: '',
        fortune_distribution: {}
      };
    }
  }

  /**
   * 운세 완성률 추적
   */
  static async trackFortuneCompletion(
    userId: string,
    fortuneType: string,
    completionData: {
      started_at: Date;
      completed_at: Date;
      user_satisfaction?: number; // 1-5 점수
      feedback?: string;
    }
  ): Promise<void> {
    try {
      await supabase
        .from('fortune_completions')
        .insert({
          user_id: userId,
          fortune_type: fortuneType,
          started_at: completionData.started_at.toISOString(),
          completed_at: completionData.completed_at.toISOString(),
          duration_seconds: Math.floor(
            (completionData.completed_at.getTime() - completionData.started_at.getTime()) / 1000
          ),
          user_satisfaction: completionData.user_satisfaction,
          feedback: completionData.feedback,
          created_date: new Date().toISOString().split('T')[0]
        });
    } catch (error) {
      console.error('운세 완성률 추적 실패:', error);
    }
  }

  /**
   * 운세 타입별 완성률 조회
   */
  static async getCompletionRates(): Promise<Array<{
    fortune_type: string;
    total_starts: number;
    total_completions: number;
    completion_rate: number;
    avg_duration: number;
    avg_satisfaction: number;
  }>> {
    try {
      const { data } = await supabase
        .from('fortune_completions')
        .select('fortune_type, duration_seconds, user_satisfaction')
        .not('completed_at', 'is', null);

      if (!data) return [];

      const stats = data.reduce((acc, record) => {
        const type = record.fortune_type;
        if (!acc[type]) {
          acc[type] = {
            completions: 0,
            total_duration: 0,
            total_satisfaction: 0,
            satisfaction_count: 0
          };
        }
        
        acc[type].completions++;
        acc[type].total_duration += record.duration_seconds || 0;
        
        if (record.user_satisfaction) {
          acc[type].total_satisfaction += record.user_satisfaction;
          acc[type].satisfaction_count++;
        }
        
        return acc;
      }, {} as Record<string, any>);

      return Object.entries(stats).map(([fortune_type, data]) => ({
        fortune_type,
        total_starts: data.completions, // 임시로 완성 수와 동일하게 설정
        total_completions: data.completions,
        completion_rate: 100, // 임시로 100%로 설정
        avg_duration: data.completions ? Math.round(data.total_duration / data.completions) : 0,
        avg_satisfaction: data.satisfaction_count ? 
          Math.round((data.total_satisfaction / data.satisfaction_count) * 10) / 10 : 0
      }));

    } catch (error) {
      console.error('완성률 조회 실패:', error);
      return [];
    }
  }

  /**
   * 운세 추천 시스템을 위한 사용자 선호도 분석
   */
  static async analyzeUserPreferences(userId: string): Promise<{
    recommended_types: string[];
    avoid_types: string[];
    best_time: string;
    preferred_categories: string[];
  }> {
    try {
      // 사용자의 운세 기록 분석
      const { data: userHistory } = await supabase
        .from('daily_fortunes')
        .select('fortune_type, created_at')
        .eq('user_id', userId)
        .order('created_at', { ascending: false })
        .limit(50);

      // 완성률 데이터 분석
      const { data: completionData } = await supabase
        .from('fortune_completions')
        .select('fortune_type, user_satisfaction, created_at')
        .eq('user_id', userId)
        .order('created_at', { ascending: false })
        .limit(30);

      if (!userHistory || userHistory.length === 0) {
        // 신규 사용자인 경우 인기 운세 추천
        const stats = await this.getFortuneUsageStats(7);
        return {
          recommended_types: stats.popular_types.slice(0, 5).map(t => t.fortune_type),
          avoid_types: [],
          best_time: '오전',
          preferred_categories: ['daily', 'lucky-items']
        };
      }

      // 자주 사용하는 운세 타입
      const typeFrequency = userHistory.reduce((acc, { fortune_type }) => {
        acc[fortune_type] = (acc[fortune_type] || 0) + 1;
        return acc;
      }, {} as Record<string, number>);

      // 만족도가 높은 운세 타입
      const satisfactionByType = completionData?.reduce((acc, { fortune_type, user_satisfaction }) => {
        if (user_satisfaction && user_satisfaction >= 4) {
          acc[fortune_type] = (acc[fortune_type] || 0) + 1;
        }
        return acc;
      }, {} as Record<string, number>) || {};

      // 추천 운세 (자주 사용하면서 만족도가 높은 것들)
      const recommendedTypes = Object.keys(typeFrequency)
        .filter(type => satisfactionByType[type] > 0)
        .sort((a, b) => (satisfactionByType[b] || 0) - (satisfactionByType[a] || 0))
        .slice(0, 5);

      // 피할 운세 (만족도가 낮은 것들)
      const avoidTypes = Object.keys(completionData?.reduce((acc, { fortune_type, user_satisfaction }) => {
        if (user_satisfaction && user_satisfaction <= 2) {
          acc[fortune_type] = (acc[fortune_type] || 0) + 1;
        }
        return acc;
      }, {} as Record<string, number>) || {});

      return {
        recommended_types: recommendedTypes,
        avoid_types: avoidTypes,
        best_time: '오전', // 실제로는 시간대별 분석 필요
        preferred_categories: ['daily'] // 실제로는 카테고리별 분석 필요
      };

    } catch (error) {
      console.error('사용자 선호도 분석 실패:', error);
      return {
        recommended_types: [],
        avoid_types: [],
        best_time: '오전',
        preferred_categories: []
      };
    }
  }
} 