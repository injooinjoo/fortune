import type { Metadata } from 'next';
import { Geist_Mono } from 'next/font/google';
import './globals.css';
import { Toaster } from "@/components/ui/toaster";
import Providers from '@/components/providers';
import ConditionalLayout from '@/components/ConditionalLayout';
import SecureErrorBoundary from '@/components/SecureErrorBoundary';
import AdSenseProvider from '@/components/ads/AdSenseProvider';
import { ChunkLoadErrorBoundary } from '@/components/ads/AdErrorBoundary';

const geistMono = Geist_Mono({
  variable: '--font-geist-mono',
  subsets: ['latin'],
  display: 'swap',
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
      <body className={`${geistMono.variable} antialiased`}>
        <script
          dangerouslySetInnerHTML={{
            __html: `
              // 실제 파일명 기반 React Error #31 차단
              window.addEventListener('error', function(e) {
                if (e.message && 
                    e.message.includes('Minified React error #31') &&
                    e.filename && (
                      e.filename.match(/inspector\.[a-f0-9]+\.js/) ||
                      e.filename.includes('render-error.js') ||
                      e.filename.includes('contentScript.js') ||
                      e.filename.match(/ads\.[a-f0-9]+\.js/) ||
                      e.filename.includes('chrome-extension://') ||
                      e.filename.includes('moz-extension://')
                    )) {
                  e.preventDefault();
                  e.stopImmediatePropagation();
                  return false;
                }
              });
              
              // 개발 환경에서만 로깅
              if (window.location.hostname.includes('localhost')) {
                console.log('🔧 Simple error filtering enabled');
              }
            `,
          }}
        />
        <ChunkLoadErrorBoundary>
          <Providers>
            <SecureErrorBoundary>
              <ConditionalLayout>
                {children}
              </ConditionalLayout>
            </SecureErrorBoundary>
            <Toaster />
            <AdSenseProvider />
          </Providers>
        </ChunkLoadErrorBoundary>
      </body>
    </html>
  );
}