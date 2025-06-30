import { NextRequest, NextResponse } from 'next/server';
import { FortuneService } from '@/lib/services/fortune-service';

const fortuneService = new FortuneService();

export async function GET(request: NextRequest) {
  try {
    console.log('💕 전통 궁합 API 요청');
    
    // URL에서 사용자 ID 추출 (쿼리 파라미터 또는 헤더에서)
    const userId = request.nextUrl.searchParams.get('userId') || 'dev-user-123';
    console.log(`🔍 전통 궁합 요청: 사용자 ID = ${userId}`);

    const result = await fortuneService.getOrCreateFortune(userId, 'traditional-compatibility');

    if (!result.success) {
      return NextResponse.json(
        { success: false, error: result.error },
        { status: 500 }
      );
    }

    console.log(`✅ 전통 궁합 API 응답 완료: ${userId}`);
    return NextResponse.json({
      success: true,
      data: result.data
    });

  } catch (error) {
    console.error('❌ 전통 궁합 API 오류:', error);
    return NextResponse.json(
      { success: false, error: '전통 궁합 생성 중 오류가 발생했습니다.' },
      { status: 500 }
    );
  }
} 