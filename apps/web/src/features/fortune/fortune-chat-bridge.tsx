'use client';

import { AppLink as Link } from '@/components/app-link';
import { useEffect, useState } from 'react';

interface ContextPointer {
  id: string;
  title: string;
  createdAt: number;
}

export function FortuneChatBridge() {
  const [pointer, setPointer] = useState<ContextPointer | null>(null);

  useEffect(() => {
    try {
      const raw = sessionStorage.getItem('ondo:last-fortune-context');
      if (!raw) return;
      const value = JSON.parse(raw) as Partial<ContextPointer>;
      const fresh = typeof value.createdAt === 'number' && Date.now() - value.createdAt < 30 * 60 * 1000;
      const validId = typeof value.id === 'string' && /^[0-9a-f-]{36}$/i.test(value.id);
      if (fresh && validId && typeof value.title === 'string') {
        setPointer(value as ContextPointer);
      }
    } catch {
      sessionStorage.removeItem('ondo:last-fortune-context');
    }
  }, []);

  if (!pointer) return null;
  return (
    <div className="ondo-card ondo-stack" style={{ gap: 'var(--ondo-spacing-sm)' }}>
      <p className="ondo-kicker">결과 다음 이야기</p>
      <h3 className="ondo-h3">캐릭터와 {pointer.title} 이야기를 이어가세요.</h3>
      <p className="ondo-muted">결과 원문은 URL에 넣지 않고, 내 계정에 저장된 요약만 대화 맥락으로 사용해요.</p>
      <div>
        <Link className="ondo-button" href="/대화">대화 상대 고르기</Link>
      </div>
    </div>
  );
}
