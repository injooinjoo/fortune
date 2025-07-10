"use client";

import { useState, useEffect } from 'react';
import { X } from 'lucide-react';
import { logger } from '@/lib/logger';

export function BrowserExtensionWarning() {
  const [showWarning, setShowWarning] = useState(false);
  const [extensionName, setExtensionName] = useState<string | null>(null);

  useEffect(() => {
    // 브라우저 확장 프로그램 간섭 감지
    const detectInterference = () => {
      const suspiciousKeys = Object.keys(localStorage).filter(key => 
        key.includes('fortune-auth-token-code-verifier') || 
        (key.includes('code-verifier') && !key.startsWith('sb-'))
      );

      if (suspiciousKeys.length > 0) {
        logger.warn('Browser extension interference detected:', suspiciousKeys);
        
        // 일반적인 패턴으로 확장 프로그램 추측
        if (suspiciousKeys.some(key => key.includes('fortune'))) {
          setExtensionName('a browser extension');
        }
        
        setShowWarning(true);
      }
    };

    // 초기 확인
    detectInterference();

    // storage 이벤트 리스너
    const handleStorageChange = () => {
      detectInterference();
    };

    window.addEventListener('storage', handleStorageChange);

    return () => {
      window.removeEventListener('storage', handleStorageChange);
    };
  }, []);

  if (!showWarning) return null;

  return (
    <div className="fixed top-4 right-4 max-w-md bg-yellow-50 border border-yellow-200 rounded-lg shadow-lg p-4 z-50">
      <div className="flex items-start justify-between">
        <div className="flex-1">
          <h3 className="text-sm font-semibold text-yellow-800 mb-1">
            브라우저 확장 프로그램 간섭 감지
          </h3>
          <p className="text-sm text-yellow-700">
            {extensionName ? `${extensionName}이(가)` : '브라우저 확장 프로그램이'} 
            로그인 프로세스를 방해하고 있을 수 있습니다. 
            로그인 문제가 계속되면 확장 프로그램을 일시적으로 비활성화하거나 
            시크릿 모드에서 시도해 주세요.
          </p>
        </div>
        <button
          onClick={() => setShowWarning(false)}
          className="ml-3 text-yellow-600 hover:text-yellow-800"
          aria-label="경고 닫기"
        >
          <X className="h-5 w-5" />
        </button>
      </div>
    </div>
  );
}