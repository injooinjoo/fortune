"use client";

import { useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { supabase } from '@/lib/supabase';

export default function AuthCallbackPage() {
  const router = useRouter();

  useEffect(() => {
    const handleAuthCallback = async () => {
      try {
        const { data, error } = await supabase.auth.getSession();
        
        if (error) {
          console.error('Auth callback error:', error);
          router.push('/auth/selection?error=callback_failed');
          return;
        }

        if (data.session) {
          console.log('Authentication successful:', data.session.user);
          router.push('/home');
        } else {
          router.push('/auth/selection');
        }
      } catch (error) {
        console.error('Unexpected error:', error);
        router.push('/auth/selection?error=unexpected');
      }
    };

    handleAuthCallback();
  }, [router]);

  return (
    <div className="min-h-screen flex items-center justify-center bg-background">
      <div className="text-center">
        <div className="animate-spin h-8 w-8 border-4 border-primary border-t-transparent rounded-full mx-auto mb-4"></div>
        <p className="text-lg">로그인 처리 중...</p>
        <p className="text-sm text-muted-foreground mt-2">잠시만 기다려주세요.</p>
      </div>
    </div>
  );
} 