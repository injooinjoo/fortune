
import type { Metadata } from 'next';
import { Lato, Geist_Mono } from 'next/font/google'; // Changed Geist to Lato
import './globals.css';
import { Toaster } from "@/components/ui/toaster";
import Providers from '@/components/providers';
import ClientOnly from '@/components/client-only';
import BackgroundAudioPlayer from '@/components/background-audio-player';

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
  title: '운세 탐험',
  description: '당신의 운명을 탐험하고 새로운 가능성을 발견하세요.',
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="ko">
      {/* Changed font variable in body className */}
      <body className={`${lato.variable} ${geistMono.variable} antialiased`}>
        <Providers>
          {children}
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
