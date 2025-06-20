"use client";

import { motion } from "framer-motion";
import { FortuneCompassIcon } from "@/components/icons/fortune-compass-icon";
import { Button } from "@/components/ui/button";
import { Bell, Settings, User } from "lucide-react";
import Link from "next/link";

interface AppHeaderProps {
  title?: string;
  showBack?: boolean;
  showNotification?: boolean;
  showProfile?: boolean;
}

export default function AppHeader({ 
  title = "Fortune", 
  showBack = false, 
  showNotification = true, 
  showProfile = true 
}: AppHeaderProps) {
  return (
    <motion.header
      initial={{ y: -20, opacity: 0 }}
      animate={{ y: 0, opacity: 1 }}
      transition={{ duration: 0.3 }}
      className="sticky top-0 z-50 w-full bg-white/80 backdrop-blur-md border-b border-gray-200/50"
    >
      <div className="flex items-center justify-between px-6 py-4">
        {/* 왼쪽 영역 */}
        <div className="flex items-center space-x-3">
          <motion.div
            whileHover={{ rotate: 360 }}
            transition={{ duration: 0.5 }}
          >
            <FortuneCompassIcon className="w-8 h-8 text-purple-600" />
          </motion.div>
          <motion.h1 
            className="text-xl font-bold text-gray-900"
            initial={{ x: -10, opacity: 0 }}
            animate={{ x: 0, opacity: 1 }}
            transition={{ delay: 0.1 }}
          >
            {title}
          </motion.h1>
        </div>

        {/* 오른쪽 영역 */}
        <div className="flex items-center space-x-2">
          {showNotification && (
            <motion.div
              whileHover={{ scale: 1.1 }}
              whileTap={{ scale: 0.95 }}
            >
              <Button variant="ghost" size="sm" className="relative">
                <Bell className="w-5 h-5 text-gray-600" />
                <motion.div
                  className="absolute -top-1 -right-1 w-3 h-3 bg-red-500 rounded-full"
                  animate={{ scale: [1, 1.2, 1] }}
                  transition={{ repeat: Infinity, duration: 2 }}
                />
              </Button>
            </motion.div>
          )}
          
          {showProfile && (
            <motion.div
              whileHover={{ scale: 1.1 }}
              whileTap={{ scale: 0.95 }}
            >
              <Link href="/profile">
                <Button variant="ghost" size="sm">
                  <User className="w-5 h-5 text-gray-600" />
                </Button>
              </Link>
            </motion.div>
          )}
        </div>
      </div>
    </motion.header>
  );
} 