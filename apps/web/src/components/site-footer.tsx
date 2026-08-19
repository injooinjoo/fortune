/**
 * 모든 페이지 하단 고지.
 *
 * 엔터테인먼트 문구는 새로 쓰지 않고 결과 화면이 쓰는 `Disclaimer` 를 그대로
 * 가져온다 — 같은 고지가 페이지마다 다른 문장이 되면 안 된다.
 *
 * 개인정보처리방침/이용약관은 아직 루트 `public/*.html` + 루트 vercel.json
 * rewrite 로만 서빙돼서 여기서 링크하면 404 가 된다. 그래서 링크 없이 고지만 둔다.
 */

import { Disclaimer } from '@/features/fortune/result';

export function SiteFooter() {
  return (
    <footer style={{ borderTop: '1px solid var(--ondo-color-border)' }}>
      <div
        className="ondo-shell ondo-stack"
        style={{
          gap: 'var(--ondo-spacing-xs)',
          paddingTop: 'var(--ondo-spacing-xl)',
          paddingBottom: 'var(--ondo-spacing-xl)',
        }}
      >
        <p className="ondo-kicker">온도 · ONDO</p>
        <Disclaimer />
      </div>
    </footer>
  );
}
