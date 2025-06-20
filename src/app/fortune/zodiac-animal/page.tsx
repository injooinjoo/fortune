"use client";

import React, { useState, useEffect } from "react";
import { motion } from "framer-motion";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Progress } from "@/components/ui/progress";
import AppHeader from "@/components/AppHeader";
import {
  Star,
  TrendingUp,
  Heart,
  Briefcase,
  Coins,
  Crown,
  Gift,
  User,
  Clock,
  Sparkles
} from "lucide-react";

interface ZodiacAnimal {
  id: string;
  name: string;
  emoji: string;
  years: number[];
  element: string;
  personality: string[];
  luckyNumbers: number[];
  luckyColors: string[];
  compatibility: {
    best: string[];
    good: string[];
    avoid: string[];
  };
  fortune: {
    overall: number;
    love: number;
    career: number;
    wealth: number;
    health: number;
  };
  monthlyAdvice: string;
  luckyDays: string[];
  warnings: string[];
}

const zodiacAnimals: ZodiacAnimal[] = [
  {
    id: "rat",
    name: "쥐띠",
    emoji: "🐭",
    years: [1972, 1984, 1996, 2008, 2020, 2032],
    element: "물",
    personality: ["영리함", "적응력", "사교성"],
    luckyNumbers: [2, 3, 6],
    luckyColors: ["파랑", "금색", "녹색"],
    compatibility: {
      best: ["용띠", "원숭이띠"],
      good: ["소띠", "호랑이띠"],
      avoid: ["말띠", "양띠"]
    },
    fortune: {
      overall: 82,
      love: 75,
      career: 88,
      wealth: 79,
      health: 85
    },
    monthlyAdvice: "새로운 기회를 놓치지 마세요. 인맥을 통한 좋은 소식이 있을 것입니다.",
    luckyDays: ["화요일", "토요일"],
    warnings: ["감정적인 결정은 피하세요", "건강 관리에 신경 쓰세요"]
  },
  {
    id: "ox",
    name: "소띠",
    emoji: "🐂",
    years: [1973, 1985, 1997, 2009, 2021, 2033],
    element: "땅",
    personality: ["성실함", "끈기", "신뢰성"],
    luckyNumbers: [1, 4, 9],
    luckyColors: ["갈색", "노란색", "초록색"],
    compatibility: {
      best: ["뱀띠", "닭띠"],
      good: ["쥐띠", "토끼띠"],
      avoid: ["호랑이띠", "용띠"]
    },
    fortune: {
      overall: 85,
      love: 80,
      career: 90,
      wealth: 83,
      health: 87
    },
    monthlyAdvice: "꾸준함이 빛을 발하는 달입니다. 계획한 일을 차근차근 진행하세요.",
    luckyDays: ["월요일", "금요일"],
    warnings: ["성급한 판단 금물", "과로 주의"]
  },
  {
    id: "tiger",
    name: "호랑이띠",
    emoji: "🐅",
    years: [1974, 1986, 1998, 2010, 2022, 2034],
    element: "나무",
    personality: ["용기", "리더십", "자신감"],
    luckyNumbers: [1, 3, 4],
    luckyColors: ["주황", "빨강", "금색"],
    compatibility: {
      best: ["말띠", "개띠"],
      good: ["토끼띠", "용띠"],
      avoid: ["소띠", "뱀띠"]
    },
    fortune: {
      overall: 78,
      love: 82,
      career: 85,
      wealth: 72,
      health: 80
    },
    monthlyAdvice: "도전 정신을 발휘할 때입니다. 새로운 프로젝트에 적극 참여하세요.",
    luckyDays: ["수요일", "일요일"],
    warnings: ["충동적인 행동 자제", "금전 관리 주의"]
  },
  {
    id: "rabbit",
    name: "토끼띠",
    emoji: "🐰",
    years: [1975, 1987, 1999, 2011, 2023, 2035],
    element: "나무",
    personality: ["온화함", "섬세함", "평화주의"],
    luckyNumbers: [3, 4, 6],
    luckyColors: ["분홍", "빨강", "보라"],
    compatibility: {
      best: ["양띠", "돼지띠"],
      good: ["호랑이띠", "용띠"],
      avoid: ["닭띠", "개띠"]
    },
    fortune: {
      overall: 88,
      love: 90,
      career: 84,
      wealth: 86,
      health: 92
    },
    monthlyAdvice: "인간관계에서 좋은 기운이 흐릅니다. 협력을 통해 성과를 얻으세요.",
    luckyDays: ["목요일", "토요일"],
    warnings: ["우유부단함 주의", "스트레스 관리"]
  },
  {
    id: "dragon",
    name: "용띠",
    emoji: "🐲",
    years: [1976, 1988, 2000, 2012, 2024, 2036],
    element: "땅",
    personality: ["카리스마", "창의성", "야망"],
    luckyNumbers: [1, 6, 7],
    luckyColors: ["보라", "금색", "은색"],
    compatibility: {
      best: ["쥐띠", "원숭이띠"],
      good: ["호랑이띠", "토끼띠"],
      avoid: ["개띠", "소띠"]
    },
    fortune: {
      overall: 92,
      love: 87,
      career: 95,
      wealth: 90,
      health: 89
    },
    monthlyAdvice: "리더십을 발휘할 절호의 기회입니다. 큰 그림을 그리며 행동하세요.",
    luckyDays: ["월요일", "금요일"],
    warnings: ["자만 금물", "건강 체크 필요"]
  },
  {
    id: "snake",
    name: "뱀띠",
    emoji: "🐍",
    years: [1977, 1989, 2001, 2013, 2025, 2037],
    element: "불",
    personality: ["지혜", "직감", "신비로움"],
    luckyNumbers: [2, 8, 9],
    luckyColors: ["녹색", "빨강", "노랑"],
    compatibility: {
      best: ["소띠", "닭띠"],
      good: ["용띠", "양띠"],
      avoid: ["호랑이띠", "돼지띠"]
    },
    fortune: {
      overall: 86,
      love: 83,
      career: 89,
      wealth: 88,
      health: 84
    },
    monthlyAdvice: "직감을 믿고 신중하게 판단하세요. 투자나 계약에 좋은 시기입니다.",
    luckyDays: ["화요일", "일요일"],
    warnings: ["의심 과다 주의", "소화기 건강"]
  },
  {
    id: "horse",
    name: "말띠",
    emoji: "🐴",
    years: [1978, 1990, 2002, 2014, 2026, 2038],
    element: "불",
    personality: ["자유로움", "활동적", "열정"],
    luckyNumbers: [2, 3, 7],
    luckyColors: ["빨강", "주황", "노랑"],
    compatibility: {
      best: ["호랑이띠", "개띠"],
      good: ["뱀띠", "양띠"],
      avoid: ["쥐띠", "소띠"]
    },
    fortune: {
      overall: 80,
      love: 85,
      career: 82,
      wealth: 75,
      health: 88
    },
    monthlyAdvice: "활동적으로 움직일수록 운이 따릅니다. 여행이나 이동에 좋은 시기입니다.",
    luckyDays: ["수요일", "토요일"],
    warnings: ["성급함 주의", "과로 금물"]
  },
  {
    id: "goat",
    name: "양띠",
    emoji: "🐐",
    years: [1979, 1991, 2003, 2015, 2027, 2039],
    element: "땅",
    personality: ["온순함", "예술성", "배려심"],
    luckyNumbers: [3, 4, 9],
    luckyColors: ["보라", "분홍", "초록"],
    compatibility: {
      best: ["토끼띠", "돼지띠"],
      good: ["뱀띠", "말띠"],
      avoid: ["쥐띠", "소띠"]
    },
    fortune: {
      overall: 84,
      love: 89,
      career: 78,
      wealth: 82,
      health: 86
    },
    monthlyAdvice: "예술적 감성을 살려보세요. 창작 활동이나 취미에 집중하면 좋습니다.",
    luckyDays: ["목요일", "일요일"],
    warnings: ["우울감 주의", "결정 장애"]
  },
  {
    id: "monkey",
    name: "원숭이띠",
    emoji: "🐵",
    years: [1980, 1992, 2004, 2016, 2028, 2040],
    element: "금",
    personality: ["재치", "유머", "적응력"],
    luckyNumbers: [1, 7, 8],
    luckyColors: ["금색", "흰색", "파랑"],
    compatibility: {
      best: ["쥐띠", "용띠"],
      good: ["뱀띠", "개띠"],
      avoid: ["호랑이띠", "돼지띠"]
    },
    fortune: {
      overall: 87,
      love: 82,
      career: 91,
      wealth: 89,
      health: 85
    },
    monthlyAdvice: "재치와 유머로 어려운 상황을 헤쳐나가세요. 네트워킹이 중요합니다.",
    luckyDays: ["월요일", "금요일"],
    warnings: ["장난 과다 주의", "집중력 부족"]
  },
  {
    id: "rooster",
    name: "닭띠",
    emoji: "🐓",
    years: [1981, 1993, 2005, 2017, 2029, 2041],
    element: "금",
    personality: ["정확성", "근면", "자부심"],
    luckyNumbers: [5, 7, 8],
    luckyColors: ["노랑", "갈색", "금색"],
    compatibility: {
      best: ["소띠", "뱀띠"],
      good: ["용띠", "원숭이띠"],
      avoid: ["토끼띠", "개띠"]
    },
    fortune: {
      overall: 83,
      love: 79,
      career: 87,
      wealth: 85,
      health: 81
    },
    monthlyAdvice: "세심한 계획과 실행력이 빛을 발합니다. 디테일에 신경 쓰세요.",
    luckyDays: ["화요일", "토요일"],
    warnings: ["완벽주의 주의", "스트레스 관리"]
  },
  {
    id: "dog",
    name: "개띠",
    emoji: "🐕",
    years: [1982, 1994, 2006, 2018, 2030, 2042],
    element: "땅",
    personality: ["충성심", "정의감", "보호본능"],
    luckyNumbers: [3, 4, 9],
    luckyColors: ["갈색", "빨강", "보라"],
    compatibility: {
      best: ["호랑이띠", "말띠"],
      good: ["원숭이띠", "돼지띠"],
      avoid: ["용띠", "양띠"]
    },
    fortune: {
      overall: 81,
      love: 84,
      career: 86,
      wealth: 77,
      health: 83
    },
    monthlyAdvice: "정의로운 일에 앞장서세요. 도움을 주는 만큼 돌아올 것입니다.",
    luckyDays: ["수요일", "일요일"],
    warnings: ["의심 과다", "관절 건강"]
  },
  {
    id: "pig",
    name: "돼지띠",
    emoji: "🐷",
    years: [1983, 1995, 2007, 2019, 2031, 2043],
    element: "물",
    personality: ["관대함", "정직함", "풍요로움"],
    luckyNumbers: [2, 5, 8],
    luckyColors: ["분홍", "노랑", "갈색"],
    compatibility: {
      best: ["토끼띠", "양띠"],
      good: ["호랑이띠", "개띠"],
      avoid: ["뱀띠", "원숭이띠"]
    },
    fortune: {
      overall: 89,
      love: 91,
      career: 85,
      wealth: 92,
      health: 88
    },
    monthlyAdvice: "관대한 마음으로 베푸세요. 재물운이 상승하는 시기입니다.",
    luckyDays: ["목요일", "토요일"],
    warnings: ["과소비 주의", "과식 금물"]
  }
];

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

export default function ZodiacAnimalPage() {
  const [selectedAnimal, setSelectedAnimal] = useState<ZodiacAnimal | null>(null);
  const [userBirthYear, setUserBirthYear] = useState<number | null>(null);
  const [fontSize, setFontSize] = useState<'small' | 'medium' | 'large'>('medium');

  useEffect(() => {
    const stored = localStorage.getItem('userProfile');
    if (stored) {
      try {
        const profile = JSON.parse(stored);
        if (profile.birthDate) {
          const birthYear = new Date(profile.birthDate).getFullYear();
          setUserBirthYear(birthYear);
          
          const userAnimal = zodiacAnimals.find(animal => 
            animal.years.some(year => (birthYear - year) % 12 === 0)
          );
          if (userAnimal) {
            setSelectedAnimal(userAnimal);
          }
        }
      } catch (error) {
        console.error('프로필 파싱 오류:', error);
      }
    }
  }, []);

  const getCurrentMonth = () => {
    const months = [
      "1월", "2월", "3월", "4월", "5월", "6월",
      "7월", "8월", "9월", "10월", "11월", "12월"
    ];
    return months[new Date().getMonth()];
  };

  if (!selectedAnimal) {
    return (
      <>
        <AppHeader 
          title="띠 운세" 
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
              <Crown className="h-8 w-8 text-yellow-600" />
              <h1 className="text-3xl font-bold bg-gradient-to-r from-yellow-600 to-red-600 bg-clip-text text-transparent">
                12간지 운세
              </h1>
            </div>
            <p className="text-gray-600">
              당신의 띠를 선택하여 {getCurrentMonth()} 운세를 확인해보세요
            </p>
          </motion.div>

          <div className="grid grid-cols-3 gap-3">
            {zodiacAnimals.map((animal) => (
              <motion.div
                key={animal.id}
                variants={itemVariants}
                whileHover={{ scale: 1.05 }}
                whileTap={{ scale: 0.95 }}
                onClick={() => setSelectedAnimal(animal)}
                className="cursor-pointer"
              >
                <Card className="text-center hover:shadow-md transition-all duration-300 border-2 hover:border-yellow-300">
                  <CardContent className="p-4">
                    <div className="text-3xl mb-2">{animal.emoji}</div>
                    <div className="font-medium text-sm">{animal.name}</div>
                    <div className="text-xs text-gray-500 mt-1">
                      {animal.years.slice(-2).join(', ')}년
                    </div>
                  </CardContent>
                </Card>
              </motion.div>
            ))}
          </div>

          {userBirthYear && (
            <motion.div variants={itemVariants} className="mt-6">
              <Card className="bg-blue-50 border-blue-200">
                <CardContent className="p-4 text-center">
                  <p className="text-sm text-blue-700">
                    {userBirthYear}년생이시네요! 위에서 해당하는 띠를 선택해주세요.
                  </p>
                </CardContent>
              </Card>
            </motion.div>
          )}
        </motion.div>
      </>
    );
  }

  return (
    <>
      <AppHeader 
        title={`${selectedAnimal.name} 운세`} 
        onFontSizeChange={setFontSize}
        currentFontSize={fontSize}
      />
      <motion.div 
        className="container mx-auto px-4 pt-4 pb-20"
        variants={containerVariants}
        initial="hidden"
        animate="visible"
      >
        <motion.div variants={itemVariants} className="text-center mb-6">
          <div className="text-6xl mb-4">{selectedAnimal.emoji}</div>
          <h1 className="text-2xl font-bold text-gray-900 mb-2">{selectedAnimal.name}</h1>
          <p className="text-gray-600">{getCurrentMonth()} 운세</p>
          <Button 
            variant="outline" 
            size="sm" 
            onClick={() => setSelectedAnimal(null)}
            className="mt-3"
          >
            다른 띠 보기
          </Button>
        </motion.div>

        <motion.div variants={itemVariants}>
          <Card className="mb-6 bg-gradient-to-r from-yellow-50 to-orange-50 border-yellow-200">
            <CardHeader className="text-center">
              <CardTitle className="flex items-center justify-center gap-2 text-yellow-700">
                <Star className="h-5 w-5" />
                {getCurrentMonth()} 종합 운세
              </CardTitle>
            </CardHeader>
            <CardContent className="text-center">
              <div className="text-4xl font-bold text-yellow-600 mb-2">
                {selectedAnimal.fortune.overall}점
              </div>
              <Progress value={selectedAnimal.fortune.overall} className="mb-4" />
              <p className="text-sm text-gray-600">
                {selectedAnimal.monthlyAdvice}
              </p>
            </CardContent>
          </Card>
        </motion.div>

        <motion.div variants={itemVariants}>
          <Card className="mb-6">
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <TrendingUp className="h-5 w-5" />
                분야별 운세
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-2">
                    <Heart className="h-4 w-4 text-red-500" />
                    <span>연애운</span>
                  </div>
                  <div className="flex items-center gap-2">
                    <Progress value={selectedAnimal.fortune.love} className="w-20" />
                    <span className="text-sm font-medium w-8">{selectedAnimal.fortune.love}</span>
                  </div>
                </div>
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-2">
                    <Briefcase className="h-4 w-4 text-blue-500" />
                    <span>직업운</span>
                  </div>
                  <div className="flex items-center gap-2">
                    <Progress value={selectedAnimal.fortune.career} className="w-20" />
                    <span className="text-sm font-medium w-8">{selectedAnimal.fortune.career}</span>
                  </div>
                </div>
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-2">
                    <Coins className="h-4 w-4 text-yellow-500" />
                    <span>재물운</span>
                  </div>
                  <div className="flex items-center gap-2">
                    <Progress value={selectedAnimal.fortune.wealth} className="w-20" />
                    <span className="text-sm font-medium w-8">{selectedAnimal.fortune.wealth}</span>
                  </div>
                </div>
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-2">
                    <Sparkles className="h-4 w-4 text-green-500" />
                    <span>건강운</span>
                  </div>
                  <div className="flex items-center gap-2">
                    <Progress value={selectedAnimal.fortune.health} className="w-20" />
                    <span className="text-sm font-medium w-8">{selectedAnimal.fortune.health}</span>
                  </div>
                </div>
              </div>
            </CardContent>
          </Card>
        </motion.div>

        <motion.div variants={itemVariants}>
          <Card className="mb-6">
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <User className="h-5 w-5" />
                {selectedAnimal.name} 특성
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                <div>
                  <div className="text-sm text-gray-600 mb-2">오행 원소</div>
                  <Badge variant="outline" className="text-purple-700">
                    {selectedAnimal.element}
                  </Badge>
                </div>
                <div>
                  <div className="text-sm text-gray-600 mb-2">성격</div>
                  <div className="flex flex-wrap gap-2">
                    {selectedAnimal.personality.map((trait, index) => (
                      <Badge key={index} variant="secondary">
                        {trait}
                      </Badge>
                    ))}
                  </div>
                </div>
              </div>
            </CardContent>
          </Card>
        </motion.div>

        <motion.div variants={itemVariants}>
          <Card className="mb-6">
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <Gift className="h-5 w-5" />
                행운의 정보
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <div className="text-sm text-gray-600 mb-1">행운의 숫자</div>
                  <div className="text-sm font-medium">
                    {selectedAnimal.luckyNumbers.join(', ')}
                  </div>
                </div>
                <div>
                  <div className="text-sm text-gray-600 mb-1">행운의 색상</div>
                  <div className="text-sm font-medium">
                    {selectedAnimal.luckyColors.join(', ')}
                  </div>
                </div>
                <div>
                  <div className="text-sm text-gray-600 mb-1">행운의 요일</div>
                  <div className="text-sm font-medium">
                    {selectedAnimal.luckyDays.join(', ')}
                  </div>
                </div>
              </div>
            </CardContent>
          </Card>
        </motion.div>

        <motion.div variants={itemVariants}>
          <Card className="mb-6">
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <Heart className="h-5 w-5" />
                띠별 궁합
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-3">
                <div>
                  <div className="text-sm text-gray-600 mb-2">최고 궁합</div>
                  <div className="flex flex-wrap gap-2">
                    {selectedAnimal.compatibility.best.map((animal, index) => (
                      <Badge key={index} className="bg-green-100 text-green-700">
                        {animal}
                      </Badge>
                    ))}
                  </div>
                </div>
                <div>
                  <div className="text-sm text-gray-600 mb-2">좋은 궁합</div>
                  <div className="flex flex-wrap gap-2">
                    {selectedAnimal.compatibility.good.map((animal, index) => (
                      <Badge key={index} className="bg-blue-100 text-blue-700">
                        {animal}
                      </Badge>
                    ))}
                  </div>
                </div>
                <div>
                  <div className="text-sm text-gray-600 mb-2">주의할 궁합</div>
                  <div className="flex flex-wrap gap-2">
                    {selectedAnimal.compatibility.avoid.map((animal, index) => (
                      <Badge key={index} className="bg-red-100 text-red-700">
                        {animal}
                      </Badge>
                    ))}
                  </div>
                </div>
              </div>
            </CardContent>
          </Card>
        </motion.div>

        <motion.div variants={itemVariants}>
          <Card className="bg-red-50 border-red-200">
            <CardHeader>
              <CardTitle className="flex items-center gap-2 text-red-700">
                <Clock className="h-5 w-5" />
                이달의 주의사항
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-2">
                {selectedAnimal.warnings.map((warning, index) => (
                  <div key={index} className="flex items-start gap-2 text-sm text-red-700">
                    <span className="text-red-400 mt-1">•</span>
                    <span>{warning}</span>
                  </div>
                ))}
              </div>
            </CardContent>
          </Card>
        </motion.div>
      </motion.div>
    </>
  );
} 