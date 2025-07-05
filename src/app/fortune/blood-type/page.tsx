"use client";

import { useState, useEffect } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import AppHeader from "@/components/AppHeader";
import { useFortuneStream } from "@/hooks/use-fortune-stream";
import { useDailyFortune } from "@/hooks/use-daily-fortune";
import { useProfileCompletion } from "@/hooks/use-profile-completion";
import { FortuneResult } from "@/lib/schemas";
import { callGPTFortuneAPI, validateUserInput, FORTUNE_REQUIRED_FIELDS, FortuneServiceError } from "@/lib/fortune-utils";
import { FortuneErrorBoundary } from "@/components/FortuneErrorBoundary";
import ProfileCompletionModal from "@/components/ProfileCompletionModal";
import { getUserInfo } from "@/lib/user-storage";
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
  RotateCcw,
  CheckCircle,
  ArrowLeft,
  AlertCircle
} from "lucide-react";

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
  const [result, setResult] = useState<BloodTypeFortune | null>(null);
  const [hasProfileInfo, setHasProfileInfo] = useState(false);
  
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

  const {
    isModalOpen,
    currentFortune,
    checkProfileCompletion,
    requireProfileCompletion,
    handleProfileComplete,
    closeModal
  } = useProfileCompletion();

  // 프로필 정보 확인
  useEffect(() => {
    const { isComplete } = checkProfileCompletion('blood-type');
    setHasProfileInfo(isComplete);
    
    if (hasTodayFortune && todayFortune && step === 'form' && isComplete) {
      const savedData = todayFortune.fortune_data as any;
      
      if (savedData.fortune_scores) {
        if (!savedData.insights?.blood_type_traits || !savedData.insights?.lucky_advice || 
            !savedData.lucky_items?.compatible_blood_types) {
          throw new FortuneServiceError('혈액형');
        }
        
        const restoredResult: BloodTypeFortune = {
          overall_luck: savedData.fortune_scores.overall_luck,
          personality_match: savedData.fortune_scores.personality_match,
          love_match: savedData.fortune_scores.love_match,
          career_match: savedData.fortune_scores.career_match,
          health_match: savedData.fortune_scores.health_match,
          blood_type_traits: savedData.insights.blood_type_traits,
          lucky_advice: savedData.insights.lucky_advice,
          compatible_blood_types: savedData.lucky_items.compatible_blood_types
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
    const userInfo = getUserInfo();
    
    // 프로필 정보 검증
    if (!userInfo.name || !userInfo.birthDate || !userInfo.bloodType) {
      throw new Error('프로필 정보가 부족합니다.');
    }

    // GPT API 호출
    const gptResult = await callGPTFortuneAPI({
      type: 'blood-type',
      userInfo: {
        name: userInfo.name,
        birth_date: userInfo.birthDate,
        blood_type: userInfo.bloodType
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

  const handleSubmit = async () => {
    // 프로필 완성도 체크 후 운세 생성
    requireProfileCompletion('blood-type', '혈액형 운세', async () => {
      setIsGenerating(true);

      try {
        const userInfo = getUserInfo();
        
        if (hasTodayFortune && todayFortune) {
          const savedData = todayFortune.fortune_data as any;
          if (!savedData.fortune_scores || !savedData.insights?.blood_type_traits || 
              !savedData.insights?.lucky_advice || !savedData.lucky_items?.compatible_blood_types) {
            throw new FortuneServiceError('혈액형');
          }
          
          const restoredResult: BloodTypeFortune = {
            overall_luck: savedData.fortune_scores.overall_luck,
            personality_match: savedData.fortune_scores.personality_match,
            love_match: savedData.fortune_scores.love_match,
            career_match: savedData.fortune_scores.career_match,
            health_match: savedData.fortune_scores.health_match,
            blood_type_traits: savedData.insights.blood_type_traits,
            lucky_advice: savedData.insights.lucky_advice,
            compatible_blood_types: savedData.lucky_items.compatible_blood_types
          };
          setResult(restoredResult);
        } else {
          // 실제 GPT API 호출
          const fortuneResult = await analyzeBloodTypeFortune();
          setResult(fortuneResult);
          
          const fortuneData: FortuneResult = {
            user_info: {
              name: userInfo.name,
              birth_date: userInfo.birthDate,
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
            blood_type: userInfo.bloodType,
          }
        };
        
        await saveFortune(fortuneData);
      }
      
      setStep('result');
      } catch (error) {
        console.error('혈액형 운세 분석 실패:', error);
        
        // FortuneServiceError인 경우 에러 상태로 설정
        if (error instanceof FortuneServiceError) {
          setError(error);
        } else {
          alert('운세 분석 중 오류가 발생했습니다. 다시 시도해주세요.');
        }
      } finally {
        setIsGenerating(false);
      }
    });
  };

  const handleReset = () => {
    setStep('form');
    setResult(null);
  };

  const [error, setError] = useState<Error | null>(null);

  if (error) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-red-50 via-pink-50 to-rose-50 dark:from-gray-900 dark:via-red-900 dark:to-gray-800 pb-20">
        <AppHeader 
          title="혈액형 운세" 
          onFontSizeChange={setFontSize}
          currentFontSize={fontSize}
        />
        <FortuneErrorBoundary 
          error={error} 
          reset={() => setError(null)}
          fallbackMessage="혈액형 운세 서비스는 현재 준비 중입니다. 실제 AI 분석을 곧 제공할 예정입니다."
        />
      </div>
    );
  }

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

              {/* 프로필 정보 표시 */}
              {hasProfileInfo && (
                <motion.div variants={itemVariants}>
                  <Card className="border-red-200 dark:border-red-700 dark:bg-gray-800">
                    <CardHeader className="pb-4">
                      <CardTitle className={`${fontClasses.title} flex items-center gap-2 text-red-700 dark:text-red-400`}>
                        <Users className="w-5 h-5" />
                        프로필 정보
                      </CardTitle>
                    </CardHeader>
                    <CardContent className="space-y-4">
                      {(() => {
                        const userInfo = getUserInfo();
                        return (
                          <div className="space-y-3">
                            <div className="flex justify-between items-center">
                              <span className={`${fontClasses.text} text-gray-600 dark:text-gray-400`}>이름</span>
                              <span className={`${fontClasses.text} font-medium`}>{userInfo.name}</span>
                            </div>
                            <div className="flex justify-between items-center">
                              <span className={`${fontClasses.text} text-gray-600 dark:text-gray-400`}>생년월일</span>
                              <span className={`${fontClasses.text} font-medium`}>{userInfo.birthDate}</span>
                            </div>
                            <div className="flex justify-between items-center">
                              <span className={`${fontClasses.text} text-gray-600 dark:text-gray-400`}>혈액형</span>
                              <Badge variant="outline" className="bg-red-50 dark:bg-red-900/20 text-red-700 dark:text-red-400">
                                {userInfo.bloodType}
                              </Badge>
                            </div>
                          </div>
                        );
                      })()}
                    </CardContent>
                  </Card>
                </motion.div>
              )}

              {/* 프로필 정보 부족 안내 */}
              {!hasProfileInfo && (
                <motion.div variants={itemVariants}>
                  <Card className="border-amber-200 dark:border-amber-700 bg-amber-50 dark:bg-amber-900/20">
                    <CardContent className="p-6">
                      <div className="flex items-center gap-3 mb-4">
                        <AlertCircle className="w-6 h-6 text-amber-600 dark:text-amber-400" />
                        <h3 className={`${fontClasses.title} font-semibold text-amber-800 dark:text-amber-200`}>
                          추가 정보 필요
                        </h3>
                      </div>
                      <p className={`${fontClasses.text} text-amber-700 dark:text-amber-300 mb-4`}>
                        혈액형 운세를 확인하려면 이름, 생년월일, 혈액형 정보가 필요합니다.
                      </p>
                      <p className={`${fontClasses.label} text-amber-600 dark:text-amber-400`}>
                        아래 버튼을 클릭하면 필요한 정보를 입력할 수 있습니다.
                      </p>
                    </CardContent>
                  </Card>
                </motion.div>
              )}

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
                    onClick={() => void (async () => {
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
                        
                        // FortuneServiceError인 경우 에러 상태로 설정
                        if (error instanceof FortuneServiceError) {
                          setError(error);
                        } else {
                          alert('운세 재생성에 실패했습니다. 다시 시도해주세요.');
                        }
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

      {/* 프로필 완성 모달 */}
      <ProfileCompletionModal
        isOpen={isModalOpen}
        onClose={closeModal}
        onComplete={handleProfileComplete}
        fortuneCategory={currentFortune?.category || 'blood-type'}
        fortuneTitle={currentFortune?.title}
      />
    </div>
  );
}