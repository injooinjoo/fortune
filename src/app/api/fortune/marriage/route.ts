import { NextRequest, NextResponse } from 'next/server';
import { fortuneService } from '@/lib/services/fortune-service';
import { UserProfile } from '@/lib/types/fortune-system';

// 개발용 고정 사용자 프로필
const mockUserProfile: UserProfile = {
  id: 'dev-user-001',
  name: '테스트 사용자',
  birth_date: '1995-07-15',
  birth_time: '14:30',
  gender: '여성',
  mbti: 'ENFP',
  created_at: new Date().toISOString(),
  updated_at: new Date().toISOString()
};

export async function GET(request: NextRequest) {
  try {
    console.log('📍 결혼운 API 요청 접수');

    // URL에서 사용자 ID 추출 (없으면 기본값 사용)
    const { searchParams } = new URL(request.url);
    const userId = searchParams.get('userId') || 'dev-user-001';

    console.log(`🔍 결혼운 요청: 사용자 ID = ${userId}`);

    // FortuneService를 통해 결혼운 데이터 요청
    const result = await fortuneService.getOrCreateFortune(
      userId,
      'marriage',  // FortuneCategory
      mockUserProfile
    );

    console.log('✅ 결혼운 API 응답 준비 완료');

    return NextResponse.json({
      success: true,
      data: result.data,
      cached: result.cached,
      cache_source: result.cache_source,
      generated_at: result.generated_at
    });

  } catch (error) {
    console.error('❌ 결혼운 API 오류:', error);
    
    return NextResponse.json(
      {
        success: false,
        error: error instanceof Error ? error.message : '결혼운 생성 중 오류가 발생했습니다',
        data: null
      },
      { status: 500 }
    );
  }
} 