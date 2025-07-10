"use client";

import React, { useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { FortuneCompassIcon } from '@/components/icons/fortune-compass-icon';

export default function AuthSelectionPage({ searchParams }: { searchParams: Record<string, string | string[]> }) {
  const router = useRouter();

  useEffect(() => {
    // Redirect to main page - this page is deprecated
    const returnUrl = searchParams.returnUrl;
    if (returnUrl && typeof returnUrl === 'string') {
      router.replace(`/?returnUrl=${encodeURIComponent(returnUrl)}`);
    } else {
      router.replace('/');
    }
  }, [router, searchParams]);

  // Show a loading state while redirecting
  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-purple-50 via-white to-pink-50">
      <div className="text-center">
        <FortuneCompassIcon className="h-16 w-16 mx-auto mb-4 animate-spin text-purple-600" />
        <p className="text-lg text-gray-600">리다이렉션 중...</p>
      </div>
    </div>
  );
}