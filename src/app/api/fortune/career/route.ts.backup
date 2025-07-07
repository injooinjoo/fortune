import { NextRequest, NextResponse } from 'next/server';
import { FortuneService } from '@/lib/services/fortune-service';

export async function GET(request: NextRequest) {
  try {
    console.log('🎯 진로운 API 요청');
    
    const searchParams = request.nextUrl.searchParams;
    const userId = searchParams.get('userId') || 'anonymous';
    
    console.log(`🔍 진로운 요청: 사용자 ID = ${userId}`);
    
    const fortuneService = new FortuneService();
    const result = await fortuneService.getOrCreateFortune(userId, 'career');
    
    console.log(`✅ 진로운 API 응답 완료: ${userId}`);
    return NextResponse.json(result);
    
  } catch (error) {
    console.error('진로운 API 오류:', error);
    return NextResponse.json(
      { 
        error: '진로운을 불러오는 중 오류가 발생했습니다.',
        category: 'career',
        generated_at: new Date().toISOString()
      },
      { status: 500 }
    );
  }
} 