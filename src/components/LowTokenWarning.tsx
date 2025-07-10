'use client';

import { logger } from '@/lib/logger';
import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { AlertCircle, Coins, X } from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';
import { Button } from '@/components/ui/button';
import { useAuth } from '@/contexts/AuthContext';

interface LowTokenWarningProps {
  threshold?: number; // 토큰이 이 숫자 이하일 때 경고 표시
  forceShow?: boolean; // 테스트용 강제 표시
}

export function LowTokenWarning({ 
  threshold = 5, 
  forceShow = false 
}: LowTokenWarningProps) {
  const router = useRouter();
  const { user } = useAuth();
  const [show, setShow] = useState(false);
  const [balance, setBalance] = useState<number | null>(null);
  const [dismissed, setDismissed] = useState(false);

  useEffect(() => {
    if (!user || dismissed) return;

    const checkBalance = async () => {
      try {
        const response = await fetch('/api/user/token-balance');
        if (!response.ok) {
          throw new Error('Failed to fetch token balance');
        }
        
        const data = await response.json();
        const currentBalance = data.data.balance;
        setBalance(currentBalance);
        
        // 무제한 사용자는 경고 표시 안함
        if (data.data.isUnlimited) {
          setShow(false);
          return;
        }
        
        // 토큰이 부족하거나 강제 표시 모드일 때
        if (currentBalance <= threshold || forceShow) {
          setShow(true);
        } else {
          setShow(false);
        }
      } catch (error) {
        logger.error('토큰 잔액 확인 실패:', error);
      }
    };

    checkBalance();
    
    // 5분마다 잔액 확인
    const interval = setInterval(checkBalance, 5 * 60 * 1000);
    
    return () => clearInterval(interval);
  }, [user, threshold, forceShow, dismissed]);

  const handleDismiss = () => {
    setDismissed(true);
    setShow(false);
    // 24시간 동안 다시 표시하지 않음
    setTimeout(() => setDismissed(false), 24 * 60 * 60 * 1000);
  };

  const handlePurchase = () => {
    router.push('/payment/tokens');
    handleDismiss();
  };

  if (!user) return null;

  return (
    <AnimatePresence>
      {show && (
        <motion.div
          initial={{ opacity: 0, y: -20, scale: 0.95 }}
          animate={{ opacity: 1, y: 0, scale: 1 }}
          exit={{ opacity: 0, y: -20, scale: 0.95 }}
          transition={{ duration: 0.3, ease: 'easeOut' }}
          className="fixed top-20 right-4 z-50 max-w-sm"
        >
          <div className="bg-yellow-50 dark:bg-yellow-900/20 border border-yellow-200 dark:border-yellow-800 rounded-lg shadow-lg p-4">
            <div className="flex items-start gap-3">
              <div className="flex-shrink-0">
                <div className="p-2 bg-yellow-100 dark:bg-yellow-800 rounded-full">
                  <AlertCircle className="h-5 w-5 text-yellow-600 dark:text-yellow-400" />
                </div>
              </div>
              
              <div className="flex-1">
                <div className="flex items-center justify-between mb-1">
                  <h3 className="font-semibold text-yellow-900 dark:text-yellow-100">
                    토큰이 부족합니다
                  </h3>
                  <button
                    onClick={handleDismiss}
                    className="text-yellow-600 hover:text-yellow-800 dark:text-yellow-400 dark:hover:text-yellow-200"
                  >
                    <X className="h-4 w-4" />
                  </button>
                </div>
                
                <p className="text-sm text-yellow-800 dark:text-yellow-200 mb-3">
                  현재 {balance !== null ? `${balance}개` : '남은'} 토큰으로는 
                  {balance !== null && balance > 0 ? ` ${Math.floor(balance / 3)}~${balance}회` : ' 추가'} 
                  운세 조회만 가능합니다.
                </p>
                
                <div className="flex gap-2">
                  <Button
                    onClick={handlePurchase}
                    size="sm"
                    className="bg-yellow-600 hover:bg-yellow-700 text-white"
                  >
                    <Coins className="h-4 w-4 mr-1" />
                    토큰 충전하기
                  </Button>
                  <Button
                    onClick={handleDismiss}
                    size="sm"
                    variant="ghost"
                    className="text-yellow-700 hover:text-yellow-800 dark:text-yellow-300"
                  >
                    나중에
                  </Button>
                </div>
              </div>
            </div>
          </div>
        </motion.div>
      )}
    </AnimatePresence>
  );
}

// 전역 경고 컴포넌트 - 앱 전체에서 사용
export function GlobalLowTokenWarning() {
  return <LowTokenWarning threshold={5} />;
}