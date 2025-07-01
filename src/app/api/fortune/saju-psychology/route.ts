import { NextRequest, NextResponse } from 'next/server';
import { FortuneService } from '@/lib/services/fortune-service';
import { getUserProfile } from '@/lib/mock-storage';

export async function GET(request: NextRequest) {
  try {
    console.log('🧠 사주 심리분석 API 요청');
    
    const fortuneService = new FortuneService();

    // 개발용 고정 사용자 ID (실제로는 JWT에서 추출)
    const { searchParams } = new URL(request.url);
    const userId = searchParams.get('userId') || `guest_${Date.now()}`;
    
    console.log(`🔍 사주 심리분석 요청: 사용자 ID = ${userId}`);

    // 사용자 프로필 조회
    const userProfile = getUserProfile(userId);
    if (!userProfile) {
      return NextResponse.json(
        { success: false, error: '사용자 프로필을 찾을 수 없습니다.' },
        { status: 404 }
      );
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