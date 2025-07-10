import { logger } from '@/lib/logger';
import { NextRequest, NextResponse } from 'next/server';
import { FortuneService } from '@/lib/services/fortune-service';
import { withFortuneAuth, createSafeErrorResponse } from '@/lib/security-api-utils';
import { AuthenticatedRequest } from '@/middleware/auth';
import { createSuccessResponse, createErrorResponse, createFortuneResponse, handleApiError } from '@/lib/api-response-utils';
import { getUserProfileForAPI } from '@/lib/api-utils';



export const GET = withFortuneAuth(async (request: AuthenticatedRequest, fortuneService: FortuneService) => {
  try {
    logger.debug('💕 전통 궁합 API 요청');
    
    // URL에서 사용자 ID 추출 (쿼리 파라미터 또는 헤더에서)
    const userId = request.nextUrl.request.userId!;
    logger.debug(`🔍 전통 궁합 요청: 사용자 ID = ${userId}`);

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

    // INTERACTIVE 그룹을 위한 InteractiveInput 생성
    const interactiveInput = {
      type: 'compatibility' as const,
      data: {},
      user_profile: profile
    };

    const result = await fortuneService.getOrCreateFortune(userId, 'traditional-compatibility', profile, interactiveInput);

    if (!result.success) {
      return createSafeErrorResponse(error, '운세를 가져오는 중 오류가 발생했습니다.');
    }

    logger.debug(`✅ 전통 궁합 API 응답 완료: ${userId}`);
    return createSuccessResponse(result.data, undefined, { cached: false, generated_at: new Date().toISOString() });

  } catch (error) {
    logger.error('❌ 전통 궁합 API 오류:', error);
    return createSafeErrorResponse(error, '전통 궁합 생성 중 오류가 발생했습니다.');
  }
});
