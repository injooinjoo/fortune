"use client";

import React, { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { auth } from '@/lib/supabase'; // Supabase auth 객체 가져오기
import type { User } from '@supabase/supabase-js';
import { FortuneCompassIcon } from '@/components/icons/fortune-compass-icon';

export default function HomePage() {
  const router = useRouter();
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const { data: { subscription } } = auth.onAuthStateChanged((currentUser: any) => {
      setUser(currentUser);
      setLoading(false);
      
      if (!currentUser) {
        // 로그인하지 않은 사용자는 인증 페이지로 리디렉션
        router.push('/auth/selection');
      }
    });

    return () => subscription?.unsubscribe();
  }, [router]);

  const handleLogout = async () => {
    try {
      await auth.signOut();
      router.push('/auth/selection'); // 로그아웃 후 로그인 선택 페이지로 이동
    } catch (error) {
      console.error("로그아웃 실패:", error);
    }
  };

  if (loading) {
    return (
      <div className="min-h-screen flex flex-col items-center justify-center bg-background text-foreground p-4">
        <FortuneCompassIcon className="h-12 w-12 text-primary animate-spin mb-4" />
        <p className="text-muted-foreground">사용자 정보 확인 중...</p>
      </div>
    );
  }

  if (!user) {
    // 이 경우는 useEffect에서 router.push로 처리되지만, 만약을 위한 방어 코드
    return null; 
  }

  return (
    <div className="min-h-screen flex flex-col items-center justify-center bg-background text-foreground p-4">
      <Card className="w-full max-w-md shadow-xl">
        <CardHeader className="text-center">
          <div className="mx-auto mb-6 h-16 w-16">
            <FortuneCompassIcon className="h-16 w-16 text-primary" />
          </div>
          <CardTitle className="text-2xl">운세 탐험 홈</CardTitle>
          <CardDescription className="mt-2">
            {user.user_metadata.user_name || user.user_metadata.user_email || '사용자'}님, 환영합니다!
          </CardDescription>
        </CardHeader>
        <CardContent className="space-y-4 p-6 text-center">
          <p>성공적으로 로그인되었습니다.</p>
          <p className="text-sm text-muted-foreground">이제 다양한 운세를 탐험할 준비가 되었습니다.</p>
          {/* 여기에 실제 홈 콘텐츠가 들어갑니다. 예: 운세 카테고리 카드 등 */}
          <Button 
            onClick={() => router.push('/')} // 프로필 설정 페이지로 임시 이동 (추후 실제 운세 보기 페이지로 변경)
            variant="outline"
            className="w-full mt-4"
          >
            프로필 다시 설정하기 (임시)
          </Button>
        </CardContent>
      </Card>
      <Button onClick={handleLogout} variant="link" className="mt-8 text-primary">
        로그아웃
      </Button>
       <footer className="py-8 text-center text-xs text-muted-foreground">
         <p>&copy; 운세 탐험. 모든 운명은 당신의 선택에 달려있습니다.</p>
      </footer>
    </div>
  );
}
