"use client";

import { FortuneCompassIcon } from "@/components/icons/fortune-compass-icon";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Card, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Sparkles, Star, Moon, Sun } from "lucide-react";
import React, { useState, useRef, useEffect } from "react";
import { auth } from "@/lib/supabase";
import { useToast } from "@/hooks/use-toast";
import { useRouter } from "next/navigation";

export default function LandingPage() {
  const [isDarkMode, setIsDarkMode] = useState(false);
  const [isCheckingAuth, setIsCheckingAuth] = useState(true);
  const { toast } = useToast();
  const router = useRouter();

  // 페이지 로드 시 로그인 상태 확인
  useEffect(() => {
    // 데모 세션 정리
    const clearDemoData = () => {
      const keys = Object.keys(localStorage);
      keys.forEach(key => {
        if (key.startsWith('demo_') || key === 'demo_session' || key === 'guest_user_id') {
          localStorage.removeItem(key);
        }
      });
    };

    const checkAuthState = async () => {
      try {
        // 먼저 데모 데이터 정리
        clearDemoData();
        
        const { data: { session } } = await auth.getSession();
        if (session && session.user) {
          console.log('Existing session found, redirecting to home');
          // 로그인되어 있으면 홈으로 리다이렉트
          router.push('/home');
          return;
        }
      } catch (error) {
        console.error('로그인 상태 확인 실패:', error);
      } finally {
        setIsCheckingAuth(false);
      }
    };

    // 약간의 지연을 두어 URL 해시 처리 시간 확보
    const timer = setTimeout(() => {
      checkAuthState();
    }, 500);

    // 실시간 인증 상태 변화 감지
    const { data: { subscription } } = auth.onAuthStateChanged((session: any) => {
      if (session && session.user) {
        console.log('Auth state changed, user logged in');
        router.push('/home');
      } else {
        console.log('Auth state changed, user logged out');
        setIsCheckingAuth(false);
      }
    });

    return () => {
      clearTimeout(timer);
      subscription?.unsubscribe();
    };
  }, [router]);

  const handleGetStarted = () => {
    console.log("시작하기 버튼 클릭");
    // 프로필 온보딩으로 바로 이동
    router.push("/onboarding/profile");
  };



  const handleSocialLogin = async (provider: string) => {
    try {
      if (provider === 'Google') {
        console.log("Google 로그인 시도 중...");
        await auth.signInWithGoogle();
        toast({
          title: "로그인 진행 중",
          description: "Google 계정으로 로그인하고 있습니다...",
        });
      } else if (provider === 'Kakao') {
        toast({
          title: "준비 중인 기능",
          description: "카카오 로그인은 현재 준비 중입니다.",
        });
      }
    } catch (error: any) {
      console.error(`${provider} 로그인 실패:`, error);
      toast({
        title: "로그인 실패",
        description: error.message || "다시 시도해주세요.",
        variant: "destructive",
      });
    }
  };

  const toggleTheme = () => {
    setIsDarkMode(!isDarkMode);
  };

  // 로그인 상태 확인 중이면 로딩 화면 표시
  if (isCheckingAuth) {
    return (
      <div className={`min-h-screen flex flex-col items-center justify-center transition-colors ${
        isDarkMode 
          ? 'bg-gradient-to-br from-gray-900 via-purple-900 to-gray-900 text-white' 
          : 'bg-gradient-to-br from-purple-50 via-white to-pink-50 text-gray-900'
      }`}>
        <div className="text-center">
          <FortuneCompassIcon className={`h-16 w-16 mx-auto mb-4 animate-spin ${
            isDarkMode ? 'text-purple-400' : 'text-purple-600'
          }`} />
          <p className={`text-lg ${
            isDarkMode ? 'text-gray-300' : 'text-gray-600'
          }`}>
            로그인 상태를 확인하고 있습니다...
          </p>
        </div>
      </div>
    );
  }

  return (
    <div className={`min-h-screen flex flex-col transition-colors ${
      isDarkMode 
        ? 'bg-gradient-to-br from-gray-900 via-purple-900 to-gray-900 text-white' 
        : 'bg-gradient-to-br from-purple-50 via-white to-pink-50 text-gray-900'
    }`}>
      {/* 헤더 */}
      <header className="w-full px-6 py-4 flex justify-between items-center">
        <div className="flex items-center space-x-2">
          <FortuneCompassIcon className={`h-8 w-8 ${
            isDarkMode ? 'text-purple-400' : 'text-purple-600'
          }`} />
          <span className={`text-xl font-bold ${
            isDarkMode ? 'text-white' : 'text-gray-900'
          }`}>운세</span>
        </div>
        <Button
          onClick={toggleTheme}
          variant="ghost"
          size="sm"
          className="rounded-full w-10 h-10 p-0"
          aria-label={isDarkMode ? "라이트 모드로 전환" : "다크 모드로 전환"}
        >
          {isDarkMode ? (
            <Sun className="h-5 w-5 text-yellow-400" />
          ) : (
            <Moon className="h-5 w-5 text-gray-600" />
          )}
        </Button>
      </header>

      {/* 메인 콘텐츠 */}
      <main className="flex-1 flex flex-col items-center justify-center px-6">
        {/* 히어로 섹션 */}
        <div className="text-center mb-12 max-w-md mx-auto">
          <div className="mb-8">
            <FortuneCompassIcon className={`h-24 w-24 mx-auto mb-4 ${
              isDarkMode ? 'text-purple-400' : 'text-purple-600'
            }`} />
          </div>
          
          <h1 className={`text-4xl font-bold mb-4 ${
            isDarkMode ? 'text-white' : 'text-gray-900'
          }`}>
            당신의 운명을 <br />
            <span className={`${
              isDarkMode ? 'text-purple-400' : 'text-purple-600'
            }`}>탐험해보세요</span>
          </h1>
          
          <p className={`text-lg mb-8 ${
            isDarkMode ? 'text-gray-300' : 'text-gray-600'
          }`}>
            AI가 제공하는 개인화된 운세로<br />
            새로운 가능성을 발견하세요
          </p>

          <div className="space-y-4 mb-12">
            <Button 
              onClick={handleGetStarted}
              className={`w-full max-w-sm font-medium py-4 px-8 rounded-full shadow-lg transition-all duration-300 hover:scale-105 ${
                isDarkMode 
                  ? 'bg-purple-500 hover:bg-purple-600 text-white' 
                  : 'bg-purple-600 hover:bg-purple-700 text-white'
              }`}
            >
              <Sparkles className="w-5 h-5 mr-2" />
              무료로 시작하기
            </Button>
            
            <Button 
              onClick={() => router.push('/fortune/saju')}
              variant="outline"
              className={`w-full max-w-sm font-medium py-4 px-8 rounded-full shadow-lg transition-all duration-300 hover:scale-105 ${
                isDarkMode 
                  ? 'border-purple-400 text-purple-400 hover:bg-purple-400 hover:text-white' 
                  : 'border-purple-600 text-purple-600 hover:bg-purple-600 hover:text-white'
              }`}
            >
              <Star className="w-5 h-5 mr-2" />
              사주팔자 바로보기
            </Button>
            
            {/* 간편 로그인 */}
            <div className="space-y-3">
              <Button 
                className={`w-full max-w-sm font-medium py-3 rounded-lg flex items-center justify-center space-x-2 shadow-sm transition-colors ${
                  isDarkMode 
                    ? 'bg-gray-700 hover:bg-gray-600 text-white border-gray-600' 
                    : 'bg-white hover:bg-gray-50 text-gray-900 border-gray-300'
                } border`}
                onClick={() => handleSocialLogin('Google')}
              >
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48" width="18" height="18">
                  <path fill="#EA4335" d="M24 9.5c3.54 0 6.71 1.22 9.21 3.6l6.85-6.85C35.9 2.38 30.47 0 24 0 14.62 0 6.51 5.38 2.56 13.22l7.98 6.19C12.43 13.72 17.74 9.5 24 9.5z"/>
                  <path fill="#4285F4" d="M46.98 24.55c0-1.57-.15-3.09-.38-4.55H24v9.02h12.94c-.58 2.96-2.26 5.48-4.78 7.18l7.73 6c4.51-4.18 7.09-10.36 7.09-17.65z"/>
                  <path fill="#FBBC05" d="M10.53 28.59c-.48-1.45-.76-2.99-.76-4.59s.27-3.14.76-4.59l-7.98-6.19C.92 16.46 0 20.12 0 24c0 3.88.92 7.54 2.56 10.78l7.97-6.19z"/>
                  <path fill="#34A853" d="M24 48c6.48 0 11.93-2.13 15.89-5.81l-7.73-6c-2.15 1.45-4.92 2.3-8.16 2.3-6.26 0-11.57-4.22-13.47-9.91l-7.98 6.19C6.51 42.62 14.62 48 24 48z"/>
                </svg>
                <span>Google로 계속하기</span>
              </Button>
              
              <Button
                className="w-full max-w-sm bg-[#FEE500] hover:bg-[#FEE500]/90 text-black font-medium py-3 rounded-lg flex items-center justify-center space-x-2 shadow-sm"
                onClick={() => handleSocialLogin('Kakao')}
              >
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="18" height="18">
                  <path fill="currentColor" d="M12 2C6.477 2 2 5.813 2 10.176c0 2.923 2.137 5.487 5.338 6.93L6 22l4.184-3.006c.594.09 1.207.138 1.816.138 5.523 0 10-3.813 10-8.176S17.523 2 12 2z" />
                </svg>
                <span>카카오로 계속하기</span>
              </Button>
              

            </div>
          </div>
        </div>

        {/* 기능 카드들 */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6 w-full max-w-4xl mb-16">
          <Card className={`text-center p-6 shadow-lg transition-all hover:scale-105 cursor-pointer ${
            isDarkMode 
              ? 'bg-gray-800 border-gray-700 hover:bg-gray-750' 
              : 'bg-white border-gray-200 hover:bg-gray-50'
          }`}
          onClick={() => router.push("/fortune")}
          >
            <CardHeader>
              <div className={`mx-auto mb-4 w-12 h-12 rounded-full flex items-center justify-center ${
                isDarkMode ? 'bg-purple-500' : 'bg-purple-100'
              }`}>
                <Star className={`w-6 h-6 ${
                  isDarkMode ? 'text-white' : 'text-purple-600'
                }`} />
              </div>
              <CardTitle className={`text-lg ${
                isDarkMode ? 'text-white' : 'text-gray-900'
              }`}>
                개인화된 운세
              </CardTitle>
              <CardDescription className={`${
                isDarkMode ? 'text-gray-400' : 'text-gray-600'
              }`}>
                당신만의 특별한 운세를 받아보세요
              </CardDescription>
            </CardHeader>
          </Card>

          <Card className={`text-center p-6 shadow-lg transition-all hover:scale-105 cursor-pointer ${
            isDarkMode 
              ? 'bg-gray-800 border-gray-700 hover:bg-gray-750' 
              : 'bg-white border-gray-200 hover:bg-gray-50'
          }`}
          onClick={() => router.push("/interactive/psychology-test")}
          >
            <CardHeader>
              <div className={`mx-auto mb-4 w-12 h-12 rounded-full flex items-center justify-center ${
                isDarkMode ? 'bg-blue-500' : 'bg-blue-100'
              }`}>
                <Sparkles className={`w-6 h-6 ${
                  isDarkMode ? 'text-white' : 'text-blue-600'
                }`} />
              </div>
              <CardTitle className={`text-lg ${
                isDarkMode ? 'text-white' : 'text-gray-900'
              }`}>
                심리테스트
              </CardTitle>
              <CardDescription className={`${
                isDarkMode ? 'text-gray-400' : 'text-gray-600'
              }`}>
                5가지 질문으로 알아보는 나의 성격
              </CardDescription>
            </CardHeader>
          </Card>

          <Card className={`text-center p-6 shadow-lg transition-all hover:scale-105 cursor-pointer ${
            isDarkMode 
              ? 'bg-gray-800 border-gray-700 hover:bg-gray-750' 
              : 'bg-white border-gray-200 hover:bg-gray-50'
          }`}
          onClick={() => router.push("/fortune/celebrity")}
          >
            <CardHeader>
              <div className={`mx-auto mb-4 w-12 h-12 rounded-full flex items-center justify-center ${
                isDarkMode ? 'bg-pink-500' : 'bg-pink-100'
              }`}>
                <Moon className={`w-6 h-6 ${
                  isDarkMode ? 'text-white' : 'text-pink-600'
                }`} />
              </div>
              <CardTitle className={`text-lg ${
                isDarkMode ? 'text-white' : 'text-gray-900'
              }`}>
                유명인 운세
              </CardTitle>
              <CardDescription className={`${
                isDarkMode ? 'text-gray-400' : 'text-gray-600'
              }`}>
                당신과 닮은 유명인의 운세 확인
              </CardDescription>
            </CardHeader>
          </Card>
        </div>


      </main>

      {/* 푸터 */}
      <footer className={`w-full py-6 px-6 mt-auto transition-colors border-t ${
        isDarkMode 
          ? 'border-gray-800' 
          : 'border-gray-200'
      }`}>
        <div className="text-center">
          <p className={`text-xs ${
            isDarkMode ? 'text-gray-500' : 'text-gray-500'
          }`}>
            © 2024 Fortune. 모든 권리 보유.
          </p>
        </div>
      </footer>
    </div>
  );
}

