import { NextRequest, NextResponse } from 'next/server';
import { fortuneService } from '@/lib/services/fortune-service';
import { UserProfile } from '@/lib/types/fortune-system';

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
  try {
    const { searchParams } = new URL(request.url);
    const userId = searchParams.get('userId') || `guest_${Date.now()}`;
    
    // 기본 사용자 프로필 생성
    const userProfile = getDefaultUserProfile(userId);

    console.log('🔮 인연운 API 요청:', userId);

    const destinyData = await fortuneService.getOrCreateFortune(
      userId,
      'destiny', // FortuneCategory
      userProfile
    );

    console.log('✅ 인연운 API 응답 완료:', userId);

    return NextResponse.json({
      success: true,
      data: destinyData.data,
      cached: destinyData.cached
    });

  } catch (error) {
    console.error('❌ 인연운 API 오류:', error);
    
    return NextResponse.json(
      {
        success: false,
        error: error instanceof Error ? error.message : '인연운 생성 중 오류가 발생했습니다.'
      },
      { status: 500 }
    );
  }
} 