/**
 * 운세 하나를 가리키는 링크 카드. 목록(/운세)과 랜딩이 같은 걸 쓴다.
 *
 * 제목/설명/가격은 전부 `WebFortune` 에서만 읽는다 — 카탈로그가 SoT 라
 * 여기서 문구를 새로 쓰거나 숫자를 하드코딩하지 않는다.
 */

import Link from 'next/link';

import { fortuneHref } from '@/lib/href';

import type { WebFortune } from '@/features/fortune/catalog';

export function FortuneLinkCard({ fortune }: { fortune: WebFortune }) {
  return (
    <Link
      className="ondo-card ondo-stack"
      href={fortuneHref(fortune.slug)}
      style={{ gap: 'var(--ondo-spacing-xxs)' }}
    >
      <h3 className="ondo-h3">{fortune.title}</h3>
      {fortune.blurb ? <p className="ondo-muted">{fortune.blurb}</p> : null}
      <div className="ondo-card-footer">
        <span className="ondo-kicker">온도 {fortune.costPoints}개</span>
        <span aria-hidden="true" className="ondo-card-arrow">
          열어보기 →
        </span>
      </div>
    </Link>
  );
}
