"use client";

import { FortuneCompassIcon } from "@/components/icons/fortune-compass-icon";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Card, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Sparkles, Star, Moon, Sun } from "lucide-react";
import React, { useState, useRef, useEffect, useCallback } from "react";
import { auth, supabase } from "@/lib/supabase";
import { useToast } from "@/hooks/use-toast";
import { useRouter } from "next/navigation";
import { SecureStorage } from "@/lib/secure-storage";

export default function LandingPage() {
  const [isDarkMode, setIsDarkMode] = useState(false);
  const [isCheckingAuth, setIsCheckingAuth] = useState(true);
  const [isAuthProcessing, setIsAuthProcessing] = useState(false);
  const [checkAuthState, setCheckAuthState] = useState(0);
  const { toast } = useToast();
  const router = useRouter();

  // 인증 상태 확인을 useCallback으로 메모이제이션
  const checkAuthStateCallback = useCallback(async () => {
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
    let isMounted = true;
    let subscription: any = null;

    const handleAuthCallback = () => {
      // Promise를 반환하지 않도록 async 로직을 즉시 실행 함수로 감쌈
      (async () => {
        // URL 해시에서 토큰 확인 (구글 OAuth 콜백)
        const hash = window.location.hash;
        if (hash && hash.includes('access_token')) {
          console.log('OAuth 토큰 발견, 세션 처리 중...');
          
          try {
            // 토큰이 있으면 세션이 설정될 때까지 기다림
            await new Promise(resolve => setTimeout(resolve, 1000));
            
            // Supabase가 자동으로 URL 해시의 토큰을 처리하도록 함
            const { data, error } = await auth.getSession();
            
            if (data.session && data.session.user) {
              if (process.env.NODE_ENV === 'development') {
                console.log('OAuth 로그인 성공:', 
                  data.session.user.email?.replace(/(.{3}).*@/, '$1...@'));
              }
              
              // 사용자 프로필 생성 및 저장
              const userProfile = {
                id: data.session.user.id,
                email: data.session.user.email || '',
                name: data.session.user.user_metadata?.full_name || 
                      data.session.user.user_metadata?.name || 
                      data.session.user.email?.split('@')[0] || '사용자',
                avatar_url: data.session.user.user_metadata?.avatar_url || 
                           data.session.user.user_metadata?.picture,
                provider: data.session.user.app_metadata?.provider || 'google',
                created_at: data.session.user.created_at,
                subscription_status: 'free' as const,
                fortune_count: 0,
                favorite_fortune_types: []
              };
              
              SecureStorage.setItem("userProfile", userProfile);
              
              // URL 해시 제거
              window.history.replaceState(null, '', window.location.pathname);
              
              // 홈으로 리다이렉트
              router.replace('/home');
              return;
            }
          } catch (error) {
            console.error('OAuth 토큰 처리 오류:', error);
            // 에러 시 해시 제거
            window.history.replaceState(null, '', window.location.pathname);
          }
        }
      })();
    };

    const initializeAuth = () => {
      // Promise를 반환하지 않도록 async/await을 즉시 실행 함수로 감쌈
      (async () => {
        try {
          // 먼저 URL 해시 토큰 처리
          await handleAuthCallback();
          
          if (!isMounted) return;
          
          // URL에 에러 파라미터가 있는 경우 처리
          const urlParams = new URLSearchParams(window.location.search);
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
          await checkAuthStateCallback();
        } catch (error) {
          if (process.env.NODE_ENV === 'development') {
            console.error('인증 초기화 실패:', error);
          }
          if (isMounted) {
            setIsCheckingAuth(false);
          }
        }
      })();
    };

    // 비동기 초기화 실행
    initializeAuth();

    // 실시간 인증 상태 변화 감지
    const { data } = auth.onAuthStateChanged((user: any) => {
      if (!isMounted) return;
      
      if (process.env.NODE_ENV === 'development') {
        console.log('Auth state changed:', user ? 'SIGNED_IN' : 'SIGNED_OUT', 
          user?.email ? user.email.replace(/(.{3}).*@/, '$1...@') : undefined);
      }
      
      if (user) {
        // 사용자가 로그인되어 있으면 프로필 정보 저장 후 홈으로 이동
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
          console.log('Auth state changed, user logged in, redirecting to /home');
        }
        
        // 즉시 리다이렉트하지 않고 약간의 지연 후 이동
        setTimeout(() => {
          if (isMounted) {
            router.replace('/home');
          }
        }, 100);
      } else {
        if (process.env.NODE_ENV === 'development') {
          console.log('Auth state changed, user logged out');
        }
        setIsCheckingAuth(false);
      }
    });
    
    subscription = data.subscription;

    return () => {
      isMounted = false;
      if (subscription) {
        subscription.unsubscribe();
      }
    };
  }, [checkAuthStateCallback, router]);

  const handleGetStarted = useCallback(() => {
    if (process.env.NODE_ENV === 'development') {
      console.log("시작하기 버튼 클릭");
    }
    router.push("/onboarding/profile");
  }, [router]);

  const handleSocialLogin = useCallback(async (provider: string) => {
    if (isAuthProcessing) return;
    
    setIsAuthProcessing(true);
    
    // Promise가 React 렌더링 함수로 반환되지 않도록 즉시 실행
    (async () => {
      try {
        if (provider === 'Google') {
          toast({
            title: "로그인 진행 중",
            description: "Google 계정으로 로그인하고 있습니다...",
          });
          
          const result = await auth.signInWithGoogle();
          
          if (result?.error) {
            let errorMessage = 'Google 로그인에 실패했습니다.';
            
            // 에러 타입에 따른 사용자 친화적 메시지
            if (result.error.message?.includes('popup') || result.error.message?.includes('window')) {
              errorMessage = '팝업이 차단되었습니다. 팝업 차단을 해제하고 다시 시도해주세요.';
            } else if (result.error.message?.includes('network')) {
              errorMessage = '네트워크 연결을 확인하고 다시 시도해주세요.';
            } else if (result.error.message?.includes('cancelled')) {
              errorMessage = '로그인이 취소되었습니다.';
            }
            
            throw new Error(errorMessage);
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
          description: error.message || "로그인 중 문제가 발생했습니다. 다시 시도해주세요.",
          variant: "destructive",
        });
      } finally {
        // 리다이렉션되지 않은 경우에만 로딩 상태 해제
        setTimeout(() => {
          setIsAuthProcessing(false);
        }, 1000);
      }
    })();
    
    // 동기적으로 undefined 반환하여 Promise가 렌더링으로 전달되지 않도록 함
    return undefined;
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

