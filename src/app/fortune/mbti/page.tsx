"use client";

import { useState, useEffect, useCallback } from "react";
import { motion } from "framer-motion";
import { useForm, Controller } from "react-hook-form";
import toast from 'react-hot-toast';
import { useFortuneStream } from "@/hooks/use-fortune-stream";
import { useUserProfile, hasUserMBTI, hasUserName } from "@/hooks/use-user-profile";
import AppHeader from "@/components/AppHeader";
import { Progress } from "@/components/ui/progress";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { 
  ZapIcon, 
  TrendingUpIcon, 
  StarIcon, 
  HeartIcon, 
  BriefcaseIcon, 
  CoinsIcon,
  UserIcon,
  CheckCircleIcon,
  AlertCircleIcon,
  BrainIcon,
  UsersIcon,
  TargetIcon,
  RefreshCwIcon,
  SparklesIcon,
  ClockIcon
} from "lucide-react";

// MBTI 유형별 데이터 (UI 전용)
const MBTI_TYPES = {
  INTJ: { name: "건축가", color: "purple", emoji: "🏗️", element: "직관 + 사고" },
  INTP: { name: "논리술사", color: "indigo", emoji: "🔬", element: "직관 + 사고" },
  ENTJ: { name: "통솔자", color: "red", emoji: "👑", element: "직관 + 사고" },
  ENTP: { name: "변론가", color: "orange", emoji: "💡", element: "직관 + 사고" },
  INFJ: { name: "옹호자", color: "green", emoji: "🌱", element: "직관 + 감정" },
  INFP: { name: "중재자", color: "pink", emoji: "🎨", element: "직관 + 감정" },
  ENFJ: { name: "선도자", color: "blue", emoji: "🌟", element: "직관 + 감정" },
  ENFP: { name: "활동가", color: "yellow", emoji: "🎭", element: "직관 + 감정" },
  ISTJ: { name: "현실주의자", color: "gray", emoji: "📋", element: "감각 + 사고" },
  ISFJ: { name: "수호자", color: "teal", emoji: "🛡️", element: "감각 + 감정" },
  ESTJ: { name: "경영자", color: "emerald", emoji: "📊", element: "감각 + 사고" },
  ESFJ: { name: "집정관", color: "rose", emoji: "🤝", element: "감각 + 감정" },
  ISTP: { name: "만능재주꾼", color: "slate", emoji: "🔧", element: "감각 + 사고" },
  ISFP: { name: "모험가", color: "cyan", emoji: "🌸", element: "감각 + 감정" },
  ESTP: { name: "사업가", color: "amber", emoji: "⚡", element: "감각 + 사고" },
  ESFP: { name: "연예인", color: "lime", emoji: "🎪", element: "감각 + 감정" }
};

interface MBTIFormData {
  mbti: string;
  name: string;
  includeCareer: boolean;
  includeLove: boolean;
  includeWealth: boolean;
}

export default function MbtiFortunePage() {
  const [selectedMBTI, setSelectedMBTI] = useState<string>("");
  const [fontSize, setFontSize] = useState<'small' | 'medium' | 'large'>('medium');
  const [lastGenerated, setLastGenerated] = useState<Date | null>(null);
  
  // 사용자 프로필 훅 사용
  const { profile, isLoading: profileLoading } = useUserProfile();

  // Context7 최적화 패턴: useForm 활용
  const { control, handleSubmit, watch, setValue, reset } = useForm<MBTIFormData>({
    mode: 'onChange',
    defaultValues: {
      mbti: '',
      name: '',
      includeCareer: true,
      includeLove: true,
      includeWealth: true
    }
  });

  // Context7 패턴: 특정 필드만 구독
  const watchedMBTI = watch('mbti');

  // 향상된 운세 Hook 사용
  const {
    control: fortuneControl,
    isGenerating,
    progress,
    result,
    error,
    generateFortune,
    checkCache,
    reset: resetFortune
  } = useFortuneStream({
    packageType: 'single',
    enableCache: true,
    cacheDuration: 1440, // 24시간 캐시
    onSuccess: () => {
      setLastGenerated(new Date());
      toast.success('🔮 MBTI 운세가 완성되었습니다!', {
        duration: 3000,
        icon: '✨'
      });
    },
    onError: (error) => {
      toast.error(`운세 생성 실패: ${error.message}`, {
        duration: 5000
      });
    }
  });

  // 프로필 데이터로 폼 초기화
  useEffect(() => {
    if (!profileLoading && profile) {
      if (hasUserMBTI(profile)) {
        setSelectedMBTI(profile.mbti!);
        setValue('mbti', profile.mbti!);
      }
      if (hasUserName(profile)) {
        setValue('name', profile.name);
      }
    }
  }, [profile, profileLoading, setValue]);

  // Context7 패턴: 메모이제이션된 MBTI 선택 핸들러
  const handleMBTISelect = useCallback((mbti: string) => {
    setSelectedMBTI(mbti);
    setValue('mbti', mbti);
  }, [setValue]);

  // Context7 패턴: Promise toast를 활용한 운세 생성
  const onSubmit = useCallback(async (data: MBTIFormData) => {
    if (!data.mbti || !data.name) {
      toast.error('MBTI와 이름을 모두 입력해주세요!');
      return;
    }

    // 캐시 확인
    const cachedResult = checkCache({
      category: 'mbti',
      userInfo: {
        mbti: data.mbti,
        name: data.name
      },
      packageType: 'single'
    });

    if (cachedResult) {
      return;
    }

    // 새로운 GPT 연동 운세 생성
    await generateFortune({
      category: 'mbti',
      userInfo: {
        mbti: data.mbti,
        name: data.name,
        preferences: {
          includeCareer: data.includeCareer,
          includeLove: data.includeLove,
          includeWealth: data.includeWealth
        }
      },
      packageType: 'single'
    });
  }, [generateFortune, checkCache]);

  // 결과 렌더링 함수
  const renderFortuneResult = () => {
    if (!result?.mbti) return null;

    const fortune = result.mbti;
    const mbtiInfo = MBTI_TYPES[watchedMBTI as keyof typeof MBTI_TYPES];

    return (
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.5 }}
        className="mt-8 space-y-6"
      >
        {/* MBTI 정보 카드 */}
        <Card className="border-violet-200 bg-gradient-to-r from-violet-50 to-purple-50">
          <CardHeader className="text-center">
            <div className="flex items-center justify-center gap-3 mb-2">
              <span className="text-4xl">{mbtiInfo?.emoji}</span>
              <div>
                <h2 className="text-2xl font-bold text-violet-700">{watchedMBTI}</h2>
                <p className="text-violet-600">{mbtiInfo?.name}</p>
                <p className="text-sm text-violet-500">{mbtiInfo?.element}</p>
              </div>
            </div>
            {lastGenerated && (
              <div className="flex items-center justify-center gap-2 text-sm text-gray-500">
                <ClockIcon className="h-4 w-4" />
                마지막 업데이트: {lastGenerated.toLocaleString('ko-KR')}
              </div>
            )}
          </CardHeader>
        </Card>

        {/* 종합 운세 */}
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <StarIcon className="h-5 w-5 text-yellow-500" />
              종합 운세
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="mb-4">
              <div className="flex items-center justify-between mb-2">
                <span className="font-medium">전체 운세</span>
                <span className="text-lg font-bold text-violet-600">
                  {fortune.overall_score || 85}점
                </span>
              </div>
              <Progress 
                value={fortune.overall_score || 85} 
                className="h-2"
              />
            </div>
            
            <p className="text-gray-700 leading-relaxed mb-4">
              {fortune.summary || "AI가 생성한 개인 맞춤 운세입니다."}
            </p>

            {fortune.keywords && (
              <div className="flex flex-wrap gap-2">
                {fortune.keywords.map((keyword: string, index: number) => (
                  <Badge key={index} variant="secondary" className="bg-violet-100 text-violet-700">
                    {keyword}
                  </Badge>
                ))}
              </div>
            )}
          </CardContent>
        </Card>

        {/* 세부 운세 */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          <Card className="bg-red-50 border-red-200">
            <CardHeader className="pb-3">
              <CardTitle className="text-lg flex items-center gap-2">
                <HeartIcon className="h-5 w-5 text-red-500" />
                연애운
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="text-center mb-3">
                <span className="text-2xl font-bold text-red-600">
                  {fortune.love_score || 78}점
                </span>
              </div>
              <Progress value={fortune.love_score || 78} className="h-2 mb-3" />
              <p className="text-sm text-gray-600">
                {fortune.love_advice || "새로운 인연의 기회가 찾아올 것입니다."}
              </p>
            </CardContent>
          </Card>

          <Card className="bg-blue-50 border-blue-200">
            <CardHeader className="pb-3">
              <CardTitle className="text-lg flex items-center gap-2">
                <BriefcaseIcon className="h-5 w-5 text-blue-500" />
                직업운
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="text-center mb-3">
                <span className="text-2xl font-bold text-blue-600">
                  {fortune.career_score || 82}점
                </span>
              </div>
              <Progress value={fortune.career_score || 82} className="h-2 mb-3" />
              <p className="text-sm text-gray-600">
                {fortune.career_advice || "새로운 도전이 성공으로 이어질 것입니다."}
              </p>
            </CardContent>
          </Card>

          <Card className="bg-green-50 border-green-200">
            <CardHeader className="pb-3">
              <CardTitle className="text-lg flex items-center gap-2">
                <CoinsIcon className="h-5 w-5 text-green-500" />
                재물운
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="text-center mb-3">
                <span className="text-2xl font-bold text-green-600">
                  {fortune.wealth_score || 75}점
                </span>
              </div>
              <Progress value={fortune.wealth_score || 75} className="h-2 mb-3" />
              <p className="text-sm text-gray-600">
                {fortune.wealth_advice || "꾸준한 투자가 좋은 결과를 가져올 것입니다."}
              </p>
            </CardContent>
          </Card>
        </div>

        {/* 조언 카드 */}
        {fortune.advice && (
          <Card className="bg-gradient-to-r from-amber-50 to-orange-50 border-amber-200">
            <CardHeader>
              <CardTitle className="flex items-center gap-2 text-amber-700">
                <SparklesIcon className="h-5 w-5" />
                AI의 맞춤 조언
              </CardTitle>
            </CardHeader>
            <CardContent>
              <p className="text-gray-700 leading-relaxed">{fortune.advice}</p>
            </CardContent>
          </Card>
        )}

        {/* 재생성 버튼 */}
        <div className="text-center">
          <Button
            onClick={() => resetFortune()}
            variant="outline"
            size="lg"
            disabled={isGenerating}
            className="gap-2"
          >
            <RefreshCwIcon className="h-4 w-4" />
            새로운 운세 받기
          </Button>
        </div>
      </motion.div>
    );
  };

  const containerVariants = {
    hidden: { opacity: 0 },
    visible: {
      opacity: 1,
      transition: { staggerChildren: 0.1 }
    }
  };

  const itemVariants = {
    hidden: { y: 20, opacity: 0 },
    visible: {
      y: 0,
      opacity: 1,
      transition: { type: "spring" as const, stiffness: 100 }
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-violet-50 via-purple-50 to-indigo-50">
      <AppHeader 
        title="MBTI 주간운세"
        onFontSizeChange={setFontSize}
        currentFontSize={fontSize}
      />
      
      <motion.div 
        className="container mx-auto px-4 pt-4 pb-20"
        variants={containerVariants}
        initial="hidden"
        animate="visible"
      >
        {/* 헤더 섹션 */}
        <motion.div variants={itemVariants} className="text-center mb-8">
          <div className="flex items-center justify-center gap-2 mb-4">
            <ZapIcon className="h-8 w-8 text-violet-600" />
            <h1 className="text-3xl font-bold bg-gradient-to-r from-violet-600 to-purple-600 bg-clip-text text-transparent">
              MBTI 맞춤 운세
            </h1>
          </div>
          <p className="text-gray-600">
            AI가 분석하는 성격 유형별 개인 맞춤 운세 (GPT-4 기반)
          </p>
        </motion.div>

        {/* MBTI 선택 */}
        {!selectedMBTI && (
          <motion.div variants={itemVariants}>
            <Card className="mb-8">
              <CardHeader>
                <CardTitle className="text-center flex items-center justify-center gap-2">
                  <BrainIcon className="h-5 w-5 text-violet-600" />
                  당신의 MBTI를 선택해주세요
                </CardTitle>
              </CardHeader>
              <CardContent>
                <div className="grid grid-cols-4 gap-3">
                  {Object.entries(MBTI_TYPES).map(([type, info]) => (
                    <motion.div
                      key={type}
                      whileHover={{ scale: 1.05 }}
                      whileTap={{ scale: 0.95 }}
                    >
                      <Button
                        variant="outline"
                        className="h-auto p-3 flex flex-col items-center gap-2 w-full hover:bg-violet-50"
                        onClick={() => handleMBTISelect(type)}
                      >
                        <span className="text-2xl">{info.emoji}</span>
                        <span className="font-bold text-sm">{type}</span>
                        <span className="text-xs text-gray-600">{info.name}</span>
                      </Button>
                    </motion.div>
                  ))}
                </div>
              </CardContent>
            </Card>
          </motion.div>
        )}

        {/* 운세 생성 폼 */}
        {selectedMBTI && !result && (
          <motion.div variants={itemVariants}>
            <Card className="mb-8">
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <UserIcon className="h-5 w-5 text-violet-600" />
                  운세 생성하기
                </CardTitle>
              </CardHeader>
              <CardContent className="space-y-4">
                <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
                  <div className="flex items-center gap-3 p-3 bg-violet-50 rounded-lg">
                    <span className="text-2xl">{MBTI_TYPES[selectedMBTI as keyof typeof MBTI_TYPES]?.emoji}</span>
                    <div>
                      <p className="font-bold">{selectedMBTI} - {MBTI_TYPES[selectedMBTI as keyof typeof MBTI_TYPES]?.name}</p>
                      <p className="text-sm text-gray-600">{MBTI_TYPES[selectedMBTI as keyof typeof MBTI_TYPES]?.element}</p>
                    </div>
                    <Button 
                      type="button"
                      variant="outline" 
                      size="sm"
                      onClick={() => setSelectedMBTI("")}
                      className="ml-auto"
                    >
                      변경
                    </Button>
                  </div>

                  {profile && hasUserMBTI(profile) && hasUserName(profile) && (
                    <div className="p-3 bg-green-50 border border-green-200 rounded-lg">
                      <p className="text-sm text-green-700 flex items-center gap-2">
                        <CheckCircleIcon className="h-4 w-4" />
                        프로필 정보를 사용하여 자동으로 입력되었습니다
                      </p>
                    </div>
                  )}

                  <div>
                    <label className="block text-sm font-medium mb-2">이름</label>
                    <Controller
                      control={control}
                      name="name"
                      rules={{ required: '이름을 입력해주세요' }}
                      render={({ field, fieldState }) => (
                        <div>
                          <input
                            {...field}
                            type="text"
                            placeholder="이름을 입력하세요"
                            className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-violet-500 focus:border-transparent"
                          />
                          {fieldState.error && (
                            <p className="text-red-500 text-sm mt-1">{fieldState.error.message}</p>
                          )}
                        </div>
                      )}
                    />
                  </div>

                  <div className="space-y-3">
                    <label className="block text-sm font-medium">포함할 운세 (선택)</label>
                    <div className="grid grid-cols-3 gap-4">
                      <Controller
                        control={control}
                        name="includeCareer"
                        render={({ field }) => (
                          <label className="flex items-center gap-2">
                            <input
                              type="checkbox"
                              checked={field.value}
                              onChange={field.onChange}
                              className="rounded border-gray-300 text-violet-600 focus:ring-violet-500"
                            />
                            <span className="text-sm">직업운</span>
                          </label>
                        )}
                      />
                      <Controller
                        control={control}
                        name="includeLove"
                        render={({ field }) => (
                          <label className="flex items-center gap-2">
                            <input
                              type="checkbox"
                              checked={field.value}
                              onChange={field.onChange}
                              className="rounded border-gray-300 text-violet-600 focus:ring-violet-500"
                            />
                            <span className="text-sm">연애운</span>
                          </label>
                        )}
                      />
                      <Controller
                        control={control}
                        name="includeWealth"
                        render={({ field }) => (
                          <label className="flex items-center gap-2">
                            <input
                              type="checkbox"
                              checked={field.value}
                              onChange={field.onChange}
                              className="rounded border-gray-300 text-violet-600 focus:ring-violet-500"
                            />
                            <span className="text-sm">재물운</span>
                          </label>
                        )}
                      />
                    </div>
                  </div>

                  <Button
                    type="submit"
                    size="lg"
                    disabled={isGenerating || !watch('name')}
                    className="w-full bg-gradient-to-r from-violet-600 to-purple-600 hover:from-violet-700 hover:to-purple-700"
                  >
                    {isGenerating ? (
                      <div className="flex items-center gap-2">
                        <div className="animate-spin rounded-full h-4 w-4 border-2 border-white border-t-transparent" />
                        AI 분석 중... {progress}%
                      </div>
                    ) : (
                      <div className="flex items-center gap-2">
                        <SparklesIcon className="h-4 w-4" />
                        AI 맞춤 운세 생성하기
                      </div>
                    )}
                  </Button>
                </form>

                {isGenerating && (
                  <div className="mt-4">
                    <Progress value={progress} className="h-2" />
                    <p className="text-sm text-gray-600 mt-2 text-center">
                      AI가 당신만의 맞춤 운세를 생성하고 있습니다...
                    </p>
                  </div>
                )}
              </CardContent>
            </Card>
          </motion.div>
        )}

        {/* 운세 결과 */}
        {renderFortuneResult()}

        {/* 에러 표시 */}
        {error && (
          <motion.div variants={itemVariants}>
            <Card className="border-red-200 bg-red-50">
              <CardContent className="pt-6">
                <div className="flex items-center gap-2 text-red-600">
                  <AlertCircleIcon className="h-5 w-5" />
                  <span>오류가 발생했습니다: {error.message}</span>
                </div>
              </CardContent>
            </Card>
          </motion.div>
        )}
      </motion.div>
    </div>
  );
} 