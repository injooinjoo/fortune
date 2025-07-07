import { NextRequest, NextResponse } from 'next/server';
import { fortuneService, FortuneService } from '@/lib/services/fortune-service';
import { UserProfile } from '@/lib/types/fortune-system';
import { handleFortuneResponseWithSpread, getUserProfileForAPI } from '@/lib/api-utils';
import { withAuth, AuthenticatedRequest } from '@/middleware/auth';
import { createSuccessResponse, createErrorResponse, createFortuneResponse, handleApiError } from '@/lib/api-response-utils';

export async function GET(request: NextRequest) {
  return withAuth(request, async (req: AuthenticatedRequest) => {
    try {
      console.log('📍 연애운 API 요청 접수');

      // 인증된 사용자만 접근 가능
      if (!req.userId || req.userId === 'guest' || req.userId === 'system') {
        return createErrorResponse('로그인이 필요합니다.', undefined, undefined, 401);
      }

      console.log(`🔍 연애운 요청: 사용자 ID = ${req.userId}`);

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

      // FortuneService를 통해 연애운 데이터 요청
      const result = await fortuneService.getOrCreateFortune(
        req.userId,
        'love',  // FortuneCategory
        profile
      );

      console.log('✅ 연애운 API 응답 준비 완료');

      // Use utility function to handle response with data spreading
      return handleFortuneResponseWithSpread(result, '연애운');

    } catch (error) {
      console.error('❌ 연애운 API 오류:', error);
      
      return createErrorResponse(error instanceof Error ? error.message : '연애운 생성 중 오류가 발생했습니다', undefined, null, 500);
    }
  });
} 