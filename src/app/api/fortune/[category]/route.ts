// 운세 카테고리별 API 엔드포인트
// 작성일: 2024-12-19

import { NextRequest, NextResponse } from 'next/server';
import { fortuneService } from '@/lib/services/fortune-service';
import { FortuneCategory, InteractiveInput } from '@/lib/types/fortune-system';
import { getUserProfile, getAllProfiles } from '@/lib/mock-storage';

// 임시로 인증 우회 (개발용)
async function getCurrentUser() {
  // 실제 프로덕션에서는 Supabase 인증을 사용
  // 지금은 개발 단계이므로 임시 사용자 반환
  return {
    id: 'dev-user-123',
    email: 'dev@example.com'
  };
}

export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ category: string }> }
) {
  try {
    // 임시 사용자 정보 가져오기 (개발용)
    const user = await getCurrentUser();

    const { category } = await params;
    console.log(`운세 요청: ${category}, 사용자: ${user.id}`);
    
    // 공유 메모리에서 직접 프로필 조회
    console.log('전체 저장된 프로필들:', getAllProfiles());
    let userProfile = getUserProfile(user.id);
    
    // 프로필이 없으면 프로필 입력 요구
    if (!userProfile) {
      console.log('프로필 없음 - 프로필 입력 필요');
      return NextResponse.json(
        { 
          success: false, 
          error: 'PROFILE_REQUIRED',
          message: '프로필 정보가 필요합니다. 프로필을 먼저 설정해주세요.',
          redirect: '/onboarding/profile'
        },
        { status: 400 }
      );
    }
    
    console.log('실제 사용자 프로필 로드:', userProfile);

    // 운세 데이터 조회 또는 생성
    const result = await fortuneService.getOrCreateFortune(
      user.id,
      category as FortuneCategory,
      userProfile
    );

    console.log('운세 결과:', { success: result.success, cached: result.cached });
    return NextResponse.json(result);

  } catch (error) {
    console.error('운세 API 오류:', error);
    return NextResponse.json(
      { 
        success: false, 
        error: error instanceof Error ? error.message : '서버 오류가 발생했습니다.',
        cached: false,
        generated_at: new Date().toISOString()
      },
      { status: 500 }
    );
  }
}

export async function POST(
  request: NextRequest,
  { params }: { params: Promise<{ category: string }> }
) {
  try {
    // 임시 사용자 정보 가져오기 (개발용)
    const user = await getCurrentUser();

    const { category } = await params;
    const requestBody = await request.json();

    // 공유 메모리에서 직접 프로필 조회
    let userProfile = getUserProfile(user.id);
    
    if (!userProfile) {
      userProfile = {
        id: user.id,
        birth_date: '1990-01-01',
        birth_time: undefined,
        gender: '선택 안함' as const,
        mbti: undefined,
        zodiac_sign: '염소자리',
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      };
    }

    // 실시간 상호작용 운세의 경우 입력 데이터 처리
    let interactiveInput: InteractiveInput | undefined;
    
    if (['dream-interpretation', 'tarot', 'compatibility', 'worry-bead'].includes(category)) {
      if (!requestBody.inputData) {
        return NextResponse.json(
          { success: false, error: '입력 데이터가 필요합니다.' },
          { status: 400 }
        );
      }

      interactiveInput = {
        type: category.includes('dream') ? 'dream' :
              category.includes('tarot') ? 'tarot' :
              category.includes('compatibility') ? 'compatibility' : 'worry',
        data: requestBody.inputData,
        user_profile: userProfile
      };
    }

    // 운세 데이터 조회 또는 생성
    const result = await fortuneService.getOrCreateFortune(
      user.id,
      category as FortuneCategory,
      userProfile,
      interactiveInput
    );

    return NextResponse.json(result);

  } catch (error) {
    console.error('운세 API 오류:', error);
    return NextResponse.json(
      { 
        success: false, 
        error: error instanceof Error ? error.message : '서버 오류가 발생했습니다.',
        cached: false,
        generated_at: new Date().toISOString()
      },
      { status: 500 }
    );
  }
} 