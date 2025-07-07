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
    console.log('🐲 띠별 운세 API 요청');
    
    // URL에서 사용자 ID 추출 (쿼리 파라미터 또는 헤더에서)
    const userId = request.nextUrl.request.userId!;
    console.log(`🔍 띠별 운세 요청: 사용자 ID = ${userId}`);

    // 기본 사용자 프로필 생성
    const userProfile = getDefaultUserProfile(userId);

    const result = await fortuneService.getOrCreateFortune(userId, 'zodiac-animal', userProfile);

    if (!result.success) {
      return createSafeErrorResponse(error, '운세를 가져오는 중 오류가 발생했습니다.');
    }

    console.log(`✅ 띠별 운세 API 응답 완료: ${userId}`);
    return NextResponse.json({
      success: true,
      data: result.data
    });

  } catch (error) {
    console.error('❌ 띠별 운세 API 오류:', error);
    return createSafeErrorResponse(error, '띠별 운세 생성 중 오류가 발생했습니다.');
  }
});
