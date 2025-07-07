"use client";

import Script from "next/script";
import { useEffect } from "react";
import AdErrorBoundary from "./AdErrorBoundary";

// 글로벌 플래그로 스크립트 중복 로드 방지
declare global {
  interface Window {
    __adSenseScriptLoaded?: boolean;
    __adSenseScriptLoading?: boolean;
    adsbygoogle: any[];
  }
}

export default function AdSenseProvider() {
  const clientId = process.env.NEXT_PUBLIC_ADSENSE_CLIENT_ID;

  useEffect(() => {
    // 이미 로드되었거나 로딩 중이면 스킵
    if (window.__adSenseScriptLoaded || window.__adSenseScriptLoading) {
      return;
    }

    // 광고 배열 초기화
    window.adsbygoogle = window.adsbygoogle || [];
  }, []);

  if (!clientId) {
    return null;
  }

  return (
    <AdErrorBoundary>
      {/* Google AdSense 스크립트 - lazyOnload로 변경하여 페이지 로드에 영향 최소화 */}
      <Script
        id="google-adsense-script"
        src={`https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=${clientId}`}
        crossOrigin="anonymous"
        strategy="lazyOnload"
        onLoad={() => {
          window.__adSenseScriptLoaded = true;
          window.__adSenseScriptLoading = false;
          console.log("✅ AdSense 스크립트 로드 완료");
        }}
        onError={(e) => {
          window.__adSenseScriptLoading = false;
          console.error("❌ AdSense 스크립트 로드 실패:", e);
        }}
        onReady={() => {
          window.__adSenseScriptLoading = true;
        }}
      />
      
      {/* 광고 차단기 감지 */}
      <Script id="adsense-init" strategy="lazyOnload">
        {`
          // 광고 배열 초기화
          window.adsbygoogle = window.adsbygoogle || [];
          
          // 광고 차단기 감지 (지연 실행)
          if (typeof window !== 'undefined') {
            setTimeout(() => {
              if (typeof window.adsbygoogle === 'undefined' || window.adsbygoogle.length === 0) {
                console.log('⚠️ 광고 차단기가 감지되었을 수 있습니다.');
              }
            }, 5000);
          }
        `}
      </Script>
    </AdErrorBoundary>
  );
}