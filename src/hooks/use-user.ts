import { useUserProfile } from './use-user-profile';
import { useAuth } from '@/contexts/auth-context';

interface UseUserResult {
  user: any | null;
  profile: any | null;
  isLoading: boolean;
  error: Error | null;
}

export function useUser(): UseUserResult {
  // AuthContext에서 사용자 정보 가져오기
  const { user, isLoading: authLoading, error: authError } = useAuth();
  
  // 프로필 정보는 기존대로 유지
  const { profile, isLoading: profileLoading, error: profileError } = useUserProfile();

  return {
    user,
    profile,
    isLoading: authLoading || profileLoading,
    error: authError || profileError
  };
}