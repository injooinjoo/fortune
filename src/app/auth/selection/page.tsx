"use client";

import React, { useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { useToast } from '@/hooks/use-toast';

import { FortuneCompassIcon } from '@/components/icons/fortune-compass-icon';
import { auth } from '@/lib/supabase';

export default function AuthSelectionPage({ searchParams }: { searchParams: Record<string, string | string[]> }) {
  const router = useRouter();
  const { toast } = useToast();

  useEffect(() => {
    // Supabase는 자동으로 auth state를 관리하므로 별도의 redirect 처리 불필요
    const { data: { subscription } } = auth.onAuthStateChanged((user: any) => {
      if (user) {
        console.log("로그인 성공:", user);
        toast({
          title: "로그인 성공!",
          description: `${user.user_metadata?.name || '사용자'}님, 환영합니다. 홈으로 이동합니다.`,
        });
        router.push('/home');
      }
    });

    return () => subscription?.unsubscribe();
  }, [router, toast]);

  const handleGoogleSignIn = async () => {
    try {
      await auth.signInWithGoogle();
    } catch (error: any) {
      console.error("Google 로그인 실패:", error);
      toast({
        title: "로그인 실패",
        description: error.message || "다시 시도해주세요.",
        variant: "destructive",
      });
    }
  };

  const handleKakaoSignIn = async () => {
    toast({
      title: "준비 중인 기능",
      description: "카카오 로그인은 현재 준비 중입니다.",
    });
  };

  return (
    <div className="min-h-screen flex flex-col items-center justify-center bg-background text-foreground p-4">
      <Card className="w-full max-w-md shadow-xl">
        <CardHeader className="text-center">
          <div className="mx-auto mb-6 h-16 w-16">
            {/* <Image src="https://placehold.co/128x128.png" alt="앱 로고" width={64} height={64} className="rounded-full" data-ai-hint="mystical compass" /> */}
            <FortuneCompassIcon className="h-16 w-16 text-primary" />
          </div>
          <CardTitle className="text-2xl">운세</CardTitle>
          <CardDescription className="mt-2">계속하려면 인증 방법을 선택해주세요.</CardDescription>
        </CardHeader>
        <CardContent className="space-y-4 p-6">
          <Button
            variant="outline"
            className="w-full justify-center text-base py-6 font-medium"
            onClick={handleGoogleSignIn}
          >
            <svg xmlns="http://www.w3.org/2000/svg" className="mr-3 h-5 w-5" viewBox="0 0 48 48" width="20px" height="20px">
              <path fill="#EA4335" d="M24 9.5c3.54 0 6.71 1.22 9.21 3.6l6.85-6.85C35.9 2.38 30.47 0 24 0 14.62 0 6.51 5.38 2.56 13.22l7.98 6.19C12.43 13.72 17.74 9.5 24 9.5z"/>
              <path fill="#4285F4" d="M46.98 24.55c0-1.57-.15-3.09-.38-4.55H24v9.02h12.94c-.58 2.96-2.26 5.48-4.78 7.18l7.73 6c4.51-4.18 7.09-10.36 7.09-17.65z"/>
              <path fill="#FBBC05" d="M10.53 28.59c-.48-1.45-.76-2.99-.76-4.59s.27-3.14.76-4.59l-7.98-6.19C.92 16.46 0 20.12 0 24c0 3.88.92 7.54 2.56 10.78l7.97-6.19z"/>
              <path fill="#34A853" d="M24 48c6.48 0 11.93-2.13 15.89-5.81l-7.73-6c-2.15 1.45-4.92 2.3-8.16 2.3-6.26 0-11.57-4.22-13.47-9.91l-7.98 6.19C6.51 42.62 14.62 48 24 48z"/>
              <path fill="none" d="M0 0h48v48H0z"/>
            </svg>
            Google 계정으로 계속하기
          </Button>
          <Button
            className="w-full justify-center text-base py-6 bg-[#FEE500] text-black hover:bg-[#FEE500]/90 font-medium"
            onClick={handleKakaoSignIn}
          >
            <svg xmlns="http://www.w3.org/2000/svg" className="mr-3 h-5 w-5" viewBox="0 0 24 24" fill="currentColor">
              <path d="M12 2C6.477 2 2 5.813 2 10.176c0 2.923 2.137 5.487 5.338 6.93L6 22l4.184-3.006c.594.09 1.207.138 1.816.138 5.523 0 10-3.813 10-8.176S17.523 2 12 2z" />
            </svg>
            카카오 계정으로 계속하기
          </Button>
        </CardContent>
      </Card>
       <footer className="py-8 text-center text-xs text-muted-foreground">
         <p>&copy; 2024 운세. 모든 운명은 당신의 선택에 달려있습니다.</p>
      </footer>
    </div>
  );
}

