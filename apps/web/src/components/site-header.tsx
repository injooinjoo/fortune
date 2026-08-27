import Link from 'next/link';

import { AccountHeaderActions } from '@/components/account-header-actions';
import { CHAT_INDEX_HREF, FORTUNE_INDEX_HREF } from '@/lib/href';

const NAV_LINKS = [
  { href: FORTUNE_INDEX_HREF, label: '운세' },
  { href: CHAT_INDEX_HREF, label: '캐릭터 대화' },
  { href: '/#ondo-guide', label: '온도 이용 안내' },
] as const;

function NavigationLinks() {
  return (
    <>
      {NAV_LINKS.map((link) => (
        <Link href={link.href} key={link.href}>{link.label}</Link>
      ))}
      <AccountHeaderActions mobile />
    </>
  );
}

export function SiteHeader() {
  return (
    <header className="ondo-site-header">
      <div className="ondo-site-nav">
        <Link className="ondo-site-logo" href="/" aria-label="온도 홈">온도</Link>

        <nav className="ondo-desktop-nav" aria-label="사이트 메뉴">
          {NAV_LINKS.map((link) => (
            <Link href={link.href} key={link.href}>{link.label}</Link>
          ))}
        </nav>

        <div className="ondo-header-actions">
          <AccountHeaderActions />
        </div>

        <details className="ondo-mobile-menu">
          <summary>메뉴</summary>
          <nav aria-label="모바일 사이트 메뉴"><NavigationLinks /></nav>
        </details>
      </div>
    </header>
  );
}
