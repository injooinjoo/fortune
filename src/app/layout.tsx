import type { Metadata } from 'next';
import { Lato, Geist_Mono } from 'next/font/google'; // Changed Geist to Lato
import './globals.css';
import { Toaster } from "@/components/ui/toaster";
import Providers from '@/components/providers';
import ClientOnly from '@/components/client-only';
import BackgroundAudioPlayer from '@/components/background-audio-player';
import ConditionalLayout from '@/components/ConditionalLayout';

const lato = Lato({ // Changed to Lato
  variable: '--font-lato', // Changed variable name
  subsets: ['latin'],
  weight: ['300', '400', '700'] // Added common weights for Lato
});

const geistMono = Geist_Mono({
  variable: '--font-geist-mono',
  subsets: ['latin'],
});

export const metadata: Metadata = {
  title: '운세',
  description: '당신의 운명을 탐험하고 새로운 가능성을 발견하세요.',
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="ko" suppressHydrationWarning>
      {/* Changed font variable in body className */}
      <body className={`${lato.variable} ${geistMono.variable} antialiased`}>
        <script
          dangerouslySetInnerHTML={{
            __html: `
              // 전역 에러 핸들링 - React DevTools 및 브라우저 확장 프로그램 에러 방지
              window.addEventListener('error', function(e) {
                // React DevTools, 광고 차단기, 기타 확장 프로그램 에러 무시
                if (
                  e.filename && (
                    e.filename.includes('extension://') ||
                    e.filename.includes('ads.') ||
                    e.filename.includes('inspector.') ||
                    e.filename.includes('chrome-extension://') ||
                    e.filename.includes('moz-extension://')
                  )
                ) {
                  e.preventDefault();
                  e.stopImmediatePropagation();
                  return false;
                }
                
                // React Error #31 관련 에러 무시 (개발 환경이 아닌 경우)
                if (
                  e.message && 
                  e.message.includes('Minified React error #31') &&
                  typeof window !== 'undefined' &&
                  !window.location.hostname.includes('localhost')
                ) {
                  e.preventDefault();
                  e.stopImmediatePropagation();
                  return false;
                }
              });
              
              // Promise rejection 에러 처리
              window.addEventListener('unhandledrejection', function(e) {
                // 개발 환경이 아닌 경우 확장 프로그램 관련 에러 무시
                if (
                  typeof window !== 'undefined' &&
                  !window.location.hostname.includes('localhost') &&
                  e.reason && (
                    (typeof e.reason === 'string' && e.reason.includes('Extension')) ||
                    (e.reason.stack && e.reason.stack.includes('extension://'))
                  )
                ) {
                  e.preventDefault();
                  return false;
                }
              });
            `,
          }}
        />
        <Providers>
          <ConditionalLayout>
            {children}
          </ConditionalLayout>
          <Toaster />
          {/* 임시로 오디오 플레이어 비활성화
          <ClientOnly>
            <BackgroundAudioPlayer />
          </ClientOnly>
          */}
        </Providers>
      </body>
    </html>
  );
}
