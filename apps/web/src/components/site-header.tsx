/**
 * 모든 페이지 상단 내비게이션.
 *
 * 세션을 읽지 않는다 — 루트 레이아웃에서 렌더되므로 여기서 `auth.getUser()` 를
 * 부르면 정적 페이지 전부가 dynamic 으로 떨어진다. 로그인 여부는 링크가 아니라
 * 도착한 페이지에서 판단한다.
 *
 * globals.css 는 이 작업 범위 밖이라 새 클래스를 만들지 않고 기존 .ondo-* 조합 +
 * 토큰 인라인 스타일로만 만든다. 색은 전부 var(--ondo-*).
 */

import Link from 'next/link';

import { IS_BYOK_ENABLED, SETTINGS_AI_HREF } from '@/features/settings/providers';
import { CHAT_INDEX_HREF, FORTUNE_INDEX_HREF } from '@/lib/href';

/**
 * 설정 링크는 `/설정` 이 아니라 `/설정/ai` 로 간다 — 지금 설정 화면은 AI 키
 * 연결 하나뿐이고, 목록만 있는 `/설정` 을 만들면 클릭이 한 번 더 늘 뿐이다.
 * 그래서 개인 키 연결이 꺼져 있으면 설정 항목 자체를 내보내지 않는다
 * (`IS_BYOK_ENABLED` 주석 참고).
 */
const NAV_LINKS = [
  { href: FORTUNE_INDEX_HREF, label: '운세' },
  { href: CHAT_INDEX_HREF, label: '대화' },
  ...(IS_BYOK_ENABLED ? [{ href: SETTINGS_AI_HREF, label: '설정' }] : []),
  { href: '/auth/login', label: '로그인' },
];

export function SiteHeader() {
  return (
    <header style={{ borderBottom: '1px solid var(--ondo-color-border)' }}>
      {/* .ondo-shell 로 본문과 같은 폭/좌우 여백을 쓰고 세로 여백만 덮어쓴다. */}
      <nav
        aria-label="사이트 메뉴"
        className="ondo-shell ondo-row"
        style={{
          alignItems: 'center',
          justifyContent: 'space-between',
          paddingTop: 'var(--ondo-spacing-md)',
          paddingBottom: 'var(--ondo-spacing-md)',
        }}
      >
        <Link href="/">온도</Link>

        <div className="ondo-row" style={{ gap: 'var(--ondo-spacing-md)' }}>
          {NAV_LINKS.map((link) => (
            <Link className="ondo-muted" href={link.href} key={link.href}>
              {link.label}
            </Link>
          ))}
        </div>
      </nav>
    </header>
  );
}
