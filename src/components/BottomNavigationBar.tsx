"use client";

import { motion, AnimatePresence } from "framer-motion";
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { useTheme } from 'next-themes';
import { Home, Sparkles, Camera, BookOpen, User } from 'lucide-react';

interface NavItem {
  href: string;
  label: string;
  icon: React.ComponentType<{ className?: string }>;
}

const navItems: NavItem[] = [
  { href: '/home', label: '홈', icon: Home },
  { href: '/fortune', label: '운세', icon: Sparkles },
  { href: '/physiognomy', label: '관상', icon: Camera },
  { href: '/premium', label: '프리미엄사주', icon: BookOpen },
  { href: '/profile', label: '프로필', icon: User },
];

export default function BottomNavigationBar() {
  const pathname = usePathname();
  const { theme } = useTheme();

  return (
    <motion.nav
      initial={{ y: 100, opacity: 0 }}
      animate={{ y: 0, opacity: 1 }}
      transition={{ duration: 0.3 }}
      className="fixed bottom-0 left-0 right-0 z-50 bg-white/90 dark:bg-gray-900/90 backdrop-blur-md border-t border-gray-200/50 dark:border-gray-700/50 px-4 py-2"
    >
      <div className="flex justify-around items-center max-w-md mx-auto">
        {navItems.map(({ href, label, icon: Icon }, index) => {
          const isActive = pathname === href || (pathname?.startsWith(href) && href !== '/');
          
          return (
            <Link key={href} href={href} className="relative">
              <motion.div
                className="flex flex-col items-center p-2 min-w-[60px]"
                whileHover={{ scale: 1.1 }}
                whileTap={{ scale: 0.95 }}
                initial={{ y: 20, opacity: 0 }}
                animate={{ y: 0, opacity: 1 }}
                transition={{ delay: index * 0.1 }}
              >
                {/* 활성 상태 배경 */}
                <AnimatePresence>
                  {isActive && (
                    <motion.div
                      layoutId="activeTab"
                      className="absolute -top-1 -left-2 -right-2 -bottom-1 bg-purple-100 dark:bg-purple-900/30 rounded-2xl"
                      initial={{ scale: 0.8, opacity: 0 }}
                      animate={{ scale: 1, opacity: 1 }}
                      exit={{ scale: 0.8, opacity: 0 }}
                      transition={{ type: "spring", stiffness: 300, damping: 30 }}
                    />
                  )}
                </AnimatePresence>

                {/* 아이콘 */}
                <motion.div
                  className="relative z-10"
                  animate={{ 
                    scale: isActive ? 1.1 : 1,
                    color: isActive ? '#8B5CF6' : (theme === 'dark' ? '#9CA3AF' : '#6B7280')
                  }}
                  transition={{ type: "spring", stiffness: 300 }}
                >
                  <Icon className="w-6 h-6" />
                </motion.div>

                {/* 라벨 */}
                <motion.span
                  className="relative z-10 text-xs mt-1 font-medium"
                  animate={{ 
                    color: isActive ? '#8B5CF6' : (theme === 'dark' ? '#9CA3AF' : '#6B7280'),
                    fontWeight: isActive ? 600 : 500
                  }}
                  transition={{ duration: 0.2 }}
                >
                  {label}
                </motion.span>

                {/* 활성 상태 점 */}
                <AnimatePresence>
                  {isActive && (
                    <motion.div
                      className="absolute -top-3 w-1 h-1 bg-purple-600 dark:bg-purple-400 rounded-full"
                      initial={{ scale: 0, opacity: 0 }}
                      animate={{ scale: 1, opacity: 1 }}
                      exit={{ scale: 0, opacity: 0 }}
                      transition={{ delay: 0.1 }}
                    />
                  )}
                </AnimatePresence>
              </motion.div>
            </Link>
          );
        })}
      </div>
    </motion.nav>
  );
}
