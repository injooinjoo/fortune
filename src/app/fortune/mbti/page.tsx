"use client";

import { useState, useEffect } from "react";
import { motion } from "framer-motion";
import AppHeader from "@/components/AppHeader";
import { Progress } from "@/components/ui/progress";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { 
  ZapIcon, 
  TrendingUpIcon, 
  StarIcon, 
  HeartIcon, 
  BriefcaseIcon, 
  CoinsIcon,
  UserIcon,
  CheckCircleIcon,
  AlertCircleIcon,
  BrainIcon,
  UsersIcon,
  TargetIcon
} from "lucide-react";

// MBTI 유형별 데이터
const MBTI_TYPES = {
  INTJ: { name: "건축가", color: "purple", emoji: "🏗️" },
  INTP: { name: "논리술사", color: "indigo", emoji: "🔬" },
  ENTJ: { name: "통솔자", color: "red", emoji: "👑" },
  ENTP: { name: "변론가", color: "orange", emoji: "💡" },
  INFJ: { name: "옹호자", color: "green", emoji: "🌱" },
  INFP: { name: "중재자", color: "pink", emoji: "🎨" },
  ENFJ: { name: "선도자", color: "blue", emoji: "🌟" },
  ENFP: { name: "활동가", color: "yellow", emoji: "🎭" },
  ISTJ: { name: "현실주의자", color: "gray", emoji: "📋" },
  ISFJ: { name: "수호자", color: "teal", emoji: "🛡️" },
  ESTJ: { name: "경영자", color: "emerald", emoji: "📊" },
  ESFJ: { name: "집정관", color: "rose", emoji: "🤝" },
  ISTP: { name: "만능재주꾼", color: "slate", emoji: "🔧" },
  ISFP: { name: "모험가", color: "cyan", emoji: "🌸" },
  ESTP: { name: "사업가", color: "amber", emoji: "⚡" },
  ESFP: { name: "연예인", color: "lime", emoji: "🎪" }
};

const WEEKLY_FORTUNE = {
  INTJ: {
    overall: 85,
    love: 75,
    career: 92,
    wealth: 80,
    summary: "체계적인 계획이 빛을 발하는 한 주입니다.",
    keyword: ["계획", "성취", "통찰"],
    advice: "장기적 관점에서 현재 상황을 바라보세요. 당신의 전략적 사고가 큰 성과로 이어질 것입니다."
  },
  ENFP: {
    overall: 78,
    love: 88,
    career: 70,
    wealth: 65,
    summary: "새로운 인연과 기회가 가득한 활기찬 주간입니다.",
    keyword: ["열정", "소통", "창의"],
    advice: "호기심을 따라가세요. 예상치 못한 만남이 새로운 가능성을 열어줄 것입니다."
  }
  // 나머지 유형들도 추가 가능
};

export default function MbtiFortunePage() {
  const [selectedMBTI, setSelectedMBTI] = useState<string>("");
  const [currentFortune, setCurrentFortune] = useState<any>(null);
  const [fontSize, setFontSize] = useState<'small' | 'medium' | 'large'>('medium');

  useEffect(() => {
    // 로컬 스토리지에서 사용자 MBTI 불러오기
    const savedProfile = localStorage.getItem("userProfile");
    if (savedProfile) {
      try {
        const profile = JSON.parse(savedProfile);
        if (profile.mbti) {
          setSelectedMBTI(profile.mbti);
          setCurrentFortune(WEEKLY_FORTUNE[profile.mbti as keyof typeof WEEKLY_FORTUNE] || WEEKLY_FORTUNE.ENFP);
        }
      } catch (error) {
        console.error("Failed to parse user profile:", error);
      }
    }
  }, []);

  const handleMBTISelect = (mbti: string) => {
    setSelectedMBTI(mbti);
    setCurrentFortune(WEEKLY_FORTUNE[mbti as keyof typeof WEEKLY_FORTUNE] || WEEKLY_FORTUNE.ENFP);
    
    // 사용자 프로필에 MBTI 저장
    const savedProfile = localStorage.getItem("userProfile");
    if (savedProfile) {
      try {
        const profile = JSON.parse(savedProfile);
        profile.mbti = mbti;
        localStorage.setItem("userProfile", JSON.stringify(profile));
      } catch (error) {
        console.error("Failed to save MBTI:", error);
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
    <div className="min-h-screen bg-gradient-to-br from-violet-50 via-purple-50 to-indigo-50">
      <AppHeader 
        title="MBTI 주간운세"
        onFontSizeChange={setFontSize}
        currentFontSize={fontSize}
      />
      
      <motion.div 
        className="container mx-auto px-4 pt-4 pb-20"
        variants={containerVariants}
        initial="hidden"
        animate="visible"
      >
        {/* 헤더 섹션 */}
        <motion.div variants={itemVariants} className="text-center mb-8">
          <div className="flex items-center justify-center gap-2 mb-4">
            <ZapIcon className="h-8 w-8 text-violet-600" />
            <h1 className="text-3xl font-bold bg-gradient-to-r from-violet-600 to-purple-600 bg-clip-text text-transparent">
              MBTI 주간운세
            </h1>
          </div>
          <p className="text-gray-600">
            성격 유형별 맞춤 주간 운세를 확인해보세요
          </p>
        </motion.div>

        {/* MBTI 선택 */}
        {!selectedMBTI && (
          <motion.div variants={itemVariants}>
            <Card className="mb-8">
              <CardHeader>
                <CardTitle className="text-center flex items-center justify-center gap-2">
                  <BrainIcon className="h-5 w-5 text-violet-600" />
                  당신의 MBTI를 선택해주세요
                </CardTitle>
              </CardHeader>
              <CardContent>
                <div className="grid grid-cols-4 gap-3">
                  {Object.entries(MBTI_TYPES).map(([type, info]) => (
                    <motion.div
                      key={type}
                      whileHover={{ scale: 1.05 }}
                      whileTap={{ scale: 0.95 }}
                    >
                      <Button
                        variant="outline"
                        className={`h-auto p-3 flex flex-col items-center gap-2 w-full border-${info.color}-200 hover:bg-${info.color}-50`}
                        onClick={() => handleMBTISelect(type)}
                      >
                        <span className="text-2xl">{info.emoji}</span>
                        <span className="font-bold text-sm">{type}</span>
                        <span className="text-xs text-gray-600">{info.name}</span>
                      </Button>
                    </motion.div>
                  ))}
                </div>
              </CardContent>
            </Card>
          </motion.div>
        )}

        {/* 선택된 MBTI 정보 */}
        {selectedMBTI && currentFortune && (
          <>
            <motion.div variants={itemVariants}>
              <Card className="mb-6 border-violet-200 bg-gradient-to-r from-violet-50 to-purple-50">
                <CardHeader className="text-center">
                  <div className="flex items-center justify-center gap-3 mb-2">
                    <span className="text-4xl">{MBTI_TYPES[selectedMBTI as keyof typeof MBTI_TYPES]?.emoji}</span>
                    <div>
                      <h2 className="text-2xl font-bold text-violet-700">{selectedMBTI}</h2>
                      <p className="text-violet-600">{MBTI_TYPES[selectedMBTI as keyof typeof MBTI_TYPES]?.name}</p>
                    </div>
                  </div>
                  <Button 
                    variant="outline" 
                    size="sm"
                    onClick={() => setSelectedMBTI("")}
                    className="mx-auto"
                  >
                    다른 MBTI 선택
                  </Button>
                </CardHeader>
              </Card>
            </motion.div>

            {/* 이번 주 종합 운세 */}
            <motion.div variants={itemVariants}>
              <Card className="mb-6 border-purple-200 bg-gradient-to-r from-purple-50 to-indigo-50">
                <CardHeader className="text-center">
                  <CardTitle className="flex items-center justify-center gap-2 text-purple-700">
                    <TrendingUpIcon className="h-5 w-5" />
                    이번 주 종합 운세
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
                  <CardTitle className="text-center">분야별 주간 운세</CardTitle>
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

            {/* MBTI별 특화 조언 */}
            <motion.div variants={itemVariants}>
              <Card className="mb-6">
                <CardHeader>
                  <CardTitle className="flex items-center gap-2">
                    <TargetIcon className="h-5 w-5 text-violet-600" />
                    {selectedMBTI} 맞춤 조언
                  </CardTitle>
                </CardHeader>
                <CardContent>
                  <div className="bg-gradient-to-r from-violet-50 to-purple-50 p-4 rounded-lg">
                    <p className="text-sm text-violet-700 leading-relaxed">
                      {currentFortune.advice}
                    </p>
                  </div>
                </CardContent>
              </Card>
            </motion.div>

            {/* 이번 주 추천 활동 */}
            <motion.div variants={itemVariants}>
              <Card className="mb-6">
                <CardHeader>
                  <CardTitle className="flex items-center gap-2">
                    <StarIcon className="h-5 w-5 text-yellow-500" />
                    이번 주 추천 활동
                  </CardTitle>
                </CardHeader>
                <CardContent>
                  <div className="space-y-3">
                    {selectedMBTI.startsWith('E') ? (
                      <>
                        <div className="flex items-start gap-3 p-3 bg-orange-50 rounded-lg">
                          <UsersIcon className="h-5 w-5 text-orange-500 mt-0.5" />
                          <div>
                            <div className="font-medium">네트워킹 활동</div>
                            <div className="text-sm text-gray-600">새로운 사람들과의 만남을 통해 에너지 충전</div>
                          </div>
                        </div>
                        <div className="flex items-start gap-3 p-3 bg-green-50 rounded-lg">
                          <CheckCircleIcon className="h-5 w-5 text-green-500 mt-0.5" />
                          <div>
                            <div className="font-medium">팀 프로젝트 참여</div>
                            <div className="text-sm text-gray-600">협업을 통한 목표 달성에 집중</div>
                          </div>
                        </div>
                      </>
                    ) : (
                      <>
                        <div className="flex items-start gap-3 p-3 bg-blue-50 rounded-lg">
                          <BrainIcon className="h-5 w-5 text-blue-500 mt-0.5" />
                          <div>
                            <div className="font-medium">개인 시간 확보</div>
                            <div className="text-sm text-gray-600">혼자만의 시간을 통해 내면 성찰</div>
                          </div>
                        </div>
                        <div className="flex items-start gap-3 p-3 bg-purple-50 rounded-lg">
                          <CheckCircleIcon className="h-5 w-5 text-purple-500 mt-0.5" />
                          <div>
                            <div className="font-medium">계획 수립</div>
                            <div className="text-sm text-gray-600">체계적인 목표 설정과 실행 계획 마련</div>
                          </div>
                        </div>
                      </>
                    )}
                    
                    <div className="flex items-start gap-3 p-3 bg-indigo-50 rounded-lg">
                      <AlertCircleIcon className="h-5 w-5 text-indigo-500 mt-0.5" />
                      <div>
                        <div className="font-medium">균형 잡기</div>
                        <div className="text-sm text-gray-600">강점을 살리되 약점도 보완하는 시간</div>
                      </div>
                    </div>
                  </div>
                </CardContent>
              </Card>
            </motion.div>

            {/* 주간 행운 포인트 */}
            <motion.div variants={itemVariants}>
              <Card>
                <CardHeader>
                  <CardTitle className="flex items-center gap-2">
                    <StarIcon className="h-5 w-5 text-yellow-500" />
                    이번 주 행운 포인트
                  </CardTitle>
                </CardHeader>
                <CardContent>
                  <div className="grid grid-cols-2 gap-4">
                    <div className="text-center p-3 bg-yellow-50 rounded-lg">
                      <div className="text-sm font-medium text-yellow-800">행운의 요일</div>
                      <div className="text-lg font-bold text-yellow-600">수요일</div>
                    </div>
                    <div className="text-center p-3 bg-green-50 rounded-lg">
                      <div className="text-sm font-medium text-green-800">행운의 색상</div>
                      <div className="text-lg font-bold text-green-600">
                        {MBTI_TYPES[selectedMBTI as keyof typeof MBTI_TYPES]?.color === 'purple' ? '보라색' : 
                         MBTI_TYPES[selectedMBTI as keyof typeof MBTI_TYPES]?.color === 'blue' ? '파란색' : '초록색'}
                      </div>
                    </div>
                    <div className="text-center p-3 bg-purple-50 rounded-lg">
                      <div className="text-sm font-medium text-purple-800">행운의 숫자</div>
                      <div className="text-lg font-bold text-purple-600">7</div>
                    </div>
                    <div className="text-center p-3 bg-blue-50 rounded-lg">
                      <div className="text-sm font-medium text-blue-800">행운의 키워드</div>
                      <div className="text-lg font-bold text-blue-600">소통</div>
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