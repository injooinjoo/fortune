'use client';

import { AppLink as Link } from '@/components/app-link';
import { useEffect } from 'react';

export default function ErrorPage({
  error,
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  useEffect(() => {
    console.error('Ondo page render failed', { digest: error.digest });
  }, [error]);

  return (
    <main className="ondo-container ondo-status-page" role="alert">
      <p className="ondo-eyebrow">잠시 문제가 생겼어요</p>
      <h1>화면을 불러오지 못했어요.</h1>
      <p className="ondo-muted">입력한 내용은 그대로 두고 다시 불러올 수 있어요.</p>
      <div className="ondo-account-actions">
        <button className="ondo-button ondo-button--primary" onClick={reset} type="button">
          다시 시도
        </button>
        <Link className="ondo-button ondo-button--secondary" href="/support">
          도움받기
        </Link>
      </div>
    </main>
  );
}
