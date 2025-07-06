"use client";

import React, { Component, ReactNode, ErrorInfo } from 'react';
import { errorHandler } from '@/lib/error-handler';
import * as Sentry from '@sentry/nextjs';

interface Props {
  children: ReactNode;
  fallback?: ReactNode;
}

interface State {
  hasError: boolean;
  errorType: string | null;
}

/**
 * 보안 강화된 에러 바운더리
 * React Error #31 (Promise 렌더링)을 안전하게 처리
 */
export class SecureErrorBoundary extends Component<Props, State> {
  constructor(props: Props) {
    super(props);
    this.state = { hasError: false, errorType: null };
  }

  static getDerivedStateFromError(error: Error): State {
    // React Error #31 (Promise rendering) 감지
    const isPromiseRenderError = 
      error.message?.includes('Objects are not valid as a React child') ||
      error.message?.includes('object Promise') ||
      error.message?.includes('Minified React error #31');

    return {
      hasError: true,
      errorType: isPromiseRenderError ? 'promise-render' : 'general'
    };
  }

  componentDidCatch(error: Error, errorInfo: ErrorInfo) {
    // 통합된 에러 핸들러를 사용하여 안전하게 로깅
    errorHandler.logError(error, `error_boundary_${this.state.errorType}`);
    
    // Promise 렌더링 에러가 아닌 경우만 상세 처리
    if (this.state.errorType !== 'promise-render') {
      // Sentry로 에러 보고
      Sentry.withScope((scope) => {
        scope.setContext('errorBoundary', {
          errorType: this.state.errorType,
          componentStack: errorInfo.componentStack,
        });
        scope.setLevel('error');
        Sentry.captureException(error);
      });
      
      if (process.env.NODE_ENV === 'development') {
        console.warn('Error caught by boundary:', errorHandler.getUserFriendlyMessage(error));
      }
    }
  }

  render() {
    if (this.state.hasError) {
      // Promise 렌더링 에러의 경우 조용히 null 반환
      if (this.state.errorType === 'promise-render') {
        return null;
      }

      // 일반 에러의 경우 사용자 친화적 fallback UI 표시
      return this.props.fallback || (
        <div className="p-4 text-center">
          <p className="text-gray-600">
            {errorHandler.getUserFriendlyMessage('일반적인 에러')}
          </p>
          <button 
            onClick={() => window.location.reload()} 
            className="mt-2 px-4 py-2 bg-purple-600 text-white rounded hover:bg-purple-700"
          >
            새로고침
          </button>
        </div>
      );
    }

    return this.props.children;
  }
}

export default SecureErrorBoundary;