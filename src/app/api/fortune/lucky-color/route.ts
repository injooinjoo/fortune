import { logger } from '@/lib/logger';
import { NextRequest, NextResponse } from 'next/server';
import { FortuneService } from '@/lib/services/fortune-service';
import { withFortuneAuth, createSafeErrorResponse } from '@/lib/security-api-utils';
import { AuthenticatedRequest } from '@/middleware/auth';
import { createSuccessResponse, createErrorResponse, createFortuneResponse, handleApiError } from '@/lib/api-response-utils';


export const GET = withFortuneAuth(async (request: AuthenticatedRequest, fortuneService: FortuneService) => {
  logger.debug('🎨 행운의 색상 API 요청');
  
  try {
    const { searchParams } = new URL(request.url);
    const userId = request.userId!;
    
    logger.debug('🔍 행운의 색상 요청: 사용자 ID =', userId);
    
    const result = await fortuneService.getOrCreateFortune(userId, 'lucky-color');
    
    logger.debug('✅ 행운의 색상 API 응답 완료:', userId);
    return createSuccessResponse(result, undefined, { cached: false, generated_at: new Date().toISOString() }
    );
    
  } catch (error) {
    logger.error('❌ 행운의 색상 API 오류:', error);
    return createSafeErrorResponse(error, '행운의 색상 분석 중 오류가 발생했습니다.');
  }
});
