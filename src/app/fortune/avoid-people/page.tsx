"use client";

import { useState, useEffect } from "react";
import { motion } from "framer-motion";
import AppHeader from "@/components/AppHeader";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { AlertTriangle, AlertCircle, Users } from "lucide-react";

interface AvoidInfo {
  id: string;
  name: string;
  emoji: string;
  years: number[];
  avoid: string[];
  warnings: string[];
  advice: string;
}

const zodiacAvoidData: AvoidInfo[] = [
  {
    id: "rat",
    name: "쥐띠",
    emoji: "🐭",
    years: [1972, 1984, 1996, 2008, 2020, 2032],
    avoid: ["말띠", "양띠"],
    warnings: ["감정적인 결정은 피하세요", "건강 관리에 신경 쓰세요"],
    advice: "새로운 기회를 놓치지 마세요. 인맥을 통한 좋은 소식이 있을 것입니다."
  },
  {
    id: "ox",
    name: "소띠",
    emoji: "🐂",
    years: [1973, 1985, 1997, 2009, 2021, 2033],
    avoid: ["호랑이띠", "용띠"],
    warnings: ["성급한 판단 금물", "과로 주의"],
    advice: "꾸준함이 빛을 발하는 달입니다. 계획한 일을 차근차근 진행하세요."
  },
  {
    id: "tiger",
    name: "호랑이띠",
    emoji: "🐅",
    years: [1974, 1986, 1998, 2010, 2022, 2034],
    avoid: ["소띠", "뱀띠"],
    warnings: ["충동적인 행동 자제", "금전 관리 주의"],
    advice: "도전 정신을 발휘할 때입니다. 새로운 프로젝트에 적극 참여하세요."
  },
  {
    id: "rabbit",
    name: "토끼띠",
    emoji: "🐰",
    years: [1975, 1987, 1999, 2011, 2023, 2035],
    avoid: ["닭띠", "개띠"],
    warnings: ["우유부단함 주의", "스트레스 관리"],
    advice: "인간관계에서 좋은 기운이 흐릅니다. 협력을 통해 성과를 얻으세요."
  },
  {
    id: "dragon",
    name: "용띠",
    emoji: "🐲",
    years: [1976, 1988, 2000, 2012, 2024, 2036],
    avoid: ["개띠", "소띠"],
    warnings: ["자만 금물", "건강 체크 필요"],
    advice: "리더십을 발휘할 절호의 기회입니다. 큰 그림을 그리며 행동하세요."
  },
  {
    id: "snake",
    name: "뱀띠",
    emoji: "🐍",
    years: [1977, 1989, 2001, 2013, 2025, 2037],
    avoid: ["호랑이띠", "돼지띠"],
    warnings: ["의심 과다 주의", "소화기 건강"],
    advice: "직감을 믿고 신중하게 판단하세요. 투자나 계약에 좋은 시기입니다."
  },
  {
    id: "horse",
    name: "말띠",
    emoji: "🐴",
    years: [1978, 1990, 2002, 2014, 2026, 2038],
    avoid: ["쥐띠", "소띠"],
    warnings: ["성급함 주의", "과로 금물"],
    advice: "활동적으로 움직일수록 운이 따릅니다. 여행이나 이동에 좋은 시기입니다."
  },
  {
    id: "goat",
    name: "양띠",
    emoji: "🐐",
    years: [1979, 1991, 2003, 2015, 2027, 2039],
    avoid: ["쥐띠", "소띠"],
    warnings: ["우울감 주의", "결정 장애"],
    advice: "예술적 감성을 살려보세요. 창작 활동이나 취미에 집중하면 좋습니다."
  },
  {
    id: "monkey",
    name: "원숭이띠",
    emoji: "🐵",
    years: [1980, 1992, 2004, 2016, 2028, 2040],
    avoid: ["호랑이띠", "돼지띠"],
    warnings: ["장난 과다 주의", "집중력 부족"],
    advice: "재치와 유머로 어려운 상황을 헤쳐나가세요. 네트워킹이 중요합니다."
  },
  {
    id: "rooster",
    name: "닭띠",
    emoji: "🐓",
    years: [1981, 1993, 2005, 2017, 2029, 2041],
    avoid: ["토끼띠", "개띠"],
    warnings: ["완벽주의 주의", "스트레스 관리"],
    advice: "세심한 계획과 실행력이 빛을 발합니다. 디테일에 신경 쓰세요."
  },
  {
    id: "dog",
    name: "개띠",
    emoji: "🐕",
    years: [1982, 1994, 2006, 2018, 2030, 2042],
    avoid: ["용띠", "양띠"],
    warnings: ["의심 과다", "관절 건강"],
    advice: "정의로운 일에 앞장서세요. 도움을 주는 만큼 돌아올 것입니다."
  },
  {
    id: "pig",
    name: "돼지띠",
    emoji: "🐷",
    years: [1983, 1995, 2007, 2019, 2031, 2043],
    avoid: ["뱀띠", "원숭이띠"],
    warnings: ["과소비 주의", "과식 금물"],
    advice: "관대한 마음으로 베푸세요. 재물운이 상승하는 시기입니다."
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

export default function AvoidPeoplePage() {
  const [selectedSign, setSelectedSign] = useState<AvoidInfo | null>(null);
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
          const sign = zodiacAvoidData.find(z =>
            z.years.some(y => (birthYear - y) % 12 === 0)
          );
          if (sign) {
            setSelectedSign(sign);
          }
        }
      } catch (error) {
        console.error('프로필 파싱 오류:', error);
      }
    }
  }, []);

  const fontClass = fontSize === 'small' ? 'text-sm' : fontSize === 'large' ? 'text-lg' : 'text-base';

  if (!selectedSign) {
    return (
      <>
        <AppHeader
          title="피해야 할 상대"
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
              <AlertTriangle className="h-8 w-8 text-red-600" />
              <h1 className="text-3xl font-bold bg-gradient-to-r from-red-600 to-orange-600 bg-clip-text text-transparent">
                피해야 할 상대
              </h1>
            </div>
            <p className="text-gray-600">갈등을 줄이기 위해 조심해야 할 상대의 띠를 선택하세요</p>
          </motion.div>

          <div className="grid grid-cols-3 gap-3">
            {zodiacAvoidData.map(sign => (
              <motion.div
                key={sign.id}
                variants={itemVariants}
                whileHover={{ scale: 1.05 }}
                whileTap={{ scale: 0.95 }}
                onClick={() => setSelectedSign(sign)}
                className="cursor-pointer"
              >
                <Card className="text-center hover:shadow-md transition-all duration-300 border-2 hover:border-red-300">
                  <CardContent className="p-4">
                    <div className="text-3xl mb-2">{sign.emoji}</div>
                    <div className="font-medium text-sm">{sign.name}</div>
                    <div className="text-xs text-gray-500 mt-1">
                      {sign.years.slice(-2).join(', ')}년
                    </div>
                  </CardContent>
                </Card>
              </motion.div>
            ))}
          </div>

          {userBirthYear && (
            <motion.div variants={itemVariants} className="mt-6">
              <Card className="bg-red-50 border-red-200">
                <CardContent className="p-4 text-center">
                  <p className="text-sm text-red-700">
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
        title="피해야 할 상대"
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
          <div className="text-6xl mb-4">{selectedSign.emoji}</div>
          <h1 className="text-2xl font-bold text-gray-900 mb-2">{selectedSign.name}</h1>
          <Button
            variant="outline"
            size="sm"
            onClick={() => setSelectedSign(null)}
            className="mx-auto"
          >
            다른 띠 선택
          </Button>
        </motion.div>

        <motion.div variants={itemVariants}>
          <Card className="mb-6 bg-gradient-to-r from-red-50 to-orange-50 border-red-200">
            <CardHeader className="text-center">
              <CardTitle className="flex items-center justify-center gap-2 text-red-700">
                <Users className="h-5 w-5" />
                조심해야 할 상대
              </CardTitle>
            </CardHeader>
            <CardContent className="text-center">
              <div className="flex flex-wrap justify-center gap-2">
                {selectedSign.avoid.map((a, idx) => (
                  <Badge key={idx} className="bg-red-100 text-red-700">
                    {a}
                  </Badge>
                ))}
              </div>
            </CardContent>
          </Card>
        </motion.div>

        <motion.div variants={itemVariants}>
          <Card className="mb-6 border-orange-200 bg-orange-50">
            <CardHeader>
              <CardTitle className="flex items-center gap-2 text-orange-700">
                <AlertCircle className="h-5 w-5" />
                조심해야 할 점
              </CardTitle>
            </CardHeader>
            <CardContent>
              <ul className={`list-disc pl-5 space-y-2 ${fontClass}`}>
                {selectedSign.warnings.map((w, i) => (
                  <li key={i}>{w}</li>
                ))}
              </ul>
            </CardContent>
          </Card>
        </motion.div>

        <motion.div variants={itemVariants}>
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                현명한 관계를 위한 조언
              </CardTitle>
            </CardHeader>
            <CardContent>
              <p className={`${fontClass} text-gray-600`}>{selectedSign.advice}</p>
              <p className={`${fontClass} text-gray-600 mt-2`}>
                서로의 차이를 이해하고 존중하는 태도가 갈등을 줄이는 열쇠입니다.
              </p>
            </CardContent>
          </Card>
        </motion.div>
      </motion.div>
    </>
  );
}

