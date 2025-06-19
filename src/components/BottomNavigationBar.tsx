"use client";

import Link from 'next/link';
import { useRouter } from 'next/router';
import { Home, Gem, WalletCards, Menu } from 'lucide-react';
import styles from './BottomNavigationBar.module.css';

interface NavItem {
  href: string;
  label: string;
  icon: React.ComponentType<{ className?: string }>;
}

const navItems: NavItem[] = [
  { href: '/', label: '홈', icon: Home },
  { href: '/saju', label: '사주', icon: Gem },
  { href: '/tarot', label: '타로', icon: WalletCards },
  { href: '/more', label: '더보기', icon: Menu },
];

export default function BottomNavigationBar() {
  const router = useRouter();

  return (
    <nav className={styles.nav}>
      {navItems.map(({ href, label, icon: Icon }) => (
        <Link
          key={href}
          href={href}
          className={`${styles.link} ${router.pathname === href ? styles.active : ''}`}
        >
          <Icon className={styles.icon} />
          <span className={styles.label}>{label}</span>
        </Link>
      ))}
    </nav>
  );
}
