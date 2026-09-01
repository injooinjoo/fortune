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
        <div className="ondo-row">
          {/* 잔액이 바닥난 순간이 결제 의사가 가장 높은 지점이다. 로그인 링크만
              두면 이미 로그인한 사용자는 갈 곳이 없다. `/app/charge` 는 익명이면
              `next=/app/charge` 로 로그인을 거쳐 다시 돌아오므로 양쪽 다 맞는다. */}
          <Link className="ondo-button" href="/app/charge">
            온도 충전하기
          </Link>
          {/* #284 의 잔액 복구 경로 — 세션이 끊긴 게스트를 위해 유지한다. */}
          {loginHref ? (
            <Link className="ondo-button ondo-button--secondary" href={loginHref}>
              로그인하고 온도 확인하기
            </Link>
          ) : null}
        </div>
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
