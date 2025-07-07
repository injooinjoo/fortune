'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { Card } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Progress } from '@/components/ui/progress';
import { 
  Crown, 
  CheckCircle2, 
  XCircle,
  Calendar,
  CreditCard,
  TrendingUp,
  AlertCircle,
  Sparkles,
  Gift,
  Star
} from 'lucide-react';
import { motion } from 'framer-motion';
import { useToast } from '@/hooks/use-toast';
import { getAuthToken } from '@/lib/auth-utils';

interface Subscription {
  status: 'active' | 'canceled' | 'past_due' | 'free';
  plan: 'free' | 'premium' | 'premium_plus';
  currentPeriodEnd?: string;
  cancelAtPeriodEnd?: boolean;
  monthlyTokens: number;
  usedTokens: number;
  nextBillingDate?: string;
  amount?: number;
}

const planFeatures = {
  free: [
    '하루 5개 토큰',
    '기본 운세 이용',
    '제한된 운세 종류',
    '광고 표시'
  ],
  premium: [
    '매월 100개 토큰',
    '모든 운세 이용 가능',
    '우선 응답 처리',
    '광고 없음',
    '운세 히스토리 무제한'
  ],
  premium_plus: [
    '매월 300개 토큰',
    '프리미엄 모든 혜택',
    'VIP 고객 지원',
    '베타 기능 우선 체험',
    '맞춤 운세 리포트'
  ]
};

const planPrices = {
  free: 0,
  premium: 9900,
  premium_plus: 19900
};

export default function SubscriptionPage() {
  const router = useRouter();
  const { toast } = useToast();
  const [subscription, setSubscription] = useState<Subscription | null>(null);
  const [loading, setLoading] = useState(true);
  const [canceling, setCanceling] = useState(false);

  useEffect(() => {
    fetchSubscription();
  }, []);

  const fetchSubscription = async () => {
    try {
      const token = await getAuthToken();
      if (!token) {
        router.push('/login');
        return;
      }

      const response = await fetch('/api/payment/subscription', {
        headers: {
          'Authorization': `Bearer ${token}`
        }
      });

      if (!response.ok) {
        throw new Error('구독 정보를 불러올 수 없습니다');
      }

      const data = await response.json();
      setSubscription(data);
    } catch (error) {
      console.error('구독 정보 조회 실패:', error);
      // 기본 무료 플랜으로 설정
      setSubscription({
        status: 'free',
        plan: 'free',
        monthlyTokens: 5,
        usedTokens: 0
      });
    } finally {
      setLoading(false);
    }
  };

  const handleUpgrade = async (newPlan: 'premium' | 'premium_plus') => {
    try {
      const token = await getAuthToken();
      if (!token) {
        router.push('/login');
        return;
      }

      const response = await fetch('/api/payment/subscription/upgrade', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({ plan: newPlan })
      });

      const data = await response.json();

      if (!response.ok) {
        throw new Error(data.error || '구독 업그레이드 실패');
      }

      // Stripe Checkout URL로 리다이렉트
      if (data.checkoutUrl) {
        window.location.href = data.checkoutUrl;
      }
    } catch (error) {
      toast({
        title: '업그레이드 실패',
        description: error instanceof Error ? error.message : '업그레이드 중 오류가 발생했습니다',
        variant: 'destructive'
      });
    }
  };

  const handleCancel = async () => {
    if (!confirm('정말 구독을 취소하시겠습니까? 현재 결제 기간이 끝나면 프리미엄 혜택이 종료됩니다.')) {
      return;
    }

    setCanceling(true);
    try {
      const token = await getAuthToken();
      if (!token) {
        router.push('/login');
        return;
      }

      const response = await fetch('/api/payment/subscription/cancel', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${token}`
        }
      });

      if (!response.ok) {
        throw new Error('구독 취소 실패');
      }

      toast({
        title: '구독 취소 완료',
        description: '현재 결제 기간이 끝나면 구독이 종료됩니다.'
      });

      await fetchSubscription();
    } catch (error) {
      toast({
        title: '취소 실패',
        description: '구독 취소 중 오류가 발생했습니다',
        variant: 'destructive'
      });
    } finally {
      setCanceling(false);
    }
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-slate-50 to-blue-50 dark:from-slate-950 dark:to-blue-950 flex items-center justify-center">
        <div className="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-blue-600"></div>
      </div>
    );
  }

  const usagePercentage = subscription ? (subscription.usedTokens / subscription.monthlyTokens) * 100 : 0;

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-50 to-blue-50 dark:from-slate-950 dark:to-blue-950 p-4">
      <div className="max-w-6xl mx-auto">
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="mb-8"
        >
          <h1 className="text-3xl font-bold mb-2">구독 관리</h1>
          <p className="text-gray-600 dark:text-gray-400">
            현재 구독 플랜을 확인하고 관리하세요
          </p>
        </motion.div>

        {/* 현재 구독 정보 */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.1 }}
          className="mb-8"
        >
          <Card className="p-6">
            <div className="flex items-center justify-between mb-6">
              <div className="flex items-center gap-3">
                <div className={`p-3 rounded-full ${
                  subscription?.plan === 'premium_plus' ? 'bg-purple-100 dark:bg-purple-900' :
                  subscription?.plan === 'premium' ? 'bg-blue-100 dark:bg-blue-900' :
                  'bg-gray-100 dark:bg-gray-800'
                }`}>
                  <Crown className={`h-6 w-6 ${
                    subscription?.plan === 'premium_plus' ? 'text-purple-600' :
                    subscription?.plan === 'premium' ? 'text-blue-600' :
                    'text-gray-600'
                  }`} />
                </div>
                <div>
                  <h2 className="text-xl font-semibold">
                    {subscription?.plan === 'premium_plus' ? '프리미엄 플러스' :
                     subscription?.plan === 'premium' ? '프리미엄' : '무료'} 플랜
                  </h2>
                  <div className="flex items-center gap-2 mt-1">
                    {subscription?.status === 'active' ? (
                      <Badge className="bg-green-100 text-green-700 dark:bg-green-900 dark:text-green-300">
                        <CheckCircle2 className="h-3 w-3 mr-1" />
                        활성
                      </Badge>
                    ) : subscription?.status === 'canceled' ? (
                      <Badge className="bg-yellow-100 text-yellow-700 dark:bg-yellow-900 dark:text-yellow-300">
                        <AlertCircle className="h-3 w-3 mr-1" />
                        취소 예정
                      </Badge>
                    ) : subscription?.status === 'past_due' ? (
                      <Badge className="bg-red-100 text-red-700 dark:bg-red-900 dark:text-red-300">
                        <XCircle className="h-3 w-3 mr-1" />
                        결제 지연
                      </Badge>
                    ) : null}
                  </div>
                </div>
              </div>
              {subscription?.plan !== 'free' && (
                <div className="text-right">
                  <p className="text-2xl font-bold">
                    ₩{planPrices[subscription?.plan || 'free'].toLocaleString()}
                  </p>
                  <p className="text-sm text-gray-500">월</p>
                </div>
              )}
            </div>

            {/* 토큰 사용량 */}
            <div className="mb-6">
              <div className="flex items-center justify-between mb-2">
                <span className="text-sm font-medium">월간 토큰 사용량</span>
                <span className="text-sm text-gray-600">
                  {subscription?.usedTokens} / {subscription?.monthlyTokens} 토큰
                </span>
              </div>
              <Progress value={usagePercentage} className="h-2" />
              {usagePercentage > 80 && (
                <p className="text-xs text-yellow-600 mt-1">
                  토큰이 얼마 남지 않았습니다. 추가 구매를 고려해보세요.
                </p>
              )}
            </div>

            {/* 구독 정보 */}
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-6">
              {subscription?.nextBillingDate && (
                <div className="flex items-center gap-3">
                  <Calendar className="h-4 w-4 text-gray-400" />
                  <div>
                    <p className="text-sm text-gray-600">다음 결제일</p>
                    <p className="font-medium">
                      {new Date(subscription.nextBillingDate).toLocaleDateString('ko-KR')}
                    </p>
                  </div>
                </div>
              )}
              <div className="flex items-center gap-3">
                <CreditCard className="h-4 w-4 text-gray-400" />
                <div>
                  <p className="text-sm text-gray-600">결제 방법</p>
                  <p className="font-medium">•••• 1234</p>
                </div>
              </div>
            </div>

            {/* 구독 관리 버튼 */}
            <div className="flex gap-3">
              {subscription?.plan === 'free' ? (
                <>
                  <Button 
                    onClick={() => handleUpgrade('premium')}
                    className="flex-1"
                  >
                    <TrendingUp className="h-4 w-4 mr-2" />
                    프리미엄 업그레이드
                  </Button>
                  <Button 
                    onClick={() => handleUpgrade('premium_plus')}
                    variant="outline"
                    className="flex-1"
                  >
                    <Sparkles className="h-4 w-4 mr-2" />
                    프리미엄 플러스로
                  </Button>
                </>
              ) : subscription?.plan === 'premium' ? (
                <>
                  <Button 
                    onClick={() => handleUpgrade('premium_plus')}
                    className="flex-1"
                  >
                    <TrendingUp className="h-4 w-4 mr-2" />
                    프리미엄 플러스로 업그레이드
                  </Button>
                  {!subscription.cancelAtPeriodEnd && (
                    <Button 
                      onClick={handleCancel}
                      variant="outline"
                      disabled={canceling}
                    >
                      구독 취소
                    </Button>
                  )}
                </>
              ) : (
                !subscription?.cancelAtPeriodEnd && (
                  <Button 
                    onClick={handleCancel}
                    variant="outline"
                    disabled={canceling}
                    className="w-full"
                  >
                    구독 취소
                  </Button>
                )
              )}
            </div>

            {subscription?.cancelAtPeriodEnd && (
              <div className="mt-4 p-3 bg-yellow-50 dark:bg-yellow-900/20 rounded-lg">
                <p className="text-sm text-yellow-800 dark:text-yellow-200">
                  구독이 {new Date(subscription.currentPeriodEnd || '').toLocaleDateString('ko-KR')}에 종료됩니다.
                </p>
              </div>
            )}
          </Card>
        </motion.div>

        {/* 플랜 비교 */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.2 }}
        >
          <h2 className="text-2xl font-bold mb-6">플랜 비교</h2>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            {Object.entries(planFeatures).map(([plan, features], index) => (
              <Card 
                key={plan}
                className={`p-6 ${
                  subscription?.plan === plan ? 'ring-2 ring-blue-500' : ''
                }`}
              >
                <div className="mb-4">
                  <h3 className="text-xl font-semibold mb-2">
                    {plan === 'premium_plus' ? '프리미엄 플러스' :
                     plan === 'premium' ? '프리미엄' : '무료'}
                  </h3>
                  <p className="text-2xl font-bold">
                    {planPrices[plan as keyof typeof planPrices] === 0 ? 
                      '무료' : 
                      `₩${planPrices[plan as keyof typeof planPrices].toLocaleString()}/월`
                    }
                  </p>
                </div>
                <ul className="space-y-3 mb-6">
                  {features.map((feature, i) => (
                    <li key={i} className="flex items-start gap-2">
                      <CheckCircle2 className="h-4 w-4 text-green-500 mt-0.5 flex-shrink-0" />
                      <span className="text-sm">{feature}</span>
                    </li>
                  ))}
                </ul>
                {subscription?.plan !== plan && plan !== 'free' && (
                  <Button 
                    onClick={() => handleUpgrade(plan as 'premium' | 'premium_plus')}
                    className="w-full"
                    variant={plan === 'premium_plus' ? 'default' : 'outline'}
                  >
                    {plan === 'premium_plus' && <Star className="h-4 w-4 mr-2" />}
                    선택하기
                  </Button>
                )}
                {subscription?.plan === plan && (
                  <div className="text-center text-sm text-gray-500">
                    현재 플랜
                  </div>
                )}
              </Card>
            ))}
          </div>
        </motion.div>

        {/* 특별 혜택 */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.3 }}
          className="mt-12"
        >
          <Card className="p-6 bg-gradient-to-r from-purple-500 to-blue-500 text-white">
            <div className="flex items-center gap-4">
              <Gift className="h-12 w-12" />
              <div>
                <h3 className="text-xl font-bold mb-1">연간 구독 특별 혜택</h3>
                <p className="text-white/90">
                  연간 구독 시 2개월 무료! 최대 33% 할인된 가격으로 이용하세요.
                </p>
              </div>
              <Button 
                variant="secondary"
                className="ml-auto"
                onClick={() => toast({
                  title: '준비 중',
                  description: '연간 구독은 곧 출시됩니다!'
                })}
              >
                자세히 보기
              </Button>
            </div>
          </Card>
        </motion.div>
      </div>
    </div>
  );
}