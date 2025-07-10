import { logger } from '@/lib/logger';
import { useState, useEffect } from 'react';
import { 
  getUserProfile, 
  syncUserProfile, 
  updateUserProfile as updateProfile,
  type UserProfile 
} from '@/lib/user-storage';

interface UseUserProfileResult {
  profile: UserProfile | null;
  isLoading: boolean;
  error: Error | null;
  updateUserProfile: (updates: Partial<UserProfile>) => Promise<UserProfile | null>;
  refreshProfile: () => Promise<void>;
  hasCompleteProfile: boolean;
}

export function useUserProfile(): UseUserProfileResult {
  const [profile, setProfile] = useState<UserProfile | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  const loadProfile = async () => {
    try {
      setIsLoading(true);
      setError(null);
      
      // 동기화된 프로필 가져오기
      const syncedProfile = await syncUserProfile();
      setProfile(syncedProfile);
    } catch (err) {
      logger.error('프로필 로드 실패:', err);
      setError(err instanceof Error ? err : new Error('프로필 로드 실패'));
      
      // 에러 발생 시 로컬 프로필 시도
      const localProfile = getUserProfile();
      if (localProfile) {
        setProfile(localProfile);
      }
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    loadProfile();
  }, []);

  const updateUserProfile = async (updates: Partial<UserProfile>): Promise<UserProfile | null> => {
    try {
      const updatedProfile = updateProfile(updates);
      if (updatedProfile) {
        setProfile(updatedProfile);
        
        // Supabase 동기화 시도 (백그라운드)
        syncUserProfile().catch(err => 
          logger.error('프로필 동기화 실패:', err)
        );
      }
      return updatedProfile;
    } catch (err) {
      logger.error('프로필 업데이트 실패:', err);
      setError(err instanceof Error ? err : new Error('프로필 업데이트 실패'));
      return null;
    }
  };

  const refreshProfile = async () => {
    await loadProfile();
  };

  // 프로필이 완전한지 확인 (운세 생성에 필요한 최소 정보)
  const hasCompleteProfile = !!(
    profile?.name && 
    profile?.birth_date &&
    profile?.onboarding_completed
  );

  return {
    profile,
    isLoading,
    error,
    updateUserProfile,
    refreshProfile,
    hasCompleteProfile,
  };
}

// 프로필의 특정 필드가 있는지 확인하는 헬퍼 함수들
export function hasUserName(profile: UserProfile | null): boolean {
  return !!(profile?.name && profile.name.trim() !== '');
}

export function hasUserBirthDate(profile: UserProfile | null): boolean {
  return !!(profile?.birth_date);
}

export function hasUserBirthTime(profile: UserProfile | null): boolean {
  return !!(profile?.birth_time && profile.birth_time !== '모름');
}

export function hasUserMBTI(profile: UserProfile | null): boolean {
  return !!(profile?.mbti && profile.mbti.length === 4);
}

export function hasUserGender(profile: UserProfile | null): boolean {
  return !!(profile?.gender);
}

export function hasUserBloodType(profile: UserProfile | null): boolean {
  return !!(profile?.blood_type);
}

export function hasUserJob(profile: UserProfile | null): boolean {
  return !!(profile?.job && profile.job.trim() !== '');
}

export function hasUserLocation(profile: UserProfile | null): boolean {
  return !!(profile?.location && profile.location.trim() !== '');
}