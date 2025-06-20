"use client";

import { useState } from "react";
import { motion } from "framer-motion";
import AppHeader from "@/components/AppHeader";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Progress } from "@/components/ui/progress";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Badge } from "@/components/ui/badge";
import {
  BriefcaseIcon,
  CalendarIcon,
  BuildingIcon,
  StarIcon
} from "lucide-react";

export default function EmploymentFortunePage() {
  const [season, setSeason] = useState("secondHalf");

  const firstHalfScore = 78;
  const secondHalfScore = 85;
  const nextYearScore = 80;

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

  const score =
    season === "firstHalf" ? firstHalfScore : season === "secondHalf" ? secondHalfScore : nextYearScore;

  const seasonLabel =
    season === "firstHalf" ? "2024 상반기" : season === "secondHalf" ? "2024 하반기" : "2025 상반기";

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 via-indigo-50 to-purple-50">
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
            <BriefcaseIcon className="h-8 w-8 text-blue-600" />
            <h1 className="text-3xl font-bold bg-gradient-to-r from-blue-600 to-purple-600 bg-clip-text text-transparent">
              취업 운세
            </h1>
          </div>
          <p className="text-gray-600">특정 채용 시즌에 맞춘 사주 기반 취업 운세를 확인하세요</p>
        </motion.div>

        {/* 시즌별 점수 */}
        <motion.div variants={itemVariants} className="mb-6">
          <Card className="border-blue-200 bg-gradient-to-r from-blue-50 to-indigo-50">
            <CardHeader className="text-center">
              <CardTitle className="flex items-center justify-center gap-2 text-blue-700">
                <CalendarIcon className="h-5 w-5" />
                {seasonLabel} 운세
              </CardTitle>
            </CardHeader>
            <CardContent className="text-center">
              <div className="text-4xl font-bold text-blue-600 mb-2">{score}점</div>
              <Progress value={score} className="mb-4" />
              <p className="text-sm text-gray-600">취업 기회가 비교적 높은 시기입니다</p>
            </CardContent>
          </Card>
        </motion.div>

        {/* 시즌별 상세 조언 */}
        <motion.div variants={itemVariants} className="mb-6">
          <Card>
            <CardHeader>
              <CardTitle>시즌별 취업운</CardTitle>
            </CardHeader>
            <CardContent>
              <Tabs value={season} onValueChange={setSeason} className="w-full">
                <TabsList className="grid w-full grid-cols-3">
                  <TabsTrigger value="firstHalf">상반기</TabsTrigger>
                  <TabsTrigger value="secondHalf">하반기</TabsTrigger>
                  <TabsTrigger value="nextYear">내년 상반기</TabsTrigger>
                </TabsList>

                <TabsContent value="firstHalf" className="mt-4 space-y-3 text-sm text-gray-600">
                  <p>상반기는 새로운 시작의 기운이 강해 적극적인 구직 활동이 유리합니다.</p>
                  <div className="bg-blue-50 p-3 rounded-lg">
                    • 이력서 업데이트
                    <br />• 포트폴리오 정비
                    <br />• 업계 네트워킹 강화
                  </div>
                </TabsContent>

                <TabsContent value="secondHalf" className="mt-4 space-y-3 text-sm text-gray-600">
                  <p>하반기는 대규모 공채가 많아 면접 기회가 늘어납니다. 철저한 준비가 필요합니다.</p>
                  <div className="bg-indigo-50 p-3 rounded-lg">
                    • 모의 면접 참여
                    <br />• 기업 분석 강화
                    <br />• 추천서 준비
                  </div>
                </TabsContent>

                <TabsContent value="nextYear" className="mt-4 space-y-3 text-sm text-gray-600">
                  <p>내년 상반기는 새로운 환경에 도전하기 좋은 때입니다. 장기 계획을 세워보세요.</p>
                  <div className="bg-purple-50 p-3 rounded-lg">
                    • 자격증 취득
                    <br />• 전문성 향상 학습
                    <br />• 멘토링 프로그램 참여
                  </div>
                </TabsContent>
              </Tabs>
            </CardContent>
          </Card>
        </motion.div>

        {/* 회사 유형 */}
        <motion.div variants={itemVariants} className="mb-6">
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <BuildingIcon className="h-5 w-5 text-gray-600" />
                합격 가능성이 높은 회사 유형
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-3">
                <div className="flex items-center justify-between p-3 bg-green-50 rounded-lg">
                  <span className="font-medium">IT 스타트업</span>
                  <Badge variant="outline" className="bg-green-100 text-green-700">도전적</Badge>
                </div>
                <div className="flex items-center justify-between p-3 bg-blue-50 rounded-lg">
                  <span className="font-medium">공기업/공공기관</span>
                  <Badge variant="outline" className="bg-blue-100 text-blue-700">안정적</Badge>
                </div>
                <div className="flex items-center justify-between p-3 bg-purple-50 rounded-lg">
                  <span className="font-medium">대기업</span>
                  <Badge variant="outline" className="bg-purple-100 text-purple-700">경쟁적</Badge>
                </div>
              </div>
            </CardContent>
          </Card>
        </motion.div>

        {/* 면접에 유리한 날짜 */}
        <motion.div variants={itemVariants}>
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <StarIcon className="h-5 w-5 text-yellow-500" />
                면접에 유리한 날짜
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="grid grid-cols-3 gap-4 text-center">
                <div>
                  <div className="font-bold text-blue-600">9/10</div>
                  <div className="text-sm text-gray-500">긍정적</div>
                </div>
                <div>
                  <div className="font-bold text-blue-600">9/18</div>
                  <div className="text-sm text-gray-500">호조</div>
                </div>
                <div>
                  <div className="font-bold text-blue-600">9/27</div>
                  <div className="text-sm text-gray-500">성장운</div>
                </div>
              </div>
            </CardContent>
          </Card>
        </motion.div>
      </motion.div>
    </div>
  );
}

