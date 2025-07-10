"use client";

import { useToast } from '@/hooks/use-toast';
import { useState, useEffect } from "react";
import { useRouter } from "next/navigation";
import { motion } from "framer-motion";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import AppHeader from "@/components/AppHeader";
import {
  Coins,
  ShoppingCart,
  Sparkles,
  TrendingUp,
  CreditCard,
  Shield,
  Zap,
  Gift,
  Star,
  ArrowRight,
  Check,
  Plus,
  Info
} from "lucide-react";
import { auth } from "@/lib/supabase";
import { logger } from "@/lib/logger";

interface TokenPackage {
  id: string;
  name: string;
  tokens: number;
  price: number;
  bonus?: number;
  popular?: boolean;
  gradient: string;
  description: string;
}

const tokenPackages: TokenPackage[] = [
  {
    id: 'small',
    name: '스타터 팩',
    tokens: 10,
    price: 1000,
    gradient: 'from-gray-400 to-gray-600',
    description: '가볍게 시작하기'
  },
  {
    id: 'medium',
    name: '스탠다드 팩',
    tokens: 60,
    price: 5000,
    bonus: 20,
    popular: true,
    gradient: 'from-purple-500 to-indigo-500',
    description: '가장 인기 있는 선택'
  },
  {
    id: 'large',
    name: '프리미엄 팩',
    tokens: 150,
    price: 10000,
    bonus: 50,
    gradient: 'from-amber-500 to-orange-500',
    description: '최고의 가치'
  }
];

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

export default function TokenPurchasePage() {
  const { toast } = useToast();
  const router = useRouter();
  const [loading, setLoading] = useState(false);
  const [currentBalance, setCurrentBalance] = useState(0);
  const [isUnlimited, setIsUnlimited] = useState(false);
  const [userId, setUserId] = useState<string | null>(null);
  const [selectedPackage, setSelectedPackage] = useState<string | null>(null);

  useEffect(() => {
    loadUserData();
  }, []);

  const loadUserData = async () => {
    try {
      const { data: sessionData } = await auth.getSession();
      if (!sessionData?.session?.user) {
        router.push('/auth/login?redirect=/payment/tokens');
        return;
      }

      setUserId(sessionData.session.user.id);
      
      const response = await fetch('/api/user/token-balance');
      if (response.ok) {
        const data = await response.json();
        setCurrentBalance(data.data.balance);
        setIsUnlimited(data.data.isUnlimited);
      }
    } catch (error) {
      logger.error('토큰 잔액 로드 실패:', error);
    }
  };

  const handlePurchase = async (packageId: string) => {
    if (!userId) {
      router.push('/auth/login?redirect=/payment/tokens');
      return;
    }

    setLoading(true);
    setSelectedPackage(packageId);

    try {
      // 결제 세션 생성
      const response = await fetch('/api/payment/create-checkout', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          provider: 'stripe', // 또는 'toss'
          productType: 'tokens',
          productId: packageId,
          returnUrl: `${window.location.origin}/payment/success`,
          cancelUrl: `${window.location.origin}/payment/tokens`
        })
      });

      if (!response.ok) {
        throw new Error('결제 준비 중 오류가 발생했습니다.');
      }

      const data = await response.json();

      if (data.provider === 'stripe' && data.checkoutUrl) {
        // Stripe 결제 페이지로 리다이렉트
        window.location.href = data.checkoutUrl;
      } else if (data.provider === 'toss') {
        // 토스페이먼츠 결제창 호출
        router.push(`/payment/checkout?provider=toss&orderId=${data.orderId}&amount=${data.amount}&orderName=${encodeURIComponent(data.orderName)}`);
      }
    } catch (error) {
      logger.error('결제 처리 실패:', error);
      toast({
      title: '결제 처리 중 오류가 발생했습니다. 다시 시도해주세요.',
      variant: "destructive",
    });
    } finally {
      setLoading(false);
      setSelectedPackage(null);
    }
  };

  if (isUnlimited) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-purple-50 via-indigo-50 to-blue-50 dark:from-gray-900 dark:via-gray-800 dark:to-gray-900 pb-20">
        <AppHeader title="토큰 구매" showTokenBalance={false} />
        
        <div className="p-6 space-y-6">
          <Card className="border-purple-200 bg-gradient-to-r from-purple-50 to-indigo-50 dark:from-purple-900/20 dark:to-indigo-900/20">
            <CardContent className="p-6 text-center">
              <div className="w-16 h-16 bg-gradient-to-r from-purple-500 to-indigo-500 rounded-full flex items-center justify-center mx-auto mb-4">
                <Sparkles className="w-8 h-8 text-white" />
              </div>
              <h2 className="text-xl font-bold text-purple-800 dark:text-purple-300 mb-2">
                프리미엄 구독 중
              </h2>
              <p className="text-gray-600 dark:text-gray-400">
                무제한으로 모든 운세를 이용하실 수 있습니다.
              </p>
              <Button
                onClick={() => router.push('/membership')}
                className="mt-4 bg-gradient-to-r from-purple-600 to-indigo-600 hover:from-purple-700 hover:to-indigo-700 text-white"
              >
                구독 관리
              </Button>
            </CardContent>
          </Card>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-purple-50 via-indigo-50 to-blue-50 dark:from-gray-900 dark:via-gray-800 dark:to-gray-900 pb-20">
      <AppHeader title="토큰 구매" showTokenBalance={false} />
      
      <motion.div
        variants={containerVariants}
        initial="hidden"
        animate="visible"
        className="p-6 space-y-6"
      >
        {/* 현재 토큰 잔액 */}
        <motion.div variants={itemVariants}>
          <Card className="border-indigo-200 bg-gradient-to-r from-indigo-50 to-blue-50 dark:from-indigo-900/20 dark:to-blue-900/20">
            <CardContent className="p-6">
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <div className="w-12 h-12 bg-gradient-to-r from-indigo-500 to-blue-500 rounded-full flex items-center justify-center">
                    <Coins className="w-6 h-6 text-white" />
                  </div>
                  <div>
                    <p className="text-sm text-gray-600 dark:text-gray-400">현재 토큰</p>
                    <p className="text-2xl font-bold text-gray-900 dark:text-white">
                      {currentBalance.toLocaleString()}개
                    </p>
                  </div>
                </div>
                <div className="text-right">
                  <p className="text-xs text-gray-500 dark:text-gray-400">다음 무료 토큰</p>
                  <p className="text-sm font-medium text-gray-700 dark:text-gray-300">매일 자정</p>
                </div>
              </div>
            </CardContent>
          </Card>
        </motion.div>

        {/* 헤더 */}
        <motion.div variants={itemVariants} className="text-center">
          <h1 className="text-2xl font-bold text-gray-900 dark:text-white mb-2">
            토큰 충전하기
          </h1>
          <p className="text-gray-600 dark:text-gray-400">
            더 많은 운세를 보려면 토큰을 충전하세요
          </p>
        </motion.div>

        {/* 토큰 패키지 */}
        <div className="space-y-4">
          {tokenPackages.map((pkg) => (
            <motion.div
              key={pkg.id}
              variants={itemVariants}
              whileHover={{ scale: 1.02 }}
              transition={{ type: "spring", stiffness: 300 }}
            >
              <Card className={`relative overflow-hidden ${
                pkg.popular ? 'border-purple-300 shadow-lg' : ''
              }`}>
                {pkg.popular && (
                  <div className="absolute top-0 right-0 bg-gradient-to-r from-purple-500 to-indigo-500 text-white px-3 py-1 text-xs font-medium rounded-bl-lg">
                    인기
                  </div>
                )}
                
                <CardContent className="p-6">
                  <div className="flex items-center justify-between">
                    <div className="flex items-center gap-4">
                      <div className={`w-14 h-14 rounded-full bg-gradient-to-r ${pkg.gradient} flex items-center justify-center`}>
                        <Coins className="w-7 h-7 text-white" />
                      </div>
                      <div>
                        <h3 className="font-semibold text-lg text-gray-900 dark:text-white">
                          {pkg.name}
                        </h3>
                        <p className="text-sm text-gray-600 dark:text-gray-400">
                          {pkg.description}
                        </p>
                        <div className="flex items-center gap-2 mt-1">
                          <span className="text-2xl font-bold text-gray-900 dark:text-white">
                            {pkg.tokens}개
                          </span>
                          {pkg.bonus && (
                            <Badge className="bg-green-100 text-green-700 dark:bg-green-900/30 dark:text-green-400">
                              +{pkg.bonus}% 보너스
                            </Badge>
                          )}
                        </div>
                      </div>
                    </div>
                    
                    <div className="text-right">
                      <Button
                        onClick={() => handlePurchase(pkg.id)}
                        disabled={loading}
                        className={`min-w-[100px] ${
                          pkg.popular 
                            ? 'bg-gradient-to-r from-purple-600 to-indigo-600 hover:from-purple-700 hover:to-indigo-700' 
                            : 'bg-gray-600 hover:bg-gray-700'
                        } text-white`}
                      >
                        {loading && selectedPackage === pkg.id ? (
                          <div className="flex items-center gap-2">
                            <div className="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin" />
                            처리중...
                          </div>
                        ) : (
                          <div className="flex items-center gap-1">
                            <span>₩{pkg.price.toLocaleString()}</span>
                          </div>
                        )}
                      </Button>
                      <p className="text-xs text-gray-500 dark:text-gray-400 mt-1">
                        개당 ₩{Math.round(pkg.price / pkg.tokens)}
                      </p>
                    </div>
                  </div>
                </CardContent>
              </Card>
            </motion.div>
          ))}
        </div>

        {/* 토큰 사용 안내 */}
        <motion.div variants={itemVariants}>
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2 text-lg">
                <Info className="w-5 h-5 text-blue-600" />
                토큰 사용 안내
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-3">
              <div className="flex items-start gap-3">
                <Zap className="w-5 h-5 text-amber-500 flex-shrink-0 mt-0.5" />
                <div>
                  <p className="font-medium text-sm">운세별 토큰 사용량</p>
                  <p className="text-xs text-gray-600 dark:text-gray-400">
                    간단한 운세 1개, 상세 운세 2-3개, 프리미엄 운세 5개
                  </p>
                </div>
              </div>
              <div className="flex items-start gap-3">
                <Gift className="w-5 h-5 text-green-500 flex-shrink-0 mt-0.5" />
                <div>
                  <p className="font-medium text-sm">무료 토큰</p>
                  <p className="text-xs text-gray-600 dark:text-gray-400">
                    매일 자정에 3개의 무료 토큰이 지급됩니다
                  </p>
                </div>
              </div>
              <div className="flex items-start gap-3">
                <Shield className="w-5 h-5 text-blue-500 flex-shrink-0 mt-0.5" />
                <div>
                  <p className="font-medium text-sm">안전한 결제</p>
                  <p className="text-xs text-gray-600 dark:text-gray-400">
                    모든 결제는 암호화되어 안전하게 처리됩니다
                  </p>
                </div>
              </div>
            </CardContent>
          </Card>
        </motion.div>

        {/* 프리미엄 구독 안내 */}
        <motion.div variants={itemVariants}>
          <Card className="bg-gradient-to-r from-purple-500 to-indigo-500 text-white">
            <CardContent className="p-6">
              <div className="flex items-center justify-between">
                <div>
                  <h3 className="font-bold text-lg mb-1">무제한으로 이용하고 싶으신가요?</h3>
                  <p className="text-purple-100 text-sm">
                    프리미엄 구독으로 모든 운세를 무제한 이용하세요
                  </p>
                </div>
                <Button
                  onClick={() => router.push('/membership')}
                  className="bg-white text-purple-600 hover:bg-purple-50"
                >
                  <Star className="w-4 h-4 mr-2" />
                  프리미엄 구독
                </Button>
              </div>
            </CardContent>
          </Card>
        </motion.div>
      </motion.div>
    </div>
  );
}