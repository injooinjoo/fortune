import { logger } from '@/lib/logger';
import { NextRequest, NextResponse } from 'next/server';
import { createClient } from '@supabase/supabase-js';
import { TokenMonitor } from '@/lib/utils/token-monitor';
import { subDays, format } from 'date-fns';

// 관리자 전용 Supabase 클라이언트
const supabaseAdmin = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!,
  {
    auth: {
      autoRefreshToken: false,
      persistSession: false
    }
  }
);

// 관리자 권한 확인
async function verifyAdminAccess(request: NextRequest): Promise<boolean> {
  const authHeader = request.headers.get('authorization');
  if (!authHeader) return false;

  try {
    const token = authHeader.replace('Bearer ', '');
    
    // Supabase JWT 검증
    const { data: { user }, error } = await supabaseAdmin.auth.getUser(token);
    if (error || !user) return false;

    // 관리자 권한 확인 (이메일 도메인 또는 역할 기반)
    const isAdmin = user.email?.endsWith('@fortune-admin.com') || 
                   user.user_metadata?.role === 'admin';
    
    return isAdmin;
  } catch {
    return false;
  }
}

export async function GET(request: NextRequest) {
  try {
    // 관리자 권한 확인
    if (!await verifyAdminAccess(request)) {
      return NextResponse.json(
        { error: 'Unauthorized' },
        { status: 401 }
      );
    }

    // 쿼리 파라미터 파싱
    const { searchParams } = new URL(request.url);
    const days = parseInt(searchParams.get('days') || '7');
    const startDate = subDays(new Date(), days);

    const tokenMonitor = new TokenMonitor();

    // 일일 및 월간 통계
    const dailyStats = await tokenMonitor.getUsageStats('system'); // 시스템 전체
    
    // 시간대별 데이터 조회
    const { data: timelineData, error: timelineError } = await supabaseAdmin
      .from('token_usage')
      .select('created_at, total_tokens, cost')
      .gte('created_at', startDate.toISOString())
      .order('created_at', { ascending: true });

    if (timelineError) {
      logger.error('Timeline 데이터 조회 오류:', timelineError);
    }

    // 일별 집계
    const timeline = timelineData ? aggregateByDay(timelineData) : [];

    // 패키지별 통계
    const { data: packageData, error: packageError } = await supabaseAdmin
      .from('token_usage')
      .select('package_name, total_tokens, cost')
      .gte('created_at', startDate.toISOString());

    if (packageError) {
      logger.error('패키지 데이터 조회 오류:', packageError);
    }

    const byPackage = packageData ? aggregateByPackage(packageData) : {};

    // 상위 사용자
    const { data: userStats, error: userError } = await supabaseAdmin
      .from('token_usage')
      .select('user_id, total_tokens, cost')
      .gte('created_at', startDate.toISOString());

    if (userError) {
      logger.error('사용자 데이터 조회 오류:', userError);
    }

    const topUsers = await getTopUsers(userStats || []);

    // 패키지 효율성 분석
    const packageEfficiency = await tokenMonitor.analyzePackageEfficiency();

    // 응답 데이터 구성
    const response = {
      daily: dailyStats.daily,
      monthly: dailyStats.monthly,
      byPackage: {
        ...packageEfficiency,
        ...byPackage
      },
      timeline,
      topUsers
    };

    return NextResponse.json(response);

  } catch (error) {
    logger.error('토큰 사용량 통계 조회 오류:', error);
    return NextResponse.json(
      { 
        error: '통계 조회 실패',
        message: error instanceof Error ? error.message : '알 수 없는 오류'
      },
      { status: 500 }
    );
  }
}

// 일별 데이터 집계
function aggregateByDay(data: any[]): any[] {
  const dayMap = new Map<string, { tokens: number; cost: number; requests: number }>();

  data.forEach(record => {
    const date = format(new Date(record.created_at), 'yyyy-MM-dd');
    const existing = dayMap.get(date) || { tokens: 0, cost: 0, requests: 0 };
    
    dayMap.set(date, {
      tokens: existing.tokens + (record.total_tokens || 0),
      cost: existing.cost + (record.cost || 0),
      requests: existing.requests + 1
    });
  });

  return Array.from(dayMap.entries())
    .map(([date, stats]) => ({ date, ...stats }))
    .sort((a, b) => a.date.localeCompare(b.date));
}

// 패키지별 데이터 집계
function aggregateByPackage(data: any[]): any {
  const packageMap = new Map<string, {
    totalTokens: number;
    totalCost: number;
    requestCount: number;
  }>();

  data.forEach(record => {
    if (!record.package_name) return;
    
    const existing = packageMap.get(record.package_name) || {
      totalTokens: 0,
      totalCost: 0,
      requestCount: 0
    };
    
    packageMap.set(record.package_name, {
      totalTokens: existing.totalTokens + (record.total_tokens || 0),
      totalCost: existing.totalCost + (record.cost || 0),
      requestCount: existing.requestCount + 1
    });
  });

  const result: any = {};
  
  packageMap.forEach((stats, packageName) => {
    result[packageName] = {
      avgTokensPerRequest: Math.round(stats.totalTokens / stats.requestCount),
      avgCostPerRequest: stats.totalCost / stats.requestCount,
      requestCount: stats.requestCount,
      savingsPercent: calculateSavingsPercent(packageName, stats)
    };
  });

  return result;
}

// 상위 사용자 조회
async function getTopUsers(usageData: any[]): Promise<any[]> {
  const userMap = new Map<string, { tokens: number; cost: number; requests: number }>();

  usageData.forEach(record => {
    const existing = userMap.get(record.user_id) || { tokens: 0, cost: 0, requests: 0 };
    
    userMap.set(record.user_id, {
      tokens: existing.tokens + (record.total_tokens || 0),
      cost: existing.cost + (record.cost || 0),
      requests: existing.requests + 1
    });
  });

  // 상위 10명 추출
  const topUserIds = Array.from(userMap.entries())
    .sort((a, b) => b[1].tokens - a[1].tokens)
    .slice(0, 10)
    .map(([userId]) => userId);

  // 사용자 정보 조회
  const { data: profiles } = await supabaseAdmin
    .from('profiles')
    .select('id, name')
    .in('id', topUserIds);

  const profileMap = new Map(profiles?.map(p => [p.id, p.name]) || []);

  return topUserIds.map(userId => ({
    userId,
    userName: profileMap.get(userId) || '알 수 없음',
    totalTokens: userMap.get(userId)!.tokens,
    totalCost: userMap.get(userId)!.cost,
    requestCount: userMap.get(userId)!.requests
  }));
}

// 절감률 계산
function calculateSavingsPercent(packageName: string, stats: any): number {
  // 패키지에 포함된 운세 개수 추정
  const fortuneCounts: Record<string, number> = {
    'TRADITIONAL_PACKAGE': 5,
    'DAILY_PACKAGE': 4,
    'LOVE_PACKAGE_SINGLE': 4,
    'CAREER_WEALTH_PACKAGE': 4,
    'LUCKY_ITEMS_PACKAGE': 5
  };

  const fortuneCount = fortuneCounts[packageName] || 3;
  const individualCost = fortuneCount * 500 * 0.0005 / 1000; // 개별 호출 예상 비용
  const actualCost = stats.totalCost / stats.requestCount;
  
  return Math.round(((individualCost - actualCost) / individualCost) * 100);
}