import { NextRequest, NextResponse } from 'next/server';
import { fortuneService } from '@/lib/services/fortune-service';
import { UserProfile } from '@/lib/types/fortune-system';
import { handleFortuneResponseWithSpread } from '@/lib/api-utils';
import { withAuth, AuthenticatedRequest } from '@/middleware/auth';

// 개발용 기본 사용자 프로필 (실제 프로필이 없을 때 사용)
const getDefaultUserProfile = (userId: string): UserProfile => ({
  id: userId,
  name: '게스트 사용자',
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
      console.log('📍 연애운 API 요청 접수');

      // 인증된 사용자만 접근 가능
      if (!req.userId || req.userId === 'guest' || req.userId === 'system') {
        return NextResponse.json(
          { error: '로그인이 필요합니다.' },
          { status: 401 }
        );
      }

      console.log(`🔍 연애운 요청: 사용자 ID = ${req.userId}`);

      // 실제 사용자 프로필을 가져와야 함 (TODO: DB에서 조회)
      const userProfile = getDefaultUserProfile(req.userId);

      // FortuneService를 통해 연애운 데이터 요청
      const result = await fortuneService.getOrCreateFortune(
        req.userId,
        'love',  // FortuneCategory
        userProfile
      );

      console.log('✅ 연애운 API 응답 준비 완료');

      // Use utility function to handle response with data spreading
      return handleFortuneResponseWithSpread(result, '연애운');

    } catch (error) {
      console.error('❌ 연애운 API 오류:', error);
      
      return NextResponse.json(
        {
          success: false,
          error: error instanceof Error ? error.message : '연애운 생성 중 오류가 발생했습니다',
          data: null
        },
        { status: 500 }
      );
    }
  });
} 