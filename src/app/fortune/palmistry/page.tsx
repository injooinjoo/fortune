'use client'

import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Progress } from "@/components/ui/progress"
import { Button } from "@/components/ui/button"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { Hand, Heart, Brain, Star, TrendingUp, Calendar, Users, Zap, Eye, Target, Activity, Crown, Gem } from "lucide-react"
import { motion } from "framer-motion"
import { useState } from "react"
import AppHeader from "@/components/AppHeader"

export default function PalmistryPage() {
  const [selectedHand, setSelectedHand] = useState<'left' | 'right'>('right')
  const [fontSize, setFontSize] = useState<'small' | 'medium' | 'large'>('medium')

  const palmLines = [
    {
      name: "생명선",
      score: 88,
      description: "건강과 생명력을 나타내는 가장 중요한 선",
      meaning: "강하고 뚜렷한 생명선으로 건강한 체력과 활력을 의미",
      color: "green",
      icon: Activity,
      characteristics: ["장수", "활력", "체력", "회복력"]
    },
    {
      name: "사랑선",
      score: 92,
      description: "감정과 사랑, 인간관계를 나타내는 선",
      meaning: "깊고 선명한 사랑선으로 풍부한 감정과 좋은 인연을 의미",
      color: "pink",
      icon: Heart,
      characteristics: ["감정풍부", "좋은인연", "사랑운", "가족애"]
    },
    {
      name: "지능선",
      score: 90,
      description: "지혜와 사고력, 학습능력을 나타내는 선",
      meaning: "길고 뚜렷한 지능선으로 뛰어난 분석력과 판단력을 의미",
      color: "blue",
      icon: Brain,
      characteristics: ["분석력", "창의성", "학습능력", "논리적사고"]
    },
    {
      name: "운명선",
      score: 85,
      description: "인생의 방향과 성공, 사회적 성취를 나타내는 선",
      meaning: "꾸준히 상승하는 운명선으로 점진적인 발전과 성공을 의미",
      color: "purple",
      icon: Star,
      characteristics: ["성공운", "사회적지위", "리더십", "목표달성"]
    }
  ]

  const handShapes = [
    {
      type: "사각형 손",
      personality: "실용적이고 현실적인 성격",
      strengths: ["신뢰성", "책임감", "끈기", "실행력"],
      careers: ["관리직", "엔지니어", "회계사", "건축가"],
      color: "green"
    },
    {
      type: "원형 손",
      personality: "감성적이고 예술적인 성격",
      strengths: ["창의성", "공감능력", "예술성", "직감"],
      careers: ["예술가", "상담사", "작가", "디자이너"],
      color: "pink"
    },
    {
      type: "장방형 손",
      personality: "지적이고 분석적인 성격",
      strengths: ["논리성", "분석력", "학습능력", "문제해결"],
      careers: ["연구원", "변호사", "의사", "교수"],
      color: "blue"
    },
    {
      type: "혼합형 손",
      personality: "균형 잡힌 다재다능한 성격",
      strengths: ["적응력", "다재다능", "균형감", "소통능력"],
      careers: ["컨설턴트", "기획자", "영업직", "CEO"],
      color: "purple"
    }
  ]

  const fingerMeanings = [
    {
      finger: "엄지손가락",
      meaning: "의지력과 리더십",
      strong: "강한 의지력, 리더십 능력, 결단력",
      weak: "우유부단함, 의존적 성향",
      ideal: "적당한 길이로 균형 잡힌 성격"
    },
    {
      finger: "검지손가락",
      meaning: "자존심과 야망",
      strong: "높은 자존심, 강한 야망, 지배욕",
      weak: "자신감 부족, 소극적 성향",
      ideal: "적절한 자신감과 목표의식"
    },
    {
      finger: "중지손가락",
      meaning: "책임감과 균형",
      strong: "강한 책임감, 진중함, 신중함",
      weak: "무책임함, 경솔함",
      ideal: "균형 잡힌 책임감과 판단력"
    },
    {
      finger: "약지손가락",
      meaning: "예술성과 창의력",
      strong: "뛰어난 예술성, 창의력, 미적 감각",
      weak: "현실감 부족, 몽상적 성향",
      ideal: "창의성과 현실감의 조화"
    },
    {
      finger: "새끼손가락",
      meaning: "소통능력과 표현력",
      strong: "뛰어난 화술, 설득력, 사교성",
      weak: "소통 어려움, 내성적 성향",
      ideal: "자연스러운 소통과 표현 능력"
    }
  ]

  const readingGuide = {
    basics: [
      "오른손은 현재와 미래, 왼손은 과거와 타고난 성향을 봅니다",
      "선이 깊고 뚜렷할수록 그 의미가 강합니다",
      "손금은 변할 수 있으므로 정기적으로 관찰하세요",
      "여러 선을 종합적으로 해석하는 것이 중요합니다"
    ],
    tips: [
      "자연광에서 손을 펴고 관찰하세요",
      "손을 너무 세게 펴지 말고 자연스럽게 유지하세요",
      "작은 선들보다 주요 선에 집중하세요",
      "손금은 참고용이며 운명을 결정하지 않습니다"
    ]
  }

  const luckyElements = {
    today: {
      color: "골드",
      number: 7,
      direction: "동남쪽",
      time: "오후 2-4시",
      activity: "손 마사지나 핸드크림 사용"
    },
    week: {
      recommendation: "손목 스트레칭과 손가락 운동을 통해 운기 상승",
      caution: "과도한 손 사용으로 인한 피로 주의",
      lucky_day: "수요일"
    }
  }

  const monthlyPredictions = {
    "이번 달": {
      overall: "손금이 나타내는 운세가 전반적으로 상승하는 시기",
      love: "사랑선의 기운이 활발해져 새로운 만남이나 관계 발전 가능",
      career: "지능선과 운명선이 조화를 이뤄 업무에서 좋은 성과 기대",
      health: "생명선이 안정적이어서 건강 상태 양호",
      advice: "손 관리를 통해 긍정적인 에너지 유지하세요"
    },
    "다음 달": {
      overall: "내면의 성장과 자기 발견의 시기",
      love: "감정선이 깊어져 진정한 사랑을 만날 가능성",
      career: "새로운 기회나 도전에 적극적으로 임하면 좋은 결과",
      health: "손목과 손가락 건강에 특별히 주의",
      advice: "직감을 믿고 중요한 결정을 내려보세요"
    },
    "3개월 후": {
      overall: "큰 변화와 발전이 예상되는 전환점",
      love: "운명적인 만남이나 중요한 관계 변화 가능",
      career: "노력의 결실을 맺는 성취의 시기",
      health: "전반적인 활력과 에너지 상승",
      advice: "긍정적인 마음가짐으로 변화를 받아들이세요"
    }
  }

  return (
    <>
      <AppHeader 
        title="손금" 
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
          <h1 className="text-3xl font-bold bg-gradient-to-r from-amber-600 to-orange-600 bg-clip-text text-transparent mb-2">
            ✋ 손금
          </h1>
          <p className="text-gray-600">손에 새겨진 인생의 지도를 읽어보세요</p>
        </motion.div>

        {/* 손 선택 */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.1 }}
        >
          <Card className="bg-gradient-to-r from-amber-50 to-orange-50 border-amber-200">
            <CardHeader>
              <CardTitle className="flex items-center gap-2 text-amber-700">
                <Hand className="w-6 h-6" />
                손 선택
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="flex gap-4 justify-center">
                <Button
                  variant={selectedHand === 'left' ? 'default' : 'outline'}
                  onClick={() => setSelectedHand('left')}
                  className="flex items-center gap-2"
                >
                  <Hand className="w-4 h-4 scale-x-[-1]" />
                  왼손 (타고난 성향)
                </Button>
                <Button
                  variant={selectedHand === 'right' ? 'default' : 'outline'}
                  onClick={() => setSelectedHand('right')}
                  className="flex items-center gap-2"
                >
                  <Hand className="w-4 h-4" />
                  오른손 (현재/미래)
                </Button>
              </div>
              <p className="text-sm text-gray-600 text-center mt-3">
                {selectedHand === 'left' 
                  ? '왼손은 타고난 성향과 과거를 나타냅니다'
                  : '오른손은 현재 상황과 미래 가능성을 나타냅니다'
                }
              </p>
            </CardContent>
          </Card>
        </motion.div>

        {/* 주요 손금 라인 분석 */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.2 }}
        >
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2 text-blue-700">
                <Eye className="w-6 h-6" />
                주요 손금 라인 분석
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-6">
                {palmLines.map((line, index) => (
                  <motion.div
                    key={line.name}
                    initial={{ opacity: 0, x: -20 }}
                    animate={{ opacity: 1, x: 0 }}
                    transition={{ delay: 0.3 + index * 0.1 }}
                    className="p-4 rounded-lg border border-gray-200 hover:border-gray-300 transition-colors"
                  >
                    <div className="flex items-center justify-between mb-3">
                      <div className="flex items-center gap-3">
                        <div className={`p-2 rounded-full bg-${line.color}-100`}>
                          <line.icon className={`w-5 h-5 text-${line.color}-600`} />
                        </div>
                        <div>
                          <h3 className="font-semibold text-gray-800">{line.name}</h3>
                          <Badge variant="outline" className={`text-${line.color}-600 border-${line.color}-300`}>
                            {line.score}점
                          </Badge>
                        </div>
                      </div>
                      <Progress value={line.score} className="w-24 h-2" />
                    </div>
                    
                    <p className="text-sm text-gray-600 mb-2">{line.description}</p>
                    <p className="text-sm text-gray-700 mb-3 font-medium">{line.meaning}</p>
                    
                    <div className="flex flex-wrap gap-2">
                      {line.characteristics.map((char, idx) => (
                        <Badge key={idx} className={`bg-${line.color}-100 text-${line.color}-700 text-xs`}>
                          {char}
                        </Badge>
                      ))}
                    </div>
                  </motion.div>
                ))}
              </div>
            </CardContent>
          </Card>
        </motion.div>

        {/* 손 모양별 성격 분석 */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.3 }}
        >
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2 text-purple-700">
                <Target className="w-6 h-6" />
                손 모양별 성격 분석
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                {handShapes.map((shape, index) => (
                  <motion.div
                    key={shape.type}
                    initial={{ opacity: 0, scale: 0.9 }}
                    animate={{ opacity: 1, scale: 1 }}
                    transition={{ delay: 0.4 + index * 0.1 }}
                    className={`p-4 rounded-lg bg-${shape.color}-50 border border-${shape.color}-200`}
                  >
                    <h4 className={`font-semibold text-${shape.color}-800 mb-2`}>{shape.type}</h4>
                    <p className={`text-sm text-${shape.color}-700 mb-3`}>{shape.personality}</p>
                    
                    <div className="mb-3">
                      <div className="text-xs font-medium text-gray-700 mb-1">강점</div>
                      <div className="flex flex-wrap gap-1">
                        {shape.strengths.map((strength, idx) => (
                          <Badge key={idx} variant="outline" className={`text-${shape.color}-600 border-${shape.color}-300 text-xs`}>
                            {strength}
                          </Badge>
                        ))}
                      </div>
                    </div>
                    
                    <div>
                      <div className="text-xs font-medium text-gray-700 mb-1">적합한 직업</div>
                      <div className="text-xs text-gray-600">
                        {shape.careers.join(', ')}
                      </div>
                    </div>
                  </motion.div>
                ))}
              </div>
            </CardContent>
          </Card>
        </motion.div>

        {/* 손가락별 의미 */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.4 }}
        >
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2 text-green-700">
                <Zap className="w-6 h-6" />
                손가락별 의미
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                {fingerMeanings.map((finger, index) => (
                  <motion.div
                    key={finger.finger}
                    initial={{ opacity: 0, y: 10 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ delay: 0.5 + index * 0.1 }}
                    className="p-4 rounded-lg border border-gray-200"
                  >
                    <h4 className="font-semibold text-gray-800 mb-2">{finger.finger}</h4>
                    <div className="grid grid-cols-1 md:grid-cols-3 gap-3 text-sm">
                      <div className="p-2 bg-green-50 rounded border border-green-200">
                        <div className="font-medium text-green-800 mb-1">강할 때</div>
                        <div className="text-green-700">{finger.strong}</div>
                      </div>
                      <div className="p-2 bg-red-50 rounded border border-red-200">
                        <div className="font-medium text-red-800 mb-1">약할 때</div>
                        <div className="text-red-700">{finger.weak}</div>
                      </div>
                      <div className="p-2 bg-blue-50 rounded border border-blue-200">
                        <div className="font-medium text-blue-800 mb-1">이상적</div>
                        <div className="text-blue-700">{finger.ideal}</div>
                      </div>
                    </div>
                  </motion.div>
                ))}
              </div>
            </CardContent>
          </Card>
        </motion.div>

        {/* 손금 읽는 방법 */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.5 }}
        >
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2 text-indigo-700">
                <Gem className="w-6 h-6" />
                손금 읽는 방법
              </CardTitle>
            </CardHeader>
            <CardContent>
              <Tabs defaultValue="basics" className="w-full">
                <TabsList className="grid w-full grid-cols-2">
                  <TabsTrigger value="basics">기본 원칙</TabsTrigger>
                  <TabsTrigger value="tips">실용 팁</TabsTrigger>
                </TabsList>

                <TabsContent value="basics" className="mt-4">
                  <div className="space-y-3">
                    {readingGuide.basics.map((guide, index) => (
                      <motion.div
                        key={index}
                        initial={{ opacity: 0, x: -10 }}
                        animate={{ opacity: 1, x: 0 }}
                        transition={{ delay: index * 0.1 }}
                        className="flex items-start gap-3 p-3 bg-blue-50 rounded-lg border border-blue-200"
                      >
                        <div className="w-6 h-6 bg-blue-100 rounded-full flex items-center justify-center text-blue-600 font-semibold text-sm">
                          {index + 1}
                        </div>
                        <span className="text-sm text-blue-700">{guide}</span>
                      </motion.div>
                    ))}
                  </div>
                </TabsContent>

                <TabsContent value="tips" className="mt-4">
                  <div className="space-y-3">
                    {readingGuide.tips.map((tip, index) => (
                      <motion.div
                        key={index}
                        initial={{ opacity: 0, x: -10 }}
                        animate={{ opacity: 1, x: 0 }}
                        transition={{ delay: index * 0.1 }}
                        className="flex items-start gap-3 p-3 bg-amber-50 rounded-lg border border-amber-200"
                      >
                        <div className="w-6 h-6 bg-amber-100 rounded-full flex items-center justify-center text-amber-600 font-semibold text-sm">
                          💡
                        </div>
                        <span className="text-sm text-amber-700">{tip}</span>
                      </motion.div>
                    ))}
                  </div>
                </TabsContent>
              </Tabs>
            </CardContent>
          </Card>
        </motion.div>

        {/* 오늘의 손금 운세 */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.6 }}
        >
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2 text-orange-700">
                <Crown className="w-6 h-6" />
                오늘의 손금 운세
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-4">
                <div className="text-center p-3 bg-yellow-50 rounded-lg border border-yellow-200">
                  <div className="text-sm text-yellow-800 font-medium mb-1">행운의 색상</div>
                  <div className="text-yellow-600">{luckyElements.today.color}</div>
                </div>
                <div className="text-center p-3 bg-purple-50 rounded-lg border border-purple-200">
                  <div className="text-sm text-purple-800 font-medium mb-1">행운의 숫자</div>
                  <div className="text-purple-600">{luckyElements.today.number}</div>
                </div>
                <div className="text-center p-3 bg-green-50 rounded-lg border border-green-200">
                  <div className="text-sm text-green-800 font-medium mb-1">행운의 방향</div>
                  <div className="text-green-600">{luckyElements.today.direction}</div>
                </div>
                <div className="text-center p-3 bg-blue-50 rounded-lg border border-blue-200">
                  <div className="text-sm text-blue-800 font-medium mb-1">행운의 시간</div>
                  <div className="text-blue-600">{luckyElements.today.time}</div>
                </div>
              </div>
              
              <div className="p-4 bg-orange-50 rounded-lg border border-orange-200">
                <div className="font-medium text-orange-800 mb-2">오늘의 추천 활동</div>
                <p className="text-sm text-orange-700">{luckyElements.today.activity}</p>
              </div>
            </CardContent>
          </Card>
        </motion.div>

        {/* 월별 상세 예측 */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.7 }}
        >
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2 text-violet-700">
                <Calendar className="w-6 h-6" />
                월별 손금 운세
              </CardTitle>
            </CardHeader>
            <CardContent>
              <Tabs defaultValue="이번 달" className="w-full">
                <TabsList className="grid w-full grid-cols-3">
                  {Object.keys(monthlyPredictions).map(period => (
                    <TabsTrigger key={period} value={period}>{period}</TabsTrigger>
                  ))}
                </TabsList>

                {Object.entries(monthlyPredictions).map(([period, data]) => (
                  <TabsContent key={period} value={period} className="mt-4">
                    <motion.div
                      initial={{ opacity: 0, y: 10 }}
                      animate={{ opacity: 1, y: 0 }}
                      className="space-y-4"
                    >
                      <div className="p-4 rounded-lg bg-violet-50 border border-violet-200">
                        <h4 className="font-medium text-violet-800 mb-2">✋ 전체 운세</h4>
                        <p className="text-sm text-violet-700">{data.overall}</p>
                      </div>
                      
                      <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
                        <div className="p-3 rounded-lg bg-pink-50 border border-pink-200">
                          <h4 className="font-medium text-pink-800 mb-1">💕 사랑운</h4>
                          <p className="text-sm text-pink-700">{data.love}</p>
                        </div>
                        
                        <div className="p-3 rounded-lg bg-blue-50 border border-blue-200">
                          <h4 className="font-medium text-blue-800 mb-1">💼 사업운</h4>
                          <p className="text-sm text-blue-700">{data.career}</p>
                        </div>
                      </div>
                      
                      <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
                        <div className="p-3 rounded-lg bg-green-50 border border-green-200">
                          <h4 className="font-medium text-green-800 mb-1">🏥 건강운</h4>
                          <p className="text-sm text-green-700">{data.health}</p>
                        </div>
                        
                        <div className="p-3 rounded-lg bg-amber-50 border border-amber-200">
                          <h4 className="font-medium text-amber-800 mb-1">💡 조언</h4>
                          <p className="text-sm text-amber-700">{data.advice}</p>
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