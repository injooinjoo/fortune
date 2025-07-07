"use client";

import { useEffect, Suspense } from "react";
import { useRouter, useSearchParams } from "next/navigation";
import { motion } from "framer-motion";
import { Card, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import AppHeader from "@/components/AppHeader";
import {
  XCircle,
  AlertCircle,
  RefreshCw,
  ArrowLeft,
  HelpCircle,
  MessageCircle,
  Home,
  CreditCard
} from "lucide-react";
import { logger } from "@/lib/logger";

function FailContent() {
  const router = useRouter();
  const searchParams = useSearchParams();
  
  // 에러 정보 추출
  const errorCode = searchParams.get('code');
  const errorMessage = searchParams.get('message');

  useEffect(() => {
    // 실패 원인 로깅
    logger.error('결제 실패', {
      errorCode,
      errorMessage,
      url: window.location.href
    });
  }, [errorCode, errorMessage]);

  const getErrorMessage = () => {
    switch (errorCode) {
      case 'USER_CANCEL':
        return '결제를 취소하셨습니다.';
      case 'INVALID_CARD':
        return '유효하지 않은 카드 정보입니다.';
      case 'INSUFFICIENT_FUNDS':
        return '잔액이 부족합니다.';
      case 'NETWORK_ERROR':
        return '네트워크 오류가 발생했습니다.';
      default:
        return errorMessage || '결제 처리 중 오류가 발생했습니다.';
    }
  };

  const containerVariants = {
    hidden: { opacity: 0 },
    visible: {
      opacity: 1,
      transition: {
        staggerChildren: 0.1,
        delayChildren: 0.2
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

  return (
    <div className="min-h-screen bg-gradient-to-br from-red-50 via-orange-50 to-amber-50 dark:from-gray-900 dark:via-gray-800 dark:to-gray-900 pb-20">
      <AppHeader title="결제 실패" />
      
      <motion.div
        variants={containerVariants}
        initial="hidden"
        animate="visible"
        className="p-6 space-y-6 max-w-lg mx-auto"
      >
        {/* 실패 아이콘 */}
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
            className="w-24 h-24 bg-gradient-to-r from-red-500 to-orange-500 rounded-full flex items-center justify-center mx-auto mb-4"
          >
            <XCircle className="w-12 h-12 text-white" />
          </motion.div>
          <h1 className="text-2xl font-bold text-gray-900 dark:text-white mb-2">
            결제에 실패했습니다
          </h1>
          <p className="text-gray-600 dark:text-gray-400">
            {getErrorMessage()}
          </p>
        </motion.div>

        {/* 오류 상세 정보 */}
        <motion.div variants={itemVariants}>
          <Card className="border-red-200 bg-red-50 dark:bg-red-900/20">
            <CardContent className="p-6">
              <div className="flex items-start gap-3">
                <AlertCircle className="w-5 h-5 text-red-600 flex-shrink-0 mt-0.5" />
                <div className="space-y-2">
                  <p className="font-medium text-red-800 dark:text-red-300">
                    결제를 완료할 수 없습니다
                  </p>
                  <p className="text-sm text-red-700 dark:text-red-400">
                    {errorCode === 'USER_CANCEL' 
                      ? '결제 과정에서 취소하셨습니다. 다시 시도하시려면 아래 버튼을 클릭해주세요.'
                      : '일시적인 오류일 수 있습니다. 잠시 후 다시 시도해주세요.'}
                  </p>
                  {errorCode && (
                    <p className="text-xs text-red-600 dark:text-red-500 font-mono">
                      오류 코드: {errorCode}
                    </p>
                  )}
                </div>
              </div>
            </CardContent>
          </Card>
        </motion.div>

        {/* 해결 방법 제안 */}
        <motion.div variants={itemVariants}>
          <Card>
            <CardContent className="p-6 space-y-4">
              <h3 className="font-semibold flex items-center gap-2">
                <HelpCircle className="w-5 h-5 text-blue-600" />
                이렇게 해보세요
              </h3>
              <div className="space-y-3 text-sm">
                <div className="flex items-start gap-2">
                  <div className="w-1.5 h-1.5 bg-blue-600 rounded-full mt-1.5 flex-shrink-0" />
                  <p className="text-gray-700 dark:text-gray-300">
                    카드 정보가 정확한지 확인해주세요
                  </p>
                </div>
                <div className="flex items-start gap-2">
                  <div className="w-1.5 h-1.5 bg-blue-600 rounded-full mt-1.5 flex-shrink-0" />
                  <p className="text-gray-700 dark:text-gray-300">
                    카드 잔액이 충분한지 확인해주세요
                  </p>
                </div>
                <div className="flex items-start gap-2">
                  <div className="w-1.5 h-1.5 bg-blue-600 rounded-full mt-1.5 flex-shrink-0" />
                  <p className="text-gray-700 dark:text-gray-300">
                    다른 결제 수단을 이용해보세요
                  </p>
                </div>
                <div className="flex items-start gap-2">
                  <div className="w-1.5 h-1.5 bg-blue-600 rounded-full mt-1.5 flex-shrink-0" />
                  <p className="text-gray-700 dark:text-gray-300">
                    문제가 계속되면 고객센터로 문의해주세요
                  </p>
                </div>
              </div>
            </CardContent>
          </Card>
        </motion.div>

        {/* 액션 버튼 */}
        <motion.div variants={itemVariants} className="space-y-3">
          <Button
            onClick={() => router.push('/payment/tokens')}
            className="w-full bg-gradient-to-r from-purple-600 to-indigo-600 hover:from-purple-700 hover:to-indigo-700 text-white"
          >
            <RefreshCw className="w-5 h-5 mr-2" />
            다시 시도하기
          </Button>
          
          <Button
            onClick={() => router.push('/')}
            variant="outline"
            className="w-full"
          >
            <Home className="w-4 h-4 mr-2" />
            홈으로 가기
          </Button>
        </motion.div>

        {/* 고객 지원 */}
        <motion.div variants={itemVariants}>
          <Card className="bg-gray-50 dark:bg-gray-800">
            <CardContent className="p-6">
              <div className="text-center space-y-3">
                <MessageCircle className="w-8 h-8 text-gray-600 dark:text-gray-400 mx-auto" />
                <div>
                  <p className="font-medium text-gray-900 dark:text-gray-100">
                    도움이 필요하신가요?
                  </p>
                  <p className="text-sm text-gray-600 dark:text-gray-400 mt-1">
                    고객센터에서 도와드리겠습니다
                  </p>
                </div>
                <div className="flex gap-3 justify-center">
                  <Button
                    onClick={() => router.push('/support')}
                    size="sm"
                    variant="secondary"
                  >
                    고객센터
                  </Button>
                  <Button
                    onClick={() => router.push('/faq')}
                    size="sm"
                    variant="secondary"
                  >
                    자주 묻는 질문
                  </Button>
                </div>
              </div>
            </CardContent>
          </Card>
        </motion.div>
      </motion.div>
    </div>
  );
}

export default function PaymentFailPage() {
  return (
    <Suspense fallback={
      <div className="min-h-screen bg-gradient-to-br from-red-50 via-orange-50 to-amber-50 dark:from-gray-900 dark:via-gray-800 dark:to-gray-900 pb-20">
        <AppHeader title="결제 실패" />
        <div className="flex items-center justify-center h-[60vh]">
          <div className="w-8 h-8 border-4 border-red-600 border-t-transparent rounded-full animate-spin" />
        </div>
      </div>
    }>
      <FailContent />
    </Suspense>
  );
}