import { NextRequest, NextResponse } from 'next/server';
import { FortuneService } from '@/lib/services/fortune-service';
import { withFortuneAuth, createSafeErrorResponse } from '@/lib/security-api-utils';
import { AuthenticatedRequest } from '@/middleware/auth';
import { createSuccessResponse, createErrorResponse, createFortuneResponse, handleApiError } from '@/lib/api-response-utils';

export const GET = withFortuneAuth(async (request: AuthenticatedRequest, fortuneService: FortuneService) => {
  try {
    console.log('⚠️ 피해야 할 사람 API 요청');
    
    const searchParams = request.nextUrl.searchParams;
    const userId = request.userId!;
    
    console.log(`🔍 피해야 할 사람 요청: 사용자 ID = ${userId}`);
    
        const result = await fortuneService.getOrCreateFortune(userId, 'avoid-people');
    
    console.log(`✅ 피해야 할 사람 API 응답 완료: ${userId}`);
    return createSuccessResponse(result, undefined, { 
      cached: false, 
      generated_at: new Date().toISOString() 
    });
    
  } catch (error) {
    console.error('피해야 할 사람 API 오류:', error);
    return createSafeErrorResponse(error, '피해야 할 사람 분석을 불러오는 중 오류가 발생했습니다.');
  }
});
