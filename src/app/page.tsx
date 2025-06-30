"use client";

import { FortuneCompassIcon } from "@/components/icons/fortune-compass-icon";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Card, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Sparkles, Star, Moon, Sun } from "lucide-react";
import React, { useState, useRef, useEffect, useCallback } from "react";
import { auth } from "@/lib/supabase";
import { useToast } from "@/hooks/use-toast";
import { useRouter } from "next/navigation";

export default function LandingPage() {
  const [isDarkMode, setIsDarkMode] = useState(false);
  const [isCheckingAuth, setIsCheckingAuth] = useState(true);
  const [isAuthProcessing, setIsAuthProcessing] = useState(false);
  const { toast } = useToast();
  const router = useRouter();

  // 인증 상태 확인을 useCallback으로 메모이제이션
  const checkAuthState = useCallback(async () => {
    try {
      // 데모 세션 정리
      const keys = Object.keys(localStorage);
      keys.forEach(key => {
        if (key.startsWith('demo_') || key === 'demo_session' || key === 'guest_user_id') {
          localStorage.removeItem(key);
        }
      });
      
      const { data: { session }, error } = await auth.getSession();
      
      if (error) {
        if (process.env.NODE_ENV === 'development') {
          console.error('로그인 상태 확인 실패:', error);
        }
        return;
      }
      
      if (session && session.user) {
        if (process.env.NODE_ENV === 'development') {
          console.log('Existing session found, redirecting to home');
        }
        router.push('/home');
      }
    } catch (error) {
      if (process.env.NODE_ENV === 'development') {
        console.error('로그인 상태 확인 예외:', error);
      }
    } finally {
      setIsCheckingAuth(false);
    }
  }, [router]);

  // 페이지 로드 시 로그인 상태 확인
  useEffect(() => {
    let isMounted = true;
    
    // 약간의 지연을 두어 URL 해시 처리 시간 확보
    const timer = setTimeout(() => {
      if (isMounted) {
        checkAuthState();
      }
    }, 500);

    // 실시간 인증 상태 변화 감지
    const { data: { subscription } } = auth.onAuthStateChanged((session: any) => {
      if (!isMounted) return;
      
      if (session && session.user) {
        if (process.env.NODE_ENV === 'development') {
          console.log('Auth state changed, user logged in');
        }
        router.push('/home');
      } else {
        if (process.env.NODE_ENV === 'development') {
          console.log('Auth state changed, user logged out');
        }
        setIsCheckingAuth(false);
      }
    });

    return () => {
      isMounted = false;
      clearTimeout(timer);
      subscription?.unsubscribe();
    };
  }, [checkAuthState]);

  const handleGetStarted = useCallback(() => {
    if (process.env.NODE_ENV === 'development') {
      console.log("시작하기 버튼 클릭");
    }
    router.push("/onboarding/profile");
  }, [router]);

  const handleSocialLogin = useCallback(async (provider: string) => {
    if (isAuthProcessing) return;
    
    setIsAuthProcessing(true);
    try {
      if (provider === 'Google') {
        toast({
          title: "로그인 진행 중",
          description: "Google 계정으로 로그인하고 있습니다...",
        });
        
        const result = await auth.signInWithGoogle();
        
        if (result?.error) {
          throw new Error('Google 로그인에 실패했습니다.');
        }
        
        // 성공적으로 리다이렉트되면 이 코드는 실행되지 않음
      } else if (provider === 'Kakao') {
        toast({
          title: "준비 중인 기능",
          description: "카카오 로그인은 현재 준비 중입니다.",
        });
      }
    } catch (error: any) {
      if (process.env.NODE_ENV === 'development') {
        console.error(`${provider} 로그인 실패:`, error);
      }
      
      toast({
        title: "로그인 실패",
        description: "로그인 중 문제가 발생했습니다. 다시 시도해주세요.",
        variant: "destructive",
      });
    } finally {
      setIsAuthProcessing(false);
    }
  }, [toast, isAuthProcessing]);

  const toggleTheme = useCallback(() => {
    setIsDarkMode(prev => !prev);
  }, []);

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
          


          <div className="space-y-4 mb-12">

            
            {/* 소셜 로그인 버튼들 */}
            <div className="space-y-2">
              <Button 
                onClick={() => handleSocialLogin('Google')}
                disabled={isAuthProcessing}
                variant="outline"
                className={`w-full max-w-sm py-3 px-6 rounded-full transition-all duration-300 ${
                  isDarkMode 
                    ? 'border-gray-600 bg-gray-800 text-gray-200 hover:bg-gray-700 hover:border-gray-500' 
                    : 'border-gray-300 bg-white text-gray-700 hover:bg-gray-50 hover:border-gray-400'
                } ${isAuthProcessing ? 'opacity-50 cursor-not-allowed' : ''}`}
              >
                {isAuthProcessing ? '로그인 중...' : 'Google로 시작하기'}
              </Button>
              
              <Button 
                onClick={() => handleSocialLogin('Kakao')}
                disabled={isAuthProcessing}
                variant="outline"
                className={`w-full max-w-sm py-3 px-6 rounded-full transition-all duration-300 ${
                  isDarkMode 
                    ? 'border-yellow-500 bg-yellow-600 text-gray-900 hover:bg-yellow-500' 
                    : 'border-yellow-400 bg-yellow-400 text-gray-900 hover:bg-yellow-500'
                } ${isAuthProcessing ? 'opacity-50 cursor-not-allowed' : ''}`}
              >
                카카오로 시작하기
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

