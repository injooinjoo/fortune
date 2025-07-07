import { NextRequest } from 'next/server';
import { fortuneService } from '@/lib/services/fortune-service';
import { UserProfile } from '@/lib/types/fortune-system';
import { handleFortuneResponse } from '@/lib/api-utils';
import { withAuth, AuthenticatedRequest } from '@/middleware/auth';

// 개발용 기본 사용자 프로필 생성 함수
const getDefaultUserProfile = (userId: string): UserProfile => ({
  id: userId,
  name: '테스트 사용자',
  birth_date: '1995-07-15',
  birth_time: '14:30',
  gender: '여성',
  mbti: 'ENFP',
  created_at: new Date().toISOString(),
  updated_at: new Date().toISOString()
});

export async function GET(request: NextRequest) {
  return withAuth(request, async (req: AuthenticatedRequest) => {
    try {
      console.log('📍 결혼운 API 요청 접수');

      // 인증된 사용자만 접근 가능
      if (!req.userId || req.userId === 'guest' || req.userId === 'system') {
        return handleFortuneResponse({
          success: false,
          error: '로그인이 필요합니다.'
        });
      }

      console.log(`🔍 결혼운 요청: 사용자 ID = ${req.userId}`);

      // 실제 사용자 프로필을 가져와야 함 (TODO: DB에서 조회)
      const userProfile = getDefaultUserProfile(req.userId);

      // FortuneService를 통해 결혼운 데이터 요청
      const result = await fortuneService.getOrCreateFortune(
        req.userId,
        'marriage',  // FortuneCategory
        userProfile
      );

      console.log('✅ 결혼운 API 응답 준비 완료');

      // Use utility function to handle response properly
      return handleFortuneResponse(result);

    } catch (error) {
      console.error('❌ 결혼운 API 오류:', error);
      
      // 에러 시에도 일관된 응답 형식 사용
      return handleFortuneResponse({
        success: false,
        error: error instanceof Error ? error.message : '결혼운 생성 중 오류가 발생했습니다'
      });
    }
  });
} 