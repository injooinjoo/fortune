import { logger } from '@/lib/logger';
import { NextRequest, NextResponse } from 'next/server';
import { FortuneService } from '@/lib/services/fortune-service';
import { withFortuneAuth, createSafeErrorResponse } from '@/lib/security-api-utils';
import { AuthenticatedRequest } from '@/middleware/auth';
import { createSuccessResponse, createErrorResponse, createFortuneResponse, handleApiError } from '@/lib/api-response-utils';
import { getUserProfileForAPI } from '@/lib/api-utils';


export const GET = withFortuneAuth(async (request: AuthenticatedRequest, fortuneService: FortuneService) => {
  try {
    logger.debug('🧠 사주 심리분석 API 요청');
    
    
    // 개발용 고정 사용자 ID (실제로는 JWT에서 추출)
    const { searchParams } = new URL(request.url);
    const userId = request.userId!;
    
    logger.debug(`🔍 사주 심리분석 요청: 사용자 ID = ${userId}`);

    // 실제 사용자 프로필을 가져옴
    const { profile, needsOnboarding } = await getUserProfileForAPI(userId);
    
    if (needsOnboarding || !profile) {
      return createErrorResponse(
        '프로필 설정이 필요합니다.',
        undefined,
        { needsOnboarding: true },
        403
      );
    }

    // 사주 심리분석 데이터 가져오기 (캐시 우선)
    const result = await fortuneService.getOrCreateFortune(
      userId, 
      'saju-psychology',
      profile
    );

    logger.debug('✅ 사주 심리분석 API 응답 완료:', userId);
    return createSuccessResponse(result, undefined, { cached: false, generated_at: new Date().toISOString() });

  } catch (error: any) {
    logger.error('❌ 사주 심리분석 API 오류:', error);
    return createSafeErrorResponse(error, '운세를 가져오는 중 오류가 발생했습니다.');
  }
});
