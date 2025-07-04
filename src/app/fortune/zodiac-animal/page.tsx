"use client";

import { useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import AppHeader from "@/components/AppHeader";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { 
  Footprints,
  SparklesIcon,
  Loader2,
  AlertCircleIcon,
} from "lucide-react";
import { useSharedFortune } from "@/hooks/use-shared-fortune";

const ZODIAC_ANIMALS: { [key: string]: { name: string; emoji: string; } } = {
    rat: { name: "쥐띠", emoji: "🐭" },
    ox: { name: "소띠", emoji: "🐮" },
    tiger: { name: "호랑이띠", emoji: "🐯" },
    rabbit: { name: "토끼띠", emoji: "🐰" },
    dragon: { name: "용띠", emoji: "🐲" },
    snake: { name: "뱀띠", emoji: "🐍" },
    horse: { name: "말띠", emoji: "🐴" },
    sheep: { name: "양띠", emoji: "🐑" },
    monkey: { name: "원숭이띠", emoji: "🐵" },
    rooster: { name: "닭띠", emoji: "🐔" },
    dog: { name: "개띠", emoji: "🐶" },
    pig: { name: "돼지띠", emoji: "🐷" },
};

const ZodiacAnimalFortuneResult = ({ groupKey }: { groupKey: string }) => {
  const { fortuneData, isLoading, isGenerating, error, refresh } = useSharedFortune({
    fortuneType: 'zodiacAnimal',
    groupKey,
    enabled: !!groupKey,
  });

  if (isLoading || isGenerating) {
    return (
      <div className="text-center p-8 flex flex-col items-center justify-center min-h-[200px]">
        <Loader2 className="w-8 h-8 animate-spin text-amber-500 mb-4" />
        <p className="font-semibold">{isGenerating ? '운세 생성 중...' : '운세 로딩 중...'}</p>
        <p className="text-sm text-muted-foreground">AI가 오늘의 띠별 운세를 분석하고 있습니다.</p>
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
                <CardTitle>오늘의 {ZODIAC_ANIMALS[groupKey].name} 운세</CardTitle>
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


export default function ZodiacAnimalFortunePage() {
  const [selectedAnimal, setSelectedAnimal] = useState<string>("");
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
    <div className="min-h-screen bg-gradient-to-br from-amber-50 via-lime-50 to-orange-50 dark:from-gray-900 dark:via-amber-900/20 dark:to-lime-900/20">
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
            <Footprints className="h-8 w-8 text-amber-600 dark:text-amber-400" />
            <h1 className="text-3xl font-bold bg-gradient-to-r from-amber-600 to-orange-600 dark:from-amber-400 dark:to-orange-400 bg-clip-text text-transparent">
              오늘의 띠별 운세
            </h1>
          </div>
        </motion.div>

        <AnimatePresence mode="wait">
          {!selectedAnimal ? (
            <motion.div
              key="selection"
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
            >
              <Card className="mb-8 bg-white dark:bg-gray-800">
                <CardHeader>
                  <CardTitle className="text-center flex items-center justify-center gap-2">
                    <SparklesIcon className="h-5 w-5 text-amber-500" />
                    자신의 띠를 선택해주세요
                  </CardTitle>
                </CardHeader>
                <CardContent>
                  <div className="grid grid-cols-3 md:grid-cols-4 lg:grid-cols-6 gap-4">
                    {Object.entries(ZODIAC_ANIMALS).map(([key, info]) => (
                      <motion.div
                        key={key}
                        whileHover={{ scale: 1.05 }}
                        whileTap={{ scale: 0.95 }}
                      >
                        <Button
                          variant="outline"
                          className="h-auto p-4 flex flex-col items-center gap-2 w-full text-2xl"
                          onClick={() => setSelectedAnimal(key)}
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
                    <span className="text-5xl">{ZODIAC_ANIMALS[selectedAnimal].emoji}</span>
                      <h2 className="text-2xl font-bold text-amber-700">
                        {ZODIAC_ANIMALS[selectedAnimal].name}
                      </h2>
                  </div>
                  <Button 
                    variant="outline" 
                    size="sm"
                    onClick={() => setSelectedAnimal("")}
                    className="mx-auto"
                  >
                    다른 띠 선택
                  </Button>
                </CardHeader>
              </Card>
              <ZodiacAnimalFortuneResult groupKey={selectedAnimal} />
            </motion.div>
          )}
        </AnimatePresence>
      </motion.div>
    </div>
  );
}