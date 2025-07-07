"use client";

import { useState, useEffect } from "react";
import { motion } from "framer-motion";
import { Coins, Sparkles } from "lucide-react";
import { useRouter } from "next/navigation";
import { useAuth } from "@/contexts/auth-context";
import { tokenService } from "@/lib/services/token-service";
import { logger } from "@/lib/logger";

interface TokenBalanceProps {
  compact?: boolean;
  showLabel?: boolean;
  className?: string;
}

export default function TokenBalance({ 
  compact = false, 
  showLabel = true,
  className = "" 
}: TokenBalanceProps) {
  const router = useRouter();
  const { user } = useAuth();
  const [balance, setBalance] = useState(0);
  const [isUnlimited, setIsUnlimited] = useState(false);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    if (user) {
      loadTokenBalance();
    } else {
      setBalance(0);
      setIsUnlimited(false);
      setIsLoading(false);
    }
  }, [user]);

  const loadTokenBalance = async () => {
    if (!user) return;
    
    try {
      const tokenBalance = await tokenService.getTokenBalance(user.id);
      setBalance(tokenBalance.balance);
      setIsUnlimited(tokenBalance.isUnlimited);
    } catch (error) {
      logger.error('토큰 잔액 로드 실패:', error);
      setBalance(0);
    } finally {
      setIsLoading(false);
    }
  };

  const handleClick = () => {
    if (!user) {
      router.push('/auth/login?redirect=/payment/tokens');
    } else {
      router.push('/payment/tokens');
    }
  };

  if (isLoading) {
    return (
      <div className={`flex items-center gap-2 ${className}`}>
        <div className="w-8 h-8 bg-gray-200 dark:bg-gray-700 rounded-full animate-pulse" />
        {showLabel && !compact && (
          <div className="w-16 h-4 bg-gray-200 dark:bg-gray-700 rounded animate-pulse" />
        )}
      </div>
    );
  }

  if (!user) {
    return null;
  }

  return (
    <motion.button
      onClick={handleClick}
      className={`flex items-center gap-2 px-3 py-1.5 rounded-full bg-white/80 dark:bg-gray-800/80 backdrop-blur-sm border border-gray-200 dark:border-gray-700 hover:bg-white dark:hover:bg-gray-800 transition-all ${className}`}
      whileHover={{ scale: 1.05 }}
      whileTap={{ scale: 0.95 }}
      initial={{ opacity: 0, scale: 0.9 }}
      animate={{ opacity: 1, scale: 1 }}
      transition={{ duration: 0.2 }}
    >
      {isUnlimited ? (
        <>
          <div className="w-8 h-8 bg-gradient-to-r from-purple-500 to-indigo-500 rounded-full flex items-center justify-center">
            <Sparkles className="w-4 h-4 text-white" />
          </div>
          {showLabel && !compact && (
            <span className="text-sm font-medium bg-gradient-to-r from-purple-600 to-indigo-600 bg-clip-text text-transparent">
              무제한
            </span>
          )}
        </>
      ) : (
        <>
          <div className="w-8 h-8 bg-gradient-to-r from-amber-500 to-orange-500 rounded-full flex items-center justify-center">
            <Coins className="w-4 h-4 text-white" />
          </div>
          {showLabel && (
            <span className="text-sm font-medium text-gray-700 dark:text-gray-300">
              {compact ? balance : `${balance.toLocaleString()}개`}
            </span>
          )}
        </>
      )}
    </motion.button>
  );
}