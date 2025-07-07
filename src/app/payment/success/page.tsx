"use client";

import { useEffect, useState, Suspense } from "react";
import { useRouter, useSearchParams } from "next/navigation";
import { motion } from "framer-motion";
import { Card, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import AppHeader from "@/components/AppHeader";
import {
  CheckCircle,
  Sparkles,
  ArrowRight,
  Coins,
  Crown,
  Loader2,
  Gift,
  Star
} from "lucide-react";
// import confetti from 'canvas-confetti';
import { confetti } from '@/lib/payment-mock';
import { auth } from "@/lib/supabase";
import { tokenService } from "@/lib/services/token-service";
import { logger } from "@/lib/logger";

function SuccessContent() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const [loading, setLoading] = useState(true);
  const [purchaseDetails, setPurchaseDetails] = useState<any>(null);
  const [newBalance, setNewBalance] = useState(0);

  // URL 파라미터
  const sessionId = searchParams.get('session_id');
  const paymentKey = searchParams.get('paymentKey');
  const orderId = searchParams.get('orderId');

  useEffect(() => {
    // 성공 애니메이션
    setTimeout(() => {
      confetti({
        particleCount: 100,
        spread: 70,
        origin: { y: 0.6 }
      });
    }, 500);

    verifyPaymentAndUpdateBalance();
  }, []);

  const verifyPaymentAndUpdateBalance = async () => {
    try {
      const { data: sessionData } = await auth.getSession();
      if (!sessionData?.session?.user) {
        router.push('/auth/login');
        return;
      }

      // 결제 검증 API 호출 (실제로는 백엔드에서 처리)
      // 여기서는 단순화를 위해 토큰 잔액만 다시 조회
      const balance = await tokenService.getTokenBalance(sessionData.session.user.id);
      setNewBalance(balance.balance);

      // 구매 상세 정보 설정 (실제로는 서버에서 받아옴)
      setPurchaseDetails({
        type: 'tokens',
        amount: 60,
        price: 5000,
        bonus: 12
      });

      setLoading(false);
    } catch (error) {
      logger.error('결제 확인 실패:', error);
      router.push('/payment/fail');
    }
  };

  const containerVariants = {
    hidden: { opacity: 0 },
    visible: {
      opacity: 1,
      transition: {
        staggerChildren: 0.2,
        delayChildren: 0.3
      }
    }
  };

  const itemVariants = {
    hidden: { y: 20, opacity: 0 },
    visible: {
      y: 0,
      opacity: 1,
      transition: {
        type: "spring",
        stiffness: 100,
        damping: 10
      }
    }
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-purple-50 via-indigo-50 to-blue-50 dark:from-gray-900 dark:via-gray-800 dark:to-gray-900 pb-20">
        <AppHeader title="결제 완료" />
        <div className="flex items-center justify-center h-[60vh]">
          <div className="text-center">
            <Loader2 className="w-12 h-12 animate-spin text-purple-600 mx-auto mb-4" />
            <p className="text-gray-600 dark:text-gray-400">결제를 확인하고 있습니다...</p>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-green-50 via-emerald-50 to-teal-50 dark:from-gray-900 dark:via-gray-800 dark:to-gray-900 pb-20">
      <AppHeader title="결제 완료" />
      
      <motion.div
        variants={containerVariants}
        initial="hidden"
        animate="visible"
        className="p-6 space-y-6 max-w-lg mx-auto"
      >
        {/* 성공 아이콘 */}
        <motion.div 
          variants={itemVariants}
          className="text-center"
        >
          <motion.div
            initial={{ scale: 0 }}
            animate={{ scale: 1 }}
            transition={{ 
              type: "spring",
              stiffness: 200,
              damping: 15,
              delay: 0.2
            }}
            className="w-24 h-24 bg-gradient-to-r from-green-500 to-emerald-500 rounded-full flex items-center justify-center mx-auto mb-4"
          >
            <CheckCircle className="w-12 h-12 text-white" />
          </motion.div>
          <h1 className="text-2xl font-bold text-gray-900 dark:text-white mb-2">
            결제가 완료되었습니다!
          </h1>
          <p className="text-gray-600 dark:text-gray-400">
            토큰이 성공적으로 충전되었습니다
          </p>
        </motion.div>

        {/* 구매 내역 */}
        <motion.div variants={itemVariants}>
          <Card className="border-green-200 bg-gradient-to-r from-green-50 to-emerald-50 dark:from-green-900/20 dark:to-emerald-900/20">
            <CardContent className="p-6 space-y-4">
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <Coins className="w-8 h-8 text-green-600" />
                  <div>
                    <p className="text-sm text-gray-600 dark:text-gray-400">충전된 토큰</p>
                    <p className="text-2xl font-bold text-gray-900 dark:text-white">
                      {purchaseDetails?.amount || 0}개
                    </p>
                    {purchaseDetails?.bonus > 0 && (
                      <p className="text-xs text-green-600 flex items-center gap-1">
                        <Gift className="w-3 h-3" />
                        보너스 {purchaseDetails.bonus}개 포함
                      </p>
                    )}
                  </div>
                </div>
                <div className="text-right">
                  <p className="text-sm text-gray-500 dark:text-gray-400">결제 금액</p>
                  <p className="text-lg font-semibold">
                    ₩{purchaseDetails?.price?.toLocaleString() || 0}
                  </p>
                </div>
              </div>
            </CardContent>
          </Card>
        </motion.div>

        {/* 현재 잔액 */}
        <motion.div variants={itemVariants}>
          <Card>
            <CardContent className="p-6">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm text-gray-600 dark:text-gray-400 mb-1">
                    현재 토큰 잔액
                  </p>
                  <p className="text-3xl font-bold text-purple-600">
                    {newBalance.toLocaleString()}개
                  </p>
                </div>
                <Sparkles className="w-8 h-8 text-purple-400" />
              </div>
            </CardContent>
          </Card>
        </motion.div>

        {/* 추천 액션 */}
        <motion.div variants={itemVariants}>
          <Card className="bg-gradient-to-r from-purple-500 to-indigo-500 text-white">
            <CardContent className="p-6">
              <div className="flex items-center gap-3 mb-4">
                <Star className="w-6 h-6" />
                <h3 className="font-semibold text-lg">운세를 확인해보세요!</h3>
              </div>
              <p className="text-purple-100 text-sm mb-4">
                충전한 토큰으로 다양한 운세를 확인할 수 있습니다.
                오늘의 운세부터 시작해보는 건 어떨까요?
              </p>
              <div className="flex gap-3">
                <Button
                  onClick={() => router.push('/fortune/today')}
                  className="bg-white text-purple-600 hover:bg-purple-50"
                >
                  오늘의 운세
                </Button>
                <Button
                  onClick={() => router.push('/fortune/love')}
                  variant="outline"
                  className="border-white text-white hover:bg-white/20"
                >
                  연애운
                </Button>
              </div>
            </CardContent>
          </Card>
        </motion.div>

        {/* 액션 버튼 */}
        <motion.div variants={itemVariants} className="space-y-3">
          <Button
            onClick={() => router.push('/')}
            className="w-full bg-gradient-to-r from-purple-600 to-indigo-600 hover:from-purple-700 hover:to-indigo-700 text-white"
          >
            <ArrowRight className="w-5 h-5 mr-2" />
            운세 보러 가기
          </Button>
          
          <Button
            onClick={() => router.push('/history')}
            variant="outline"
            className="w-full"
          >
            결제 내역 확인
          </Button>
        </motion.div>

        {/* 프리미엄 안내 */}
        <motion.div variants={itemVariants}>
          <div className="bg-amber-50 dark:bg-amber-900/20 border border-amber-200 dark:border-amber-700 rounded-lg p-4">
            <div className="flex items-start gap-3">
              <Crown className="w-5 h-5 text-amber-600 flex-shrink-0 mt-0.5" />
              <div>
                <p className="text-sm font-medium text-amber-800 dark:text-amber-300">
                  💡 더 많은 혜택을 원하시나요?
                </p>
                <p className="text-xs text-amber-700 dark:text-amber-400 mt-1">
                  프리미엄 구독으로 모든 운세를 무제한으로 이용하세요!
                </p>
                <Button
                  onClick={() => router.push('/membership')}
                  size="sm"
                  variant="link"
                  className="text-amber-700 dark:text-amber-400 p-0 h-auto mt-2"
                >
                  프리미엄 구독 알아보기 →
                </Button>
              </div>
            </div>
          </div>
        </motion.div>
      </motion.div>
    </div>
  );
}

export default function PaymentSuccessPage() {
  return (
    <Suspense fallback={
      <div className="min-h-screen bg-gradient-to-br from-purple-50 via-indigo-50 to-blue-50 dark:from-gray-900 dark:via-gray-800 dark:to-gray-900 pb-20">
        <AppHeader title="결제 완료" />
        <div className="flex items-center justify-center h-[60vh]">
          <Loader2 className="w-8 h-8 animate-spin text-purple-600" />
        </div>
      </div>
    }>
      <SuccessContent />
    </Suspense>
  );
}