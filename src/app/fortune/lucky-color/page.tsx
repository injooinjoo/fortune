"use client";

import { useState, useEffect, useCallback } from "react";
import { motion } from "framer-motion";
import { useForm, Controller } from "react-hook-form";
import toast from 'react-hot-toast';
import { useFortuneStream } from "@/hooks/use-fortune-stream";
import AppHeader from "@/components/AppHeader";
import { Progress } from "@/components/ui/progress";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { KoreanDatePicker } from "@/components/ui/korean-date-picker";
import { 
  Palette, 
  Star, 
  Sparkles,
  RefreshCw,
  Heart,
  Sun,
  Moon,
  UserIcon,
  AlertCircle
} from "lucide-react";

interface ColorFormData {
  name: string;
  birthDate: string;
  currentMood: string;
  favoriteColor: string;
}

export default function LuckyColorPage() {
  const [fontSize, setFontSize] = useState<'small' | 'medium' | 'large'>('medium');

  // React Hook Form 설정
  const { control, handleSubmit, watch, setValue, reset } = useForm<ColorFormData>({
    mode: 'onChange',
    defaultValues: {
      name: '',
      birthDate: '',
      currentMood: '평온',
      favoriteColor: '파란색'
    }
  });

  // 향상된 운세 Hook 사용
  const {
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
      toast.success('🎨 행운의 색깔이 완성되었습니다!', {
        duration: 3000,
        icon: '✨'
      });
    },
    onError: (error) => {
      toast.error(`색깔 분석 실패: ${error.message}`, {
        duration: 5000
      });
    }
  });

  // 사용자 데이터 로드
  const loadUserData = useCallback(() => {
    try {
      const { getUserInfo } = require("@/lib/user-storage");
      const userInfo = getUserInfo();
      
      if (userInfo.name) setValue('name', userInfo.name);
      if (userInfo.birth_date) setValue('birthDate', userInfo.birth_date);
    } catch (error) {
      console.warn("사용자 데이터 로드 실패:", error);
    }
  }, [setValue]);

  useEffect(() => {
    loadUserData();
  }, [loadUserData]);

  // 폼 제출 핸들러
  const onSubmit = useCallback(async (data: ColorFormData) => {
    if (!data.name || !data.birthDate) {
      toast.error('이름과 생년월일을 모두 입력해주세요!');
      return;
    }

    // 캐시 확인
    const cachedResult = checkCache({
      category: 'lucky-color',
      userInfo: {
        name: data.name,
        birthDate: data.birthDate,
        currentMood: data.currentMood,
        favoriteColor: data.favoriteColor
      },
      packageType: 'single'
    });

    if (cachedResult) {
      return;
    }

    // 새로운 GPT 연동 운세 생성
    await generateFortune({
      category: 'lucky-color',
      userInfo: {
        name: data.name,
        birthDate: data.birthDate,
        currentMood: data.currentMood,
        favoriteColor: data.favoriteColor
      },
      packageType: 'single'
    });
  }, [generateFortune, checkCache]);

  // 결과 렌더링
  const renderColorResult = () => {
    if (!result?.['lucky-color']) return null;

    const colorResult = result['lucky-color'];

    return (
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.5 }}
        className="mt-8 space-y-6"
      >
        {/* 메인 행운 색깔 */}
        <Card className="bg-gradient-to-r from-pink-50 to-purple-50 border-pink-200">
          <CardHeader className="text-center">
            <CardTitle className="flex items-center justify-center gap-2 text-pink-700">
              <Palette className="h-6 w-6" />
              오늘의 행운 색깔
            </CardTitle>
          </CardHeader>
          <CardContent className="text-center">
            <div 
              className="w-32 h-32 mx-auto rounded-full mb-4 shadow-lg border-4 border-white"
              style={{ backgroundColor: colorResult.main_color?.hex || '#FF69B4' }}
            />
            <h3 className="text-2xl font-bold text-gray-800 mb-2">
              {colorResult.main_color?.name || '핑크'}
            </h3>
            <p className="text-gray-600 mb-4">
              {colorResult.description || "오늘 당신에게 행운을 가져다줄 색깔입니다."}
            </p>
            <div className="flex flex-wrap justify-center gap-2">
              {(colorResult.effects || ['사랑운', '행복']).map((effect: string, index: number) => (
                <Badge key={index} variant="secondary" className="bg-pink-100 text-pink-700">
                  {effect}
                </Badge>
              ))}
            </div>
          </CardContent>
        </Card>

        {/* 보조 색깔들 */}
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <Star className="h-5 w-5 text-yellow-500" />
              추천 조합 색깔
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="grid grid-cols-3 gap-4">
              {(colorResult.secondary_colors || [
                { name: '하늘색', hex: '#87CEEB', purpose: '평온함' },
                { name: '연두색', hex: '#90EE90', purpose: '희망' },
                { name: '라벤더', hex: '#E6E6FA', purpose: '우아함' }
              ]).map((color: any, index: number) => (
                <div key={index} className="text-center">
                  <div 
                    className="w-16 h-16 mx-auto rounded-full mb-2 border-2 border-gray-200"
                    style={{ backgroundColor: color.hex }}
                  />
                  <p className="text-sm font-medium">{color.name}</p>
                  <p className="text-xs text-gray-500">{color.purpose}</p>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>

        {/* 활용 방법 */}
        <Card className="bg-gradient-to-r from-amber-50 to-orange-50 border-amber-200">
          <CardHeader>
            <CardTitle className="flex items-center gap-2 text-amber-700">
              <Sparkles className="h-5 w-5" />
              색깔 활용 가이드
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div className="space-y-3">
                <h4 className="font-semibold flex items-center gap-2">
                  <Heart className="h-4 w-4 text-red-500" />
                  패션 & 액세서리
                </h4>
                <ul className="text-sm text-gray-600 space-y-1">
                  <li>• 메인 색깔의 소품이나 액세서리 착용</li>
                  <li>• 가방이나 신발에 포인트 컬러로 활용</li>
                  <li>• 네일 아트나 립스틱 색상 선택시 참고</li>
                </ul>
              </div>
              <div className="space-y-3">
                <h4 className="font-semibold flex items-center gap-2">
                  <Sun className="h-4 w-4 text-yellow-500" />
                  생활 속 활용
                </h4>
                <ul className="text-sm text-gray-600 space-y-1">
                  <li>• 핸드폰 케이스나 지갑 색상 선택</li>
                  <li>• 방 인테리어나 소품에 적용</li>
                  <li>• 중요한 일이 있을 때 해당 색상 활용</li>
                </ul>
              </div>
            </div>
          </CardContent>
        </Card>

        {/* AI 조언 */}
        {colorResult.advice && (
          <Card className="bg-gradient-to-r from-violet-50 to-purple-50 border-violet-200">
            <CardHeader>
              <CardTitle className="flex items-center gap-2 text-violet-700">
                <Moon className="h-5 w-5" />
                AI의 특별한 조언
              </CardTitle>
            </CardHeader>
            <CardContent>
              <p className="text-gray-700 leading-relaxed">{colorResult.advice}</p>
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
            <RefreshCw className="h-4 w-4" />
            새로운 색깔 분석받기
          </Button>
        </div>
      </motion.div>
    );
  };

  const moods = ['평온', '기쁨', '우울', '불안', '설렘', '피곤', '외로움', '화남'];
  const colors = ['빨간색', '파란색', '노란색', '초록색', '보라색', '핑크', '주황색', '검은색', '흰색'];

  return (
    <div className="min-h-screen bg-gradient-to-br from-pink-50 via-purple-50 to-indigo-50">
      <AppHeader 
        title="행운의 색깔"
        onFontSizeChange={setFontSize}
        currentFontSize={fontSize}
      />
      
      <div className="container mx-auto px-4 pt-4 pb-20">
        {/* 헤더 섹션 */}
        <motion.div 
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="text-center mb-8"
        >
          <div className="flex items-center justify-center gap-2 mb-4">
            <Palette className="h-8 w-8 text-pink-600" />
            <h1 className="text-3xl font-bold bg-gradient-to-r from-pink-600 to-purple-600 bg-clip-text text-transparent">
              오늘의 행운 색깔
            </h1>
          </div>
          <p className="text-gray-600">
            AI가 분석하는 개인 맞춤 행운의 색깔과 활용법
          </p>
        </motion.div>

        {/* 폼 섹션 */}
        {!result && (
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.2 }}
          >
            <Card className="mb-8">
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <UserIcon className="h-5 w-5 text-pink-600" />
                  색깔 분석하기
                </CardTitle>
              </CardHeader>
              <CardContent>
                <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
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
                            className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-pink-500 focus:border-transparent"
                          />
                          {fieldState.error && (
                            <p className="text-red-500 text-sm mt-1">{fieldState.error.message}</p>
                          )}
                        </div>
                      )}
                    />
                  </div>

                  <div>
                    <Controller
                      control={control}
                      name="birthDate"
                      rules={{ required: '생년월일을 입력해주세요' }}
                      render={({ field, fieldState }) => (
                        <div>
                          <KoreanDatePicker
                            label="생년월일"
                            value={field.value}
                            onChange={field.onChange}
                            placeholder="생년월일을 선택하세요"
                            required
                          />
                          {fieldState.error && (
                            <p className="text-red-500 text-sm mt-1">{fieldState.error.message}</p>
                          )}
                        </div>
                      )}
                    />
                  </div>

                  <div>
                    <label className="block text-sm font-medium mb-2">현재 기분</label>
                    <Controller
                      control={control}
                      name="currentMood"
                      render={({ field }) => (
                        <select
                          {...field}
                          className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-pink-500 focus:border-transparent"
                        >
                          {moods.map(mood => (
                            <option key={mood} value={mood}>{mood}</option>
                          ))}
                        </select>
                      )}
                    />
                  </div>

                  <div>
                    <label className="block text-sm font-medium mb-2">좋아하는 색깔</label>
                    <Controller
                      control={control}
                      name="favoriteColor"
                      render={({ field }) => (
                        <select
                          {...field}
                          className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-pink-500 focus:border-transparent"
                        >
                          {colors.map(color => (
                            <option key={color} value={color}>{color}</option>
                          ))}
                        </select>
                      )}
                    />
                  </div>

                  <Button
                    type="submit"
                    size="lg"
                    disabled={isGenerating || !watch('name') || !watch('birthDate')}
                    className="w-full bg-gradient-to-r from-pink-600 to-purple-600 hover:from-pink-700 hover:to-purple-700"
                  >
                    {isGenerating ? (
                      <div className="flex items-center gap-2">
                        <div className="animate-spin rounded-full h-4 w-4 border-2 border-white border-t-transparent" />
                        AI 분석 중... {progress}%
                      </div>
                    ) : (
                      <div className="flex items-center gap-2">
                        <Sparkles className="h-4 w-4" />
                        행운의 색깔 분석하기
                      </div>
                    )}
                  </Button>
                </form>

                {isGenerating && (
                  <div className="mt-4">
                    <Progress value={progress} className="h-2" />
                    <p className="text-sm text-gray-600 mt-2 text-center">
                      당신만의 행운 색깔을 찾고 있습니다...
                    </p>
                  </div>
                )}
              </CardContent>
            </Card>
          </motion.div>
        )}

        {/* 결과 섹션 */}
        {renderColorResult()}

        {/* 에러 표시 */}
        {error && (
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
          >
            <Card className="border-red-200 bg-red-50">
              <CardContent className="pt-6">
                <div className="flex items-center gap-2 text-red-600">
                  <AlertCircle className="h-5 w-5" />
                  <span>오류가 발생했습니다: {error.message}</span>
                </div>
              </CardContent>
            </Card>
          </motion.div>
        )}
      </div>
    </div>
  );
} 