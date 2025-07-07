"use client";

import { usePathname } from 'next/navigation';
import Link from 'next/link';
import { Home, Compass, Camera, BookOpen, User } from 'lucide-react';
import { cn } from '@/lib/utils';
import { motion, AnimatePresence } from 'framer-motion';

const navigationItems = [
  {
    name: '홈',
    href: '/home',
    icon: Home,
    color: 'from-blue-500 to-cyan-500',
  },
  {
    name: '운세',
    href: '/fortune',
    icon: Compass,
    color: 'from-purple-500 to-pink-500',
  },
  {
    name: '관상',
    href: '/physiognomy',
    icon: Camera,
    color: 'from-emerald-500 to-teal-500',
  },
  {
    name: '프리미엄',
    href: '/premium',
    icon: BookOpen,
    color: 'from-amber-500 to-orange-500',
  },
  {
    name: '프로필',
    href: '/profile',
    icon: User,
    color: 'from-rose-500 to-red-500',
  },
];

export default function BottomNavigationBar() {
  const pathname = usePathname();

  return (
    <motion.nav 
      className="fixed bottom-2 left-0 right-0 z-50 flex justify-center"
      initial={{ y: 100, opacity: 0 }}
      animate={{ y: 0, opacity: 1 }}
      transition={{ type: "spring", stiffness: 300, damping: 30 }}
    >
      <div className="relative">
        {/* Main Navigation Container */}
        <div className="liquid-glass-nav px-4 py-1.5">
          <div className="flex items-center justify-center space-x-5">
            {navigationItems.map((item, index) => {
              const Icon = item.icon;
              const isActive = pathname === item.href || (pathname && pathname.startsWith(item.href + '/'));
              
              return (
                <motion.div
                  key={item.name}
                  className="relative"
                  whileHover={{ scale: 1.1 }}
                  whileTap={{ scale: 0.95 }}
                  transition={{ type: "spring", stiffness: 400, damping: 17 }}
                >
                  <Link
                    href={item.href}
                    className="relative flex flex-col items-center justify-center group"
                  >
                    {/* Active Background Blob */}
                    <AnimatePresence>
                      {isActive && (
                        <motion.div
                          layoutId="activeBackground"
                          className={cn(
                            "absolute inset-0 rounded-2xl bg-gradient-to-r opacity-20",
                            item.color
                          )}
                          initial={{ scale: 0, opacity: 0 }}
                          animate={{ scale: 1, opacity: 0.2 }}
                          exit={{ scale: 0, opacity: 0 }}
                          transition={{ type: "spring", stiffness: 500, damping: 30 }}
                        />
                      )}
                    </AnimatePresence>

                    {/* Icon Container */}
                    <div className={cn(
                      "relative p-1.5 rounded-xl transition-all duration-300",
                      "backdrop-blur-sm",
                      isActive 
                        ? "bg-white/30 shadow-lg" 
                        : "hover:bg-white/20"
                    )}>
                      <Icon 
                        className={cn(
                          "h-5 w-5 transition-all duration-300",
                          isActive 
                            ? "text-white drop-shadow-sm" 
                            : "text-gray-300 group-hover:text-white"
                        )} 
                      />
                      
                    </div>
                  </Link>
                </motion.div>
              );
            })}
          </div>
        </div>


      </div>
    </motion.nav>
  );
}
