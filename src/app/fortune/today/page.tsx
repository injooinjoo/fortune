"use client";

import React, { useState, useEffect } from "react";
import { motion } from "framer-motion";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import {
  Accordion,
  AccordionContent,
  AccordionItem,
  AccordionTrigger,
} from "@/components/ui/accordion";
import {
  Star,
  Heart,
  Briefcase,
  Coins,
  Loader2,
  RefreshCw,
  Sparkles
} from "lucide-react";
import AppHeader from "@/components/AppHeader";
import { useDailyFortune } from "@/hooks/use-daily-fortune";
import { 
  ComprehensiveDailyFortuneResultSchema, 
  UserProfileSchema 
} from "@/lib/types/fortune-schemas";
import { z } from "zod";
import toast from "react-hot-toast";

// TODO: This should come from a global state/user context
const MOCK_USER_PROFILE: z.infer<typeof UserProfileSchema> = {
  id: 'user_mock_id_12345',
  name: "홍길동",
  gender: 'male',
  birthDate: "1990-01-01",
  mbti: "INFP",
};

const itemVariants = {
  hidden: { opacity: 0, y: 20 },
  visible: { opacity: 1, y: 0, transition: { duration: 0.5 } }
};

export default function TodayFortunePage() {
  const [fontSize, setFontSize] = useState<'small'|'medium'|'large'>('medium');

  const {
    dailyFortune,
    isGenerating,
    error,
    generateDailyPackage,
  } = useDailyFortune(MOCK_USER_PROFILE);

  const dailyResult = dailyFortune as z.infer<typeof ComprehensiveDailyFortuneResultSchema> | undefined;

  const handleGenerate = async () => {
    const today = new Date().toISOString().split('T')[0];
    toast.loading("AI가 오늘의 운세를 새로 분석합니다...");
    try {
      await generateDailyPackage(today);
      toast.dismiss();
      toast.success("새로운 오늘의 운세가 도착했습니다!");
    } catch (e: any) {
      toast.dismiss();
      toast.error(`운세 생성에 실패했습니다: ${e.message}`);
    }
  };
  
  useEffect(() => {
    // 초기 로딩 시 데이터가 없으면 운세 생성
    if (!dailyFortune && !isGenerating && !error) {
      handleGenerate();
    }
  }, []); // 이펙트는 마운트 시 한 번만 실행

  if (isGenerating && !dailyFortune) { // 최초 생성 로딩
    return (
      <div className="min-h-screen pb-32 px-4">
        <AppHeader title="오늘의 운세" onFontSizeChange={setFontSize} currentFontSize={fontSize} />
        <div className="flex items-center justify-center min-h-[60vh]">
          <div className="text-center space-y-4">
            <Loader2 className="w-12 h-12 animate-spin mx-auto text-emerald-500" />
            <p className="text-xl font-semibold">운세 생성 중...</p>
            <p className="text-muted-foreground">AI가 당신의 하루를 분석하고 있습니다.</p>
          </div>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="min-h-screen pb-32 px-4">
        <AppHeader title="오늘의 운세" onFontSizeChange={setFontSize} currentFontSize={fontSize} />
        <div className="flex items-center justify-center min-h-[60vh]">
          <div className="text-center space-y-4 text-red-500">
             <p className="text-xl font-semibold">오류 발생</p>
             <p>{error.message}</p>
             <Button onClick={handleGenerate}><RefreshCw className="mr-2 h-4 w-4" /> 다시 시도</Button>
          </div>
        </div>
      </div>
    );
  }

  if (!dailyResult) {
    return (
       <div className="min-h-screen pb-32 px-4">
        <AppHeader title="오늘의 운세" onFontSizeChange={setFontSize} currentFontSize={fontSize} />
        <div className="flex items-center justify-center min-h-[60vh]">
          <p>운세 정보가 없습니다.</p>
           <Button onClick={handleGenerate}><RefreshCw className="mr-2 h-4 w-4" /> 운세 생성하기</Button>
        </div>
      </div>
    );
  }

  const fortuneSections = [
    { title: "오늘의 총운", icon: Star, data: dailyResult.overall, color: "text-yellow-500" },
    { title: "오늘의 애정운", icon: Heart, data: dailyResult.love, color: "text-red-500" },
    { title: "오늘의 재물운", icon: Coins, data: dailyResult.wealth, color: "text-green-500" },
    { title: "오늘의 직업운", icon: Briefcase, data: dailyResult.work, color: "text-blue-500" },
  ];

  return (
    <div className="min-h-screen pb-32 px-4 space-y-6 bg-gradient-to-br from-emerald-50 to-teal-50 dark:from-gray-900 dark:to-gray-800">
      <AppHeader title="오늘의 운세" onFontSizeChange={setFontSize} currentFontSize={fontSize} />
      
      <motion.div
        className="max-w-4xl mx-auto"
        initial="hidden"
        animate="visible"
        variants={{ hidden: { opacity: 0 }, visible: { opacity: 1, transition: { staggerChildren: 0.1 } } }}
      >
        <motion.div variants={itemVariants} className="text-center mb-8">
            <h1 className="text-4xl font-bold bg-gradient-to-r from-emerald-600 to-teal-600 bg-clip-text text-transparent">
              {new Date().toLocaleDateString('ko-KR', { month: 'long', day: 'numeric' })} 운세
            </h1>
        </motion.div>
        
        <div className="flex justify-end mb-4">
          <Button onClick={handleGenerate} disabled={isGenerating} variant="outline" size="sm">
            <RefreshCw className={`mr-2 h-4 w-4 ${isGenerating ? 'animate-spin' : ''}`} />
            새로 생성
          </Button>
        </div>

        <motion.div variants={itemVariants}>
          <Card className="shadow-lg border-0 bg-white/70 dark:bg-gray-800/70 backdrop-blur-sm">
            <CardHeader>
              <CardTitle className="text-2xl text-gray-800 dark:text-gray-200 flex items-center justify-center gap-2">
                <Sparkles className="w-6 h-6 text-emerald-500" />
                종합 분석
              </CardTitle>
            </CardHeader>
            <CardContent>
              <Accordion type="single" collapsible defaultValue="item-0">
                {fortuneSections.map((section, index) => (
                  <AccordionItem value={`item-${index}`} key={index}>
                    <AccordionTrigger className="text-lg font-semibold">
                      <div className="flex items-center gap-3">
                        <section.icon className={`${section.color} w-6 h-6`} />
                        {section.title}
                      </div>
                    </AccordionTrigger>
                    <AccordionContent className="space-y-4 pt-4">
                      <p className="text-base text-muted-foreground">{section.data.summary}</p>
                      <p className="text-sm text-muted-foreground whitespace-pre-wrap">{section.data.details}</p>
                      <div className="flex flex-wrap gap-2 pt-2">
                        {section.data.keywords.map(kw => <Badge key={kw} variant="secondary">{kw}</Badge>)}
                      </div>
                    </AccordionContent>
                  </AccordionItem>
                ))}
              </Accordion>
            </CardContent>
          </Card>
        </motion.div>
      </motion.div>
    </div>
  );
}
