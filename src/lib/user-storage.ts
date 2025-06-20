export interface UserInfo {
  name: string;
  birthDate: string;
  birthTime?: string;
  gender?: string;
  mbti?: string;
  bloodType?: string;
  zodiacSign?: string;
  job?: string;
  location?: string;
}

export interface UserProfile {
  id: string;
  email: string;
  name: string;
  avatar_url?: string;
  provider: string;
  created_at: string;
  subscription_status: 'free' | 'premium' | 'premium_plus';
  fortune_count?: number;
  favorite_fortune_types?: string[];
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
    location: ''
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

// 로컬 스토리지에서 사용자 프로필 가져오기
export const getUserProfile = (): UserProfile | null => {
  try {
    const stored = localStorage.getItem('userProfile');
    if (stored) {
      return JSON.parse(stored);
    }
    return null;
  } catch (error) {
    console.error('사용자 프로필 로드 실패:', error);
    return null;
  }
};

// 로컬 스토리지에 사용자 프로필 저장
export const saveUserProfile = (profile: UserProfile): void => {
  try {
    localStorage.setItem('userProfile', JSON.stringify(profile));
  } catch (error) {
    console.error('사용자 프로필 저장 실패:', error);
  }
};

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