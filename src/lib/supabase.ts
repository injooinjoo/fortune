import { createClient } from '@supabase/supabase-js';
import AuthSessionManager from './auth-session-manager';

// 타입 정의
export interface UserProfile {
  id: string;
  email?: string;
  name: string;
  avatar_url?: string;
  birth_date?: string;
  birth_time?: string;
  gender?: 'male' | 'female' | 'other';
  mbti?: string;
  blood_type?: 'A' | 'B' | 'AB' | 'O';
  zodiac_sign?: string;
  chinese_zodiac?: string;
  job?: string;
  location?: string;
  subscription_status?: 'free' | 'premium' | 'enterprise';
  fortune_count?: number;
  favorite_fortune_types?: string[];
  onboarding_completed?: boolean;
  privacy_settings?: any;
  created_at?: string;
  updated_at?: string;
}


export interface FortuneCompletion {
  id?: string;
  user_id: string;
  fortune_type: string;
  started_at: string;
  completed_at?: string;
  duration_seconds?: number;
  user_satisfaction?: number;
  feedback?: string;
  created_date?: string;
  created_at?: string;
  updated_at?: string;
}

// 보안 강화된 로컬 스토리지 유틸리티
export class SecureStorage {
  private static readonly KEY_PREFIX = 'fortune_secure_';
  private static readonly MAX_AGE = 24 * 60 * 60 * 1000; // 24시간

  // 민감하지 않은 데이터만 저장 허용
  private static readonly ALLOWED_KEYS = [
    'userProfile',
    'recentFortunes',
    'theme',
    'preferences'
  ];

  // 키 검증
  private static isValidKey(key: string): boolean {
    return this.ALLOWED_KEYS.includes(key);
  }

  // 데이터 만료 확인
  private static isExpired(timestamp: number): boolean {
    return Date.now() - timestamp > this.MAX_AGE;
  }

  // 민감 데이터 마스킹
  private static sanitizeData(data: any): any {
    if (!data || typeof data !== 'object') return data;

    const sanitized = { ...data };
    
    // 이메일 마스킹
    if (sanitized.email) {
      const [localPart, domain] = sanitized.email.split('@');
      if (localPart && domain) {
        sanitized.email = localPart.slice(0, 2) + '***@' + domain;
      }
    }

    // ID 부분 마스킹
    if (sanitized.id && typeof sanitized.id === 'string') {
      sanitized.id = sanitized.id.slice(0, 8) + '***';
    }

    return sanitized;
  }

  // 안전한 데이터 저장
  static setItem(key: string, value: any): boolean {
    try {
      if (typeof window === 'undefined') {
        return false;
      }

      if (!this.isValidKey(key)) {
        console.warn(`SecureStorage: 허용되지 않은 키입니다: ${key}`);
        return false;
      }

      const data = {
        value: this.sanitizeData(value),
        timestamp: Date.now(),
        checksum: this.generateChecksum(value)
      };

      const encryptedData = this.encrypt(JSON.stringify(data));
      localStorage.setItem(this.KEY_PREFIX + key, encryptedData);
      
      // 만료된 데이터 정리
      this.cleanup();
      
      return true;
    } catch (error) {
      console.error('SecureStorage setItem 오류:', error);
      return false;
    }
  }

  // 안전한 데이터 조회
  static getItem(key: string): any {
    try {
      if (typeof window === 'undefined') {
        return null;
      }

      if (!this.isValidKey(key)) {
        console.warn(`SecureStorage: 허용되지 않은 키입니다: ${key}`);
        return null;
      }

      const encryptedData = localStorage.getItem(this.KEY_PREFIX + key);
      if (!encryptedData) return null;

      const decryptedData = this.decrypt(encryptedData);
      const data = JSON.parse(decryptedData);

      // 만료 확인
      if (this.isExpired(data.timestamp)) {
        this.removeItem(key);
        return null;
      }

      // 체크섬 검증
      if (!this.verifyChecksum(data.value, data.checksum)) {
        console.warn('SecureStorage: 데이터 무결성 검증 실패');
        this.removeItem(key);
        return null;
      }

      return data.value;
    } catch (error) {
      console.error('SecureStorage getItem 오류:', error);
      return null;
    }
  }

  // 데이터 삭제
  static removeItem(key: string): boolean {
    try {
      if (typeof window === 'undefined') {
        return false;
      }
      
      if (!this.isValidKey(key)) {
        return false;
      }
      localStorage.removeItem(this.KEY_PREFIX + key);
      return true;
    } catch (error) {
      console.error('SecureStorage removeItem 오류:', error);
      return false;
    }
  }

  // 만료된 데이터 정리
  private static cleanup(): void {
    try {
      if (typeof window === 'undefined') {
        return;
      }
      
      const keys = Object.keys(localStorage);
      keys.forEach(key => {
        if (key.startsWith(this.KEY_PREFIX)) {
          const rawKey = key.replace(this.KEY_PREFIX, '');
          this.getItem(rawKey); // 자동으로 만료된 항목 제거
        }
      });
    } catch (error) {
      console.error('SecureStorage cleanup 오류:', error);
    }
  }

  // 간단한 암호화 (실제 프로덕션에서는 더 강력한 암호화 사용)
  private static encrypt(data: string): string {
    return btoa(encodeURIComponent(data));
  }

  // 간단한 복호화
  private static decrypt(encryptedData: string): string {
    return decodeURIComponent(atob(encryptedData));
  }

  // 체크섬 생성
  private static generateChecksum(data: any): string {
    const str = JSON.stringify(data);
    let hash = 0;
    for (let i = 0; i < str.length; i++) {
      const char = str.charCodeAt(i);
      hash = ((hash << 5) - hash) + char;
      hash = hash & hash; // 32비트 정수로 변환
    }
    return hash.toString(36);
  }

  // 체크섬 검증
  private static verifyChecksum(data: any, expectedChecksum: string): boolean {
    return this.generateChecksum(data) === expectedChecksum;
  }
}

// Supabase 설정
const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!;
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!;

// 환경변수 검증
if (!supabaseUrl || !supabaseAnonKey) {
  throw new Error('⚠️ Supabase 환경변수가 설정되지 않았습니다. NEXT_PUBLIC_SUPABASE_URL과 NEXT_PUBLIC_SUPABASE_ANON_KEY를 확인해주세요.');
}

if (process.env.NODE_ENV === 'development') {
  console.log('🔧 Supabase configured successfully');
}

export const supabase = createClient(supabaseUrl, supabaseAnonKey, {
  auth: {
    autoRefreshToken: true,
    persistSession: true,
    detectSessionInUrl: true, // URL에서 세션 자동 감지 활성화
    flowType: 'pkce',
    debug: false, // 디버그 로그 비활성화 (GoTrueClient 무한 로그 방지)
    storage: typeof window !== 'undefined' ? window.localStorage : undefined,
    storageKey: 'fortune-auth-token', // 명시적인 storage key 설정
  }
});

// 로컬 모드 여부 확인 - 인증된 사용자는 Supabase 사용
const isDemoMode = async () => {
  try {
    // 인증된 사용자 확인
    const { data: { user } } = await supabase.auth.getUser();
    
    // 인증된 사용자가 있고 demo_mode가 명시적으로 설정되지 않은 경우 Supabase 사용
    if (user && localStorage.getItem('demo_mode') !== 'true') {
      return false; // Supabase 사용
    }
    
    // 게스트 사용자거나 demo_mode가 true인 경우 로컬 스토리지 사용
    return true;
  } catch (error) {
    console.error('Auth check error:', error);
    return true; // 에러 시 안전하게 로컬 모드 사용
  }
};

// 사용자 프로필 관리 함수들
export const userProfileService = {
  // 사용자 프로필 조회
  async getProfile(userId: string): Promise<UserProfile | null> {
    const isDemo = await isDemoMode();
    
    if (isDemo) {
      // 데모 모드: 로컬 스토리지에서 조회
      try {
        // 먼저 demo_profile 키로 시도
        let profile = localStorage.getItem(`demo_profile_${userId}`);
        if (profile) {
          return JSON.parse(profile);
        }
        
        // 기본 userProfile 키로 시도
        profile = localStorage.getItem('userProfile');
        if (profile) {
          const parsedProfile = JSON.parse(profile);
          if (parsedProfile.id === userId) {
            return parsedProfile;
          }
        }
        
        return null;
      } catch (error) {
        console.error('로컬 프로필 조회 오류:', error);
        return null;
      }
    }
    
    // 실제 모드: Supabase에서 조회
    try {
      const { data, error } = await supabase
        .from('user_profiles')
        .select('*')
        .eq('id', userId)
        .single();
      
      if (error) {
        console.error('Supabase 프로필 조회 오류:', error);
        return null;
      }
      
      return data;
    } catch (error) {
      console.error('프로필 조회 중 오류:', error);
      return null;
    }
  },

  // 사용자 프로필 생성/업데이트
  async upsertProfile(profile: Partial<UserProfile>): Promise<UserProfile | null> {
    const isDemo = await isDemoMode();
    
    if (isDemo) {
      // 데모 모드에서는 로컬 스토리지에 저장
      const updatedProfile = {
        ...profile,
        updated_at: new Date().toISOString()
      };
      localStorage.setItem(`demo_profile_${profile.id}`, JSON.stringify(updatedProfile));
      return updatedProfile as UserProfile;
    }

    const { data, error } = await supabase
      .from('user_profiles')
      .upsert(profile)
      .select()
      .single();

    if (error) {
      console.error('프로필 저장 오류:', error);
      return null;
    }

    return data;
  },

  // 온보딩 완료 표시
  async markOnboardingComplete(userId: string): Promise<boolean> {
    const isDemo = await isDemoMode();
    
    if (isDemo) {
      const profile = await this.getProfile(userId);
      if (profile) {
        profile.onboarding_completed = true;
        localStorage.setItem(`demo_profile_${userId}`, JSON.stringify(profile));
        return true;
      }
      return false;
    }

    const { error } = await supabase
      .from('user_profiles')
      .update({ onboarding_completed: true })
      .eq('id', userId);

    return !error;
  }
};


// 운세 완성 기록 관리 함수들
export const fortuneCompletionService = {
  // 운세 시작 기록
  async startFortune(userId: string, fortuneType: string): Promise<string | null> {
    const completion: Partial<FortuneCompletion> = {
      user_id: userId,
      fortune_type: fortuneType,
      started_at: new Date().toISOString(),
      created_date: new Date().toISOString().split('T')[0]
    };

    // 항상 로컬 스토리지 사용
    const id = `completion_${Date.now()}`;
    localStorage.setItem(`demo_completion_${id}`, JSON.stringify({ ...completion, id }));
    console.log('💾 운세 시작 기록을 로컬 스토리지에 저장했습니다.');
    return id;
  },

  // 운세 완성 기록
  async completeFortune(
    completionId: string, 
    satisfaction?: number, 
    feedback?: string
  ): Promise<boolean> {
    const updateData = {
      completed_at: new Date().toISOString(),
      user_satisfaction: satisfaction,
      feedback: feedback
    };

    // 항상 로컬 스토리지 사용
    try {
      const completion = localStorage.getItem(`demo_completion_${completionId}`);
      if (completion) {
        const updated = { ...JSON.parse(completion), ...updateData };
        localStorage.setItem(`demo_completion_${completionId}`, JSON.stringify(updated));
        console.log('💾 운세 완성 기록을 로컬 스토리지에 업데이트했습니다.');
        return true;
      }
      return false;
    } catch (error) {
      console.error('운세 완성 기록 오류:', error);
      return false;
    }
  },

  // 사용자의 운세 기록 조회
  async getUserFortuneHistory(userId: string, limit: number = 10): Promise<FortuneCompletion[]> {
    const isDemo = await isDemoMode();
    
    if (isDemo) {
      // 데모 모드에서는 로컬 스토리지에서 조회
      const keys = Object.keys(localStorage).filter(key => key.startsWith('demo_completion_'));
      const completions = keys
        .map(key => JSON.parse(localStorage.getItem(key) || '{}'))
        .filter(completion => completion.user_id === userId)
        .sort((a, b) => new Date(b.started_at).getTime() - new Date(a.started_at).getTime())
        .slice(0, limit);
      
      return completions;
    }

    const { data, error } = await supabase
      .from('fortune_completions')
      .select('*')
      .eq('user_id', userId)
      .order('started_at', { ascending: false })
      .limit(limit);

    if (error) {
      console.error('운세 기록 조회 오류:', error);
      return [];
    }

    return data;
  }
};

// 데모 세션 정리 함수
const clearDemoSession = () => {
  localStorage.removeItem('demo_session');
  localStorage.removeItem('guest_user_id');
  // 다른 데모 관련 로컬 스토리지 정리
  const keys = Object.keys(localStorage);
  keys.forEach(key => {
    if (key.startsWith('demo_')) {
      localStorage.removeItem(key);
    }
  });
};

// 호환성을 위한 auth 객체 (기존 코드와의 호환성 유지)
export const auth = {
  currentUser: null,
  signInWithGoogle: async () => {
    try {
      // 인증 전 스토리지 준비
      AuthSessionManager.prepareForAuth();
      clearDemoSession();
      
      // 현재 URL을 기반으로 올바른 콜백 URL 생성
      const origin = window.location.origin;
      const callbackUrl = `${origin}/auth/callback`;
      
      console.log('🚀 Starting Google OAuth with callback:', callbackUrl);
      
      // 실제 Supabase 구글 로그인
      const { data, error } = await supabase.auth.signInWithOAuth({
        provider: 'google',
        options: {
          redirectTo: callbackUrl,
          queryParams: {
            access_type: 'offline',
            prompt: 'select_account',
          },
          skipBrowserRedirect: false,
          // PKCE 관련 추가 옵션
          scopes: 'email profile'
        }
      });
      
      if (error) {
        console.error('🚨 Google 로그인 실패:', error);
        AuthSessionManager.resetAuthStorage(); // 실패 시 정리
        return { error };
      }
      
      console.log('✅ Google OAuth initiated successfully');
      return { data, error: null };
    } catch (error) {
      console.error('🚨 Google 로그인 예외:', error);
      AuthSessionManager.resetAuthStorage(); // 예외 시 정리
      return { error };
    }
  },
  signOut: () => {
    clearDemoSession();
    return supabase.auth.signOut();
  },
  onAuthStateChanged: (callback: (user: any) => void) => {
    const { data: { subscription } } = supabase.auth.onAuthStateChange(async (event, session) => {
      // 로그인/로그아웃 이벤트만 로그 (디버그 모드 비활성화 상태에서도 최소한의 로그)
      if (process.env.NODE_ENV === 'development' && 
          (event === 'SIGNED_IN' || event === 'SIGNED_OUT')) {
        console.log(`Auth event: ${event}`);
      }
      
      try {
        const user = session?.user || null;
        callback(user);
      } catch (error) {
        // 에러는 조용히 처리
      }
    });
    
    return { data: { subscription } };
  },
  getSession: async () => {
    try {
      const { data, error } = await supabase.auth.getSession();
      
      if (error) {
        // 세션 관련 에러는 조용히 처리
        return { data: { session: null }, error };
      }
      return { data, error: null };
    } catch (error) {
      // 예외도 조용히 처리
      return { data: { session: null }, error };
    }
  },
} as any;

// 기존 db 객체 호환성
export const db = supabase;
