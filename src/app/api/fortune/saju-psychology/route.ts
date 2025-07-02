import { NextRequest, NextResponse } from 'next/server';
import { FortuneService } from '@/lib/services/fortune-service';
import { getUserProfile } from '@/lib/mock-storage';

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

export async function GET(request: NextRequest) {
  try {
    console.log('🧠 사주 심리분석 API 요청');
    
    const fortuneService = new FortuneService();

    // 개발용 고정 사용자 ID (실제로는 JWT에서 추출)
    const { searchParams } = new URL(request.url);
    const userId = searchParams.get('userId') || `guest_${Date.now()}`;
    
    console.log(`🔍 사주 심리분석 요청: 사용자 ID = ${userId}`);

    // 사용자 프로필 조회 (없으면 기본 프로필 사용)
    let userProfile = getUserProfile(userId);
    if (!userProfile) {
      userProfile = getDefaultUserProfile(userId);
      console.log('🔧 기본 사용자 프로필 사용');
    }

    // 사주 심리분석 데이터 가져오기 (캐시 우선)
    const result = await fortuneService.getOrCreateFortune(
      userId, 
      'saju-psychology',
      userProfile
    );

    console.log('✅ 사주 심리분석 API 응답 완료:', userId);
    return NextResponse.json(result);

  } catch (error: any) {
    console.error('❌ 사주 심리분석 API 오류:', error);
    return NextResponse.json(
      { 
        success: false, 
        error: error.message || '사주 심리분석 처리 중 오류가 발생했습니다.' 
      },
      { status: 500 }
    );
  }
} 