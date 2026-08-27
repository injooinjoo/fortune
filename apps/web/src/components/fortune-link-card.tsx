/**
 * 운세 하나를 가리키는 스캔 가능한 링크 행.
 * 제목/설명/가격은 `WebFortune` 카탈로그만 읽는다.
 */

import Link from 'next/link';

import { fortuneHref } from '@/lib/href';

import type { WebFortune } from '@/features/fortune/catalog';

export function FortuneLinkCard({ fortune }: { fortune: WebFortune }) {
  return (
    <Link className="ondo-fortune-link" href={fortuneHref(fortune.slug)}>
      <div className="ondo-stack" style={{ gap: 'var(--ondo-spacing-xxs)' }}>
        <h3>{fortune.title}</h3>
        {fortune.blurb ? <p className="ondo-muted">{fortune.blurb}</p> : null}
      </div>
      <div className="ondo-fortune-link-meta">
        <span>온도 {fortune.costPoints}개</span>
        <span aria-hidden="true">→</span>
      </div>
    </Link>
  );
}
