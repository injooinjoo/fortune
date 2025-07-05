"use client";

import { useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import AppHeader from "@/components/AppHeader";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { 
  StarIcon, 
  SparklesIcon,
  Loader2,
  AlertCircleIcon,
} from "lucide-react";
import { useSharedFortune } from "@/hooks/use-shared-fortune";

const ZODIAC_SIGNS: { [key: string]: { name: string; period: string; emoji: string; } } = {
  aries: { name: "양자리", period: "3.21 - 4.19", emoji: "♈" },
  taurus: { name: "황소자리", period: "4.20 - 5.20", emoji: "♉" },
  gemini: { name: "쌍둥이자리", period: "5.21 - 6.21", emoji: "♊" },
  cancer: { name: "게자리", period: "6.22 - 7.22", emoji: "♋" },
  leo: { name: "사자자리", period: "7.23 - 8.22", emoji: "♌" },
  virgo: { name: "처녀자리", period: "8.23 - 9.22", emoji: "♍" },
  libra: { name: "천칭자리", period: "9.23 - 10.22", emoji: "♎" },
  scorpio: { name: "전갈자리", period: "10.23 - 11.21", emoji: "♏" },
  sagittarius: { name: "사수자리", period: "11.22 - 12.21", emoji: "♐" },
  capricorn: { name: "염소자리", period: "12.22 - 1.19", emoji: "♑" },
  aquarius: { name: "물병자리", period: "1.20 - 2.18", emoji: "♒" },
  pisces: { name: "물고기자리", period: "2.19 - 3.20", emoji: "♓" }
};

const ZodiacFortuneResult = ({ groupKey }: { groupKey: string }) => {
  const { fortuneData, isLoading, isGenerating, error, refresh } = useSharedFortune({
    fortuneType: 'zodiac',
    groupKey,
    enabled: !!groupKey,
  });

  if (isLoading || isGenerating) {
    return (
      <div className="text-center p-8 flex flex-col items-center justify-center min-h-[200px]">
        <Loader2 className="w-8 h-8 animate-spin text-indigo-500 mb-4" />
        <p className="font-semibold">{isGenerating ? '운세 생성 중...' : '운세 로딩 중...'}</p>
        <p className="text-sm text-muted-foreground">AI가 오늘의 별자리 운세를 분석하고 있습니다.</p>
      </div>
    );
  }

  if (error) {
    return (
       <div className="text-center p-8 text-red-500">
        <AlertCircleIcon className="w-8 h-8 mx-auto mb-2" />
        <p className="font-semibold">오류 발생</p>
        <p className="text-sm">{error}</p>
      </div>
    );
  }
  
  if (!fortuneData) {
    return <div className="text-center p-8 text-muted-foreground">운세 정보를 불러올 수 없습니다.</div>;
  }

  return (
      <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} className="space-y-4">
        <Card>
            <CardHeader>
                <CardTitle>오늘의 {ZODIAC_SIGNS[groupKey].name} 운세</CardTitle>
            </CardHeader>
            <CardContent>
                <h3 className="font-bold mb-2">요약</h3>
                <p className="text-muted-foreground mb-4">{fortuneData.summary}</p>
                <h3 className="font-bold mb-2">상세 설명</h3>
                <p className="text-muted-foreground whitespace-pre-wrap">{fortuneData.details}</p>
            </CardContent>
        </Card>
        <Button onClick={refresh} variant="outline" className="w-full">다시 불러오기</Button>
      </motion.div>
  );
};


export default function ZodiacFortunePage() {
  const [selectedZodiac, setSelectedZodiac] = useState<string>("");
  const [fontSize, setFontSize] = useState<'small' | 'medium' | 'large'>('medium');

  const containerVariants = {
    hidden: { opacity: 0 },
    visible: { opacity: 1, transition: { staggerChildren: 0.1 } }
  };

  const itemVariants = {
    hidden: { y: 20, opacity: 0 },
    visible: { y: 0, opacity: 1 }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-indigo-50 via-purple-50 to-blue-50 dark:from-gray-900 dark:via-indigo-900/20 dark:to-purple-900/20">
      <AppHeader 
        title="오늘의 띠별 운세"
        onFontSizeChange={setFontSize}
        currentFontSize={fontSize}
      />
      
      <motion.div 
        className="container mx-auto px-4 pt-4 pb-20"
        variants={containerVariants}
        initial="hidden"
        animate="visible"
      >
        <motion.div variants={itemVariants} className="text-center mb-8">
          <div className="flex items-center justify-center gap-2 mb-4">
            <StarIcon className="h-8 w-8 text-indigo-600 dark:text-indigo-400" />
            <h1 className="text-3xl font-bold bg-gradient-to-r from-indigo-600 to-purple-600 dark:from-indigo-400 dark:to-purple-400 bg-clip-text text-transparent">
              오늘의 별자리 운세
            </h1>
          </div>
        </motion.div>

        <AnimatePresence mode="wait">
          {!selectedZodiac ? (
            <motion.div
              key="selection"
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
            >
              <Card className="mb-8 bg-white dark:bg-gray-800">
                <CardHeader>
                  <CardTitle className="text-center flex items-center justify-center gap-2">
                    <SparklesIcon className="h-5 w-5 text-indigo-500" />
                    별자리를 선택해주세요
                  </CardTitle>
                </CardHeader>
                <CardContent>
                  <div className="grid grid-cols-3 md:grid-cols-4 lg:grid-cols-6 gap-4">
                    {Object.entries(ZODIAC_SIGNS).map(([sign, info]) => (
                      <motion.div
                        key={sign}
                        whileHover={{ scale: 1.05 }}
                        whileTap={{ scale: 0.95 }}
                      >
                        <Button
                          variant="outline"
                          className="h-auto p-4 flex flex-col items-center gap-2 w-full"
                          onClick={() => setSelectedZodiac(sign)}
                        >
                          <span className="text-4xl">{info.emoji}</span>
                          <span className="font-bold">{info.name}</span>
                        </Button>
                      </motion.div>
                    ))}
                  </div>
                </CardContent>
              </Card>
            </motion.div>
          ) : (
            <motion.div
              key="result"
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              className="max-w-2xl mx-auto"
            >
              <Card className="mb-6">
                <CardHeader className="text-center">
                  <div className="flex items-center justify-center gap-3 mb-2">
                    <span className="text-5xl">{ZODIAC_SIGNS[selectedZodiac].emoji}</span>
                      <h2 className="text-2xl font-bold text-indigo-700">
                        {ZODIAC_SIGNS[selectedZodiac].name}
                      </h2>
                  </div>
                  <Button 
                    variant="outline" 
                    size="sm"
                    onClick={() => setSelectedZodiac("")}
                    className="mx-auto"
                  >
                    다른 별자리 선택
                  </Button>
                </CardHeader>
              </Card>
              <ZodiacFortuneResult groupKey={selectedZodiac} />
            </motion.div>
          )}
        </AnimatePresence>
      </motion.div>
    </div>
  );
} 