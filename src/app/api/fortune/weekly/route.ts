import { logger } from '@/lib/logger';
import { NextRequest, NextResponse } from 'next/server';
import { FortuneService } from '@/lib/services/fortune-service';
import { withFortuneAuth, createSafeErrorResponse } from '@/lib/security-api-utils';
import { AuthenticatedRequest } from '@/middleware/auth';
import { createSuccessResponse, createErrorResponse, createFortuneResponse, handleApiError } from '@/lib/api-response-utils';
import { getUserProfileForAPI } from '@/lib/api-utils';



export const GET = withFortuneAuth(async (request: AuthenticatedRequest, fortuneService: FortuneService) => {
  try {
    logger.debug('📅 주간 운세 API 요청');
    
    // URL에서 사용자 ID 추출 (테스트용)
    const { searchParams } = new URL(request.url);
    const userId = request.userId!; // 동적 기본값
    
    logger.debug(`🔍 주간 운세 요청: 사용자 ID = ${userId}`);
    
    // 기본 사용자 프로필 생성
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
    
        const result = await fortuneService.getOrCreateFortune(
      userId, 
      'weekly',
      profile
    );
    
    logger.debug('✅ 주간 운세 API 응답 완료:', userId);
    
    return createSuccessResponse(result.data, undefined, { cached: result.cached,
      cache_source: result.cache_source, generated_at: result.generated_at
     });
    
  } catch (error) {
    logger.error('❌ 주간 운세 API 오류:', error);
    
    return createSafeErrorResponse(error, '주간 운세를 가져오는 중 오류가 발생했습니다.');
  }
});
