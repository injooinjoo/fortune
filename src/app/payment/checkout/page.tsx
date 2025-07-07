"use client";

import { useState, useEffect, Suspense } from "react";
import { useRouter, useSearchParams } from "next/navigation";
import { motion } from "framer-motion";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Separator } from "@/components/ui/separator";
import AppHeader from "@/components/AppHeader";
import {
  CreditCard,
  Shield,
  Lock,
  CheckCircle,
  AlertCircle,
  Loader2,
  ArrowLeft,
  ShoppingBag,
  Sparkles
} from "lucide-react";
// import { loadStripe } from '@stripe/stripe-js';
// import { loadTossPayments } from '@tosspayments/payment-sdk';
import { loadStripe, loadTossPayments } from '@/lib/payment-mock';
import { auth } from "@/lib/supabase";
import { logger } from "@/lib/logger";

// Stripe 초기화
const stripePromise = process.env.NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY
  ? loadStripe(process.env.NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY)
  : null;

function CheckoutContent() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [userEmail, setUserEmail] = useState<string>('');
  const [userId, setUserId] = useState<string>('');

  // URL 파라미터에서 결제 정보 추출
  const provider = searchParams.get('provider') || 'stripe';
  const clientSecret = searchParams.get('client_secret');
  const orderId = searchParams.get('orderId');
  const amount = searchParams.get('amount');
  const orderName = searchParams.get('orderName');

  useEffect(() => {
    loadUserData();
    
    // Stripe 결제 처리
    if (provider === 'stripe' && clientSecret) {
      handleStripePayment();
    }
    // 토스페이먼츠 결제 처리
    else if (provider === 'toss' && orderId && amount && orderName) {
      handleTossPayment();
    }
  }, []);

  const loadUserData = async () => {
    try {
      const { data: sessionData } = await auth.getSession();
      if (!sessionData?.session?.user) {
        router.push('/auth/login?redirect=/payment/checkout');
        return;
      }

      setUserId(sessionData.session.user.id);
      setUserEmail(sessionData.session.user.email || '');
    } catch (error) {
      logger.error('사용자 정보 로드 실패:', error);
    }
  };

  const handleStripePayment = async () => {
    if (!stripePromise || !clientSecret) {
      setError('결제 정보를 찾을 수 없습니다.');
      return;
    }

    setLoading(true);
    
    try {
      const stripe = await stripePromise;
      
      // Stripe Elements 사용하여 결제 처리
      // 실제 구현에서는 Stripe Elements UI 컴포넌트를 추가해야 함
      setError('Stripe 결제 UI를 구현해주세요.');
    } catch (err) {
      logger.error('Stripe 결제 오류:', err);
      setError('결제 처리 중 오류가 발생했습니다.');
    } finally {
      setLoading(false);
    }
  };

  const handleTossPayment = async () => {
    if (!orderId || !amount || !orderName) {
      setError('결제 정보가 올바르지 않습니다.');
      return;
    }

    setLoading(true);

    try {
      const tossPayments = await loadTossPayments(process.env.NEXT_PUBLIC_TOSS_CLIENT_KEY!);
      
      // 토스페이먼츠 결제창 호출
      await tossPayments.requestPayment('카드', {
        amount: Number(amount),
        orderId: orderId,
        orderName: decodeURIComponent(orderName),
        customerName: userEmail.split('@')[0],
        customerEmail: userEmail,
        successUrl: `${window.location.origin}/payment/success`,
        failUrl: `${window.location.origin}/payment/fail`,
      });
    } catch (err: any) {
      logger.error('토스페이먼츠 결제 오류:', err);
      
      if (err.code === 'USER_CANCEL') {
        // 사용자가 결제를 취소한 경우
        router.back();
      } else {
        setError(err.message || '결제 처리 중 오류가 발생했습니다.');
      }
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-purple-50 via-indigo-50 to-blue-50 dark:from-gray-900 dark:via-gray-800 dark:to-gray-900 pb-20">
      <AppHeader title="결제하기" />
      
      <div className="p-6 space-y-6 max-w-lg mx-auto">
        {/* 결제 정보 카드 */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5 }}
        >
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <ShoppingBag className="w-5 h-5 text-purple-600" />
                주문 정보
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              {orderName && (
                <div className="flex justify-between items-center">
                  <span className="text-gray-600 dark:text-gray-400">상품명</span>
                  <span className="font-medium">{decodeURIComponent(orderName)}</span>
                </div>
              )}
              
              {amount && (
                <>
                  <Separator />
                  <div className="flex justify-between items-center">
                    <span className="text-gray-600 dark:text-gray-400">결제 금액</span>
                    <span className="text-xl font-bold text-purple-600">
                      ₩{Number(amount).toLocaleString()}
                    </span>
                  </div>
                </>
              )}
            </CardContent>
          </Card>
        </motion.div>

        {/* 결제 수단 선택 */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5, delay: 0.1 }}
        >
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <CreditCard className="w-5 h-5 text-purple-600" />
                결제 수단
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-3">
                <div className="flex items-center justify-between p-4 border rounded-lg bg-purple-50 dark:bg-purple-900/20 border-purple-200 dark:border-purple-700">
                  <div className="flex items-center gap-3">
                    <CreditCard className="w-5 h-5 text-purple-600" />
                    <span className="font-medium">신용/체크카드</span>
                  </div>
                  <CheckCircle className="w-5 h-5 text-purple-600" />
                </div>
              </div>
            </CardContent>
          </Card>
        </motion.div>

        {/* 보안 안내 */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5, delay: 0.2 }}
        >
          <Card className="bg-gray-50 dark:bg-gray-800 border-gray-200 dark:border-gray-700">
            <CardContent className="p-4">
              <div className="flex items-start gap-3">
                <Shield className="w-5 h-5 text-green-600 flex-shrink-0 mt-0.5" />
                <div className="space-y-2">
                  <p className="text-sm font-medium text-gray-900 dark:text-gray-100">
                    안전한 결제
                  </p>
                  <p className="text-xs text-gray-600 dark:text-gray-400">
                    모든 결제 정보는 SSL 암호화되어 안전하게 처리됩니다.
                    결제 정보는 저장되지 않습니다.
                  </p>
                </div>
              </div>
            </CardContent>
          </Card>
        </motion.div>

        {/* 에러 메시지 */}
        {error && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            className="bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-700 rounded-lg p-4"
          >
            <div className="flex items-start gap-3">
              <AlertCircle className="w-5 h-5 text-red-600 flex-shrink-0 mt-0.5" />
              <div>
                <p className="text-sm font-medium text-red-800 dark:text-red-300">
                  결제 오류
                </p>
                <p className="text-xs text-red-600 dark:text-red-400 mt-1">
                  {error}
                </p>
              </div>
            </div>
          </motion.div>
        )}

        {/* 액션 버튼 */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5, delay: 0.3 }}
          className="space-y-3"
        >
          {loading ? (
            <Button
              disabled
              className="w-full bg-gray-400 text-white py-6"
            >
              <Loader2 className="w-5 h-5 mr-2 animate-spin" />
              결제 처리 중...
            </Button>
          ) : (
            <>
              <Button
                onClick={() => {
                  if (provider === 'stripe') {
                    handleStripePayment();
                  } else {
                    handleTossPayment();
                  }
                }}
                className="w-full bg-gradient-to-r from-purple-600 to-indigo-600 hover:from-purple-700 hover:to-indigo-700 text-white py-6 text-lg font-semibold"
              >
                <Lock className="w-5 h-5 mr-2" />
                안전하게 결제하기
              </Button>
              
              <Button
                onClick={() => router.back()}
                variant="outline"
                className="w-full"
              >
                <ArrowLeft className="w-4 h-4 mr-2" />
                이전으로
              </Button>
            </>
          )}
        </motion.div>

        {/* 결제 제공사 로고 */}
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ duration: 0.5, delay: 0.4 }}
          className="flex items-center justify-center gap-4 pt-4"
        >
          <div className="flex items-center gap-2 text-xs text-gray-500 dark:text-gray-400">
            <Lock className="w-3 h-3" />
            <span>Powered by</span>
            <span className="font-semibold">
              {provider === 'stripe' ? 'Stripe' : 'TossPayments'}
            </span>
          </div>
        </motion.div>
      </div>
    </div>
  );
}

export default function CheckoutPage() {
  return (
    <Suspense fallback={
      <div className="min-h-screen bg-gradient-to-br from-purple-50 via-indigo-50 to-blue-50 dark:from-gray-900 dark:via-gray-800 dark:to-gray-900 pb-20">
        <AppHeader title="결제하기" />
        <div className="flex items-center justify-center h-[60vh]">
          <Loader2 className="w-8 h-8 animate-spin text-purple-600" />
        </div>
      </div>
    }>
      <CheckoutContent />
    </Suspense>
  );
}