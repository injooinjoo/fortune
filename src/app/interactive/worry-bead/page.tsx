"use client";

import React, { useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import AppHeader from "@/components/AppHeader";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { Sparkles } from "lucide-react";
import { FortuneCompassIcon } from "@/components/icons/fortune-compass-icon";

const ANSWERS = [
  "네, 좋은 결과가 있을 것입니다.",
  "아니요, 조금 더 시간을 가져보세요.",
  "지금은 결정하기 이르니 상황을 지켜보세요.",
  "긍정적인 마음가짐이 필요합니다.",
  "주변 사람들의 조언을 들어보세요.",
  "당신의 직감을 믿으세요."
];

export default function WorryBeadPage() {
  const [worry, setWorry] = useState("");
  const [step, setStep] = useState<"input" | "thinking" | "answer">("input");
  const [answer, setAnswer] = useState("");

  const askBead = () => {
    if (!worry.trim()) return;
    setStep("thinking");
    setTimeout(() => {
      const random = ANSWERS[Math.floor(Math.random() * ANSWERS.length)];
      setAnswer(random);
      setStep("answer");
    }, 1500);
  };

  const reset = () => {
    setWorry("");
    setStep("input");
  };

  return (
    <>
      <AppHeader title="고민구슬" showBack={false} />
      <div className="min-h-screen flex flex-col items-center justify-center bg-background text-foreground p-4">
        <AnimatePresence mode="wait">
          {step === "input" && (
            <motion.div
              key="input"
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -20 }}
              className="w-full max-w-md space-y-4"
            >
              <Input
                value={worry}
                onChange={(e) => setWorry(e.target.value)}
                placeholder="마음 속 고민을 적어보세요"
                className="text-lg py-6"
              />
              <Button className="w-full" onClick={askBead}>
                구슬에게 물어보기
              </Button>
            </motion.div>
          )}

          {step === "thinking" && (
            <motion.div
              key="thinking"
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              className="flex flex-col items-center space-y-4"
            >
              <FortuneCompassIcon className="h-12 w-12 text-primary animate-spin" />
              <p>고민을 듣는 중...</p>
            </motion.div>
          )}

          {step === "answer" && (
            <motion.div
              key="answer"
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -20 }}
              className="space-y-6 text-center"
            >
              <Sparkles className="w-8 h-8 mx-auto text-purple-600" />
              <p className="text-xl font-semibold">{answer}</p>
              <Button onClick={reset} variant="outline" className="w-full">
                다시 물어보기
              </Button>
            </motion.div>
          )}
        </AnimatePresence>
      </div>
    </>
  );
}
