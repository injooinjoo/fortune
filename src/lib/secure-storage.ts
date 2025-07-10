import { logger } from '@/lib/logger';

// 보안 강화된 로컬 스토리지 유틸리티
export class SecureStorage {
  private static readonly KEY_PREFIX = 'fortune_secure_';
  private static readonly MAX_AGE = 24 * 60 * 60 * 1000; // 24시간

  // 민감하지 않은 데이터만 저장 허용
  private static readonly ALLOWED_KEYS = [
    'userProfile',
    'recentFortunes',
    'theme',
    'language'
  ];

  // 민감한 필드 제거
  private static sanitizeUserProfile(profile: any) {
    if (!profile) return null;
    
    const {
      // 허용된 필드만 포함
      id,
      email,
      name,
      avatar_url,
      subscription_status,
      fortune_count,
      favorite_fortune_types,
      created_at
    } = profile;

    return {
      id: id ? String(id).substring(0, 8) + '...' : '', // ID는 일부만 저장
      email: email ? email.replace(/(.{2})(.*)(@.*)/, '$1***$3') : '', // 이메일 마스킹
      name,
      avatar_url,
      subscription_status,
      fortune_count,
      favorite_fortune_types,
      created_at
    };
  }

  static setItem(key: string, value: any): boolean {
    try {
      // 허용된 키인지 확인
      if (!this.ALLOWED_KEYS.includes(key)) {
        logger.warn(`SECURITY: 허용되지 않은 키입니다: ${key}`);
        return false;
      }

      let sanitizedValue = value;
      
      // 사용자 프로필인 경우 민감한 정보 제거
      if (key === 'userProfile') {
        sanitizedValue = this.sanitizeUserProfile(value);
      }

      const item = {
        value: sanitizedValue,
        timestamp: Date.now(),
        expires: Date.now() + this.MAX_AGE
      };

      localStorage.setItem(
        this.KEY_PREFIX + key,
        JSON.stringify(item)
      );
      
      return true;
    } catch (error) {
      logger.error('SecureStorage setItem failed:', error);
      return false;
    }
  }

  static getItem(key: string): any {
    try {
      if (!this.ALLOWED_KEYS.includes(key)) {
        return null;
      }

      const item = localStorage.getItem(this.KEY_PREFIX + key);
      if (!item) return null;

      const parsed = JSON.parse(item);
      
      // 만료 확인
      if (parsed.expires && Date.now() > parsed.expires) {
        this.removeItem(key);
        return null;
      }

      return parsed.value;
    } catch (error) {
      logger.error('SecureStorage getItem failed:', error);
      return null;
    }
  }

  static removeItem(key: string): void {
    try {
      localStorage.removeItem(this.KEY_PREFIX + key);
    } catch (error) {
      logger.error('SecureStorage removeItem failed:', error);
    }
  }

  static clear(): void {
    try {
      const keys = Object.keys(localStorage);
      keys.forEach(key => {
        if (key.startsWith(this.KEY_PREFIX)) {
          localStorage.removeItem(key);
        }
      });
    } catch (error) {
      logger.error('SecureStorage clear failed:', error);
    }
  }

  // 주기적으로 만료된 항목 정리
  static cleanup(): void {
    try {
      const keys = Object.keys(localStorage);
      keys.forEach(key => {
        if (key.startsWith(this.KEY_PREFIX)) {
          const item = localStorage.getItem(key);
          if (item) {
            try {
              const parsed = JSON.parse(item);
              if (parsed.expires && Date.now() > parsed.expires) {
                localStorage.removeItem(key);
              }
            } catch (e) {
              // 파싱 실패시 제거
              localStorage.removeItem(key);
            }
          }
        }
      });
    } catch (error) {
      logger.error('SecureStorage cleanup failed:', error);
    }
  }
}

// 페이지 로드시 자동 정리
if (typeof window !== 'undefined') {
  SecureStorage.cleanup();
}