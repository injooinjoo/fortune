
"use client";

import React from 'react';
import { useRouter } from 'next/navigation';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { useToast } from '@/hooks/use-toast';
import { Mail, LogIn, MessageSquare, Instagram, Smartphone } from 'lucide-react'; // Added Instagram
import Image from 'next/image';

export default function AuthSelectionPage() {
  const router = useRouter();
  const { toast } = useToast();

  const handleAuthMethodSelect = (method: string) => {
    toast({
      title: "인증 방법 선택됨",
      description: `${method} 로그인을 시도합니다. (UI 프로토타입)`,
    });
    // In a real app, you would initiate the respective Firebase auth flow here.
    // For example:
    // if (method === 'Google') { signInWithGoogle(); }
    // Then, on successful authentication, check Firestore for profile and navigate accordingly.
    // router.push('/home'); // Or to profile setup if new user (after actual auth)
  };

  return (
    <div className="min-h-screen flex flex-col items-center justify-center bg-background text-foreground p-4">
      <Card className="w-full max-w-md shadow-xl">
        <CardHeader className="text-center">
          <div className="mx-auto mb-6 h-16 w-16">
            <Image src="https://placehold.co/128x128.png" alt="앱 로고" width={64} height={64} className="rounded-full" data-ai-hint="mystical compass" />
          </div>
          <CardTitle className="text-2xl">운세 탐험</CardTitle>
          <CardDescription className="mt-2">계속하려면 인증 방법을 선택해주세요.</CardDescription>
        </CardHeader>
        <CardContent className="space-y-4 p-6">
          <Button 
            variant="outline" 
            className="w-full justify-center text-base py-6"
            onClick={() => handleAuthMethodSelect('Google')}
          >
            <Mail className="mr-3 h-5 w-5" /> {/* Using Mail for Google as a common icon */}
            Google 계정으로 계속하기
          </Button>
          <Button 
            variant="outline" 
            className="w-full justify-center text-base py-6 bg-[#03C75A] text-white hover:bg-[#03C75A]/90" // Naver Green
            onClick={() => handleAuthMethodSelect('Naver')}
          >
            {/* Naver uses 'N' logo, using generic LogIn as placeholder */}
            <LogIn className="mr-3 h-5 w-5" /> 
            Naver 계정으로 계속하기
          </Button>
          <Button 
            variant="outline" 
            className="w-full justify-center text-base py-6 bg-[#FEE500] text-black hover:bg-[#FEE500]/90" // Kakao Yellow
            onClick={() => handleAuthMethodSelect('Kakao')}
          >
             {/* Kakao uses chat bubble, MessageSquare is a good fit */}
            <MessageSquare className="mr-3 h-5 w-5" />
            Kakao 계정으로 계속하기
          </Button>
          <Button 
            variant="outline" 
            className="w-full justify-center text-base py-6" // Default outline for Instagram
            onClick={() => handleAuthMethodSelect('Instagram')}
          >
            <Instagram className="mr-3 h-5 w-5" />
            Instagram 계정으로 계속하기
          </Button>
          <Button 
            variant="secondary" 
            className="w-full justify-center text-base py-6"
            onClick={() => handleAuthMethodSelect('휴대폰')}
          >
            <Smartphone className="mr-3 h-5 w-5" />
            휴대폰 번호로 인증하기
          </Button>
        </CardContent>
      </Card>
       <footer className="py-8 text-center text-xs text-muted-foreground">
        <p>&copy; {new Date().getFullYear()} 운세 탐험. 모든 운명은 당신의 선택에 달려있습니다.</p>
      </footer>
    </div>
  );
}
