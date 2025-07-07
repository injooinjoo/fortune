import { NextRequest, NextResponse } from 'next/server';
import { FortuneService } from '@/lib/services/fortune-service';
import { UserProfile } from '@/lib/types/fortune-system';
import { withFortuneAuth, createSafeErrorResponse } from '@/lib/security-api-utils';
import { AuthenticatedRequest } from '@/middleware/auth';

// 개발용 기본 사용자 프로필 생성 함수
const getDefaultUserProfile = (userId: string): UserProfile => ({
  id: userId,
  name: '김인주',
  birth_date: '1988-09-05',
  birth_time: '인시',
  gender: '남성',
  mbti: 'ENTJ',
  zodiac_sign: '처녀자리',
  created_at: new Date().toISOString(),
  updated_at: new Date().toISOString()
});

export const GET = withFortuneAuth(async (request: AuthenticatedRequest, fortuneService: FortuneService) => {
  try {
    console.log('⏰ 시간별 운세 API 요청');
    
    console.log(`🔍 시간별 운세 요청: 사용자 ID = ${request.userId}`);
    
    // 기본 사용자 프로필 생성
    const userProfile = getDefaultUserProfile(request.userId!);
    
    const result = await fortuneService.getOrCreateFortune(
      request.userId!, 
      'hourly',
      userProfile
    );
    
    console.log('✅ 시간별 운세 API 응답 완료:', request.userId);
    
    return NextResponse.json({
      success: true,
      data: result.data,
      cached: result.cached,
      cache_source: result.cache_source,
      generated_at: result.generated_at
    });
    
  } catch (error) {
    return createSafeErrorResponse(error, '시간별 운세를 가져오는 중 오류가 발생했습니다.');
  }
}); 