import { NextRequest, NextResponse } from 'next/server';
import { FortuneService } from '@/lib/services/fortune-service';
import { withFortuneAuth, createSafeErrorResponse } from '@/lib/security-api-utils';
import { AuthenticatedRequest } from '@/middleware/auth';

export const GET = withFortuneAuth(async (request: AuthenticatedRequest, fortuneService: FortuneService) => {
  try {
    console.log('📅 이사 날짜 API 요청');
    
    const searchParams = request.nextUrl.searchParams;
    const userId = request.userId!;
    
    console.log(`🔍 이사 날짜 요청: 사용자 ID = ${userId}`);
    
        const result = await fortuneService.getOrCreateFortune(userId, 'moving-date');
    
    console.log(`✅ 이사 날짜 API 응답 완료: ${userId}`);
    return NextResponse.json(result);
    
  } catch (error) {
    console.error('이사 날짜 API 오류:', error);
    return createSafeErrorResponse(error, '이사 날짜를 불러오는 중 오류가 발생했습니다.');
  }
});
