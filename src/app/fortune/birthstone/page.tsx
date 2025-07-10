"use client";

import { useToast } from '@/hooks/use-toast';
import { useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { KoreanDatePicker } from "@/components/ui/korean-date-picker";
import AppHeader from "@/components/AppHeader";
import { Gem, ArrowRight } from "lucide-react";

interface BirthstoneInfo {
  stone: string;
  meaning: string;
  luck: string;
  color: string;
}

const birthstones: Record<number, BirthstoneInfo> = {
  1: { stone: "가넷", meaning: "진실한 우정과 충성", luck: "새로운 도전에서 성공을 가져다줍니다", color: "#C0443A" },
  2: { stone: "자수정", meaning: "평화와 지혜", luck: "마음을 안정시키고 통찰력을 높여줍니다", color: "#9248A4" },
  3: { stone: "아쿠아마린", meaning: "용기와 행복", luck: "여행의 안전과 성공을 가져옵니다", color: "#4AB7C8" },
  4: { stone: "다이아몬드", meaning: "순수와 영원", luck: "승리와 부를 상징합니다", color: "#E5E4E2" },
  5: { stone: "에메랄드", meaning: "희망과 행운", luck: "사랑의 성취를 돕습니다", color: "#2FB65B" },
  6: { stone: "진주", meaning: "순결과 건강", luck: "풍요와 장수를 불러옵니다", color: "#F0E5D8" },
  7: { stone: "루비", meaning: "사랑과 열정", luck: "강한 에너지와 용기를 줍니다", color: "#D60039" },
  8: { stone: "페리도트", meaning: "화합과 평화", luck: "부정적인 에너지를 막아줍니다", color: "#A6C93A" },
  9: { stone: "사파이어", meaning: "진실과 신념", luck: "지혜를 높이고 영적 성장을 돕습니다", color: "#2F55A3" },
  10: { stone: "오팔", meaning: "창조성과 영감", luck: "예술적 성공을 가져옵니다", color: "#F2A2E8" },
  11: { stone: "토파즈", meaning: "우정과 건강", luck: "풍요와 행운을 부릅니다", color: "#F5C56E" },
  12: { stone: "터키석", meaning: "행복과 행운", luck: "여행의 안전을 지켜줍니다", color: "#3FB5B8" }
};

const containerVariants = {
  hidden: { opacity: 0 },
  visible: {
    opacity: 1,
    transition: { staggerChildren: 0.1, delayChildren: 0.2 }
  }
};

const itemVariants = {
  hidden: { y: 20, opacity: 0 },
  visible: {
    y: 0,
    opacity: 1,
    transition: { type: "spring" as const, stiffness: 100, damping: 10 }
  }
};

export default function BirthstonePage() {
  const { toast } = useToast();
  const [step, setStep] = useState<'input' | 'result'>('input');
  const [birthDate, setBirthDate] = useState('');
  const [info, setInfo] = useState<BirthstoneInfo | null>(null);

  const handleSubmit = () => {
    if (!birthDate) {
      toast({
      title: '생일을 입력해주세요.',
      variant: "default",
    });
      return;
    }
    const month = new Date(birthDate).getMonth() + 1;
    setInfo(birthstones[month]);
    setStep('result');
  };

  const handleReset = () => {
    setBirthDate('');
    setInfo(null);
    setStep('input');
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-sky-50 via-white to-indigo-50 pb-32">
      <AppHeader title="탄생석" />
      <motion.div variants={containerVariants} initial="hidden" animate="visible" className="px-6 pt-6">
        <AnimatePresence mode="wait">
          {step === 'input' && (
            <motion.div key="input" initial={{ opacity: 0, x: -50 }} animate={{ opacity: 1, x: 0 }} exit={{ opacity: 0, x: 50 }} className="space-y-6">
              <motion.div variants={itemVariants} className="text-center mb-8">
                <motion.div className="bg-gradient-to-r from-sky-400 to-indigo-500 rounded-full w-20 h-20 flex items-center justify-center mx-auto mb-4" whileHover={{ rotate: 360 }} transition={{ duration: 0.8 }}>
                  <Gem className="w-10 h-10 text-white" />
                </motion.div>
                <h1 className="text-2xl font-bold text-gray-900 mb-2">나의 탄생석 찾기</h1>
                <p className="text-gray-600">생일을 입력하면 당신의 탄생석과 의미를 알려드려요</p>
              </motion.div>
              <motion.div variants={itemVariants}>
                <KoreanDatePicker
                  label="생일"
                  value={birthDate}
                  onChange={setBirthDate}
                  placeholder="생년월일을 선택하세요"
                  required
                  className="mb-4"
                />
                <Button onClick={handleSubmit} className="w-full flex gap-2">
                  다음 단계
                  <ArrowRight className="w-4 h-4" />
                </Button>
              </motion.div>
            </motion.div>
          )}

          {step === 'result' && info && (
            <motion.div key="result" initial={{ opacity: 0, x: 50 }} animate={{ opacity: 1, x: 0 }} exit={{ opacity: 0, x: -50 }} className="space-y-6">
              <motion.div variants={itemVariants} className="text-center">
                <motion.div className="rounded-full w-24 h-24 mx-auto mb-4 flex items-center justify-center shadow-lg" style={{ backgroundColor: info.color }} whileHover={{ scale: 1.05 }}>
                  <Gem className="w-12 h-12 text-white" />
                </motion.div>
                <h2 className="text-xl font-bold text-gray-900 mb-2">{info.stone}</h2>
                <p className="text-gray-700 mb-1">{info.meaning}</p>
                <p className="text-sm text-gray-600">{info.luck}</p>
              </motion.div>
              <Button onClick={handleReset} variant="outline" className="w-full">
                다시 입력하기
              </Button>
            </motion.div>
          )}
        </AnimatePresence>
      </motion.div>
    </div>
  );
}
