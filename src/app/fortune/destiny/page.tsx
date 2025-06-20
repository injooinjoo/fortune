"use client";

import React, { useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { Card, CardHeader, CardTitle, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Progress } from "@/components/ui/progress";
import AppHeader from "@/components/AppHeader";
import {
  Sparkles,
  TrendingUp,
  Calendar,
  MapPin,
  User,
  MessageCircle,
  Heart,
  Users,
  Star
} from "lucide-react";

interface DestinyFortuneData {
  destinyScore: number;
  summary: string;
  advice: string;
  meetingPeriod: string;
  meetingPlace: string;
  partnerTraits: string[];
  developmentChance: string;
  predictions: {
    firstMeeting: string;
    relationship: string;
    longTerm: string;
  };
  actionItems: string[];
}

const mockDestinyData: DestinyFortuneData = {
  destinyScore: 82,
  summary:
    "다가오는 몇 달 안에 특별한 인연을 만날 가능성이 높습니다. 현재의 노력이 좋은 결과로 이어질 것입니다.",
  advice:
    "새로운 만남에 열린 마음을 유지하고, 사람들과의 교류를 즐기는 것이 좋습니다.",
  meetingPeriod: "3~4개월 내",
  meetingPlace: "지인 모임, 취미 활동 장소",
  partnerTraits: ["밝은 에너지", "배려심", "유머 감각"],
  developmentChance: "친구에서 연인으로 발전할 확률이 높습니다.",
  predictions: {
    firstMeeting: "가까운 미래에 지인을 통해 소개받을 가능성이 있습니다.",
    relationship: "서로의 관심사가 잘 맞아 빠르게 가까워질 수 있습니다.",
    longTerm: "신뢰를 쌓아가면 오래 지속되는 관계로 발전합니다."
  },
  actionItems: [
    "친구의 초대를 가능한 한 수락하기",
    "새로운 취미 모임에 참여하기",
    "긍정적인 이미지를 유지하기"
  ]
};

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

export default function DestinyFortunePage() {
  const [data] = useState<DestinyFortuneData>(mockDestinyData);
  const [selectedStep, setSelectedStep] = useState<
    'firstMeeting' | 'relationship' | 'longTerm'
  >('firstMeeting');
  const [fontSize, setFontSize] = useState<'small' | 'medium' | 'large'>('medium');

  return (
    <>
      <AppHeader
        title="나의 인연 운세"
        onFontSizeChange={setFontSize}
        currentFontSize={fontSize}
      />
      <motion.div
        className="pb-32 px-4 space-y-6 pt-4"
        initial="hidden"
        animate="visible"
        variants={containerVariants}
      >
        <motion.div variants={itemVariants}>
          <Card className="bg-gradient-to-br from-fuchsia-50 to-rose-50 border-fuchsia-200">
            <CardHeader className="text-center">
              <div className="flex items-center justify-center gap-2 mb-2">
                <Sparkles className="w-6 h-6 text-fuchsia-600" />
                <CardTitle className="text-xl text-fuchsia-800">오늘의 인연 운</CardTitle>
              </div>
              <motion.div
                className="text-4xl font-bold text-fuchsia-600"
                initial={{ scale: 0 }}
                animate={{ scale: 1 }}
                transition={{ delay: 0.5, type: 'spring', stiffness: 200 }}
              >
                {data.destinyScore}점
              </motion.div>
            </CardHeader>
            <CardContent>
              <Progress value={data.destinyScore} className="mb-4" />
              <p className="text-center text-fuchsia-700 leading-relaxed">
                {data.summary}
              </p>
            </CardContent>
          </Card>
        </motion.div>

        <motion.div variants={itemVariants}>
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <TrendingUp className="w-5 h-5" />
                만남 시기와 장소
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="grid grid-cols-2 gap-4">
                <div className="flex items-center gap-3">
                  <Calendar className="w-5 h-5 text-blue-600" />
                  <div>
                    <div className="text-sm text-gray-600">예상 시기</div>
                    <div className="font-medium">{data.meetingPeriod}</div>
                  </div>
                </div>
                <div className="flex items-center gap-3">
                  <MapPin className="w-5 h-5 text-green-600" />
                  <div>
                    <div className="text-sm text-gray-600">주요 장소</div>
                    <div className="font-medium">{data.meetingPlace}</div>
                  </div>
                </div>
              </div>
            </CardContent>
          </Card>
        </motion.div>

        <motion.div variants={itemVariants}>
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <Users className="w-5 h-5" />
                예상되는 상대 특징
              </CardTitle>
            </CardHeader>
            <CardContent className="flex flex-wrap gap-2">
              {data.partnerTraits.map((trait) => (
                <Badge
                  key={trait}
                  variant="secondary"
                  className="bg-fuchsia-100 text-fuchsia-700"
                >
                  {trait}
                </Badge>
              ))}
            </CardContent>
          </Card>
        </motion.div>

        <motion.div variants={itemVariants}>
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <Star className="w-5 h-5" />
                관계 발전 가능성
              </CardTitle>
            </CardHeader>
            <CardContent>
              <p className="text-sm text-gray-700 leading-relaxed mb-2">
                {data.developmentChance}
              </p>
              <div className="flex gap-2 mb-4">
                {[
                  { key: 'firstMeeting', label: '첫 만남' },
                  { key: 'relationship', label: '연애 진행' },
                  { key: 'longTerm', label: '장기 전망' }
                ].map((step) => (
                  <Button
                    key={step.key}
                    variant={selectedStep === step.key ? 'default' : 'outline'}
                    size="sm"
                    onClick={() => setSelectedStep(step.key as any)}
                  >
                    {step.label}
                  </Button>
                ))}
              </div>
              <AnimatePresence mode="wait">
                <motion.div
                  key={selectedStep}
                  initial={{ opacity: 0, y: 10 }}
                  animate={{ opacity: 1, y: 0 }}
                  exit={{ opacity: 0, y: -10 }}
                  transition={{ duration: 0.2 }}
                  className="text-sm text-gray-700 leading-relaxed"
                >
                  {data.predictions[selectedStep]}
                </motion.div>
              </AnimatePresence>
            </CardContent>
          </Card>
        </motion.div>

        <motion.div variants={itemVariants}>
          <Card className="bg-gradient-to-br from-purple-50 to-fuchsia-50 border-purple-200">
            <CardHeader>
              <CardTitle className="flex items-center gap-2 text-purple-800">
                <MessageCircle className="w-5 h-5" />
                오늘의 조언
              </CardTitle>
            </CardHeader>
            <CardContent>
              <p className="text-purple-700 leading-relaxed">
                {data.advice}
              </p>
            </CardContent>
          </Card>
        </motion.div>

        <motion.div variants={itemVariants}>
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <Heart className="w-5 h-5" />
                실천 가이드
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-3">
                {data.actionItems.map((item, index) => (
                  <motion.div
                    key={index}
                    className="flex items-center gap-3 p-3 bg-gray-50 rounded-lg"
                    initial={{ opacity: 0, x: -20 }}
                    animate={{ opacity: 1, x: 0 }}
                    transition={{ delay: 0.8 + index * 0.1 }}
                  >
                    <div className="w-6 h-6 bg-fuchsia-100 rounded-full flex items-center justify-center">
                      <span className="text-xs font-medium text-fuchsia-600">
                        {index + 1}
                      </span>
                    </div>
                    <span className="text-sm text-gray-700">{item}</span>
                  </motion.div>
                ))}
              </div>
            </CardContent>
          </Card>
        </motion.div>

        <motion.div
          variants={itemVariants}
          className="sticky bottom-16 left-0 right-0 bg-background border-t p-4 flex gap-2"
        >
          <Button className="flex-1 bg-fuchsia-600 hover:bg-fuchsia-700">
            결과 저장하기
          </Button>
          <Button variant="outline" className="flex-1 border-fuchsia-300 text-fuchsia-600 hover:bg-fuchsia-50">
            공유하기
          </Button>
        </motion.div>
      </motion.div>
    </>
  );
}

