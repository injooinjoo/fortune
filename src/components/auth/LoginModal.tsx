"use client"

import React from "react"
import {
  Dialog,
  DialogTrigger,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogDescription,
} from "@/components/ui/dialog"
import { Button } from "@/components/ui/button"
import { supabase } from "@/lib/supabase"
import { useTheme } from "next-themes"

interface LoginModalProps {
  trigger: React.ReactNode
}

function GoogleIcon(props: React.SVGProps<SVGSVGElement>) {
  return (
    <svg viewBox="0 0 24 24" aria-hidden="true" {...props}>
      <path
        d="M21.35 11.1h-9.16v2.92h5.32c-.23 1.42-.94 2.61-2 3.41v2.83h3.23c1.89-1.73 2.98-4.26 2.98-7.16z"
        fill="#4285F4"
      />
      <path d="M12.18 22c2.7 0 4.96-.9 6.61-2.44l-3.23-2.83c-.9.6-2.05.96-3.38.96-2.6 0-4.8-1.76-5.58-4.12H3.22v2.59C4.94 19.84 8.3 22 12.18 22z" fill="#34A853"
      />
      <path
        d="M6.6 13.57a5.99 5.99 0 010-3.14v-2.6H3.23a10.04 10.04 0 000 8.34l3.37-2.6z"
        fill="#FBBC05"
      />
      <path
        d="M12.18 5.77c1.47 0 2.8.5 3.84 1.48l2.87-2.87C17.12 2.5 14.86 1.58 12.18 1.58c-3.88 0-7.24 2.16-8.94 5.3l3.37 2.6c.79-2.36 2.98-4.1 5.57-4.1z"
        fill="#EA4335"
      />
    </svg>
  )
}

function KakaoIcon(props: React.SVGProps<SVGSVGElement>) {
  return (
    <svg viewBox="0 0 24 24" aria-hidden="true" {...props}>
      <path d="M12 2C6.48 2 2 5.94 2 10.6c0 2.98 2.02 5.64 5.06 7.1L6 22l4.46-2.44c.5.07 1.02.1 1.54.1 5.52 0 10-3.94 10-8.6S17.52 2 12 2z"
        fill="#3C1E1E"
      />
    </svg>
  )
}

export default function LoginModal({ trigger }: LoginModalProps) {
  const { theme } = useTheme()
  const isDarkMode = theme === 'dark'
  
  const handleSocialLogin = async (provider: "google" | "kakao") => {
    try {
      if (provider === "google") {
        const { data, error } = await supabase.auth.signInWithOAuth({
          provider: 'google',
          options: {
            redirectTo: `${window.location.origin}/auth/callback`
          }
        });
        
        if (error) {
          console.error('Google 로그인 오류:', error);
          alert('로그인 중 오류가 발생했습니다. 다시 시도해주세요.');
        }
      } else if (provider === "kakao") {
        // 카카오 로그인은 나중에 구현
        alert('카카오 로그인은 준비 중입니다.');
      }
    } catch (error) {
      console.error('로그인 오류:', error);
      alert('로그인 중 오류가 발생했습니다.');
    }
  }

  return (
    <Dialog>
      <DialogTrigger asChild>{trigger}</DialogTrigger>
      <DialogContent className="sm:max-w-[420px]">
        <DialogHeader className="space-y-2 text-center">
          <DialogTitle>로그인 / 회원가입</DialogTitle>
          <DialogDescription>
            SNS 계정으로 1초 만에 시작하세요.
          </DialogDescription>
        </DialogHeader>
        <div className="mt-6 space-y-3">
          <Button
            variant="outline"
            className={`w-full py-3 font-medium flex items-center justify-center space-x-3 transition-colors ${
              isDarkMode 
                ? 'bg-gray-800 border-gray-600 text-white hover:bg-gray-700' 
                : 'bg-white border-gray-300 text-gray-900 hover:bg-gray-50'
            }`}
            onClick={() => void handleSocialLogin("google")}
          >
            <GoogleIcon className="h-5 w-5" />
            <span>Google로 시작하기</span>
          </Button>
          <Button
            className="w-full py-3 bg-[#FEE500] hover:bg-[#f7d900] text-black font-medium flex items-center justify-center space-x-3 transition-colors"
            onClick={() => void handleSocialLogin("kakao")}
          >
            <KakaoIcon className="h-5 w-5" />
            <span>카카오로 시작하기</span>
          </Button>
        </div>
      </DialogContent>
    </Dialog>
  )
}
