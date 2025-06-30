"use client";

import { useState, useEffect } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { Card, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Progress } from "@/components/ui/progress";
import { 
  Sparkles, 
  Clock, 
  Star, 
  Zap,
  Eye,
  Gift,
  Crown,
  Loader2
} from "lucide-react";

interface AdLoadingScreenProps {
  fortuneType: string;
  fortuneTitle: string;
  onComplete: () => void;
  onSkip?: () => void;
}

export default function AdLoadingScreen({ 
  fortuneType, 
  fortuneTitle, 
  onComplete, 
  onSkip 
}: AdLoadingScreenProps) {
  const [progress, setProgress] = useState(0);
  const [currentStep, setCurrentStep] = useState(0);
  const [canSkip, setCanSkip] = useState(false);
  const [timeLeft, setTimeLeft] = useState(5);

  const loadingSteps = [
    { icon: Sparkles, text: "운세 데이터를 분석하고 있어요", duration: 1500 },
    { icon: Star, text: "당신만의 특별한 점괘를 찾고 있어요", duration: 1500 },
    { icon: Zap, text: "AI가 운세를 해석하고 있어요", duration: 1500 },
    { icon: Eye, text: "미래의 흐름을 읽고 있어요", duration: 1000 }
  ];

  // 진행률 업데이트
  useEffect(() => {
    const totalDuration = loadingSteps.reduce((sum, step) => sum + step.duration, 0);
    let elapsed = 0;
    
    const timer = setInterval(() => {
      elapsed += 50;
      const newProgress = Math.min((elapsed / totalDuration) * 100, 100);
      setProgress(newProgress);
      
      // 현재 단계 계산
      let accumulatedTime = 0;
      for (let i = 0; i < loadingSteps.length; i++) {
        accumulatedTime += loadingSteps[i].duration;
        if (elapsed <= accumulatedTime) {
          setCurrentStep(i);
          break;
        }
      }
      
      if (elapsed >= totalDuration) {
        clearInterval(timer);
        setCanSkip(true);
      }
    }, 50);

    return () => clearInterval(timer);
  }, []);

  // 스킵 버튼 활성화 타이머
  useEffect(() => {
    const skipTimer = setTimeout(() => {
      setCanSkip(true);
    }, 5000); // 5초 후 스킵 가능

    const countdownTimer = setInterval(() => {
      setTimeLeft(prev => {
        if (prev <= 1) {
          clearInterval(countdownTimer);
          return 0;
        }
        return prev - 1;
      });
    }, 1000);

    return () => {
      clearTimeout(skipTimer);
      clearInterval(countdownTimer);
    };
  }, []);

  const currentStepData = loadingSteps[currentStep];

  return (
    <div className="min-h-screen max-h-screen bg-gradient-to-br from-purple-900 via-indigo-900 to-blue-900 flex flex-col items-center justify-center p-4 relative overflow-hidden">
      {/* 배경 애니메이션 */}
      <div className="absolute inset-0 overflow-hidden">
        {[...Array(20)].map((_, i) => (
          <motion.div
            key={i}
            className="absolute w-2 h-2 bg-white rounded-full opacity-20"
            animate={{
              y: [-100, window.innerHeight + 100],
              x: [Math.random() * window.innerWidth, Math.random() * window.innerWidth],
              opacity: [0, 1, 0]
            }}
            transition={{
              duration: Math.random() * 3 + 2,
              repeat: Infinity,
              delay: Math.random() * 2
            }}
            style={{
              left: Math.random() * 100 + '%',
              top: Math.random() * 100 + '%'
            }}
          />
        ))}
      </div>

      {/* 메인 카드 */}
      <motion.div
        initial={{ scale: 0.8, opacity: 1 }}
        animate={{ scale: 1, opacity: 1 }}
        transition={{ duration: 0.5 }}
        className="w-full max-w-sm sm:max-w-md relative z-10 max-h-[80vh] overflow-y-auto scrollbar-hide"
      >
        <Card className="bg-white/10 backdrop-blur-lg border-white/20 text-white">
          <CardContent className="p-4 sm:p-6 text-center space-y-4 sm:space-y-6">
            {/* 운세 타입 */}
            <div className="space-y-2">
              <motion.div
                animate={{ rotate: 360 }}
                transition={{ duration: 2, repeat: Infinity, ease: "linear" }}
                className="bg-white/20 rounded-full w-12 h-12 sm:w-16 sm:h-16 flex items-center justify-center mx-auto"
              >
                <currentStepData.icon className="w-6 h-6 sm:w-8 sm:h-8" />
              </motion.div>
              <h2 className="text-lg sm:text-xl font-bold">{fortuneTitle}</h2>
              <p className="text-white/80 text-xs sm:text-sm">운세를 분석하고 있습니다</p>
            </div>

            {/* 현재 단계 */}
            <AnimatePresence mode="wait">
              <motion.div
                key={currentStep}
                initial={{ y: 20, opacity: 0 }}
                animate={{ y: 0, opacity: 1 }}
                exit={{ y: -20, opacity: 0 }}
                transition={{ duration: 0.3 }}
                className="space-y-3"
              >
                <p className="text-lg font-medium">{currentStepData.text}</p>
                <div className="flex items-center justify-center gap-2">
                  <Loader2 className="w-4 h-4 animate-spin" />
                  <span className="text-sm text-white/80">잠시만 기다려주세요...</span>
                </div>
              </motion.div>
            </AnimatePresence>

            {/* 진행률 바 */}
            <div className="space-y-2">
              <Progress value={progress} className="h-2 bg-white/20" />
              <p className="text-sm text-white/70">{Math.round(progress)}% 완료</p>
            </div>

            {/* 광고 영역 */}
            <div className="bg-white/5 border border-white/20 rounded-lg p-4 space-y-3">
              <div className="flex items-center justify-center gap-2 text-yellow-300">
                <Gift className="w-4 h-4" />
                <span className="text-sm font-medium">광고를 보고 무료로 이용하세요</span>
              </div>
              
              {/* 실제 광고 영역 - AdSense/AdMob */}
              <div className="bg-gray-800/50 rounded-lg p-3 sm:p-4 min-h-[120px] sm:min-h-[160px] flex items-center justify-center">
                <div className="text-center space-y-1 sm:space-y-2">
                  <div className="text-2xl sm:text-4xl">📱</div>
                  <p className="text-xs sm:text-sm text-white/80">광고 영역</p>
                  <p className="text-xs text-white/60 hidden sm:block">AdSense/AdMob 광고가 여기에 표시됩니다</p>
                </div>
              </div>
            </div>

            {/* 확인 버튼 */}
            <div className="space-y-3">
              {progress >= 100 && (
                <Button
                  onClick={onComplete}
                  className="w-full font-semibold py-3 bg-gradient-to-r from-purple-600 to-indigo-600 hover:from-purple-700 hover:to-indigo-700 text-white"
                >
                  <div className="flex items-center gap-2">
                    <Star className="w-5 h-5" />
                    운세 보기
                  </div>
                </Button>
              )}
             
              {/* 프리미엄 업그레이드 안내 */}
              <div className="bg-gradient-to-r from-yellow-500/20 to-orange-500/20 border border-yellow-500/30 rounded-lg p-3">
                <div className="flex items-center gap-2 justify-center text-yellow-300 mb-2">
                  <Crown className="w-4 h-4" />
                  <span className="text-sm font-medium">프리미엄으로 업그레이드</span>
                </div>
                <p className="text-xs text-yellow-200 text-center">
                  광고 없이 바로 운세를 확인하세요!
                </p>
                {onSkip && (
                  <Button
                    onClick={onSkip}
                    variant="outline"
                    size="sm"
                    className="w-full mt-2 border-yellow-500/50 text-yellow-300 hover:bg-yellow-500/10"
                  >
                    프리미엄 알아보기
                  </Button>
                )}
              </div>
            </div>
          </CardContent>
        </Card>
      </motion.div>

      {/* 하단 정보 */}
      <motion.div
        initial={{ y: 20, opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        transition={{ delay: 0.5 }}
        className="mt-6 text-center text-white/60 text-sm"
      >
        <p>광고를 통해 무료 서비스를 제공하고 있습니다</p>
        <p>이용해 주셔서 감사합니다 ✨</p>
      </motion.div>
    </div>
  );
} 