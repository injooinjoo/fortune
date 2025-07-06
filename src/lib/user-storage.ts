// User storage utilities for local and Supabase data management

// 데이터 유효성 검사 함수들
export const validateUserProfile = (profile: any): { isValid: boolean; errors: string[] } => {
  const errors: string[] = [];
  
  if (!profile) {
    errors.push('프로필이 비어있습니다.');
    return { isValid: false, errors };
  }
  
  if (!profile.id) errors.push('ID가 누락되었습니다.');
  if (!profile.name || profile.name.trim() === '') errors.push('이름이 누락되었습니다.');
  if (typeof profile.onboarding_completed !== 'boolean') errors.push('온보딩 완료 상태가 올바르지 않습니다.');
  
  // 생년월일 검증
  if (profile.birth_date) {
    const dateRegex = /^\d{4}-\d{2}-\d{2}$/;
    if (!dateRegex.test(profile.birth_date)) {
      errors.push('생년월일 형식이 올바르지 않습니다 (YYYY-MM-DD).');
    } else {
      const date = new Date(profile.birth_date);
      if (isNaN(date.getTime())) {
        errors.push('생년월일이 유효하지 않습니다.');
      }
    }
  }
  
  // MBTI 검증
  if (profile.mbti && profile.mbti.length !== 4) {
    errors.push('MBTI는 4자리여야 합니다.');
  }
  
  // 이메일 검증
  if (profile.email) {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(profile.email)) {
      errors.push('이메일 형식이 올바르지 않습니다.');
    }
  }
  
  return { isValid: errors.length === 0, errors };
};

// 데이터 마이그레이션 함수 (구버전 -> 신버전)
export const migrateUserProfile = (profile: any): UserProfile | null => {
  if (!profile) return null;
  
  try {
    // 구버전 필드명 변환
    const migrated: UserProfile = {
      id: profile.id || `migrated_${Date.now()}`,
      name: profile.name || '',
      email: profile.email || '',
      birth_date: profile.birth_date || profile.birthDate || profile.birthdate || '',
      birth_time: profile.birth_time || profile.birthTime || '',
      gender: profile.gender as 'male' | 'female' | 'other' | undefined,
      mbti: profile.mbti || '',
      blood_type: profile.blood_type || profile.bloodType as 'A' | 'B' | 'AB' | 'O' | undefined,
      zodiac_sign: profile.zodiac_sign || profile.zodiacSign || '',
      chinese_zodiac: profile.chinese_zodiac || profile.chineseZodiac || '',
      job: profile.job || '',
      location: profile.location || '',
      subscription_status: profile.subscription_status || 'free',
      fortune_count: profile.fortune_count || profile.fortuneCount || 0,
      favorite_fortune_types: profile.favorite_fortune_types || profile.favoriteFortuneTypes || [],
      onboarding_completed: profile.onboarding_completed ?? false,
      privacy_settings: profile.privacy_settings || {
        show_profile: true,
        share_fortune: false,
        email_notifications: true
      },
      created_at: profile.created_at || profile.createdAt || new Date().toISOString(),
      updated_at: new Date().toISOString()
    };
    
    // 별자리와 띠 자동 계산
    if (migrated.birth_date) {
      migrated.zodiac_sign = migrated.zodiac_sign || getZodiacSign(migrated.birth_date);
      migrated.chinese_zodiac = migrated.chinese_zodiac || getChineseZodiac(migrated.birth_date);
    }
    
    return migrated;
  } catch (error) {
    console.error('프로필 마이그레이션 실패:', error);
    return null;
  }
};

export interface UserProfile {
  id: string;
  name: string;
  email?: string;
  avatar_url?: string;
  birth_date?: string;
  birth_time?: string;
  birth_hour?: string;
  gender?: 'male' | 'female' | 'other';
  mbti?: string;
  blood_type?: 'A' | 'B' | 'AB' | 'O';
  zodiac_sign?: string;
  chinese_zodiac?: string;
  job?: string;
  location?: string;
  subscription_status?: 'free' | 'premium' | 'premium_plus' | 'enterprise';
  fortune_count?: number;
  premium_fortunes_count?: number;
  favorite_fortune_types?: string[];
  onboarding_completed: boolean;
  privacy_settings?: {
    show_profile: boolean;
    share_fortune: boolean;
    email_notifications: boolean;
  };
  created_at?: string;
  updated_at?: string;
}

// 생년월일에서 나이 계산
export const calculateAge = (birthDate: string): number => {
  if (!birthDate) return 0;
  
  const today = new Date();
  const birth = new Date(birthDate);
  let age = today.getFullYear() - birth.getFullYear();
  const monthDiff = today.getMonth() - birth.getMonth();
  
  if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birth.getDate())) {
    age--;
  }
  
  return age;
};

// 생년월일에서 별자리 계산
export const getZodiacSign = (birthDate: string): string => {
  if (!birthDate) return '';
  
  const date = new Date(birthDate);
  const month = date.getMonth() + 1;
  const day = date.getDate();
  
  if ((month === 3 && day >= 21) || (month === 4 && day <= 19)) return '양자리';
  if ((month === 4 && day >= 20) || (month === 5 && day <= 20)) return '황소자리';
  if ((month === 5 && day >= 21) || (month === 6 && day <= 20)) return '쌍둥이자리';
  if ((month === 6 && day >= 21) || (month === 7 && day <= 22)) return '게자리';
  if ((month === 7 && day >= 23) || (month === 8 && day <= 22)) return '사자자리';
  if ((month === 8 && day >= 23) || (month === 9 && day <= 22)) return '처녀자리';
  if ((month === 9 && day >= 23) || (month === 10 && day <= 22)) return '천칭자리';
  if ((month === 10 && day >= 23) || (month === 11 && day <= 21)) return '전갈자리';
  if ((month === 11 && day >= 22) || (month === 12 && day <= 21)) return '사수자리';
  if ((month === 12 && day >= 22) || (month === 1 && day <= 19)) return '염소자리';
  if ((month === 1 && day >= 20) || (month === 2 && day <= 18)) return '물병자리';
  if ((month === 2 && day >= 19) || (month === 3 && day <= 20)) return '물고기자리';
  
  return '';
};

// 생년월일에서 띠 계산
export const getChineseZodiac = (birthDate: string): string => {
  if (!birthDate) return '';
  
  const year = new Date(birthDate).getFullYear();
  const animals = ['원숭이', '닭', '개', '돼지', '쥐', '소', '호랑이', '토끼', '용', '뱀', '말', '양'];
  return animals[year % 12];
};


/**
 * 로컬 스토리지에서 사용자 프로필을 안전하게 가져옵니다.
 * 데이터 검증 및 마이그레이션을 포함합니다.
 */
export function getUserProfile(): UserProfile | null {
  try {
    const userProfileJson = localStorage.getItem('userProfile');
    if (!userProfileJson) return null;

    const parsed = JSON.parse(userProfileJson);

    // 데이터 마이그레이션 시도
    const migrated = migrateUserProfile(parsed);
    if (!migrated) {
      console.warn('프로필 마이그레이션 실패, 데이터 삭제');
      localStorage.removeItem('userProfile');
      return null;
    }
    
    // 데이터 검증
    const validation = validateUserProfile(migrated);
    if (!validation.isValid) {
      console.warn('프로필 검증 실패:', validation.errors);
      // 심각한 오류가 아니면 수정된 데이터 사용
      const criticalErrors = validation.errors.filter(err => 
        err.includes('ID가 누락') || err.includes('온보딩 완료 상태')
      );
      
      if (criticalErrors.length > 0) {
        localStorage.removeItem('userProfile');
        return null;
      }
    }
    
    // 마이그레이션된 데이터가 원본과 다르면 저장
    if (JSON.stringify(parsed) !== JSON.stringify(migrated)) {
      console.log('프로필 데이터 마이그레이션 완료');
      localStorage.setItem('userProfile', JSON.stringify(migrated));
    }
    
    return migrated;
  } catch (error) {
    console.error("로컬 프로필 파싱 실패:", error);
    localStorage.removeItem('userProfile');
    return null;
  }
}

/**
 * 사용자 프로필을 로컬 스토리지에 저장합니다.
 * 저장 전 데이터 검증을 수행합니다.
 */
export function saveUserProfile(profile: UserProfile | null) {
  if (profile) {
    // 데이터 검증
    const validation = validateUserProfile(profile);
    if (!validation.isValid) {
      console.error('프로필 저장 실패 - 검증 오류:', validation.errors);
      throw new Error(`프로필 검증 실패: ${validation.errors.join(', ')}`);
    }
    
    // 타임스탬프 업데이트
    const profileToSave = {
      ...profile,
      updated_at: new Date().toISOString()
    };
    
    localStorage.setItem('userProfile', JSON.stringify(profileToSave));
    console.log('💾 프로필 저장 완료:', profileToSave.name);
  } else {
    localStorage.removeItem('userProfile');
    console.log('💾 프로필 삭제 완료');
  }
}

/**
 * 로컬 스토리지와 Supabase 간 사용자 프로필을 동기화합니다.
 * Supabase가 우선이며, 실패 시 로컬 스토리지를 사용합니다.
 */
export async function syncUserProfile(): Promise<UserProfile | null> {
  try {
    // 1. 로컬 프로필 확인
    const localProfile = getUserProfile();
    
    // 2. Supabase 세션 확인 시도
    try {
      const { supabase, userProfileService } = await import('@/lib/supabase');
      const { data: sessionData } = await supabase.auth.getSession();
      
      if (sessionData?.session?.user) {
        console.log('🔄 Supabase 세션 확인, 프로필 동기화 시작');
        
        // 3. Supabase에서 프로필 가져오기
        const supabaseProfile = await userProfileService.getProfile(sessionData.session.user.id);
        
        if (supabaseProfile) {
          // 4. Supabase 프로필이 있으면 로컬에 동기화
          const mergedProfile = {
            ...localProfile,
            ...supabaseProfile,
            updated_at: new Date().toISOString()
          };
          
          saveUserProfile(mergedProfile);
          console.log('✅ Supabase → 로컬 동기화 완료');
          return mergedProfile;
        } else if (localProfile && localProfile.onboarding_completed) {
          // 5. Supabase에 프로필이 없지만 로컬에 있으면 업로드
          await userProfileService.upsertProfile({
            id: sessionData.session.user.id,
            email: sessionData.session.user.email || '',
            name: localProfile.name,
            birth_date: localProfile.birth_date,
            birth_time: localProfile.birth_time,
            mbti: localProfile.mbti,
            gender: localProfile.gender,
            onboarding_completed: localProfile.onboarding_completed
          });
          
          console.log('✅ 로컬 → Supabase 동기화 완료');
          return localProfile;
        }
      }
    } catch (supabaseError) {
      console.log('🔐 게스트 사용자 또는 Supabase 연결 실패:', supabaseError);
    }
    
    // 6. Supabase 사용 불가 시 로컬 프로필 반환
    if (localProfile) {
      console.log('💾 로컬 프로필 사용 (게스트 모드)');
      return localProfile;
    }
    
    console.log('❌ 프로필 없음');
    return null;
    
  } catch (err) {
    console.error('syncUserProfile 함수에서 예외 발생:', err);
    return getUserProfile();
  }
}

// 사용자 운세 조회 횟수 증가
export const incrementFortuneCount = (): void => {
  try {
    const profile = getUserProfile();
    if (profile) {
      profile.fortune_count = (profile.fortune_count || 0) + 1;
      saveUserProfile(profile);
    }
  } catch (error) {
    console.error('운세 조회 횟수 업데이트 실패:', error);
  }
};

// 무료 사용자 일일 제한 확인
export const checkDailyLimit = (): { canUse: boolean; remaining: number } => {
  try {
    const today = new Date().toDateString();
    const dailyUsage = localStorage.getItem('dailyFortuneUsage');
    
    if (dailyUsage) {
      const usage = JSON.parse(dailyUsage);
      if (usage.date === today) {
        const remaining = Math.max(0, 3 - usage.count);
        return { canUse: remaining > 0, remaining };
      }
    }
    
    // 새로운 날이거나 첫 사용
    return { canUse: true, remaining: 3 };
  } catch (error) {
    console.error('일일 제한 확인 실패:', error);
    return { canUse: true, remaining: 3 };
  }
};

// 무료 사용자 일일 사용량 증가
export const incrementDailyUsage = (): void => {
  try {
    const today = new Date().toDateString();
    const dailyUsage = localStorage.getItem('dailyFortuneUsage');
    
    let usage = { date: today, count: 0 };
    if (dailyUsage) {
      const parsed = JSON.parse(dailyUsage);
      if (parsed.date === today) {
        usage = parsed;
      }
    }
    
    usage.count += 1;
    localStorage.setItem('dailyFortuneUsage', JSON.stringify(usage));
    
    // 전체 사용량도 업데이트
    incrementFortuneCount();
  } catch (error) {
    console.error('일일 사용량 업데이트 실패:', error);
  }
};

/**
 * 애플리케이션 시작 시 데이터 검사 및 정리
 */
export const initializeUserData = (): void => {
  try {
    // 데이터 일관성 검사
    const consistencyCheck = checkAndFixDataConsistency();
    if (consistencyCheck.issues.length > 0) {
      console.log('🔧 데이터 일관성 문제 발견:', consistencyCheck.issues);
    }
    
    // 오래된 임시 데이터 정리 (30일 이상)
    const keys = Object.keys(localStorage);
    const now = Date.now();
    const thirtyDaysAgo = now - (30 * 24 * 60 * 60 * 1000);
    
    keys.forEach(key => {
      if (key.startsWith('temp_') || key.startsWith('guest_')) {
        try {
          const data = JSON.parse(localStorage.getItem(key) || '{}');
          const createdAt = data.created_at ? new Date(data.created_at).getTime() : 0;
          
          if (createdAt < thirtyDaysAgo) {
            localStorage.removeItem(key);
            console.log('🗑️ 오래된 임시 데이터 삭제:', key);
          }
        } catch {
          // 파싱 실패하면 삭제
          localStorage.removeItem(key);
        }
      }
    });
    
    console.log('✅ 사용자 데이터 초기화 완료');
  } catch (error) {
    console.error('사용자 데이터 초기화 실패:', error);
  }
};

// 구대 getUserInfo 호환성을 위한 새로운 함수
export const hasUserProfile = (): boolean => {
  const profile = getUserProfile();
  return !!(profile && profile.name && profile.birth_date && profile.onboarding_completed);
};

// 전체 사용자 데이터 초기화
export const clearAllUserData = (): void => {
  try {
    const keysToRemove = [
      'userProfile',
      'dailyFortuneUsage',
      'fortune_cache',
      'app_settings'
    ];
    
    keysToRemove.forEach(key => {
      localStorage.removeItem(key);
    });
    
    // 임시 데이터도 모두 삭제
    const allKeys = Object.keys(localStorage);
    allKeys.forEach(key => {
      if (key.startsWith('temp_') || key.startsWith('guest_') || key.startsWith('fortune_')) {
        localStorage.removeItem(key);
      }
    });
    
    console.log('💾 모든 사용자 데이터가 삭제되었습니다.');
  } catch (error) {
    console.error('사용자 데이터 삭제 실패:', error);
  }
};

/**
 * 빈 사용자 프로필 템플릿 생성
 */
export const createEmptyUserProfile = (id?: string, email?: string): UserProfile => {
  return {
    id: id || `guest_${Date.now()}`,
    name: '',
    email: email || '',
    birth_date: '',
    birth_time: '',
    gender: undefined,
    mbti: '',
    blood_type: undefined,
    zodiac_sign: '',
    chinese_zodiac: '',
    job: '',
    location: '',
    subscription_status: 'free',
    fortune_count: 0,
    favorite_fortune_types: [],
    onboarding_completed: false,
    privacy_settings: {
      show_profile: true,
      share_fortune: false,
      email_notifications: true
    },
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString()
  };
};

/**
 * 사용자 프로필 업데이트 (기존 데이터와 병합)
 * 자동으로 별자리와 띠를 재계산합니다.
 */
export const updateUserProfile = (updates: Partial<UserProfile>): UserProfile | null => {
  try {
    const currentProfile = getUserProfile();
    
    if (!currentProfile) {
      // 프로필이 없으면 새로 생성
      const newProfile = createEmptyUserProfile(updates.id, updates.email);
      const updatedProfile = { ...newProfile, ...updates };
      
      // 별자리와 띠 자동 계산
      if (updatedProfile.birth_date) {
        updatedProfile.zodiac_sign = getZodiacSign(updatedProfile.birth_date);
        updatedProfile.chinese_zodiac = getChineseZodiac(updatedProfile.birth_date);
      }
      
      saveUserProfile(updatedProfile);
      return updatedProfile;
    }
    
    // 기존 프로필 업데이트
    const updatedProfile: UserProfile = {
      ...currentProfile,
      ...updates,
      updated_at: new Date().toISOString()
    };
    
    // 생년월일이 변경되면 별자리와 띠 재계산
    if (updates.birth_date && updates.birth_date !== currentProfile.birth_date) {
      updatedProfile.zodiac_sign = getZodiacSign(updates.birth_date);
      updatedProfile.chinese_zodiac = getChineseZodiac(updates.birth_date);
    }
    
    saveUserProfile(updatedProfile);
    return updatedProfile;
  } catch (error) {
    console.error('프로필 업데이트 실패:', error);
    return null;
  }
};

/**
 * 데이터 일관성 검사 및 복구
 */
export const checkAndFixDataConsistency = (): { fixed: boolean; issues: string[] } => {
  const issues: string[] = [];
  let fixed = false;
  
  try {
    const profile = getUserProfile();
    if (!profile) {
      return { fixed: false, issues: ['프로필이 존재하지 않습니다.'] };
    }
    
    let needsUpdate = false;
    const updatedProfile = { ...profile };
    
    // 별자리 재계산
    if (profile.birth_date) {
      const correctZodiac = getZodiacSign(profile.birth_date);
      if (profile.zodiac_sign !== correctZodiac) {
        updatedProfile.zodiac_sign = correctZodiac;
        issues.push(`별자리 수정: ${profile.zodiac_sign} → ${correctZodiac}`);
        needsUpdate = true;
      }
      
      const correctChinese = getChineseZodiac(profile.birth_date);
      if (profile.chinese_zodiac !== correctChinese) {
        updatedProfile.chinese_zodiac = correctChinese;
        issues.push(`띠 수정: ${profile.chinese_zodiac} → ${correctChinese}`);
        needsUpdate = true;
      }
    }
    
    // MBTI 대문자 변환
    if (profile.mbti && profile.mbti !== profile.mbti.toUpperCase()) {
      updatedProfile.mbti = profile.mbti.toUpperCase();
      issues.push(`MBTI 대문자 변환: ${profile.mbti} → ${updatedProfile.mbti}`);
      needsUpdate = true;
    }
    
    // 기본 설정 추가
    if (!profile.privacy_settings) {
      updatedProfile.privacy_settings = {
        show_profile: true,
        share_fortune: false,
        email_notifications: true
      };
      issues.push('기본 개인정보 설정 추가');
      needsUpdate = true;
    }
    
    if (needsUpdate) {
      saveUserProfile(updatedProfile);
      fixed = true;
      console.log('💡 데이터 일관성 문제 수정 완료');
    }
    
    return { fixed, issues };
  } catch (error) {
    console.error('데이터 일관성 검사 실패:', error);
    return { fixed: false, issues: ['일관성 검사 중 오류 발생'] };
  }
};

/**
 * 게스트 사용자인지 확인합니다.
 * 게스트 사용자는 이메일이 없거나 id가 'guest_'로 시작합니다.
 */
export const isGuestUser = (profile: UserProfile | null): boolean => {
  if (!profile) return true;
  return !profile.email || profile.id.startsWith('guest_');
};

/**
 * 프리미엄 사용자인지 확인합니다.
 */
export const isPremiumUser = (profile: UserProfile | null): boolean => {
  if (!profile) return false;
  return profile.subscription_status === 'premium' || profile.subscription_status === 'premium_plus';
}; 