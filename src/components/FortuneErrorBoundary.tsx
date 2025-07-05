"use client";

import React from 'react';
import { AlertTriangle, RefreshCw, Home } from 'lucide-react';
import Link from 'next/link';

interface FortuneErrorBoundaryProps {
  error?: Error | string;
  reset?: () => void;
  fallbackMessage?: string;
}

/**
 * 운세 관련 에러를 위한 전용 에러 바운더리 컴포넌트
 */
export function FortuneErrorBoundary({ 
  error, 
  reset, 
  fallbackMessage = "운세 서비스가 일시적으로 이용할 수 없습니다." 
}: FortuneErrorBoundaryProps) {
  const errorMessage = typeof error === 'string' ? error : error?.message;
  
  // GPT API 관련 에러인지 확인
  const isGPTError = errorMessage?.includes('GPT') || errorMessage?.includes('API');
  const isNetworkError = errorMessage?.includes('fetch') || errorMessage?.includes('network');
  
  let displayMessage = fallbackMessage;
  let actionText = "다시 시도";
  
  if (isGPTError) {
    displayMessage = "AI 운세 분석 서비스가 현재 준비 중입니다. 곧 실제 AI 분석을 제공할 예정입니다.";
    actionText = "새로고침";
  } else if (isNetworkError) {
    displayMessage = "네트워크 연결을 확인하고 다시 시도해주세요.";
  }

  return (
    <div className="min-h-[300px] flex items-center justify-center p-8">
      <div className="text-center max-w-md mx-auto">
        <div className="mb-6">
          <AlertTriangle className="h-12 w-12 text-amber-500 mx-auto mb-4" />
          <h3 className="text-lg font-semibold text-gray-900 mb-2">
            서비스 준비 중
          </h3>
          <p className="text-gray-600 text-sm leading-relaxed">
            {displayMessage}
          </p>
        </div>
        
        <div className="space-y-3">
          {reset && (
            <button
              onClick={reset}
              className="inline-flex items-center px-4 py-2 bg-purple-600 text-white rounded-lg hover:bg-purple-700 transition-colors"
            >
              <RefreshCw className="h-4 w-4 mr-2" />
              {actionText}
            </button>
          )}
          
          <div>
            <Link
              href="/"
              className="inline-flex items-center px-4 py-2 bg-gray-100 text-gray-700 rounded-lg hover:bg-gray-200 transition-colors"
            >
              <Home className="h-4 w-4 mr-2" />
              홈으로 돌아가기
            </Link>
          </div>
        </div>
        
        {process.env.NODE_ENV === 'development' && errorMessage && (
          <details className="mt-6 text-left">
            <summary className="text-xs text-gray-500 cursor-pointer">
              개발자 정보
            </summary>
            <pre className="mt-2 p-2 bg-gray-100 text-xs text-gray-700 rounded overflow-auto">
              {errorMessage}
            </pre>
          </details>
        )}
      </div>
    </div>
  );
}

export default FortuneErrorBoundary;