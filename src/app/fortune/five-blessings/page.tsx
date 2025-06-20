"use client";

import { useState } from "react";
import { motion } from "framer-motion";
import AppHeader from "@/components/AppHeader";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Progress } from "@/components/ui/progress";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import {
  Sparkles,
  Coins,
  Users,
  HeartPulse,
  SunIcon,
  Gem
} from "lucide-react";

interface Blessing {
  id: string;
  name: string;
  score: number;
  description: string;
  tips: string[];
  icon: React.ComponentType<{ className?: string }>;
  color: string;
}

const blessings: Blessing[] = [
  {
    id: "wealth",
    name: "재물복",
    score: 90,
    description: "재물을 모으고 관리하는 능력이 뛰어납니다.",
    tips: ["소득 일부를 꾸준히 저축", "장기적 재테크 계획", "나눔 실천"],
    icon: Coins,
    color: "yellow"
  },
  {
    id: "people",
    name: "인복",
    score: 85,
    description: "주변에 좋은 인연이 많아 협력이 쉽습니다.",
    tips: ["감사 표현 자주 하기", "상대 칭찬 아끼지 않기", "윈윈 관계 유지"],
    icon: Users,
    color: "emerald"
  },
  {
    id: "health",
    name: "건강복",
    score: 80,
    description: "타고난 체력과 회복력을 지녔습니다.",
    tips: ["규칙적 운동", "균형 잡힌 식단", "정기 검진"],
    icon: HeartPulse,
    color: "red"
  },
  {
    id: "longevity",
    name: "장수복",
    score: 75,
    description: "오래도록 활기찬 삶을 이어갈 가능성이 높습니다.",
    tips: ["긍정적 마음가짐", "스트레스 관리", "취미 생활 즐기기"],
    icon: SunIcon,
    color: "purple"
  },
  {
    id: "virtue",
    name: "덕망복",
    score: 88,
    description: "베푸는 마음이 커 주변의 존경을 받습니다.",
    tips: ["작은 선행도 꾸준히", "공동체 활동 참여", "겸손한 태도"],
    icon: Gem,
    color: "blue"
  }
];

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

export default function FiveBlessingsPage() {
  const [fontSize, setFontSize] = useState<'small' | 'medium' | 'large'>('medium');
  const totalScore = Math.round(
    blessings.reduce((sum, b) => sum + b.score, 0) / blessings.length
  );

  return (
    <>
      <AppHeader
        title="천생복덕운"
        onFontSizeChange={setFontSize}
        currentFontSize={fontSize}
      />
      <motion.div
        className="pb-32 px-4 space-y-6 pt-4"
        initial="hidden"
        animate="visible"
        variants={containerVariants}
      >
        {/* 요약 섹션 */}
        <motion.div variants={itemVariants}>
          <Card className="bg-gradient-to-br from-teal-50 to-emerald-50 border-teal-200">
            <CardHeader className="text-center">
              <div className="flex items-center justify-center gap-2">
                <Sparkles className="w-6 h-6 text-teal-600" />
                <CardTitle className="text-teal-800">천생복덕 운세</CardTitle>
              </div>
            </CardHeader>
            <CardContent className="text-center space-y-2">
              <div className="text-4xl font-bold text-teal-600">{totalScore}점</div>
              <Progress value={totalScore} className="mb-2" />
              <p className="text-sm text-muted-foreground">
                타고난 오복의 조화가 좋은 편입니다. 긍정적인 마음으로 복을 누려보세요.
              </p>
            </CardContent>
          </Card>
        </motion.div>

        {/* 상세 복 분석 */}
        <motion.div variants={itemVariants} className="space-y-4">
          {blessings.map((b) => {
            const Icon = b.icon;
            return (
              <Card key={b.id} className="border-gray-200 bg-gradient-to-r from-white to-gray-50">
                <CardHeader>
                  <CardTitle className="flex items-center gap-2">
                    <Icon className={`w-5 h-5 text-${b.color}-600`} />
                    {b.name}
                    <Badge className={`ml-2 bg-${b.color}-100 text-${b.color}-700`}>{b.score}점</Badge>
                  </CardTitle>
                </CardHeader>
                <CardContent>
                  <Progress value={b.score} className="mb-2" />
                  <p className="text-sm text-muted-foreground mb-2">{b.description}</p>
                  <ul className="list-disc pl-5 space-y-1 text-sm text-muted-foreground">
                    {b.tips.map((tip, idx) => (
                      <li key={idx}>{tip}</li>
                    ))}
                  </ul>
                </CardContent>
              </Card>
            );
          })}
        </motion.div>

        {/* 하단 버튼 */}
        <div className="sticky bottom-16 left-0 right-0 bg-background border-t p-4 flex gap-2">
          <Button className="flex-1">결과 저장하기</Button>
          <Button variant="outline" className="flex-1">
            공유하기
          </Button>
        </div>
      </motion.div>
    </>
  );
}
