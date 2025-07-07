import { NextRequest, NextResponse } from 'next/server';
import { fortuneService } from '@/lib/services/fortune-service';
import { UserProfile } from '@/lib/types/fortune-system';
import { handleFortuneResponse } from '@/lib/api-utils';
import { withAuth, AuthenticatedRequest } from '@/middleware/auth';

// 개발용 기본 사용자 프로필 생성 함수
const getDefaultUserProfile = (userId: string): UserProfile => ({
  id: userId,
  name: '김인주',
  birth_date: '1988-09-05',
  birth_time: '인시',
  gender: '남성' as const,
  mbti: 'ENTJ',
  zodiac_sign: '처녀자리',
  created_at: new Date().toISOString(),
  updated_at: new Date().toISOString()
});

export async function GET(request: NextRequest) {
  return withAuth(request, async (req: AuthenticatedRequest) => {
    try {
      console.log('📍 인연운 API 요청 접수');

      // 인증된 사용자만 접근 가능
      if (!req.userId || req.userId === 'guest' || req.userId === 'system') {
        return NextResponse.json(
          { error: '로그인이 필요합니다.' },
          { status: 401 }
        );
      }

      console.log(`🔮 인연운 요청: 사용자 ID = ${req.userId}`);
      
      // 기본 사용자 프로필 생성
      const userProfile = getDefaultUserProfile(req.userId);

      const destinyData = await fortuneService.getOrCreateFortune(
        req.userId,
        'destiny', // FortuneCategory
        userProfile
      );

      console.log('✅ 인연운 API 응답 완료');

      return handleFortuneResponse(destinyData);

    } catch (error) {
      console.error('❌ 인연운 API 오류:', error);
      
      return handleFortuneResponse({
        success: false,
        error: error instanceof Error ? error.message : '인연운 생성 중 오류가 발생했습니다.'
      });
    }
  });
} 