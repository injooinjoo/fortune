"use client";

import { useState } from "react";
import { motion } from "framer-motion";
import AppHeader from "@/components/AppHeader";
import { Progress } from "@/components/ui/progress";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import {
  BriefcaseIcon,
  Sparkles,
  StarIcon,
  CheckCircleIcon
} from "lucide-react";

export default function LuckyJobPage() {
  const [selectedTab, setSelectedTab] = useState("today");

  const todayScore = 88;
  const weekScore = 92;
  const monthScore = 85;

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

  const jobRecommendations = [
    { level: "최고", field: "데이터 분석", score: 95, color: "green" },
    { level: "좋음", field: "UX/UI 디자인", score: 90, color: "blue" },
    { level: "양호", field: "마케팅 전략", score: 82, color: "purple" },
    { level: "도전", field: "창업", score: 70, color: "orange" }
  ];

  return (
    <div className="min-h-screen bg-gradient-to-br from-teal-50 via-cyan-50 to-emerald-50">
      <AppHeader title="행운의 직업" />

      <motion.div
        className="container mx-auto px-4 pt-4 pb-20"
        variants={containerVariants}
        initial="hidden"
        animate="visible"
      >
        {/* 헤더 섹션 */}
        <motion.div variants={itemVariants} className="text-center mb-8">
          <div className="flex items-center justify-center gap-2 mb-4">
            <BriefcaseIcon className="h-8 w-8 text-teal-600" />
            <h1 className="text-3xl font-bold bg-gradient-to-r from-teal-600 to-emerald-600 bg-clip-text text-transparent">
              행운의 직업
            </h1>
          </div>
          <p className="text-gray-600">
            사주를 기반으로 성공 가능성이 높은 직업 분야를 알려드립니다
          </p>
        </motion.div>

        {/* 오늘의 적합도 점수 */}
        <motion.div variants={itemVariants}>
          <Card className="mb-6 border-teal-200 bg-gradient-to-r from-teal-50 to-cyan-50">
            <CardHeader className="text-center">
              <CardTitle className="flex items-center justify-center gap-2 text-teal-700">
                <Sparkles className="h-5 w-5" />
                오늘의 적합도
              </CardTitle>
            </CardHeader>
            <CardContent className="text-center">
              <div className="text-4xl font-bold text-teal-600 mb-2">{todayScore}점</div>
              <Progress value={todayScore} className="mb-4" />
              <p className="text-sm text-gray-600">새로운 도전을 시작하기 좋은 날입니다</p>
            </CardContent>
          </Card>
        </motion.div>

        {/* 기간별 점수 */}
        <motion.div variants={itemVariants}>
          <Card className="mb-6">
            <CardHeader>
              <CardTitle className="text-center">기간별 적합도</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="grid grid-cols-3 gap-4">
                <div className="text-center">
                  <div className="text-2xl font-bold text-teal-600">{todayScore}</div>
                  <div className="text-sm text-gray-500">오늘</div>
                </div>
                <div className="text-center">
                  <div className="text-2xl font-bold text-cyan-600">{weekScore}</div>
                  <div className="text-sm text-gray-500">이번 주</div>
                </div>
                <div className="text-center">
                  <div className="text-2xl font-bold text-emerald-600">{monthScore}</div>
                  <div className="text-sm text-gray-500">이번 달</div>
                </div>
              </div>
            </CardContent>
          </Card>
        </motion.div>

        {/* 추천 직업 분야 */}
        <motion.div variants={itemVariants}>
          <Card className="mb-6">
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <StarIcon className="h-5 w-5 text-yellow-500" />
                추천 직업 분야
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-3">
                {jobRecommendations.map((job) => (
                  <div
                    key={job.field}
                    className={`flex items-center justify-between p-3 bg-${job.color}-50 rounded-lg`}
                  >
                    <div className="flex items-center gap-2">
                      <Badge variant="outline" className={`bg-${job.color}-100 text-${job.color}-700`}>{job.level}</Badge>
                      <span className="font-medium">{job.field}</span>
                    </div>
                    <div className={`text-${job.color}-600 font-bold`}>{job.score}점</div>
                  </div>
                ))}
              </div>
            </CardContent>
          </Card>
        </motion.div>

        {/* 개인화된 조언 */}
        <motion.div variants={itemVariants}>
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <CheckCircleIcon className="h-5 w-5 text-green-600" />
                개인화된 조언
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-2 text-sm text-gray-600">
                <p>사주의 오행 중 목(木)의 기운이 강하니 창의성과 소통 능력을 살리는 직업이 잘 맞습니다.</p>
                <p>꾸준한 학습과 네트워킹을 통해 전문성을 키우면 큰 성공을 기대할 수 있습니다.</p>
              </div>
            </CardContent>
          </Card>
        </motion.div>
      </motion.div>
    </div>
  );
}
