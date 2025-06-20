"use client";

import { useState } from "react";
import { motion } from "framer-motion";
import AppHeader from "@/components/AppHeader";
import { Progress } from "@/components/ui/progress";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { 
  CoinsIcon, 
  TrendingUpIcon, 
  StarIcon, 
  ClockIcon, 
  MapPinIcon, 
  UserIcon,
  CheckCircleIcon,
  AlertCircleIcon,
  CreditCardIcon,
  PiggyBankIcon,
  DollarSignIcon,
  BarChart3Icon
} from "lucide-react";

export default function WealthFortunePage() {
  const [selectedTab, setSelectedTab] = useState("today");

  const todayScore = 72;
  const weekScore = 85;
  const monthScore = 79;

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
            <CoinsIcon className="h-8 w-8 text-yellow-600" />
            <h1 className="text-3xl font-bold bg-gradient-to-r from-yellow-600 to-orange-600 bg-clip-text text-transparent">
              금전운
            </h1>
          </div>
          <p className="text-gray-600">
            재물과 투자의 흐름을 확인해보세요
          </p>
        </motion.div>

        {/* 오늘의 금전운 점수 */}
        <motion.div variants={itemVariants}>
          <Card className="mb-6 border-yellow-200 bg-gradient-to-r from-yellow-50 to-orange-50">
            <CardHeader className="text-center">
              <CardTitle className="flex items-center justify-center gap-2 text-yellow-700">
                <DollarSignIcon className="h-5 w-5" />
                오늘의 금전운
              </CardTitle>
            </CardHeader>
            <CardContent className="text-center">
              <div className="text-4xl font-bold text-yellow-600 mb-2">{todayScore}점</div>
              <Progress value={todayScore} className="mb-4" />
              <p className="text-sm text-gray-600">
                신중한 판단이 필요한 날입니다
              </p>
            </CardContent>
          </Card>
        </motion.div>

        {/* 기간별 점수 */}
        <motion.div variants={itemVariants}>
          <Card className="mb-6">
            <CardHeader>
              <CardTitle className="text-center">기간별 금전운</CardTitle>
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
                    <div className="text-sm text-gray-600">오전 10-12시</div>
                  </div>
                </div>
                <div className="flex items-center gap-2">
                  <MapPinIcon className="h-4 w-4 text-green-500" />
                  <div>
                    <div className="text-sm font-medium">행운의 장소</div>
                    <div className="text-sm text-gray-600">은행, 증권사</div>
                  </div>
                </div>
                <div className="flex items-center gap-2">
                  <div className="h-4 w-4 bg-yellow-500 rounded-full"></div>
                  <div>
                    <div className="text-sm font-medium">행운의 색상</div>
                    <div className="text-sm text-gray-600">골드, 브라운</div>
                  </div>
                </div>
                <div className="flex items-center gap-2">
                  <UserIcon className="h-4 w-4 text-orange-500" />
                  <div>
                    <div className="text-sm font-medium">도움이 되는 사람</div>
                    <div className="text-sm text-gray-600">재무 전문가</div>
                  </div>
                </div>
              </div>
            </CardContent>
          </Card>
        </motion.div>

        {/* 투자 분야별 운세 */}
        <motion.div variants={itemVariants}>
          <Card className="mb-6">
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <BarChart3Icon className="h-5 w-5 text-gray-600" />
                투자 분야별 운세
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-3">
                <div className="flex items-center justify-between p-3 bg-green-50 rounded-lg">
                  <div className="flex items-center gap-2">
                    <Badge variant="outline" className="bg-green-100 text-green-700">최고</Badge>
                    <span className="font-medium">부동산</span>
                  </div>
                  <div className="text-green-600 font-bold">92점</div>
                </div>
                <div className="flex items-center justify-between p-3 bg-blue-50 rounded-lg">
                  <div className="flex items-center gap-2">
                    <Badge variant="outline" className="bg-blue-100 text-blue-700">좋음</Badge>
                    <span className="font-medium">예금/적금</span>
                  </div>
                  <div className="text-blue-600 font-bold">85점</div>
                </div>
                <div className="flex items-center justify-between p-3 bg-purple-50 rounded-lg">
                  <div className="flex items-center gap-2">
                    <Badge variant="outline" className="bg-purple-100 text-purple-700">좋음</Badge>
                    <span className="font-medium">펀드/ETF</span>
                  </div>
                  <div className="text-purple-600 font-bold">78점</div>
                </div>
                <div className="flex items-center justify-between p-3 bg-red-50 rounded-lg">
                  <div className="flex items-center gap-2">
                    <Badge variant="outline" className="bg-red-100 text-red-700">주의</Badge>
                    <span className="font-medium">주식/코인</span>
                  </div>
                  <div className="text-red-600 font-bold">45점</div>
                </div>
              </div>
            </CardContent>
          </Card>
        </motion.div>

        {/* 기간별 예측 */}
        <motion.div variants={itemVariants}>
          <Card className="mb-6">
            <CardHeader>
              <CardTitle>기간별 금전운 예측</CardTitle>
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
                      오늘은 큰 지출을 피하고 신중한 재정 관리가 필요한 날입니다. 
                      예상치 못한 비용이 발생할 수 있으니 주의하세요.
                    </p>
                    <div className="bg-yellow-50 p-3 rounded-lg">
                      <div className="font-medium text-yellow-800 mb-1">주의사항</div>
                      <div className="text-sm text-yellow-600">
                        • 충동구매 자제<br/>
                        • 투자 결정 신중히<br/>
                        • 가계부 작성 권장
                      </div>
                    </div>
                  </div>
                </TabsContent>
                
                <TabsContent value="week" className="mt-4">
                  <div className="space-y-3">
                    <p className="text-sm text-gray-600">
                      이번 주는 재정 계획을 세우기에 좋은 시기입니다. 
                      안정적인 투자 기회를 모색해보세요.
                    </p>
                    <div className="bg-orange-50 p-3 rounded-lg">
                      <div className="font-medium text-orange-800 mb-1">추천 활동</div>
                      <div className="text-sm text-orange-600">
                        • 가계 예산 재검토<br/>
                        • 적금 상품 비교<br/>
                        • 부채 정리 계획
                      </div>
                    </div>
                  </div>
                </TabsContent>
                
                <TabsContent value="month" className="mt-4">
                  <div className="space-y-3">
                    <p className="text-sm text-gray-600">
                      이번 달은 장기 투자 계획을 수립하기에 적합한 시기입니다. 
                      다양한 포트폴리오 구성을 고려해보세요.
                    </p>
                    <div className="bg-amber-50 p-3 rounded-lg">
                      <div className="font-medium text-amber-800 mb-1">장기 전략</div>
                      <div className="text-sm text-amber-600">
                        • 은퇴 자금 계획<br/>
                        • 부동산 투자 검토<br/>
                        • 보험 상품 점검
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
                <PiggyBankIcon className="h-5 w-5 text-yellow-600" />
                개인화된 조언
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                <div className="bg-gradient-to-r from-yellow-50 to-orange-50 p-4 rounded-lg">
                  <h4 className="font-medium text-yellow-800 mb-2">재정 관리 방향</h4>
                  <p className="text-sm text-yellow-700">
                    현재는 안정성을 중시하는 투자가 유리합니다. 
                    고위험 투자보다는 꾸준한 저축과 안전한 투자처를 찾아보세요.
                  </p>
                </div>
                
                <div className="bg-gradient-to-r from-green-50 to-emerald-50 p-4 rounded-lg">
                  <h4 className="font-medium text-green-800 mb-2">투자 성공 팁</h4>
                  <p className="text-sm text-green-700">
                    분산 투자의 원칙을 지키고, 감정적인 판단보다는 
                    데이터와 전문가의 조언을 바탕으로 결정하세요. 
                    장기적인 관점에서 접근하는 것이 중요합니다.
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
                    <div className="font-medium">가계부 작성</div>
                    <div className="text-sm text-gray-600">오늘의 수입과 지출을 정확히 기록</div>
                  </div>
                </div>
                
                <div className="flex items-start gap-3 p-3 bg-gray-50 rounded-lg">
                  <CreditCardIcon className="h-5 w-5 text-blue-500 mt-0.5" />
                  <div>
                    <div className="font-medium">카드 사용 내역 점검</div>
                    <div className="text-sm text-gray-600">불필요한 지출이 있었는지 확인</div>
                  </div>
                </div>
                
                <div className="flex items-start gap-3 p-3 bg-gray-50 rounded-lg">
                  <AlertCircleIcon className="h-5 w-5 text-orange-500 mt-0.5" />
                  <div>
                    <div className="font-medium">투자 포트폴리오 검토</div>
                    <div className="text-sm text-gray-600">현재 투자 상품의 수익률과 리스크 분석</div>
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