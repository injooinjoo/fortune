"use client";

import { useState } from "react";
import { motion } from "framer-motion";
import AppHeader from "@/components/AppHeader";
import { Progress } from "@/components/ui/progress";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { 
  BriefcaseIcon, 
  TrendingUpIcon, 
  StarIcon, 
  ClockIcon, 
  MapPinIcon, 
  UserIcon,
  CheckCircleIcon,
  AlertCircleIcon,
  BuildingIcon,
  GraduationCapIcon
} from "lucide-react";

export default function CareerFortunePage() {
  const [selectedTab, setSelectedTab] = useState("today");

  const todayScore = 78;
  const weekScore = 82;
  const monthScore = 75;

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
              취업운
            </h1>
          </div>
          <p className="text-gray-600">
            당신의 커리어 발전과 취업 기회를 확인해보세요
          </p>
        </motion.div>

        {/* 오늘의 취업운 점수 */}
        <motion.div variants={itemVariants}>
          <Card className="mb-6 border-blue-200 bg-gradient-to-r from-blue-50 to-indigo-50">
            <CardHeader className="text-center">
              <CardTitle className="flex items-center justify-center gap-2 text-blue-700">
                <TrendingUpIcon className="h-5 w-5" />
                오늘의 취업운
              </CardTitle>
            </CardHeader>
            <CardContent className="text-center">
              <div className="text-4xl font-bold text-blue-600 mb-2">{todayScore}점</div>
              <Progress value={todayScore} className="mb-4" />
              <p className="text-sm text-gray-600">
                새로운 기회가 찾아올 가능성이 높은 날입니다
              </p>
            </CardContent>
          </Card>
        </motion.div>

        {/* 기간별 점수 */}
        <motion.div variants={itemVariants}>
          <Card className="mb-6">
            <CardHeader>
              <CardTitle className="text-center">기간별 취업운</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="grid grid-cols-3 gap-4">
                <div className="text-center">
                  <div className="text-2xl font-bold text-blue-600">{todayScore}</div>
                  <div className="text-sm text-gray-500">오늘</div>
                </div>
                <div className="text-center">
                  <div className="text-2xl font-bold text-indigo-600">{weekScore}</div>
                  <div className="text-sm text-gray-500">이번 주</div>
                </div>
                <div className="text-center">
                  <div className="text-2xl font-bold text-purple-600">{monthScore}</div>
                  <div className="text-sm text-gray-500">이번 달</div>
                </div>
              </div>
            </CardContent>
          </Card>
        </motion.div>

        {/* 행운의 정보 */}
        <motion.div variants={itemVariants}>
          <Card className="mb-6">
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <StarIcon className="h-5 w-5 text-yellow-500" />
                행운의 정보
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="grid grid-cols-2 gap-4">
                <div className="flex items-center gap-2">
                  <ClockIcon className="h-4 w-4 text-blue-500" />
                  <div>
                    <div className="text-sm font-medium">행운의 시간</div>
                    <div className="text-sm text-gray-600">오후 2-4시</div>
                  </div>
                </div>
                <div className="flex items-center gap-2">
                  <MapPinIcon className="h-4 w-4 text-green-500" />
                  <div>
                    <div className="text-sm font-medium">행운의 장소</div>
                    <div className="text-sm text-gray-600">카페, 도서관</div>
                  </div>
                </div>
                <div className="flex items-center gap-2">
                  <div className="h-4 w-4 bg-blue-500 rounded-full"></div>
                  <div>
                    <div className="text-sm font-medium">행운의 색상</div>
                    <div className="text-sm text-gray-600">네이비, 화이트</div>
                  </div>
                </div>
                <div className="flex items-center gap-2">
                  <UserIcon className="h-4 w-4 text-purple-500" />
                  <div>
                    <div className="text-sm font-medium">도움이 되는 사람</div>
                    <div className="text-sm text-gray-600">선배, 멘토</div>
                  </div>
                </div>
              </div>
            </CardContent>
          </Card>
        </motion.div>

        {/* 업계별 운세 */}
        <motion.div variants={itemVariants}>
          <Card className="mb-6">
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <BuildingIcon className="h-5 w-5 text-gray-600" />
                업계별 운세
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-3">
                <div className="flex items-center justify-between p-3 bg-green-50 rounded-lg">
                  <div className="flex items-center gap-2">
                    <Badge variant="outline" className="bg-green-100 text-green-700">최고</Badge>
                    <span className="font-medium">IT/소프트웨어</span>
                  </div>
                  <div className="text-green-600 font-bold">95점</div>
                </div>
                <div className="flex items-center justify-between p-3 bg-blue-50 rounded-lg">
                  <div className="flex items-center gap-2">
                    <Badge variant="outline" className="bg-blue-100 text-blue-700">좋음</Badge>
                    <span className="font-medium">금융/보험</span>
                  </div>
                  <div className="text-blue-600 font-bold">88점</div>
                </div>
                <div className="flex items-center justify-between p-3 bg-purple-50 rounded-lg">
                  <div className="flex items-center gap-2">
                    <Badge variant="outline" className="bg-purple-100 text-purple-700">좋음</Badge>
                    <span className="font-medium">교육/연구</span>
                  </div>
                  <div className="text-purple-600 font-bold">82점</div>
                </div>
                <div className="flex items-center justify-between p-3 bg-yellow-50 rounded-lg">
                  <div className="flex items-center gap-2">
                    <Badge variant="outline" className="bg-yellow-100 text-yellow-700">보통</Badge>
                    <span className="font-medium">제조/생산</span>
                  </div>
                  <div className="text-yellow-600 font-bold">65점</div>
                </div>
              </div>
            </CardContent>
          </Card>
        </motion.div>

        {/* 기간별 예측 */}
        <motion.div variants={itemVariants}>
          <Card className="mb-6">
            <CardHeader>
              <CardTitle>기간별 취업운 예측</CardTitle>
            </CardHeader>
            <CardContent>
              <Tabs value={selectedTab} onValueChange={setSelectedTab}>
                <TabsList className="grid w-full grid-cols-3">
                  <TabsTrigger value="today">오늘</TabsTrigger>
                  <TabsTrigger value="week">이번 주</TabsTrigger>
                  <TabsTrigger value="month">이번 달</TabsTrigger>
                </TabsList>
                
                <TabsContent value="today" className="mt-4">
                  <div className="space-y-3">
                    <p className="text-sm text-gray-600">
                      오늘은 새로운 기회를 포착하기에 좋은 날입니다. 
                      네트워킹 활동이나 이력서 작성에 집중해보세요.
                    </p>
                    <div className="bg-blue-50 p-3 rounded-lg">
                      <div className="font-medium text-blue-800 mb-1">추천 활동</div>
                      <div className="text-sm text-blue-600">
                        • 채용 공고 검색 및 지원<br/>
                        • 포트폴리오 업데이트<br/>
                        • 업계 전문가와의 네트워킹
                      </div>
                    </div>
                  </div>
                </TabsContent>
                
                <TabsContent value="week" className="mt-4">
                  <div className="space-y-3">
                    <p className="text-sm text-gray-600">
                      이번 주는 면접 기회가 늘어날 가능성이 높습니다. 
                      철저한 준비와 자신감을 가지고 임하세요.
                    </p>
                    <div className="bg-indigo-50 p-3 rounded-lg">
                      <div className="font-medium text-indigo-800 mb-1">주요 포인트</div>
                      <div className="text-sm text-indigo-600">
                        • 면접 준비에 집중<br/>
                        • 기술 스택 업그레이드<br/>
                        • 추천서 요청 고려
                      </div>
                    </div>
                  </div>
                </TabsContent>
                
                <TabsContent value="month" className="mt-4">
                  <div className="space-y-3">
                    <p className="text-sm text-gray-600">
                      이번 달은 장기적인 커리어 계획을 세우기에 적합한 시기입니다. 
                      새로운 분야로의 도전을 고려해보세요.
                    </p>
                    <div className="bg-purple-50 p-3 rounded-lg">
                      <div className="font-medium text-purple-800 mb-1">장기 전략</div>
                      <div className="text-sm text-purple-600">
                        • 새로운 기술 학습<br/>
                        • 자격증 취득 계획<br/>
                        • 커리어 멘토링 참여
                      </div>
                    </div>
                  </div>
                </TabsContent>
              </Tabs>
            </CardContent>
          </Card>
        </motion.div>

        {/* 개인화된 조언 */}
        <motion.div variants={itemVariants}>
          <Card className="mb-6">
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <GraduationCapIcon className="h-5 w-5 text-blue-600" />
                개인화된 조언
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                <div className="bg-gradient-to-r from-blue-50 to-indigo-50 p-4 rounded-lg">
                  <h4 className="font-medium text-blue-800 mb-2">커리어 발전 방향</h4>
                  <p className="text-sm text-blue-700">
                    현재 시점에서는 전문성을 깊이 있게 발전시키는 것이 중요합니다. 
                    특히 디지털 역량 강화에 집중하면 더 많은 기회를 얻을 수 있을 것입니다.
                  </p>
                </div>
                
                <div className="bg-gradient-to-r from-green-50 to-emerald-50 p-4 rounded-lg">
                  <h4 className="font-medium text-green-800 mb-2">면접 성공 팁</h4>
                  <p className="text-sm text-green-700">
                    자신의 경험을 구체적인 사례로 설명하고, 
                    해당 기업의 문화와 가치관에 대한 이해를 보여주세요. 
                    열정과 성장 의지를 어필하는 것이 중요합니다.
                  </p>
                </div>
              </div>
            </CardContent>
          </Card>
        </motion.div>

        {/* 실천 항목 */}
        <motion.div variants={itemVariants}>
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <CheckCircleIcon className="h-5 w-5 text-green-600" />
                오늘의 실천 항목
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-3">
                <div className="flex items-start gap-3 p-3 bg-gray-50 rounded-lg">
                  <CheckCircleIcon className="h-5 w-5 text-green-500 mt-0.5" />
                  <div>
                    <div className="font-medium">이력서 및 포트폴리오 점검</div>
                    <div className="text-sm text-gray-600">최신 경험과 기술을 반영하여 업데이트</div>
                  </div>
                </div>
                
                <div className="flex items-start gap-3 p-3 bg-gray-50 rounded-lg">
                  <AlertCircleIcon className="h-5 w-5 text-blue-500 mt-0.5" />
                  <div>
                    <div className="font-medium">업계 동향 파악</div>
                    <div className="text-sm text-gray-600">관심 분야의 최신 트렌드와 요구사항 조사</div>
                  </div>
                </div>
                
                <div className="flex items-start gap-3 p-3 bg-gray-50 rounded-lg">
                  <UserIcon className="h-5 w-5 text-purple-500 mt-0.5" />
                  <div>
                    <div className="font-medium">네트워킹 활동</div>
                    <div className="text-sm text-gray-600">업계 전문가나 선배와의 만남 주선</div>
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