import { logger } from '@/lib/logger';
import { NextRequest } from 'next/server';
import { fortuneService, FortuneService } from '@/lib/services/fortune-service';
import { handleFortuneResponse } from '@/lib/api-utils';
import { withAuth, AuthenticatedRequest } from '@/middleware/auth';
import { createSuccessResponse, createErrorResponse, createFortuneResponse, handleApiError } from '@/lib/api-response-utils';



export async function GET(request: NextRequest) {
  return withAuth(request, async (req: AuthenticatedRequest) => {
    try {
      logger.debug('📍 결혼운 API 요청 접수');

      // 인증된 사용자만 접근 가능
      if (!req.userId || req.userId === 'guest' || req.userId === 'system') {
        return handleFortuneResponse({
          success: false,
          error: '로그인이 필요합니다.'
        });
      }

      logger.debug(`🔍 결혼운 요청: 사용자 ID = ${req.userId}`);

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

      // FortuneService를 통해 결혼운 데이터 요청
      const result = await fortuneService.getOrCreateFortune(
        req.userId,
        'marriage',  // FortuneCategory
        profile
      );

      logger.debug('✅ 결혼운 API 응답 준비 완료');

      // Use utility function to handle response properly
      return handleFortuneResponse(result);

    } catch (error) {
      logger.error('❌ 결혼운 API 오류:', error);
      
      // 에러 시에도 일관된 응답 형식 사용
      return handleFortuneResponse({
        success: false,
        error: error instanceof Error ? error.message : '결혼운 생성 중 오류가 발생했습니다'
      });
    }
  });
} 