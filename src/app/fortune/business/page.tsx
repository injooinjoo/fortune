"use client";

import { useState } from "react";
import { motion } from "framer-motion";
import AppHeader from "@/components/AppHeader";
import { Progress } from "@/components/ui/progress";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { 
  Building2Icon, 
  TrendingUpIcon, 
  StarIcon, 
  ClockIcon, 
  MapPinIcon, 
  UserIcon,
  CheckCircleIcon,
  AlertCircleIcon,
  DollarSignIcon,
  HandshakeIcon,
  BarChart3Icon,
  BriefcaseIcon
} from "lucide-react";

export default function BusinessFortunePage() {
  const [selectedTab, setSelectedTab] = useState("today");
  const [fontSize, setFontSize] = useState<'small' | 'medium' | 'large'>('medium');

  const todayScore = 85;
  const weekScore = 78;
  const monthScore = 88;

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
    <div className="min-h-screen bg-gradient-to-br from-emerald-50 via-white to-teal-50 dark:from-gray-900 dark:via-gray-800 dark:to-gray-900">
      <AppHeader 
        title="사업운" 
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
            <Building2Icon className="h-8 w-8 text-emerald-600 dark:text-emerald-400" />
            <h1 className="text-3xl font-bold bg-gradient-to-r from-emerald-600 to-teal-600 dark:from-emerald-400 dark:to-teal-400 bg-clip-text text-transparent">
              사업운
            </h1>
          </div>
          <p className="text-gray-600 dark:text-gray-300">
            당신의 사업 성공과 투자 기회를 확인해보세요
          </p>
        </motion.div>

        {/* 오늘의 사업운 점수 */}
        <motion.div variants={itemVariants}>
          <Card className="mb-6 border-emerald-200 dark:border-emerald-800 bg-gradient-to-r from-emerald-50 to-teal-50 dark:from-emerald-900/20 dark:to-teal-900/20">
            <CardHeader className="text-center">
              <CardTitle className="flex items-center justify-center gap-2 text-emerald-700 dark:text-emerald-300">
                <TrendingUpIcon className="h-5 w-5" />
                오늘의 사업운
              </CardTitle>
            </CardHeader>
            <CardContent className="text-center">
              <div className="text-4xl font-bold text-emerald-600 dark:text-emerald-400 mb-2">{todayScore}점</div>
              <Progress value={todayScore} className="mb-4" />
              <p className="text-sm text-gray-600 dark:text-gray-300">
                새로운 사업 기회가 찾아올 가능성이 높은 날입니다
              </p>
            </CardContent>
          </Card>
        </motion.div>

        {/* 기간별 점수 */}
        <motion.div variants={itemVariants}>
          <Card className="mb-6 bg-white/80 dark:bg-gray-800/80 backdrop-blur-sm border-gray-200 dark:border-gray-700">
            <CardHeader>
              <CardTitle className="text-center text-gray-900 dark:text-gray-100">기간별 사업운</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="grid grid-cols-3 gap-4">
                <div className="text-center">
                  <div className="text-2xl font-bold text-emerald-600 dark:text-emerald-400">{todayScore}</div>
                  <div className="text-sm text-gray-500 dark:text-gray-400">오늘</div>
                </div>
                <div className="text-center">
                  <div className="text-2xl font-bold text-teal-600 dark:text-teal-400">{weekScore}</div>
                  <div className="text-sm text-gray-500 dark:text-gray-400">이번 주</div>
                </div>
                <div className="text-center">
                  <div className="text-2xl font-bold text-cyan-600 dark:text-cyan-400">{monthScore}</div>
                  <div className="text-sm text-gray-500 dark:text-gray-400">이번 달</div>
                </div>
              </div>
            </CardContent>
          </Card>
        </motion.div>

        {/* 행운의 정보 */}
        <motion.div variants={itemVariants}>
          <Card className="mb-6 bg-white/80 dark:bg-gray-800/80 backdrop-blur-sm border-gray-200 dark:border-gray-700">
            <CardHeader>
              <CardTitle className="flex items-center gap-2 text-gray-900 dark:text-gray-100">
                <StarIcon className="h-5 w-5 text-yellow-500" />
                행운의 정보
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="grid grid-cols-2 gap-4">
                <div className="flex items-center gap-2">
                  <ClockIcon className="h-4 w-4 text-emerald-500 dark:text-emerald-400" />
                  <div>
                    <div className="text-sm font-medium text-gray-900 dark:text-gray-100">행운의 시간</div>
                    <div className="text-sm text-gray-600 dark:text-gray-300">오전 10-12시</div>
                  </div>
                </div>
                <div className="flex items-center gap-2">
                  <MapPinIcon className="h-4 w-4 text-teal-500 dark:text-teal-400" />
                  <div>
                    <div className="text-sm font-medium text-gray-900 dark:text-gray-100">행운의 장소</div>
                    <div className="text-sm text-gray-600 dark:text-gray-300">오피스, 회의실</div>
                  </div>
                </div>
                <div className="flex items-center gap-2">
                  <div className="h-4 w-4 bg-emerald-500 dark:bg-emerald-400 rounded-full"></div>
                  <div>
                    <div className="text-sm font-medium text-gray-900 dark:text-gray-100">행운의 색상</div>
                    <div className="text-sm text-gray-600 dark:text-gray-300">에메랄드, 골드</div>
                  </div>
                </div>
                <div className="flex items-center gap-2">
                  <UserIcon className="h-4 w-4 text-cyan-500 dark:text-cyan-400" />
                  <div>
                    <div className="text-sm font-medium text-gray-900 dark:text-gray-100">도움이 되는 사람</div>
                    <div className="text-sm text-gray-600 dark:text-gray-300">투자자, 파트너</div>
                  </div>
                </div>
              </div>
            </CardContent>
          </Card>
        </motion.div>

        {/* 업종별 운세 */}
        <motion.div variants={itemVariants}>
          <Card className="mb-6 bg-white/80 dark:bg-gray-800/80 backdrop-blur-sm border-gray-200 dark:border-gray-700">
            <CardHeader>
              <CardTitle className="flex items-center gap-2 text-gray-900 dark:text-gray-100">
                <BarChart3Icon className="h-5 w-5 text-gray-600 dark:text-gray-400" />
                업종별 운세
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-3">
                <div className="flex items-center justify-between p-3 bg-green-50 dark:bg-green-900/20 rounded-lg border border-green-200 dark:border-green-800">
                  <div className="flex items-center gap-2">
                    <Badge variant="outline" className="bg-green-100 dark:bg-green-900/40 text-green-700 dark:text-green-300 border-green-300 dark:border-green-700">최고</Badge>
                    <span className="font-medium text-gray-900 dark:text-gray-100">IT/테크</span>
                  </div>
                  <div className="text-green-600 dark:text-green-400 font-bold">92점</div>
                </div>
                <div className="flex items-center justify-between p-3 bg-blue-50 dark:bg-blue-900/20 rounded-lg border border-blue-200 dark:border-blue-800">
                  <div className="flex items-center gap-2">
                    <Badge variant="outline" className="bg-blue-100 dark:bg-blue-900/40 text-blue-700 dark:text-blue-300 border-blue-300 dark:border-blue-700">좋음</Badge>
                    <span className="font-medium text-gray-900 dark:text-gray-100">금융/투자</span>
                  </div>
                  <div className="text-blue-600 dark:text-blue-400 font-bold">85점</div>
                </div>
                <div className="flex items-center justify-between p-3 bg-purple-50 dark:bg-purple-900/20 rounded-lg border border-purple-200 dark:border-purple-800">
                  <div className="flex items-center gap-2">
                    <Badge variant="outline" className="bg-purple-100 dark:bg-purple-900/40 text-purple-700 dark:text-purple-300 border-purple-300 dark:border-purple-700">좋음</Badge>
                    <span className="font-medium text-gray-900 dark:text-gray-100">유통/서비스</span>
                  </div>
                  <div className="text-purple-600 dark:text-purple-400 font-bold">78점</div>
                </div>
                <div className="flex items-center justify-between p-3 bg-yellow-50 dark:bg-yellow-900/20 rounded-lg border border-yellow-200 dark:border-yellow-800">
                  <div className="flex items-center gap-2">
                    <Badge variant="outline" className="bg-yellow-100 dark:bg-yellow-900/40 text-yellow-700 dark:text-yellow-300 border-yellow-300 dark:border-yellow-700">보통</Badge>
                    <span className="font-medium text-gray-900 dark:text-gray-100">제조업</span>
                  </div>
                  <div className="text-yellow-600 dark:text-yellow-400 font-bold">68점</div>
                </div>
              </div>
            </CardContent>
          </Card>
        </motion.div>

        {/* 투자 조언 */}
        <motion.div variants={itemVariants}>
          <Card className="mb-6 bg-white/80 dark:bg-gray-800/80 backdrop-blur-sm border-gray-200 dark:border-gray-700">
            <CardHeader>
              <CardTitle className="flex items-center gap-2 text-gray-900 dark:text-gray-100">
                <DollarSignIcon className="h-5 w-5 text-green-500" />
                투자 조언
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="p-4 bg-emerald-50 dark:bg-emerald-900/20 rounded-lg border border-emerald-200 dark:border-emerald-800">
                <div className="flex items-center gap-2 mb-2">
                  <CheckCircleIcon className="h-4 w-4 text-emerald-600 dark:text-emerald-400" />
                  <span className="font-medium text-emerald-800 dark:text-emerald-200">추천 투자</span>
                </div>
                <p className="text-sm text-emerald-700 dark:text-emerald-300">
                  장기적 관점에서 안정적인 수익을 기대할 수 있는 투자가 좋습니다. 
                  특히 기술 관련 분야나 친환경 사업에 주목하세요.
                </p>
              </div>
              <div className="p-4 bg-red-50 dark:bg-red-900/20 rounded-lg border border-red-200 dark:border-red-800">
                <div className="flex items-center gap-2 mb-2">
                  <AlertCircleIcon className="h-4 w-4 text-red-600 dark:text-red-400" />
                  <span className="font-medium text-red-800 dark:text-red-200">주의사항</span>
                </div>
                <p className="text-sm text-red-700 dark:text-red-300">
                  성급한 투자 결정은 피하고, 충분한 시장 조사와 전문가 상담을 받으세요. 
                  리스크 관리를 철저히 하는 것이 중요합니다.
                </p>
              </div>
            </CardContent>
          </Card>
        </motion.div>

        {/* 사업 파트너십 */}
        <motion.div variants={itemVariants}>
          <Card className="bg-white/80 dark:bg-gray-800/80 backdrop-blur-sm border-gray-200 dark:border-gray-700">
            <CardHeader>
              <CardTitle className="flex items-center gap-2 text-gray-900 dark:text-gray-100">
                <HandshakeIcon className="h-5 w-5 text-blue-500" />
                파트너십 운세
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                <div className="text-center">
                  <div className="text-2xl font-bold text-blue-600 dark:text-blue-400 mb-2">83점</div>
                  <p className="text-sm text-gray-600 dark:text-gray-300">
                    새로운 비즈니스 파트너와의 만남이 기대됩니다
                  </p>
                </div>
                <div className="grid grid-cols-2 gap-4 mt-4">
                  <div className="text-center p-3 bg-blue-50 dark:bg-blue-900/20 rounded-lg border border-blue-200 dark:border-blue-800">
                    <div className="text-sm font-medium text-blue-800 dark:text-blue-200">좋은 파트너</div>
                    <div className="text-xs text-blue-600 dark:text-blue-300 mt-1">경험 많은 선배</div>
                  </div>
                  <div className="text-center p-3 bg-purple-50 dark:bg-purple-900/20 rounded-lg border border-purple-200 dark:border-purple-800">
                    <div className="text-sm font-medium text-purple-800 dark:text-purple-200">주의할 파트너</div>
                    <div className="text-xs text-purple-600 dark:text-purple-300 mt-1">성급한 성격</div>
                  </div>
                </div>
              </div>
            </CardContent>
          </Card>
        </motion.div>
      </motion.div>
    </div>
  );
} 