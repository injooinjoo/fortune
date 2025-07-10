"use client";

import { useToast } from '@/hooks/use-toast';
import { useState, useEffect } from "react";
import { motion, AnimatePresence } from "framer-motion";
import AppHeader from "@/components/AppHeader";
import { isPremiumUser } from "@/lib/user-storage";
import { useUserProfile, hasUserBirthDate } from "@/hooks/use-user-profile";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { KoreanDatePicker } from "@/components/ui/korean-date-picker";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Cake, CheckCircle } from "lucide-react";
import AdLoadingScreen from "@/components/AdLoadingScreen";

interface BirthdateFortune {
  lifePath: number;
  personality: string;
  talent: string;
  fortune: string;
}

const LIFE_PATH_INFO: Record<number, { personality: string; talent: string; fortune: string }> = {
  1: {
    personality: "주도적이고 자신감 넘치는 성격입니다.",
    talent: "리더십과 개척 정신이 돋보입니다.",
    fortune: "도전적인 시도에서 행운을 얻습니다."
  },
  2: {
    personality: "배려심이 깊고 협력적인 성향입니다.",
    talent: "조율 능력이 뛰어나 팀에서 빛납니다.",
    fortune: "주변과 조화를 이룰 때 운이 상승합니다."
  },
  3: {
    personality: "낙천적이며 표현력이 풍부합니다.",
    talent: "예술적 감각과 사교성이 강점입니다.",
    fortune: "즐겁게 행동할수록 좋은 기회가 찾아옵니다."
  },
  4: {
    personality: "성실하고 책임감이 강한 편입니다.",
    talent: "체계적인 계획 수립에 능합니다.",
    fortune: "꾸준함을 유지하면 안정된 결과를 얻습니다."
  },
  5: {
    personality: "변화를 즐기고 모험심이 강합니다.",
    talent: "다양한 경험을 통해 통찰을 얻습니다.",
    fortune: "새로운 환경에서 행운을 만납니다."
  },
  6: {
    personality: "온화하고 책임감 있는 성향입니다.",
    talent: "타인을 돌보고 조화롭게 이끄는 힘이 있습니다.",
    fortune: "사람들과의 유대 속에서 복이 들어옵니다."
  },
  7: {
    personality: "사색적이고 탐구심이 많습니다.",
    talent: "분석력과 직관이 뛰어납니다.",
    fortune: "집중하여 연구할 때 좋은 성과가 있습니다."
  },
  8: {
    personality: "실용적이고 목표 지향적인 성격입니다.",
    talent: "조직 관리와 재무 감각이 우수합니다.",
    fortune: "현실적인 목표 설정이 큰 성공을 부릅니다."
  },
  9: {
    personality: "포용력이 크고 이상주의적입니다.",
    talent: "봉사 정신과 창의성이 장점입니다.",
    fortune: "타인을 돕는 일에서 행운이 따릅니다."
  }
};

function getLifePathNumber(date: string): number {
  const digits = date.replace(/-/g, "").split("").map(Number);
  let sum = digits.reduce((a, b) => a + b, 0);
  while (sum > 9) {
    sum = sum.toString().split("").reduce((a, b) => a + Number(b), 0);
  }
  return sum === 0 ? 9 : sum;
}

function analyzeBirthdate(date: string): BirthdateFortune {
  const lifePath = getLifePathNumber(date);
  const info = LIFE_PATH_INFO[lifePath];
  return { lifePath, ...info };
}

export default function BirthdateFortunePage() {
  const { toast } = useToast();
  const [step, setStep] = useState<'input' | 'loading' | 'result'>('input');
  const [birthDate, setBirthDate] = useState('');
  const [result, setResult] = useState<BirthdateFortune | null>(null);
  
  // 사용자 프로필 훅 사용
  const { profile, isLoading: profileLoading } = useUserProfile();

  // 프로필 데이터로 생년월일 초기화
  useEffect(() => {
    if (!profileLoading && profile && hasUserBirthDate(profile)) {
      setBirthDate(profile.birth_date!);
    }
  }, [profile, profileLoading]);

  const handleSubmit = () => {
    if (!birthDate) {
      toast({
      title: '생년월일을 입력해주세요.',
      variant: "default",
    });
      return;
    }

    const isPremium = isPremiumUser(profile);
    
    if (isPremium) {
      // 프리미엄 사용자는 바로 결과 표시
      const analysis = analyzeBirthdate(birthDate);
      setResult(analysis);
      setStep('result');
    } else {
      // 일반 사용자는 광고 로딩 화면 표시
      setStep('loading');
    }
  };

  // 광고 로딩 완료 후 결과 표시
  const handleAdComplete = () => {
    // 결과 분석 및 상태 변경을 동시에 처리하여 중간 단계가 보이지 않도록 함
    const analysis = analyzeBirthdate(birthDate);
    setResult(analysis);
    setStep('result');
  };

  // 프리미엄 업그레이드 페이지로 이동
  const handleUpgradeToPremium = () => {
    window.location.href = '/membership';
  };

  const handleReset = () => {
    setBirthDate('');
    setResult(null);
    setStep('input');
  };

  const containerVariants = {
    hidden: { opacity: 0 },
    visible: { opacity: 1, transition: { staggerChildren: 0.1 } }
  };
  const itemVariants = {
    hidden: { y: 20, opacity: 0 },
    visible: { y: 0, opacity: 1, transition: { type: 'spring', stiffness: 100 } }
  };

  // 광고 로딩 화면 표시
  if (step === 'loading') {
    return (
      <AdLoadingScreen
        fortuneType="birthdate"
        fortuneTitle="생년월일 운세"
        onComplete={handleAdComplete}
        onSkip={handleUpgradeToPremium}
      />
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-cyan-50 via-blue-50 to-indigo-50 pb-32">
      <AppHeader title="생년월일 운세" />
      <motion.div
        variants={containerVariants}
        initial="hidden"
        animate="visible"
        className="px-6 pt-6"
      >
        <AnimatePresence mode="wait">
          {step === 'input' && (
            <motion.div
              key="input"
              initial={{ opacity: 0, x: -50 }}
              animate={{ opacity: 1, x: 0 }}
              exit={{ opacity: 0, x: 50 }}
              className="space-y-6"
            >
              <motion.div variants={itemVariants} className="text-center mb-8">
                <motion.div
                  className="bg-gradient-to-r from-cyan-500 to-blue-500 rounded-full w-20 h-20 flex items-center justify-center mx-auto mb-4"
                  whileHover={{ rotate: 360 }}
                  transition={{ duration: 0.8 }}
                >
                  <Cake className="w-10 h-10 text-white" />
                </motion.div>
                <h1 className="text-2xl font-bold text-gray-900 mb-2">생년월일 운세</h1>
                <p className="text-gray-600">태어난 날짜로 보는 간단 운세입니다</p>
              </motion.div>

              <motion.div variants={itemVariants}>
                <Card className="border-cyan-200">
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2 text-cyan-700">
                      <Cake className="w-5 h-5" />
                      기본 정보 입력
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div>
                      <KoreanDatePicker
                        value={birthDate}
                        onChange={(date) => setBirthDate(date)}
                        label="생년월일"
                        placeholder="생년월일을 선택하세요"
                        required={true}
                      />
                    </div>
                    <div className="text-right">
                      <Button onClick={handleSubmit}>분석하기</Button>
                    </div>
                  </CardContent>
                </Card>
              </motion.div>
            </motion.div>
          )}

          {step === 'result' && result && (
            <motion.div
              key="result"
              initial={{ opacity: 0, x: 50 }}
              animate={{ opacity: 1, x: 0 }}
              exit={{ opacity: 0, x: -50 }}
              className="space-y-6"
            >
              <motion.div variants={itemVariants}>
                <Card className="border-cyan-200 bg-gradient-to-r from-cyan-50 to-blue-50">
                  <CardHeader className="text-center">
                    <CardTitle className="text-cyan-700 flex items-center justify-center gap-2">
                      <Cake className="w-5 h-5" />
                      라이프 패스 넘버 {result.lifePath}
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div>
                      <h3 className="font-semibold text-gray-900 mb-1">성격</h3>
                      <p className="text-sm text-gray-600">{result.personality}</p>
                    </div>
                    <div>
                      <h3 className="font-semibold text-gray-900 mb-1">재능</h3>
                      <p className="text-sm text-gray-600">{result.talent}</p>
                    </div>
                    <div>
                      <h3 className="font-semibold text-gray-900 mb-1">운의 특징</h3>
                      <p className="text-sm text-gray-600">{result.fortune}</p>
                    </div>
                  </CardContent>
                </Card>
              </motion.div>
              <motion.div variants={itemVariants} className="flex justify-between">
                <Button variant="outline" onClick={handleReset} className="flex-1 mr-2">
                  다시 입력
                </Button>
                <Button onClick={() => window.scrollTo({ top: 0, behavior: 'smooth' })} className="flex-1 ml-2">
                  맨 위로
                </Button>
              </motion.div>
            </motion.div>
          )}
        </AnimatePresence>
      </motion.div>
    </div>
  );
}

