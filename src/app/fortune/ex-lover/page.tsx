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
import AppHeader from "@/components/AppHeader";
import { 
  HeartCrack, 
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
  Lightbulb
} from "lucide-react";

interface ExLoverInfo {
  name: string;
  relationship_duration: string;
  breakup_reason: string;
  time_since_breakup: string;
  feelings: string;
}

interface AnalysisResult {
  closure_score: number;
  reconciliation_chance: number;
  emotional_healing: number;
  future_relationship_impact: number;
  insights: {
    current_status: string;
    emotional_state: string;
    advice: string;
  };
  closure_activities: string[];
  warning_signs: string[];
  positive_aspects: string[];
  timeline: {
    healing_phase: string;
    duration: string;
    next_steps: string;
  };
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
  if (score >= 80) return "text-green-600 bg-green-50";
  if (score >= 60) return "text-blue-600 bg-blue-50";
  if (score >= 40) return "text-yellow-600 bg-yellow-50";
  return "text-red-600 bg-red-50";
};

const getScoreText = (score: number) => {
  if (score >= 80) return "매우 좋음";
  if (score >= 60) return "좋음";
  if (score >= 40) return "보통";
  return "관심 필요";
};

export default function ExLoverPage() {
  const [step, setStep] = useState<'input' | 'result'>('input');
  const [loading, setLoading] = useState(false);
  const [formData, setFormData] = useState<ExLoverInfo>({
    name: '',
    relationship_duration: '',
    breakup_reason: '',
    time_since_breakup: '',
    feelings: ''
  });
  const [result, setResult] = useState<AnalysisResult | null>(null);

  const analyzeExLover = async (): Promise<AnalysisResult> => {
    try {
      const response = await fetch('/api/fortune/ex-lover', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(formData),
      });

      if (!response.ok) {
        throw new Error('헤어진 애인 분석에 실패했습니다.');
      }

      const data = await response.json();
      return data.analysis || data;
    } catch (error) {
      console.error('GPT 연동 실패, 기본 데이터 사용:', error);
      
      // GPT 실패시 기본 로직
      const baseScore = Math.floor(Math.random() * 30) + 40;
      
      return {
        closure_score: Math.max(20, Math.min(100, baseScore + Math.floor(Math.random() * 20))),
        reconciliation_chance: Math.max(10, Math.min(90, baseScore + Math.floor(Math.random() * 30) - 15)),
        emotional_healing: Math.max(30, Math.min(100, baseScore + Math.floor(Math.random() * 25))),
        future_relationship_impact: Math.max(25, Math.min(95, baseScore + Math.floor(Math.random() * 20))),
        insights: {
          current_status: "현재 과거의 관계에 대한 감정적 정리가 어느 정도 진행되고 있습니다.",
          emotional_state: "여전히 그리움과 아쉬움이 남아있지만, 점차 자신만의 삶을 찾아가고 있는 상태입니다.",
          advice: "과거를 완전히 놓아주고 새로운 시작을 위한 준비를 하는 것이 좋겠습니다."
        },
        closure_activities: [
          "편지 쓰기 (보내지 않고 태우기)",
          "함께했던 추억의 물건 정리하기",
          "새로운 취미나 관심사 찾기",
          "친구들과의 시간 늘리기",
          "자기계발에 집중하기"
        ],
        warning_signs: [
          "계속해서 연락을 시도하고 싶은 충동",
          "SNS를 통한 지속적인 관찰",
          "공통 지인들을 통한 소식 확인",
          "비슷한 유형의 사람에게만 관심"
        ],
        positive_aspects: [
          "관계를 통해 자신에 대해 더 잘 알게 됨",
          "사랑하는 방법을 배웠음",
          "성숙한 이별을 경험함",
          "앞으로 더 건강한 관계를 맺을 수 있는 기반 마련"
        ],
        timeline: {
          healing_phase: "회복 진행 단계",
          duration: "3-6개월",
          next_steps: "새로운 관계에 대한 마음의 준비가 되어가는 시기"
        }
      };
    }
  };

  const handleSubmit = async () => {
    if (!formData.name || !formData.relationship_duration || !formData.breakup_reason || !formData.time_since_breakup) {
      alert('필수 정보를 모두 입력해주세요.');
      return;
    }

    setLoading(true);
    
    try {
      await new Promise(resolve => setTimeout(resolve, 2000));
      const analysisResult = await analyzeExLover();
      setResult(analysisResult);
      setStep('result');
    } catch (error) {
      console.error('분석 중 오류:', error);
      alert('분석 중 오류가 발생했습니다. 다시 시도해주세요.');
    } finally {
      setLoading(false);
    }
  };

  const handleReset = () => {
    setStep('input');
    setResult(null);
    setFormData({
      name: '',
      relationship_duration: '',
      breakup_reason: '',
      time_since_breakup: '',
      feelings: ''
    });
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-50 via-white to-gray-50 pb-20">
      <AppHeader title="헤어진 애인" />
      
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
                  className="bg-gradient-to-r from-slate-500 to-gray-500 rounded-full w-20 h-20 flex items-center justify-center mx-auto mb-4"
                  whileHover={{ rotate: 360 }}
                  transition={{ duration: 0.8 }}
                >
                  <HeartCrack className="w-10 h-10 text-white" />
                </motion.div>
                <h1 className="text-2xl font-bold text-gray-900 mb-2">헤어진 애인 분석</h1>
                <p className="text-gray-600">과거 연인과의 관계를 분석하고 현재 상황을 파악해보세요</p>
              </motion.div>

              {/* 기본 정보 */}
              <motion.div variants={itemVariants}>
                <Card className="border-slate-200">
                  <CardHeader className="pb-4">
                    <CardTitle className="flex items-center gap-2 text-slate-700">
                      <Heart className="w-5 h-5" />
                      기본 정보
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div>
                      <Label htmlFor="ex-name">헤어진 애인의 이름 (또는 별명)</Label>
                      <Input
                        id="ex-name"
                        placeholder="이름을 입력하세요"
                        value={formData.name}
                        onChange={(e) => setFormData(prev => ({ ...prev, name: e.target.value }))}
                        className="mt-1"
                      />
                    </div>
                    <div>
                      <Label htmlFor="duration">교제 기간</Label>
                      <RadioGroup 
                        value={formData.relationship_duration} 
                        onValueChange={(value) => setFormData(prev => ({ ...prev, relationship_duration: value }))}
                        className="mt-2"
                      >
                        <div className="flex items-center space-x-2">
                          <RadioGroupItem value="1-6months" id="1-6months" />
                          <Label htmlFor="1-6months">1-6개월</Label>
                        </div>
                        <div className="flex items-center space-x-2">
                          <RadioGroupItem value="6months-1year" id="6months-1year" />
                          <Label htmlFor="6months-1year">6개월-1년</Label>
                        </div>
                        <div className="flex items-center space-x-2">
                          <RadioGroupItem value="1-3years" id="1-3years" />
                          <Label htmlFor="1-3years">1-3년</Label>
                        </div>
                        <div className="flex items-center space-x-2">
                          <RadioGroupItem value="3years+" id="3years+" />
                          <Label htmlFor="3years+">3년 이상</Label>
                        </div>
                      </RadioGroup>
                    </div>
                  </CardContent>
                </Card>
              </motion.div>

              {/* 이별 정보 */}
              <motion.div variants={itemVariants}>
                <Card className="border-slate-200">
                  <CardHeader className="pb-4">
                    <CardTitle className="flex items-center gap-2 text-slate-700">
                      <Calendar className="w-5 h-5" />
                      이별 정보
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div>
                      <Label htmlFor="breakup-reason">헤어진 이유</Label>
                      <RadioGroup 
                        value={formData.breakup_reason} 
                        onValueChange={(value) => setFormData(prev => ({ ...prev, breakup_reason: value }))}
                        className="mt-2"
                      >
                        <div className="flex items-center space-x-2">
                          <RadioGroupItem value="mutual" id="mutual" />
                          <Label htmlFor="mutual">상호 합의</Label>
                        </div>
                        <div className="flex items-center space-x-2">
                          <RadioGroupItem value="i-broke-up" id="i-broke-up" />
                          <Label htmlFor="i-broke-up">내가 이별을 제안</Label>
                        </div>
                        <div className="flex items-center space-x-2">
                          <RadioGroupItem value="they-broke-up" id="they-broke-up" />
                          <Label htmlFor="they-broke-up">상대방이 이별을 제안</Label>
                        </div>
                        <div className="flex items-center space-x-2">
                          <RadioGroupItem value="cheating" id="cheating" />
                          <Label htmlFor="cheating">바람/배신</Label>
                        </div>
                        <div className="flex items-center space-x-2">
                          <RadioGroupItem value="distance" id="distance" />
                          <Label htmlFor="distance">거리/환경적 이유</Label>
                        </div>
                        <div className="flex items-center space-x-2">
                          <RadioGroupItem value="other" id="other" />
                          <Label htmlFor="other">기타</Label>
                        </div>
                      </RadioGroup>
                    </div>
                    
                    <div>
                      <Label htmlFor="time-since">헤어진 지 얼마나 됐나요?</Label>
                      <RadioGroup 
                        value={formData.time_since_breakup} 
                        onValueChange={(value) => setFormData(prev => ({ ...prev, time_since_breakup: value }))}
                        className="mt-2"
                      >
                        <div className="flex items-center space-x-2">
                          <RadioGroupItem value="1month" id="1month" />
                          <Label htmlFor="1month">1개월 이내</Label>
                        </div>
                        <div className="flex items-center space-x-2">
                          <RadioGroupItem value="1-3months" id="1-3months" />
                          <Label htmlFor="1-3months">1-3개월</Label>
                        </div>
                        <div className="flex items-center space-x-2">
                          <RadioGroupItem value="3-6months" id="3-6months" />
                          <Label htmlFor="3-6months">3-6개월</Label>
                        </div>
                        <div className="flex items-center space-x-2">
                          <RadioGroupItem value="6months-1year" id="6months-1year-since" />
                          <Label htmlFor="6months-1year-since">6개월-1년</Label>
                        </div>
                        <div className="flex items-center space-x-2">
                          <RadioGroupItem value="1year+" id="1year+" />
                          <Label htmlFor="1year+">1년 이상</Label>
                        </div>
                      </RadioGroup>
                    </div>
                  </CardContent>
                </Card>
              </motion.div>

              {/* 현재 감정 */}
              <motion.div variants={itemVariants}>
                <Card className="border-slate-200">
                  <CardHeader className="pb-4">
                    <CardTitle className="flex items-center gap-2 text-slate-700">
                      <MessageCircle className="w-5 h-5" />
                      현재 마음 상태
                    </CardTitle>
                  </CardHeader>
                  <CardContent>
                    <Label htmlFor="feelings">지금 그 사람에 대한 감정이나 생각을 자유롭게 적어주세요 (선택사항)</Label>
                    <Textarea
                      id="feelings"
                      placeholder="예: 아직도 그립다, 다시 만나고 싶다, 미안한 마음이 있다, 완전히 잊고 싶다 등..."
                      value={formData.feelings}
                      onChange={(e) => setFormData(prev => ({ ...prev, feelings: e.target.value }))}
                      className="mt-2 min-h-[100px]"
                    />
                  </CardContent>
                </Card>
              </motion.div>

              {/* 분석 버튼 */}
              <motion.div variants={itemVariants} className="pt-4">
                <Button
                  onClick={handleSubmit}
                  disabled={loading}
                  className="w-full bg-gradient-to-r from-slate-500 to-gray-500 hover:from-slate-600 hover:to-gray-600 text-white py-6 text-lg font-semibold"
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
                      관계 분석하기
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
              {/* 전체 분석 결과 */}
              <motion.div variants={itemVariants}>
                <Card className="bg-gradient-to-r from-slate-500 to-gray-500 text-white">
                  <CardContent className="text-center py-8">
                    <div className="flex items-center justify-center gap-2 mb-4">
                      <HeartCrack className="w-6 h-6" />
                      <span className="text-xl font-medium">{formData.name}님과의 관계</span>
                    </div>
                    <p className="text-white/90 text-lg mb-4">현재 감정 정리 상태</p>
                    <motion.div
                      initial={{ scale: 0 }}
                      animate={{ scale: 1 }}
                      transition={{ delay: 0.3, type: "spring" }}
                      className="text-6xl font-bold mb-2"
                    >
                      {result.closure_score}점
                    </motion.div>
                    <Badge variant="secondary" className="bg-white/20 text-white border-white/30">
                      {getScoreText(result.closure_score)}
                    </Badge>
                  </CardContent>
                </Card>
              </motion.div>

              {/* 세부 분석 */}
              <motion.div variants={itemVariants}>
                <Card>
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2">
                      <TrendingUp className="w-5 h-5 text-slate-600" />
                      세부 분석 결과
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    {[
                      { label: "감정 정리도", score: result.closure_score, icon: Heart, desc: "과거 관계에 대한 정리 정도" },
                      { label: "재결합 가능성", score: result.reconciliation_chance, icon: Users, desc: "다시 만날 수 있는 가능성" },
                      { label: "감정 치유도", score: result.emotional_healing, icon: Sparkles, desc: "상처로부터의 회복 정도" },
                      { label: "미래 관계 영향", score: result.future_relationship_impact, icon: TrendingUp, desc: "앞으로의 연애에 미치는 영향" }
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
                                className="bg-slate-500 h-2 rounded-full"
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

              {/* 현재 상태 분석 */}
              <motion.div variants={itemVariants}>
                <Card>
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2 text-slate-600">
                      <Clock className="w-5 h-5" />
                      현재 상태 분석
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div className="grid gap-4">
                      <div className="p-4 bg-slate-50 rounded-lg">
                        <h4 className="font-medium text-slate-800 mb-2">관계 상태</h4>
                        <p className="text-gray-700">{result.insights.current_status}</p>
                      </div>
                      <div className="p-4 bg-gray-50 rounded-lg">
                        <h4 className="font-medium text-gray-800 mb-2">감정 상태</h4>
                        <p className="text-gray-700">{result.insights.emotional_state}</p>
                      </div>
                    </div>
                  </CardContent>
                </Card>
              </motion.div>

              {/* 치유 활동 추천 */}
              <motion.div variants={itemVariants}>
                <Card>
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2 text-green-600">
                      <Lightbulb className="w-5 h-5" />
                      치유를 위한 활동
                    </CardTitle>
                  </CardHeader>
                  <CardContent>
                    <div className="space-y-2">
                      {result.closure_activities.map((activity, index) => (
                        <motion.div
                          key={index}
                          initial={{ opacity: 0, x: -10 }}
                          animate={{ opacity: 1, x: 0 }}
                          transition={{ delay: 0.6 + index * 0.1 }}
                          className="flex items-start gap-2"
                        >
                          <Star className="w-4 h-4 text-green-500 mt-0.5 flex-shrink-0" />
                          <p className="text-gray-700">{activity}</p>
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
                      주의해야 할 신호들
                    </CardTitle>
                  </CardHeader>
                  <CardContent>
                    <div className="space-y-2">
                      {result.warning_signs.map((warning, index) => (
                        <motion.div
                          key={index}
                          initial={{ opacity: 0, x: -10 }}
                          animate={{ opacity: 1, x: 0 }}
                          transition={{ delay: 0.8 + index * 0.1 }}
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

              {/* 긍정적 측면 */}
              <motion.div variants={itemVariants}>
                <Card>
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2 text-blue-600">
                      <Heart className="w-5 h-5" />
                      이 관계에서 얻은 것들
                    </CardTitle>
                  </CardHeader>
                  <CardContent>
                    <div className="space-y-2">
                      {result.positive_aspects.map((aspect, index) => (
                        <motion.div
                          key={index}
                          initial={{ opacity: 0, x: -10 }}
                          animate={{ opacity: 1, x: 0 }}
                          transition={{ delay: 1.0 + index * 0.1 }}
                          className="flex items-start gap-2"
                        >
                          <Heart className="w-4 h-4 text-blue-500 mt-0.5 flex-shrink-0" />
                          <p className="text-gray-700">{aspect}</p>
                        </motion.div>
                      ))}
                    </div>
                  </CardContent>
                </Card>
              </motion.div>

              {/* 조언 */}
              <motion.div variants={itemVariants}>
                <Card className="border-slate-200">
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2 text-slate-600">
                      <Sparkles className="w-5 h-5" />
                      앞으로의 방향
                    </CardTitle>
                  </CardHeader>
                  <CardContent>
                    <p className="text-gray-700 leading-relaxed mb-4">{result.insights.advice}</p>
                    <div className="p-4 bg-slate-50 rounded-lg">
                      <h4 className="font-medium text-slate-800 mb-2">현재 단계: {result.timeline.healing_phase}</h4>
                      <p className="text-sm text-gray-600 mb-2">예상 기간: {result.timeline.duration}</p>
                      <p className="text-sm text-gray-700">{result.timeline.next_steps}</p>
                    </div>
                  </CardContent>
                </Card>
              </motion.div>

              {/* 다시 분석하기 버튼 */}
              <motion.div variants={itemVariants} className="pt-4">
                <Button
                  onClick={handleReset}
                  variant="outline"
                  className="w-full border-slate-300 text-slate-600 hover:bg-slate-50 py-3"
                >
                  <ArrowRight className="w-4 h-4 mr-2" />
                  다른 관계 분석하기
                </Button>
              </motion.div>
            </motion.div>
          )}
        </AnimatePresence>
      </motion.div>
    </div>
  );
} 