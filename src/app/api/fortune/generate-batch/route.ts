import { NextRequest, NextResponse } from 'next/server';
import { centralizedFortuneService } from '@/lib/services/centralized-fortune-service';
import { BatchFortuneRequest } from '@/types/batch-fortune';
import { supabase } from '@/lib/supabase';
import { z } from 'zod';
import { withAuth, AuthenticatedRequest } from '@/middleware/auth';
import { withRateLimit } from '@/middleware/rate-limit';


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
  return withAuth(request, async (req: AuthenticatedRequest) => {
    return withRateLimit(req, async () => {
      try {
        // 인증된 사용자만 접근 가능
        if (!req.userId || req.userId === 'guest' || req.userId === 'system') {
          return NextResponse.json(
            {
              success: false,
              error: '로그인이 필요합니다',
              data: null
            },
            { status: 401 }
          );
        }

        const userId = req.userId;

    // 2. 요청 본문 파싱 및 검증
    const body = await request.json();
    const validationResult = requestSchema.safeParse(body);
    
    if (!validationResult.success) {
      return NextResponse.json(
        {
          success: false,
          error: '잘못된 요청 형식',
          details: validationResult.error,
          data: null
        },
        { status: 400 }
      );
    }

        const batchRequest: BatchFortuneRequest = validationResult.data;
        
        // 3. 사용자 ID 검증
        if (batchRequest.user_profile.id !== userId && !isAdminUser(userId)) {
          return NextResponse.json(
            {
              success: false,
              error: '권한이 없습니다',
              data: null
            },
            { status: 403 }
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

    // 표준화된 응답 형식으로 래핑
    return NextResponse.json({
      success: true,
      data: response,
      cached: false,
      generated_at: new Date().toISOString()
    }, { headers, status: 200 });
    
      } catch (error) {
        console.error('배치 운세 생성 오류:', error);
        
        // 에러 로깅
        await logError(error, req);
        
        return NextResponse.json(
          {
            success: false,
            error: '운세 생성 중 오류가 발생했습니다',
            message: error instanceof Error ? error.message : '알 수 없는 오류',
            data: null
          },
          { status: 500 }
        );
      }
    }, { limit: 2, windowMs: 3600000 }); // 시간당 2회 제한
  });
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