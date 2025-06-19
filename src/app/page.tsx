"use client";

import { FortuneCompassIcon } from "@/components/icons/fortune-compass-icon";
import { Button } from "@/components/ui/button";
import { Card, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Sparkles, Star, Moon, Sun } from "lucide-react";
import React from "react";

export default function LandingPage() {
  const handleLoginClick = () => {
    console.log("로그인 버튼 클릭");
  };

  const handleGetStarted = () => {
    console.log("시작하기 버튼 클릭");
  };

  const handleSocialLogin = (provider: string) => {
    console.log(`${provider} 로그인 클릭`);
  };

  return (
    <div className="flex flex-col items-start relative w-full min-h-screen bg-white">
      {/* 헤더 */}
      <header className="flex items-center justify-between w-full px-6 py-4">
        <div className="flex items-center space-x-2">
          <FortuneCompassIcon className="w-6 h-6 text-purple-600" />
          <span className="text-xl font-bold text-gray-900">Fortune</span>
        </div>
        <Button 
          variant="outline" 
          className="border-gray-300 text-gray-700 hover:bg-gray-50 text-sm px-4 py-2"
          onClick={handleLoginClick}
        >
          로그인
        </Button>
      </header>

      {/* 메인 컨텐츠 */}
      <main className="flex flex-col items-start w-full">
        {/* 히어로 섹션 */}
        <section className="flex flex-col items-center text-center w-full px-6 py-12">
          <div className="mb-8">
            <h1 className="text-3xl font-bold text-gray-900 mb-4 leading-tight">
              당신의 운명을
              <br />
              <span className="text-purple-600">
                읽어드립니다
              </span>
            </h1>
            <p className="text-base text-gray-600 leading-relaxed max-w-sm mx-auto">
              AI와 전통 명리학이 만나
              <br />
              당신만의 특별한 운세를 제공합니다
            </p>
          </div>

          {/* CTA 버튼 */}
          <div className="mb-12">
            <Button 
              className="bg-purple-600 hover:bg-purple-700 text-white font-medium px-8 py-3 rounded-full shadow-lg"
              onClick={handleGetStarted}
            >
              <Sparkles className="w-4 h-4 mr-2" />
              무료로 시작하기
            </Button>
          </div>
        </section>

        {/* 서비스 소개 섹션 */}
        <section className="w-full px-6 pb-12">
          <div className="text-center mb-8">
            <h2 className="text-2xl font-bold text-gray-900 mb-2">
              다양한 운세 서비스
            </h2>
            <p className="text-gray-600 text-sm">
              전통과 현대가 만나는 특별한 경험
            </p>
          </div>

          <div className="space-y-4">
            <Card className="bg-white border border-gray-200 shadow-sm hover:shadow-md transition-shadow duration-300">
              <CardHeader className="text-center p-6">
                <div className="mx-auto mb-3 w-12 h-12 bg-orange-100 rounded-full flex items-center justify-center">
                  <Sun className="h-6 w-6 text-orange-600" />
                </div>
                <CardTitle className="text-gray-900 text-lg mb-2">사주팔자</CardTitle>
                <CardDescription className="text-gray-600 text-sm leading-relaxed">
                  생년월일시를 바탕으로 한 정통 사주 풀이로 
                  당신의 타고난 운명을 분석합니다
                </CardDescription>
              </CardHeader>
            </Card>

            <Card className="bg-white border border-gray-200 shadow-sm hover:shadow-md transition-shadow duration-300">
              <CardHeader className="text-center p-6">
                <div className="mx-auto mb-3 w-12 h-12 bg-purple-100 rounded-full flex items-center justify-center">
                  <Star className="h-6 w-6 text-purple-600" />
                </div>
                <CardTitle className="text-gray-900 text-lg mb-2">AI 관상</CardTitle>
                <CardDescription className="text-gray-600 text-sm leading-relaxed">
                  최신 AI 기술로 얼굴 특징을 분석하여 
                  성격과 운세를 읽어드립니다
                </CardDescription>
              </CardHeader>
            </Card>

            <Card className="bg-white border border-gray-200 shadow-sm hover:shadow-md transition-shadow duration-300">
              <CardHeader className="text-center p-6">
                <div className="mx-auto mb-3 w-12 h-12 bg-indigo-100 rounded-full flex items-center justify-center">
                  <Moon className="h-6 w-6 text-indigo-600" />
                </div>
                <CardTitle className="text-gray-900 text-lg mb-2">타로 리딩</CardTitle>
                <CardDescription className="text-gray-600 text-sm leading-relaxed">
                  신비로운 타로카드를 통해 현재와 미래의 
                  가능성을 탐색해보세요
                </CardDescription>
              </CardHeader>
            </Card>
          </div>
        </section>

        {/* 소셜 로그인 섹션 */}
        <section className="w-full px-6 pb-12">
          <div className="text-center mb-6">
            <h3 className="text-xl font-bold text-gray-900 mb-1">간편 로그인</h3>
            <p className="text-gray-600 text-sm">소셜 계정으로 빠르게 시작하세요</p>
          </div>
          
          <div className="space-y-3 max-w-sm mx-auto">
            <Button 
              className="w-full bg-white hover:bg-gray-50 text-gray-900 font-medium py-3 rounded-lg border border-gray-300 flex items-center justify-center space-x-2 shadow-sm"
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
          </div>
        </section>
      </main>

      {/* 푸터 */}
      <footer className="w-full border-t border-gray-200 py-6 px-6 mt-auto">
        <div className="text-center">
          <p className="text-gray-500 text-xs">
            © 2024 Fortune. 모든 권리 보유.
          </p>
        </div>
      </footer>
    </div>
  );
}

