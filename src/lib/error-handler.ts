import { logger } from '@/lib/logger';

/**
 * 통합된 에러 처리 시스템
 * 보안을 고려한 에러 로깅 및 사용자 친화적 메시지 제공
 */

export interface ErrorInfo {
  code?: string;
  message: string;
  context?: string;
  timestamp: number;
  userAgent?: string;
  url?: string;
}

export class SecureErrorHandler {
  private static instance: SecureErrorHandler;
  private errorQueue: ErrorInfo[] = [];
  private maxQueueSize = 50;

  static getInstance(): SecureErrorHandler {
    if (!SecureErrorHandler.instance) {
      SecureErrorHandler.instance = new SecureErrorHandler();
    }
    return SecureErrorHandler.instance;
  }

  /**
   * 에러를 안전하게 로깅 (민감한 정보 제거)
   */
  logError(error: Error | string, context?: string): void {
    const errorInfo: ErrorInfo = {
      message: this.sanitizeErrorMessage(error),
      context,
      timestamp: Date.now(),
      userAgent: this.sanitizeUserAgent(),
      url: this.sanitizeUrl()
    };

    // 개발 환경에서만 상세 로깅
    if (process.env.NODE_ENV === 'development') {
      logger.error('🔴 Error logged:', errorInfo);
    }

    // 큐에 추가 (최대 크기 유지)
    this.errorQueue.push(errorInfo);
    if (this.errorQueue.length > this.maxQueueSize) {
      this.errorQueue.shift();
    }
  }

  /**
   * 사용자 친화적 에러 메시지 생성
   */
  getUserFriendlyMessage(error: Error | string): string {
    const errorStr = typeof error === 'string' ? error : error.message;

    // React Error #31 처리
    if (errorStr.includes('Minified React error #31') || 
        errorStr.includes('Objects are not valid as a React child')) {
      return '페이지 로딩 중 일시적인 문제가 발생했습니다. 새로고침해주세요.';
    }

    // 네트워크 에러 처리
    if (errorStr.includes('fetch') || errorStr.includes('Network')) {
      return '네트워크 연결을 확인하고 다시 시도해주세요.';
    }

    // 인증 에러 처리
    if (errorStr.includes('Unauthorized') || errorStr.includes('401')) {
      return '로그인이 필요합니다. 다시 로그인해주세요.';
    }

    // OAuth 에러 처리
    if (errorStr.includes('OAuth') || errorStr.includes('session')) {
      return '로그인 처리 중 문제가 발생했습니다. 다시 시도해주세요.';
    }

    // 일반적인 에러
    return '일시적인 문제가 발생했습니다. 잠시 후 다시 시도해주세요.';
  }

  /**
   * 에러 메시지에서 민감한 정보 제거
   */
  private sanitizeErrorMessage(error: Error | string): string {
    let message = typeof error === 'string' ? error : error.message;
    
    // URL과 토큰 정보 제거
    message = message.replace(/https?:\/\/[^\s]+/g, '[URL_FILTERED]');
    message = message.replace(/token[s]?[=:]\s*[^\s&]+/gi, '[TOKEN_FILTERED]');
    message = message.replace(/key[s]?[=:]\s*[^\s&]+/gi, '[KEY_FILTERED]');
    message = message.replace(/password[s]?[=:]\s*[^\s&]+/gi, '[PASSWORD_FILTERED]');
    
    return message;
  }

  /**
   * User Agent에서 민감한 정보 제거
   */
  private sanitizeUserAgent(): string {
    if (typeof navigator === 'undefined') return 'server';
    
    const ua = navigator.userAgent;
    // 브라우저와 OS 정보만 유지, 구체적인 버전은 일반화
    return ua.replace(/[\d.]+/g, 'x.x').substring(0, 100);
  }

  /**
   * URL에서 민감한 정보 제거
   */
  private sanitizeUrl(): string {
    if (typeof window === 'undefined') return 'server';
    
    const url = window.location.href;
    // 쿼리 파라미터와 해시 제거
    return url.split('?')[0].split('#')[0];
  }

  /**
   * 에러 통계 조회 (개발 환경에서만)
   */
  getErrorStats(): { total: number; recent: ErrorInfo[] } {
    if (process.env.NODE_ENV !== 'development') {
      return { total: 0, recent: [] };
    }

    const recent = this.errorQueue.slice(-10);
    return {
      total: this.errorQueue.length,
      recent
    };
  }

  /**
   * 에러 큐 초기화
   */
  clearErrors(): void {
    this.errorQueue = [];
  }
}

// 전역 에러 핸들러 인스턴스
export const errorHandler = SecureErrorHandler.getInstance();

// 전역 에러 이벤트 리스너 설정
if (typeof window !== 'undefined') {
  window.addEventListener('error', (event) => {
    // 외부 스크립트 에러는 이미 layout.tsx에서 필터링됨
    // 애플리케이션 에러만 처리
    if (event.filename && event.filename.includes(window.location.hostname)) {
      errorHandler.logError(event.error || event.message, 'global_error');
    }
  });

  window.addEventListener('unhandledrejection', (event) => {
    errorHandler.logError(event.reason || 'Unhandled Promise Rejection', 'promise_rejection');
  });
}