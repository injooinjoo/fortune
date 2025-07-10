"use client";

import { logger } from '@/lib/logger';
import { useState, useEffect } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import AppHeader from "@/components/AppHeader";
import { z } from "zod";
import toast from "react-hot-toast";
import { Loader2, Sparkles, RotateCcw, MessageCircle, BookOpen, Wand2 } from "lucide-react";
import { useAuth } from "@/contexts/AuthContext";
import { useUserProfile } from "@/hooks/use-user-profile";
import { useRouter } from "next/navigation";

interface TarotResult {
  situation: string;
  cards: Array<{
    name: string;
    meaning: string;
    position: string;
  }>;
  interpretation: string;
  advice: string;
}


const containerVariants = {
  hidden: { opacity: 0 },
  visible: { opacity: 1, transition: { staggerChildren: 0.1 } }
};

const itemVariants = {
  hidden: { y: 20, opacity: 0 },
  visible: { y: 0, opacity: 1 }
};

export default function TarotPage() {
  const [fontSize, setFontSize] = useState<'small' | 'medium' | 'large'>('medium');
  const [step, setStep] = useState<'input' | 'generating' | 'result'>('input');
  const [question, setQuestion] = useState("");
  const [result, setResult] = useState<TarotResult | null>(null);
  
  const { user } = useAuth();
  const { profile, isLoading: profileLoading, hasCompleteProfile } = useUserProfile();
  const router = useRouter();

  const handleTarotRequest = async () => {
    if (!question.trim()) {
      toast.error("질문을 입력해주세요.");
      return;
    }
    
    if (!profile || !hasCompleteProfile) {
      toast.error("프로필을 먼저 완성해주세요.");
      router.push('/onboarding');
      return;
    }
    
    setStep('generating');
    const loadingToast = toast.loading("AI가 타로 카드를 해석하고 있습니다...");

    try {
      const requestData = {
        userProfile: {
          name: profile.name,
          gender: profile.gender || 'other',
          birthDate: profile.birth_date!,
          mbti: profile.mbti || undefined,
        },
        category: "tarot",
        question: question,
      };

      const response = await fetch('/api/fortune/interactive', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(requestData),
      });

      if (!response.ok) {
        throw new Error('API request failed');
      }

      const finalResult = await response.json();
      
      setResult(finalResult);
      setStep('result');
      toast.success("타로 카드 해석이 완료되었습니다.", { id: loadingToast });

    } catch (error) {
      logger.error("타로 운세 생성 오류:", error);
      toast.error("오류가 발생했습니다. 다시 시도해주세요.", { id: loadingToast });
      setStep('input');
    }
  };
  
  const handleReset = () => {
    setStep('input');
    setResult(null);
    setQuestion("");
  };

  // 프로필 로딩 중일 때 표시
  if (profileLoading) {
    return (
      <div className="min-h-screen pb-32 px-4">
        <AppHeader title="AI 타로" onFontSizeChange={setFontSize} currentFontSize={fontSize} />
        <div className="flex items-center justify-center min-h-[50vh]">
          <div className="text-center space-y-4">
            <Loader2 className="w-8 h-8 animate-spin mx-auto" />
            <p>프로필 정보를 불러오는 중...</p>
          </div>
        </div>
      </div>
    );
  }

  const renderInputStep = () => (
    <motion.div
      key="input"
      variants={containerVariants}
      initial="hidden"
      animate="visible"
      exit={{ opacity: 0 }}
      className="max-w-2xl mx-auto"
    >
      <motion.div variants={itemVariants} className="text-center mb-8">
        <h1 className="text-4xl font-bold bg-gradient-to-r from-purple-600 to-indigo-600 bg-clip-text text-transparent">
          AI 타로 리딩
        </h1>
        <p className="text-muted-foreground mt-2">마음 속 질문을 입력하면, AI가 타로 카드를 통해 답을 찾아드립니다.</p>
      </motion.div>
      
      <motion.div variants={itemVariants}>
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <MessageCircle className="w-5 h-5 text-purple-500" />
              질문하기
            </CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            <Label htmlFor="tarot-question">고민이나 질문을 입력해주세요.</Label>
            <Input
              id="tarot-question"
              placeholder="예) 지금 진행하는 프로젝트가 잘 될까요?"
              value={question}
              onChange={(e) => setQuestion(e.target.value)}
              onKeyDown={(e) => e.key === 'Enter' && handleTarotRequest()}
            />
            <Button onClick={handleTarotRequest} className="w-full">
              <Sparkles className="mr-2 h-4 w-4" />
              AI 타로 해석 요청
            </Button>
          </CardContent>
        </Card>
      </motion.div>
    </motion.div>
  );

  const renderGeneratingStep = () => (
     <div className="flex flex-col items-center justify-center min-h-[50vh] text-center">
        <Loader2 className="w-12 h-12 animate-spin text-purple-500 mb-4" />
        <h2 className="text-2xl font-semibold">AI가 카드를 섞고 있습니다...</h2>
        <p className="text-muted-foreground mt-2">당신의 질문에 대한 답을 신중하게 찾고 있습니다.</p>
      </div>
  );
  
  const renderResultStep = () => {
    if (!result) return null;
    
    return (
      <motion.div
        key="result"
        variants={containerVariants}
        initial="hidden"
        animate="visible"
        className="max-w-4xl mx-auto space-y-6"
      >
        <motion.div variants={itemVariants}>
          <Card className="bg-gradient-to-br from-purple-50 via-indigo-50 to-blue-50 dark:from-gray-800 dark:to-gray-900">
            <CardHeader>
              <CardTitle className="text-2xl flex items-center gap-3">
                <BookOpen className="w-6 h-6 text-purple-600" />
                AI의 해석
              </CardTitle>
            </CardHeader>
            <CardContent>
              <p className="text-lg text-muted-foreground whitespace-pre-wrap">{result.interpretation}</p>
            </CardContent>
          </Card>
        </motion.div>

        <motion.div variants={itemVariants}>
          <Card>
             <CardHeader>
              <CardTitle className="text-xl flex items-center gap-3">
                <Wand2 className="w-5 h-5 text-indigo-500" />
                AI의 조언
              </CardTitle>
            </CardHeader>
            <CardContent>
              <p className="text-muted-foreground whitespace-pre-wrap">{result.advice}</p>
            </CardContent>
          </Card>
        </motion.div>

        {result.relatedTarotCards && result.relatedTarotCards.length > 0 && (
            <motion.div variants={itemVariants}>
            <h3 className="text-xl font-bold text-center">관련 카드</h3>
            <div className="flex flex-wrap justify-center gap-4 mt-4">
              {result.relatedTarotCards.map((card: string, index: number) => (
                <Card key={index} className="p-4 min-w-[120px] text-center">
                  <p>{card}</p>
                </Card>
              ))}
            </div>
            </motion.div>
        )}
        
        <motion.div variants={itemVariants} className="text-center pt-6">
            <Button onClick={handleReset} variant="outline">
                <RotateCcw className="mr-2 h-4 w-4" />
                다른 질문하기
            </Button>
        </motion.div>
      </motion.div>
    );
  };

  return (
    <div className="min-h-screen pb-32 px-4">
      <AppHeader title="AI 타로" onFontSizeChange={setFontSize} currentFontSize={fontSize} />
      <AnimatePresence mode="wait">
        {step === 'input' && renderInputStep()}
        {step === 'generating' && renderGeneratingStep()}
        {step === 'result' && renderResultStep()}
      </AnimatePresence>
    </div>
  );
}