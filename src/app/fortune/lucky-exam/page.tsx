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
import { 
  GraduationCap, 
  Calendar,
  Star, 
  Sparkles,
  ArrowRight,
  Shuffle,
  Clock,
  Award,
  BookOpen,
  Brain,
  Target,
  CheckCircle,
  AlertCircle,
  TrendingUp,
  Shield,
  Zap,
  Sun,
  Moon,
  Coffee,
  Timer,
  Trophy,
  PenTool,
  Users,
  MapPin,
  Lightbulb,
  Heart
} from "lucide-react";

interface ExamInfo {
  name: string;
  birth_date: string;
  exam_type: string;
  exam_subject: string[];
  exam_period_start: string;
  exam_period_end: string;
  preparation_level: string;
  study_style: string[];
  preferred_time: string[];
  exam_experience: string;
  stress_level: string;
  special_concerns: string;
  goals: string;
}

interface ExamFortune {
  overall_luck: number;
  concentration_luck: number;
  memory_luck: number;
  confidence_luck: number;
  timing_luck: number;
  best_dates: {
    date: string;
    day_of_week: string;
    luck_score: number;
    reasons: string[];
  }[];
  best_times: {
    time: string;
    period: string;
    energy_level: string;
    focus_index: number;
  }[];
  preparation_guide: {
    final_week: string[];
    day_before: string[];
    exam_day: string[];
    mindset_tips: string[];
  };
  lucky_elements: {
    colors: string[];
    numbers: number[];
    items: string[];
    foods: string[];
  };
  biorhythm_analysis: {
    physical: number;
    emotional: number;
    intellectual: number;
    overall_trend: string;
  };
  warning_dates: string[];
  success_factors: string[];
}

const examTypes = [
  "수능", "공무원", "자격증", "대학원", "취업", "편입", "토익/토플", "한능검",
  "기사/산업기사", "의료진", "금융", "IT", "교원", "변리사", "회계사", "세무사"
];

const examSubjects = [
  "국어", "영어", "수학", "과학", "사회", "한국사", "논술", "면접",
  "컴퓨터", "경영", "회계", "법학", "의학", "공학", "교육학", "심리학"
];

const studyStyles = [
  "혼자 집중", "그룹 스터디", "카페 공부", "도서관", "인강 수강", "과외/학원",
  "문제풀이 위주", "이론 정리", "암기 위주", "이해 위주", "실전 연습", "모의고사"
];

const preferredTimes = [
  "새벽(4-7시)", "오전(7-10시)", "늦은 오전(10-12시)", "오후(12-15시)",
  "늦은 오후(15-18시)", "저녁(18-21시)", "밤(21-24시)", "심야(24-3시)"
];

const getLuckColor = (score: number) => {
  if (score >= 85) return "text-green-600 bg-green-50";
  if (score >= 70) return "text-blue-600 bg-blue-50";
  if (score >= 55) return "text-orange-600 bg-orange-50";
  return "text-red-600 bg-red-50";
};

const getLuckText = (score: number) => {
  if (score >= 85) return "합격 대운";
  if (score >= 70) return "상승 운세";
  if (score >= 55) return "안정 운세";
  return "신중 필요";
};

export default function LuckyExamPage() {
  const [step, setStep] = useState<'input' | 'result'>('input');
  const [loading, setLoading] = useState(false);
  const [formData, setFormData] = useState<ExamInfo>({
    name: '',
    birth_date: '',
    exam_type: '',
    exam_subject: [],
    exam_period_start: '',
    exam_period_end: '',
    preparation_level: '',
    study_style: [],
    preferred_time: [],
    exam_experience: '',
    stress_level: '',
    special_concerns: '',
    goals: ''
  });
  const [result, setResult] = useState<ExamFortune | null>(null);

  const analyzeExamFortune = async (): Promise<ExamFortune> => {
    const baseScore = Math.floor(Math.random() * 25) + 65;
    
    // 시험 기간 내 랜덤 날짜 생성
    const startDate = new Date(formData.exam_period_start);
    const endDate = new Date(formData.exam_period_end);
    const dateDiff = Math.floor((endDate.getTime() - startDate.getTime()) / (1000 * 60 * 60 * 24));
    
    const bestDates = [];
    for (let i = 0; i < Math.min(5, dateDiff + 1); i++) {
      const randomDays = Math.floor(Math.random() * (dateDiff + 1));
      const date = new Date(startDate);
      date.setDate(date.getDate() + randomDays);
      
      const dayNames = ['일', '월', '화', '수', '목', '금', '토'];
      const dayOfWeek = dayNames[date.getDay()];
      
      bestDates.push({
        date: date.toISOString().split('T')[0],
        day_of_week: dayOfWeek,
        luck_score: Math.floor(Math.random() * 25) + 75,
        reasons: [
          "집중력이 최고조에 달하는 날",
          "기억력과 판단력이 향상되는 시기",
          "심리적 안정감이 높아지는 날"
        ].slice(0, Math.floor(Math.random() * 3) + 1)
      });
    }

    return {
      overall_luck: Math.max(50, Math.min(95, baseScore + Math.floor(Math.random() * 15))),
      concentration_luck: Math.max(45, Math.min(100, baseScore + Math.floor(Math.random() * 20) - 5)),
      memory_luck: Math.max(40, Math.min(95, baseScore + Math.floor(Math.random() * 20) - 10)),
      confidence_luck: Math.max(50, Math.min(100, baseScore + Math.floor(Math.random() * 15))),
      timing_luck: Math.max(55, Math.min(95, baseScore + Math.floor(Math.random() * 20) - 5)),
      best_dates: bestDates.sort((a, b) => b.luck_score - a.luck_score).slice(0, 3),
      best_times: [
        {
          time: "09:00-12:00",
          period: "오전",
          energy_level: "최고",
          focus_index: 95
        },
        {
          time: "14:00-17:00", 
          period: "오후",
          energy_level: "높음",
          focus_index: 88
        },
        {
          time: "10:00-13:00",
          period: "늦은 오전",
          energy_level: "좋음",
          focus_index: 82
        }
      ],
      preparation_guide: {
        final_week: [
          "핵심 내용만 반복 학습하기",
          "새로운 내용 공부는 자제하기",
          "충분한 수면으로 컨디션 관리",
          "가벼운 운동으로 스트레스 해소",
          "시험 당일 일정 미리 점검"
        ],
        day_before: [
          "일찍 잠자리에 들기",
          "시험 준비물 미리 챙기기",
          "시험장 위치와 교통편 확인",
          "무거운 식사 피하기",
          "긍정적인 마음가짐 유지"
        ],
        exam_day: [
          "여유있게 일찍 출발하기",
          "가벼운 아침식사 하기",
          "시험 시작 전 심호흡하기",
          "문제를 차근차근 읽기",
          "시간 배분 철저히 하기"
        ],
        mindset_tips: [
          "완벽보다는 최선을 다하는 마음",
          "실수해도 다음 문제에 집중",
          "평소 실력을 믿고 자신감 갖기",
          "긴장될 때는 깊게 숨쉬기",
          "합격에 대한 긍정적 이미지 그리기"
        ]
      },
      lucky_elements: {
        colors: ["파란색", "초록색", "흰색"].slice().sort(() => 0.5 - Math.random()).slice(0, 2),
        numbers: [3, 7, 9, 13, 21].slice().sort(() => 0.5 - Math.random()).slice(0, 3),
        items: ["펜", "지우개", "시계", "물", "초콜릿"].slice().sort(() => 0.5 - Math.random()).slice(0, 3),
        foods: ["견과류", "바나나", "블루베리", "다크초콜릿"].slice().sort(() => 0.5 - Math.random()).slice(0, 2)
      },
      biorhythm_analysis: {
        physical: Math.floor(Math.random() * 40) + 60,
        emotional: Math.floor(Math.random() * 40) + 60,
        intellectual: Math.floor(Math.random() * 40) + 60,
        overall_trend: "상승세"
      },
      warning_dates: [],
      success_factors: [
        "꾸준한 학습 습관",
        "체계적인 시간 관리",
        "긍정적인 마음가짐",
        "건강한 생활 리듬",
        "적절한 휴식과 스트레스 관리"
      ]
    };
  };

  const handleSubmit = async () => {
    if (!formData.name || !formData.birth_date || !formData.exam_type || !formData.exam_period_start) {
      alert('필수 정보를 모두 입력해주세요.');
      return;
    }

    setLoading(true);
    
    try {
      await new Promise(resolve => setTimeout(resolve, 3000));
      const analysisResult = await analyzeExamFortune();
      setResult(analysisResult);
      setStep('result');
    } catch (error) {
      console.error('분석 중 오류:', error);
      alert('분석 중 오류가 발생했습니다. 다시 시도해주세요.');
    } finally {
      setLoading(false);
    }
  };

  const handleCheckboxChange = (value: string, checked: boolean, field: keyof Pick<ExamInfo, 'exam_subject' | 'study_style' | 'preferred_time'>) => {
    setFormData(prev => ({
      ...prev,
      [field]: checked 
        ? [...prev[field], value]
        : prev[field].filter(item => item !== value)
    }));
  };

  const handleReset = () => {
    setStep('input');
    setResult(null);
    setFormData({
      name: '',
      birth_date: '',
      exam_type: '',
      exam_subject: [],
      exam_period_start: '',
      exam_period_end: '',
      preparation_level: '',
      study_style: [],
      preferred_time: [],
      exam_experience: '',
      stress_level: '',
      special_concerns: '',
      goals: ''
    });
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-emerald-50 via-green-25 to-teal-50 pb-32">
      <AppHeader title="행운의 시험일자" />
      
      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
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
              <div className="text-center mb-8">
                <motion.div
                  className="bg-gradient-to-r from-emerald-500 to-green-500 rounded-full w-20 h-20 flex items-center justify-center mx-auto mb-4"
                  whileHover={{ scale: 1.1 }}
                  transition={{ duration: 0.3 }}
                >
                  <GraduationCap className="w-10 h-10 text-white" />
                </motion.div>
                <h1 className="text-2xl font-bold text-gray-900 mb-2">행운의 시험일자</h1>
                <p className="text-gray-600">합격을 부르는 최적의 시험 날짜를 찾아보세요</p>
              </div>

              {/* 기본 정보 */}
              <Card className="border-emerald-200">
                <CardHeader className="pb-4">
                  <CardTitle className="flex items-center gap-2 text-emerald-700">
                    <Users className="w-5 h-5" />
                    기본 정보
                  </CardTitle>
                </CardHeader>
                <CardContent className="space-y-4">
                  <div className="grid grid-cols-2 gap-4">
                    <div>
                      <Label htmlFor="name">이름</Label>
                      <Input
                        id="name"
                        placeholder="이름"
                        value={formData.name}
                        onChange={(e) => setFormData(prev => ({ ...prev, name: e.target.value }))}
                        className="mt-1"
                      />
                    </div>
                    <div>
                      <Label htmlFor="birth_date">생년월일</Label>
                      <Input
                        id="birth_date"
                        type="date"
                        value={formData.birth_date}
                        onChange={(e) => setFormData(prev => ({ ...prev, birth_date: e.target.value }))}
                        className="mt-1"
                      />
                    </div>
                  </div>
                </CardContent>
              </Card>

              {/* 시험 정보 */}
              <Card className="border-green-200">
                <CardHeader className="pb-4">
                  <CardTitle className="flex items-center gap-2 text-green-700">
                    <BookOpen className="w-5 h-5" />
                    시험 정보
                  </CardTitle>
                </CardHeader>
                <CardContent className="space-y-4">
                  <div>
                    <Label>시험 종류</Label>
                    <RadioGroup 
                      value={formData.exam_type} 
                      onValueChange={(value) => setFormData(prev => ({ ...prev, exam_type: value }))}
                      className="mt-2"
                    >
                      <div className="grid grid-cols-3 gap-2">
                        {examTypes.map((type) => (
                          <div key={type} className="flex items-center space-x-2">
                            <RadioGroupItem value={type} id={type} />
                            <Label htmlFor={type} className="text-sm">{type}</Label>
                          </div>
                        ))}
                      </div>
                    </RadioGroup>
                  </div>
                  <div>
                    <Label>시험 과목 (복수 선택)</Label>
                    <div className="grid grid-cols-3 gap-2 mt-2">
                      {examSubjects.map((subject) => (
                        <div key={subject} className="flex items-center space-x-2">
                          <Checkbox
                            id={subject}
                            checked={formData.exam_subject.includes(subject)}
                            onCheckedChange={(checked) => 
                              handleCheckboxChange(subject, checked as boolean, 'exam_subject')
                            }
                          />
                          <Label htmlFor={subject} className="text-sm">{subject}</Label>
                        </div>
                      ))}
                    </div>
                  </div>
                  <div className="grid grid-cols-2 gap-4">
                    <div>
                      <Label htmlFor="exam_period_start">시험 기간 시작일</Label>
                      <Input
                        id="exam_period_start"
                        type="date"
                        value={formData.exam_period_start}
                        onChange={(e) => setFormData(prev => ({ ...prev, exam_period_start: e.target.value }))}
                        className="mt-1"
                      />
                    </div>
                    <div>
                      <Label htmlFor="exam_period_end">시험 기간 종료일</Label>
                      <Input
                        id="exam_period_end"
                        type="date"
                        value={formData.exam_period_end}
                        onChange={(e) => setFormData(prev => ({ ...prev, exam_period_end: e.target.value }))}
                        className="mt-1"
                      />
                    </div>
                  </div>
                </CardContent>
              </Card>

              {/* 준비 상태 */}
              <Card className="border-teal-200">
                <CardHeader className="pb-4">
                  <CardTitle className="flex items-center gap-2 text-teal-700">
                    <Target className="w-5 h-5" />
                    준비 상태 & 학습 스타일
                  </CardTitle>
                </CardHeader>
                <CardContent className="space-y-4">
                  <div>
                    <Label>현재 준비 수준</Label>
                    <RadioGroup 
                      value={formData.preparation_level} 
                      onValueChange={(value) => setFormData(prev => ({ ...prev, preparation_level: value }))}
                      className="mt-2"
                    >
                      <div className="flex items-center space-x-2">
                        <RadioGroupItem value="완벽" id="완벽" />
                        <Label htmlFor="완벽">완벽 (90% 이상)</Label>
                      </div>
                      <div className="flex items-center space-x-2">
                        <RadioGroupItem value="충분" id="충분" />
                        <Label htmlFor="충분">충분 (70-90%)</Label>
                      </div>
                      <div className="flex items-center space-x-2">
                        <RadioGroupItem value="보통" id="보통" />
                        <Label htmlFor="보통">보통 (50-70%)</Label>
                      </div>
                      <div className="flex items-center space-x-2">
                        <RadioGroupItem value="부족" id="부족" />
                        <Label htmlFor="부족">부족 (50% 미만)</Label>
                      </div>
                    </RadioGroup>
                  </div>
                  <div>
                    <Label>학습 스타일 (복수 선택)</Label>
                    <div className="grid grid-cols-3 gap-2 mt-2">
                      {studyStyles.map((style) => (
                        <div key={style} className="flex items-center space-x-2">
                          <Checkbox
                            id={style}
                            checked={formData.study_style.includes(style)}
                            onCheckedChange={(checked) => 
                              handleCheckboxChange(style, checked as boolean, 'study_style')
                            }
                          />
                          <Label htmlFor={style} className="text-sm">{style}</Label>
                        </div>
                      ))}
                    </div>
                  </div>
                  <div>
                    <Label>선호하는 시험 시간 (복수 선택)</Label>
                    <div className="grid grid-cols-2 gap-2 mt-2">
                      {preferredTimes.map((time) => (
                        <div key={time} className="flex items-center space-x-2">
                          <Checkbox
                            id={time}
                            checked={formData.preferred_time.includes(time)}
                            onCheckedChange={(checked) => 
                              handleCheckboxChange(time, checked as boolean, 'preferred_time')
                            }
                          />
                          <Label htmlFor={time} className="text-sm">{time}</Label>
                        </div>
                      ))}
                    </div>
                  </div>
                </CardContent>
              </Card>

              {/* 심리 상태 */}
              <Card className="border-emerald-200">
                <CardHeader className="pb-4">
                  <CardTitle className="flex items-center gap-2 text-emerald-700">
                    <Heart className="w-5 h-5" />
                    심리 상태 & 목표
                  </CardTitle>
                </CardHeader>
                <CardContent className="space-y-4">
                  <div>
                    <Label>시험 경험</Label>
                    <RadioGroup 
                      value={formData.exam_experience} 
                      onValueChange={(value) => setFormData(prev => ({ ...prev, exam_experience: value }))}
                      className="mt-2"
                    >
                      <div className="flex items-center space-x-2">
                        <RadioGroupItem value="많음" id="많음" />
                        <Label htmlFor="많음">많음 (5회 이상)</Label>
                      </div>
                      <div className="flex items-center space-x-2">
                        <RadioGroupItem value="보통" id="경험보통" />
                        <Label htmlFor="경험보통">보통 (2-5회)</Label>
                      </div>
                      <div className="flex items-center space-x-2">
                        <RadioGroupItem value="적음" id="적음" />
                        <Label htmlFor="적음">적음 (1-2회)</Label>
                      </div>
                      <div className="flex items-center space-x-2">
                        <RadioGroupItem value="처음" id="처음" />
                        <Label htmlFor="처음">처음</Label>
                      </div>
                    </RadioGroup>
                  </div>
                  <div>
                    <Label>스트레스 수준</Label>
                    <RadioGroup 
                      value={formData.stress_level} 
                      onValueChange={(value) => setFormData(prev => ({ ...prev, stress_level: value }))}
                      className="mt-2"
                    >
                      <div className="flex items-center space-x-2">
                        <RadioGroupItem value="매우높음" id="매우높음" />
                        <Label htmlFor="매우높음">매우 높음</Label>
                      </div>
                      <div className="flex items-center space-x-2">
                        <RadioGroupItem value="높음" id="높음" />
                        <Label htmlFor="높음">높음</Label>
                      </div>
                      <div className="flex items-center space-x-2">
                        <RadioGroupItem value="보통스트레스" id="보통스트레스" />
                        <Label htmlFor="보통스트레스">보통</Label>
                      </div>
                      <div className="flex items-center space-x-2">
                        <RadioGroupItem value="낮음" id="낮음" />
                        <Label htmlFor="낮음">낮음</Label>
                      </div>
                    </RadioGroup>
                  </div>
                  <div>
                    <Label htmlFor="special_concerns">특별한 고민이나 우려사항</Label>
                    <Textarea
                      id="special_concerns"
                      placeholder="시간 부족, 암기 어려움, 집중력 부족, 시험 불안 등..."
                      value={formData.special_concerns}
                      onChange={(e) => setFormData(prev => ({ ...prev, special_concerns: e.target.value }))}
                      className="mt-1 min-h-[60px]"
                    />
                  </div>
                  <div>
                    <Label htmlFor="goals">시험 목표 및 기대점수</Label>
                    <Input
                      id="goals"
                      placeholder="예: 90점 이상, 1급 합격, 상위 10% 등..."
                      value={formData.goals}
                      onChange={(e) => setFormData(prev => ({ ...prev, goals: e.target.value }))}
                      className="mt-1"
                    />
                  </div>
                </CardContent>
              </Card>

              {/* 분석 버튼 */}
              <div className="pt-4">
                <Button
                  onClick={handleSubmit}
                  disabled={loading}
                  className="w-full bg-gradient-to-r from-emerald-500 to-green-500 hover:from-emerald-600 hover:to-green-600 text-white py-6 text-lg font-semibold"
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
                      <GraduationCap className="w-5 h-5" />
                      최적 시험일자 분석하기
                    </div>
                  )}
                </Button>
              </div>
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
              {/* 전체 운세 */}
              <Card className="bg-gradient-to-r from-emerald-500 to-green-500 text-white">
                <CardContent className="text-center py-8">
                  <div className="flex items-center justify-center gap-2 mb-4">
                    <GraduationCap className="w-6 h-6" />
                    <span className="text-xl font-medium">{formData.name}님의 시험 운세</span>
                  </div>
                  <motion.div
                    initial={{ scale: 0 }}
                    animate={{ scale: 1 }}
                    transition={{ delay: 0.3, type: "spring" }}
                    className="text-6xl font-bold mb-2"
                  >
                    {result.overall_luck}점
                  </motion.div>
                  <Badge variant="secondary" className="bg-white/20 text-white border-white/30">
                    {getLuckText(result.overall_luck)}
                  </Badge>
                </CardContent>
              </Card>

              {/* 세부 운세 */}
              <Card>
                <CardHeader>
                  <CardTitle className="flex items-center gap-2 text-emerald-600">
                    <Brain className="w-5 h-5" />
                    세부 시험 운세
                  </CardTitle>
                </CardHeader>
                <CardContent className="space-y-4">
                  {[
                    { label: "집중력", score: result.concentration_luck, icon: Target, desc: "문제에 몰입하고 집중하는 능력" },
                    { label: "기억력", score: result.memory_luck, icon: Brain, desc: "학습한 내용을 정확히 기억하는 능력" },
                    { label: "자신감", score: result.confidence_luck, icon: Trophy, desc: "시험에 임하는 심리적 안정감" },
                    { label: "타이밍", score: result.timing_luck, icon: Clock, desc: "최적의 시험 일정을 선택하는 운" }
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
                            <span className={`px-3 py-1 rounded-full text-sm font-medium ${getLuckColor(item.score)}`}>
                              {item.score}점
                            </span>
                          </div>
                          <div className="w-full bg-gray-200 rounded-full h-2">
                            <motion.div
                              className="bg-emerald-500 h-2 rounded-full"
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

              {/* 추천 시험 날짜 */}
              <Card>
                <CardHeader>
                  <CardTitle className="flex items-center gap-2 text-green-600">
                    <Calendar className="w-5 h-5" />
                    추천 시험 날짜 TOP 3
                  </CardTitle>
                </CardHeader>
                <CardContent className="space-y-4">
                  {result.best_dates.map((dateInfo, index) => (
                    <motion.div
                      key={index}
                      initial={{ opacity: 0, y: 10 }}
                      animate={{ opacity: 1, y: 0 }}
                      transition={{ delay: 0.6 + index * 0.1 }}
                      className="p-4 bg-gradient-to-r from-green-50 to-emerald-50 rounded-lg border border-green-200"
                    >
                      <div className="flex items-center justify-between mb-3">
                        <div className="flex items-center gap-3">
                          <Badge variant="secondary" className="bg-green-100 text-green-700">
                            {index + 1}순위
                          </Badge>
                          <div>
                            <p className="font-semibold text-gray-800">
                              {(() => {
                                const date = new Date(dateInfo.date);
                                return `${String(date.getFullYear()).padStart(4, '0')}년 ${String(date.getMonth() + 1).padStart(2, '0')}월 ${String(date.getDate()).padStart(2, '0')}일`;
                              })()}
                            </p>
                            <p className="text-sm text-gray-600">{dateInfo.day_of_week}요일</p>
                          </div>
                        </div>
                        <div className="text-right">
                          <p className="text-2xl font-bold text-green-600">{dateInfo.luck_score}점</p>
                          <p className="text-xs text-green-500">행운 지수</p>
                        </div>
                      </div>
                      <div className="space-y-1">
                        {dateInfo.reasons.map((reason, reasonIndex) => (
                          <div key={reasonIndex} className="flex items-center gap-2">
                            <CheckCircle className="w-4 h-4 text-green-500 flex-shrink-0" />
                            <p className="text-sm text-gray-700">{reason}</p>
                          </div>
                        ))}
                      </div>
                    </motion.div>
                  ))}
                </CardContent>
              </Card>

              {/* 최적 시험 시간 */}
              <Card>
                <CardHeader>
                  <CardTitle className="flex items-center gap-2 text-blue-600">
                    <Clock className="w-5 h-5" />
                    최적 시험 시간대
                  </CardTitle>
                </CardHeader>
                <CardContent className="space-y-3">
                  {result.best_times.map((timeInfo, index) => (
                    <motion.div
                      key={index}
                      initial={{ opacity: 0, x: -10 }}
                      animate={{ opacity: 1, x: 0 }}
                      transition={{ delay: 0.8 + index * 0.1 }}
                      className="p-3 bg-blue-50 rounded-lg"
                    >
                      <div className="flex items-center justify-between">
                        <div className="flex items-center gap-3">
                          <div className="p-2 bg-blue-100 rounded-full">
                            {timeInfo.period === "오전" ? <Sun className="w-4 h-4 text-blue-600" /> : 
                             timeInfo.period === "오후" ? <Coffee className="w-4 h-4 text-blue-600" /> :
                             <Moon className="w-4 h-4 text-blue-600" />}
                          </div>
                          <div>
                            <p className="font-medium text-blue-800">{timeInfo.time}</p>
                            <p className="text-sm text-blue-600">{timeInfo.period} • {timeInfo.energy_level} 에너지</p>
                          </div>
                        </div>
                        <div className="text-right">
                          <p className="text-lg font-bold text-blue-600">{timeInfo.focus_index}%</p>
                          <p className="text-xs text-blue-500">집중력</p>
                        </div>
                      </div>
                    </motion.div>
                  ))}
                </CardContent>
              </Card>

              {/* 시험 준비 가이드 */}
              <Card>
                <CardHeader>
                  <CardTitle className="flex items-center gap-2 text-purple-600">
                    <Lightbulb className="w-5 h-5" />
                    단계별 시험 준비 가이드
                  </CardTitle>
                </CardHeader>
                <CardContent className="space-y-6">
                  <div>
                    <h4 className="font-medium text-gray-800 mb-3 flex items-center gap-2">
                      <Timer className="w-4 h-4 text-orange-500" />
                      시험 일주일 전
                    </h4>
                    <div className="space-y-2">
                      {result.preparation_guide.final_week.map((tip, index) => (
                        <motion.div
                          key={index}
                          initial={{ opacity: 0, x: -10 }}
                          animate={{ opacity: 1, x: 0 }}
                          transition={{ delay: 1.0 + index * 0.1 }}
                          className="flex items-start gap-2"
                        >
                          <Star className="w-4 h-4 text-orange-500 mt-0.5 flex-shrink-0" />
                          <p className="text-gray-700 text-sm">{tip}</p>
                        </motion.div>
                      ))}
                    </div>
                  </div>

                  <div>
                    <h4 className="font-medium text-gray-800 mb-3 flex items-center gap-2">
                      <Moon className="w-4 h-4 text-purple-500" />
                      시험 전날
                    </h4>
                    <div className="space-y-2">
                      {result.preparation_guide.day_before.map((tip, index) => (
                        <motion.div
                          key={index}
                          initial={{ opacity: 0, x: -10 }}
                          animate={{ opacity: 1, x: 0 }}
                          transition={{ delay: 1.2 + index * 0.1 }}
                          className="flex items-start gap-2"
                        >
                          <CheckCircle className="w-4 h-4 text-purple-500 mt-0.5 flex-shrink-0" />
                          <p className="text-gray-700 text-sm">{tip}</p>
                        </motion.div>
                      ))}
                    </div>
                  </div>

                  <div>
                    <h4 className="font-medium text-gray-800 mb-3 flex items-center gap-2">
                      <Trophy className="w-4 h-4 text-green-500" />
                      시험 당일
                    </h4>
                    <div className="space-y-2">
                      {result.preparation_guide.exam_day.map((tip, index) => (
                        <motion.div
                          key={index}
                          initial={{ opacity: 0, x: -10 }}
                          animate={{ opacity: 1, x: 0 }}
                          transition={{ delay: 1.4 + index * 0.1 }}
                          className="flex items-start gap-2"
                        >
                          <Zap className="w-4 h-4 text-green-500 mt-0.5 flex-shrink-0" />
                          <p className="text-gray-700 text-sm">{tip}</p>
                        </motion.div>
                      ))}
                    </div>
                  </div>
                </CardContent>
              </Card>

              {/* 행운의 요소 */}
              <Card>
                <CardHeader>
                  <CardTitle className="flex items-center gap-2 text-yellow-600">
                    <Sparkles className="w-5 h-5" />
                    행운의 시험 요소
                  </CardTitle>
                </CardHeader>
                <CardContent className="space-y-4">
                  <div className="grid grid-cols-2 gap-4">
                    <div className="p-4 bg-yellow-50 rounded-lg">
                      <h4 className="font-medium text-yellow-800 mb-2 flex items-center gap-2">
                        <Star className="w-4 h-4" />
                        행운의 색상
                      </h4>
                      <div className="flex flex-wrap gap-2">
                        {result.lucky_elements.colors.map((color, index) => (
                          <Badge key={index} variant="secondary" className="bg-yellow-100 text-yellow-700">
                            {color}
                          </Badge>
                        ))}
                      </div>
                    </div>
                    <div className="p-4 bg-indigo-50 rounded-lg">
                      <h4 className="font-medium text-indigo-800 mb-2 flex items-center gap-2">
                        <Target className="w-4 h-4" />
                        행운의 숫자
                      </h4>
                      <div className="flex flex-wrap gap-2">
                        {result.lucky_elements.numbers.map((number, index) => (
                          <Badge key={index} variant="secondary" className="bg-indigo-100 text-indigo-700">
                            {number}
                          </Badge>
                        ))}
                      </div>
                    </div>
                  </div>
                  <div className="grid grid-cols-2 gap-4">
                    <div className="p-4 bg-green-50 rounded-lg">
                      <h4 className="font-medium text-green-800 mb-2 flex items-center gap-2">
                        <PenTool className="w-4 h-4" />
                        행운의 준비물
                      </h4>
                      <div className="space-y-1">
                        {result.lucky_elements.items.map((item, index) => (
                          <p key={index} className="text-green-700 text-sm">{item}</p>
                        ))}
                      </div>
                    </div>
                    <div className="p-4 bg-pink-50 rounded-lg">
                      <h4 className="font-medium text-pink-800 mb-2 flex items-center gap-2">
                        <Coffee className="w-4 h-4" />
                        행운의 음식
                      </h4>
                      <div className="space-y-1">
                        {result.lucky_elements.foods.map((food, index) => (
                          <p key={index} className="text-pink-700 text-sm">{food}</p>
                        ))}
                      </div>
                    </div>
                  </div>
                </CardContent>
              </Card>

              {/* 다시 분석하기 버튼 */}
              <div className="pt-4">
                <Button
                  onClick={handleReset}
                  variant="outline"
                  className="w-full border-emerald-300 text-emerald-600 hover:bg-emerald-50 py-3"
                >
                  <ArrowRight className="w-4 h-4 mr-2" />
                  다른 분석하기
                </Button>
              </div>
            </motion.div>
          )}
        </AnimatePresence>
      </motion.div>
    </div>
  );
} 