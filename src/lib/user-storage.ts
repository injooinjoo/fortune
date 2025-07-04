import { supabase } from "./supabase";

export interface UserInfo {
  name: string;
  birthDate: string;
  birthTime?: string;
  gender?: string;
  mbti?: string;
  bloodType?: string;
  zodiacSign?: string;
  job?: string;
}

export interface UserProfile {
  id: string;
  name: string;
  email?: string;
  birth_date?: string;
  birth_time?: string;
  gender?: 'male' | 'female' | 'other';
  mbti?: string;
  onboarding_completed: boolean;
  [key: string]: any;
}

const USER_INFO_KEY = 'fortune_user_info';

// 사용자 정보 저장
export const saveUserInfo = (userInfo: Partial<UserInfo>): void => {
  try {
    const existingInfo = getUserInfo();
    const updatedInfo = { ...existingInfo, ...userInfo };
    localStorage.setItem(USER_INFO_KEY, JSON.stringify(updatedInfo));
  } catch (error) {
    console.error('사용자 정보 저장 실패:', error);
  }
};

// 사용자 정보 불러오기
export const getUserInfo = (): UserInfo => {
  try {
    const stored = localStorage.getItem(USER_INFO_KEY);
    if (stored) {
      return JSON.parse(stored);
    }
  } catch (error) {
    console.error('사용자 정보 불러오기 실패:', error);
  }
  
  return {
    name: '',
    birthDate: '',
    birthTime: '',
    gender: '',
    mbti: '',
    bloodType: '',
    zodiacSign: '',
    job: '',
  };
};

// 특정 필드만 불러오기
export const getUserField = (field: keyof UserInfo): string => {
  const userInfo = getUserInfo();
  return userInfo[field] || '';
};

// 사용자 정보 초기화
export const clearUserInfo = (): void => {
  try {
    localStorage.removeItem(USER_INFO_KEY);
  } catch (error) {
    console.error('사용자 정보 초기화 실패:', error);
  }
};

// 사용자 정보가 있는지 확인
export const hasUserInfo = (): boolean => {
  const userInfo = getUserInfo();
  return !!(userInfo.name && userInfo.birthDate);
};

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

// 사용자 프리미엄 상태 확인
export const isPremiumUser = (user?: UserProfile | null): boolean => {
  if (!user) return false;
  return user.subscription_status === 'premium' || user.subscription_status === 'premium_plus';
};

/**
 * 로컬 스토리지에서 사용자 프로필을 안전하게 가져옵니다.
 * 데이터가 없거나 형식이 잘못된 경우 null을 반환합니다.
 */
export function getUserProfile(): UserProfile | null {
  try {
    const userProfileJson = localStorage.getItem('userProfile');
    if (!userProfileJson) return null;

    const parsed = JSON.parse(userProfileJson);

    // 간단한 타입 가드: 필수 필드가 있는지 확인
    if (parsed && typeof parsed === 'object' && 'id' in parsed && 'name' in parsed && 'onboarding_completed' in parsed) {
       return parsed as UserProfile;
    }
    
    return null;
  } catch (error) {
    console.error("로컬 프로필 파싱 실패:", error);
    localStorage.removeItem('userProfile'); // 잘못된 데이터는 삭제
    return null;
  }
}

/**
 * 사용자 프로필을 로컬 스토리지에 저장합니다.
 */
export function saveUserProfile(profile: UserProfile | null) {
  if (profile) {
    localStorage.setItem('userProfile', JSON.stringify(profile));
  } else {
    localStorage.removeItem('userProfile');
  }
}

/**
 * DB에서 최신 프로필을 가져와 로컬 스토리지와 동기화하고, 최신 프로필을 반환합니다.
 */
export async function syncUserProfile(): Promise<UserProfile | null> {
  try {
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) {
      // 로그인하지 않은 경우, 로컬 프로필도 삭제하는 것이 안전합니다.
      saveUserProfile(null);
      return null;
    }

    const { data, error } = await supabase
      .from('user_profiles')
      .select('*')
      .eq('id', user.id)
      .single(); // 결과는 하나여야 하므로 single() 사용

    if (error) {
      if (error.code === 'PGRST116') { // 행이 없는 경우, 오류가 아님
        console.log('DB에 프로필이 아직 없습니다. 로컬 데이터를 사용합니다.');
        return getUserProfile();
      }
      // 그 외 실제 DB 오류
      console.error('DB에서 프로필 조회 실패:', error);
      return getUserProfile(); // DB 실패 시 일단 로컬 데이터 반환
    }

    if (data) {
       const dbProfile: UserProfile = {
        id: data.id,
        name: data.name,
        email: data.email,
        birth_date: data.birth_date,
        birth_time: data.birth_time,
        gender: data.gender,
        mbti: data.mbti,
        onboarding_completed: data.onboarding_completed || false,
      };
      saveUserProfile(dbProfile); // 최신 DB 데이터로 로컬 스토리지 덮어쓰기
      return dbProfile;
    }
    
    return getUserProfile(); // DB에 데이터가 없는 경우 로컬 데이터 반환
  } catch (err) {
    console.error('syncUserProfile 함수에서 예외 발생:', err);
    return getUserProfile(); // 모든 예외 발생 시 로컬 데이터 반환
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
  } catch (error) {
    console.error('일일 사용량 업데이트 실패:', error);
  }
};

/**
 * 온보딩 데이터를 기반으로 Supabase의 사용자 프로필을 업데이트합니다.
 */
export const updateUserProfileFromOnboarding = async (): Promise<{ success: boolean; error?: any }> => {
  try {
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) {
      // 로그인하지 않은 사용자는 DB 업데이트를 시도하지 않음
      return { success: true }; 
    }

    const userInfo = getUserInfo();
    const updateData: any = {};

    if (userInfo.name) updateData.full_name = userInfo.name;
    if (userInfo.birthDate) updateData.birth_date = userInfo.birthDate;
    if (userInfo.gender) updateData.gender = userInfo.gender;
    if (userInfo.mbti) updateData.mbti = userInfo.mbti;
    if (userInfo.birthTime) updateData.birth_time = userInfo.birthTime;
    if (userInfo.job) updateData.job = userInfo.job;
    if (userInfo.bloodType) updateData.blood_type = userInfo.bloodType;

    const { error } = await supabase.auth.updateUser({
      data: updateData
    });

    if (error) {
      console.error('DB 프로필 업데이트 실패:', error);
      return { success: false, error };
    }

    // 로컬 스토리지와도 동기화
    await syncUserProfile();

    return { success: true };
  } catch (error) {
    console.error('프로필 업데이트 중 예외 발생:', error);
    return { success: false, error };
  }
}; 