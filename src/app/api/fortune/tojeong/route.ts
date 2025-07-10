import { logger } from '@/lib/logger';
import { NextRequest, NextResponse } from 'next/server';
import { fortuneService } from '@/lib/services/fortune-service';
import { handleFortuneResponse, getUserProfileForAPI } from '@/lib/api-utils';
import { withAuth, AuthenticatedRequest } from '@/middleware/auth';
import { createSuccessResponse, createErrorResponse, createFortuneResponse, handleApiError } from '@/lib/api-response-utils';


export async function GET(request: NextRequest) {
  return withAuth(request, async (req: AuthenticatedRequest) => {
    try {
      logger.debug('📍 토정비결 API 요청 접수');

      // 인증된 사용자만 접근 가능
      if (!req.userId || req.userId === 'guest' || req.userId === 'system') {
        return createErrorResponse('로그인이 필요합니다.', undefined, undefined, 401);
      }

      logger.debug(`🔍 토정비결 요청: 사용자 ID = ${req.userId}`);

      // 기본 사용자 프로필 생성
      // 실제 사용자 프로필을 가져옴
    const { profile, needsOnboarding } = await getUserProfileForAPI(req.userId);
    
    if (needsOnboarding || !profile) {
      return createErrorResponse(
        '프로필 설정이 필요합니다.',
        undefined,
        { needsOnboarding: true },
        403
      );
    }

      const result = await fortuneService.getOrCreateFortune(req.userId, 'tojeong', profile);

      logger.debug(`✅ 토정비결 API 응답 완료`);
      return handleFortuneResponse(result);

    } catch (error) {
      logger.error('❌ 토정비결 API 오류:', error);
      return handleFortuneResponse({
        success: false,
        error: error instanceof Error ? error.message : '토정비결 생성 중 오류가 발생했습니다.'
      });
    }
  });
} 