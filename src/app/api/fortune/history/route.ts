import { NextRequest, NextResponse } from 'next/server';
import { createClient } from '@supabase/supabase-js';
import { validateApiKey } from '@/lib/api-auth';
import { checkRateLimit } from '@/lib/rate-limit';
import { createSuccessResponse, createErrorResponse, createFortuneResponse, handleApiError } from '@/lib/api-response-utils';

// Supabase 클라이언트 초기화
const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY! // 서비스 롤 키 사용 (RLS 우회)
);

export async function GET(request: NextRequest) {
  try {
    // API 키 검증
    const authResult = await validateApiKey(request);
    if (!authResult.isValid) {
      return NextResponse.json(
        { error: 'Unauthorized', details: authResult.error },
        { status: 401 }
      );
    }

    // Rate limiting 체크
    const clientIp = request.headers.get('x-forwarded-for') || 'anonymous';
    const rateLimitResult = await checkRateLimit(clientIp, 'fortune-history');
    
    if (!rateLimitResult.allowed) {
      return NextResponse.json(
        { 
          error: 'Too many requests', 
          retryAfter: rateLimitResult.retryAfter 
        },
        { 
          status: 429,
          headers: {
            'Retry-After': String(rateLimitResult.retryAfter || 60)
          }
        }
      );
    }

    // URL 파라미터 파싱
    const { searchParams } = new URL(request.url);
    const userId = searchParams.get('userId');
    const fortuneType = searchParams.get('fortuneType');
    const limit = parseInt(searchParams.get('limit') || '20');
    const offset = parseInt(searchParams.get('offset') || '0');
    const startDate = searchParams.get('startDate');
    const endDate = searchParams.get('endDate');

    if (!userId) {
      return createErrorResponse('userId is required', undefined, undefined, 400);
    }

    // 쿼리 빌드
    let query = supabase
      .from('fortune_history')
      .select('*', { count: 'exact' })
      .eq('user_id', userId)
      .order('created_at', { ascending: false })
      .range(offset, offset + limit - 1);

    // 필터 적용
    if (fortuneType) {
      query = query.eq('fortune_type', fortuneType);
    }

    if (startDate) {
      query = query.gte('created_at', startDate);
    }

    if (endDate) {
      query = query.lte('created_at', endDate);
    }

    // 데이터 조회
    const { data, error, count } = await query;

    if (error) {
      console.error('Fortune history query error:', error);
      return NextResponse.json(
        { error: 'Failed to fetch fortune history', details: error.message },
        { status: 500 }
      );
    }

    // 토큰 사용량 집계
    const tokenSummary = data?.reduce((acc, record) => {
      acc.totalTokensUsed += record.token_cost || 0;
      acc.totalRequests += 1;
      return acc;
    }, { totalTokensUsed: 0, totalRequests: 0 });

    // 응답 반환
    return NextResponse.json({
      success: true,
      data: {
        history: data || [],
        pagination: {
          total: count || 0,
          limit,
          offset,
          hasMore: (count || 0) > offset + limit
        },
        summary: {
          ...tokenSummary,
          userId,
          fortuneType: fortuneType || 'all'
        }
      }
    });

  } catch (error) {
    console.error('Fortune history API error:', error);
    return NextResponse.json(
      { 
        error: 'Internal server error',
        message: error instanceof Error ? error.message : 'Unknown error'
      },
      { status: 500 }
    );
  }
}

// 운세 히스토리 삭제 (선택적)
export async function DELETE(request: NextRequest) {
  try {
    // API 키 검증
    const authResult = await validateApiKey(request);
    if (!authResult.isValid) {
      return NextResponse.json(
        { error: 'Unauthorized', details: authResult.error },
        { status: 401 }
      );
    }

    const body = await request.json();
    const { historyId, userId } = body;

    if (!historyId || !userId) {
      return createErrorResponse('historyId and userId are required', undefined, undefined, 400);
    }

    // 데이터 삭제 (사용자 본인의 데이터만 삭제 가능)
    const { error } = await supabase
      .from('fortune_history')
      .delete()
      .eq('id', historyId)
      .eq('user_id', userId);

    if (error) {
      console.error('Fortune history delete error:', error);
      return NextResponse.json(
        { error: 'Failed to delete fortune history', details: error.message },
        { status: 500 }
      );
    }

    return NextResponse.json({
      success: true,
      message: 'Fortune history deleted successfully'
    });

  } catch (error) {
    console.error('Fortune history DELETE API error:', error);
    return NextResponse.json(
      { 
        error: 'Internal server error',
        message: error instanceof Error ? error.message : 'Unknown error'
      },
      { status: 500 }
    );
  }
}