import { NextResponse } from 'next/server';
import { FortuneResponse, UserProfile } from '@/lib/types/fortune-system';
import { userProfileService } from '@/lib/supabase';

/**
 * API에서 사용자 프로필을 가져오는 헬퍼 함수
 * 프로필이 없는 경우 온보딩으로 리다이렉트해야 함을 알려줌
 */
export async function getUserProfileForAPI(userId: string): Promise<{
  profile: UserProfile | null;
  needsOnboarding: boolean;
}> {
  try {
    const profile = await userProfileService.getProfile(userId);
    
    if (!profile) {
      console.log(`⚠️ 사용자 프로필을 찾을 수 없음: ${userId}`);
      return { profile: null, needsOnboarding: true };
    }
    
    // 프로필은 있지만 온보딩이 완료되지 않은 경우
    if (!profile.onboarding_completed) {
      console.log(`⚠️ 사용자 온보딩 미완료: ${userId}`);
      return { profile, needsOnboarding: true };
    }
    
    return { profile, needsOnboarding: false };
  } catch (error) {
    console.error('프로필 조회 중 오류:', error);
    return { profile: null, needsOnboarding: true };
  }
}

/**
 * 개발용 기본 사용자 프로필 (실제 프로필이 없을 때 폴백)
 * @deprecated 실제 프로필 사용을 권장. getUserProfileForAPI 사용
 */
export const getDefaultUserProfile = (userId: string): UserProfile => ({
  id: userId,
  name: '게스트 사용자',
  birth_date: '1995-07-15',
  birth_time: '14:30',
  gender: '여성',
  mbti: 'ENFP',
  created_at: new Date().toISOString(),
  updated_at: new Date().toISOString()
});

/**
 * Fortune API 응답을 일관된 형식으로 반환하는 유틸리티 함수
 * data 필드 안에 운세 데이터를 감싸서 반환
 */
export function handleFortuneResponse<T>(result: FortuneResponse<T>) {
  if (!result.success) {
    // 에러 응답 - data 필드 없음
    return NextResponse.json({
      success: false,
      error: result.error || '운세 생성 중 오류가 발생했습니다',
      cached: false,
      generated_at: new Date().toISOString()
    }, { status: 500 });
  }

  // 성공 응답 - data 필드에 운세 데이터 포함
  return NextResponse.json({
    success: true,
    data: result.data,
    cached: result.cached || false,
    cache_source: result.cache_source,
    generated_at: result.generated_at || new Date().toISOString()
  });
}

/**
 * Fortune API 응답을 루트 레벨에 spread하여 반환하는 유틸리티 함수
 * 기존 API와의 호환성을 위해 사용
 */
export function handleFortuneResponseWithSpread<T>(result: FortuneResponse<T>) {
  if (!result.success) {
    // 에러 응답
    return NextResponse.json({
      success: false,
      error: result.error || '운세 생성 중 오류가 발생했습니다'
    }, { status: 500 });
  }

  // 성공 응답 - 데이터를 루트에 spread
  return NextResponse.json({
    success: true,
    ...result.data,
    cached: result.cached || false,
    cache_source: result.cache_source,
    generated_at: result.generated_at || new Date().toISOString()
  });
}