import { logger } from '@/lib/logger';
import { NextRequest } from 'next/server';
import { withAuth } from '@/middleware/auth';
import { createSuccessResponse, createErrorResponse } from '@/lib/api-response';
import { supabase } from '@/lib/supabase';
import { startOfDay, subDays, format } from 'date-fns';

async function getTokenStats(timeRange: string) {
  // Using the supabase client directly
  
  // 시간 범위 계산
  const days = timeRange === '7d' ? 7 : timeRange === '30d' ? 30 : 90;
  const startDate = startOfDay(subDays(new Date(), days));
  
  // 토큰 사용 기록 조회 (실제로는 token_usage 테이블에서)
  const { data: usageData, error: usageError } = await supabase
    .from('token_usage')
    .select('*')
    .gte('created_at', startDate.toISOString())
    .order('created_at', { ascending: false });

  // 사용자 정보 조회
  const { data: userData, error: userError } = await supabase
    .from('profiles')
    .select('id, full_name, is_premium')
    .eq('is_active', true);

  // 모의 데이터 생성 (실제 데이터가 없을 경우)
  if (!usageData || usageData.length === 0) {
    return generateMockStats(days);
  }

  // 실제 통계 계산
  const stats = calculateStats(usageData, userData || [], days);
  return stats;
}

function generateMockStats(days: number) {
  const now = new Date();
  const daily = [];
  const hourly = Array(24).fill(0).map((_, i) => ({
    hour: i,
    tokens: Math.floor(Math.random() * 1000) + 100
  }));

  // 일별 데이터 생성
  for (let i = 0; i < days; i++) {
    const date = subDays(now, i);
    daily.unshift({
      date: format(date, 'yyyy-MM-dd'),
      tokens: Math.floor(Math.random() * 5000) + 2000,
      cost: Math.floor(Math.random() * 50000) + 20000
    });
  }

  // 운세별 사용량
  const fortunes = [
    { fortune: '일일 운세', tokens: 15000, count: 3000 },
    { fortune: '타로 운세', tokens: 12000, count: 1500 },
    { fortune: '연애 운세', tokens: 10000, count: 2000 },
    { fortune: '직업 운세', tokens: 8000, count: 1600 },
    { fortune: '건강 운세', tokens: 5000, count: 1000 }
  ];

  // 상위 사용자
  const topUsers = [
    { userId: 'user1', name: '김철수', tokens: 5000, percentage: 10 },
    { userId: 'user2', name: '이영희', tokens: 4500, percentage: 9 },
    { userId: 'user3', name: '박민수', tokens: 4000, percentage: 8 },
    { userId: 'user4', name: '정소영', tokens: 3500, percentage: 7 },
    { userId: 'user5', name: '최준호', tokens: 3000, percentage: 6 }
  ];

  const totalUsed = daily.reduce((sum, d) => sum + d.tokens, 0);
  const averagePerDay = Math.floor(totalUsed / days);
  const totalRemaining = 100000; // 예시 잔여 토큰
  
  return {
    summary: {
      totalUsed,
      totalRemaining,
      totalPurchased: totalUsed + totalRemaining,
      averagePerDay,
      trend: Math.random() > 0.5 ? 'up' : 'down',
      trendPercentage: Math.floor(Math.random() * 20) + 5
    },
    usage: {
      daily,
      hourly,
      byFortune: fortunes
    },
    users: {
      topUsers,
      activeUsers: 150,
      premiumUsers: 45
    },
    predictions: {
      estimatedDaysRemaining: Math.floor(totalRemaining / averagePerDay),
      projectedMonthlyUsage: averagePerDay * 30,
      recommendedPurchase: averagePerDay * 30 * 1.2 // 20% 버퍼
    }
  };
}

function calculateStats(usageData: any[], userData: any[], days: number) {
  // 실제 데이터로부터 통계 계산
  // 여기에 실제 계산 로직 구현
  return generateMockStats(days); // 임시로 모의 데이터 반환
}

export async function GET(request: NextRequest) {
  return withAuth(async (req: NextRequest, user?: any) => {
    try {
      // 관리자 권한 체크 (실제로는 user role 확인)
      // if (!user || user.role !== 'admin') {
      //   return createErrorResponse('Unauthorized', 403);
      // }

      const { searchParams } = new URL(request.url);
      const range = searchParams.get('range') || '7d';
      
      const stats = await getTokenStats(range);
      return createSuccessResponse(stats);
    } catch (error) {
      logger.error('Token stats error:', error);
      return createErrorResponse('Failed to fetch token statistics', 500);
    }
  })(request);
}