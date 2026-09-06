'use client';

import { usePathname } from 'next/navigation';
import { useEffect, useRef } from 'react';
import { AppLink as Link } from '@/components/app-link';

import { AccountHeaderActions } from '@/components/account-header-actions';
import { CHAT_INDEX_HREF, FORTUNE_INDEX_HREF } from '@/lib/href';

const NAV_LINKS = [
  { href: '/', label: '오늘' },
  { href: FORTUNE_INDEX_HREF, label: '운세' },
  { href: CHAT_INDEX_HREF, label: '대화' },
  { href: '/app', label: '내 기록' },
] as const;

function NavigationLinks({ pathname }: { pathname: string }) {
  return (
    <>
      {NAV_LINKS.map((link) => (
        <Link aria-current={isCurrentSection(pathname, link.href) ? 'page' : undefined} href={link.href} key={link.href}>{link.label}</Link>
      ))}
      <AccountHeaderActions mobile />
    </>
  );
}

function isCurrentSection(pathname: string, href: string) {
  // usePathname may return either encoded or decoded Korean segments.
  const paths = [href, decodeURI(href)];
  return paths.some((path) => pathname === path || (path !== '/' && pathname.startsWith(`${path}/`)));
}

export function SiteHeader() {
  const pathname = usePathname();
  const menuRef = useRef<HTMLDetailsElement>(null);

  useEffect(() => {
    if (menuRef.current) menuRef.current.open = false;
  }, [pathname]);

  useEffect(() => {
    function closeOutside(event: PointerEvent) {
      const menu = menuRef.current;
      if (menu?.open && !menu.contains(event.target as Node)) menu.open = false;
    }
    document.addEventListener('pointerdown', closeOutside);
    return () => document.removeEventListener('pointerdown', closeOutside);
  }, []);

  return (
    <header className="ondo-site-header">
      <div className="ondo-site-nav">
        <Link className="ondo-site-logo" href="/" aria-label="온도 홈">온도</Link>

        <nav className="ondo-desktop-nav" aria-label="사이트 메뉴">
          {NAV_LINKS.map((link) => (
            <Link aria-current={isCurrentSection(pathname, link.href) ? 'page' : undefined} href={link.href} key={link.href}>{link.label}</Link>
          ))}
        </nav>

        <div className="ondo-header-actions">
          <AccountHeaderActions />
        </div>

        <details
          className="ondo-mobile-menu"
          ref={menuRef}
          onKeyDown={(event) => {
            if (event.key !== 'Escape' || !event.currentTarget.open) return;
            event.preventDefault();
            event.currentTarget.open = false;
            event.currentTarget.querySelector('summary')?.focus();
          }}
          onBlur={(event) => {
            if (!event.currentTarget.contains(event.relatedTarget)) event.currentTarget.open = false;
          }}
        >
          <summary>메뉴</summary>
          <nav aria-label="모바일 사이트 메뉴"><NavigationLinks pathname={pathname} /></nav>
        </details>
      </div>
    </header>
  );
}
