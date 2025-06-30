"use client";

import React, { useState, useEffect } from "react";
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
  Star,
  Loader2
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
  const [data, setData] = useState<DestinyFortuneData | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [selectedStep, setSelectedStep] = useState<
    'firstMeeting' | 'relationship' | 'longTerm'
  >('firstMeeting');
  const [fontSize, setFontSize] = useState<'small' | 'medium' | 'large'>('medium');

  // API에서 인연운 데이터 가져오기
  useEffect(() => {
    const fetchDestinyData = async () => {
      try {
        setLoading(true);
        const response = await fetch('/api/fortune/destiny');
        
        if (!response.ok) {
          throw new Error('인연운 데이터를 가져오는데 실패했습니다');
        }
        
        const result = await response.json();
        
        if (result.success && result.data?.destiny) {
          const destinyData = result.data.destiny;
          setData({
            destinyScore: destinyData.destiny_score,
            summary: destinyData.summary,
            advice: destinyData.advice,
            meetingPeriod: destinyData.meeting_period,
            meetingPlace: destinyData.meeting_place,
            partnerTraits: destinyData.partner_traits,
            developmentChance: destinyData.development_chance,
            predictions: {
              firstMeeting: destinyData.predictions.first_meeting,
              relationship: destinyData.predictions.relationship,
              longTerm: destinyData.predictions.long_term
            },
            actionItems: destinyData.action_items
          });
        } else {
          throw new Error('잘못된 응답 형식입니다');
        }
      } catch (err) {
        setError(err instanceof Error ? err.message : '알 수 없는 오류가 발생했습니다');
      } finally {
        setLoading(false);
      }
    };

    fetchDestinyData();
  }, []);

  if (loading) {
    return (
      <>
        <AppHeader title="나의 인연 운세" />
        <div className="flex items-center justify-center min-h-[60vh]">
          <div className="text-center">
            <Loader2 className="w-8 h-8 animate-spin mx-auto mb-4 text-fuchsia-600" />
            <p className="text-gray-600">인연운을 분석 중입니다...</p>
          </div>
        </div>
      </>
    );
  }

  if (error || !data) {
    return (
      <>
        <AppHeader title="나의 인연 운세" />
        <div className="flex items-center justify-center min-h-[60vh]">
          <div className="text-center">
            <p className="text-red-600 mb-4">{error || '데이터를 불러올 수 없습니다'}</p>
            <Button onClick={() => window.location.reload()}>다시 시도</Button>
          </div>
        </div>
      </>
    );
  }

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

