/**
 * 모든 페이지 하단 고지와 운영 문서 링크.
 *
 * 엔터테인먼트 문구는 새로 쓰지 않고 결과 화면이 쓰는 `Disclaimer` 를 그대로
 * 가져온다 — 같은 고지가 페이지마다 다른 문장이 되면 안 된다.
 *
 * 정책 문서는 기존 공개 검증 사이트의 배포본을 단일 원본으로 쓴다. Next 웹에서
 * 약관 문구를 복제하면 두 배포의 개정일과 내용이 갈릴 수 있으므로 외부 링크로
 * 명시적으로 연결한다.
 */

import { Disclaimer } from '@/features/fortune/result';

const PUBLIC_DOCUMENTS = [
  { href: 'https://fortune-mocha.vercel.app/privacy', label: '개인정보처리방침' },
  { href: 'https://fortune-mocha.vercel.app/terms', label: '이용약관' },
  { href: 'https://fortune-mocha.vercel.app/support', label: '고객 지원' },
  { href: 'https://fortune-mocha.vercel.app/delete-account', label: '계정 삭제 안내' },
] as const;

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
        <nav
          aria-label="운영 정보"
          style={{
            display: 'flex',
            flexWrap: 'wrap',
            gap: 'var(--ondo-spacing-md)',
            marginTop: 'var(--ondo-spacing-xs)',
          }}
        >
          {PUBLIC_DOCUMENTS.map((document) => (
            <a href={document.href} key={document.href}>
              {document.label}
            </a>
          ))}
        </nav>
      </div>
    </footer>
  );
}
