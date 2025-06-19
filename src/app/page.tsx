"use client";

import { FortuneCompassIcon } from "@/components/icons/fortune-compass-icon";
import { Button } from "@/components/ui/button";
import { Card, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Gem, Eye, LayoutTemplate } from "lucide-react";
import React from "react";

export default function LandingPage() {
  const handleLoginClick = () => {
    console.log("로그인 버튼 클릭");
  };

  const handleSocialLogin = (provider: string) => {
    console.log(`${provider} 로그인 클릭`);
  };

  return (
    <div className="min-h-screen flex flex-col bg-background text-foreground">
      <header className="flex items-center justify-between p-4 md:p-6">
        <div className="flex items-center space-x-2 text-xl font-bold">
          <FortuneCompassIcon className="w-6 h-6 text-primary" />
          <span>행운</span>
        </div>
        <Button onClick={handleLoginClick}>로그인</Button>
      </header>

      <main className="flex-1">
        <section className="relative flex flex-col items-center text-center py-20 px-4 overflow-hidden bg-background">
          <div className="absolute inset-0 pointer-events-none bg-gradient-to-br from-primary/20 via-accent/20 to-background" />
          <h1 className="relative z-10 text-3xl md:text-5xl font-extrabold mb-4">
            AI가 분석하는 당신만의 운명 나침반
          </h1>
          <p className="relative z-10 max-w-2xl text-muted-foreground mb-8">
            전통 지혜와 최신 AI 기술을 결합하여 당신의 삶에 대한 깊이 있는 통찰력을 제공합니다.
          </p>
          <div className="relative z-10 w-full max-w-xs space-y-4">
            <Button className="w-full justify-center" onClick={() => handleSocialLogin('Google')}>
              <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48" width="20" height="20" className="mr-2">
                <path fill="#EA4335" d="M24 9.5c3.54 0 6.71 1.22 9.21 3.6l6.85-6.85C35.9 2.38 30.47 0 24 0 14.62 0 6.51 5.38 2.56 13.22l7.98 6.19C12.43 13.72 17.74 9.5 24 9.5z"/>
                <path fill="#4285F4" d="M46.98 24.55c0-1.57-.15-3.09-.38-4.55H24v9.02h12.94c-.58 2.96-2.26 5.48-4.78 7.18l7.73 6c4.51-4.18 7.09-10.36 7.09-17.65z"/>
                <path fill="#FBBC05" d="M10.53 28.59c-.48-1.45-.76-2.99-.76-4.59s.27-3.14.76-4.59l-7.98-6.19C.92 16.46 0 20.12 0 24c0 3.88.92 7.54 2.56 10.78l7.97-6.19z"/>
                <path fill="#34A853" d="M24 48c6.48 0 11.93-2.13 15.89-5.81l-7.73-6c-2.15 1.45-4.92 2.3-8.16 2.3-6.26 0-11.57-4.22-13.47-9.91l-7.98 6.19C6.51 42.62 14.62 48 24 48z"/>
                <path fill="none" d="M0 0h48v48H0z"/>
              </svg>
              Google로 시작하기
            </Button>
            <Button
              className="w-full justify-center bg-[#FEE500] text-black hover:bg-[#FEE500]/90"
              onClick={() => handleSocialLogin('Kakao')}
            >
              <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="20" height="20" className="mr-2">
                <path fill="currentColor" d="M12 2C6.477 2 2 5.813 2 10.176c0 2.923 2.137 5.487 5.338 6.93L6 22l4.184-3.006c.594.09 1.207.138 1.816.138 5.523 0 10-3.813 10-8.176S17.523 2 12 2z" />
              </svg>
              카카오로 시작하기
            </Button>
          </div>
        </section>

        <section className="py-16 px-4 bg-background">
          <div className="grid gap-6 md:grid-cols-3">
            <Card className="text-center">
              <CardHeader>
                <Gem className="mx-auto mb-4 h-8 w-8 text-primary" />
                <CardTitle>사주팔자</CardTitle>
                <CardDescription>전통 명리학으로 당신의 근본 운을 풀이합니다.</CardDescription>
              </CardHeader>
            </Card>
            <Card className="text-center">
              <CardHeader>
                <Eye className="mx-auto mb-4 h-8 w-8 text-primary" />
                <CardTitle>AI 관상</CardTitle>
                <CardDescription>얼굴 특징을 분석해 숨겨진 운명을 찾아드립니다.</CardDescription>
              </CardHeader>
            </Card>
            <Card className="text-center">
              <CardHeader>
                <LayoutTemplate className="mx-auto mb-4 h-8 w-8 text-primary" />
                <CardTitle>타로카드</CardTitle>
                <CardDescription>미래의 가능성을 타로 카드로 읽어드립니다.</CardDescription>
              </CardHeader>
            </Card>
          </div>
        </section>
      </main>
    </div>
  );
}

