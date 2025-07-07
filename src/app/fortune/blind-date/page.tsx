"use client";

import { useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Badge } from "@/components/ui/badge";
import { RadioGroup, RadioGroupItem } from "@/components/ui/radio-group";
import { Textarea } from "@/components/ui/textarea";
import { Checkbox } from "@/components/ui/checkbox";
import AppHeader from "@/components/AppHeader";
import { DeterministicRandom } from '@/lib/deterministic-random';
import { 
  Coffee, 
  Heart, 
  Star, 
  Calendar,
  Sparkles,
  ArrowRight,
  Shuffle,
  Clock,
  Users,
  MessageCircle,
  TrendingUp,
  Lightbulb,
  MapPin,
  Smile
} from "lucide-react";

interface BlindDateInfo {
  name: string;
  age: string;
  job: string;
  personality: string[];
  ideal_type: string;
  experience_level: string;
  preferred_location: string;
  preferred_activity: string;
  concerns: string;
}

interface BlindDateResult {
  success_rate: number;
  chemistry_score: number;
  conversation_score: number;
  impression_score: number;
  insights: {
    personality_analysis: string;
    strengths: string;
    areas_to_improve: string;
  };
  recommendations: {
    ideal_venues: string[];
    conversation_topics: string[];
    style_tips: string[];
    behavior_tips: string[];
  };
  timeline: {
    best_timing: string;
    preparation_period: string;
    success_indicators: string[];
  };
  warnings: string[];
}

const containerVariants = {
  hidden: { opacity: 0 },
  visible: {
    opacity: 1,
    transition: {
      staggerChildren: 0.1,
      delayChildren: 0.2
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
      stiffness: 100,
      damping: 10
    }
  }
};

const getScoreColor = (score: number) => {
  if (score >= 85) return "text-green-600 bg-green-50";
  if (score >= 70) return "text-blue-600 bg-blue-50";
  if (score >= 55) return "text-orange-600 bg-orange-50";
  return "text-red-600 bg-red-50";
};

const getScoreText = (score: number) => {
  if (score >= 85) return "매우 높음";
  if (score >= 70) return "높음";
  if (score >= 55) return "보통";
  return "노력 필요";
};

const personalityOptions = [
  "외향적", "내향적", "유머러스", "진지함", "활발함", 
  "차분함", "긍정적", "신중함", "적극적", "배려심 많음"
];

export default function BlindDatePage() {
  // Initialize deterministic random for consistent results
  // Get actual user ID from auth context
  const { user } = useAuth();
  const userId = user?.id || 'guest-user';
  const today = new Date().toISOString().split('T')[0];
  const fortuneType = 'page';
  const deterministicRandom = new DeterministicRandom(userId, today, fortuneType);

  const [step, setStep] = useState<'input' | 'result'>('input');
  const [loading, setLoading] = useState(false);
  const [formData, setFormData] = useState<BlindDateInfo>({
    name: '',
    age: '',
    job: '',
    personality: [],
    ideal_type: '',
    experience_level: '',
    preferred_location: '',
    preferred_activity: '',
    concerns: ''
  });
  const [result, setResult] = useState<BlindDateResult | null>(null);

  const analyzeBlindDate = async (): Promise<BlindDateResult> => {
    try {
      const response = await fetch('/api/fortune/blind-date', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(formData),
      });

      if (!response.ok) {
        throw new Error('소개팅 분석에 실패했습니다.');
      }

      const data = await response.json();
      return data.analysis || data;
    } catch (error) {
      console.error('GPT 연동 실패, 기본 데이터 사용:', error);
      
      // GPT 실패시 기본 로직
      const baseScore = deterministicRandom.randomInt(60, 60 + 25 - 1); // 60-85 사이
      
      return {
        success_rate: Math.max(45, Math.min(95, baseScore + Math.floor(deterministicRandom.random() * 15))),
        chemistry_score: Math.max(50, Math.min(100, baseScore + Math.floor(deterministicRandom.random() * 20) - 5)),
        conversation_score: Math.max(45, Math.min(95, baseScore + Math.floor(deterministicRandom.random() * 20) - 10)),
        impression_score: Math.max(55, Math.min(100, baseScore + Math.floor(deterministicRandom.random() * 15))),
        insights: {
          personality_analysis: "당신은 진솔하고 매력적인 성격을 가지고 있어 상대방에게 좋은 인상을 줄 수 있습니다.",
          strengths: "자연스러운 대화 능력과 상대방을 배려하는 마음이 큰 장점입니다.",
          areas_to_improve: "첫 만남에서의 긴장감을 줄이고 좀 더 자신감을 가지면 좋겠습니다."
        },
        recommendations: {
          ideal_venues: [
            "조용한 카페나 티하우스",
            "브런치 레스토랑",
            "미술관이나 전시회",
            "공원에서 산책",
            "북카페"
          ],
          conversation_topics: [
            "취미와 관심사에 대한 이야기",
            "여행 경험과 가고 싶은 곳",
            "좋아하는 음식과 맛집",
            "최근에 본 영화나 드라마",
            "일상적인 소소한 이야기"
          ],
          style_tips: [
            "깔끔하고 단정한 옷차림",
            "너무 화려하지 않은 자연스러운 메이크업",
            "편안하면서도 매너있는 스타일",
            "상황에 맞는 적절한 액세서리"
          ],
          behavior_tips: [
            "진솔한 모습으로 대화하기",
            "상대방의 이야기에 집중하고 공감하기",
            "적절한 아이컨택 유지하기",
            "자연스러운 미소 짓기",
            "휴대폰 사용 자제하기"
          ]
        },
        timeline: {
          best_timing: "오후 2-4시 또는 저녁 6-8시",
          preparation_period: "만남 1주일 전부터 컨디션 관리",
          success_indicators: [
            "대화가 자연스럽게 이어짐",
            "서로 웃음이 많아짐",
            "시간 가는 줄 모름",
            "다음 만남에 대한 언급"
          ]
        },
        warnings: [
          "과도한 기대는 금물",
          "첫 만남에서 너무 개인적인 질문 피하기",
          "과거 연애 이야기는 신중하게",
          "상대방을 평가하려는 태도 지양"
        ]
      };
    }
  };

  const handleSubmit = async () => {
    if (!formData.name || !formData.age || !formData.experience_level || !formData.preferred_activity) {
      alert('필수 정보를 모두 입력해주세요.');
      return;
    }

    setLoading(true);
    
    try {
      await new Promise(resolve => setTimeout(resolve, 2000));
      const analysisResult = await analyzeBlindDate();
      setResult(analysisResult);
      setStep('result');
    } catch (error) {
      console.error('분석 중 오류:', error);
      alert('분석 중 오류가 발생했습니다. 다시 시도해주세요.');
    } finally {
      setLoading(false);
    }
  };

  const handlePersonalityChange = (personality: string, checked: boolean) => {
    if (checked) {
      setFormData(prev => ({
        ...prev,
        personality: [...prev.personality, personality]
      }));
    } else {
      setFormData(prev => ({
        ...prev,
        personality: prev.personality.filter(p => p !== personality)
      }));
    }
  };

  const handleReset = () => {
    setStep('input');
    setResult(null);
    setFormData({
      name: '',
      age: '',
      job: '',
      personality: [],
      ideal_type: '',
      experience_level: '',
      preferred_location: '',
      preferred_activity: '',
      concerns: ''
    });
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-orange-50 via-white to-amber-50 pb-32">
      <AppHeader title="소개팅 운세" />
      
      <motion.div
        variants={containerVariants}
        initial="hidden"
        animate="visible"
        className="px-6 pt-6"
      >
        <AnimatePresence mode="wait">
          {step === 'input' && (
            <motion.div
              key="input"
              initial={{ opacity: 0, x: -50 }}
              animate={{ opacity: 1, x: 0 }}
              exit={{ opacity: 0, x: 50 }}
              className="space-y-6"
            >
              {/* 헤더 */}
              <motion.div variants={itemVariants} className="text-center mb-8">
                <motion.div
                  className="bg-gradient-to-r from-orange-500 to-amber-500 rounded-full w-20 h-20 flex items-center justify-center mx-auto mb-4"
                  whileHover={{ rotate: 360 }}
                  transition={{ duration: 0.8 }}
                >
                  <Coffee className="w-10 h-10 text-white" />
                </motion.div>
                <h1 className="text-2xl font-bold text-gray-900 mb-2">소개팅 운세</h1>
                <p className="text-gray-600">당신의 소개팅 성공률과 맞춤 조언을 확인해보세요</p>
              </motion.div>

              {/* 기본 정보 */}
              <motion.div variants={itemVariants}>
                <Card className="border-orange-200">
                  <CardHeader className="pb-4">
                    <CardTitle className="flex items-center gap-2 text-orange-700">
                      <Users className="w-5 h-5" />
                      기본 정보
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div>
                      <Label htmlFor="name">이름</Label>
                      <Input
                        id="name"
                        placeholder="이름을 입력하세요"
                        value={formData.name}
                        onChange={(e) => setFormData(prev => ({ ...prev, name: e.target.value }))}
                        className="mt-1"
                      />
                    </div>
                    <div>
                      <Label htmlFor="age">나이</Label>
                      <Input
                        id="age"
                        type="number"
                        placeholder="나이를 입력하세요"
                        value={formData.age}
                        onChange={(e) => setFormData(prev => ({ ...prev, age: e.target.value }))}
                        className="mt-1"
                      />
                    </div>
                    <div>
                      <Label htmlFor="job">직업 (선택사항)</Label>
                      <Input
                        id="job"
                        placeholder="직업을 입력하세요"
                        value={formData.job}
                        onChange={(e) => setFormData(prev => ({ ...prev, job: e.target.value }))}
                        className="mt-1"
                      />
                    </div>
                  </CardContent>
                </Card>
              </motion.div>

              {/* 성격 */}
              <motion.div variants={itemVariants}>
                <Card className="border-orange-200">
                  <CardHeader className="pb-4">
                    <CardTitle className="flex items-center gap-2 text-orange-700">
                      <Smile className="w-5 h-5" />
                      성격 (복수 선택 가능)
                    </CardTitle>
                  </CardHeader>
                  <CardContent>
                    <div className="grid grid-cols-2 gap-3">
                      {personalityOptions.map((personality) => (
                        <div key={personality} className="flex items-center space-x-2">
                          <Checkbox
                            id={personality}
                            checked={formData.personality.includes(personality)}
                            onCheckedChange={(checked) => 
                              handlePersonalityChange(personality, checked as boolean)
                            }
                          />
                          <Label htmlFor={personality} className="text-sm">
                            {personality}
                          </Label>
                        </div>
                      ))}
                    </div>
                  </CardContent>
                </Card>
              </motion.div>

              {/* 이상형 */}
              <motion.div variants={itemVariants}>
                <Card className="border-orange-200">
                  <CardHeader className="pb-4">
                    <CardTitle className="flex items-center gap-2 text-orange-700">
                      <Heart className="w-5 h-5" />
                      이상형과 경험
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div>
                      <Label htmlFor="ideal-type">어떤 사람과 만나고 싶으신가요?</Label>
                      <Textarea
                        id="ideal-type"
                        placeholder="성격, 외모, 취미 등 자유롭게 적어주세요"
                        value={formData.ideal_type}
                        onChange={(e) => setFormData(prev => ({ ...prev, ideal_type: e.target.value }))}
                        className="mt-1 min-h-[80px]"
                      />
                    </div>
                    <div>
                      <Label htmlFor="experience">소개팅 경험</Label>
                      <RadioGroup 
                        value={formData.experience_level} 
                        onValueChange={(value) => setFormData(prev => ({ ...prev, experience_level: value }))}
                        className="mt-2"
                      >
                        <div className="flex items-center space-x-2">
                          <RadioGroupItem value="first-time" id="first-time" />
                          <Label htmlFor="first-time">첫 소개팅</Label>
                        </div>
                        <div className="flex items-center space-x-2">
                          <RadioGroupItem value="few-times" id="few-times" />
                          <Label htmlFor="few-times">몇 번 해봤음</Label>
                        </div>
                        <div className="flex items-center space-x-2">
                          <RadioGroupItem value="experienced" id="experienced" />
                          <Label htmlFor="experienced">많은 경험 있음</Label>
                        </div>
                      </RadioGroup>
                    </div>
                  </CardContent>
                </Card>
              </motion.div>

              {/* 선호사항 */}
              <motion.div variants={itemVariants}>
                <Card className="border-orange-200">
                  <CardHeader className="pb-4">
                    <CardTitle className="flex items-center gap-2 text-orange-700">
                      <MapPin className="w-5 h-5" />
                      선호 장소와 활동
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div>
                      <Label htmlFor="location">선호하는 만남 장소</Label>
                      <RadioGroup 
                        value={formData.preferred_location} 
                        onValueChange={(value) => setFormData(prev => ({ ...prev, preferred_location: value }))}
                        className="mt-2"
                      >
                        <div className="flex items-center space-x-2">
                          <RadioGroupItem value="cafe" id="cafe" />
                          <Label htmlFor="cafe">카페</Label>
                        </div>
                        <div className="flex items-center space-x-2">
                          <RadioGroupItem value="restaurant" id="restaurant" />
                          <Label htmlFor="restaurant">레스토랑</Label>
                        </div>
                        <div className="flex items-center space-x-2">
                          <RadioGroupItem value="cultural" id="cultural" />
                          <Label htmlFor="cultural">문화공간 (미술관, 전시회 등)</Label>
                        </div>
                        <div className="flex items-center space-x-2">
                          <RadioGroupItem value="outdoor" id="outdoor" />
                          <Label htmlFor="outdoor">야외 (공원, 산책로 등)</Label>
                        </div>
                        <div className="flex items-center space-x-2">
                          <RadioGroupItem value="activity" id="activity" />
                          <Label htmlFor="activity">액티비티 (볼링, 영화 등)</Label>
                        </div>
                      </RadioGroup>
                    </div>
                    <div>
                      <Label htmlFor="activity">어떤 활동을 하고 싶으신가요?</Label>
                      <RadioGroup 
                        value={formData.preferred_activity} 
                        onValueChange={(value) => setFormData(prev => ({ ...prev, preferred_activity: value }))}
                        className="mt-2"
                      >
                        <div className="flex items-center space-x-2">
                          <RadioGroupItem value="conversation" id="conversation" />
                          <Label htmlFor="conversation">대화 위주</Label>
                        </div>
                        <div className="flex items-center space-x-2">
                          <RadioGroupItem value="light-activity" id="light-activity" />
                          <Label htmlFor="light-activity">가벼운 활동 (산책 등)</Label>
                        </div>
                        <div className="flex items-center space-x-2">
                          <RadioGroupItem value="experience" id="experience" />
                          <Label htmlFor="experience">체험 활동 (만들기, 게임 등)</Label>
                        </div>
                        <div className="flex items-center space-x-2">
                          <RadioGroupItem value="cultural-activity" id="cultural-activity" />
                          <Label htmlFor="cultural-activity">문화 활동 (영화, 전시 등)</Label>
                        </div>
                      </RadioGroup>
                    </div>
                  </CardContent>
                </Card>
              </motion.div>

              {/* 고민사항 */}
              <motion.div variants={itemVariants}>
                <Card className="border-orange-200">
                  <CardHeader className="pb-4">
                    <CardTitle className="flex items-center gap-2 text-orange-700">
                      <MessageCircle className="w-5 h-5" />
                      고민이나 걱정 (선택사항)
                    </CardTitle>
                  </CardHeader>
                  <CardContent>
                    <Label htmlFor="concerns">소개팅에 대한 걱정이나 궁금한 점이 있다면 적어주세요</Label>
                    <Textarea
                      id="concerns"
                      placeholder="예: 대화가 끊길까 봐 걱정, 어떤 옷을 입어야 할지 모르겠음, 너무 긴장됨 등..."
                      value={formData.concerns}
                      onChange={(e) => setFormData(prev => ({ ...prev, concerns: e.target.value }))}
                      className="mt-2 min-h-[80px]"
                    />
                  </CardContent>
                </Card>
              </motion.div>

              {/* 분석 버튼 */}
              <motion.div variants={itemVariants} className="pt-4">
                <Button
                  onClick={handleSubmit}
                  disabled={loading}
                  className="w-full bg-gradient-to-r from-orange-500 to-amber-500 hover:from-orange-600 hover:to-amber-600 text-white py-6 text-lg font-semibold"
                >
                  {loading ? (
                    <motion.div
                      animate={{ rotate: 360 }}
                      transition={{ repeat: Infinity, duration: 1 }}
                      className="flex items-center gap-2"
                    >
                      <Shuffle className="w-5 h-5" />
                      분석 중...
                    </motion.div>
                  ) : (
                    <div className="flex items-center gap-2">
                      <Sparkles className="w-5 h-5" />
                      소개팅 운세 보기
                    </div>
                  )}
                </Button>
              </motion.div>
            </motion.div>
          )}

          {step === 'result' && result && (
            <motion.div
              key="result"
              initial={{ opacity: 0, x: 50 }}
              animate={{ opacity: 1, x: 0 }}
              exit={{ opacity: 0, x: -50 }}
              className="space-y-6"
            >
              {/* 전체 성공률 */}
              <motion.div variants={itemVariants}>
                <Card className="bg-gradient-to-r from-orange-500 to-amber-500 text-white">
                  <CardContent className="text-center py-8">
                    <div className="flex items-center justify-center gap-2 mb-4">
                      <Coffee className="w-6 h-6" />
                      <span className="text-xl font-medium">{formData.name}님의 소개팅</span>
                    </div>
                    <p className="text-white/90 text-lg mb-4">성공 가능성</p>
                    <motion.div
                      initial={{ scale: 0 }}
                      animate={{ scale: 1 }}
                      transition={{ delay: 0.3, type: "spring" }}
                      className="text-6xl font-bold mb-2"
                    >
                      {result.success_rate}%
                    </motion.div>
                    <Badge variant="secondary" className="bg-white/20 text-white border-white/30">
                      {getScoreText(result.success_rate)}
                    </Badge>
                  </CardContent>
                </Card>
              </motion.div>

              {/* 세부 분석 */}
              <motion.div variants={itemVariants}>
                <Card>
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2">
                      <TrendingUp className="w-5 h-5 text-orange-600" />
                      세부 분석 결과
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    {[
                      { label: "호감도", score: result.impression_score, icon: Heart, desc: "첫인상과 매력도" },
                      { label: "케미", score: result.chemistry_score, icon: Sparkles, desc: "상대방과의 궁합" },
                      { label: "대화력", score: result.conversation_score, icon: MessageCircle, desc: "대화의 자연스러움" }
                    ].map((item, index) => (
                      <motion.div
                        key={item.label}
                        initial={{ x: -20, opacity: 0 }}
                        animate={{ x: 0, opacity: 1 }}
                        transition={{ delay: 0.4 + index * 0.1 }}
                        className="space-y-2"
                      >
                        <div className="flex items-center gap-3">
                          <item.icon className="w-5 h-5 text-gray-600" />
                          <div className="flex-1">
                            <div className="flex justify-between items-center mb-1">
                              <div>
                                <span className="font-medium">{item.label}</span>
                                <p className="text-xs text-gray-500">{item.desc}</p>
                              </div>
                              <span className={`px-3 py-1 rounded-full text-sm font-medium ${getScoreColor(item.score)}`}>
                                {item.score}점
                              </span>
                            </div>
                            <div className="w-full bg-gray-200 rounded-full h-2">
                              <motion.div
                                className="bg-orange-500 h-2 rounded-full"
                                initial={{ width: 0 }}
                                animate={{ width: `${item.score}%` }}
                                transition={{ delay: 0.5 + index * 0.1, duration: 0.8 }}
                              />
                            </div>
                          </div>
                        </div>
                      </motion.div>
                    ))}
                  </CardContent>
                </Card>
              </motion.div>

              {/* 성격 분석 */}
              <motion.div variants={itemVariants}>
                <Card>
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2 text-orange-600">
                      <Users className="w-5 h-5" />
                      성격 분석
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div className="grid gap-4">
                      <div className="p-4 bg-orange-50 rounded-lg">
                        <h4 className="font-medium text-orange-800 mb-2">성격 분석</h4>
                        <p className="text-gray-700">{result.insights.personality_analysis}</p>
                      </div>
                      <div className="p-4 bg-green-50 rounded-lg">
                        <h4 className="font-medium text-green-800 mb-2">당신의 장점</h4>
                        <p className="text-gray-700">{result.insights.strengths}</p>
                      </div>
                      <div className="p-4 bg-blue-50 rounded-lg">
                        <h4 className="font-medium text-blue-800 mb-2">개선하면 좋을 점</h4>
                        <p className="text-gray-700">{result.insights.areas_to_improve}</p>
                      </div>
                    </div>
                  </CardContent>
                </Card>
              </motion.div>

              {/* 추천 장소 */}
              <motion.div variants={itemVariants}>
                <Card>
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2 text-green-600">
                      <MapPin className="w-5 h-5" />
                      추천 장소
                    </CardTitle>
                  </CardHeader>
                  <CardContent>
                    <div className="space-y-2">
                      {result.recommendations.ideal_venues.map((venue, index) => (
                        <motion.div
                          key={index}
                          initial={{ opacity: 0, x: -10 }}
                          animate={{ opacity: 1, x: 0 }}
                          transition={{ delay: 0.6 + index * 0.1 }}
                          className="flex items-start gap-2"
                        >
                          <MapPin className="w-4 h-4 text-green-500 mt-0.5 flex-shrink-0" />
                          <p className="text-gray-700">{venue}</p>
                        </motion.div>
                      ))}
                    </div>
                  </CardContent>
                </Card>
              </motion.div>

              {/* 대화 주제 */}
              <motion.div variants={itemVariants}>
                <Card>
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2 text-blue-600">
                      <MessageCircle className="w-5 h-5" />
                      추천 대화 주제
                    </CardTitle>
                  </CardHeader>
                  <CardContent>
                    <div className="space-y-2">
                      {result.recommendations.conversation_topics.map((topic, index) => (
                        <motion.div
                          key={index}
                          initial={{ opacity: 0, x: -10 }}
                          animate={{ opacity: 1, x: 0 }}
                          transition={{ delay: 0.8 + index * 0.1 }}
                          className="flex items-start gap-2"
                        >
                          <MessageCircle className="w-4 h-4 text-blue-500 mt-0.5 flex-shrink-0" />
                          <p className="text-gray-700">{topic}</p>
                        </motion.div>
                      ))}
                    </div>
                  </CardContent>
                </Card>
              </motion.div>

              {/* 스타일 팁 */}
              <motion.div variants={itemVariants}>
                <Card>
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2 text-purple-600">
                      <Sparkles className="w-5 h-5" />
                      스타일 팁
                    </CardTitle>
                  </CardHeader>
                  <CardContent>
                    <div className="space-y-2">
                      {result.recommendations.style_tips.map((tip, index) => (
                        <motion.div
                          key={index}
                          initial={{ opacity: 0, x: -10 }}
                          animate={{ opacity: 1, x: 0 }}
                          transition={{ delay: 1.0 + index * 0.1 }}
                          className="flex items-start gap-2"
                        >
                          <Sparkles className="w-4 h-4 text-purple-500 mt-0.5 flex-shrink-0" />
                          <p className="text-gray-700">{tip}</p>
                        </motion.div>
                      ))}
                    </div>
                  </CardContent>
                </Card>
              </motion.div>

              {/* 행동 팁 */}
              <motion.div variants={itemVariants}>
                <Card>
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2 text-indigo-600">
                      <Lightbulb className="w-5 h-5" />
                      행동 가이드
                    </CardTitle>
                  </CardHeader>
                  <CardContent>
                    <div className="space-y-2">
                      {result.recommendations.behavior_tips.map((tip, index) => (
                        <motion.div
                          key={index}
                          initial={{ opacity: 0, x: -10 }}
                          animate={{ opacity: 1, x: 0 }}
                          transition={{ delay: 1.2 + index * 0.1 }}
                          className="flex items-start gap-2"
                        >
                          <Lightbulb className="w-4 h-4 text-indigo-500 mt-0.5 flex-shrink-0" />
                          <p className="text-gray-700">{tip}</p>
                        </motion.div>
                      ))}
                    </div>
                  </CardContent>
                </Card>
              </motion.div>

              {/* 주의사항 */}
              <motion.div variants={itemVariants}>
                <Card>
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2 text-amber-600">
                      <Calendar className="w-5 h-5" />
                      주의사항
                    </CardTitle>
                  </CardHeader>
                  <CardContent>
                    <div className="space-y-2">
                      {result.warnings.map((warning, index) => (
                        <motion.div
                          key={index}
                          initial={{ opacity: 0, x: -10 }}
                          animate={{ opacity: 1, x: 0 }}
                          transition={{ delay: 1.4 + index * 0.1 }}
                          className="flex items-start gap-2"
                        >
                          <Calendar className="w-4 h-4 text-amber-500 mt-0.5 flex-shrink-0" />
                          <p className="text-gray-700">{warning}</p>
                        </motion.div>
                      ))}
                    </div>
                  </CardContent>
                </Card>
              </motion.div>

              {/* 타이밍과 성공 지표 */}
              <motion.div variants={itemVariants}>
                <Card className="border-orange-200">
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2 text-orange-600">
                      <Clock className="w-5 h-5" />
                      베스트 타이밍
                    </CardTitle>
                  </CardHeader>
                  <CardContent>
                    <div className="space-y-4">
                      <div className="p-4 bg-orange-50 rounded-lg">
                        <h4 className="font-medium text-orange-800 mb-2">추천 시간대</h4>
                        <p className="text-gray-700">{result.timeline.best_timing}</p>
                      </div>
                      <div className="p-4 bg-amber-50 rounded-lg">
                        <h4 className="font-medium text-amber-800 mb-2">준비 기간</h4>
                        <p className="text-gray-700">{result.timeline.preparation_period}</p>
                      </div>
                      <div className="p-4 bg-green-50 rounded-lg">
                        <h4 className="font-medium text-green-800 mb-2">성공 신호들</h4>
                        <ul className="space-y-1">
                          {result.timeline.success_indicators.map((indicator, index) => (
                            <li key={index} className="text-gray-700 flex items-start gap-2">
                              <Star className="w-3 h-3 text-green-500 mt-1 flex-shrink-0" />
                              {indicator}
                            </li>
                          ))}
                        </ul>
                      </div>
                    </div>
                  </CardContent>
                </Card>
              </motion.div>

              {/* 다시 분석하기 버튼 */}
              <motion.div variants={itemVariants} className="pt-4">
                <Button
                  onClick={handleReset}
                  variant="outline"
                  className="w-full border-orange-300 text-orange-600 hover:bg-orange-50 py-3"
                >
                  <ArrowRight className="w-4 h-4 mr-2" />
                  다른 조건으로 분석하기
                </Button>
              </motion.div>
            </motion.div>
          )}
        </AnimatePresence>
      </motion.div>
    </div>
  );
} 