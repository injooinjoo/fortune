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
      console.error('Failed to initialize auth session:', error);
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
      console.error('Failed to clear expired sessions:', error);
      sessionStorage.removeItem(AUTH_SESSION_KEY);
    }
  }

  // PKCE 관련 데이터 정리
  static clearPKCEData(): void {
    try {
      // Supabase가 사용하는 모든 PKCE 관련 키 정리
      const keysToRemove = [
        'supabase.auth.token',
        'supabase.auth.refresh_token',
        'supabase.auth.code_verifier',
        'supabase.auth.state',
        'fortune-auth-token',
      ];

      // localStorage에서 PKCE 관련 데이터 삭제
      keysToRemove.forEach(key => {
        localStorage.removeItem(key);
      });

      // sessionStorage에서도 정리
      const sessionKeys = Object.keys(sessionStorage);
      sessionKeys.forEach(key => {
        if (key.includes('auth') || key.includes('pkce') || key.includes('supabase')) {
          sessionStorage.removeItem(key);
        }
      });

      // fortune-auth-token으로 시작하는 모든 키 정리
      Object.keys(localStorage).forEach(key => {
        if (key.startsWith('fortune-auth-token')) {
          localStorage.removeItem(key);
        }
      });

    } catch (error) {
      console.error('Failed to clear PKCE data:', error);
    }
  }

  // 전체 인증 스토리지 리셋
  static resetAuthStorage(): void {
    this.clearPKCEData();
    sessionStorage.removeItem(AUTH_SESSION_KEY);
    
    // 추가 정리
    try {
      // Supabase 관련 모든 스토리지 키 정리
      const allKeys = [...Object.keys(localStorage), ...Object.keys(sessionStorage)];
      allKeys.forEach(key => {
        if (
          key.includes('supabase') || 
          key.includes('auth') || 
          key.includes('pkce') ||
          key.includes('code_verifier') ||
          key.includes('state')
        ) {
          localStorage.removeItem(key);
          sessionStorage.removeItem(key);
        }
      });
    } catch (error) {
      console.error('Failed to reset auth storage:', error);
    }
  }

  // 인증 전 준비
  static prepareForAuth(): void {
    // 기존 세션 데이터 정리
    this.resetAuthStorage();
    
    // 새 세션 초기화
    this.initializeAuthSession();
    
    console.log('✅ Auth storage prepared for new authentication');
  }

  // 인증 후 정리
  static cleanupAfterAuth(): void {
    // 임시 세션 데이터만 정리 (토큰은 유지)
    sessionStorage.removeItem(AUTH_SESSION_KEY);
    
    // PKCE 관련 임시 데이터 정리
    const tempKeys = [
      'supabase.auth.code_verifier',
      'supabase.auth.state',
    ];
    
    tempKeys.forEach(key => {
      localStorage.removeItem(key);
      sessionStorage.removeItem(key);
    });
  }
}

export default AuthSessionManager;