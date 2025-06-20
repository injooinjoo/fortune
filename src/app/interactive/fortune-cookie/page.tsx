"use client";

import { useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { Button } from "@/components/ui/button";
import { Card, CardHeader, CardTitle, CardContent } from "@/components/ui/card";
import AppHeader from "@/components/AppHeader";

const fortunes = [
  "오늘은 멋진 일이 생길 거예요!",
  "작은 친절이 큰 행운을 부릅니다.",
  "새로운 시도가 좋은 결과로 이어집니다.",
  "웃음이 복을 가져다줍니다.",
  "당신의 노력에 보상이 따를 거예요.",
  "행운은 준비된 자에게 미소 짓습니다.",
  "뜻밖의 기회가 찾아옵니다.",
  "긍정적인 마음이 하루를 밝게 만듭니다.",
  "주변 사람들과의 협력이 중요합니다.",
  "지금 떠오른 그 아이디어를 실천해 보세요.",
];

export default function FortuneCookiePage() {
  const [opened, setOpened] = useState(false);
  const [message, setMessage] = useState("");

  const breakCookie = () => {
    const random = fortunes[Math.floor(Math.random() * fortunes.length)];
    setMessage(random);
    setOpened(true);
  };

  const reset = () => {
    setOpened(false);
    setMessage("");
  };

  return (
    <>
      <AppHeader title="포춘쿠키" />
      <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-amber-50 via-yellow-50 to-orange-100 p-4">
        <AnimatePresence mode="wait">
          {!opened ? (
            <motion.button
              key="cookie"
              initial={{ scale: 0, rotate: -15, opacity: 0 }}
              animate={{ scale: 1, rotate: 0, opacity: 1 }}
              exit={{ scale: 0, rotate: 15, opacity: 0 }}
              transition={{ type: "spring", stiffness: 200 }}
              onClick={breakCookie}
              className="focus:outline-none text-8xl"
              aria-label="포춘쿠키 깨기"
            >
              🥠
            </motion.button>
          ) : (
            <motion.div
              key="result"
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -20 }}
              transition={{ duration: 0.4 }}
              className="w-full max-w-sm"
            >
              <Card className="text-center bg-white/90 backdrop-blur-md">
                <CardHeader>
                  <CardTitle>오늘의 행운</CardTitle>
                </CardHeader>
                <CardContent className="space-y-4">
                  <motion.div
                    initial={{ rotate: -20, scale: 0 }}
                    animate={{ rotate: 0, scale: 1 }}
                    transition={{ type: "spring", stiffness: 200 }}
                    className="text-7xl"
                  >
                    🥠
                  </motion.div>
                  <p className="text-lg font-medium text-gray-800">{message}</p>
                  <Button onClick={reset} className="w-full">
                    다른 쿠키 열기
                  </Button>
                </CardContent>
              </Card>
            </motion.div>
          )}
        </AnimatePresence>
      </div>
    </>
  );
}
