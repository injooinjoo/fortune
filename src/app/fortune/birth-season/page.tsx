"use client";

import { useState } from "react";
import Image from "next/image";
import { motion } from "framer-motion";
import AppHeader from "@/components/AppHeader";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Leaf, Sun, Wind, RefreshCw } from "lucide-react";

const SEASONS = {
  spring: {
    name: "봄", 
    image: "https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?auto=format&fit=crop&w=600&q=60",
    personality: "따뜻하고 낙천적인 성격으로 새로운 시작을 즐깁니다. 창의력과 적응력이 뛰어난 편입니다.",
    fortune: "성장과 발전의 기운이 강해 도전하는 일마다 좋은 결실을 맺을 확률이 높습니다."
  },
  summer: {
    name: "여름",
    image: "https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=600&q=60",
    personality: "열정적이고 활력이 넘쳐 주변을 이끄는 리더십을 갖추고 있습니다.",
    fortune: "성공과 활약의 운세가 높아 목표를 향해 힘차게 나아갈 때 큰 성취를 얻습니다."
  },
  autumn: {
    name: "가을",
    image: "https://images.unsplash.com/photo-1476041800959-2f3e8a7cf5fa?auto=format&fit=crop&w=600&q=60",
    personality: "침착하고 균형 감각이 뛰어나 분석적 사고를 잘 합니다.",
    fortune: "수확의 시기로 그동안 노력해온 일에서 안정적인 결과를 얻을 수 있습니다."
  },
  winter: {
    name: "겨울",
    image: "https://images.unsplash.com/photo-1482192596544-9eb780fc7f66?auto=format&fit=crop&w=600&q=60",
    personality: "인내심이 강하고 내면의 힘이 단단해 어려움 속에서도 쉽게 흔들리지 않습니다.",
    fortune: "준비와 축적의 운이 좋으니 차분하게 계획을 세우면 다음 기회를 확실히 잡을 수 있습니다."
  }
} as const;

type SeasonKey = keyof typeof SEASONS;

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
    transition: { type: "spring", stiffness: 100, damping: 15 }
  }
};

export default function BirthSeasonPage() {
  const [season, setSeason] = useState<SeasonKey | null>(null);
  const [fontSize, setFontSize] = useState<'small' | 'medium' | 'large'>('medium');

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 via-white to-purple-50">
      <AppHeader
        title="태어난 계절운"
        onFontSizeChange={setFontSize}
        currentFontSize={fontSize}
      />
      <motion.div
        className="container mx-auto px-4 pt-4 pb-20"
        variants={containerVariants}
        initial="hidden"
        animate="visible"
      >
        {!season && (
          <motion.div variants={itemVariants}>
            <Card>
              <CardHeader>
                <CardTitle className="text-center flex items-center justify-center gap-2">
                  <Leaf className="w-5 h-5 text-green-600" />
                  태어난 계절을 선택하세요
                </CardTitle>
              </CardHeader>
              <CardContent>
                <div className="grid grid-cols-2 gap-4">
                  {(Object.keys(SEASONS) as SeasonKey[]).map((key) => (
                    <motion.button
                      key={key}
                      whileHover={{ scale: 1.05 }}
                      whileTap={{ scale: 0.95 }}
                      onClick={() => setSeason(key)}
                      className="relative group rounded-lg overflow-hidden"
                    >
                      <Image
                        src={SEASONS[key].image}
                        alt={SEASONS[key].name}
                        width={300}
                        height={200}
                        className="object-cover w-full h-32"
                      />
                      <div className="absolute inset-0 bg-black/30 opacity-0 group-hover:opacity-100 transition" />
                      <span className="absolute bottom-2 left-2 text-white font-bold drop-shadow">
                        {SEASONS[key].name}
                      </span>
                    </motion.button>
                  ))}
                </div>
              </CardContent>
            </Card>
          </motion.div>
        )}

        {season && (
          <>
            <motion.div variants={itemVariants} className="mb-4">
              <div className="relative h-40 w-full rounded-lg overflow-hidden">
                <Image src={SEASONS[season].image} alt={SEASONS[season].name} fill className="object-cover" />
                <div className="absolute inset-0 bg-black/40 flex items-center justify-center">
                  <h2 className="text-2xl font-bold text-white">{SEASONS[season].name} 태생</h2>
                </div>
              </div>
            </motion.div>

            <motion.div variants={itemVariants} className="mb-4">
              <Card>
                <CardHeader>
                  <CardTitle className="flex items-center gap-2 text-indigo-700">
                    <Sun className="w-5 h-5" /> 성격 특징
                  </CardTitle>
                </CardHeader>
                <CardContent>
                  <p className="text-sm text-gray-700 leading-relaxed">
                    {SEASONS[season].personality}
                  </p>
                </CardContent>
              </Card>
            </motion.div>

            <motion.div variants={itemVariants}>
              <Card>
                <CardHeader>
                  <CardTitle className="flex items-center gap-2 text-purple-700">
                    <Wind className="w-5 h-5" /> 운세 포인트
                  </CardTitle>
                </CardHeader>
                <CardContent>
                  <p className="text-sm text-gray-700 leading-relaxed">
                    {SEASONS[season].fortune}
                  </p>
                </CardContent>
              </Card>
            </motion.div>

            <motion.div variants={itemVariants} className="mt-6 text-center">
              <Button variant="outline" onClick={() => setSeason(null)} className="flex items-center gap-1">
                <RefreshCw className="w-4 h-4" /> 다른 계절 선택하기
              </Button>
            </motion.div>
          </>
        )}
      </motion.div>
    </div>
  );
}

