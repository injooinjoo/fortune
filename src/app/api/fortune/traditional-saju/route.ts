import { NextRequest, NextResponse } from 'next/server';
import { FortuneService } from '@/lib/services/fortune-service';
import { UserProfile } from '@/lib/types/fortune-system';

// 개발용 고정 사용자 프로필
const mockUserProfile: UserProfile = {
  id: 'dev-user-123',
  name: '김인주',
  birth_date: '1988-09-05',
  birth_time: '인시',
  gender: '남성',
  mbti: 'ENTJ',
  zodiac_sign: '처녀자리',
  created_at: '2025-06-30T16:43:32.858Z',
  updated_at: '2025-06-30T16:43:32.858Z'
};

export async function GET(request: NextRequest) {
  try {
    console.log('🔮 전통 사주 API 요청');
    
    // URL에서 사용자 ID 추출 (테스트용)
    const { searchParams } = new URL(request.url);
    const userId = searchParams.get('userId') || 'dev-user-123'; // 기본값
    
    console.log(`🔍 전통 사주 요청: 사용자 ID = ${userId}`);
    
    const fortuneService = new FortuneService();
    const result = await fortuneService.getOrCreateFortune(
      userId, 
      'traditional-saju',
      mockUserProfile
    );
    
    console.log('✅ 전통 사주 API 응답 완료:', userId);
    
    return NextResponse.json({
      success: true,
      data: result.data,
      cached: result.cached,
      cache_source: result.cache_source,
      generated_at: result.generated_at
    });
    
  } catch (error) {
    console.error('❌ 전통 사주 API 오류:', error);
    
    return NextResponse.json(
      { 
        success: false, 
        error: '전통 사주를 가져오는 중 오류가 발생했습니다.' 
      },
      { status: 500 }
    );
  }
} 