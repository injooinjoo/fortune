import { logger } from '@/lib/logger';
import { NextRequest, NextResponse } from 'next/server';
import { FortuneService } from '@/lib/services/fortune-service';
import { withFortuneAuth, createSafeErrorResponse } from '@/lib/security-api-utils';
import { AuthenticatedRequest } from '@/middleware/auth';
import { createSuccessResponse, createErrorResponse, createFortuneResponse, handleApiError } from '@/lib/api-response-utils';
import { getUserProfileForAPI } from '@/lib/api-utils';



export const GET = withFortuneAuth(async (request: AuthenticatedRequest, fortuneService: FortuneService) => {
  try {
    logger.debug('⏰ 시간별 운세 API 요청');
    
    logger.debug(`🔍 시간별 운세 요청: 사용자 ID = ${request.userId}`);
    
    // 기본 사용자 프로필 생성
    // 실제 사용자 프로필을 가져옴
    const { profile, needsOnboarding } = await getUserProfileForAPI(request.userId!);
    
    if (needsOnboarding || !profile) {
      return createErrorResponse(
        '프로필 설정이 필요합니다.',
        undefined,
        { needsOnboarding: true },
        403
      );
    }
    
    const result = await fortuneService.getOrCreateFortune(
      request.userId!, 
      'hourly',
      profile
    );
    
    logger.debug('✅ 시간별 운세 API 응답 완료:', request.userId);
    
    return createSuccessResponse(result.data, undefined, { cached: result.cached,
      cache_source: result.cache_source, generated_at: result.generated_at
     });
    
  } catch (error) {
    return createSafeErrorResponse(error, '시간별 운세를 가져오는 중 오류가 발생했습니다.');
  }
}); 