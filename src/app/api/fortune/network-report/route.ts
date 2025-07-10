import { logger } from '@/lib/logger';
import { NextRequest, NextResponse } from 'next/server';
import { FortuneService } from '@/lib/services/fortune-service';
import { withFortuneAuth, createSafeErrorResponse } from '@/lib/security-api-utils';
import { AuthenticatedRequest } from '@/middleware/auth';
import { createSuccessResponse, createErrorResponse, createFortuneResponse, handleApiError } from '@/lib/api-response-utils';
import { getUserProfileForAPI } from '@/lib/api-utils';


export const GET = withFortuneAuth(async (request: AuthenticatedRequest, fortuneService: FortuneService) => {
  try {
    logger.debug('🤝 인맥보고서 API 요청 접수');
    
    const { searchParams } = new URL(request.url);
    const userId = request.userId!;
    
    logger.debug(`🔍 인맥보고서 요청: 사용자 ID = ${userId}`);

    // 기본 사용자 프로필 생성
    // 실제 사용자 프로필을 가져옴
    const { profile, needsOnboarding } = await getUserProfileForAPI(userId);
    
    if (needsOnboarding || !profile) {
      return createErrorResponse(
        '프로필 설정이 필요합니다.',
        undefined,
        { needsOnboarding: true },
        403
      );
    }

        const result = await fortuneService.getOrCreateFortune(
      userId,
      'network-report',
      profile
    );

    logger.debug('✅ 인맥보고서 API 응답 완료:', userId);

    return createSuccessResponse(result, undefined, { cached: false, generated_at: new Date().toISOString() }
    );
  } catch (error) {
    logger.error('❌ 인맥보고서 API 오류:', error);
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
});
