"use client";

import { useState, useEffect, useRef } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Badge } from "@/components/ui/badge";
import AppHeader from "@/components/AppHeader";
import { useFortuneStream } from "@/hooks/use-fortune-stream";
import { useDailyFortune } from "@/hooks/use-daily-fortune";
import { FortuneResult } from "@/lib/schemas";
import { callGPTFortuneAPI, validateUserInput, FORTUNE_REQUIRED_FIELDS, FortuneServiceError } from "@/lib/fortune-utils";
import { FortuneErrorBoundary } from "@/components/FortuneErrorBoundary";
import {
  Camera, 
  User, 
  Star, 
  ArrowRight,
  Shuffle,
  Users,
  Crown,
  BarChart3,
  Activity,
  Shield,
  RotateCcw,
  CheckCircle,
  ArrowLeft,
  Upload
} from "lucide-react";
import { 
  getYearOptions, 
  getMonthOptions, 
  getDayOptions, 
  formatKoreanDate,
  koreanToIsoDate,
} from "@/lib/utils";

interface FaceReadingInfo {
  name: string;
  birthYear: string;
  birthMonth: string;
  birthDay: string;
  gender: string;
  image: File | null;
}

interface FaceReadingFortune {
  overall_luck: number;
  face_shape: string;
  eye_analysis: { shape: string; meaning: string; fortune: string; };
  nose_analysis: { shape: string; meaning: string; fortune: string; };
  mouth_analysis: { shape: string; meaning: string; fortune: string; };
  personality_traits: string[];
  life_fortune: { wealth: number; love: number; career: number; health: number; };
  lucky_advice: string;
  image_url: string;
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

// 하드코딩된 관상 특징 배열 제거됨 - GPT API에서 데이터 제공

const getLuckColor = (score: number) => {
  if (score >= 85) return "text-green-600 dark:text-green-400 bg-green-50 dark:bg-green-900/30";
  if (score >= 70) return "text-blue-600 dark:text-blue-400 bg-blue-50 dark:bg-blue-900/30";
  if (score >= 55) return "text-orange-600 dark:text-orange-400 bg-orange-50 dark:bg-orange-900/30";
  return "text-red-600 dark:text-red-400 bg-red-50 dark:bg-red-900/30";
};

const getLuckText = (score: number) => {
  if (score >= 85) return "매우 좋음";
  if (score >= 70) return "좋음";
  if (score >= 55) return "보통";
  return "노력 필요";
};

export default function FaceReadingPage() {
  const [step, setStep] = useState<'form' | 'result'>('form');
  const [fontSize, setFontSize] = useState<'small' | 'medium' | 'large'>('medium');
  const [isGenerating, setIsGenerating] = useState(false);
  const [formData, setFormData] = useState<FaceReadingInfo>({
    name: '',
    birthYear: '',
    birthMonth: '',
    birthDay: '',
    gender: '',
    image: null,
  });
  const [result, setResult] = useState<FaceReadingFortune | null>(null);
  const [error, setError] = useState<Error | null>(null);
  const fileInputRef = useRef<HTMLInputElement>(null);
  
  useFortuneStream();
  
  const {
    todayFortune,
    isLoading: isDailyLoading,
    isGenerating: isDailyGenerating,
    hasTodayFortune,
    saveFortune,
    regenerateFortune,
    canRegenerate
  } = useDailyFortune({ fortuneType: 'face-reading' });

  useEffect(() => {
    if (hasTodayFortune && todayFortune && step === 'form') {
      const savedData = todayFortune.fortune_data as any;
      const metadata = savedData.metadata || {};
      
      setFormData({
        name: savedData.user_info?.name || '',
        birthYear: savedData.user_info?.birth_date ? savedData.user_info.birth_date.split('-')[0] : '',
        birthMonth: savedData.user_info?.birth_date ? savedData.user_info.birth_date.split('-')[1] : '',
        birthDay: savedData.user_info?.birth_date ? savedData.user_info.birth_date.split('-')[2] : '',
        gender: metadata.gender || '',
        image: null, // Image cannot be restored directly from saved data
      });
      
      if (savedData.fortune_scores) {
        // 운세 데이터가 불완전하면 에러 발생
        if (!savedData.fortune_scores.overall_luck || !savedData.insights?.face_shape || 
            !savedData.insights?.eye_analysis || !savedData.insights?.nose_analysis || 
            !savedData.insights?.mouth_analysis || !savedData.insights?.personality_traits || 
            !savedData.fortune_scores.life_fortune || !savedData.insights?.lucky_advice) {
          throw new FortuneServiceError('face-reading');
        }
        
        const restoredResult: FaceReadingFortune = {
          overall_luck: savedData.fortune_scores.overall_luck,
          face_shape: savedData.insights.face_shape,
          eye_analysis: savedData.insights.eye_analysis,
          nose_analysis: savedData.insights.nose_analysis,
          mouth_analysis: savedData.insights.mouth_analysis,
          personality_traits: savedData.insights.personality_traits,
          life_fortune: savedData.fortune_scores.life_fortune,
          lucky_advice: savedData.insights.lucky_advice,
          image_url: savedData.metadata?.image_url || '',
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

  const analyzeFaceReadingFortune = async (imageFile: File): Promise<FaceReadingFortune> => {
    // 입력 검증
    if (!validateUserInput(formData, FORTUNE_REQUIRED_FIELDS['face-reading'])) {
      throw new Error('필수 입력 정보가 부족합니다.');
    }

    if (!imageFile) {
      throw new Error('관상 분석을 위한 사진이 필요합니다.');
    }

    // GPT API 호출 (현재는 에러를 발생시켜 가짜 데이터 생성 방지)
    const gptResult = await callGPTFortuneAPI({
      type: 'face-reading',
      userInfo: {
        name: formData.name,
        birth_date: `${formData.birthYear}-${formData.birthMonth}-${formData.birthDay}`,
        gender: formData.gender,
        image: imageFile
      }
    });

    return gptResult;
  };

  const yearOptions = getYearOptions();
  const monthOptions = getMonthOptions();
  const dayOptions = getDayOptions(
    formData.birthYear ? parseInt(formData.birthYear) : undefined,
    formData.birthMonth ? parseInt(formData.birthMonth) : undefined
  );

  const handleImageChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    if (event.target.files && event.target.files[0]) {
      setFormData(prev => ({ ...prev, image: event.target.files![0] }));
    }
  };

  const handleSubmit = async () => {
    if (!formData.name || !formData.birthYear || !formData.birthMonth || !formData.birthDay || !formData.gender || !formData.image) {
      alert('이름, 생년월일, 성별, 사진을 모두 입력해주세요.');
      return;
    }

    setIsGenerating(true);

    try {
      const birthDate = koreanToIsoDate(formData.birthYear, formData.birthMonth, formData.birthDay);
      
      if (hasTodayFortune && todayFortune) {
        const savedData = todayFortune.fortune_data as any;
        // 운세 데이터가 불완전하면 에러 발생
        if (!savedData.fortune_scores?.overall_luck || !savedData.insights?.face_shape || 
            !savedData.insights?.eye_analysis || !savedData.insights?.nose_analysis || 
            !savedData.insights?.mouth_analysis || !savedData.insights?.personality_traits || 
            !savedData.fortune_scores?.life_fortune || !savedData.insights?.lucky_advice) {
          throw new FortuneServiceError('face-reading');
        }
        
        const restoredResult: FaceReadingFortune = {
          overall_luck: savedData.fortune_scores.overall_luck,
          face_shape: savedData.insights.face_shape,
          eye_analysis: savedData.insights.eye_analysis,
          nose_analysis: savedData.insights.nose_analysis,
          mouth_analysis: savedData.insights.mouth_analysis,
          personality_traits: savedData.insights.personality_traits,
          life_fortune: savedData.fortune_scores.life_fortune,
          lucky_advice: savedData.insights.lucky_advice,
          image_url: savedData.metadata?.image_url || '',
        };
        setResult(restoredResult);
      } else {
        const fortuneResult = await analyzeFaceReadingFortune(formData.image);
        setResult(fortuneResult);
        
        const fortuneData: FortuneResult = {
          user_info: {
            name: formData.name,
            birth_date: koreanToIsoDate(formData.birthYear, formData.birthMonth, formData.birthDay),
          },
          fortune_scores: {
            overall_luck: fortuneResult.overall_luck,
            life_fortune: fortuneResult.life_fortune,
          },
          insights: {
            face_shape: fortuneResult.face_shape,
            eye_analysis: fortuneResult.eye_analysis,
            nose_analysis: fortuneResult.nose_analysis,
            mouth_analysis: fortuneResult.mouth_analysis,
            personality_traits: fortuneResult.personality_traits,
            lucky_advice: fortuneResult.lucky_advice,
          },
          metadata: {
            gender: formData.gender,
            image_url: fortuneResult.image_url,
          }
        };
        
        await saveFortune(fortuneData);
      }
      
      setStep('result');
    } catch (error) {
      console.error('관상 분석 실패:', error);
      
      // FortuneServiceError인 경우 에러 상태로 설정
      if (error instanceof FortuneServiceError) {
        setError(error);
      } else {
        alert('관상 분석 중 오류가 발생했습니다. 다시 시도해주세요.');
      }
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
      gender: '',
      image: null,
    });
    if (fileInputRef.current) {
      fileInputRef.current.value = '';
    }
  };

  if (error) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-purple-50 via-indigo-50 to-blue-50 dark:from-gray-900 dark:via-purple-900 dark:to-gray-800 pb-20">
        <AppHeader 
          title="관상 분석" 
          onFontSizeChange={setFontSize}
          currentFontSize={fontSize}
        />
        <FortuneErrorBoundary 
          error={error} 
          reset={() => setError(null)}
          fallbackMessage="관상 분석 서비스는 현재 준비 중입니다. 실제 AI 분석을 곧 제공할 예정입니다."
        />
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-purple-50 via-indigo-50 to-blue-50 dark:from-gray-900 dark:via-purple-900 dark:to-gray-800 pb-20">
      <AppHeader 
        title="관상 분석" 
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
                  className="bg-gradient-to-r from-purple-500 to-indigo-500 rounded-full w-20 h-20 flex items-center justify-center mx-auto mb-4"
                  whileHover={{ rotate: 360 }}
                  transition={{ duration: 0.8 }}
                >
                  <User className="w-10 h-10 text-white" />
                </motion.div>
                <h1 className={`${fontClasses.heading} font-bold text-gray-900 dark:text-gray-100 mb-2`}>관상 분석</h1>
                <p className={`${fontClasses.text} text-gray-600 dark:text-gray-400`}>AI가 당신의 얼굴을 분석하여 운세를 알려드립니다.</p>
              </motion.div>

              {/* 기본 정보 */}
              <motion.div variants={itemVariants}>
                <Card className="border-purple-200 dark:border-purple-700 dark:bg-gray-800">
                  <CardHeader className="pb-4">
                    <CardTitle className={`${fontClasses.title} flex items-center gap-2 text-purple-700 dark:text-purple-400`}>
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
                      <select 
                        value={formData.birthYear} 
                        onChange={(e) => setFormData(prev => ({ ...prev, birthYear: e.target.value }))}
                        className={`${fontClasses.text} mt-1 block w-full rounded-md border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 py-2 px-3 shadow-sm focus:border-purple-500 focus:ring-purple-500 sm:text-sm`}
                      >
                        <option value="">년도 선택</option>
                        {yearOptions.map((year) => (
                          <option key={year} value={year.toString()}>
                            {year}년
                          </option>
                        ))}
                      </select>
                    </div>

                    {/* 월 선택 */}
                    <div>
                      <Label className={`${fontClasses.text} dark:text-gray-300`}>생월</Label>
                      <select 
                        value={formData.birthMonth} 
                        onChange={(e) => setFormData(prev => ({ ...prev, birthMonth: e.target.value }))}
                        className={`${fontClasses.text} mt-1 block w-full rounded-md border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 py-2 px-3 shadow-sm focus:border-purple-500 focus:ring-purple-500 sm:text-sm`}
                      >
                        <option value="">월 선택</option>
                        {monthOptions.map((month) => (
                          <option key={month} value={month.toString()}>
                            {month}월
                          </option>
                        ))}
                      </select>
                    </div>

                    {/* 일 선택 */}
                    <div>
                      <Label className={`${fontClasses.text} dark:text-gray-300`}>생일</Label>
                      <select 
                        value={formData.birthDay} 
                        onChange={(e) => setFormData(prev => ({ ...prev, birthDay: e.target.value }))}
                        className={`${fontClasses.text} mt-1 block w-full rounded-md border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 py-2 px-3 shadow-sm focus:border-purple-500 focus:ring-purple-500 sm:text-sm`}
                      >
                        <option value="">일 선택</option>
                        {dayOptions.map((day) => (
                          <option key={day} value={day.toString()}>
                            {day}일
                          </option>
                        ))}
                      </select>
                    </div>

                    {/* 성별 선택 */}
                    <div>
                      <Label className={`${fontClasses.text} dark:text-gray-300`}>성별</Label>
                      <div className="flex space-x-4 mt-2">
                        <label className="flex items-center">
                          <input
                            type="radio"
                            name="gender"
                            value="남성"
                            checked={formData.gender === "남성"}
                            onChange={(e) => setFormData(prev => ({ ...prev, gender: e.target.value }))}
                            className="form-radio text-purple-600"
                          />
                          <span className={`${fontClasses.label} ml-2 dark:text-gray-300`}>남성</span>
                        </label>
                        <label className="flex items-center">
                          <input
                            type="radio"
                            name="gender"
                            value="여성"
                            checked={formData.gender === "여성"}
                            onChange={(e) => setFormData(prev => ({ ...prev, gender: e.target.value }))}
                            className="form-radio text-purple-600"
                          />
                          <span className={`${fontClasses.label} ml-2 dark:text-gray-300`}>여성</span>
                        </label>
                      </div>
                    </div>

                    {/* 선택된 생년월일 표시 */}
                    {formData.birthYear && formData.birthMonth && formData.birthDay && (
                      <div className="p-3 bg-purple-50 dark:bg-purple-900/20 rounded-lg border border-purple-200 dark:border-purple-700">
                        <p className={`${fontClasses.text} font-medium text-purple-800 dark:text-purple-300 text-center`}>
                          {formatKoreanDate(formData.birthYear, formData.birthMonth, formData.birthDay)}
                        </p>
                      </div>
                    )}
                  </CardContent>
                </Card>
              </motion.div>

              {/* 사진 업로드 */}
              <motion.div variants={itemVariants}>
                <Card className="border-indigo-200 dark:border-indigo-700 dark:bg-gray-800">
                  <CardHeader className="pb-4">
                    <CardTitle className={`${fontClasses.title} flex items-center gap-2 text-indigo-700 dark:text-indigo-400`}>
                      <Camera className="w-5 h-5" />
                      사진 업로드
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div>
                      <Label htmlFor="face-image" className={`${fontClasses.text} dark:text-gray-300`}>정면 사진을 업로드해주세요.</Label>
                      <Input
                        id="face-image"
                        type="file"
                        accept="image/*"
                        onChange={handleImageChange}
                        ref={fileInputRef}
                        className={`${fontClasses.text} mt-1 block w-full text-gray-900 dark:text-gray-100
                          file:mr-4 file:py-2 file:px-4
                          file:rounded-full file:border-0
                          file:text-sm file:font-semibold
                          file:bg-indigo-50 file:text-indigo-700
                          hover:file:bg-indigo-100
                        `}
                      />
                      {formData.image && (
                        <div className="mt-4 text-center">
                          <img 
                            src={URL.createObjectURL(formData.image)}
                            alt="Uploaded Face"
                            className="max-w-full h-auto rounded-lg shadow-md mx-auto"
                            style={{ maxHeight: '200px' }}
                          />
                          <p className={`${fontClasses.label} text-gray-500 dark:text-gray-400 mt-2`}>
                            {formData.image.name}
                          </p>
                        </div>
                      )}
                    </div>
                  </CardContent>
                </Card>
              </motion.div>

              {/* 분석 버튼 */}
              <motion.div variants={itemVariants} className="pt-4">
                <Button
                  onClick={handleSubmit}
                  disabled={isGenerating || isDailyGenerating}
                  className={`w-full bg-gradient-to-r from-purple-500 to-indigo-500 hover:from-purple-600 hover:to-indigo-600 text-white py-6 ${fontClasses.title} font-semibold`}
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
                          오늘의 관상 운세 보기
                        </>
                      ) : (
                        <>
                          <User className="w-5 h-5" />
                          관상 분석하기
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
              {/* 분석된 이미지 */}
              {result.image_url && (
                <motion.div variants={itemVariants} className="text-center">
                  <img 
                    src={result.image_url}
                    alt="Analyzed Face"
                    className="max-w-full h-auto rounded-lg shadow-md mx-auto mb-4"
                    style={{ maxHeight: '300px' }}
                  />
                </motion.div>
              )}

              {/* 전체 운세 */}
              <motion.div variants={itemVariants}>
                <Card className="bg-gradient-to-r from-purple-500 to-indigo-500 text-white">
                  <CardContent className="text-center py-8">
                    <div className={`flex items-center justify-center gap-2 mb-4`}>
                      <User className="w-6 h-6" />
                      <span className={`${fontClasses.title} font-medium`}>{formData.name}님의 관상 운세</span>
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

              {/* 세부 관상 분석 */}
              <motion.div variants={itemVariants}>
                <Card className="dark:bg-gray-800 dark:border-gray-700">
                  <CardHeader>
                    <CardTitle className={`${fontClasses.title} flex items-center gap-2 text-purple-600 dark:text-purple-400`}>
                      <BarChart3 className="w-5 h-5" />
                      세부 관상 분석
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    {[
                      { label: "얼굴형", shape: result.face_shape, icon: Face, meaning: "전반적인 인상" },
                      { label: "눈", shape: result.eye_analysis.shape, icon: Star, meaning: result.eye_analysis.meaning, fortune: result.eye_analysis.fortune },
                      { label: "코", shape: result.nose_analysis.shape, icon: Crown, meaning: result.nose_analysis.meaning, fortune: result.nose_analysis.fortune },
                      { label: "입", shape: result.mouth_analysis.shape, icon: Activity, meaning: result.mouth_analysis.meaning, fortune: result.mouth_analysis.fortune }
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
                                <span className={`${fontClasses.text} font-medium dark:text-gray-200`}>{item.label}: {item.shape}</span>
                                {item.meaning && <p className={`${fontClasses.label} text-gray-500 dark:text-gray-400`}>{item.meaning}</p>}
                                {item.fortune && <p className={`${fontClasses.label} text-purple-500 dark:text-purple-400`}>{item.fortune}</p>}
                              </div>
                            </div>
                          </div>
                        </div>
                      </motion.div>
                    ))}
                  </CardContent>
                </Card>
              </motion.div>

              {/* 성격 특성 및 인생 운세 */}
              <motion.div variants={itemVariants}>
                <Card className="dark:bg-gray-800 dark:border-gray-700">
                  <CardHeader>
                    <CardTitle className={`${fontClasses.title} flex items-center gap-2 text-blue-600 dark:text-blue-400`}>
                      <Users className="w-5 h-5" />
                      성격 및 인생 운세
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div className="p-4 bg-blue-50 dark:bg-blue-900/30 rounded-lg">
                      <h4 className={`${fontClasses.text} font-medium text-blue-800 dark:text-blue-300 mb-2 flex items-center gap-2`}>
                        <Star className="w-4 h-4" />
                        주요 성격 특성
                      </h4>
                      <p className={`${fontClasses.text} text-blue-700 dark:text-blue-400`}>
                        {result.personality_traits.join(', ')}
                      </p>
                    </div>
                    <div className="grid grid-cols-2 gap-4">
                      <div className="p-4 bg-green-50 dark:bg-green-900/30 rounded-lg">
                        <h4 className={`${fontClasses.text} font-medium text-green-800 dark:text-green-300 mb-2 flex items-center gap-2`}>
                          <Crown className="w-4 h-4" />
                          재물운
                        </h4>
                        <p className={`${fontClasses.title} font-semibold ${getLuckColor(result.life_fortune.wealth)}`}>
                          {result.life_fortune.wealth}점
                        </p>
                      </div>
                      <div className="p-4 bg-pink-50 dark:bg-pink-900/30 rounded-lg">
                        <h4 className={`${fontClasses.text} font-medium text-pink-800 dark:text-pink-300 mb-2 flex items-center gap-2`}>
                          <Star className="w-4 h-4" />
                          연애운
                        </h4>
                        <p className={`${fontClasses.title} font-semibold ${getLuckColor(result.life_fortune.love)}`}>
                          {result.life_fortune.love}점
                        </p>
                      </div>
                      <div className="p-4 bg-orange-50 dark:bg-orange-900/30 rounded-lg">
                        <h4 className={`${fontClasses.text} font-medium text-orange-800 dark:text-orange-300 mb-2 flex items-center gap-2`}>
                          <Activity className="w-4 h-4" />
                          직업운
                        </h4>
                        <p className={`${fontClasses.title} font-semibold ${getLuckColor(result.life_fortune.career)}`}>
                          {result.life_fortune.career}점
                        </p>
                      </div>
                      <div className="p-4 bg-teal-50 dark:bg-teal-900/30 rounded-lg">
                        <h4 className={`${fontClasses.text} font-medium text-teal-800 dark:text-teal-300 mb-2 flex items-center gap-2`}>
                          <Shield className="w-4 h-4" />
                          건강운
                        </h4>
                        <p className={`${fontClasses.title} font-semibold ${getLuckColor(result.life_fortune.health)}`}>
                          {result.life_fortune.health}점
                        </p>
                      </div>
                    </div>
                    <div className="p-4 bg-gray-50 dark:bg-gray-700 rounded-lg">
                      <h4 className={`${fontClasses.text} font-medium text-gray-800 dark:text-gray-300 mb-2 flex items-center gap-2`}>
                        <Star className="w-4 h-4" />
                        행운 조언
                      </h4>
                      <p className={`${fontClasses.text} text-gray-700 dark:text-gray-400`}>{result.lucky_advice}</p>
                    </div>
                  </CardContent>
                </Card>
              </motion.div>

              {/* 다시 분석하기 및 재생성 버튼 */}
              <motion.div variants={itemVariants} className="pt-4 space-y-3">
                {canRegenerate && (
                  <Button
                    onClick={() => void (async () => {
                      try {
                        await new Promise(resolve => setTimeout(resolve, 3000));
                        const analysisResult = await analyzeFaceReadingFortune(formData.image!); // Use existing image
                        
                        const fortuneResult: FortuneResult = {
                          user_info: {
                            name: formData.name,
                            birth_date: koreanToIsoDate(formData.birthYear, formData.birthMonth, formData.birthDay),
                          },
                          fortune_scores: {
                            overall_luck: analysisResult.overall_luck,
                            life_fortune: analysisResult.life_fortune,
                          },
                          insights: {
                            face_shape: analysisResult.face_shape,
                            eye_analysis: analysisResult.eye_analysis,
                            nose_analysis: analysisResult.nose_analysis,
                            mouth_analysis: analysisResult.mouth_analysis,
                            personality_traits: analysisResult.personality_traits,
                            lucky_advice: analysisResult.lucky_advice,
                          },
                          metadata: {
                            gender: formData.gender,
                            image_url: analysisResult.image_url,
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
                    })()}
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
                  className={`w-full border-purple-300 dark:border-purple-700 text-purple-600 dark:text-purple-400 hover:bg-purple-50 dark:hover:bg-purple-900/30 py-3 ${fontClasses.text}`}
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