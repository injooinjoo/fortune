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
  StarIcon,
  ClockIcon,
  MapPinIcon,
  UserIcon,
  CheckCircleIcon,
  AlertCircleIcon,
  DollarSignIcon,
  SparklesIcon
} from "lucide-react";

export default function LuckySideJobPage() {
  const [selectedTab, setSelectedTab] = useState("today");

  const todayScore = 80;
  const weekScore = 88;
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
    <div className="min-h-screen bg-gradient-to-br from-yellow-50 via-orange-50 to-amber-50">
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
            <BriefcaseIcon className="h-8 w-8 text-yellow-600" />
            <h1 className="text-3xl font-bold bg-gradient-to-r from-yellow-600 to-orange-600 bg-clip-text text-transparent">
              행운의 부업
            </h1>
          </div>
          <p className="text-gray-600">
            재물운과 재능을 살펴 추가 수입의 기회를 알아보세요
          </p>
        </motion.div>

        {/* 오늘의 부업운 점수 */}
        <motion.div variants={itemVariants}>
          <Card className="mb-6 border-yellow-200 bg-gradient-to-r from-yellow-50 to-orange-50">
            <CardHeader className="text-center">
              <CardTitle className="flex items-center justify-center gap-2 text-yellow-700">
                <DollarSignIcon className="h-5 w-5" />
                오늘의 부업운
              </CardTitle>
            </CardHeader>
            <CardContent className="text-center">
              <div className="text-4xl font-bold text-yellow-600 mb-2">{todayScore}점</div>
              <Progress value={todayScore} className="mb-4" />
              <p className="text-sm text-gray-600">
                새로운 수입 아이디어가 떠오르기 좋은 날입니다
              </p>
            </CardContent>
          </Card>
        </motion.div>

        {/* 기간별 점수 */}
        <motion.div variants={itemVariants}>
          <Card className="mb-6">
            <CardHeader>
              <CardTitle className="text-center">기간별 부업운</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="grid grid-cols-3 gap-4">
                <div className="text-center">
                  <div className="text-2xl font-bold text-yellow-600">{todayScore}</div>
                  <div className="text-sm text-gray-500">오늘</div>
                </div>
                <div className="text-center">
                  <div className="text-2xl font-bold text-orange-600">{weekScore}</div>
                  <div className="text-sm text-gray-500">이번 주</div>
                </div>
                <div className="text-center">
                  <div className="text-2xl font-bold text-amber-600">{monthScore}</div>
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
                  <ClockIcon className="h-4 w-4 text-yellow-500" />
                  <div>
                    <div className="text-sm font-medium">행운의 시간</div>
                    <div className="text-sm text-gray-600">저녁 7-9시</div>
                  </div>
                </div>
                <div className="flex items-center gap-2">
                  <MapPinIcon className="h-4 w-4 text-green-500" />
                  <div>
                    <div className="text-sm font-medium">행운의 장소</div>
                    <div className="text-sm text-gray-600">온라인 플랫폼</div>
                  </div>
                </div>
                <div className="flex items-center gap-2">
                  <div className="h-4 w-4 bg-yellow-500 rounded-full"></div>
                  <div>
                    <div className="text-sm font-medium">행운의 색상</div>
                    <div className="text-sm text-gray-600">오렌지, 골드</div>
                  </div>
                </div>
                <div className="flex items-center gap-2">
                  <UserIcon className="h-4 w-4 text-orange-500" />
                  <div>
                    <div className="text-sm font-medium">도움이 되는 사람</div>
                    <div className="text-sm text-gray-600">친구, 동료</div>
                  </div>
                </div>
              </div>
            </CardContent>
          </Card>
        </motion.div>

        {/* 부업 분야별 운세 */}
        <motion.div variants={itemVariants}>
          <Card className="mb-6">
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <SparklesIcon className="h-5 w-5 text-gray-600" />
                추천 부업 분야
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-3">
                <div className="flex items-center justify-between p-3 bg-green-50 rounded-lg">
                  <div className="flex items-center gap-2">
                    <Badge variant="outline" className="bg-green-100 text-green-700">최고</Badge>
                    <span className="font-medium">온라인 마케팅</span>
                  </div>
                  <div className="text-green-600 font-bold">90점</div>
                </div>
                <div className="flex items-center justify-between p-3 bg-blue-50 rounded-lg">
                  <div className="flex items-center gap-2">
                    <Badge variant="outline" className="bg-blue-100 text-blue-700">좋음</Badge>
                    <span className="font-medium">콘텐츠 제작</span>
                  </div>
                  <div className="text-blue-600 font-bold">85점</div>
                </div>
                <div className="flex items-center justify-between p-3 bg-purple-50 rounded-lg">
                  <div className="flex items-center gap-2">
                    <Badge variant="outline" className="bg-purple-100 text-purple-700">보통</Badge>
                    <span className="font-medium">핸드메이드 판매</span>
                  </div>
                  <div className="text-purple-600 font-bold">70점</div>
                </div>
                <div className="flex items-center justify-between p-3 bg-red-50 rounded-lg">
                  <div className="flex items-center gap-2">
                    <Badge variant="outline" className="bg-red-100 text-red-700">주의</Badge>
                    <span className="font-medium">중고거래 리셀</span>
                  </div>
                  <div className="text-red-600 font-bold">60점</div>
                </div>
              </div>
            </CardContent>
          </Card>
        </motion.div>

        {/* 기간별 예측 */}
        <motion.div variants={itemVariants}>
          <Card className="mb-6">
            <CardHeader>
              <CardTitle>기간별 부업운 예측</CardTitle>
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
                      아이디어가 번뜩이는 날입니다. 준비에 집중하면 좋은 결과로 이어질 수 있습니다.
                    </p>
                    <div className="bg-yellow-50 p-3 rounded-lg">
                      <div className="font-medium text-yellow-800 mb-1">주의사항</div>
                      <div className="text-sm text-yellow-600">
                        • 즉흥적인 지출 자제<br/>
                        • 계획 없는 투입 금지<br/>
                        • 타임라인 점검
                      </div>
                    </div>
                  </div>
                </TabsContent>

                <TabsContent value="week" className="mt-4">
                  <div className="space-y-3">
                    <p className="text-sm text-gray-600">
                      주변에서 다양한 부업 제안이 들어올 수 있는 시기입니다. 네트워크를 적극 활용하세요.
                    </p>
                    <div className="bg-orange-50 p-3 rounded-lg">
                      <div className="font-medium text-orange-800 mb-1">추천 활동</div>
                      <div className="text-sm text-orange-600">
                        • 관심 분야 시장 조사<br/>
                        • 협업 파트너 탐색<br/>
                        • 목표 수입 설정
                      </div>
                    </div>
                  </div>
                </TabsContent>

                <TabsContent value="month" className="mt-4">
                  <div className="space-y-3">
                    <p className="text-sm text-gray-600">
                      꾸준한 노력이 수익으로 이어질 가능성이 높습니다. 시간 관리에 신경쓰세요.
                    </p>
                    <div className="bg-amber-50 p-3 rounded-lg">
                      <div className="font-medium text-amber-800 mb-1">장기 전략</div>
                      <div className="text-sm text-amber-600">
                        • 수익 구조 점검<br/>
                        • 필요한 역량 강화<br/>
                        • 일정 관리 최적화
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
                <BriefcaseIcon className="h-5 w-5 text-yellow-600" />
                개인화된 조언
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                <div className="bg-gradient-to-r from-yellow-50 to-orange-50 p-4 rounded-lg">
                  <h4 className="font-medium text-yellow-800 mb-2">부업 관리 방향</h4>
                  <p className="text-sm text-yellow-700">
                    현실적인 목표를 세우고, 본업과 부업의 시간을 명확히 구분하세요. 작은 성과를 꾸준히 쌓는 것이 중요합니다.
                  </p>
                </div>

                <div className="bg-gradient-to-r from-green-50 to-emerald-50 p-4 rounded-lg">
                  <h4 className="font-medium text-green-800 mb-2">성공 팁</h4>
                  <p className="text-sm text-green-700">
                    네트워크를 넓히고 필요한 기술을 지속적으로 업그레이드하세요. 좋은 평판이 장기적인 수익으로 이어집니다.
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
                    <div className="font-medium">부업 아이디어 메모</div>
                    <div className="text-sm text-gray-600">떠오르는 아이디어를 바로 기록</div>
                  </div>
                </div>

                <div className="flex items-start gap-3 p-3 bg-gray-50 rounded-lg">
                  <AlertCircleIcon className="h-5 w-5 text-blue-500 mt-0.5" />
                  <div>
                    <div className="font-medium">시장 동향 조사</div>
                    <div className="text-sm text-gray-600">수요가 늘어나는 분야 확인</div>
                  </div>
                </div>

                <div className="flex items-start gap-3 p-3 bg-gray-50 rounded-lg">
                  <UserIcon className="h-5 w-5 text-purple-500 mt-0.5" />
                  <div>
                    <div className="font-medium">협업 파트너 연락</div>
                    <div className="text-sm text-gray-600">함께 할 수 있는 사람에게 연락하기</div>
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
