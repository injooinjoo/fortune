import { logger } from '@/lib/logger';

// 보안 유틸리티 함수들

export class SecurityUtils {
  // XSS 방지를 위한 HTML 이스케이프
  static escapeHtml(unsafe: string): string {
    if (typeof unsafe !== 'string') return '';
    
    return unsafe
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;")
      .replace(/'/g, "&#039;")
      .replace(/\//g, "&#x2F;");
  }

  // URL 파라미터 안전하게 추출
  static getSafeUrlParam(params: URLSearchParams, key: string): string | null {
    try {
      const value = params.get(key);
      if (!value) return null;
      
      // 기본 검증
      if (value.length > 200) return null; // 너무 긴 값 차단
      if (/<script|javascript:|data:|vbscript:/i.test(value)) return null; // 악성 스크립트 차단
      
      return this.escapeHtml(value);
    } catch (error) {
      logger.error('URL 파라미터 추출 실패:', error);
      return null;
    }
  }

  // 에러 메시지 안전하게 처리
  static getSafeErrorMessage(error: any): string {
    if (!error) return '알 수 없는 오류가 발생했습니다.';
    
    // 개발 환경에서만 상세 에러 표시
    if (process.env.NODE_ENV === 'development') {
      const message = error.message || error.toString();
      return this.escapeHtml(message);
    }
    
    // 프로덕션에서는 일반적인 메시지만
    const errorMap: Record<string, string> = {
      'network': '네트워크 연결을 확인해주세요.',
      'timeout': '요청 시간이 초과되었습니다.',
      'auth': '인증에 실패했습니다.',
      'permission': '권한이 없습니다.',
      'not_found': '요청한 리소스를 찾을 수 없습니다.',
      'server': '서버에 문제가 발생했습니다.',
    };

    const message = error.message || error.toString();
    
    // 일반적인 에러 타입 확인
    for (const [key, safeMessage] of Object.entries(errorMap)) {
      if (message.toLowerCase().includes(key)) {
        return safeMessage;
      }
    }
    
    return '일시적인 오류가 발생했습니다. 잠시 후 다시 시도해주세요.';
  }

  // 리다이렉트 URL 검증
  static getSafeRedirectUrl(url: string, allowedDomains: string[] = []): string {
    try {
      const parsedUrl = new URL(url, window.location.origin);
      
      // 프로토콜 검증
      if (!['http:', 'https:'].includes(parsedUrl.protocol)) {
        return '/';
      }
      
      // 도메인 검증
      const currentDomain = window.location.hostname;
      if (allowedDomains.length > 0) {
        const isAllowed = allowedDomains.some(domain => 
          parsedUrl.hostname === domain || parsedUrl.hostname.endsWith('.' + domain)
        );
        if (!isAllowed && parsedUrl.hostname !== currentDomain) {
          return '/';
        }
      } else if (parsedUrl.hostname !== currentDomain) {
        return '/';
      }
      
      // 경로 검증 (상대 경로만 허용)
      if (parsedUrl.origin === window.location.origin) {
        return parsedUrl.pathname + parsedUrl.search;
      }
      
      return '/';
    } catch (error) {
      logger.error('URL 검증 실패:', error);
      return '/';
    }
  }

  // 입력값 검증
  static validateInput(input: string, maxLength: number = 100, allowedChars?: RegExp): boolean {
    if (typeof input !== 'string') return false;
    if (input.length > maxLength) return false;
    if (allowedChars && !allowedChars.test(input)) return false;
    
    // 기본 XSS 패턴 검사
    const xssPatterns = [
      /<script/i,
      /javascript:/i,
      /vbscript:/i,
      /data:/i,
      /on\w+\s*=/i,
      /<iframe/i,
      /<object/i,
      /<embed/i,
    ];
    
    return !xssPatterns.some(pattern => pattern.test(input));
  }

  // 로그 정리 (민감한 정보 제거)
  static sanitizeLog(data: any): any {
    if (typeof data !== 'object' || data === null) {
      return data;
    }
    
    const sensitiveKeys = [
      'password', 'token', 'key', 'secret', 'auth', 'session',
      'email', 'phone', 'address', 'ssn', 'credit_card'
    ];
    
    const sanitized = { ...data };
    
    for (const key in sanitized) {
      if (sensitiveKeys.some(sensitive => key.toLowerCase().includes(sensitive))) {
        sanitized[key] = '[REDACTED]';
      } else if (typeof sanitized[key] === 'object') {
        sanitized[key] = this.sanitizeLog(sanitized[key]);
      }
    }
    
    return sanitized;
  }

  // 개발 환경에서만 로그 출력
  static secureLog(message: string, data?: any): void {
    if (process.env.NODE_ENV === 'development') {
      if (data) {
        logger.debug(message, this.sanitizeLog(data));
      } else {
        logger.debug(message);
      }
    }
  }
}