# 🎯 Google AdSense 구현 가이드

## 📋 목차
1. [빠른 시작](#1-빠른-시작)
2. [컴포넌트 구조](#2-컴포넌트-구조)
3. [광고 타입별 구현](#3-광고-타입별-구현)
4. [고급 기능](#4-고급-기능)
5. [테스트 및 디버깅](#5-테스트-및-디버깅)
6. [성능 최적화](#6-성능-최적화)
7. [정책 및 주의사항](#7-정책-및-주의사항)

## 1. 빠른 시작

### 1.1 환경 변수 설정
`.env.local` 파일에 AdSense 정보 추가:
```env
# AdSense 설정
NEXT_PUBLIC_GOOGLE_ADSENSE_CLIENT_ID=ca-pub-xxxxxxxxxx
NEXT_PUBLIC_GOOGLE_ADSENSE_SLOT_ID_01=xxxxxxxxxx  # 기본 슬롯
NEXT_PUBLIC_GOOGLE_ADSENSE_SLOT_ID_02=xxxxxxxxxx  # 보조 슬롯
```

### 1.2 기본 사용법
```tsx
import { GoogleAdsense } from '@/components/adsense/google-adsense';

// 페이지에 광고 추가
export default function FortunePage() {
  return (
    <div>
      <h1>운세 결과</h1>
      <GoogleAdsense slotType="primary" />
      <FortuneResult />
      <GoogleAdsense slotType="secondary" />
    </div>
  );
}
```

## 2. 컴포넌트 구조

### 2.1 핵심 컴포넌트 계층
```
src/components/adsense/
├── AdSenseProvider.tsx       # 전역 AdSense 스크립트 관리
├── GoogleAdsense.tsx          # 메인 광고 컴포넌트
├── DisplayAd.tsx              # 디스플레이 광고
├── InFeedAd.tsx              # 인피드 광고
├── NativeAd.tsx              # 네이티브 광고
├── FortunePageAd.tsx         # 운세 페이지 전용 광고
└── hooks/
    └── useAdRevenue.ts       # 광고 수익 추적
```

### 2.2 AdSenseProvider 구현
```tsx
// src/components/adsense/AdSenseProvider.tsx
'use client';

import Script from 'next/script';
import { createContext, useContext, useState } from 'react';

interface AdSenseContextType {
  isLoaded: boolean;
  isTestMode: boolean;
}

const AdSenseContext = createContext<AdSenseContextType>({
  isLoaded: false,
  isTestMode: process.env.NODE_ENV === 'development'
});

export function AdSenseProvider({ children }: { children: React.ReactNode }) {
  const [isLoaded, setIsLoaded] = useState(false);
  const clientId = process.env.NEXT_PUBLIC_GOOGLE_ADSENSE_CLIENT_ID;

  return (
    <AdSenseContext.Provider value={{ isLoaded, isTestMode: !clientId }}>
      {clientId && (
        <Script
          id="google-adsense"
          src={`https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=${clientId}`}
          crossOrigin="anonymous"
          strategy="afterInteractive"
          onLoad={() => setIsLoaded(true)}
        />
      )}
      {children}
    </AdSenseContext.Provider>
  );
}

export const useAdSense = () => useContext(AdSenseContext);
```

### 2.3 메인 광고 컴포넌트
```tsx
// src/components/adsense/GoogleAdsense.tsx
'use client';

import { useEffect, useRef } from 'react';
import { useAdSense } from './AdSenseProvider';

interface GoogleAdsenseProps {
  slotType: 'primary' | 'secondary';
  format?: 'auto' | 'rectangle' | 'horizontal' | 'vertical';
  responsive?: boolean;
  className?: string;
}

export function GoogleAdsense({
  slotType,
  format = 'auto',
  responsive = true,
  className = ''
}: GoogleAdsenseProps) {
  const { isLoaded, isTestMode } = useAdSense();
  const adRef = useRef<HTMLDivElement>(null);
  
  const slotId = slotType === 'primary' 
    ? process.env.NEXT_PUBLIC_GOOGLE_ADSENSE_SLOT_ID_01
    : process.env.NEXT_PUBLIC_GOOGLE_ADSENSE_SLOT_ID_02;

  useEffect(() => {
    if (!isLoaded || !adRef.current || isTestMode) return;

    try {
      // @ts-ignore
      (window.adsbygoogle = window.adsbygoogle || []).push({});
    } catch (error) {
      console.error('AdSense error:', error);
    }
  }, [isLoaded, isTestMode]);

  if (isTestMode) {
    return (
      <div className={`bg-gray-200 border-2 border-dashed border-gray-400 p-4 text-center ${className}`}>
        <p className="text-gray-600">광고 영역 ({slotType})</p>
        <p className="text-xs text-gray-500">개발 모드</p>
      </div>
    );
  }

  return (
    <div ref={adRef} className={`adsense-container ${className}`}>
      <ins
        className="adsbygoogle"
        style={{ display: 'block' }}
        data-ad-client={process.env.NEXT_PUBLIC_GOOGLE_ADSENSE_CLIENT_ID}
        data-ad-slot={slotId}
        data-ad-format={format}
        data-full-width-responsive={responsive}
      />
    </div>
  );
}
```

## 3. 광고 타입별 구현

### 3.1 운세 페이지 전용 광고
```tsx
// src/components/adsense/FortunePageAd.tsx
import { GoogleAdsense } from './GoogleAdsense';
import { useState, useEffect } from 'react';

export function FortunePageAd() {
  const [showAd, setShowAd] = useState(false);

  useEffect(() => {
    // 3초 후 광고 표시 (사용자 경험 개선)
    const timer = setTimeout(() => setShowAd(true), 3000);
    return () => clearTimeout(timer);
  }, []);

  if (!showAd) return null;

  return (
    <div className="my-8 animate-fade-in">
      <div className="text-center mb-2">
        <span className="text-xs text-gray-500">광고</span>
      </div>
      <GoogleAdsense 
        slotType="primary" 
        format="rectangle"
        className="max-w-[336px] mx-auto"
      />
    </div>
  );
}
```

### 3.2 인피드 광고
```tsx
// src/components/adsense/InFeedAd.tsx
export function InFeedAd({ index }: { index: number }) {
  // 5개 항목마다 광고 삽입
  if (index % 5 !== 0) return null;

  return (
    <div className="border rounded-lg p-4 bg-gray-50">
      <GoogleAdsense 
        slotType="secondary" 
        format="horizontal"
        className="min-h-[90px]"
      />
    </div>
  );
}
```

### 3.3 네이티브 광고
```tsx
// src/components/adsense/NativeAd.tsx
export function NativeAd() {
  return (
    <div className="native-ad-container">
      <ins
        className="adsbygoogle"
        style={{ display: 'block' }}
        data-ad-format="autorelaxed"
        data-ad-client={process.env.NEXT_PUBLIC_GOOGLE_ADSENSE_CLIENT_ID}
        data-ad-slot={process.env.NEXT_PUBLIC_GOOGLE_ADSENSE_SLOT_ID_02}
      />
    </div>
  );
}
```

## 4. 고급 기능

### 4.1 광고 수익 추적
```tsx
// src/hooks/useAdRevenue.ts
import { useEffect } from 'react';
import { analytics } from '@/lib/analytics';

export function useAdRevenue(pageName: string) {
  useEffect(() => {
    // 광고 노출 추적
    analytics.track('ad_impression', {
      page: pageName,
      timestamp: new Date().toISOString()
    });

    // 광고 클릭 추적 (AdSense 이벤트 리스너)
    const handleAdClick = (e: MouseEvent) => {
      const target = e.target as HTMLElement;
      if (target.closest('.adsbygoogle')) {
        analytics.track('ad_click', {
          page: pageName,
          timestamp: new Date().toISOString()
        });
      }
    };

    document.addEventListener('click', handleAdClick);
    return () => document.removeEventListener('click', handleAdClick);
  }, [pageName]);
}
```

### 4.2 프리미엄 사용자 처리
```tsx
// src/components/adsense/ConditionalAd.tsx
import { useUser } from '@/hooks/use-user';
import { GoogleAdsense } from './GoogleAdsense';

export function ConditionalAd(props: any) {
  const { user } = useUser();
  
  // 프리미엄 사용자는 광고 없음
  if (user?.isPremium) {
    return null;
  }

  return <GoogleAdsense {...props} />;
}
```

### 4.3 A/B 테스트
```tsx
// src/components/adsense/ABTestAd.tsx
import { useEffect, useState } from 'react';
import { GoogleAdsense } from './GoogleAdsense';

export function ABTestAd() {
  const [variant, setVariant] = useState<'A' | 'B'>('A');

  useEffect(() => {
    // 사용자를 50:50으로 분할
    setVariant(Math.random() > 0.5 ? 'A' : 'B');
  }, []);

  return (
    <div data-variant={variant}>
      <GoogleAdsense 
        slotType="primary"
        format={variant === 'A' ? 'rectangle' : 'horizontal'}
      />
    </div>
  );
}
```

## 5. 테스트 및 디버깅

### 5.1 테스트 페이지
```tsx
// src/app/test-ads/page.tsx
export default function TestAdsPage() {
  return (
    <div className="container mx-auto p-4 space-y-8">
      <h1 className="text-2xl font-bold">광고 테스트 페이지</h1>
      
      <section>
        <h2 className="text-xl mb-4">기본 광고</h2>
        <GoogleAdsense slotType="primary" />
      </section>

      <section>
        <h2 className="text-xl mb-4">보조 광고</h2>
        <GoogleAdsense slotType="secondary" />
      </section>

      <section>
        <h2 className="text-xl mb-4">네이티브 광고</h2>
        <NativeAd />
      </section>
    </div>
  );
}
```

### 5.2 디버그 모드
```tsx
// src/lib/adsense-debug.ts
export const adDebug = {
  log: (message: string, data?: any) => {
    if (process.env.NODE_ENV === 'development') {
      console.log(`[AdSense] ${message}`, data);
    }
  },
  
  checkSlots: () => {
    const slots = {
      primary: process.env.NEXT_PUBLIC_GOOGLE_ADSENSE_SLOT_ID_01,
      secondary: process.env.NEXT_PUBLIC_GOOGLE_ADSENSE_SLOT_ID_02
    };
    
    Object.entries(slots).forEach(([key, value]) => {
      if (!value) {
        console.warn(`[AdSense] ${key} slot is not configured`);
      }
    });
  }
};
```

## 6. 성능 최적화

### 6.1 지연 로딩
```tsx
import dynamic from 'next/dynamic';

const LazyAd = dynamic(() => import('./GoogleAdsense'), {
  loading: () => <div className="h-[250px] bg-gray-100 animate-pulse" />,
  ssr: false
});
```

### 6.2 뷰포트 기반 로딩
```tsx
import { useInView } from 'react-intersection-observer';

export function ViewportAd(props: any) {
  const { ref, inView } = useInView({
    threshold: 0.1,
    triggerOnce: true
  });

  return (
    <div ref={ref}>
      {inView && <GoogleAdsense {...props} />}
    </div>
  );
}
```

### 6.3 광고 새로고침 방지
```tsx
// 페이지 전환 시 광고 재로딩 방지
export function PersistentAd() {
  const [key] = useState(() => Math.random());
  
  return <GoogleAdsense key={key} slotType="primary" />;
}
```

## 7. 정책 및 주의사항

### 7.1 필수 준수 사항
- ✅ 광고임을 명확히 표시 ("광고" 라벨 필수)
- ✅ 자체 클릭 금지
- ✅ 클릭 유도 문구 금지 ("클릭해주세요" 등)
- ✅ 콘텐츠와 광고 명확히 구분
- ✅ 성인/도박 콘텐츠 근처 광고 금지

### 7.2 권장 사항
- 📱 모바일 최적화 필수
- 🎨 사이트 디자인과 조화
- 📊 3개 이하의 광고 유닛 권장
- ⚡ 페이지 로딩 속도 고려
- 🔍 정기적인 수익 분석

### 7.3 한국 특별 규정
- 개인정보 처리방침에 광고 관련 내용 명시
- 쿠키 사용 동의 획득
- 14세 미만 이용 제한 명시

---

**마지막 업데이트**: 2025년 7월 7일  
**문서 상태**: ✅ 최신 구현 반영됨