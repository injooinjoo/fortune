import { NextRequest, NextResponse } from 'next/server';
import { FortuneService } from '@/lib/services/fortune-service';
import { withFortuneAuth, createSafeErrorResponse } from '@/lib/security-api-utils';
import { AuthenticatedRequest } from '@/middleware/auth';


// 개발용 기본 사용자 프로필 생성 함수
const getDefaultUserProfile = (userId: string) => ({
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

export const GET = withFortuneAuth(async (request: AuthenticatedRequest, fortuneService: FortuneService) => {
  try {
    console.log('💕 전통 궁합 API 요청');
    
    // URL에서 사용자 ID 추출 (쿼리 파라미터 또는 헤더에서)
    const userId = request.nextUrl.request.userId!;
    console.log(`🔍 전통 궁합 요청: 사용자 ID = ${userId}`);

    // 기본 사용자 프로필 생성
    const userProfile = getDefaultUserProfile(userId);

    // INTERACTIVE 그룹을 위한 InteractiveInput 생성
    const interactiveInput = {
      type: 'compatibility' as const,
      data: {},
      user_profile: userProfile
    };

    const result = await fortuneService.getOrCreateFortune(userId, 'traditional-compatibility', userProfile, interactiveInput);

    if (!result.success) {
      return createSafeErrorResponse(error, '운세를 가져오는 중 오류가 발생했습니다.');
    }

    console.log(`✅ 전통 궁합 API 응답 완료: ${userId}`);
    return NextResponse.json({
      success: true,
      data: result.data
    });

  } catch (error) {
    console.error('❌ 전통 궁합 API 오류:', error);
    return createSafeErrorResponse(error, '전통 궁합 생성 중 오류가 발생했습니다.');
  }
});
