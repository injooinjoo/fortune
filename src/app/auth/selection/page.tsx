
"use client";

import React, { useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { useToast } from '@/hooks/use-toast';
import { Mail, LogIn, MessageSquare, Instagram, Smartphone } from 'lucide-react';
import Image from 'next/image';

import { auth } from '@/lib/firebase'; // Firebase auth 객체 가져오기
import { GoogleAuthProvider, signInWithRedirect, getRedirectResult, UserCredential } from 'firebase/auth'; // Firebase auth 관련 함수 가져오기
import { FortuneCompassIcon } from '@/components/icons/fortune-compass-icon';

export default function AuthSelectionPage() {
  const router = useRouter();
  const { toast } = useToast();

  useEffect(() => {
    const handleRedirectResult = async () => {
      try {
        const result = await getRedirectResult(auth);
        if (result) {
          // This is the redirect back from Google Sign-In.
          const user = result.user;
          console.log("Google 로그인 성공 (Redirect):", user);
          toast({
            title: "Google 로그인 성공!",
            description: `${user.displayName || '사용자'}님, 환영합니다. 홈으로 이동합니다.`,
          });
          // TODO: Firestore에서 사용자 프로필 존재 여부 확인 후,
          // 신규 사용자면 프로필 생성 페이지로, 기존 사용자면 홈으로 리디렉션
          router.push('/home'); // 임시 홈 페이지로 이동
        }
      } catch (error: any) {
        console.error("Google 로그인 실패 (Redirect):", error);
        toast({
          title: "Google 로그인 실패",
          description: error.message || "다시 시도해주세요.",
          variant: "destructive",
        });
      }
    };

    handleRedirectResult();
  }, [router, toast]);

  const handleGoogleSignIn = async () => {
    const provider = new GoogleAuthProvider();
    try {
      await signInWithRedirect(auth, provider);
      // signInWithRedirect does not return a UserCredential immediately.
      // The user will be redirected to the Google sign-in page.
    } catch (error: any) {
      console.error("Google 로그인 실패:", error);
      toast({
        title: "Google 로그인 실패",
        description: error.message || "다시 시도해주세요.",
        variant: "destructive",
      });
    }
  };

  const handleOtherAuthMethodSelect = (method: string) => {
    toast({
      title: "인증 방법 선택됨",
      description: `${method} 로그인을 시도합니다. (UI 프로토타입 - ${method} 연동 필요)`,
    });
    // In a real app, you would initiate the respective Firebase auth flow here.
  };

  return (
    <div className="min-h-screen flex flex-col items-center justify-center bg-background text-foreground p-4">
      <Card className="w-full max-w-md shadow-xl">
        <CardHeader className="text-center">
          <div className="mx-auto mb-6 h-16 w-16">
            {/* <Image src="https://placehold.co/128x128.png" alt="앱 로고" width={64} height={64} className="rounded-full" data-ai-hint="mystical compass" /> */}
            <FortuneCompassIcon className="h-16 w-16 text-primary" />
          </div>
          <CardTitle className="text-2xl">운세 탐험</CardTitle>
          <CardDescription className="mt-2">계속하려면 인증 방법을 선택해주세요.</CardDescription>
        </CardHeader>
        <CardContent className="space-y-4 p-6">
          <Button
            variant="outline"
            className="w-full justify-center text-base py-6"
            onClick={handleGoogleSignIn} // Google 로그인 함수 연결
          >
            <svg xmlns="http://www.w3.org/2000/svg" className="mr-3 h-5 w-5" viewBox="0 0 48 48" width="24px" height="24px">
              <path fill="#EA4335" d="M24 9.5c3.54 0 6.71 1.22 9.21 3.6l6.85-6.85C35.9 2.38 30.47 0 24 0 14.62 0 6.51 5.38 2.56 13.22l7.98 6.19C12.43 13.72 17.74 9.5 24 9.5z"/>
              <path fill="#4285F4" d="M46.98 24.55c0-1.57-.15-3.09-.38-4.55H24v9.02h12.94c-.58 2.96-2.26 5.48-4.78 7.18l7.73 6c4.51-4.18 7.09-10.36 7.09-17.65z"/>
              <path fill="#FBBC05" d="M10.53 28.59c-.48-1.45-.76-2.99-.76-4.59s.27-3.14.76-4.59l-7.98-6.19C.92 16.46 0 20.12 0 24c0 3.88.92 7.54 2.56 10.78l7.97-6.19z"/>
              <path fill="#34A853" d="M24 48c6.48 0 11.93-2.13 15.89-5.81l-7.73-6c-2.15 1.45-4.92 2.3-8.16 2.3-6.26 0-11.57-4.22-13.47-9.91l-7.98 6.19C6.51 42.62 14.62 48 24 48z"/>
              <path fill="none" d="M0 0h48v48H0z"/>
            </svg>
            Google 계정으로 계속하기
          </Button>
          <Button
            variant="outline"
            className="w-full justify-center text-base py-6 bg-[#03C75A] text-white hover:bg-[#03C75A]/90"
            onClick={() => handleOtherAuthMethodSelect('Naver')}
          >
            <svg xmlns="http://www.w3.org/2000/svg" className="mr-3 h-5 w-5 text-white" viewBox="0 0 24 24" fill="currentColor">
              <path d="M16.273 12.845h-3.217V8.53h3.217v4.315zm0 4.308h-3.217v-3.21h3.217v3.21zM7.727 8.53v8.623H4V4h7.54v3.21H7.727v1.32zM20 4v16H4V4h16z"/>
            </svg>
            Naver 계정으로 계속하기
          </Button>
          <Button
            variant="outline"
            className="w-full justify-center text-base py-6 bg-[#FEE500] text-black hover:bg-[#FEE500]/90"
            onClick={() => handleOtherAuthMethodSelect('Kakao')}
          >
            <MessageSquare className="mr-3 h-5 w-5" />
            Kakao 계정으로 계속하기
          </Button>
          <Button
            variant="outline"
            className="w-full justify-center text-base py-6"
            onClick={() => handleOtherAuthMethodSelect('Instagram')}
          >
            <Instagram className="mr-3 h-5 w-5" />
            Instagram 계정으로 계속하기
          </Button>
          <Button
            variant="secondary"
            className="w-full justify-center text-base py-6"
            onClick={() => handleOtherAuthMethodSelect('휴대폰')}
          >
            <Smartphone className="mr-3 h-5 w-5" />
            휴대폰 번호로 인증하기
          </Button>
        </CardContent>
      </Card>
       <footer className="py-8 text-center text-xs text-muted-foreground">
        {/* <p>&copy; {new Date().getFullYear()} 운세 탐험. 모든 운명은 당신의 선택에 달려있습니다.</p> */}
         <p>&copy; 운세 탐험. 모든 운명은 당신의 선택에 달려있습니다.</p> {/* Hydration error 방지 위해 new Date() 제거 */}
      </footer>
    </div>
  );
}

