"use client";

import { useEffect, useState } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import { supabase } from '@/lib/supabase';
import { SecureStorage } from '@/lib/secure-storage';

export default function AuthCallbackPage() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const [isProcessing, setIsProcessing] = useState(true);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);

  useEffect(() => {
    let isMounted = true;
    let authSubscription: any = null;
    let timeoutId: NodeJS.Timeout;
    
    if (process.env.NODE_ENV === 'development') {
      console.log('Auth callback started...');
    }

    // 사용자 프로필 저장 함수
    const saveUserProfile = async (user: any) => {
      const userProfile = {
        id: user.id,
        email: user.email || '',
        name: user.user_metadata?.full_name || 
              user.user_metadata?.name || 
              user.email?.split('@')[0] || '사용자',
        avatar_url: user.user_metadata?.avatar_url || 
                   user.user_metadata?.picture,
        provider: user.app_metadata?.provider || 'google',
        created_at: user.created_at,
        subscription_status: 'free' as const,
        fortune_count: 0,
        favorite_fortune_types: []
      };
      
      SecureStorage.setItem("userProfile", userProfile);
      
      if (process.env.NODE_ENV === 'development') {
        console.log('User profile saved securely');
      }
    };

    // 실시간 인증 상태 변화 감지 설정
    const { data } = supabase.auth.onAuthStateChange(async (event, session) => {
      if (!isMounted) return;
      
      if (process.env.NODE_ENV === 'development') {
        console.log('Auth state change in callback:', event, 
          session?.user?.email ? session.user.email.replace(/(.{3}).*@/, '$1...@') : 'no email');
      }
      
      if (event === 'SIGNED_IN' && session && session.user) {
        if (process.env.NODE_ENV === 'development') {
          console.log('Authentication successful:', {
            userId: session.user.id?.substring(0, 8) + '...',
            email: session.user.email?.replace(/(.{3}).*@/, '$1...@'),
            provider: session.user.app_metadata?.provider
          });
        }
        
        await saveUserProfile(session.user);
        setIsProcessing(false);
        router.replace('/home');
      } else if (event === 'SIGNED_OUT' || !session) {
        if (process.env.NODE_ENV === 'development') {
          console.log('No session found, redirecting to home with error');
        }
        setErrorMessage('로그인 세션을 찾을 수 없습니다.');
        setIsProcessing(false);
        router.push('/?error=no_session');
      } else if (event === 'TOKEN_REFRESHED' && session) {
        if (process.env.NODE_ENV === 'development') {
          console.log('Token refreshed successfully');
        }
        await saveUserProfile(session.user);
        setIsProcessing(false);
        router.replace('/home');
      }
    });
    
    authSubscription = data.subscription;

    // 안전한 타임아웃: 15초 후에도 인증 이벤트가 없으면 에러 처리
    timeoutId = setTimeout(() => {
      if (!isMounted) return;
      
      console.log('Timeout: No auth state change after 15 seconds');
      setErrorMessage('로그인 처리 시간이 초과되었습니다. 다시 시도해 주세요.');
      setIsProcessing(false);
      router.push('/?error=timeout&retry=true');
    }, 15000);

    return () => {
      isMounted = false;
      if (authSubscription) {
        authSubscription.unsubscribe();
      }
      if (timeoutId) {
        clearTimeout(timeoutId);
      }
    };
  }, [router]);

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-purple-50 via-white to-pink-50">
      <div className="text-center max-w-md mx-auto p-6">
        {isProcessing ? (
          <>
            <div className="animate-spin h-8 w-8 border-4 border-purple-600 border-t-transparent rounded-full mx-auto mb-4"></div>
            <p className="text-lg text-gray-900 mb-2">구글 로그인 처리 중...</p>
            <p className="text-sm text-gray-600">
              인증 정보를 확인하고 있습니다...
            </p>
          </>
        ) : (
          <>
            <div className="text-red-500 text-6xl mb-4">⚠️</div>
            <p className="text-lg text-gray-900 mb-2">로그인 처리 중 문제가 발생했습니다</p>
            {errorMessage && (
              <p className="text-sm text-red-600 mb-4">{errorMessage}</p>
            )}
            <p className="text-sm text-gray-600">
              잠시 후 메인 페이지로 이동합니다...
            </p>
          </>
        )}
      </div>
    </div>
  );
} 