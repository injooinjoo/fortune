'use client';

import React, { createContext, useContext, useEffect, useState, useRef } from 'react';
import { User } from '@supabase/supabase-js';
import { supabase } from '@/lib/supabase';

interface AuthContextType {
  user: User | null;
  session: any | null;
  isLoading: boolean;
  error: Error | null;
  refreshUser: () => Promise<void>;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [session, setSession] = useState<any | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);
  const isInitialized = useRef(false);
  const lastRefreshAt = useRef<number>(0);

  // 사용자 정보 새로고침
  const refreshUser = async () => {
    // 1초 내 중복 호출 방지
    const now = Date.now();
    if (now - lastRefreshAt.current < 1000) {
      return;
    }
    lastRefreshAt.current = now;

    try {
      const { data: { session }, error } = await supabase.auth.getSession();
      
      if (error) {
        // 세션이 없는 경우는 정상 상태로 처리
        if (error.message?.includes('session') || error.message?.includes('JWT')) {
          setUser(null);
          setSession(null);
          setError(null);
        } else {
          throw error;
        }
      } else {
        setUser(session?.user ?? null);
        setSession(session);
        setError(null);
      }
    } catch (err) {
      if (process.env.NODE_ENV === 'development') {
        console.error('Auth refresh error:', err);
      }
      setError(err instanceof Error ? err : new Error('Failed to refresh user'));
    }
  };

  useEffect(() => {
    // 초기화 중복 방지
    if (isInitialized.current) return;
    isInitialized.current = true;

    const initAuth = async () => {
      try {
        // 초기 세션 체크
        const { data: { session } } = await supabase.auth.getSession();
        setUser(session?.user ?? null);
        setSession(session);
      } catch (err) {
        if (process.env.NODE_ENV === 'development') {
          console.error('Initial auth check error:', err);
        }
        setError(err instanceof Error ? err : new Error('Failed to initialize auth'));
      } finally {
        setIsLoading(false);
      }
    };

    initAuth();

    // Auth 상태 변경 리스너 (한 번만 등록)
    const { data: { subscription } } = supabase.auth.onAuthStateChange(
      async (event, session) => {
        // 실제 변경사항이 있을 때만 업데이트
        const newUser = session?.user ?? null;
        const hasChanged = JSON.stringify(newUser?.id) !== JSON.stringify(user?.id);
        
        if (hasChanged) {
          setUser(newUser);
          setSession(session);
          setIsLoading(false);
          
          // 로그인/로그아웃 이벤트만 로그
          if (process.env.NODE_ENV === 'development' && 
              (event === 'SIGNED_IN' || event === 'SIGNED_OUT')) {
            console.log(`Auth event: ${event}`, newUser?.email);
          }
        }
      }
    );

    return () => {
      subscription.unsubscribe();
    };
  }, []); // 의존성 배열 비워두기

  return (
    <AuthContext.Provider value={{ user, session, isLoading, error, refreshUser }}>
      {children}
    </AuthContext.Provider>
  );
}

// Custom hook for using auth context
export function useAuth() {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
}

// useUser 훅과의 호환성을 위한 래퍼
export function useAuthUser() {
  const { user, isLoading, error } = useAuth();
  return {
    user,
    profile: null, // 프로필은 별도로 관리
    isLoading,
    error
  };
}