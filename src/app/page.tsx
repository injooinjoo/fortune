"use client";

import { FortuneCompassIcon } from "@/components/icons/fortune-compass-icon";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Card, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Sparkles, Star, Moon, Sun } from "lucide-react";
import React, { useState, useRef, useEffect, useCallback } from "react";
import { useToast } from "@/hooks/use-toast";
import { useRouter } from "next/navigation";
import { getUserProfile, saveUserProfile } from "@/lib/user-storage";

export default function LandingPage() {
  const [isDarkMode, setIsDarkMode] = useState(false);
  const [isCheckingAuth, setIsCheckingAuth] = useState(true);
  const [isAuthProcessing, setIsAuthProcessing] = useState(false);
  const [checkAuthState, setCheckAuthState] = useState(0);
  const [isClient, setIsClient] = useState(false);
  const { toast } = useToast();
  const router = useRouter();

  // 클라이언트 사이드 마운트 확인 (hydration 오류 방지)
  useEffect(() => {
    setIsClient(true);
  }, []);

  // 인증 상태 확인 (Supabase 세션 + 로컬 스토리지)
  const checkAuthStateCallback = useCallback(async () => {
    try {
      // Supabase 세션 확인
      const { auth } = await import('@/lib/supabase');
      const { data } = await auth.getSession();
      
      if (data?.session?.user) {
        // 로그인된 사용자 - 프로필 확인
        const { userProfileService } = await import('@/lib/supabase');
        const profile = await userProfileService.getProfile(data.session.user.id);
        
        if (profile && profile.onboarding_completed) {
          if (process.env.NODE_ENV === 'development') {
            console.log('Authenticated user with completed onboarding, redirecting to home');
          }
          router.push('/home');
        }
        // 온보딩 미완료 사용자는 현재 페이지에 머물러 있음
      } else {
        // 세션이 없는 경우 로컬 스토리지 확인 (게스트 사용자)
        const userProfile = getUserProfile();
        
        if (userProfile && userProfile.onboarding_completed) {
          if (process.env.NODE_ENV === 'development') {
            console.log('Guest user profile found, redirecting to home');
          }
          router.push('/home');
        }
      }
    } catch (error) {
      if (process.env.NODE_ENV === 'development') {
        console.error('사용자 상태 확인 예외:', error);
      }
    } finally {
      setIsCheckingAuth(false);
    }
  }, [router]);

  // URL 파라미터 확인하여 에러 메시지 표시
  useEffect(() => {
    const urlParams = new URLSearchParams(window.location.search);
    const error = urlParams.get('error');
    const retry = urlParams.get('retry');
    
    if (error === 'session_expired') {
      toast({
        title: "세션이 만료되었습니다",
        description: "보안을 위해 세션이 만료되었습니다. 다시 로그인해 주세요.",
        variant: "destructive",
      });
      // URL 파라미터 정리
      window.history.replaceState(null, '', window.location.pathname);
    } else if (error === 'auth_failure' && retry) {
      toast({
        title: "로그인 실패",
        description: "로그인 처리 중 문제가 발생했습니다. 다시 시도해 주세요.",
        variant: "destructive",
      });
      // URL 파라미터 정리
      window.history.replaceState(null, '', window.location.pathname);
    } else if (error === 'timeout' && retry) {
      toast({
        title: "로그인 시간 초과",
        description: "로그인 처리 시간이 초과되었습니다. 다시 시도해 주세요.",
        variant: "destructive",
      });
      // URL 파라미터 정리
      window.history.replaceState(null, '', window.location.pathname);
    } else if (error === 'no_session') {
      toast({
        title: "세션을 찾을 수 없습니다",
        description: "로그인 세션을 찾을 수 없습니다. 다시 로그인해 주세요.",
        variant: "destructive",
      });
      // URL 파라미터 정리
      window.history.replaceState(null, '', window.location.pathname);
    }
  }, [toast]);

  // 페이지 로드 시 로그인 상태 확인
  useEffect(() => {
    if (!isClient) return;
    
    let isMounted = true;
    let subscription: any = null;

    const initializeAuth = () => {
      try {
        if (!isMounted) return;
        
        // URL에 OAuth code가 있는 경우 콜백 페이지로 리다이렉트
        const urlParams = new URLSearchParams(window.location.search);
        const code = urlParams.get('code');
        
        if (code) {
          console.log('🔄 OAuth code detected, redirecting to callback');
          router.replace(`/auth/callback${window.location.search}`);
          return;
        }
        
        // URL에 에러 파라미터가 있는 경우 처리
        const error = urlParams.get('error');
        
        if (error) {
          console.log('Auth error from URL:', error);
          
          // 에러 타입에 따른 사용자 친화적 메시지
          let errorMessage = '';
          switch (error) {
            case 'no_session':
              errorMessage = '로그인 세션을 찾을 수 없습니다. 다시 로그인해주세요.';
              break;
            case 'session_failed':
              errorMessage = '로그인 처리 중 문제가 발생했습니다.';
              break;
            case 'timeout':
              errorMessage = '로그인 처리 시간이 초과되었습니다.';
              break;
            default:
              errorMessage = '로그인 중 문제가 발생했습니다.';
          }
          
          toast({
            title: "로그인 실패",
            description: errorMessage,
            variant: "destructive",
          });
          
          // URL에서 에러 파라미터 제거
          const cleanUrl = window.location.pathname;
          window.history.replaceState(null, '', cleanUrl);
          
          setIsCheckingAuth(false);
          return;
        }
        
        // 인증 상태 확인
        console.log('Checking initial auth state...');
        checkAuthStateCallback();
      } catch (error) {
        if (process.env.NODE_ENV === 'development') {
          console.error('인증 초기화 실패:', error);
        }
        if (isMounted) {
          setIsCheckingAuth(false);
        }
      }
    };

    // 비동기 초기화 실행
    initializeAuth();

    // 로컬 스토리지 상태 변화 감지 (storage 이벤트 사용)
    const handleStorageChange = (e: StorageEvent) => {
      if (!isMounted) return;
      
      if (e.key === 'userProfile' || e.key === 'fortune_secure_userProfile') {
        if (process.env.NODE_ENV === 'development') {
          console.log('User profile changed in storage');
        }
        checkAuthStateCallback();
      }
    };
    
    window.addEventListener('storage', handleStorageChange);

    return () => {
      isMounted = false;
      window.removeEventListener('storage', handleStorageChange);
    };
  }, [checkAuthStateCallback, router, isClient]);

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
        // 실제 Google OAuth 로그인 시작
        const { auth } = await import('@/lib/supabase');
        const { error } = await auth.signInWithGoogle();
        
        if (error) {
          console.error('Google login error:', error);
          toast({
            title: "로그인 실패",
            description: "Google 로그인 중 문제가 발생했습니다. 다시 시도해주세요.",
            variant: "destructive",
          });
          setIsAuthProcessing(false);
          return;
        }
        
        // OAuth 로그인 성공 시 콜백 페이지에서 처리됨
        toast({
          title: "로그인 중",
          description: "Google 로그인을 처리하고 있습니다...",
        });
        
      } else if (provider === 'Kakao') {
        toast({
          title: "준비 중인 기능",
          description: "카카오 로그인은 현재 준비 중입니다.",
        });
        setIsAuthProcessing(false);
      }
    } catch (error: any) {
      if (process.env.NODE_ENV === 'development') {
        console.error(`${provider} 로그인 처리 중 오류:`, error);
      }
      
      toast({
        title: "처리 실패",
        description: "처리 중 문제가 발생했습니다. 다시 시도해주세요.",
        variant: "destructive",
      });
      setIsAuthProcessing(false);
    }
    
    return undefined;
  }, [toast, isAuthProcessing, router]);

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
                onClick={() => void handleSocialLogin('Google')}
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
                onClick={() => void handleSocialLogin('Kakao')}
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

