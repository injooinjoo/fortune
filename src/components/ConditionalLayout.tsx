"use client";

import { usePathname } from "next/navigation";
import BottomNavigationBar from "./BottomNavigationBar";

interface ConditionalLayoutProps {
  children: React.ReactNode;
}

export default function ConditionalLayout({ children }: ConditionalLayoutProps) {
  const pathname = usePathname();
  
  // 네비게이션 바를 표시할 경로들
  const showNavigation = [
    '/home',
    '/fortune',
    '/physiognomy',
    '/interactive',
    '/profile'
  ].some(path => pathname?.startsWith(path));

  // 랜딩 페이지나 인증 페이지에서는 네비게이션 숨김
  const hideNavigation = 
    pathname === '/' ||
    pathname?.startsWith('/auth') ||
    pathname?.startsWith('/onboarding');

  return (
    <>
      {children}
      {showNavigation && !hideNavigation && <BottomNavigationBar />}
    </>
  );
} 