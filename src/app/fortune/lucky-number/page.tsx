"use client";

import { useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import AppHeader from "@/components/AppHeader";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { KoreanDatePicker } from "@/components/ui/korean-date-picker";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Dice5, Calendar, Sparkles } from "lucide-react";

const containerVariants = {
  hidden: { opacity: 0 },
  visible: {
    opacity: 1,
    transition: {
      staggerChildren: 0.1,
      delayChildren: 0.2,
    },
  },
};

const itemVariants = {
  hidden: { y: 20, opacity: 0 },
  visible: {
    y: 0,
    opacity: 1,
    transition: {
      type: "spring" as const,
      stiffness: 100,
      damping: 10,
    },
  },
};

function generateLuckyNumbers(birthDate: string): number[] {
  const sanitized = birthDate.replace(/-/g, "");
  let seed = parseInt(sanitized, 10) +
    new Date().getFullYear() * 10000 +
    (new Date().getMonth() + 1) * 100 +
    new Date().getDate();
  const rand = () => {
    seed = (seed * 9301 + 49297) % 233280;
    return seed / 233280;
  };
  const nums = new Set<number>();
  while (nums.size < 6) {
    nums.add(Math.floor(rand() * 45) + 1);
  }
  return Array.from(nums).sort((a, b) => a - b);
}

export default function LuckyNumberPage() {
  const [step, setStep] = useState<'input' | 'result'>('input');
  const [birth, setBirth] = useState('');
  const [numbers, setNumbers] = useState<number[]>([]);

  const handleGenerate = () => {
    if (!birth) return;
    setNumbers(generateLuckyNumbers(birth));
    setStep('result');
  };

  const handleRetry = () => {
    setNumbers(generateLuckyNumbers(birth));
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 via-white to-indigo-50 pb-20">
      <AppHeader title="행운의 번호" />
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
              <motion.div variants={itemVariants} className="text-center mb-6">
                <motion.div
                  className="bg-gradient-to-r from-indigo-500 to-purple-500 rounded-full w-20 h-20 flex items-center justify-center mx-auto mb-4"
                  whileHover={{ rotate: 360 }}
                  transition={{ duration: 0.8 }}
                >
                  <Dice5 className="w-10 h-10 text-white" />
                </motion.div>
                <h1 className="text-2xl font-bold text-gray-900 dark:text-gray-100 mb-2">나만의 행운 번호</h1>
                <p className="text-gray-600 dark:text-gray-400">생년월일을 입력하고 오늘의 번호 6개를 확인하세요</p>
              </motion.div>
              <motion.div variants={itemVariants}>
                <Card className="border-indigo-200">
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2 text-indigo-700">
                      <Calendar className="w-5 h-5" /> 생년월일
                    </CardTitle>
                  </CardHeader>
                  <CardContent>
                    <KoreanDatePicker
                      value={birth}
                      onChange={(date) => setBirth(date)}
                      placeholder="생년월일을 선택하세요"
                      required={true}
                    />
                  </CardContent>
                </Card>
              </motion.div>
              <motion.div variants={itemVariants} className="text-center pt-4">
                <Button onClick={handleGenerate} className="px-8">번호 생성하기</Button>
              </motion.div>
            </motion.div>
          )}
          {step === 'result' && (
            <motion.div
              key="result"
              initial={{ opacity: 0, x: -50 }}
              animate={{ opacity: 1, x: 0 }}
              exit={{ opacity: 0, x: 50 }}
              className="space-y-6"
            >
              <motion.div variants={itemVariants} className="text-center mb-6">
                <motion.div
                  className="bg-gradient-to-r from-indigo-500 to-purple-500 rounded-full w-20 h-20 flex items-center justify-center mx-auto mb-4"
                  animate={{ rotate: [0, 360] }}
                  transition={{ duration: 10, repeat: Infinity, ease: 'linear' }}
                >
                  <Sparkles className="w-10 h-10 text-white" />
                </motion.div>
                <h2 className="text-xl font-bold text-gray-900 dark:text-gray-100 mb-4">오늘의 행운 번호</h2>
                <div className="flex justify-center gap-3">
                  {numbers.map((n, idx) => (
                    <motion.div
                      key={n}
                      initial={{ scale: 0 }}
                      animate={{ scale: 1 }}
                      transition={{ delay: 0.2 * idx }}
                      className="bg-white border border-indigo-200 rounded-full w-12 h-12 flex items-center justify-center text-lg font-semibold text-indigo-700 shadow"
                    >
                      {n}
                    </motion.div>
                  ))}
                </div>
              </motion.div>
              <motion.div variants={itemVariants} className="flex justify-center gap-4">
                <Button variant="outline" onClick={() => setStep('input')}>다시 입력</Button>
                <Button onClick={handleRetry}>다시 뽑기</Button>
              </motion.div>
            </motion.div>
          )}
        </AnimatePresence>
      </motion.div>
    </div>
  );
}
