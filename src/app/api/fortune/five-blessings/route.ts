import { NextRequest, NextResponse } from 'next/server';
import { FortuneService } from '@/lib/services/fortune-service';
import { withFortuneAuth, createSafeErrorResponse } from '@/lib/security-api-utils';
import { AuthenticatedRequest } from '@/middleware/auth';

export const GET = withFortuneAuth(async (request: AuthenticatedRequest, fortuneService: FortuneService) => {
  try {
    console.log('🌸 오복 API 요청');
    
    const searchParams = request.nextUrl.searchParams;
    const userId = request.userId!;
    
    console.log(`🔍 오복 요청: 사용자 ID = ${userId}`);
    
        const result = await fortuneService.getOrCreateFortune(userId, 'five-blessings');
    
    console.log(`✅ 오복 API 응답 완료: ${userId}`);
    return NextResponse.json(result);
    
  } catch (error) {
    console.error('오복 API 오류:', error);
    return createSafeErrorResponse(error, '오복 분석을 불러오는 중 오류가 발생했습니다.');
  }
});
