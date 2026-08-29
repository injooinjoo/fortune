'use client';

import { useLayoutEffect, useRef } from 'react';

import { AppLink as Link } from '@/components/app-link';

import type { FortuneFailureKind } from './runner';

export function FailureNotice({
  kind,
  message,
  loginHref,
}: {
  kind: FortuneFailureKind;
  message: string;
  loginHref?: string;
}) {
  const noticeRef = useRef<HTMLElement | null>(null);

  useLayoutEffect(() => {
    const notice = noticeRef.current;
    if (!notice) return;

    notice.focus({ preventScroll: true });
    notice.scrollIntoView({ block: 'nearest' });
  }, [kind, message]);

  if (kind === 'auth') {
    return (
      <div
        className="ondo-notice ondo-stack"
        ref={(element) => {
          noticeRef.current = element;
        }}
        role="alert"
        style={{ gap: 'var(--ondo-spacing-sm)' }}
        tabIndex={-1}
      >
        <p className="ondo-h3">로그인이 필요해요</p>
        <p className="ondo-muted">{message}</p>
        {loginHref ? (
          <Link className="ondo-button" href={loginHref}>
            다시 로그인
          </Link>
        ) : null}
      </div>
    );
  }

  if (kind === 'tokens') {
    return (
      <div
        className="ondo-notice ondo-stack"
        ref={(element) => {
          noticeRef.current = element;
        }}
        role="alert"
        style={{ gap: 'var(--ondo-spacing-sm)' }}
        tabIndex={-1}
      >
        <p className="ondo-h3">온도가 부족해요</p>
        <p className="ondo-muted">{message}</p>
      </div>
    );
  }

  return (
    <p
      className="ondo-notice ondo-notice--error"
      ref={(element) => {
        noticeRef.current = element;
      }}
      role="alert"
      tabIndex={-1}
    >
      {message}
    </p>
  );
}
