import { NextRequest, NextResponse } from 'next/server';
import { fortuneService } from '@/lib/services/fortune-service';
import { UserProfile } from '@/lib/types/fortune-system';

export async function GET(request: NextRequest) {
  try {
    const userId = 'kim-in-ju'; // 실제로는 세션에서 가져와야 함
    
    // 임시 사용자 프로필 (실제로는 데이터베이스에서 가져와야 함)
    const userProfile: UserProfile = {
      id: userId,
      name: '김인주',
      birth_date: '1992-03-15',
      birth_time: '14:30',
      gender: '여성',
      mbti: 'ENFP',
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    };

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