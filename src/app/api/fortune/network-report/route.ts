import { NextRequest, NextResponse } from 'next/server';
import { FortuneService } from '@/lib/services/fortune-service';

export async function GET(request: NextRequest) {
  try {
    console.log('🤝 인맥보고서 API 요청 접수');
    
    const { searchParams } = new URL(request.url);
    const userId = searchParams.get('userId') || 'dev-user-123';
    
    console.log(`🔍 인맥보고서 요청: 사용자 ID = ${userId}`);

    const fortuneService = new FortuneService();
    const result = await fortuneService.getOrCreateFortune(
      userId,
      'network-report'
    );

    console.log('✅ 인맥보고서 API 응답 완료:', userId);

    return NextResponse.json(result);
  } catch (error) {
    console.error('❌ 인맥보고서 API 오류:', error);
    return NextResponse.json(
      { 
        success: false, 
        error: '인맥보고서를 불러오는 중 오류가 발생했습니다.',
        data: {
          score: 75,
          summary: '인맥보고서를 준비 중입니다. 잠시 후 다시 시도해주세요.',
          benefactors: ['준비 중입니다'],
          challengers: ['준비 중입니다'],
          advice: '인맥 분석이 진행 중입니다.',
          actionItems: ['잠시 후 다시 확인해주세요'],
          lucky: { color: '#FFD700', number: 7, direction: '동쪽' }
        }
      },
      { status: 500 }
    );
  }
} 