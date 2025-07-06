"use client";

import Script from "next/script";

export default function AdSenseProvider() {
  const clientId = process.env.NEXT_PUBLIC_ADSENSE_CLIENT_ID;

  if (!clientId) {
    return null;
  }

  return (
    <>
      {/* Google AdSense 스크립트 */}
      <Script
        async
        src={`https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=${clientId}`}
        crossOrigin="anonymous"
        strategy="afterInteractive"
        onError={(e) => {
          console.error("AdSense 스크립트 로드 실패:", e);
        }}
      />
      
      {/* 광고 차단기 감지 (선택사항) */}
      <Script id="adsense-init" strategy="afterInteractive">
        {`
          window.adsbygoogle = window.adsbygoogle || [];
          
          // 광고 차단기 감지
          setTimeout(() => {
            if (typeof window.adsbygoogle === 'undefined') {
              console.log('광고 차단기가 감지되었습니다.');
            }
          }, 3000);
        `}
      </Script>
    </>
  );
}