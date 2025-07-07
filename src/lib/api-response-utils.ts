/**
 * 표준화된 API 응답 유틸리티
 * 모든 Fortune API는 이 형식을 따라야 합니다.
 */

import { NextResponse } from 'next/server';

interface ApiSuccessResponse<T = any> {
  success: true;
  data: T;
  message?: string;
  metadata?: {
    timestamp: string;
    version?: string;
    [key: string]: any;
  };
}

interface ApiErrorResponse {
  success: false;
  error: {
    message: string;
    code?: string;
    details?: any;
  };
  metadata?: {
    timestamp: string;
    [key: string]: any;
  };
}

type ApiResponse<T = any> = ApiSuccessResponse<T> | ApiErrorResponse;

/**
 * 성공 응답 생성
 */
export function createSuccessResponse<T = any>(
  data: T,
  message?: string,
  metadata?: Record<string, any>
): NextResponse<ApiSuccessResponse<T>> {
  return NextResponse.json({
    success: true,
    data,
    message,
    metadata: {
      timestamp: new Date().toISOString(),
      ...metadata
    }
  });
}

/**
 * 에러 응답 생성
 */
export function createErrorResponse(
  message: string,
  code?: string,
  details?: any,
  status: number = 500
): NextResponse<ApiErrorResponse> {
  return NextResponse.json(
    {
      success: false,
      error: {
        message,
        code,
        details
      },
      metadata: {
        timestamp: new Date().toISOString()
      }
    },
    { status }
  );
}

/**
 * 표준 에러 핸들러
 */
export function handleApiError(error: unknown): NextResponse<ApiErrorResponse> {
  console.error('API Error:', error);

  if (error instanceof Error) {
    // 특정 에러 타입 처리
    if (error.message.includes('Unauthorized')) {
      return createErrorResponse('인증이 필요합니다.', 'UNAUTHORIZED', null, 401);
    }
    
    if (error.message.includes('Rate limit')) {
      return createErrorResponse('요청 한도를 초과했습니다.', 'RATE_LIMITED', null, 429);
    }

    if (error.message.includes('Invalid input')) {
      return createErrorResponse(error.message, 'INVALID_INPUT', null, 400);
    }

    // 일반 에러
    return createErrorResponse(
      error.message || '서버 오류가 발생했습니다.',
      'INTERNAL_ERROR',
      process.env.NODE_ENV === 'development' ? error.stack : undefined
    );
  }

  // 알 수 없는 에러
  return createErrorResponse('알 수 없는 오류가 발생했습니다.', 'UNKNOWN_ERROR');
}

/**
 * Fortune API 표준 응답 래퍼
 */
export function createFortuneResponse<T = any>(
  fortuneData: T,
  fortuneType: string,
  userId?: string
): NextResponse<ApiSuccessResponse<T>> {
  return createSuccessResponse(
    fortuneData,
    `${fortuneType} 운세가 생성되었습니다.`,
    {
      fortune_type: fortuneType,
      user_id: userId,
      generated_at: new Date().toISOString()
    }
  );
}

/**
 * 입력 검증 에러 응답
 */
export function createValidationErrorResponse(
  errors: Record<string, string[]>
): NextResponse<ApiErrorResponse> {
  return createErrorResponse(
    '입력값이 올바르지 않습니다.',
    'VALIDATION_ERROR',
    errors,
    400
  );
}

/**
 * 인증 에러 응답
 */
export function createAuthErrorResponse(
  message: string = '로그인이 필요합니다.'
): NextResponse<ApiErrorResponse> {
  return createErrorResponse(message, 'AUTHENTICATION_REQUIRED', null, 401);
}

/**
 * 권한 에러 응답
 */
export function createForbiddenResponse(
  message: string = '접근 권한이 없습니다.'
): NextResponse<ApiErrorResponse> {
  return createErrorResponse(message, 'FORBIDDEN', null, 403);
}

/**
 * Rate Limit 에러 응답
 */
export function createRateLimitResponse(
  retryAfter?: number
): NextResponse<ApiErrorResponse> {
  const headers = new Headers();
  if (retryAfter) {
    headers.set('Retry-After', retryAfter.toString());
  }

  return new NextResponse(
    JSON.stringify({
      success: false,
      error: {
        message: '너무 많은 요청이 발생했습니다. 잠시 후 다시 시도해주세요.',
        code: 'RATE_LIMITED'
      },
      metadata: {
        timestamp: new Date().toISOString(),
        retry_after: retryAfter
      }
    }),
    {
      status: 429,
      headers
    }
  );
}