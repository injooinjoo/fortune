"use client";

import { useState, useEffect } from "react";
import { motion } from "framer-motion";
import AppHeader from "@/components/AppHeader";
import { Progress } from "@/components/ui/progress";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { 
  StarIcon, 
  TrendingUpIcon, 
  HeartIcon, 
  BriefcaseIcon, 
  CoinsIcon,
  UserIcon,
  CheckCircleIcon,
  AlertCircleIcon,
  MoonIcon,
  SunIcon,
  SparklesIcon,
  CalendarIcon
} from "lucide-react";

// 별자리 데이터
const ZODIAC_SIGNS = {
  aries: { name: "양자리", period: "3.21 - 4.19", color: "red", emoji: "♈", element: "불" },
  taurus: { name: "황소자리", period: "4.20 - 5.20", color: "green", emoji: "♉", element: "땅" },
  gemini: { name: "쌍둥이자리", period: "5.21 - 6.21", color: "yellow", emoji: "♊", element: "공기" },
  cancer: { name: "게자리", period: "6.22 - 7.22", color: "blue", emoji: "♋", element: "물" },
  leo: { name: "사자자리", period: "7.23 - 8.22", color: "orange", emoji: "♌", element: "불" },
  virgo: { name: "처녀자리", period: "8.23 - 9.22", color: "emerald", emoji: "♍", element: "땅" },
  libra: { name: "천칭자리", period: "9.23 - 10.22", color: "pink", emoji: "♎", element: "공기" },
  scorpio: { name: "전갈자리", period: "10.23 - 11.21", color: "purple", emoji: "♏", element: "물" },
  sagittarius: { name: "사수자리", period: "11.22 - 12.21", color: "indigo", emoji: "♐", element: "불" },
  capricorn: { name: "염소자리", period: "12.22 - 1.19", color: "gray", emoji: "♑", element: "땅" },
  aquarius: { name: "물병자리", period: "1.20 - 2.18", color: "cyan", emoji: "♒", element: "공기" },
  pisces: { name: "물고기자리", period: "2.19 - 3.20", color: "teal", emoji: "♓", element: "물" }
};

const MONTHLY_FORTUNE = {
  leo: {
    overall: 88,
    love: 92,
    career: 85,
    wealth: 80,
    summary: "태양의 힘이 가장 강한 시기, 당신의 매력이 빛나는 한 달입니다.",
    keyword: ["리더십", "창의성", "자신감"],
    advice: "자신감을 가지고 앞으로 나아가세요. 당신의 카리스마가 주변 사람들을 이끌 것입니다.",
    luckyStone: "페리도트",
    luckyColor: "골드",
    luckyDay: "일요일"
  },
  scorpio: {
    overall: 82,
    love: 88,
    career: 78,
    wealth: 85,
    summary: "직감과 통찰력이 뛰어난 시기, 숨겨진 기회를 발견할 것입니다.",
    keyword: ["직감", "변화", "깊이"],
    advice: "표면적인 것에 속지 마세요. 당신의 직감을 믿고 깊이 있게 탐구하세요.",
    luckyStone: "토파즈",
    luckyColor: "진홍색",
    luckyDay: "화요일"
  },
  pisces: {
    overall: 75,
    love: 90,
    career: 65,
    wealth: 70,
    summary: "감성과 직감이 발달하는 시기, 예술적 영감이 풍부해집니다.",
    keyword: ["감성", "직감", "영감"],
    advice: "논리보다는 감정과 직감을 따라가세요. 예술적 활동이 도움이 될 것입니다.",
    luckyStone: "아쿠아마린",
    luckyColor: "바다색",
    luckyDay: "목요일"
  }
};

export default function ZodiacFortunePage() {
  const [selectedZodiac, setSelectedZodiac] = useState<string>("");
  const [currentFortune, setCurrentFortune] = useState<any>(null);
  const [currentMonth] = useState(new Date().toLocaleDateString('ko-KR', { month: 'long' }));

  useEffect(() => {
    // 로컬 스토리지에서 사용자 별자리 불러오기
    const savedProfile = localStorage.getItem("userProfile");
    if (savedProfile) {
      try {
        const profile = JSON.parse(savedProfile);
        if (profile.zodiac) {
          setSelectedZodiac(profile.zodiac);
          setCurrentFortune(MONTHLY_FORTUNE[profile.zodiac as keyof typeof MONTHLY_FORTUNE] || MONTHLY_FORTUNE.leo);
        }
      } catch (error) {
        console.error("Failed to parse user profile:", error);
      }
    }
  }, []);

  const handleZodiacSelect = (zodiac: string) => {
    setSelectedZodiac(zodiac);
    setCurrentFortune(MONTHLY_FORTUNE[zodiac as keyof typeof MONTHLY_FORTUNE] || MONTHLY_FORTUNE.leo);
    
    // 사용자 프로필에 별자리 저장
    const savedProfile = localStorage.getItem("userProfile");
    if (savedProfile) {
      try {
        const profile = JSON.parse(savedProfile);
        profile.zodiac = zodiac;
        localStorage.setItem("userProfile", JSON.stringify(profile));
      } catch (error) {
        console.error("Failed to save zodiac:", error);
      }
    }
  };

  const containerVariants = {
    hidden: { opacity: 0 },
    visible: {
      opacity: 1,
      transition: {
        staggerChildren: 0.1
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
        stiffness: 100
      }
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-indigo-50 via-purple-50 to-blue-50">
      <AppHeader />
      
      <motion.div 
        className="container mx-auto px-4 pt-4 pb-20"
        variants={containerVariants}
        initial="hidden"
        animate="visible"
      >
        {/* 헤더 섹션 */}
        <motion.div variants={itemVariants} className="text-center mb-8">
          <div className="flex items-center justify-center gap-2 mb-4">
            <StarIcon className="h-8 w-8 text-indigo-600" />
            <h1 className="text-3xl font-bold bg-gradient-to-r from-indigo-600 to-purple-600 bg-clip-text text-transparent">
              별자리 월간운세
            </h1>
          </div>
          <p className="text-gray-600">
            {currentMonth} 별이 전하는 메시지를 확인해보세요
          </p>
        </motion.div>

        {/* 별자리 선택 */}
        {!selectedZodiac && (
          <motion.div variants={itemVariants}>
            <Card className="mb-8">
              <CardHeader>
                <CardTitle className="text-center flex items-center justify-center gap-2">
                  <SparklesIcon className="h-5 w-5 text-indigo-600" />
                  당신의 별자리를 선택해주세요
                </CardTitle>
              </CardHeader>
              <CardContent>
                <div className="grid grid-cols-3 md:grid-cols-4 gap-3">
                  {Object.entries(ZODIAC_SIGNS).map(([sign, info]) => (
                    <motion.div
                      key={sign}
                      whileHover={{ scale: 1.05 }}
                      whileTap={{ scale: 0.95 }}
                    >
                      <Button
                        variant="outline"
                        className={`h-auto p-4 flex flex-col items-center gap-2 w-full border-${info.color}-200 hover:bg-${info.color}-50`}
                        onClick={() => handleZodiacSelect(sign)}
                      >
                        <span className="text-3xl">{info.emoji}</span>
                        <span className="font-bold text-sm">{info.name}</span>
                        <span className="text-xs text-gray-600">{info.period}</span>
                      </Button>
                    </motion.div>
                  ))}
                </div>
              </CardContent>
            </Card>
          </motion.div>
        )}

        {/* 선택된 별자리 정보 */}
        {selectedZodiac && currentFortune && (
          <>
            <motion.div variants={itemVariants}>
              <Card className="mb-6 border-indigo-200 bg-gradient-to-r from-indigo-50 to-purple-50">
                <CardHeader className="text-center">
                  <div className="flex items-center justify-center gap-3 mb-2">
                    <span className="text-5xl">{ZODIAC_SIGNS[selectedZodiac as keyof typeof ZODIAC_SIGNS]?.emoji}</span>
                    <div>
                      <h2 className="text-2xl font-bold text-indigo-700">
                        {ZODIAC_SIGNS[selectedZodiac as keyof typeof ZODIAC_SIGNS]?.name}
                      </h2>
                      <p className="text-indigo-600">
                        {ZODIAC_SIGNS[selectedZodiac as keyof typeof ZODIAC_SIGNS]?.period}
                      </p>
                      <Badge variant="outline" className="mt-1">
                        {ZODIAC_SIGNS[selectedZodiac as keyof typeof ZODIAC_SIGNS]?.element} 원소
                      </Badge>
                    </div>
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
            </motion.div>

            {/* 이번 달 종합 운세 */}
            <motion.div variants={itemVariants}>
              <Card className="mb-6 border-purple-200 bg-gradient-to-r from-purple-50 to-indigo-50">
                <CardHeader className="text-center">
                  <CardTitle className="flex items-center justify-center gap-2 text-purple-700">
                    <CalendarIcon className="h-5 w-5" />
                    {currentMonth} 종합 운세
                  </CardTitle>
                </CardHeader>
                <CardContent className="text-center">
                  <div className="text-4xl font-bold text-purple-600 mb-2">{currentFortune.overall}점</div>
                  <Progress value={currentFortune.overall} className="mb-4" />
                  <p className="text-sm text-gray-600 mb-4">
                    {currentFortune.summary}
                  </p>
                  
                  <div className="flex flex-wrap justify-center gap-2">
                    {currentFortune.keyword.map((keyword: string, index: number) => (
                      <motion.div
                        key={keyword}
                        initial={{ scale: 0, opacity: 0 }}
                        animate={{ scale: 1, opacity: 1 }}
                        transition={{ delay: 0.6 + index * 0.1 }}
                      >
                        <Badge variant="secondary" className="bg-white/20 text-purple-700 border-purple-300">
                          #{keyword}
                        </Badge>
                      </motion.div>
                    ))}
                  </div>
                </CardContent>
              </Card>
            </motion.div>

            {/* 분야별 운세 */}
            <motion.div variants={itemVariants}>
              <Card className="mb-6">
                <CardHeader>
                  <CardTitle className="text-center">분야별 월간 운세</CardTitle>
                </CardHeader>
                <CardContent>
                  <div className="grid grid-cols-3 gap-4">
                    <div className="text-center p-4 bg-pink-50 rounded-lg">
                      <HeartIcon className="h-6 w-6 text-pink-600 mx-auto mb-2" />
                      <div className="text-2xl font-bold text-pink-600">{currentFortune.love}</div>
                      <div className="text-sm text-gray-600">연애운</div>
                    </div>
                    <div className="text-center p-4 bg-blue-50 rounded-lg">
                      <BriefcaseIcon className="h-6 w-6 text-blue-600 mx-auto mb-2" />
                      <div className="text-2xl font-bold text-blue-600">{currentFortune.career}</div>
                      <div className="text-sm text-gray-600">취업운</div>
                    </div>
                    <div className="text-center p-4 bg-yellow-50 rounded-lg">
                      <CoinsIcon className="h-6 w-6 text-yellow-600 mx-auto mb-2" />
                      <div className="text-2xl font-bold text-yellow-600">{currentFortune.wealth}</div>
                      <div className="text-sm text-gray-600">금전운</div>
                    </div>
                  </div>
                </CardContent>
              </Card>
            </motion.div>

            {/* 별자리별 특화 조언 */}
            <motion.div variants={itemVariants}>
              <Card className="mb-6">
                <CardHeader>
                  <CardTitle className="flex items-center gap-2">
                    <StarIcon className="h-5 w-5 text-indigo-600" />
                    {ZODIAC_SIGNS[selectedZodiac as keyof typeof ZODIAC_SIGNS]?.name} 맞춤 조언
                  </CardTitle>
                </CardHeader>
                <CardContent>
                  <div className="bg-gradient-to-r from-indigo-50 to-purple-50 p-4 rounded-lg">
                    <p className="text-sm text-indigo-700 leading-relaxed">
                      {currentFortune.advice}
                    </p>
                  </div>
                </CardContent>
              </Card>
            </motion.div>

            {/* 이번 달 주요 운세 포인트 */}
            <motion.div variants={itemVariants}>
              <Card className="mb-6">
                <CardHeader>
                  <CardTitle className="flex items-center gap-2">
                    <MoonIcon className="h-5 w-5 text-blue-600" />
                    이번 달 주요 운세 포인트
                  </CardTitle>
                </CardHeader>
                <CardContent>
                  <div className="space-y-4">
                    <div className="bg-gradient-to-r from-blue-50 to-indigo-50 p-4 rounded-lg">
                      <h4 className="font-medium text-blue-800 mb-2">상반기 (1-15일)</h4>
                      <p className="text-sm text-blue-700">
                        새로운 시작에 유리한 시기입니다. 계획했던 일들을 실행에 옮기기 좋은 때입니다.
                      </p>
                    </div>
                    
                    <div className="bg-gradient-to-r from-purple-50 to-pink-50 p-4 rounded-lg">
                      <h4 className="font-medium text-purple-800 mb-2">하반기 (16-31일)</h4>
                      <p className="text-sm text-purple-700">
                        인간관계에 집중하는 시기입니다. 소통과 협력을 통해 좋은 결과를 얻을 수 있습니다.
                      </p>
                    </div>
                  </div>
                </CardContent>
              </Card>
            </motion.div>

            {/* 이번 달 추천 활동 */}
            <motion.div variants={itemVariants}>
              <Card className="mb-6">
                <CardHeader>
                  <CardTitle className="flex items-center gap-2">
                    <SunIcon className="h-5 w-5 text-yellow-500" />
                    이번 달 추천 활동
                  </CardTitle>
                </CardHeader>
                <CardContent>
                  <div className="space-y-3">
                    {ZODIAC_SIGNS[selectedZodiac as keyof typeof ZODIAC_SIGNS]?.element === '불' && (
                      <>
                        <div className="flex items-start gap-3 p-3 bg-orange-50 rounded-lg">
                          <StarIcon className="h-5 w-5 text-orange-500 mt-0.5" />
                          <div>
                            <div className="font-medium">적극적인 도전</div>
                            <div className="text-sm text-gray-600">새로운 프로젝트나 활동에 적극적으로 참여하세요</div>
                          </div>
                        </div>
                        <div className="flex items-start gap-3 p-3 bg-red-50 rounded-lg">
                          <CheckCircleIcon className="h-5 w-5 text-red-500 mt-0.5" />
                          <div>
                            <div className="font-medium">리더십 발휘</div>
                            <div className="text-sm text-gray-600">팀이나 그룹에서 주도적인 역할을 맡아보세요</div>
                          </div>
                        </div>
                      </>
                    )}
                    
                    {ZODIAC_SIGNS[selectedZodiac as keyof typeof ZODIAC_SIGNS]?.element === '물' && (
                      <>
                        <div className="flex items-start gap-3 p-3 bg-blue-50 rounded-lg">
                          <MoonIcon className="h-5 w-5 text-blue-500 mt-0.5" />
                          <div>
                            <div className="font-medium">감정 정리</div>
                            <div className="text-sm text-gray-600">내면의 목소리에 귀 기울이고 감정을 정리하는 시간</div>
                          </div>
                        </div>
                        <div className="flex items-start gap-3 p-3 bg-teal-50 rounded-lg">
                          <CheckCircleIcon className="h-5 w-5 text-teal-500 mt-0.5" />
                          <div>
                            <div className="font-medium">창작 활동</div>
                            <div className="text-sm text-gray-600">예술이나 창작 활동을 통해 영감을 표현하세요</div>
                          </div>
                        </div>
                      </>
                    )}
                    
                    {ZODIAC_SIGNS[selectedZodiac as keyof typeof ZODIAC_SIGNS]?.element === '공기' && (
                      <>
                        <div className="flex items-start gap-3 p-3 bg-sky-50 rounded-lg">
                          <UserIcon className="h-5 w-5 text-sky-500 mt-0.5" />
                          <div>
                            <div className="font-medium">소통 강화</div>
                            <div className="text-sm text-gray-600">다양한 사람들과의 대화와 교류에 집중하세요</div>
                          </div>
                        </div>
                        <div className="flex items-start gap-3 p-3 bg-cyan-50 rounded-lg">
                          <CheckCircleIcon className="h-5 w-5 text-cyan-500 mt-0.5" />
                          <div>
                            <div className="font-medium">학습과 연구</div>
                            <div className="text-sm text-gray-600">새로운 지식 습득이나 연구 활동이 도움이 됩니다</div>
                          </div>
                        </div>
                      </>
                    )}
                    
                    {ZODIAC_SIGNS[selectedZodiac as keyof typeof ZODIAC_SIGNS]?.element === '땅' && (
                      <>
                        <div className="flex items-start gap-3 p-3 bg-green-50 rounded-lg">
                          <CheckCircleIcon className="h-5 w-5 text-green-500 mt-0.5" />
                          <div>
                            <div className="font-medium">안정적인 계획</div>
                            <div className="text-sm text-gray-600">체계적이고 실용적인 계획 수립에 집중하세요</div>
                          </div>
                        </div>
                        <div className="flex items-start gap-3 p-3 bg-emerald-50 rounded-lg">
                          <AlertCircleIcon className="h-5 w-5 text-emerald-500 mt-0.5" />
                          <div>
                            <div className="font-medium">건강 관리</div>
                            <div className="text-sm text-gray-600">규칙적인 생활과 건강 관리에 신경 쓰세요</div>
                          </div>
                        </div>
                      </>
                    )}
                  </div>
                </CardContent>
              </Card>
            </motion.div>

            {/* 이번 달 행운 아이템 */}
            <motion.div variants={itemVariants}>
              <Card>
                <CardHeader>
                  <CardTitle className="flex items-center gap-2">
                    <SparklesIcon className="h-5 w-5 text-yellow-500" />
                    이번 달 행운 아이템
                  </CardTitle>
                </CardHeader>
                <CardContent>
                  <div className="grid grid-cols-2 gap-4">
                    <div className="text-center p-3 bg-purple-50 rounded-lg">
                      <div className="text-sm font-medium text-purple-800">행운의 보석</div>
                      <div className="text-lg font-bold text-purple-600">{currentFortune.luckyStone}</div>
                    </div>
                    <div className="text-center p-3 bg-yellow-50 rounded-lg">
                      <div className="text-sm font-medium text-yellow-800">행운의 색상</div>
                      <div className="text-lg font-bold text-yellow-600">{currentFortune.luckyColor}</div>
                    </div>
                    <div className="text-center p-3 bg-blue-50 rounded-lg">
                      <div className="text-sm font-medium text-blue-800">행운의 요일</div>
                      <div className="text-lg font-bold text-blue-600">{currentFortune.luckyDay}</div>
                    </div>
                    <div className="text-center p-3 bg-green-50 rounded-lg">
                      <div className="text-sm font-medium text-green-800">행운의 숫자</div>
                      <div className="text-lg font-bold text-green-600">
                        {selectedZodiac === 'leo' ? '5' : selectedZodiac === 'scorpio' ? '8' : '3'}
                      </div>
                    </div>
                  </div>
                </CardContent>
              </Card>
            </motion.div>
          </>
        )}
      </motion.div>
    </div>
  );
} 