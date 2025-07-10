import { logger } from '@/lib/logger';
import { NextRequest, NextResponse } from 'next/server';
import { withAuth, AuthenticatedRequest } from '@/middleware/auth';
import { withRateLimit } from '@/middleware/rate-limit';
import { FortuneService } from '@/lib/services/fortune-service';
import { UserProfile } from '@/lib/types/fortune-system';

/**
 * Fortune API를 위한 보안 래퍼
 * - 인증 체크 (로그인 필수)
 * - Rate limiting 적용
 */
export function withFortuneAuth(
  handler: (req: AuthenticatedRequest, fortuneService: FortuneService) => Promise<NextResponse>
) {
  return async (request: NextRequest) => {
    return withAuth(request, async (authReq: AuthenticatedRequest) => {
      // Rate limiting 적용
      return withRateLimit(authReq, async () => {
        const fortuneService = FortuneService.getInstance();
        
        return handler(authReq, fortuneService);
      }, {
        limit: 10, // 회원은 분당 10회
        premiumLimit: 100, // 프리미엄 회원은 100회
        windowMs: 60000 // 1분
      });
    });
  };
}

/**
 * POST 요청에서 사용자 정보 추출 및 검증
 */
export async function extractUserInfo(request: NextRequest): Promise<{
  userProfile: UserProfile | null;
  error?: string;
}> {
  try {
    const body = await request.json();
    const { userInfo } = body;
    
    if (!userInfo || !userInfo.name || !userInfo.birthDate) {
      return {
        userProfile: null,
        error: '사용자 정보가 부족합니다. 이름과 생년월일이 필요합니다.'
      };
    }
    
    // 사용자 정보를 기반으로 일관된 ID 생성
    const crypto = require('crypto');
    const userData = `${userInfo.name}_${userInfo.birthDate}`;
    const userId = `user_${crypto.createHash('md5').update(userData).digest('hex').substring(0, 8)}`;
    
    const userProfile: UserProfile = {
      id: userId,
      name: userInfo.name,
      birth_date: userInfo.birthDate,
      birth_time: userInfo.birthTime || undefined,
      gender: userInfo.gender || undefined,
      mbti: userInfo.mbti || undefined,
      zodiac_sign: userInfo.zodiacSign || undefined,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    };
    
    return { userProfile };
  } catch (error) {
    return {
      userProfile: null,
      error: '잘못된 요청 형식입니다.'
    };
  }
}

/**
 * 기본 응답 헤더 설정
 */
export function setSecurityHeaders(response: NextResponse): NextResponse {
  response.headers.set('X-Content-Type-Options', 'nosniff');
  response.headers.set('X-Frame-Options', 'DENY');
  response.headers.set('X-XSS-Protection', '1; mode=block');
  response.headers.set('Referrer-Policy', 'strict-origin-when-cross-origin');
  response.headers.set('Permissions-Policy', 'camera=(), microphone=(), geolocation=()');
  return response;
}

/**
 * 안전한 에러 응답 생성 (민감한 정보 제거)
 */
export function createSafeErrorResponse(error: any, defaultMessage: string = '요청 처리 중 오류가 발생했습니다.'): NextResponse {
  logger.error('API Error:', error);
  
  // 프로덕션에서는 상세 에러 메시지를 노출하지 않음
  const isDevelopment = process.env.NODE_ENV === 'development';
  const errorMessage = isDevelopment && error.message ? error.message : defaultMessage;
  
  return NextResponse.json(
    { 
      error: errorMessage,
      ...(isDevelopment && { details: error.toString() })
    },
    { status: 500 }
  );
}