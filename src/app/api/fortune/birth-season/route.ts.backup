import { NextRequest, NextResponse } from 'next/server';
import { FortuneService } from '@/lib/services/fortune-service';

const fortuneService = new FortuneService();

export async function GET(request: NextRequest) {
  console.log('🌱 태어난 계절 API 요청');
  
  try {
    const { searchParams } = new URL(request.url);
    const userId = searchParams.get('userId') || 'test_user';
    
    console.log('🔍 태어난 계절 요청: 사용자 ID =', userId);
    
    const result = await fortuneService.getOrCreateFortune(userId, 'birth-season');
    
    console.log('✅ 태어난 계절 API 응답 완료:', userId);
    return NextResponse.json(result);
    
  } catch (error) {
    console.error('❌ 태어난 계절 API 오류:', error);
    return NextResponse.json(
      { error: '태어난 계절 분석 중 오류가 발생했습니다.' },
      { status: 500 }
    );
  }
} 