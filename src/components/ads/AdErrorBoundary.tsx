"use client";

import { logger } from '@/lib/logger';
import React, { Component, ReactNode } from 'react';
import { Card, CardContent } from '@/components/ui/card';
import { AlertCircle, RefreshCw } from 'lucide-react';
import { Button } from '@/components/ui/button';

interface Props {
  children: ReactNode;
  fallback?: ReactNode;
  onError?: (error: Error, errorInfo: React.ErrorInfo) => void;
}

interface State {
  hasError: boolean;
  error: Error | null;
  errorCount: number;
}

export default class AdErrorBoundary extends Component<Props, State> {
  private retryTimeoutId: NodeJS.Timeout | null = null;

  constructor(props: Props) {
    super(props);
    this.state = {
      hasError: false,
      error: null,
      errorCount: 0,
    };
  }

  static getDerivedStateFromError(error: Error): State {
    return {
      hasError: true,
      error,
      errorCount: 0,
    };
  }

  componentDidCatch(error: Error, errorInfo: React.ErrorInfo) {
    logger.error('광고 컴포넌트 에러:', error, errorInfo);
    
    // 부모 컴포넌트에 에러 전달
    if (this.props.onError) {
      this.props.onError(error, errorInfo);
    }

    // 에러 카운트 증가
    this.setState(prevState => ({
      errorCount: prevState.errorCount + 1
    }));

    // 3번 이상 에러 발생시 자동 재시도 중지
    if (this.state.errorCount < 3) {
      // 5초 후 자동 재시도
      this.retryTimeoutId = setTimeout(() => {
        this.handleReset();
      }, 5000);
    }
  }

  componentWillUnmount() {
    if (this.retryTimeoutId) {
      clearTimeout(this.retryTimeoutId);
      this.retryTimeoutId = null;
    }
  }

  handleReset = () => {
    if (this.retryTimeoutId) {
      clearTimeout(this.retryTimeoutId);
      this.retryTimeoutId = null;
    }

    this.setState({
      hasError: false,
      error: null,
    });
  };

  render() {
    if (this.state.hasError) {
      // 커스텀 fallback이 제공된 경우
      if (this.props.fallback) {
        return <>{this.props.fallback}</>;
      }

      // 기본 에러 UI
      return (
        <Card className="bg-gray-50 dark:bg-gray-900 border-gray-200 dark:border-gray-800">
          <CardContent className="p-4 text-center space-y-3">
            <div className="flex items-center justify-center gap-2 text-gray-600 dark:text-gray-400">
              <AlertCircle className="w-5 h-5" />
              <span className="text-sm font-medium">광고 로드 중 문제가 발생했습니다</span>
            </div>
            
            {this.state.errorCount < 3 && (
              <p className="text-xs text-gray-500 dark:text-gray-500">
                5초 후 자동으로 재시도합니다...
              </p>
            )}
            
            <Button
              onClick={this.handleReset}
              variant="outline"
              size="sm"
              className="text-xs"
            >
              <RefreshCw className="w-3 h-3 mr-1" />
              다시 시도
            </Button>

            {/* 개발 환경에서만 에러 상세 표시 */}
            {process.env.NODE_ENV === 'development' && this.state.error && (
              <div className="mt-2 p-2 bg-red-50 dark:bg-red-900/20 rounded text-xs text-red-600 dark:text-red-400 text-left">
                <strong>에러:</strong> {this.state.error.message}
              </div>
            )}
          </CardContent>
        </Card>
      );
    }

    return this.props.children;
  }
}

// 청크 로드 에러를 처리하는 특별한 에러 바운더리
export class ChunkLoadErrorBoundary extends Component<Props, State> {
  constructor(props: Props) {
    super(props);
    this.state = {
      hasError: false,
      error: null,
      errorCount: 0,
    };
  }

  static getDerivedStateFromError(error: Error): State | null {
    // ChunkLoadError인 경우 특별 처리
    if (error.name === 'ChunkLoadError' || error.message.includes('Loading chunk')) {
      // 페이지 새로고침을 통해 해결 시도
      if (typeof window !== 'undefined' && window.location) {
        logger.debug('청크 로드 에러 감지 - 페이지 새로고침 시도');
        setTimeout(() => {
          window.location.reload();
        }, 1000);
      }
      
      return {
        hasError: true,
        error,
        errorCount: 0,
      };
    }
    
    return null;
  }

  componentDidCatch(error: Error, errorInfo: React.ErrorInfo) {
    if (error.name === 'ChunkLoadError' || error.message.includes('Loading chunk')) {
      logger.error('청크 로드 에러:', error, errorInfo);
    }
  }

  render() {
    if (this.state.hasError && this.state.error && 
        (this.state.error.name === 'ChunkLoadError' || 
         this.state.error.message.includes('Loading chunk'))) {
      return (
        <div className="fixed inset-0 flex items-center justify-center bg-white dark:bg-gray-900">
          <Card className="max-w-md">
            <CardContent className="p-6 text-center space-y-4">
              <div className="animate-pulse">
                <RefreshCw className="w-8 h-8 mx-auto text-blue-500 animate-spin" />
              </div>
              <h2 className="text-lg font-semibold">페이지를 다시 로드하는 중...</h2>
              <p className="text-sm text-gray-600 dark:text-gray-400">
                잠시만 기다려주세요. 자동으로 새로고침됩니다.
              </p>
            </CardContent>
          </Card>
        </div>
      );
    }

    return this.props.children;
  }
}