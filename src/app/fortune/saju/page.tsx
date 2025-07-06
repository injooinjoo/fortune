"use client";

import React, { useState, useEffect } from "react";
import { Card, CardHeader, CardTitle, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Loader2, RefreshCw, Star, TrendingUp } from "lucide-react";
import AppHeader from "@/components/AppHeader";
import { useToast } from "@/hooks/use-toast";
import {
  RadarChart,
  PolarGrid,
  PolarAngleAxis,
  PolarRadiusAxis,
  Radar,
  ResponsiveContainer,
} from "recharts";
import { useDailyFortune } from "@/hooks/use-daily-fortune-legacy";
import { LifeProfileResultSchema, UserProfileSchema } from "@/ai/flows/generate-specialized-fortune";
import { z } from "zod";
import { useUserProfile } from "@/hooks/use-user-profile";
import { useRouter } from "next/navigation";

export default function SajuAnalysisPage() {
  const [fontSize, setFontSize] = useState<'small' | 'medium' | 'large'>('medium');
  const { toast } = useToast();
  const router = useRouter();
  
  // 사용자 프로필 훅 사용
  const { profile, isLoading: profileLoading, hasCompleteProfile } = useUserProfile();

  const { 
    todayFortune, 
    isLoading, 
    isGenerating, 
    error,
    hasTodayFortune,
    generateNewLifeProfile,
    loadTodayFortune,
  } = useDailyFortune({
    fortuneType: 'life-profile', // DB 저장을 위한 타입
    enabled: false, // 처음에는 수동으로 로드
  });

  const sajuResult = todayFortune?.fortune_data as z.infer<typeof LifeProfileResultSchema> | undefined;

  const handleLoad = async (forceRefresh = false) => {
    if (!profile || !hasCompleteProfile) {
      toast({ 
        title: "프로필 필요", 
        description: "사주 분석을 위해 프로필을 완성해주세요.",
        variant: "destructive"
      });
      router.push('/onboarding');
      return;
    }
    
    const userProfile: z.infer<typeof UserProfileSchema> = {
      name: profile.name,
      gender: profile.gender || 'other',
      birthDate: profile.birth_date!,
      mbti: profile.mbti || undefined,
    };
    
    if (forceRefresh) {
      toast({ title: "사주 재생성 중...", description: "AI가 당신의 운명을 다시 분석합니다." });
      await generateNewLifeProfile(userProfile);
      return;
    }
    
    // DB에 저장된 데이터가 있는지 먼저 확인
    await loadTodayFortune();
  };
  
  // 데이터가 로드되었지만, 실제 운세 데이터가 없는 경우 (처음 방문)
  useEffect(() => {
    if (!isLoading && !hasTodayFortune && !isGenerating && !error && profile && hasCompleteProfile) {
      const userProfile: z.infer<typeof UserProfileSchema> = {
        name: profile.name,
        gender: profile.gender || 'other',
        birthDate: profile.birth_date!,
        mbti: profile.mbti || undefined,
      };
      
      toast({ title: "첫 방문을 환영합니다!", description: "AI가 당신의 평생 사주를 생성합니다." });
      generateNewLifeProfile(userProfile);
    }
  }, [isLoading, hasTodayFortune, isGenerating, error, generateNewLifeProfile, profile, hasCompleteProfile]);

  // 최초 로드 - 프로필이 로드된 후 실행
  useEffect(() => {
    if (!profileLoading && profile) {
      handleLoad();
    }
  }, [profileLoading, profile]);

  if (profileLoading || isLoading || isGenerating) {
    return (
      <>
        <AppHeader 
          title="사주팔자" 
          onFontSizeChange={setFontSize}
          currentFontSize={fontSize}
        />
        <div className="flex items-center justify-center min-h-[400px]">
          <div className="text-center space-y-4">
            <Loader2 className="w-8 h-8 animate-spin mx-auto" />
            <div className="space-y-2">
              <p className="text-lg font-medium">{isGenerating ? "사주팔자 생성 중..." : "데이터 확인 중..."}</p>
              <p className="text-sm text-muted-foreground">
                {isGenerating ? 'AI가 당신의 운명을 분석하고 있습니다...' : '저장된 사주 정보를 불러오고 있습니다...'}
              </p>
            </div>
          </div>
        </div>
      </>
    );
  }

  if (error) {
    return (
      <>
        <AppHeader 
          title="사주팔자" 
          onFontSizeChange={setFontSize}
          currentFontSize={fontSize}
        />
        <div className="flex items-center justify-center min-h-[400px]">
          <div className="text-center space-y-4">
            <div className="text-red-500">
              <svg className="w-12 h-12 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.732-.833-2.5 0L3.34 16.5c-.77.833.192 2.5 1.732 2.5z" />
              </svg>
            </div>
            <div className="space-y-2">
              <p className="text-lg font-medium">데이터 로드 실패</p>
              <p className="text-sm text-muted-foreground">{error}</p>
            </div>
            <Button onClick={() => handleLoad(true)} className="mt-4">
              <RefreshCw className="w-4 h-4 mr-2" />
              다시 시도
            </Button>
          </div>
        </div>
      </>
    );
  }
  
  if (!sajuResult) {
    // 이 상태는 보통 로딩중에만 표시되지만, 에러 없이 데이터가 없는 엣지 케이스를 위해 유지
    return (
      <>
        <AppHeader 
          title="사주팔자" 
          onFontSizeChange={setFontSize}
          currentFontSize={fontSize}
        />
        <div className="flex items-center justify-center min-h-[400px]">
          <p>사주 정보를 표시할 수 없습니다.</p>
        </div>
      </>
    );
  }

  // 데이터가 없으면 빈 페이지 반환
  if (!sajuResult || !sajuResult.saju) {
    return (
      <>
        <AppHeader 
          title="사주팔자" 
          onFontSizeChange={setFontSize}
          currentFontSize={fontSize}
        />
        <div className="min-h-screen bg-gradient-to-br from-amber-50 via-orange-50 to-yellow-50 dark:from-gray-900 dark:via-gray-800 dark:to-gray-700 flex items-center justify-center">
          <Card className="max-w-md w-full mx-4">
            <CardContent className="pt-6 text-center">
              <p className="text-gray-600 dark:text-gray-400">
                운세 데이터를 불러올 수 없습니다. 새로고침해주세요.
              </p>
              <Button 
                onClick={() => window.location.reload()} 
                className="mt-4"
              >
                새로고침
              </Button>
            </CardContent>
          </Card>
        </div>
      </>
    );
  }

  // TODO: RadarChart 데이터 구조를 새로운 스키마에 맞게 변경해야 함.
  // 현재 sajuResult.saju.keywords 등을 활용할 수 있음.
  const chartData = sajuResult.saju.keywords && sajuResult.saju.keywords.length > 0 
    ? sajuResult.saju.keywords.map(kw => ({ subject: kw, A: Math.random() * 100, fullMark: 100 }))
    : [];

  return (
    <>
      <AppHeader 
        title="사주팔자" 
        onFontSizeChange={setFontSize}
        currentFontSize={fontSize}
      />
      <div className="pb-32 min-h-screen bg-gradient-to-br from-amber-50 via-orange-50 to-yellow-50 dark:from-gray-900 dark:via-gray-800 dark:to-gray-700">
        <div className="sticky top-16 z-10 bg-background/95 backdrop-blur-sm border-b">
          <div className="px-4 py-3 flex items-center justify-between">
            <div className="flex items-center gap-2">
              <Badge variant={hasTodayFortune ? "secondary" : "default"}>
                {hasTodayFortune ? `기존 정보 로드` : '새로 생성됨'}
              </Badge>
            </div>
            <Button 
              onClick={() => handleLoad(true)} 
              variant="outline" 
              size="sm"
              disabled={isGenerating || isLoading}
            >
              <RefreshCw className={`w-4 h-4 mr-2 ${isGenerating ? 'animate-spin' : ''}`} />
              새로 생성
            </Button>
          </div>
        </div>

        <div className="space-y-6 px-4 pt-6">
          <div className="bg-gradient-to-r from-blue-500/10 to-purple-500/10 rounded-2xl p-6 text-center">
            <div className="flex items-center justify-center gap-2 mb-3">
              <Star className="w-6 h-6 text-yellow-500" />
              <h2 className="text-xl font-bold">사주 총평</h2>
            </div>
            <p className="text-lg text-muted-foreground leading-relaxed">
              {sajuResult.saju.summary}
            </p>
          </div>

          <Card>
            <CardHeader className="pb-3">
              <CardTitle className="flex items-center gap-2">
                <TrendingUp className="w-5 h-5 text-green-500" />
                상세 분석
              </CardTitle>
            </CardHeader>
            <CardContent>
              <p className="text-muted-foreground leading-relaxed whitespace-pre-wrap">
                {sajuResult.saju.details}
              </p>
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle>타고난 재능</CardTitle>
            </CardHeader>
            <CardContent>
              <p className="text-muted-foreground">{sajuResult.talent.summary}</p>
              <p className="mt-4 text-sm text-muted-foreground whitespace-pre-wrap">{sajuResult.talent.details}</p>
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle>전생의 모습</CardTitle>
            </CardHeader>
            <CardContent>
              <p className="text-muted-foreground">{sajuResult.pastLife.summary}</p>
              <p className="mt-4 text-sm text-muted-foreground whitespace-pre-wrap">{sajuResult.pastLife.details}</p>
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle>사주 키워드 분석</CardTitle>
            </CardHeader>
            <CardContent className="h-[300px]">
              <ResponsiveContainer width="100%" height="100%">
                <RadarChart cx="50%" cy="50%" outerRadius="80%" data={chartData}>
                  <PolarGrid />
                  <PolarAngleAxis dataKey="subject" />
                  <PolarRadiusAxis />
                  <Radar name="Value" dataKey="A" stroke="#8884d8" fill="#8884d8" fillOpacity={0.6} />
                </RadarChart>
              </ResponsiveContainer>
            </CardContent>
          </Card>
        </div>
      </div>
    </>
  );
}

