"use client";

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { supabase } from '@/lib/supabase';

export default function AuthCallbackPage() {
  const router = useRouter();
  const [isProcessing, setIsProcessing] = useState(true);

  useEffect(() => {
    const handleAuthCallback = async () => {
      try {
        console.log('Auth callback started...');
        console.log('Current URL:', window.location.href);
        
        let session = null;
        let attempts = 0;
        const maxAttempts = 5;
        
        while (!session && attempts < maxAttempts) {
          attempts++;
          console.log(`Session check attempt ${attempts}/${maxAttempts}`);
          
          const { data, error } = await supabase.auth.getSession();
          
          if (error) {
            console.error('Auth callback error:', error);
            if (attempts === maxAttempts) {
              setIsProcessing(false);
              router.push('/?error=callback_failed');
              return;
            }
            // 잠시 대기 후 재시도
            await new Promise(resolve => setTimeout(resolve, 500));
            continue;
          }
          
          if (data.session && data.session.user) {
            session = data.session;
            break;
          }
          
          // 세션이 없으면 잠시 대기 후 재시도
          if (attempts < maxAttempts) {
            await new Promise(resolve => setTimeout(resolve, 1000));
          }
        }

        if (session && session.user) {
          console.log('Authentication successful:', session.user.email);
          
          // 사용자 프로필 정보 로컬 스토리지에 저장
          const userProfile = {
            id: session.user.id,
            email: session.user.email || '',
            name: session.user.user_metadata?.full_name || session.user.user_metadata?.name || '사용자',
            avatar_url: session.user.user_metadata?.avatar_url || session.user.user_metadata?.picture,
            provider: session.user.app_metadata?.provider || 'google',
            created_at: session.user.created_at,
            subscription_status: 'free' as const,
            fortune_count: 0,
            favorite_fortune_types: []
          };
          
          localStorage.setItem("userProfile", JSON.stringify(userProfile));
          
          setIsProcessing(false);
          router.push('/home');
        } else {
          console.log('No session found after all attempts, redirecting to main page');
          setIsProcessing(false);
          router.push('/');
        }
      } catch (error) {
        console.error('Unexpected error:', error);
        setIsProcessing(false);
        router.push('/?error=unexpected');
      }
    };

    // URL 해시 변화 감지를 위한 약간의 지연
    const timer = setTimeout(() => {
      handleAuthCallback();
    }, 1000);

    return () => clearTimeout(timer);
  }, [router]);

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-purple-50 via-white to-pink-50">
      <div className="text-center">
        <div className="animate-spin h-8 w-8 border-4 border-purple-600 border-t-transparent rounded-full mx-auto mb-4"></div>
        <p className="text-lg text-gray-900">구글 로그인 처리 중...</p>
        <p className="text-sm text-gray-600 mt-2">
          {isProcessing ? '인증 정보를 확인하고 있습니다...' : '리다이렉트 중...'}
        </p>
      </div>
    </div>
  );
} 