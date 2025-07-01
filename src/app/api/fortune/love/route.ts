import { NextRequest, NextResponse } from 'next/server';
import { fortuneService } from '@/lib/services/fortune-service';
import { UserProfile } from '@/lib/types/fortune-system';

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
  try {
    console.log('📍 연애운 API 요청 접수');

    // URL에서 사용자 ID 추출 (없으면 기본값 사용)
    const { searchParams } = new URL(request.url);
    const userId = searchParams.get('userId') || `guest_${Date.now()}`;

    console.log(`🔍 연애운 요청: 사용자 ID = ${userId}`);

    // 기본 사용자 프로필 생성
    const userProfile = getDefaultUserProfile(userId);

    // FortuneService를 통해 연애운 데이터 요청
    const result = await fortuneService.getOrCreateFortune(
      userId,
      'love',  // FortuneCategory
      userProfile
    );

    console.log('✅ 연애운 API 응답 준비 완료');

    return NextResponse.json({
      success: true,
      data: result.data,
      cached: result.cached,
      cache_source: result.cache_source,
      generated_at: result.generated_at
    });

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
} 