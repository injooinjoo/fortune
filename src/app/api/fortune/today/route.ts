import { NextRequest, NextResponse } from 'next/server';
import { FortuneService } from '@/lib/services/fortune-service';
import { UserProfile } from '@/lib/types/fortune-system';
import { withFortuneAuth, extractUserInfo, createSafeErrorResponse } from '@/lib/security-api-utils';
import { AuthenticatedRequest } from '@/middleware/auth';
import { createSuccessResponse, createErrorResponse, createFortuneResponse, handleApiError } from '@/lib/api-response-utils';

export const POST = withFortuneAuth(async (request: AuthenticatedRequest, fortuneService: FortuneService) => {
  try {
    console.log('📅 오늘의 운세 API 요청 (POST)');
    
    const { userProfile, error } = await extractUserInfo(request);
    
    if (error || !userProfile) {
      return createErrorResponse(error || '사용자 정보 처리 중 오류가 발생했습니다.' 
        , undefined, undefined, 400);
    }
    
    console.log(`🔍 오늘의 운세 요청: 사용자 = ${userProfile.name}, 인증 사용자 = ${request.userId}`);
    
    // 인증된 사용자의 userId 사용
    const userId = request.userId!;
    
    const result = await fortuneService.getOrCreateFortune(
      userId, 
      'today',
      userProfile
    );
    
    console.log('✅ 오늘의 운세 API 응답 완료:', userProfile.name);
    
    return createSuccessResponse(result.data, undefined, { cached: result.cached,
      cache_source: result.cache_source, generated_at: result.generated_at
     });
    
  } catch (error) {
    return createSafeErrorResponse(error, '오늘의 운세를 가져오는 중 오류가 발생했습니다.');
  }
});

// GET 메서드도 인증 적용
export const GET = withFortuneAuth(async (request: AuthenticatedRequest, fortuneService: FortuneService) => {
  try {
    console.log('📅 오늘의 운세 API 요청 (GET)');
    
    // 기본 사용자 프로필 생성
    const userProfile: UserProfile = {
      id: request.userId!,
      name: '회원',
      birth_date: '1990-01-01',
      birth_time: '오시',
      gender: '선택 안함',
      mbti: 'ENFP',
      zodiac_sign: '염소자리',
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    };
    
    const result = await fortuneService.getOrCreateFortune(
      request.userId!, 
      'today',
      userProfile
    );
    
    console.log('✅ 오늘의 운세 API 응답 완료');
    
    return createSuccessResponse(result.data, undefined, { cached: result.cached,
      cache_source: result.cache_source, generated_at: result.generated_at
     });
    
  } catch (error) {
    return createSafeErrorResponse(error, '오늘의 운세를 가져오는 중 오류가 발생했습니다.');
  }
}); 