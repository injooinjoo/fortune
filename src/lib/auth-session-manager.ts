import { logger } from '@/lib/logger';

// Auth Session Manager - PKCE 및 세션 관리 유틸리티

interface AuthSession {
  codeVerifier?: string;
  state?: string;
  timestamp: number;
}

const SESSION_TIMEOUT = 10 * 60 * 1000; // 10분
const AUTH_SESSION_KEY = 'fortune_auth_session';

export class AuthSessionManager {
  // 인증 세션 초기화 및 정리
  static initializeAuthSession(): void {
    this.clearExpiredSessions();
    
    // 새 세션 데이터 생성
    const session: AuthSession = {
      timestamp: Date.now()
    };
    
    try {
      sessionStorage.setItem(AUTH_SESSION_KEY, JSON.stringify(session));
    } catch (error) {
      logger.error('Failed to initialize auth session:', error);
    }
  }

  // 만료된 세션 정리
  static clearExpiredSessions(): void {
    try {
      const stored = sessionStorage.getItem(AUTH_SESSION_KEY);
      if (stored) {
        const session: AuthSession = JSON.parse(stored);
        if (Date.now() - session.timestamp > SESSION_TIMEOUT) {
          sessionStorage.removeItem(AUTH_SESSION_KEY);
        }
      }
    } catch (error) {
      logger.error('Failed to clear expired sessions:', error);
      sessionStorage.removeItem(AUTH_SESSION_KEY);
    }
  }

  // PKCE 관련 데이터 정리 (토큰과 세션은 유지)
  static clearPKCEData(): void {
    try {
      // 인증 완료 후에만 정리해야 할 임시 데이터
      const tempKeysToRemove = [
        'supabase.auth.state',
        // code_verifier는 OAuth 콜백 처리 중에 필요하므로 제거하지 않음
        // Supabase가 자동으로 처리 후 제거함
      ];

      // 임시 데이터만 정리
      tempKeysToRemove.forEach(key => {
        localStorage.removeItem(key);
      });

      // sessionStorage의 임시 데이터만 정리
      const sessionKeys = Object.keys(sessionStorage);
      sessionKeys.forEach(key => {
        if (key.includes('state') && !key.includes('token')) {
          sessionStorage.removeItem(key);
        }
      });

    } catch (error) {
      logger.error('Failed to clear PKCE data:', error);
    }
  }

  // 전체 인증 스토리지 리셋 (실패한 인증 시도 후에만 사용)
  static resetAuthStorage(): void {
    sessionStorage.removeItem(AUTH_SESSION_KEY);
    
    // 추가 정리
    try {
      // 실패한 인증 관련 데이터만 정리
      const keysToClean = [
        'supabase.auth.state',
        // code_verifier는 Supabase의 기본 키 패턴으로도 저장될 수 있음
        // 실패 시에만 정리하되, 모든 가능한 패턴을 확인
      ];
      
      // localStorage의 모든 키를 확인하여 PKCE 관련 키 찾기
      const allKeys = Object.keys(localStorage);
      allKeys.forEach(key => {
        // Supabase의 기본 auth 키 패턴 확인
        if (key.startsWith('sb-') && key.includes('auth-token')) {
          try {
            const value = localStorage.getItem(key);
            if (value) {
              const parsed = JSON.parse(value);
              // 만료된 세션이나 code_verifier만 있는 경우 정리
              if (!parsed.access_token && !parsed.refresh_token) {
                keysToClean.push(key);
              }
            }
          } catch {
            // JSON 파싱 실패 시 무시
          }
        }
      });
      
      keysToClean.forEach(key => {
        localStorage.removeItem(key);
        sessionStorage.removeItem(key);
      });
      
      logger.debug('✅ Auth storage reset completed (failed auth cleanup)');
    } catch (error) {
      logger.error('Failed to reset auth storage:', error);
    }
  }

  // 인증 전 준비
  static prepareForAuth(): void {
    // 만료된 세션만 정리 (code_verifier는 유지)
    this.clearExpiredSessions();
    
    // 새 세션 초기화
    this.initializeAuthSession();
    
    // PKCE code_verifier는 절대 삭제하지 않음 - Supabase가 자동 관리
    logger.debug('✅ Auth storage prepared for new authentication');
  }

  // 인증 후 정리
  static cleanupAfterAuth(): void {
    // 임시 세션 데이터만 정리 (토큰은 유지)
    sessionStorage.removeItem(AUTH_SESSION_KEY);
    
    // state만 정리 (code_verifier는 Supabase가 자동으로 관리)
    // 인증 성공 후에도 code_verifier를 삭제하지 않음
    const tempKeys = [
      'supabase.auth.state',
    ];
    
    tempKeys.forEach(key => {
      localStorage.removeItem(key);
      sessionStorage.removeItem(key);
    });
    
    logger.debug('✅ Post-auth cleanup completed (keeping PKCE data)');
  }
}

export default AuthSessionManager;