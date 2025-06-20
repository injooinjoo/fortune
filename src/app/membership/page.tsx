"use client";

import { useState, useEffect } from "react";
import { useRouter } from "next/navigation";
import { motion } from "framer-motion";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Switch } from "@/components/ui/switch";
import AppHeader from "@/components/AppHeader";
import {
  Crown,
  Star,
  Zap,
  Shield,
  Heart,
  Sparkles,
  Infinity,
  CheckCircle,
  XCircle,
  Calendar,
  CreditCard,
  Gift,
  Users,
  BarChart3,
  Clock,
  ArrowRight,
  Gem
} from "lucide-react";
import { supabase } from "@/lib/supabase";

interface SubscriptionPlan {
  id: string;
  name: string;
  price: number;
  period: 'month' | 'year';
  features: string[];
  popular?: boolean;
  icon: React.ComponentType<{ className?: string }>;
  gradient: string;
  description: string;
}

const plans: SubscriptionPlan[] = [
  {
    id: 'free',
    name: '무료',
    price: 0,
    period: 'month',
    description: '기본적인 운세 서비스를 무료로 이용하세요',
    icon: Star,
    gradient: 'from-gray-400 to-gray-600',
    features: [
      '하루 3회 운세 조회',
      '기본 운세 (데일리, 연애, 재물)',
      '운세 히스토리 7일',
      '커뮤니티 기본 기능',
      '광고 포함'
    ]
  },
  {
    id: 'premium',
    name: '프리미엄',
    price: 9900,
    period: 'month',
    description: '더 정확하고 상세한 운세로 업그레이드하세요',
    icon: Crown,
    gradient: 'from-purple-500 to-indigo-500',
    popular: true,
    features: [
      '무제한 운세 조회',
      '모든 운세 타입 (60여 개)',
      '상세 분석 및 조언',
      '운세 히스토리 무제한',
      '개인 맞춤 추천',
      '광고 제거',
      '우선 고객지원'
    ]
  },
  {
    id: 'premium_plus',
    name: '프리미엄 플러스',
    price: 19900,
    period: 'month',
    description: '최고 수준의 프리미엄 운세 경험을 제공합니다',
    icon: Gem,
    gradient: 'from-yellow-500 to-orange-500',
    features: [
      '프리미엄 모든 기능',
      'AI 전문가 상담 (월 3회)',
      '실시간 운세 알림',
      '독점 프리미엄 콘텐츠',
      '개인 운세 리포트 (월간)',
      '커뮤니티 VIP 기능',
      '24시간 우선 지원',
      '특별 이벤트 우선 참여'
    ]
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
      type: "spring" as const,
      stiffness: 100,
      damping: 10
    }
  }
};

export default function MembershipPage() {
  const router = useRouter();
  const [currentPlan, setCurrentPlan] = useState<string>('free');
  const [isYearly, setIsYearly] = useState(false);
  const [isLoading, setIsLoading] = useState(true);
  const [user, setUser] = useState<any>(null);

  useEffect(() => {
    loadUserSubscription();
  }, []);

  const loadUserSubscription = async () => {
    try {
      const { data: { user: authUser } } = await supabase.auth.getUser();
      
      if (authUser) {
        setUser(authUser);
        // 실제로는 DB에서 구독 정보를 조회
        // const subscription = await getUserSubscription(authUser.id);
        // setCurrentPlan(subscription?.plan_id || 'free');
        setCurrentPlan('free'); // 임시
      }
    } catch (error) {
      console.error('구독 정보 로드 실패:', error);
    } finally {
      setIsLoading(false);
    }
  };

  const handleSubscribe = async (planId: string) => {
    if (planId === 'free') {
      // 무료 플랜으로 다운그레이드
      setCurrentPlan('free');
      return;
    }

    try {
      // 실제로는 결제 처리 API 호출
      console.log('구독 처리:', planId);
      // await processSubscription(planId, isYearly);
      
      // 성공 시 현재 플랜 업데이트
      setCurrentPlan(planId);
      
      // 성공 메시지 표시
      alert('구독이 성공적으로 처리되었습니다!');
    } catch (error) {
      console.error('구독 처리 실패:', error);
      alert('구독 처리 중 오류가 발생했습니다. 다시 시도해주세요.');
    }
  };

  const getPlanPrice = (plan: SubscriptionPlan) => {
    if (plan.price === 0) return '무료';
    
    const price = isYearly ? Math.floor(plan.price * 12 * 0.8) : plan.price;
    const period = isYearly ? '년' : '월';
    
    return `₩${price.toLocaleString()}/${period}`;
  };

  const getPlanBadge = (planId: string) => {
    switch (planId) {
      case 'premium':
        return <Badge className="bg-purple-500">현재 플랜</Badge>;
      case 'premium_plus':
        return <Badge className="bg-orange-500">현재 플랜</Badge>;
      case 'free':
        return <Badge variant="secondary">현재 플랜</Badge>;
      default:
        return null;
    }
  };

  if (isLoading) {
    return (
      <div className="min-h-screen bg-background pb-20">
        <AppHeader title="구독 관리" />
        <div className="p-6">
          <div className="animate-pulse space-y-4">
            <div className="h-32 bg-gray-200 rounded-lg"></div>
            <div className="h-64 bg-gray-200 rounded-lg"></div>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-purple-50 via-indigo-25 to-blue-50 dark:from-gray-900 dark:via-gray-800 dark:to-gray-900 pb-20">
      <AppHeader title="구독 관리" />
      
      <motion.div
        variants={containerVariants}
        initial="hidden"
        animate="visible"
        className="p-6 space-y-6"
      >
        {/* 헤더 */}
        <motion.div variants={itemVariants} className="text-center">
          <motion.div
            className="bg-gradient-to-r from-purple-500 to-indigo-500 rounded-full w-16 h-16 flex items-center justify-center mx-auto mb-4"
            whileHover={{ rotate: 360 }}
            transition={{ duration: 0.8 }}
          >
            <Crown className="w-8 h-8 text-white" />
          </motion.div>
          <h1 className="text-2xl font-bold text-gray-900 dark:text-white mb-2">
            프리미엄 멤버십
          </h1>
          <p className="text-gray-600 dark:text-gray-400">
            더 정확하고 상세한 운세로 업그레이드하세요
          </p>
        </motion.div>

        {/* 현재 구독 상태 */}
        {currentPlan !== 'free' && (
          <motion.div variants={itemVariants}>
            <Card className="border-purple-200 bg-gradient-to-r from-purple-50 to-indigo-50 dark:from-purple-900/20 dark:to-indigo-900/20">
              <CardContent className="p-6">
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-3">
                    <Crown className="w-6 h-6 text-purple-600" />
                    <div>
                      <h3 className="font-semibold text-purple-800 dark:text-purple-300">
                        {plans.find(p => p.id === currentPlan)?.name} 구독 중
                      </h3>
                      <p className="text-sm text-purple-600 dark:text-purple-400">
                        다음 결제일: 2024년 1월 15일
                      </p>
                    </div>
                  </div>
                  <Button variant="outline" size="sm">
                    구독 관리
                  </Button>
                </div>
              </CardContent>
            </Card>
          </motion.div>
        )}

        {/* 연간/월간 토글 */}
        <motion.div variants={itemVariants}>
          <Card>
            <CardContent className="p-6">
              <div className="flex items-center justify-center gap-4">
                <span className={`text-sm font-medium ${!isYearly ? 'text-purple-600' : 'text-gray-500'}`}>
                  월간
                </span>
                <Switch
                  checked={isYearly}
                  onCheckedChange={setIsYearly}
                />
                <span className={`text-sm font-medium ${isYearly ? 'text-purple-600' : 'text-gray-500'}`}>
                  연간
                </span>
                {isYearly && (
                  <Badge variant="outline" className="text-green-600 border-green-200">
                    20% 할인
                  </Badge>
                )}
              </div>
            </CardContent>
          </Card>
        </motion.div>

        {/* 구독 플랜들 */}
        <div className="space-y-4">
          {plans.map((plan, index) => (
            <motion.div
              key={plan.id}
              variants={itemVariants}
              whileHover={{ scale: 1.02 }}
              transition={{ type: "spring", stiffness: 300 }}
            >
              <Card className={`relative overflow-hidden ${
                plan.popular ? 'border-purple-300 shadow-lg' : ''
              } ${currentPlan === plan.id ? 'ring-2 ring-purple-500' : ''}`}>
                {plan.popular && (
                  <div className="absolute top-0 right-0 bg-gradient-to-r from-purple-500 to-indigo-500 text-white px-3 py-1 text-xs font-medium rounded-bl-lg">
                    인기
                  </div>
                )}
                
                <CardHeader className="pb-4">
                  <div className="flex items-center justify-between">
                    <div className="flex items-center gap-3">
                      <div className={`w-12 h-12 rounded-full bg-gradient-to-r ${plan.gradient} flex items-center justify-center`}>
                        <plan.icon className="w-6 h-6 text-white" />
                      </div>
                      <div>
                        <CardTitle className="flex items-center gap-2">
                          {plan.name}
                          {currentPlan === plan.id && getPlanBadge(plan.id)}
                        </CardTitle>
                        <p className="text-sm text-gray-600 dark:text-gray-400">
                          {plan.description}
                        </p>
                      </div>
                    </div>
                    <div className="text-right">
                      <div className="text-2xl font-bold text-gray-900 dark:text-white">
                        {getPlanPrice(plan)}
                      </div>
                      {isYearly && plan.price > 0 && (
                        <div className="text-sm text-green-600 line-through">
                          ₩{(plan.price * 12).toLocaleString()}/년
                        </div>
                      )}
                    </div>
                  </div>
                </CardHeader>

                <CardContent className="space-y-4">
                  <div className="space-y-2">
                    {plan.features.map((feature, featureIndex) => (
                      <div key={featureIndex} className="flex items-center gap-2">
                        <CheckCircle className="w-4 h-4 text-green-500 flex-shrink-0" />
                        <span className="text-sm text-gray-700 dark:text-gray-300">
                          {feature}
                        </span>
                      </div>
                    ))}
                  </div>

                  <Button
                    onClick={() => handleSubscribe(plan.id)}
                    disabled={currentPlan === plan.id}
                    className={`w-full ${
                      plan.id === 'free' 
                        ? 'bg-gray-500 hover:bg-gray-600' 
                        : `bg-gradient-to-r ${plan.gradient} hover:opacity-90`
                    } text-white`}
                  >
                    {currentPlan === plan.id ? (
                      '현재 플랜'
                    ) : plan.id === 'free' ? (
                      '무료 플랜으로 변경'
                    ) : (
                      <>
                        <ArrowRight className="w-4 h-4 mr-2" />
                        구독하기
                      </>
                    )}
                  </Button>
                </CardContent>
              </Card>
            </motion.div>
          ))}
        </div>

        {/* 혜택 정보 */}
        <motion.div variants={itemVariants}>
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <Gift className="w-5 h-5 text-purple-600" />
                프리미엄 혜택
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="grid grid-cols-2 gap-4">
                <div className="flex items-center gap-3 p-3 bg-purple-50 dark:bg-purple-900/20 rounded-lg">
                  <Infinity className="w-6 h-6 text-purple-600" />
                  <div>
                    <div className="font-medium text-sm">무제한 이용</div>
                    <div className="text-xs text-gray-600 dark:text-gray-400">제한 없이 자유롭게</div>
                  </div>
                </div>
                <div className="flex items-center gap-3 p-3 bg-indigo-50 dark:bg-indigo-900/20 rounded-lg">
                  <Shield className="w-6 h-6 text-indigo-600" />
                  <div>
                    <div className="font-medium text-sm">광고 제거</div>
                    <div className="text-xs text-gray-600 dark:text-gray-400">깔끔한 경험</div>
                  </div>
                </div>
                <div className="flex items-center gap-3 p-3 bg-blue-50 dark:bg-blue-900/20 rounded-lg">
                  <Sparkles className="w-6 h-6 text-blue-600" />
                  <div>
                    <div className="font-medium text-sm">상세 분석</div>
                    <div className="text-xs text-gray-600 dark:text-gray-400">더 정확한 결과</div>
                  </div>
                </div>
                <div className="flex items-center gap-3 p-3 bg-green-50 dark:bg-green-900/20 rounded-lg">
                  <Heart className="w-6 h-6 text-green-600" />
                  <div>
                    <div className="font-medium text-sm">우선 지원</div>
                    <div className="text-xs text-gray-600 dark:text-gray-400">빠른 고객 서비스</div>
                  </div>
                </div>
              </div>
            </CardContent>
          </Card>
        </motion.div>

        {/* FAQ */}
        <motion.div variants={itemVariants}>
          <Card>
            <CardHeader>
              <CardTitle>자주 묻는 질문</CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="space-y-2">
                <h4 className="font-medium">언제든지 구독을 취소할 수 있나요?</h4>
                <p className="text-sm text-gray-600 dark:text-gray-400">
                  네, 언제든지 구독을 취소하실 수 있습니다. 취소 후에도 결제 기간 만료까지는 프리미엄 기능을 이용하실 수 있습니다.
                </p>
              </div>
              <div className="space-y-2">
                <h4 className="font-medium">결제는 어떻게 처리되나요?</h4>
                <p className="text-sm text-gray-600 dark:text-gray-400">
                  안전한 결제 시스템을 통해 신용카드, 계좌이체 등 다양한 방법으로 결제하실 수 있습니다.
                </p>
              </div>
            </CardContent>
          </Card>
        </motion.div>
      </motion.div>
    </div>
  );
} 