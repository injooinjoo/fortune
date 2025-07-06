import { useUserProfile } from './use-user-profile';
import { useEffect, useState } from 'react';
import { supabase } from '@/lib/supabase';
import { User } from '@supabase/supabase-js';

interface UseUserResult {
  user: User | null;
  profile: any | null;
  isLoading: boolean;
  error: Error | null;
}

export function useUser(): UseUserResult {
  const { profile, isLoading: profileLoading, error: profileError } = useUserProfile();
  const [user, setUser] = useState<User | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    const getUser = async () => {
      try {
        const { data: { user }, error } = await supabase.auth.getUser();
        if (error) throw error;
        setUser(user);
      } catch (err) {
        console.error('Failed to get user:', err);
        setError(err instanceof Error ? err : new Error('Failed to get user'));
      } finally {
        setIsLoading(false);
      }
    };

    getUser();

    // Listen for auth changes
    const { data: { subscription } } = supabase.auth.onAuthStateChange((_event, session) => {
      setUser(session?.user ?? null);
    });

    return () => subscription.unsubscribe();
  }, []);

  return {
    user,
    profile,
    isLoading: isLoading || profileLoading,
    error: error || profileError
  };
}