"use client";

import { useState, useEffect } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { Card, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Badge } from "@/components/ui/badge";
import { RadioGroup, RadioGroupItem } from "@/components/ui/radio-group";
import AppHeader from "@/components/AppHeader";
import { 
  Star, 
  ArrowRight,
  Users,
  Crown,
  Clock,
  CheckCircle,
  Sparkles,
  ScrollText,
  Heart,
  Calendar,
  Mountain,
  Coins,
  Shield,
  Eye,
  TrendingUp,
  BookOpen,
  Zap
} from "lucide-react";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Separator } from "@/components/ui/separator";
import { 
  getYearOptions, 
  getMonthOptions, 
  getDayOptions, 
  formatKoreanDate,
  koreanToIsoDate,
  TIME_PERIODS
} from "@/lib/utils";

interface UserInfo {
  name: string;
  birth_date: string;
  birth_time: string;
  gender: string;
}

interface SajuData {
  year_pillar: string;
  month_pillar: string;
  day_pillar: string;
  time_pillar: string;
  elements: Record<string, number>;
  fortune_score: number;
  personality_traits: string[];
  career_suggestions: string[];
  love_insights: string[];
}

const containerVariants = {
  hidden: { opacity: 0 },
  visible: {
    opacity: 1,
    transition: {
      staggerChildren: 0.3,
      delayChildren: 0.2
    }
  }
};

const itemVariants = {
  hidden: { y: 50, opacity: 0 },
  visible: {
    y: 0,
    opacity: 1,
    transition: {
      type: "spring" as const,
      stiffness: 100,
      damping: 15,
      duration: 0.8
    }
  }
};

export default function PremiumSajuPage() {
  const [step, setStep] = useState<'input' | 'story' | 'premium'>('input');
  const [loading, setLoading] = useState(false);
  const [fontSize, setFontSize] = useState<'small' | 'medium' | 'large'>('medium');
  const [formData, setFormData] = useState({
    name: "",
    birthYear: "",
    birthMonth: "",
    birthDay: "",
    birthTimePeriod: "",
    gender: ""
  });
  const [sajuData, setSajuData] = useState<SajuData | null>(null);
  const [currentScene, setCurrentScene] = useState(0);

  // 폰트 크기 클래스 매핑
  const getFontSizeClasses = (size: 'small' | 'medium' | 'large') => {
    switch (size) {
      case 'small':
        return {
          text: 'text-sm',
          title: 'text-lg',
          heading: 'text-xl',
          score: 'text-4xl',
          label: 'text-xs'
        };
      case 'large':
        return {
          text: 'text-lg',
          title: 'text-2xl',
          heading: 'text-3xl',
          score: 'text-8xl',
          label: 'text-base'
        };
      default: // medium
        return {
          text: 'text-base',
          title: 'text-xl',
          heading: 'text-2xl',
          score: 'text-6xl',
          label: 'text-sm'
        };
    }
  };

  const fontClasses = getFontSizeClasses(fontSize);

  const analyzeSaju = async (): Promise<SajuData> => {
    // 실제로는 AI API를 호출하여 사주를 분석
    return {
      year_pillar: "갑자",
      month_pillar: "을축",
      day_pillar: "병인",
      time_pillar: "정묘",
      elements: { 목: 2, 화: 0, 토: 2, 금: 2, 수: 2 },
      fortune_score: 85,
      personality_traits: ["창의적 리더십", "강한 의지력", "감성적 직관"],
      career_suggestions: ["창작 분야", "경영진", "컨설팅"],
      love_insights: ["깊은 감정 교류 추구", "진실한 관계 지향", "헌신적 사랑"]
    };
  };

  const yearOptions = getYearOptions();
  const monthOptions = getMonthOptions();
  const dayOptions = getDayOptions(
    formData.birthYear ? parseInt(formData.birthYear) : undefined,
    formData.birthMonth ? parseInt(formData.birthMonth) : undefined
  );

  const handleSubmit = async () => {
    if (!formData.name || !formData.birthYear || !formData.birthMonth || !formData.birthDay) {
      alert("이름과 생년월일을 모두 입력해주세요.");
      return;
    }

    setLoading(true);

    try {
      // 한국식 날짜를 ISO 형식으로 변환
      const birthDate = koreanToIsoDate(formData.birthYear, formData.birthMonth, formData.birthDay);
      
      // API 호출 로직
      const response = await fetch('/api/fortune/generate', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          name: formData.name,
          birth_date: birthDate,
          birth_time_period: formData.birthTimePeriod,
          gender: formData.gender,
          fortune_type: 'premium_saju'
        }),
      });

      if (!response.ok) {
        throw new Error('운세 생성에 실패했습니다.');
      }

      const data = await response.json();
      setSajuData(data);
      setStep('story');
    } catch (error) {
      console.error('Error:', error);
      alert('운세 생성 중 오류가 발생했습니다.');
    } finally {
      setLoading(false);
    }
  };

  const storyScenes = [
    {
      background: "bg-gradient-to-b from-amber-50 to-orange-100",
      character: "👩‍🏫",
      title: "청월아씨 정통사주",
      subtitle: "지금까지 43,524명이 찾아온",
      text: `${formData.name}님, 만나서 반가워요!`,
      subtext: `지금부터 ${formData.name}님의 사주를 보드랍게 풀어드릴게요`,
      illustration: (
        <div className="w-full h-64 bg-gradient-to-b from-blue-100 to-blue-200 rounded-lg flex items-center justify-center mb-4">
          <div className="text-center">
            <div className="text-6xl mb-4">📜</div>
            <p className="text-blue-800 font-medium">정통 사주풀이</p>
          </div>
        </div>
      )
    },
    {
      background: "bg-gradient-to-b from-blue-50 to-indigo-100",
      character: "📚",
      title: "사주분석 중...",
      text: "잠깐만, 먼저 제가 김인주님의 사주부터 보기 시작할게요",
      subtext: "지금부터 김인주님의 사주를 보드랍게 풀어드릴게요",
      illustration: (
        <div className="w-full h-64 bg-gradient-to-b from-purple-100 to-purple-200 rounded-lg flex items-center justify-center mb-4">
          <div className="text-center">
            <motion.div 
              className="text-6xl mb-4"
              animate={{ rotate: 360 }}
              transition={{ repeat: Infinity, duration: 2 }}
            >
              ⚡
            </motion.div>
            <p className="text-purple-800 font-medium">사주를 분석중이에요</p>
          </div>
        </div>
      )
    },
    {
      background: "bg-gradient-to-b from-green-50 to-emerald-100",
      character: "📋",
      title: "생년월일 확인",
      text: `${formData.name}님의 사주`,
      birthData: true,
      illustration: (
        <div className="w-full bg-white rounded-lg p-6 border-2 border-emerald-300 mb-4">
          <h3 className="text-center font-bold text-emerald-800 mb-4">{formData.name}님의 사주</h3>
          <div className="text-center mb-4">
            <p className="text-lg font-semibold">1988년 09월 05일 축시</p>
          </div>
          <div className="grid grid-cols-4 gap-2 mb-4">
            <div className="text-center">
              <div className="font-bold text-xs text-gray-600 mb-1">時</div>
              <div className="font-bold text-xs text-gray-600 mb-1">日</div>
              <div className="font-bold text-xs text-gray-600 mb-1">月</div>
              <div className="font-bold text-xs text-gray-600">年</div>
            </div>
            <div className="text-center">
              <div className="font-bold text-xs text-gray-600 mb-1">십부(십간)</div>
              <div className="font-bold text-xs text-gray-600 mb-1">십부(십간)</div>
              <div className="font-bold text-xs text-gray-600 mb-1">정갑(십간)</div>
              <div className="font-bold text-xs text-gray-600">정직(십간)</div>
            </div>
            <div className="text-center">
              <div className="bg-teal-500 text-white font-bold p-1 text-xs rounded mb-1">갑</div>
              <div className="bg-gray-700 text-white font-bold p-1 text-xs rounded mb-1">계</div>
              <div className="bg-gray-600 text-white font-bold p-1 text-xs rounded mb-1">정</div>
              <div className="bg-yellow-500 text-white font-bold p-1 text-xs rounded">정</div>
            </div>
            <div className="text-center">
              <div className="bg-teal-500 text-white font-bold p-1 text-xs rounded mb-1">황</div>
              <div className="bg-gray-700 text-white font-bold p-1 text-xs rounded mb-1">현</div>
              <div className="bg-gray-600 text-white font-bold p-1 text-xs rounded mb-1">신</div>
              <div className="bg-yellow-500 text-white font-bold p-1 text-xs rounded">진</div>
            </div>
          </div>
        </div>
      )
    },
    {
      background: "bg-gradient-to-b from-purple-50 to-pink-100",
      character: "⭐",
      title: "오행 분석",
      text: "내 오행의 특징들과 나가 가까이 해야 할 것들까지 전부 알려드릴게요",
      illustration: (
        <div className="w-full bg-white rounded-lg p-6 border-2 border-purple-300 mb-4">
          <h3 className="text-center font-bold text-purple-800 mb-4">{formData.name}님의 오행표</h3>
          <div className="flex justify-center items-center space-x-4 mb-4">
            {[
              { name: "목", count: 2, color: "bg-green-500" },
              { name: "화", count: 0, color: "bg-red-500" },
              { name: "토", count: 2, color: "bg-yellow-500" },
              { name: "금", count: 2, color: "bg-gray-400" },
              { name: "수", count: 2, color: "bg-blue-500" }
            ].map((element) => (
              <div key={element.name} className="text-center">
                <div className={`w-8 h-8 ${element.color} rounded-full text-white font-bold flex items-center justify-center mb-1`}>
                  {element.name}
                </div>
                <div className="text-xs">{element.count}</div>
              </div>
            ))}
          </div>
          <div className="text-center text-sm text-gray-600">
            <p className="mb-1">'목'의 기운에서 기운을 얻어요</p>
            <p>'토'의 기운에서 기운을 썩혀요</p>
          </div>
        </div>
      )
    },
    {
      background: "bg-gradient-to-b from-indigo-50 to-blue-100",
      character: "🎯",
      title: "비밀스러운 이야기만",
      text: "조금 비밀스러운 이야기지만",
      illustration: (
        <div className="w-full h-64 bg-gradient-to-b from-gray-100 to-gray-200 rounded-lg flex items-center justify-center mb-4 relative overflow-hidden">
          <div className="absolute inset-0 bg-black bg-opacity-50 backdrop-blur-sm flex items-center justify-center">
            <div className="text-center text-white">
              <div className="text-6xl mb-4">👁️</div>
              <p className="font-medium">비밀스러운 내용</p>
            </div>
          </div>
        </div>
      )
    },
    {
      background: "bg-gradient-to-b from-teal-50 to-cyan-100",
      character: "📈",
      title: "시기별 계상",
      text: `${formData.name}님이 앞으로 엄마나 많은 재물을 알게 될까에 대해 포르고`,
      illustration: (
        <div className="w-full bg-white rounded-lg p-6 border-2 border-teal-300 mb-4">
          <h3 className="text-center font-bold text-teal-800 mb-4">{formData.name}님의 시기별 계상</h3>
          <div className="relative">
            <svg viewBox="0 0 300 150" className="w-full h-32">
              <polyline
                fill="none"
                stroke="#06b6d4"
                strokeWidth="3"
                points="0,120 50,100 100,80 150,60 200,40 250,30 300,20"
              />
              <circle cx="50" cy="100" r="4" fill="#0891b2" />
              <circle cx="100" cy="80" r="4" fill="#0891b2" />
              <circle cx="150" cy="60" r="4" fill="#0891b2" />
              <circle cx="200" cy="40" r="4" fill="#0891b2" />
              <circle cx="250" cy="30" r="4" fill="#0891b2" />
            </svg>
            <div className="flex justify-between text-xs text-gray-600 mt-2">
              <span>초년기</span>
              <span>청년기</span>
              <span>중년기</span>
              <span>장년기</span>
            </div>
          </div>
          <p className="text-center text-sm text-gray-600 mt-4">5년 안에 찾아올 위기들도 째 구체적으로 보여요</p>
        </div>
      )
    },
    {
      background: "bg-gradient-to-b from-rose-50 to-pink-100",
      character: "💝",
      title: `${formData.name}님께 찾아올 위기`,
      text: "01. 작은 출산과 해외 근무",
      subtext: "02. 감정에 너무 냉정",
      subtext2: "03. 어떤먹지 못하는 천재성",
      blurred: true,
      illustration: (
        <div className="w-full h-48 bg-gradient-to-b from-gray-100 to-gray-200 rounded-lg flex items-center justify-center mb-4 relative overflow-hidden">
          <div className="absolute inset-0 bg-black bg-opacity-30 backdrop-blur-md flex items-center justify-center">
            <div className="text-center text-white">
              <div className="text-4xl mb-2">🔒</div>
              <p className="font-medium text-sm">프리미엄에서 확인 가능</p>
            </div>
          </div>
        </div>
      )
    },
    {
      background: "bg-gradient-to-b from-blue-50 to-indigo-100",
      character: "💫",
      title: `이 바에도 ${formData.name}님의 대운 드림 만좌이 정말 만족요`,
      text: "만이 기대하셔도 좋아요 😊",
      subtitle: `"오직 ${formData.name}님만을 위해 준비한 이야기"`,
      illustration: (
        <div className="w-full h-32 bg-gradient-to-r from-blue-200 to-purple-200 rounded-lg flex items-center justify-center mb-4">
          <div className="text-center">
            <div className="text-4xl mb-2">✨</div>
            <p className="text-blue-800 font-medium">특별한 운세가 기다리고 있어요</p>
          </div>
        </div>
      )
    }
  ];

  const premiumBenefits = [
    "나의 사주팔자&상세분석",
    "일주분석", 
    "십성분석",
    "십이운성 분석",
    "십이신살 분석",
    "귀인 분석",
    "재물운",
    "건강운",
    "대운",
    "연운과 삼재",
    "월운에 대한 답변"
  ];

  useEffect(() => {
    if (step === 'story') {
      const timer = setInterval(() => {
        setCurrentScene(prev => {
          if (prev < storyScenes.length - 1) {
            return prev + 1;
          } else {
            clearInterval(timer);
            setTimeout(() => setStep('premium'), 1000);
            return prev;
          }
        });
      }, 4000);

      return () => clearInterval(timer);
    }
  }, [step, storyScenes.length]);

  if (step === 'input') {
    return (
      <div className="min-h-screen bg-gradient-to-br from-purple-50 via-indigo-50 to-blue-50 dark:from-gray-900 dark:via-gray-800 dark:to-gray-700 pb-32">
        <AppHeader 
          title="프리미엄 사주" 
          onFontSizeChange={setFontSize}
          currentFontSize={fontSize}
        />
        
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          className="px-6 pt-6 space-y-6"
        >
          {/* 헤더 */}
          <motion.div 
            initial={{ y: 20, opacity: 0 }}
            animate={{ y: 0, opacity: 1 }}
            className="text-center mb-8"
          >
            <motion.div
              className="bg-gradient-to-r from-purple-500 to-indigo-500 dark:from-purple-700 dark:to-indigo-700 rounded-full w-20 h-20 flex items-center justify-center mx-auto mb-4"
              whileHover={{ rotate: 360 }}
              transition={{ duration: 0.8 }}
            >
              <ScrollText className="w-10 h-10 text-white" />
            </motion.div>
            <h1 className={`${fontClasses.heading} font-bold text-gray-900 dark:text-gray-100 mb-2`}>청월아씨 정통사주</h1>
            <p className={`${fontClasses.text} text-gray-600 dark:text-gray-400`}>지금까지 43,524명이 찾아온</p>
            <p className={`${fontClasses.text} text-gray-600 dark:text-gray-400 font-semibold`}>만화로 보는 나만의 사주 이야기</p>
          </motion.div>

          {/* 기본 정보 */}
          <motion.div
            initial={{ y: 20, opacity: 0 }}
            animate={{ y: 0, opacity: 1 }}
            transition={{ delay: 0.2 }}
          >
            <Card className="border-purple-200 dark:border-purple-700">
              <CardContent className="p-6 space-y-4">
                <div>
                  <Label htmlFor="name" className={`${fontClasses.text} dark:text-gray-300`}>이름</Label>
                  <Input
                    id="name"
                    placeholder="이름"
                    value={formData.name}
                    onChange={(e) => setFormData(prev => ({ ...prev, name: e.target.value }))}
                    className={`${fontClasses.text} mt-1`}
                  />
                </div>

                {/* 년도 선택 */}
                <div>
                  <Label className={`${fontClasses.text} dark:text-gray-300`}>생년</Label>
                  <Select 
                    value={formData.birthYear} 
                    onValueChange={(value) => setFormData(prev => ({ ...prev, birthYear: value }))}
                  >
                    <SelectTrigger className={`${fontClasses.text} mt-1`}>
                      <SelectValue placeholder="년도 선택" />
                    </SelectTrigger>
                    <SelectContent>
                      {yearOptions.map((year) => (
                        <SelectItem key={year} value={year.toString()}>
                          {year}년
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                </div>

                {/* 월 선택 */}
                <div>
                  <Label className={`${fontClasses.text} dark:text-gray-300`}>생월</Label>
                  <Select 
                    value={formData.birthMonth} 
                    onValueChange={(value) => setFormData(prev => ({ ...prev, birthMonth: value }))}
                  >
                    <SelectTrigger className={`${fontClasses.text} mt-1`}>
                      <SelectValue placeholder="월 선택" />
                    </SelectTrigger>
                    <SelectContent>
                      {monthOptions.map((month) => (
                        <SelectItem key={month} value={month.toString()}>
                          {month}월
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                </div>

                {/* 일 선택 */}
                <div>
                  <Label className={`${fontClasses.text} dark:text-gray-300`}>생일</Label>
                  <Select 
                    value={formData.birthDay} 
                    onValueChange={(value) => setFormData(prev => ({ ...prev, birthDay: value }))}
                  >
                    <SelectTrigger className={`${fontClasses.text} mt-1`}>
                      <SelectValue placeholder="일 선택" />
                    </SelectTrigger>
                    <SelectContent>
                      {dayOptions.map((day) => (
                        <SelectItem key={day} value={day.toString()}>
                          {day}일
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                </div>
                
                {/* 시진 선택 */}
                <div>
                  <div className="flex items-center gap-2 mb-2">
                    <Clock className="w-4 h-4 text-gray-600 dark:text-gray-400" />
                    <Label className={`${fontClasses.text} dark:text-gray-300`}>태어난 시진 (선택사항)</Label>
                  </div>
                  <p className={`${fontClasses.label} text-gray-500 dark:text-gray-400 mb-2`}>
                    더 정확한 사주 풀이를 위해 태어난 시간대를 선택해주세요
                  </p>
                  <Select 
                    value={formData.birthTimePeriod} 
                    onValueChange={(value) => setFormData(prev => ({ ...prev, birthTimePeriod: value }))}
                  >
                    <SelectTrigger className={`${fontClasses.text} mt-1`}>
                      <SelectValue placeholder="시진 선택" />
                    </SelectTrigger>
                    <SelectContent>
                      {TIME_PERIODS.map((period) => (
                        <SelectItem key={period.value} value={period.value}>
                          <div className="flex flex-col">
                            <span className="font-medium">{period.label}</span>
                            <span className="text-xs text-gray-500">{period.description}</span>
                          </div>
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                </div>

                {/* 성별 선택 */}
                <div>
                  <Label className={`${fontClasses.text} dark:text-gray-300`}>성별 (선택사항)</Label>
                  <Select 
                    value={formData.gender} 
                    onValueChange={(value) => setFormData(prev => ({ ...prev, gender: value }))}
                  >
                    <SelectTrigger className={`${fontClasses.text} mt-1`}>
                      <SelectValue placeholder="성별 선택" />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="male">남성</SelectItem>
                      <SelectItem value="female">여성</SelectItem>
                    </SelectContent>
                  </Select>
                </div>

                {/* 선택된 생년월일 표시 */}
                {formData.birthYear && formData.birthMonth && formData.birthDay && (
                  <div className="p-3 bg-purple-50 dark:bg-purple-900/20 rounded-lg border border-purple-200 dark:border-purple-700">
                    <p className={`${fontClasses.text} font-medium text-purple-800 dark:text-purple-300 text-center`}>
                      {formatKoreanDate(formData.birthYear, formData.birthMonth, formData.birthDay)}
                    </p>
                    {formData.birthTimePeriod && (
                      <p className={`${fontClasses.label} text-purple-600 dark:text-purple-400 text-center mt-1`}>
                        {TIME_PERIODS.find(p => p.value === formData.birthTimePeriod)?.label}
                      </p>
                    )}
                  </div>
                )}

                <Button 
                  onClick={handleSubmit} 
                  disabled={loading}
                  className={`${fontClasses.text} w-full bg-gradient-to-r from-purple-600 to-indigo-600 dark:from-purple-500 dark:to-indigo-500 hover:from-purple-700 hover:to-indigo-700 text-white font-semibold py-3 rounded-lg shadow-lg transition-all duration-300`}
                >
                  {loading ? (
                    <div className="flex items-center gap-2">
                      <div className="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin" />
                      프리미엄 사주 생성 중...
                    </div>
                  ) : (
                    <div className="flex items-center gap-2">
                      <Sparkles className="w-5 h-5" />
                      프리미엄 사주 보기
                    </div>
                  )}
                </Button>
              </CardContent>
            </Card>
          </motion.div>

          {/* 미리보기 */}
          <motion.div
            initial={{ y: 20, opacity: 0 }}
            animate={{ y: 0, opacity: 1 }}
            transition={{ delay: 0.4 }}
          >
            <Card className="bg-gradient-to-r from-amber-50 to-orange-50 dark:from-amber-900/30 dark:to-orange-900/30 border-amber-200 dark:border-amber-700 dark:bg-gray-800">
              <CardContent className="p-6 text-center">
                <div className="text-4xl mb-3">📜</div>
                <h3 className={`${fontClasses.title} font-semibold text-amber-800 dark:text-amber-400 mb-2`}>특별한 사주 이야기</h3>
                <p className={`${fontClasses.text} text-amber-700 dark:text-amber-300`}>
                  만화 형식으로 풀어내는 당신만의 사주 스토리를 경험해보세요
                </p>
              </CardContent>
            </Card>
          </motion.div>
        </motion.div>
      </div>
    );
  }

  if (step === 'story') {
    const currentStory = storyScenes[currentScene];
    
    return (
      <div className={`min-h-screen ${currentStory.background} pb-32`}>
        <AppHeader title="프리미엄 사주" />
        
        <AnimatePresence mode="wait">
          <motion.div
            key={currentScene}
            initial={{ opacity: 0, y: 50 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -50 }}
            transition={{ duration: 0.8 }}
            className="px-6 pt-6 space-y-6"
          >
            {/* 캐릭터 아이콘 */}
            <div className="text-center">
              <div className="text-6xl mb-4">{currentStory.character}</div>
            </div>

            {/* 스토리 컨텐트 */}
            <Card className="bg-white/90 backdrop-blur border-0 shadow-lg">
              <CardContent className="p-6 text-center space-y-4">
                {currentStory.subtitle && (
                  <p className={`${fontClasses.text} text-gray-600 font-semibold`}>
                    {currentStory.subtitle}
                  </p>
                )}
                
                <h2 className={`${fontClasses.heading} font-bold text-gray-900`}>
                  {currentStory.title}
                </h2>
                
                {currentStory.illustration}
                
                <p className={`${fontClasses.title} text-gray-800 font-medium leading-relaxed`}>
                  {currentStory.text}
                </p>
                
                {currentStory.subtext && (
                  <p className={`${fontClasses.text} text-gray-600`}>
                    {currentStory.subtext}
                  </p>
                )}
                
                {currentStory.subtext2 && (
                  <p className={`${fontClasses.text} text-gray-600`}>
                    {currentStory.subtext2}
                  </p>
                )}

                {currentStory.blurred && (
                  <div className="bg-yellow-50 border border-yellow-200 rounded-lg p-3 mt-4">
                    <p className={`${fontClasses.text} text-yellow-800`}>
                      🔒 더 자세한 내용은 프리미엄에서 확인하세요
                    </p>
                  </div>
                )}
              </CardContent>
            </Card>

            {/* 진행 표시 */}
            <div className="flex justify-center space-x-2">
              {storyScenes.map((_, index) => (
                <div
                  key={index}
                  className={`w-2 h-2 rounded-full transition-colors ${
                    index === currentScene ? 'bg-purple-500' : 'bg-gray-300'
                  }`}
                />
              ))}
            </div>
          </motion.div>
        </AnimatePresence>
      </div>
    );
  }

  if (step === 'premium') {
    return (
      <div className="min-h-screen bg-gradient-to-b from-indigo-900 via-purple-900 to-pink-900 text-white pb-32">
        <AppHeader title="프리미엄 사주" />
        
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          className="px-6 pt-6 space-y-8"
        >
          {/* 마무리 인사 */}
          <motion.div 
            initial={{ y: 50, opacity: 0 }}
            animate={{ y: 0, opacity: 1 }}
            className="text-center space-y-4"
          >
            <div className="text-6xl">👩‍🏫</div>
            <p className={`${fontClasses.text} text-purple-200`}>
              지금까지 본 '사주풀이' 어떠셨나요?
            </p>
            <h2 className={`${fontClasses.heading} font-bold`}>
              미래를 선명하게 그려드리는 청월아씨는
            </h2>
          </motion.div>

          {/* 타이머 */}
          <motion.div 
            initial={{ scale: 0 }}
            animate={{ scale: 1 }}
            className="bg-white/10 backdrop-blur rounded-lg p-4 text-center"
          >
            <p className={`${fontClasses.text} text-yellow-300 mb-2`}>할인혜택 종료까지</p>
            <div className={`${fontClasses.score} font-bold text-yellow-400`}>03:20:13:83</div>
          </motion.div>

          {/* 프리미엄 혜택 */}
          <motion.div
            initial={{ y: 50, opacity: 0 }}
            animate={{ y: 0, opacity: 1 }}
            transition={{ delay: 0.3 }}
          >
            <Card className="bg-white/10 backdrop-blur border-0">
              <CardContent className="p-6">
                <h3 className={`${fontClasses.title} font-bold text-center mb-4`}>
                  정통사주 총보
                </h3>
                <div className="space-y-2">
                  {premiumBenefits.map((benefit, index) => (
                    <motion.div
                      key={benefit}
                      initial={{ x: -20, opacity: 0 }}
                      animate={{ x: 0, opacity: 1 }}
                      transition={{ delay: 0.1 * index }}
                      className="flex items-center gap-3"
                    >
                      <CheckCircle className="w-5 h-5 text-green-400 flex-shrink-0" />
                      <span className={fontClasses.text}>{benefit}</span>
                    </motion.div>
                  ))}
                </div>
              </CardContent>
            </Card>
          </motion.div>

          {/* 가격 정보 */}
          <motion.div
            initial={{ y: 50, opacity: 0 }}
            animate={{ y: 0, opacity: 1 }}
            transition={{ delay: 0.5 }}
            className="space-y-4"
          >
            <div className="text-center">
              <p className={`${fontClasses.text} text-gray-300 line-through`}>정통사주 정가: 53,400원</p>
              <p className={`${fontClasses.text} text-yellow-400`}>
                <span className="bg-yellow-400 text-black px-2 py-1 rounded text-sm font-bold">30% 할인</span>
                {" "}- 16,000원
              </p>
              <p className={`${fontClasses.score} font-bold text-white`}>37,400원</p>
            </div>

            {/* 구매 버튼 */}
            <Button
              className="w-full bg-gradient-to-r from-yellow-500 to-orange-500 hover:from-yellow-600 hover:to-orange-600 text-black font-bold py-6 text-lg"
              onClick={() => alert('결제 시스템 연동 예정입니다!')}
            >
              <Crown className="w-5 h-5 mr-2" />
              정통사주 지금 받아보기
            </Button>

            {/* 주의사항 */}
            <div className="bg-orange-500/20 border border-orange-400 rounded-lg p-4">
              <div className="flex items-start gap-2">
                <div className="text-orange-400 mt-1">⚠️</div>
                <div>
                  <p className={`${fontClasses.text} text-orange-300 font-semibold mb-1`}>
                    정통사주는 오늘이 가장 저렴해요!
                  </p>
                  <p className={`${fontClasses.label} text-orange-200`}>
                    한정 할인 끝나기 전 드리며, 인생마감시 할인혜택이 종료돼요
                  </p>
                </div>
              </div>
            </div>

            {/* 특별 코드 */}
            <motion.div
              initial={{ scale: 0 }}
              animate={{ scale: 1 }}
              transition={{ delay: 0.8 }}
              className="bg-gradient-to-r from-purple-600 to-pink-600 rounded-lg p-4 text-center"
            >
              <p className={`${fontClasses.text} font-bold mb-2`}>🎁 특별 할인 코드</p>
              <p className={`${fontClasses.title} font-mono font-bold tracking-wider`}>PREMIUM30</p>
              <p className={`${fontClasses.label} text-purple-200 mt-1`}>프리미엄 사주 전용 30% 할인</p>
            </motion.div>
          </motion.div>
        </motion.div>
      </div>
    );
  }

  return null;
}

