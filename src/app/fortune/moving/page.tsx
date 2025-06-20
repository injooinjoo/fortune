'use client'

import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Progress } from "@/components/ui/progress"
import { Button } from "@/components/ui/button"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { Home, Compass, Calendar, MapPin, Clock, Star, CheckCircle, TrendingUp, AlertTriangle, Sparkles, ArrowRight, Building, TreePine } from "lucide-react"
import { motion } from "framer-motion"
import { useState } from "react"
import AppHeader from "@/components/AppHeader"

export default function MovingFortunePage() {
  const [checkedItems, setCheckedItems] = useState<Record<string, boolean>>({})
  const [fontSize, setFontSize] = useState<'small' | 'medium' | 'large'>('medium')

  const movingScore = {
    today: 85,
    week: 78,
    month: 92,
    year: 88
  }

  const luckyDirections = {
    best: "동북쪽",
    good: ["동쪽", "남동쪽"],
    avoid: ["서쪽", "남서쪽"]
  }

  const goodTiming = {
    months: ["3월", "6월", "9월", "11월"],
    days: ["화요일", "목요일", "토요일"],
    time: "오전 10시 ~ 오후 2시"
  }

  const houseTypes = [
    { type: "아파트", score: 92, desc: "안정적이고 현실적인 선택", color: "blue", advantage: "교통 편리, 시설 완비" },
    { type: "빌라/연립", score: 85, desc: "균형 잡힌 주거 환경", color: "green", advantage: "적당한 가격, 개인공간" },
    { type: "단독주택", score: 88, desc: "독립성과 자유로움", color: "purple", advantage: "프라이버시, 마당 공간" },
    { type: "오피스텔", score: 75, desc: "편리하지만 신중한 선택 필요", color: "orange", advantage: "도심 접근성, 관리 편의" }
  ]

  const fengShuiTips = [
    { category: "현관", tip: "현관은 집의 얼굴입니다. 밝고 깨끗하게 유지하세요", icon: Home, color: "blue" },
    { category: "침실", tip: "침실은 동쪽이나 남동쪽이 좋으며, 거울은 침대 정면에 두지 마세요", icon: Star, color: "purple" },
    { category: "주방", tip: "주방은 집의 재물운을 담당합니다. 깨끗하고 정리된 상태를 유지하세요", icon: Sparkles, color: "yellow" },
    { category: "화장실", tip: "화장실 문은 항상 닫아두고, 환기를 잘 시켜주세요", icon: CheckCircle, color: "green" }
  ]

  const checklist = {
    beforeMoving: [
      "이사 업체 견적 비교하기",
      "전입신고 및 주소 변경 신청",
      "인터넷, 가스, 전기 이전 신청",
      "우편물 이전 서비스 신청",
      "은행, 카드회사 주소 변경",
      "자녀 전학 수속 준비"
    ],
    onMovingDay: [
      "이사 짐 마지막 점검",
      "구 집 가스, 전기 차단 확인",
      "새 집 열쇠 및 보안 점검",
      "이사 업체와 최종 확인",
      "깨지기 쉬운 물건 직접 운반",
      "중요 서류 분실 방지"
    ],
    afterMoving: [
      "전입신고 완료하기",
      "가스, 전기, 수도 개통",
      "인터넷 설치 완료",
      "주변 편의시설 파악하기",
      "이웃과 인사 나누기",
      "집들이 계획 세우기"
    ]
  }

  const predictions = {
    "오늘": {
      score: movingScore.today,
      prediction: "오늘은 이사와 관련된 정보를 수집하거나 집을 알아보기 좋은 날입니다.",
      advice: "부동산 매물을 살펴보거나 이사 업체 상담을 받아보세요.",
      caution: "계약은 서두르지 말고 충분히 검토 후 결정하세요."
    },
    "이번 주": {
      score: movingScore.week,
      prediction: "이번 주는 실제 이사 준비나 계약 진행에 적합한 시기입니다.",
      advice: "필요한 서류들을 미리 준비하고 체크리스트를 만들어보세요.",
      caution: "급하게 결정하기보다는 신중하게 검토하는 것이 중요합니다."
    },
    "이번 달": {
      score: movingScore.month,
      prediction: "이번 달은 이사운이 매우 좋은 시기로, 새로운 시작에 적합합니다.",
      advice: "이사를 계획하고 있다면 이번 달에 실행에 옮기는 것이 좋습니다.",
      caution: "좋은 기운을 놓치지 않도록 미리 계획을 세워두세요."
    },
    "올해": {
      score: movingScore.year,
      prediction: "올해는 전반적으로 이사운이 좋아 주거 환경 개선에 유리한 해입니다.",
      advice: "봄과 가을에 특히 좋은 기운이 있으니 이 시기를 활용하세요.",
      caution: "너무 큰 변화보다는 점진적인 개선이 더 안정적입니다."
    }
  }

  const toggleCheck = (section: string, index: number) => {
    const key = `${section}-${index}`
    setCheckedItems(prev => ({
      ...prev,
      [key]: !prev[key]
    }))
  }

  return (
    <>
      <AppHeader 
        title="이사운" 
        onFontSizeChange={setFontSize}
        currentFontSize={fontSize}
      />
      <div className="pb-32 px-4 space-y-6 pt-4">
        {/* 헤더 */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="text-center"
        >
          <h1 className="text-3xl font-bold bg-gradient-to-r from-blue-600 to-green-600 bg-clip-text text-transparent mb-2">
            🏠 이사운
          </h1>
          <p className="text-gray-600">새로운 보금자리로의 행복한 이주를 위한 운세</p>
        </motion.div>

        {/* 오늘의 이사운 점수 */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.1 }}
        >
          <Card className="bg-gradient-to-r from-blue-100 to-green-100 border-blue-200">
            <CardHeader>
              <CardTitle className="flex items-center gap-2 text-blue-700">
                <Home className="w-6 h-6" />
                오늘의 이사운
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                  {[
                    { label: "오늘", value: movingScore.today, color: "blue" },
                    { label: "이번 주", value: movingScore.week, color: "indigo" },
                    { label: "이번 달", value: movingScore.month, color: "green" },
                    { label: "올해", value: movingScore.year, color: "emerald" }
                  ].map((item, index) => (
                    <motion.div
                      key={item.label}
                      initial={{ scale: 0 }}
                      animate={{ scale: 1 }}
                      transition={{ delay: 0.2 + index * 0.1 }}
                      className="text-center"
                    >
                      <div className="text-2xl font-bold text-gray-800">{item.value}점</div>
                      <div className="text-sm text-gray-600">{item.label}</div>
                      <Progress
                        value={item.value}
                        className="mt-2 h-2"
                      />
                    </motion.div>
                  ))}
                </div>
              </div>
            </CardContent>
          </Card>
        </motion.div>

        {/* 행운의 방향 */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.2 }}
        >
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2 text-purple-700">
                <Compass className="w-6 h-6" />
                행운의 방향
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                <div className="text-center p-4 bg-green-50 rounded-lg border border-green-200">
                  <div className="text-lg font-bold text-green-800 mb-2">최고의 방향</div>
                  <div className="text-2xl font-bold text-green-600">{luckyDirections.best}</div>
                </div>
                
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div className="p-4 bg-blue-50 rounded-lg border border-blue-200">
                    <div className="font-medium text-blue-800 mb-2">좋은 방향</div>
                    <div className="flex flex-wrap gap-2">
                      {luckyDirections.good.map((direction, index) => (
                        <Badge key={index} className="bg-blue-100 text-blue-700">
                          {direction}
                        </Badge>
                      ))}
                    </div>
                  </div>
                  
                  <div className="p-4 bg-red-50 rounded-lg border border-red-200">
                    <div className="font-medium text-red-800 mb-2">피해야 할 방향</div>
                    <div className="flex flex-wrap gap-2">
                      {luckyDirections.avoid.map((direction, index) => (
                        <Badge key={index} className="bg-red-100 text-red-700">
                          {direction}
                        </Badge>
                      ))}
                    </div>
                  </div>
                </div>
              </div>
            </CardContent>
          </Card>
        </motion.div>

        {/* 좋은 이사 시기 */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.3 }}
        >
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2 text-emerald-700">
                <Calendar className="w-6 h-6" />
                좋은 이사 시기
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                <div className="p-4 rounded-lg border border-gray-200">
                  <div className="font-medium text-gray-800 mb-2 flex items-center gap-2">
                    <Calendar className="w-4 h-4" />
                    행운의 달
                  </div>
                  <div className="flex flex-wrap gap-2">
                    {goodTiming.months.map((month, index) => (
                      <Badge key={index} variant="outline" className="text-green-600 border-green-300">
                        {month}
                      </Badge>
                    ))}
                  </div>
                </div>
                
                <div className="p-4 rounded-lg border border-gray-200">
                  <div className="font-medium text-gray-800 mb-2 flex items-center gap-2">
                    <Star className="w-4 h-4" />
                    행운의 요일
                  </div>
                  <div className="flex flex-wrap gap-2">
                    {goodTiming.days.map((day, index) => (
                      <Badge key={index} variant="outline" className="text-blue-600 border-blue-300">
                        {day}
                      </Badge>
                    ))}
                  </div>
                </div>
                
                <div className="p-4 rounded-lg border border-gray-200">
                  <div className="font-medium text-gray-800 mb-2 flex items-center gap-2">
                    <Clock className="w-4 h-4" />
                    행운의 시간
                  </div>
                  <div className="text-sm text-gray-600">{goodTiming.time}</div>
                </div>
              </div>
            </CardContent>
          </Card>
        </motion.div>

        {/* 집 종류별 운세 */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.4 }}
        >
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2 text-indigo-700">
                <Building className="w-6 h-6" />
                집 종류별 운세
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                {houseTypes.map((house, index) => (
                  <motion.div
                    key={house.type}
                    initial={{ opacity: 0, x: -20 }}
                    animate={{ opacity: 1, x: 0 }}
                    transition={{ delay: 0.5 + index * 0.1 }}
                    className="p-4 rounded-lg border border-gray-200 hover:border-gray-300 transition-colors"
                  >
                    <div className="flex items-center justify-between mb-2">
                      <div className="flex items-center gap-3">
                        <div className={`w-3 h-3 rounded-full bg-${house.color}-500`}></div>
                        <h3 className="font-semibold text-gray-800">{house.type}</h3>
                        <Badge variant="outline" className={`text-${house.color}-600 border-${house.color}-300`}>
                          {house.score}점
                        </Badge>
                      </div>
                      <Progress value={house.score} className="w-24 h-2" />
                    </div>
                    <p className="text-sm text-gray-600 mb-1">{house.desc}</p>
                    <p className="text-xs text-gray-500">✨ {house.advantage}</p>
                  </motion.div>
                ))}
              </div>
            </CardContent>
          </Card>
        </motion.div>

        {/* 풍수 조언 */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.5 }}
        >
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2 text-amber-700">
                <TreePine className="w-6 h-6" />
                풍수 조언
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                {fengShuiTips.map((tip, index) => (
                  <motion.div
                    key={tip.category}
                    initial={{ opacity: 0, scale: 0.9 }}
                    animate={{ opacity: 1, scale: 1 }}
                    transition={{ delay: 0.6 + index * 0.1 }}
                    className={`p-4 rounded-lg bg-${tip.color}-50 border border-${tip.color}-200`}
                  >
                    <div className="flex items-start gap-3">
                      <div className={`p-2 rounded-full bg-${tip.color}-100`}>
                        <tip.icon className={`w-4 h-4 text-${tip.color}-600`} />
                      </div>
                      <div>
                        <h4 className={`font-medium text-${tip.color}-800 mb-1`}>{tip.category}</h4>
                        <p className={`text-sm text-${tip.color}-700`}>{tip.tip}</p>
                      </div>
                    </div>
                  </motion.div>
                ))}
              </div>
            </CardContent>
          </Card>
        </motion.div>

        {/* 이사 준비 체크리스트 */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.6 }}
        >
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2 text-green-700">
                <CheckCircle className="w-6 h-6" />
                이사 준비 체크리스트
              </CardTitle>
            </CardHeader>
            <CardContent>
              <Tabs defaultValue="beforeMoving" className="w-full">
                <TabsList className="grid w-full grid-cols-3">
                  <TabsTrigger value="beforeMoving">이사 전</TabsTrigger>
                  <TabsTrigger value="onMovingDay">이사 당일</TabsTrigger>
                  <TabsTrigger value="afterMoving">이사 후</TabsTrigger>
                </TabsList>

                {Object.entries(checklist).map(([key, items]) => (
                  <TabsContent key={key} value={key} className="mt-4">
                    <div className="space-y-2">
                      {items.map((item, index) => (
                        <motion.div
                          key={index}
                          initial={{ opacity: 0, y: 10 }}
                          animate={{ opacity: 1, y: 0 }}
                          transition={{ delay: index * 0.1 }}
                          className="flex items-center gap-3 p-3 rounded-lg hover:bg-gray-50 transition-colors cursor-pointer"
                          onClick={() => toggleCheck(key, index)}
                        >
                          <div
                            className={`w-5 h-5 rounded border-2 flex items-center justify-center transition-colors ${
                              checkedItems[`${key}-${index}`]
                                ? 'bg-green-500 border-green-500 text-white'
                                : 'border-gray-300'
                            }`}
                          >
                            {checkedItems[`${key}-${index}`] && (
                              <CheckCircle className="w-3 h-3" />
                            )}
                          </div>
                          <span className={`text-sm ${
                            checkedItems[`${key}-${index}`] ? 'line-through text-gray-500' : 'text-gray-700'
                          }`}>
                            {item}
                          </span>
                        </motion.div>
                      ))}
                    </div>
                  </TabsContent>
                ))}
              </Tabs>
            </CardContent>
          </Card>
        </motion.div>

        {/* 기간별 상세 예측 */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.7 }}
        >
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2 text-violet-700">
                <TrendingUp className="w-6 h-6" />
                기간별 상세 예측
              </CardTitle>
            </CardHeader>
            <CardContent>
              <Tabs defaultValue="오늘" className="w-full">
                <TabsList className="grid w-full grid-cols-4">
                  {Object.keys(predictions).map(period => (
                    <TabsTrigger key={period} value={period}>{period}</TabsTrigger>
                  ))}
                </TabsList>

                {Object.entries(predictions).map(([period, data]) => (
                  <TabsContent key={period} value={period} className="mt-4">
                    <motion.div
                      initial={{ opacity: 0, y: 10 }}
                      animate={{ opacity: 1, y: 0 }}
                      className="space-y-4"
                    >
                      <div className="text-center">
                        <div className="text-3xl font-bold text-blue-600 mb-2">{data.score}점</div>
                        <Progress value={data.score} className="w-full h-3" />
                      </div>
                      
                      <div className="space-y-3">
                        <div className="p-4 rounded-lg bg-blue-50 border border-blue-200">
                          <h4 className="font-medium text-blue-800 mb-2">🏠 운세 예측</h4>
                          <p className="text-sm text-blue-700">{data.prediction}</p>
                        </div>
                        
                        <div className="p-4 rounded-lg bg-green-50 border border-green-200">
                          <h4 className="font-medium text-green-800 mb-2">✨ 추천 활동</h4>
                          <p className="text-sm text-green-700">{data.advice}</p>
                        </div>
                        
                        <div className="p-4 rounded-lg bg-yellow-50 border border-yellow-200">
                          <h4 className="font-medium text-yellow-800 mb-2">⚠️ 주의사항</h4>
                          <p className="text-sm text-yellow-700">{data.caution}</p>
                        </div>
                      </div>
                    </motion.div>
                  </TabsContent>
                ))}
              </Tabs>
            </CardContent>
          </Card>
        </motion.div>
      </div>
    </>
  )
} 