import { NextRequest, NextResponse } from 'next/server';
import { FortuneService } from '@/lib/services/fortune-service';
import { withFortuneAuth, createSafeErrorResponse } from '@/lib/security-api-utils';
import { AuthenticatedRequest } from '@/middleware/auth';
import { createSuccessResponse, createErrorResponse, createFortuneResponse, handleApiError } from '@/lib/api-response-utils';


export const GET = withFortuneAuth(async (request: AuthenticatedRequest, fortuneService: FortuneService) => {
  console.log('🎣 낚시 운세 API 요청');
  
  try {
    const { searchParams } = new URL(request.url);
    const userId = request.userId!;
    
    console.log('🔍 낚시 운세 요청: 사용자 ID =', userId);
    
    const result = await fortuneService.getOrCreateFortune(userId, 'lucky-fishing');
    
    console.log('✅ 낚시 운세 API 응답 완료:', userId);
    return createSuccessResponse(result, undefined, { cached: false, generated_at: new Date( }).toISOString()
    );
    
  } catch (error) {
    console.error('❌ 낚시 운세 API 오류:', error);
    return createSafeErrorResponse(error, '낚시 운세 분석 중 오류가 발생했습니다.');
  }
});
