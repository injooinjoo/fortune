"use client";

import { useState, useEffect } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Badge } from "@/components/ui/badge";
import { RadioGroup, RadioGroupItem } from "@/components/ui/radio-group";
import { Textarea } from "@/components/ui/textarea";
import AppHeader from "@/components/AppHeader";
import { useFortuneStream } from "@/hooks/use-fortune-stream";
import { useDailyFortune } from "@/hooks/use-daily-fortune";
import { FortuneResult } from "@/lib/schemas";
import { 
  Droplet, 
  Star, 
  ArrowRight,
  Shuffle,
  Users,
  Crown,
  Clock,
  BarChart3,
  Activity,
  Shield,
  CloudRain,
  Compass,
  TreePine,
  RotateCcw,
  CheckCircle,
  ArrowLeft,
  MapPin,
  Sunrise
} from "lucide-react";
import { 
  getYearOptions, 
  getMonthOptions, 
  getDayOptions, 
  formatKoreanDate,
  koreanToIsoDate,
  TIME_PERIODS
} from "@/lib/utils";

interface BloodTypeInfo {
  name: string;
  birthYear: string;
  birthMonth: string;
  birthDay: string;
  bloodType: string;
}

interface BloodTypeFortune {
  overall_luck: number;
  personality_match: number;
  love_match: number;
  career_match: number;
  health_match: number;
  blood_type_traits: string;
  lucky_advice: string;
  compatible_blood_types: string[];
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

const bloodTypes = ["A형", "B형", "O형", "AB형"];

const getLuckColor = (score: number) => {
  if (score >= 85) return "text-green-600 dark:text-green-400 bg-green-50 dark:bg-green-900/30";
  if (score >= 70) return "text-blue-600 dark:text-blue-400 bg-blue-50 dark:bg-blue-900/30";
  if (score >= 55) return "text-orange-600 dark:text-orange-400 bg-orange-50 dark:bg-orange-900/30";
  return "text-red-600 dark:text-red-400 bg-red-50 dark:bg-red-900/30";
};

const getLuckText = (score: number) => {
  if (score >= 85) return "최고의 궁합";
  if (score >= 70) return "좋은 궁합";
  if (score >= 55) return "보통 궁합";
  return "노력 필요";
};

export default function BloodTypeFortunePage() {
  const [step, setStep] = useState<'form' | 'result'>('form');
  const [fontSize, setFontSize] = useState<'small' | 'medium' | 'large'>('medium');
  const [isGenerating, setIsGenerating] = useState(false);
  const [formData, setFormData] = useState<BloodTypeInfo>({
    name: '',
    birthYear: '',
    birthMonth: '',
    birthDay: '',
    bloodType: ''
  });
  const [result, setResult] = useState<BloodTypeFortune | null>(null);
  
  useFortuneStream();
  
  const {
    todayFortune,
    isLoading: isDailyLoading,
    isGenerating: isDailyGenerating,
    hasTodayFortune,
    saveFortune,
    regenerateFortune,
    canRegenerate
  } = useDailyFortune({ fortuneType: 'blood-type' });

  useEffect(() => {
    if (hasTodayFortune && todayFortune && step === 'form') {
      const savedData = todayFortune.fortune_data as any;
      const metadata = savedData.metadata || {};
      
      setFormData({
        name: savedData.user_info?.name || '',
        birthYear: savedData.user_info?.birth_date ? savedData.user_info.birth_date.split('-')[0] : '',
        birthMonth: savedData.user_info?.birth_date ? savedData.user_info.birth_date.split('-')[1] : '',
        birthDay: savedData.user_info?.birth_date ? savedData.user_info.birth_date.split('-')[2] : '',
        bloodType: metadata.blood_type || ''
      });
      
      if (savedData.fortune_scores) {
        const restoredResult: BloodTypeFortune = {
          overall_luck: savedData.fortune_scores.overall_luck,
          personality_match: savedData.fortune_scores.personality_match,
          love_match: savedData.fortune_scores.love_match,
          career_match: savedData.fortune_scores.career_match,
          health_match: savedData.fortune_scores.health_match,
          blood_type_traits: savedData.insights?.blood_type_traits || '',
          lucky_advice: savedData.insights?.lucky_advice || '',
          compatible_blood_types: savedData.lucky_items?.compatible_blood_types || []
        };
        setResult(restoredResult);
        setStep('result');
      }
    }
  }, [hasTodayFortune, todayFortune, step]);

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

  const analyzeBloodTypeFortune = async (): Promise<BloodTypeFortune> => {
    const baseScore = Math.floor(Math.random() * 25) + 60;

    const traitsMap: { [key: string]: string } = {
      "A형": "신중하고 책임감이 강하며, 배려심이 깊습니다. 때로는 소심하거나 완벽주의적인 경향이 있습니다.",
      "B형": "자유분방하고 창의적이며, 솔직하고 낙천적입니다. 때로는 자기중심적이거나 변덕스러운 면이 있습니다.",
      "O형": "사교적이고 리더십이 있으며, 활발하고 긍정적입니다. 때로는 고집이 세거나 단순한 면이 있습니다.",
      "AB형": "합리적이고 분석적이며, 독특하고 개성이 강합니다. 때로는 이중적이거나 비판적인 면이 있습니다."
    };

    const compatibleMap: { [key: string]: string[] } = {
      "A형": ["O형", "AB형"],
      "B형": ["O형", "AB형"],
      "O형": ["A형", "B형", "O형", "AB형"],
      "AB형": ["A형", "B형", "AB형"]
    };

    return {
      overall_luck: Math.max(50, Math.min(95, baseScore + Math.floor(Math.random() * 15))),
      personality_match: Math.max(45, Math.min(100, baseScore + Math.floor(Math.random() * 20) - 5)),
      love_match: Math.max(40, Math.min(95, baseScore + Math.floor(Math.random() * 20) - 10)),
      career_match: Math.max(50, Math.min(100, baseScore + Math.floor(Math.random() * 15))),
      health_match: Math.max(55, Math.min(95, baseScore + Math.floor(Math.random() * 20) - 5)),
      blood_type_traits: traitsMap[formData.bloodType] || "혈액형 특성 정보 없음",
      lucky_advice: "자신의 혈액형 특성을 이해하고 강점을 살리면 좋은 운을 만들 수 있습니다.",
      compatible_blood_types: compatibleMap[formData.bloodType] || []
    };
  };

  const yearOptions = getYearOptions();
  const monthOptions = getMonthOptions();
  const dayOptions = getDayOptions(
    formData.birthYear ? parseInt(formData.birthYear) : undefined,
    formData.birthMonth ? parseInt(formData.birthMonth) : undefined
  );

  const handleSubmit = async () => {
    if (!formData.name || !formData.birthYear || !formData.birthMonth || !formData.birthDay || !formData.bloodType) {
      alert('이름, 생년월일, 혈액형을 모두 입력해주세요.');
      return;
    }

    setIsGenerating(true);

    try {
      const birthDate = koreanToIsoDate(formData.birthYear, formData.birthMonth, formData.birthDay);
      
      if (hasTodayFortune && todayFortune) {
        const savedData = todayFortune.fortune_data as any;
        const restoredResult: BloodTypeFortune = {
          overall_luck: savedData.fortune_scores?.overall_luck || 0,
          personality_match: savedData.fortune_scores?.personality_match || 0,
          love_match: savedData.fortune_scores?.love_match || 0,
          career_match: savedData.fortune_scores?.career_match || 0,
          health_match: savedData.fortune_scores?.health_match || 0,
          blood_type_traits: savedData.insights?.blood_type_traits || '',
          lucky_advice: savedData.insights?.lucky_advice || '',
          compatible_blood_types: savedData.lucky_items?.compatible_blood_types || []
        };
        setResult(restoredResult);
      } else {
        const fortuneResult = await analyzeBloodTypeFortune();
        setResult(fortuneResult);
        
        const fortuneData: FortuneResult = {
          user_info: {
            name: formData.name,
            birth_date: koreanToIsoDate(formData.birthYear, formData.birthMonth, formData.birthDay),
          },
          fortune_scores: {
            overall_luck: fortuneResult.overall_luck,
            personality_match: fortuneResult.personality_match,
            love_match: fortuneResult.love_match,
            career_match: fortuneResult.career_match,
            health_match: fortuneResult.health_match,
          },
          insights: {
            blood_type_traits: fortuneResult.blood_type_traits,
            lucky_advice: fortuneResult.lucky_advice,
          },
          lucky_items: {
            compatible_blood_types: fortuneResult.compatible_blood_types,
          },
          metadata: {
            blood_type: formData.bloodType,
          }
        };
        
        await saveFortune(fortuneData);
      }
      
      setStep('result');
    } catch (error) {
      console.error('혈액형 운세 분석 실패:', error);
      alert('운세 분석 중 오류가 발생했습니다. 다시 시도해주세요.');
    } finally {
      setIsGenerating(false);
    }
  };

  const handleReset = () => {
    setStep('form');
    setResult(null);
    setFormData({
      name: '',
      birthYear: '',
      birthMonth: '',
      birthDay: '',
      bloodType: ''
    });
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-red-50 via-pink-50 to-rose-50 dark:from-gray-900 dark:via-red-900 dark:to-gray-800 pb-20">
      <AppHeader 
        title="혈액형 운세" 
        onFontSizeChange={setFontSize}
        currentFontSize={fontSize}
      />
      
      <motion.div
        variants={containerVariants}
        initial="hidden"
        animate="visible"
        className="px-6 pt-6"
      >
        <AnimatePresence mode="wait">
          {step === 'form' && (
            <motion.div
              key="form"
              initial={{ opacity: 0, x: -50 }}
              animate={{ opacity: 1, x: 0 }}
              exit={{ opacity: 0, x: 50 }}
              className="space-y-6"
            >
              {/* 헤더 */}
              <motion.div variants={itemVariants} className="text-center mb-8">
                <motion.div
                  className="bg-gradient-to-r from-red-500 to-pink-500 rounded-full w-20 h-20 flex items-center justify-center mx-auto mb-4"
                  whileHover={{ rotate: 360 }}
                  transition={{ duration: 0.8 }}
                >
                  <Droplet className="w-10 h-10 text-white" />
                </motion.div>
                <h1 className={`${fontClasses.heading} font-bold text-gray-900 dark:text-gray-100 mb-2`}>혈액형 운세</h1>
                <p className={`${fontClasses.text} text-gray-600 dark:text-gray-400`}>혈액형으로 보는 당신의 성격과 운세</p>
              </motion.div>

              {/* 기본 정보 */}
              <motion.div variants={itemVariants}>
                <Card className="border-red-200 dark:border-red-700 dark:bg-gray-800">
                  <CardHeader className="pb-4">
                    <CardTitle className={`${fontClasses.title} flex items-center gap-2 text-red-700 dark:text-red-400`}>
                      <Users className="w-5 h-5" />
                      기본 정보
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
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

                    {/* 선택된 생년월일 표시 */}
                    {formData.birthYear && formData.birthMonth && formData.birthDay && (
                      <div className="p-3 bg-red-50 dark:bg-red-900/20 rounded-lg border border-red-200 dark:border-red-700">
                        <p className={`${fontClasses.text} font-medium text-red-800 dark:text-red-300 text-center`}>
                          {formatKoreanDate(formData.birthYear, formData.birthMonth, formData.birthDay)}
                        </p>
                      </div>
                    )}
                  </CardContent>
                </Card>
              </motion.div>

              {/* 혈액형 선택 */}
              <motion.div variants={itemVariants}>
                <Card className="border-pink-200 dark:border-pink-700 dark:bg-gray-800">
                  <CardHeader className="pb-4">
                    <CardTitle className={`${fontClasses.title} flex items-center gap-2 text-pink-700 dark:text-pink-400`}>
                      <Droplet className="w-5 h-5" />
                      혈액형 선택
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div>
                      <Label className={`${fontClasses.text} dark:text-gray-300`}>당신의 혈액형은?</Label>
                      <RadioGroup 
                        value={formData.bloodType} 
                        onValueChange={(value) => setFormData(prev => ({ ...prev, bloodType: value }))}
                        className="mt-2 grid grid-cols-2 gap-2"
                      >
                        {bloodTypes.map((type) => (
                          <div key={type} className="flex items-center space-x-2">
                            <RadioGroupItem value={type} id={type} />
                            <Label htmlFor={type} className={`${fontClasses.label} dark:text-gray-300`}>{type}</Label>
                          </div>
                        ))}
                      </RadioGroup>
                    </div>
                  </CardContent>
                </Card>
              </motion.div>

              {/* 분석 버튼 */}
              <motion.div variants={itemVariants} className="pt-4">
                <Button
                  onClick={handleSubmit}
                  disabled={isGenerating || isDailyGenerating}
                  className={`w-full bg-gradient-to-r from-red-500 to-pink-500 hover:from-red-600 hover:to-pink-600 text-white py-6 ${fontClasses.title} font-semibold`}
                >
                  {(isGenerating || isDailyGenerating) ? (
                    <motion.div
                      animate={{ rotate: 360 }}
                      transition={{ repeat: Infinity, duration: 1 }}
                      className="flex items-center gap-2"
                    >
                      <Shuffle className="w-5 h-5" />
                      {hasTodayFortune ? '불러오는 중...' : '분석 중...'}
                    </motion.div>
                  ) : (
                    <div className="flex items-center gap-2">
                      {hasTodayFortune ? (
                        <>
                          <CheckCircle className="w-5 h-5" />
                          오늘의 혈액형 운세 보기
                        </>
                      ) : (
                        <>
                          <Droplet className="w-5 h-5" />
                          혈액형 운세 분석하기
                        </>
                      )}
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
              {/* 전체 운세 */}
              <motion.div variants={itemVariants}>
                <Card className="bg-gradient-to-r from-red-500 to-pink-500 text-white">
                  <CardContent className="text-center py-8">
                    <div className={`flex items-center justify-center gap-2 mb-4`}>
                      <Droplet className="w-6 h-6" />
                      <span className={`${fontClasses.title} font-medium`}>{formData.name}님의 혈액형 운세</span>
                    </div>
                    <motion.div
                      initial={{ scale: 0 }}
                      animate={{ scale: 1 }}
                      transition={{ delay: 0.3, type: "spring" }}
                      className={`${fontClasses.score} font-bold mb-2`}
                    >
                      {result.overall_luck}점
                    </motion.div>
                    <Badge variant="secondary" className={`${fontClasses.text} bg-white/20 text-white border-white/30`}>
                      {getLuckText(result.overall_luck)}
                    </Badge>
                  </CardContent>
                </Card>
              </motion.div>

              {/* 세부 운세 */}
              <motion.div variants={itemVariants}>
                <Card className="dark:bg-gray-800 dark:border-gray-700">
                  <CardHeader>
                    <CardTitle className={`${fontClasses.title} flex items-center gap-2 text-red-600 dark:text-red-400`}>
                      <BarChart3 className="w-5 h-5" />
                      세부 혈액형 운세
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    {[
                      { label: "성격 궁합", score: result.personality_match, icon: Users, desc: "성격적 조화도" },
                      { label: "연애 궁합", score: result.love_match, icon: Star, desc: "연애에서의 조화도" },
                      { label: "직업 궁합", score: result.career_match, icon: Activity, desc: "직업적 성공 조화도" },
                      { label: "건강 궁합", score: result.health_match, icon: Shield, desc: "건강 관리 조화도" }
                    ].map((item, index) => (
                      <motion.div
                        key={item.label}
                        initial={{ x: -20, opacity: 0 }}
                        animate={{ x: 0, opacity: 1 }}
                        transition={{ delay: 0.4 + index * 0.1 }}
                        className="space-y-2"
                      >
                        <div className="flex items-center gap-3">
                          <item.icon className="w-5 h-5 text-gray-600 dark:text-gray-400" />
                          <div className="flex-1">
                            <div className="flex justify-between items-center mb-1">
                              <div>
                                <span className={`${fontClasses.text} font-medium dark:text-gray-200`}>{item.label}</span>
                                <p className={`${fontClasses.label} text-gray-500 dark:text-gray-400`}>{item.desc}</p>
                              </div>
                              <span className={`px-3 py-1 rounded-full ${fontClasses.label} font-medium ${getLuckColor(item.score)}`}>
                                {item.score}점
                              </span>
                            </div>
                            <div className="w-full bg-gray-200 dark:bg-gray-700 rounded-full h-2">
                              <motion.div
                                className="bg-red-500 dark:bg-red-400 h-2 rounded-full"
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

              {/* 혈액형 특성 및 조언 */}
              <motion.div variants={itemVariants}>
                <Card className="dark:bg-gray-800 dark:border-gray-700">
                  <CardHeader>
                    <CardTitle className={`${fontClasses.title} flex items-center gap-2 text-purple-600 dark:text-purple-400`}>
                      <Crown className="w-5 h-5" />
                      혈액형 특성 및 조언
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div className="p-4 bg-purple-50 dark:bg-purple-900/30 rounded-lg">
                      <h4 className={`${fontClasses.text} font-medium text-purple-800 dark:text-purple-300 mb-2 flex items-center gap-2`}>
                        <Droplet className="w-4 h-4" />
                        {formData.bloodType} 특성
                      </h4>
                      <p className={`${fontClasses.text} text-purple-700 dark:text-purple-400`}>{result.blood_type_traits}</p>
                    </div>
                    <div className="p-4 bg-indigo-50 dark:bg-indigo-900/30 rounded-lg">
                      <h4 className={`${fontClasses.text} font-medium text-indigo-800 dark:text-indigo-300 mb-2 flex items-center gap-2`}>
                        <Star className="w-4 h-4" />
                        행운 조언
                      </h4>
                      <p className={`${fontClasses.text} text-indigo-700 dark:text-indigo-400`}>{result.lucky_advice}</p>
                    </div>
                    {result.compatible_blood_types && result.compatible_blood_types.length > 0 && (
                      <div className="p-4 bg-teal-50 dark:bg-teal-900/30 rounded-lg">
                        <h4 className={`${fontClasses.text} font-medium text-teal-800 dark:text-teal-300 mb-2 flex items-center gap-2`}>
                          <Users className="w-4 h-4" />
                          궁합이 좋은 혈액형
                        </h4>
                        <p className={`${fontClasses.title} font-semibold text-teal-700 dark:text-teal-400`}>
                          {result.compatible_blood_types.join(', ')}
                        </p>
                      </div>
                    )}
                  </CardContent>
                </Card>
              </motion.div>

              {/* 다시 분석하기 및 재생성 버튼 */}
              <motion.div variants={itemVariants} className="pt-4 space-y-3">
                {canRegenerate && (
                  <Button
                    onClick={async () => {
                      try {
                        await new Promise(resolve => setTimeout(resolve, 3000));
                        const analysisResult = await analyzeBloodTypeFortune();
                        
                        const fortuneResult: FortuneResult = {
                          user_info: {
                            name: formData.name,
                            birth_date: koreanToIsoDate(formData.birthYear, formData.birthMonth, formData.birthDay),
                          },
                          fortune_scores: {
                            overall_luck: analysisResult.overall_luck,
                            personality_match: analysisResult.personality_match,
                            love_match: analysisResult.love_match,
                            career_match: analysisResult.career_match,
                            health_match: analysisResult.health_match,
                          },
                          insights: {
                            blood_type_traits: analysisResult.blood_type_traits,
                            lucky_advice: analysisResult.lucky_advice,
                          },
                          lucky_items: {
                            compatible_blood_types: analysisResult.compatible_blood_types,
                          },
                          metadata: {
                            blood_type: formData.bloodType,
                          }
                        };

                        const success = await regenerateFortune(fortuneResult);
                        if (success) {
                          setResult(analysisResult);
                        }
                      } catch (error) {
                        console.error('재생성 중 오류:', error);
                        alert('운세 재생성에 실패했습니다. 다시 시도해주세요.');
                      }
                    }}
                    disabled={isGenerating}
                    className={`w-full bg-gradient-to-r from-purple-500 to-indigo-500 hover:from-purple-600 hover:to-indigo-600 text-white py-3 ${fontClasses.text}`}
                  >
                    {isGenerating ? (
                      <motion.div
                        animate={{ rotate: 360 }}
                        transition={{ repeat: Infinity, duration: 1 }}
                        className="flex items-center gap-2"
                      >
                        <Shuffle className="w-4 h-4" />
                        재생성 중...
                      </motion.div>
                    ) : (
                      <div className="flex items-center gap-2">
                        <RotateCcw className="w-4 h-4" />
                        오늘 운세 다시 생성하기
                      </div>
                    )}
                  </Button>
                )}
                <Button
                  onClick={handleReset}
                  variant="outline"
                  className={`w-full border-red-300 dark:border-red-700 text-red-600 dark:text-red-400 hover:bg-red-50 dark:hover:bg-red-900/30 py-3 ${fontClasses.text}`}
                >
                  <ArrowLeft className="w-4 h-4 mr-2" />
                  다른 분석하기
                </Button>
              </motion.div>
            </motion.div>
          )}
        </AnimatePresence>
      </motion.div>
    </div>
  );
}