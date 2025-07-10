import { logger } from '@/lib/logger';
import { NextRequest, NextResponse } from 'next/server';
import { FortuneService } from '@/lib/services/fortune-service';
import { withAuth, AuthenticatedRequest } from '@/middleware/auth';
import { withTokenGuard } from '@/middleware/token-guard';
import { createSuccessResponse, createErrorResponse, createFortuneResponse, handleApiError } from '@/lib/api-response-utils';

const fortuneService = new FortuneService();

export async function GET(request: NextRequest) {
  return withAuth(request, async (req: AuthenticatedRequest) => {
    logger.debug('📅 일일 운세 API 요청');
    
    try {
      // 인증된 사용자만 접근 가능
      if (!req.userId || req.userId === 'guest') {
        return createErrorResponse('로그인이 필요합니다.', undefined, undefined, 401);
      }
      
      logger.debug('🔍 일일 운세 요청: 사용자 ID =', req.userId);
      
      // 토큰 가드를 통한 토큰 처리 및 운세 생성
      return withTokenGuard(
        request,
        req.userId,
        { fortuneCategory: 'daily' },
        async () => {
          // 운세 생성
          const result = await fortuneService.getOrCreateFortune(req.userId, 'daily');
          
          logger.debug('✅ 일일 운세 API 응답 완료:', req.userId);
          
          return createSuccessResponse(result, undefined, { cached: false, generated_at: new Date().toISOString() }
          );
        }
      );
      
      
    } catch (error) {
      logger.error('❌ 일일 운세 API 오류:', error);
      return createErrorResponse('일일 운세 분석 중 오류가 발생했습니다.', undefined, undefined, 500);
    }
  });
} 