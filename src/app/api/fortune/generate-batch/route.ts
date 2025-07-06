import { NextRequest, NextResponse } from 'next/server';
import { centralizedFortuneService } from '@/lib/services/centralized-fortune-service';
import { BatchFortuneRequest } from '@/types/batch-fortune';
import { supabase } from '@/lib/supabase';
import { z } from 'zod';

// 메모리 기반 Rate Limiting
const rateLimitStore = new Map<string, { count: number; resetTime: number }>();

// 요청 검증 스키마
const requestSchema = z.object({
  request_type: z.enum(['onboarding_complete', 'daily_refresh', 'user_direct_request']),
  user_profile: z.object({
    id: z.string(),
    name: z.string(),
    birth_date: z.string(),
    birth_time: z.string().optional(),
    gender: z.string().optional(),
    mbti: z.string().optional(),
    zodiac_sign: z.string().optional(),
    relationship_status: z.string().optional()
  }),
  requested_categories: z.array(z.string()).optional(),
  fortune_types: z.array(z.string()).optional(),
  target_date: z.string().optional(),
  analysis_period: z.string().optional(),
  generation_context: z.object({
    is_initial_setup: z.boolean().optional(),
    is_daily_auto_generation: z.boolean().optional(),
    is_user_initiated: z.boolean().optional(),
    cache_duration_hours: z.number()
  })
});

export async function POST(request: NextRequest) {
  try {
    // 1. API Key 인증 확인 (batch 작업은 관리자/크론만 허용)
    const apiKey = request.headers.get('x-api-key');
    const cronSecret = request.headers.get('x-cron-secret');
    const expectedApiKey = process.env.INTERNAL_API_KEY;
    const expectedCronSecret = process.env.CRON_SECRET;
    
    // Cron job 또는 내부 API 호출만 허용
    const isAuthorized = 
      (expectedApiKey && apiKey === expectedApiKey) ||
      (expectedCronSecret && cronSecret === expectedCronSecret);
    
    if (!isAuthorized) {
      return NextResponse.json(
        { error: 'Unauthorized. Batch generation requires admin access.' },
        { status: 401 }
      );
    }
    if (authHeader && authHeader.startsWith('Bearer ')) {
      const token = authHeader.substring(7);
      try {
        const { data: { user }, error } = await supabase.auth.getUser(token);
        if (!error && user) {
          userId = user.id;
        }
      } catch (error) {
        console.error('토큰 검증 오류:', error);
      }
    }
    
    // 쿠키에서 Supabase 세션 확인
    if (!userId && cookies) {
      const sessionMatch = cookies.match(/sb-[^-]+-auth-token=([^;]+)/);
      if (sessionMatch) {
        try {
          const sessionData = JSON.parse(decodeURIComponent(sessionMatch[1]));
          if (sessionData.access_token) {
            const { data: { user }, error } = await supabase.auth.getUser(sessionData.access_token);
            if (!error && user) {
              userId = user.id;
            }
          }
        } catch (error) {
          console.error('쿠키 파싱 오류:', error);
        }
      }
    }
    
    if (!userId) {
      return NextResponse.json(
        { error: '인증이 필요합니다' },
        { status: 401 }
      );
    }

    // 2. 요청 본문 파싱 및 검증
    const body = await request.json();
    const validationResult = requestSchema.safeParse(body);
    
    if (!validationResult.success) {
      return NextResponse.json(
        { error: '잘못된 요청 형식', details: validationResult.error },
        { status: 400 }
      );
    }

    const batchRequest: BatchFortuneRequest = validationResult.data;
    
    // 3. 사용자 ID 검증
    if (batchRequest.user_profile.id !== userId && !isAdminUser(userId)) {
      return NextResponse.json(
        { error: '권한이 없습니다' },
        { status: 403 }
      );
    }

    // 4. Rate limiting 확인
    const rateLimitOk = await checkRateLimit(userId, batchRequest.request_type);
    if (!rateLimitOk) {
      return NextResponse.json(
        { error: '요청 한도 초과. 잠시 후 다시 시도해주세요.' },
        { status: 429 }
      );
    }

    // 5. 중앙 서비스 호출
    const response = await centralizedFortuneService.callGenkitFortuneAPI(batchRequest);
    
    // 6. 응답 헤더 설정
    const headers = new Headers();
    headers.set('X-Fortune-Batch-Id', response.request_id);
    
    if (response.token_usage) {
      headers.set('X-Token-Usage', JSON.stringify(response.token_usage));
    }
    
    if (response.cache_info) {
      const maxAge = Math.floor((new Date(response.cache_info.expires_at).getTime() - Date.now()) / 1000);
      headers.set('Cache-Control', `private, max-age=${maxAge}`);
    }

    return NextResponse.json(response, { headers, status: 200 });
    
  } catch (error) {
    console.error('배치 운세 생성 오류:', error);
    
    // 에러 로깅
    await logError(error, request);
    
    return NextResponse.json(
      { 
        error: '운세 생성 중 오류가 발생했습니다',
        message: error instanceof Error ? error.message : '알 수 없는 오류'
      },
      { status: 500 }
    );
  }
}

// Rate limiting 함수
async function checkRateLimit(userId: string, requestType: string): Promise<boolean> {
  const limits = {
    'onboarding_complete': { max: 1, window: 86400 }, // 하루 1회
    'daily_refresh': { max: 2, window: 86400 }, // 하루 2회  
    'user_direct_request': { max: 10, window: 3600 } // 시간당 10회
  };
  
  const limit = limits[requestType as keyof typeof limits];
  if (!limit) return true;
  
  const now = Date.now();
  const key = `ratelimit:${requestType}:${userId}`;
  
  // 기존 rate limit 정보 가져오기
  let rateLimitInfo = rateLimitStore.get(key);
  
  // 초기화 또는 리셋
  if (!rateLimitInfo || now > rateLimitInfo.resetTime) {
    rateLimitInfo = {
      count: 0,
      resetTime: now + (limit.window * 1000)
    };
    rateLimitStore.set(key, rateLimitInfo);
  }
  
  // 카운트 증가
  rateLimitInfo.count++;
  
  return rateLimitInfo.count <= limit.max;
}

// 관리자 확인
function isAdminUser(userId: string): boolean {
  // 환경 변수에서 관리자 ID 목록 확인
  const adminIds = process.env.ADMIN_USER_IDS?.split(',') || [];
  return adminIds.includes(userId);
}

// 에러 로깅
async function logError(error: any, request: NextRequest): Promise<void> {
  try {
    const errorLog = {
      timestamp: new Date().toISOString(),
      error: error.message || 'Unknown error',
      stack: error.stack,
      url: request.url,
      method: request.method,
      headers: Object.fromEntries(request.headers.entries())
    };
    
    await supabase.from('error_logs').insert(errorLog);
  } catch (logError) {
    console.error('에러 로깅 실패:', logError);
  }
}

// OPTIONS 요청 처리 (CORS)
export async function OPTIONS(request: NextRequest) {
  return new NextResponse(null, {
    status: 200,
    headers: {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'POST, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type, Authorization',
    },
  });
}