'use client';

import { logger } from '@/lib/logger';
import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { useAuth } from '@/contexts/auth-context';
import { Loader2 } from 'lucide-react';

interface ProtectedRouteProps {
  children: React.ReactNode;
  fallback?: React.ReactNode;
  redirectTo?: string;
}

export default function ProtectedRoute({ 
  children, 
  fallback,
  redirectTo = '/'
}: ProtectedRouteProps) {
  const { user, session, isLoading } = useAuth();
  const router = useRouter();
  const [isChecking, setIsChecking] = useState(true);

  useEffect(() => {
    if (isLoading) {
      return; // 아직 로딩 중이면 대기
    }

    // 세션과 사용자 정보 모두 확인
    if (!session || !user) {
      logger.debug('🔒 미인증 사용자 감지 - 로그인 페이지로 리디렉션');
      // 현재 경로를 저장하여 로그인 후 돌아올 수 있도록 함
      const currentPath = window.location.pathname;
      const returnUrl = encodeURIComponent(currentPath);
      router.push(`${redirectTo}?returnUrl=${returnUrl}`);
      return;
    }

    setIsChecking(false);
  }, [user, session, isLoading, router, redirectTo]);

  // 로딩 중이거나 인증 체크 중
  if (isLoading || isChecking) {
    return fallback || (
      <div className="min-h-screen flex items-center justify-center">
        <div className="flex flex-col items-center space-y-4">
          <Loader2 className="h-8 w-8 animate-spin text-primary" />
          <p className="text-sm text-muted-foreground">인증 확인 중...</p>
        </div>
      </div>
    );
  }

  // 인증되지 않은 사용자는 이 시점에서 이미 리디렉션됨
  if (!session || !user) {
    return null;
  }

  // 인증된 사용자만 자식 컴포넌트 렌더링
  return <>{children}</>;
}