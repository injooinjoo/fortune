"use client";

import { useEffect, useState, useRef } from "react";
import { usePathname } from "next/navigation";

interface GoogleAdsenseProps {
  slot?: string;
  useSecondarySlot?: boolean;
  style?: React.CSSProperties;
  layout?: string;
  layoutKey?: string;
  format?: string;
  responsive?: boolean;
  className?: string;
  fallback?: React.ReactNode;
  testMode?: boolean;
}

declare global {
  interface Window {
    adsbygoogle: any[];
    __adSenseScriptLoaded?: boolean;
    __adSenseScriptLoading?: boolean;
    __adSenseSlots?: Set<string>;
  }
}

// 광고 로드 상태를 전역으로 관리하기 위한 헬퍼 함수
function getAdSlotKey(clientId: string, adSlot: string): string {
  return `${clientId}-${adSlot}`;
}

function isAdSlotLoaded(clientId: string, adSlot: string): boolean {
  if (typeof window === 'undefined') return false;
  window.__adSenseSlots = window.__adSenseSlots || new Set();
  return window.__adSenseSlots.has(getAdSlotKey(clientId, adSlot));
}

function markAdSlotLoaded(clientId: string, adSlot: string): void {
  if (typeof window === 'undefined') return;
  window.__adSenseSlots = window.__adSenseSlots || new Set();
  window.__adSenseSlots.add(getAdSlotKey(clientId, adSlot));
}

export default function GoogleAdsense({
  slot,
  useSecondarySlot = false,
  style = { display: "block" },
  layout = "",
  layoutKey = "",
  format = "auto",
  responsive = true,
  className = "",
  fallback = null,
  testMode = false,
}: GoogleAdsenseProps) {
  const [isAdBlockerDetected, setIsAdBlockerDetected] = useState(false);
  const [isLoading, setIsLoading] = useState(true);
  const [isScriptReady, setIsScriptReady] = useState(false);
  const adRef = useRef<HTMLDivElement>(null);
  const loadAttemptRef = useRef(0);
  const timeoutRef = useRef<NodeJS.Timeout>();

  // 슬롯 ID 선택 (2개만 사용)
  const getAdSlot = () => {
    if (slot) return slot; // 직접 지정된 슬롯 우선
    
    // 두 번째 슬롯 사용 여부
    return useSecondarySlot 
      ? process.env.NEXT_PUBLIC_ADSENSE_DISPLAY_SLOT 
      : process.env.NEXT_PUBLIC_ADSENSE_SLOT_ID;
  };

  // 광고 차단기 감지
  useEffect(() => {
    const detectAdBlocker = () => {
      const testAd = document.createElement('div');
      testAd.innerHTML = '&nbsp;';
      testAd.className = 'adsbox';
      testAd.style.position = 'absolute';
      testAd.style.left = '-9999px';
      document.body.appendChild(testAd);

      setTimeout(() => {
        if (testAd.offsetHeight === 0) {
          setIsAdBlockerDetected(true);
        }
        document.body.removeChild(testAd);
        setIsLoading(false);
      }, 100);
    };

    detectAdBlocker();
  }, []);

  // AdSense 스크립트 로드 상태 모니터링
  useEffect(() => {
    const checkScriptStatus = () => {
      if (window.__adSenseScriptLoaded) {
        setIsScriptReady(true);
      }
    };

    // 초기 체크
    checkScriptStatus();

    // 스크립트가 아직 로드되지 않았다면 폴링
    if (!window.__adSenseScriptLoaded) {
      const interval = setInterval(checkScriptStatus, 500);
      return () => clearInterval(interval);
    }
  }, []);

  // 광고 로드 로직 (디바운싱 적용)
  useEffect(() => {
    const clientId = process.env.NEXT_PUBLIC_ADSENSE_CLIENT_ID;
    const adSlot = getAdSlot();
    
    if (!clientId || !adSlot || !isScriptReady || isAdBlockerDetected) {
      return;
    }

    // 이미 이 슬롯에 광고가 로드되었는지 확인
    if (isAdSlotLoaded(clientId, adSlot)) {
      console.log(`✅ 광고 슬롯 ${adSlot}은 이미 로드됨`);
      return;
    }

    // 타임아웃 설정으로 무한 로딩 방지
    timeoutRef.current = setTimeout(() => {
      try {
        if (!adRef.current) return;

        // 컨테이너 너비 체크
        const adContainer = adRef.current;
        if (adContainer && adContainer.clientWidth < 250 && format === "auto") {
          console.warn("광고 컨테이너 너비 부족:", adContainer.clientWidth);
          return;
        }

        // ins 요소 상태 확인
        const insElement = adRef.current.querySelector('ins.adsbygoogle');
        if (insElement) {
          const adStatus = insElement.getAttribute('data-ad-status');
          if (adStatus === 'filled' || adStatus === 'unfilled') {
            markAdSlotLoaded(clientId, adSlot);
            return;
          }
        }

        // 최대 시도 횟수 제한
        if (loadAttemptRef.current >= 3) {
          console.warn(`❌ 광고 로드 최대 시도 횟수 초과: ${adSlot}`);
          return;
        }

        // 광고 로드
        if (window.adsbygoogle && window.adsbygoogle.push) {
          window.adsbygoogle.push({});
          markAdSlotLoaded(clientId, adSlot);
          loadAttemptRef.current++;
          console.log(`✅ 광고 로드 시도: ${adSlot}`);
        }
      } catch (error) {
        console.error("❌ AdSense 광고 로드 실패:", error);
      }
    }, 1000); // 1초 디바운스

    return () => {
      if (timeoutRef.current) {
        clearTimeout(timeoutRef.current);
      }
    };
  }, [isScriptReady, isAdBlockerDetected, format]);

  // 클라이언트 ID가 없으면 fallback 표시
  const clientId = process.env.NEXT_PUBLIC_ADSENSE_CLIENT_ID;
  const adSlot = getAdSlot();
  
  if (!clientId || !adSlot) {
    console.warn("AdSense 설정이 완료되지 않았습니다.");
    return <>{fallback}</>;
  }

  // 광고 차단기가 감지되면 대체 콘텐츠 표시
  if (isAdBlockerDetected) {
    return (
      <div className={`adsense-blocked ${className}`}>
        {fallback || (
          <div className="text-center p-4 bg-gray-100 dark:bg-gray-800 rounded-lg">
            <p className="text-sm text-gray-600 dark:text-gray-400">
              광고를 통해 무료 서비스를 운영하고 있습니다.
            </p>
            <p className="text-xs text-gray-500 dark:text-gray-500 mt-1">
              광고 차단을 해제해 주시면 감사하겠습니다.
            </p>
          </div>
        )}
      </div>
    );
  }

  // 테스트 모드일 때 테스트 광고 표시
  if (testMode) {
    return (
      <div className={`adsense-test ${className}`} style={style}>
        <div className="bg-yellow-100 dark:bg-yellow-900/20 border-2 border-dashed border-yellow-500 rounded-lg p-4 text-center">
          <p className="text-sm font-semibold text-yellow-800 dark:text-yellow-200">
            [테스트 광고]
          </p>
          <p className="text-xs text-yellow-700 dark:text-yellow-300 mt-1">
            슬롯: {adSlot} | 타입: {useSecondarySlot ? '보조' : '기본'}
          </p>
          <p className="text-xs text-yellow-600 dark:text-yellow-400 mt-1">
            {style.width || '100%'} x {style.height || 'auto'}
          </p>
        </div>
      </div>
    );
  }

  return (
    <div 
      ref={adRef}
      className={`adsense-container ${className}`} 
      style={{ minWidth: format === 'auto' ? '250px' : undefined }}
    >
      <ins
        className="adsbygoogle"
        style={style}
        data-ad-client={clientId}
        data-ad-slot={adSlot}
        data-ad-layout={layout}
        data-ad-layout-key={layoutKey}
        data-ad-format={format}
        data-full-width-responsive={responsive}
        data-ad-test={process.env.NODE_ENV === 'development' ? 'on' : undefined}
      />
    </div>
  );
}