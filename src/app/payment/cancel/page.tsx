"use client";

import { useRouter } from "next/navigation";
import { motion } from "framer-motion";
import { Card, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import AppHeader from "@/components/AppHeader";
import {
  XCircle,
  ArrowLeft,
  ShoppingCart,
  Info,
  CreditCard
} from "lucide-react";

export default function PaymentCancelPage() {
  const router = useRouter();

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
    <div className="min-h-screen bg-gradient-to-br from-gray-50 via-slate-50 to-zinc-50 dark:from-gray-900 dark:via-gray-800 dark:to-gray-900 pb-20">
      <AppHeader title="결제 취소" />
      
      <motion.div
        variants={containerVariants}
        initial="hidden"
        animate="visible"
        className="p-6 space-y-6 max-w-lg mx-auto"
      >
        {/* 취소 아이콘 */}
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
            className="w-24 h-24 bg-gradient-to-r from-gray-400 to-gray-600 rounded-full flex items-center justify-center mx-auto mb-4"
          >
            <XCircle className="w-12 h-12 text-white" />
          </motion.div>
          <h1 className="text-2xl font-bold text-gray-900 dark:text-white mb-2">
            결제를 취소하셨습니다
          </h1>
          <p className="text-gray-600 dark:text-gray-400">
            결제가 진행되지 않았습니다
          </p>
        </motion.div>

        {/* 안내 카드 */}
        <motion.div variants={itemVariants}>
          <Card className="bg-blue-50 dark:bg-blue-900/20 border-blue-200 dark:border-blue-700">
            <CardContent className="p-6">
              <div className="flex items-start gap-3">
                <Info className="w-5 h-5 text-blue-600 flex-shrink-0 mt-0.5" />
                <div className="space-y-2">
                  <p className="font-medium text-blue-800 dark:text-blue-300">
                    결제가 취소되었습니다
                  </p>
                  <p className="text-sm text-blue-700 dark:text-blue-400">
                    결제 금액이 청구되지 않았으니 안심하세요.
                    언제든지 다시 구매하실 수 있습니다.
                  </p>
                </div>
              </div>
            </CardContent>
          </Card>
        </motion.div>

        {/* 장바구니 상태 */}
        <motion.div variants={itemVariants}>
          <Card>
            <CardContent className="p-6">
              <div className="flex items-center gap-3 mb-4">
                <ShoppingCart className="w-5 h-5 text-gray-600" />
                <h3 className="font-semibold">선택하신 상품</h3>
              </div>
              <div className="bg-gray-50 dark:bg-gray-800 rounded-lg p-4">
                <p className="text-sm text-gray-600 dark:text-gray-400">
                  선택하신 상품은 장바구니에 그대로 남아있습니다.
                  준비되시면 언제든지 결제를 진행하실 수 있습니다.
                </p>
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
            <CreditCard className="w-5 h-5 mr-2" />
            다시 구매하기
          </Button>
          
          <Button
            onClick={() => router.push('/')}
            variant="outline"
            className="w-full"
          >
            <ArrowLeft className="w-4 h-4 mr-2" />
            홈으로 돌아가기
          </Button>
        </motion.div>

        {/* 추가 옵션 */}
        <motion.div variants={itemVariants}>
          <Card className="bg-gray-50 dark:bg-gray-800">
            <CardContent className="p-6">
              <p className="text-center text-sm text-gray-600 dark:text-gray-400">
                무료 토큰으로도 운세를 확인하실 수 있습니다.
                매일 자정에 3개의 무료 토큰이 지급됩니다.
              </p>
            </CardContent>
          </Card>
        </motion.div>
      </motion.div>
    </div>
  );
}