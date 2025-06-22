"use client";

import { usePathname } from 'next/navigation';
import Link from 'next/link';
import { Home, Compass, Camera, BookOpen, User } from 'lucide-react';
import { cn } from '@/lib/utils';

const navigationItems = [
  {
    name: '홈',
    href: '/home',
    icon: Home,
  },
  {
    name: '운세',
    href: '/fortune',
    icon: Compass,
  },
  {
    name: '관상',
    href: '/physiognomy',
    icon: Camera,
  },
  {
    name: '프리미엄',
    href: '/premium',
    icon: BookOpen,
  },
  {
    name: '프로필',
    href: '/profile',
    icon: User,
  },
];

export default function BottomNavigationBar() {
  const pathname = usePathname();

  return (
    <nav className="fixed bottom-4 left-1/2 transform -translate-x-1/2 z-50">
      <div className="glass-nav px-6 py-3">
        <div className="flex items-center justify-center space-x-8">
          {navigationItems.map((item) => {
            const Icon = item.icon;
            const isActive = pathname === item.href || (pathname && pathname.startsWith(item.href + '/'));
            
            return (
              <Link
                key={item.name}
                href={item.href}
                className={cn(
                  "flex items-center justify-center transition-all duration-300 group",
                  "hover:scale-110 active:scale-95"
                )}
              >
                <div className={cn(
                  "p-3 rounded-full transition-all duration-300",
                  isActive 
                    ? "bg-white/20 backdrop-blur-sm shadow-lg scale-110" 
                    : "hover:bg-white/10 backdrop-blur-sm"
                )}>
                  <Icon 
                    className={cn(
                      "h-6 w-6 transition-all duration-300",
                      isActive 
                        ? "text-white" 
                        : "text-gray-400 group-hover:text-white"
                    )} 
                  />
                </div>
              </Link>
            );
          })}
        </div>
      </div>
    </nav>
  );
}
