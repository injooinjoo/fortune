/**
 * 운세 관련 에러 클래스 및 에러 처리 유틸리티
 */

// 기본 운세 에러 클래스
export class FortuneError extends Error {
  constructor(
    message: string,
    public code: string,
    public userMessage: string,
    public details?: any
  ) {
    super(message);
    this.name = 'FortuneError';
  }
}

// 에러 타입별 상속 클래스들
export class AIServiceError extends FortuneError {
  constructor(message: string, details?: any) {
    super(
      message,
      'AI_SERVICE_ERROR',
      '운세 분석 중 일시적인 문제가 발생했습니다. 잠시 후 다시 시도해주세요.',
      details
    );
  }
}

export class TokenLimitError extends FortuneError {
  constructor(required: number, available: number) {
    super(
      `Insufficient tokens: required ${required}, available ${available}`,
      'TOKEN_LIMIT_ERROR',
      '토큰이 부족합니다. 토큰을 충전한 후 이용해주세요.',
      { required, available }
    );
  }
}

export class RateLimitError extends FortuneError {
  constructor(retryAfter: number) {
    super(
      `Rate limit exceeded. Retry after ${retryAfter} seconds`,
      'RATE_LIMIT_ERROR',
      `요청이 너무 많습니다. ${Math.ceil(retryAfter / 60)}분 후에 다시 시도해주세요.`,
      { retryAfter }
    );
  }
}

export class ValidationError extends FortuneError {
  constructor(field: string, reason: string) {
    super(
      `Validation failed for ${field}: ${reason}`,
      'VALIDATION_ERROR',
      '입력하신 정보를 확인해주세요.',
      { field, reason }
    );
  }
}

export class NetworkError extends FortuneError {
  constructor(originalError: any) {
    super(
      'Network request failed',
      'NETWORK_ERROR',
      '네트워크 연결을 확인해주세요.',
      { originalError }
    );
  }
}

// 에러 타입 감지 및 변환
export function classifyError(error: any): FortuneError {
  // OpenAI API 에러 처리
  if (error?.response?.status) {
    switch (error.response.status) {
      case 429:
        return new RateLimitError(error.response.headers?.['retry-after'] || 60);
      case 401:
      case 403:
        return new AIServiceError('Authentication failed', error);
      case 400:
        if (error.message?.includes('context_length_exceeded')) {
          return new AIServiceError('요청이 너무 깁니다. 간단히 다시 시도해주세요.', error);
        }
        return new ValidationError('request', error.message);
      case 500:
      case 502:
      case 503:
        return new AIServiceError('AI 서비스 일시 장애', error);
    }
  }

  // 네트워크 에러
  if (error.code === 'ECONNREFUSED' || error.code === 'ETIMEDOUT') {
    return new NetworkError(error);
  }

  // 한글 인코딩 에러
  if (error.message?.includes('ByteString') || error.message?.includes('encoding')) {
    return new AIServiceError('텍스트 처리 중 문제가 발생했습니다.', error);
  }

  // 기본 에러
  return new FortuneError(
    error.message || 'Unknown error',
    'UNKNOWN_ERROR',
    '예기치 않은 오류가 발생했습니다.',
    error
  );
}

// 사용자 친화적 에러 메시지 생성
export function getUserFriendlyErrorMessage(error: any): string {
  if (error instanceof FortuneError) {
    return error.userMessage;
  }

  const classified = classifyError(error);
  return classified.userMessage;
}

// 에러 로깅 (프로덕션에서는 Sentry로 전송)
export function logFortuneError(
  error: any,
  context: {
    userId?: string;
    fortuneType?: string;
    action?: string;
    [key: string]: any;
  }
) {
  const fortuneError = error instanceof FortuneError ? error : classifyError(error);
  
  const errorLog = {
    timestamp: new Date().toISOString(),
    errorCode: fortuneError.code,
    message: fortuneError.message,
    userMessage: fortuneError.userMessage,
    details: fortuneError.details,
    context,
    stack: error.stack,
  };

  // 개발 환경에서는 콘솔에 출력
  if (process.env.NODE_ENV === 'development') {
    console.error('🚨 Fortune Error:', errorLog);
  }

  // 프로덕션에서는 Sentry로 전송
  if (process.env.NODE_ENV === 'production' && typeof window !== 'undefined') {
    // window.Sentry?.captureException(error, {
    //   tags: {
    //     errorCode: fortuneError.code,
    //     fortuneType: context.fortuneType,
    //   },
    //   extra: errorLog,
    // });
  }

  return errorLog;
}

// 에러 복구 전략
export interface ErrorRecoveryStrategy {
  retry?: {
    maxAttempts: number;
    delayMs: number;
    backoff?: 'linear' | 'exponential';
  };
  fallback?: () => Promise<any>;
  cache?: boolean;
}

// 에러 복구 헬퍼
export async function withErrorRecovery<T>(
  operation: () => Promise<T>,
  strategy: ErrorRecoveryStrategy,
  context?: any
): Promise<T> {
  let lastError: any;
  const maxAttempts = strategy.retry?.maxAttempts || 1;
  
  for (let attempt = 1; attempt <= maxAttempts; attempt++) {
    try {
      return await operation();
    } catch (error) {
      lastError = error;
      logFortuneError(error, { ...context, attempt });

      // 재시도 불가능한 에러는 즉시 중단
      if (error instanceof ValidationError || error instanceof TokenLimitError) {
        break;
      }

      // 마지막 시도가 아니면 대기 후 재시도
      if (attempt < maxAttempts && strategy.retry) {
        const delay = strategy.retry.backoff === 'exponential'
          ? strategy.retry.delayMs * Math.pow(2, attempt - 1)
          : strategy.retry.delayMs * attempt;
          
        await new Promise(resolve => setTimeout(resolve, delay));
        continue;
      }
    }
  }

  // 모든 시도 실패 시 폴백 전략 실행
  if (strategy.fallback) {
    try {
      return await strategy.fallback();
    } catch (fallbackError) {
      logFortuneError(fallbackError, { ...context, phase: 'fallback' });
    }
  }

  // 최종 실패
  throw lastError;
}