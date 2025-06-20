"use client";

import { FortuneCompassIcon } from "@/components/icons/fortune-compass-icon";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Card, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Sparkles, Star, Moon, Sun } from "lucide-react";
import React, { useState, useRef } from "react";
import { auth } from "@/lib/supabase";
import { useToast } from "@/hooks/use-toast";
import { useRouter } from "next/navigation";

export default function LandingPage() {
  const [isDarkMode, setIsDarkMode] = useState(false);
  const [showNameInput, setShowNameInput] = useState(true);
  const [showLoginForm, setShowLoginForm] = useState(false);
  const [userName, setUserName] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const loginSectionRef = useRef<HTMLElement>(null);
  const { toast } = useToast();
  const router = useRouter();

  const handleGetStarted = () => {
    console.log("시작하기 버튼 클릭");
    setShowNameInput(true);
  };

  const handleNameSubmit = () => {
    if (!userName.trim()) {
      toast({
        title: "이름을 입력해주세요",
        description: "운세를 위해 이름이 필요합니다.",
        variant: "destructive",
      });
      return;
    }
    
    // 이름을 로컬 스토리지에 저장하고 생년월일 페이지로 이동
    localStorage.setItem("userName", userName);
    router.push("/onboarding/birthdate");
  };

  const handleLoginClick = () => {
    setShowLoginForm(true);
    setShowNameInput(false);
  };

  const handleLoginSubmit = () => {
    if (!email || !password) {
      toast({
        title: "이메일과 비밀번호를 입력해주세요",
        description: "로그인을 위해 필요합니다.",
        variant: "destructive",
      });
      return;
    }

    // 테스트용 더미 로그인
    localStorage.setItem("userEmail", email);
    router.push("/dashboard");
    
    toast({
      title: "로그인 성공!",
      description: "대시보드로 이동합니다.",
    });
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

          {showLoginForm ? (
            <div className="mb-12 w-full max-w-sm mx-auto">
              <div className="space-y-4">
                <div>
                  <label className={`block text-sm font-medium mb-2 ${
                    isDarkMode ? 'text-gray-300' : 'text-gray-700'
                  }`}>
                    이메일
                  </label>
                  <Input
                    type="email"
                    placeholder="이메일을 입력하세요"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    className={`w-full ${
                      isDarkMode 
                        ? 'bg-gray-800 border-gray-600 text-white placeholder-gray-400' 
                        : 'bg-white border-gray-300 text-gray-900'
                    }`}
                  />
                </div>
                <div>
                  <label className={`block text-sm font-medium mb-2 ${
                    isDarkMode ? 'text-gray-300' : 'text-gray-700'
                  }`}>
                    비밀번호
                  </label>
                  <Input
                    type="password"
                    placeholder="비밀번호를 입력하세요"
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    className={`w-full ${
                      isDarkMode 
                        ? 'bg-gray-800 border-gray-600 text-white placeholder-gray-400' 
                        : 'bg-white border-gray-300 text-gray-900'
                    }`}
                    onKeyPress={(e) => {
                      if (e.key === 'Enter') {
                        handleLoginSubmit();
                      }
                    }}
                  />
                </div>
                <Button 
                  onClick={handleLoginSubmit}
                  className={`w-full font-medium py-3 rounded-lg shadow-lg transition-colors ${
                    isDarkMode 
                      ? 'bg-purple-500 hover:bg-purple-600 text-white' 
                      : 'bg-purple-600 hover:bg-purple-700 text-white'
                  }`}
                >
                  로그인 제출
                </Button>
                <Button 
                  variant="ghost"
                  onClick={() => {
                    setShowLoginForm(false);
                    setShowNameInput(true);
                  }}
                  className="w-full"
                >
                  돌아가기
                </Button>
              </div>
            </div>
          ) : showNameInput ? (
            <div className="mb-12 w-full max-w-sm mx-auto">
              <div className="space-y-4">
                <div>
                  <label className={`block text-sm font-medium mb-2 ${
                    isDarkMode ? 'text-gray-300' : 'text-gray-700'
                  }`}>
                    이름을 입력해주세요
                  </label>
                  <Input
                    name="name"
                    placeholder="홍길동"
                    value={userName}
                    onChange={(e) => setUserName(e.target.value)}
                    className={`w-full ${
                      isDarkMode 
                        ? 'bg-gray-800 border-gray-600 text-white placeholder-gray-400' 
                        : 'bg-white border-gray-300 text-gray-900'
                    }`}
                    onKeyPress={(e) => {
                      if (e.key === 'Enter') {
                        handleNameSubmit();
                      }
                    }}
                  />
                </div>
                <Button 
                  onClick={handleNameSubmit}
                  className={`w-full font-medium py-3 rounded-lg shadow-lg transition-colors ${
                    isDarkMode 
                      ? 'bg-purple-500 hover:bg-purple-600 text-white' 
                      : 'bg-purple-600 hover:bg-purple-700 text-white'
                  }`}
                >
                  다음
                </Button>
                <Button 
                  onClick={handleLoginClick}
                  variant="outline"
                  className={`w-full max-w-sm font-medium py-4 px-8 rounded-full transition-all duration-300 hover:scale-105 ${
                    isDarkMode 
                      ? 'border-purple-400 text-purple-400 hover:bg-purple-400 hover:text-gray-900' 
                      : 'border-purple-600 text-purple-600 hover:bg-purple-600 hover:text-white'
                  }`}
                >
                  이메일로 로그인
                </Button>
              </div>
            </div>
          ) : (
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
                onClick={handleLoginClick}
                variant="outline"
                className={`w-full max-w-sm font-medium py-4 px-8 rounded-full transition-all duration-300 hover:scale-105 ${
                  isDarkMode 
                    ? 'border-purple-400 text-purple-400 hover:bg-purple-400 hover:text-gray-900' 
                    : 'border-purple-600 text-purple-600 hover:bg-purple-600 hover:text-white'
                }`}
              >
                이메일로 로그인
              </Button>
            </div>
          )}
        </div>

        {/* 기능 카드들 */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6 w-full max-w-4xl mb-16">
          <Card className={`text-center p-6 shadow-lg transition-all hover:scale-105 ${
            isDarkMode 
              ? 'bg-gray-800 border-gray-700' 
              : 'bg-white border-gray-200'
          }`}>
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

          <Card className={`text-center p-6 shadow-lg transition-all hover:scale-105 ${
            isDarkMode 
              ? 'bg-gray-800 border-gray-700' 
              : 'bg-white border-gray-200'
          }`}>
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
                AI 분석
              </CardTitle>
              <CardDescription className={`${
                isDarkMode ? 'text-gray-400' : 'text-gray-600'
              }`}>
                첨단 AI가 분석하는 정확한 예측
              </CardDescription>
            </CardHeader>
          </Card>

          <Card className={`text-center p-6 shadow-lg transition-all hover:scale-105 ${
            isDarkMode 
              ? 'bg-gray-800 border-gray-700' 
              : 'bg-white border-gray-200'
          }`}>
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
                다양한 분야
              </CardTitle>
              <CardDescription className={`${
                isDarkMode ? 'text-gray-400' : 'text-gray-600'
              }`}>
                사랑, 직업, 건강까지 모든 영역
              </CardDescription>
            </CardHeader>
          </Card>
        </div>

        {/* 소셜 로그인 섹션 */}
        <section ref={loginSectionRef} className="w-full px-6 pb-12">
          <div className="text-center mb-6">
            <h2 className="text-xl font-bold mb-1 text-gray-900">간편 로그인</h2>
            <p className={`text-sm ${
              isDarkMode ? 'text-gray-400' : 'text-gray-600'
            }`}>소셜 계정으로 빠르게 시작하세요</p>
          </div>
          
          <div className="space-y-3 max-w-sm mx-auto">
            <Button 
              className={`w-full font-medium py-3 rounded-lg flex items-center justify-center space-x-2 shadow-sm transition-colors ${
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
              className="w-full bg-[#FEE500] hover:bg-[#FEE500]/90 text-black font-medium py-3 rounded-lg flex items-center justify-center space-x-2 shadow-sm"
              onClick={() => handleSocialLogin('Kakao')}
            >
              <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="18" height="18">
                <path fill="currentColor" d="M12 2C6.477 2 2 5.813 2 10.176c0 2.923 2.137 5.487 5.338 6.93L6 22l4.184-3.006c.594.09 1.207.138 1.816.138 5.523 0 10-3.813 10-8.176S17.523 2 12 2z" />
              </svg>
              <span>카카오로 계속하기</span>
            </Button>
            
            <div className="text-center mt-4">
              <Button
                variant="link"
                className={`text-sm ${
                  isDarkMode ? 'text-gray-400 hover:text-gray-300' : 'text-gray-600 hover:text-gray-800'
                }`}
                onClick={() => router.push("/home")}
              >
                로그인 없이 체험하기
              </Button>
            </div>
          </div>
        </section>
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

