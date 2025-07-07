import { NextRequest, NextResponse } from 'next/server';
import { FortuneService } from '@/lib/services/fortune-service';
import { withFortuneAuth, createSafeErrorResponse } from '@/lib/security-api-utils';
import { AuthenticatedRequest } from '@/middleware/auth';
import { UserProfile } from '@/lib/types/fortune-system';

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
    console.log('📊 바이오리듬 API 요청');
    
    // URL에서 사용자 ID 추출 (테스트용)
    const { searchParams } = new URL(request.url);
    const userId = request.userId!; // 동적 기본값
    
    console.log(`🔍 바이오리듬 요청: 사용자 ID = ${userId}`);
    
    // 기본 사용자 프로필 생성
    const userProfile = getDefaultUserProfile(userId);
    
        const result = await fortuneService.getOrCreateFortune(
      userId, 
      'biorhythm',
      userProfile
    );
    
    console.log('✅ 바이오리듬 API 응답 완료:', userId);
    
    return NextResponse.json({
      success: true,
      data: result.data,
      cached: result.cached,
      cache_source: result.cache_source,
      generated_at: result.generated_at
    });
    
  } catch (error) {
    console.error('❌ 바이오리듬 API 오류:', error);
    
    return createSafeErrorResponse(error, '바이오리듬을 가져오는 중 오류가 발생했습니다.');
  }
});
