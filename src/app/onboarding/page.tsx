"use client";

import React, { useState, useEffect } from "react";
import { useRouter } from "next/navigation";
import { useForm } from "react-hook-form";
import { z } from "zod";
import { zodResolver } from "@hookform/resolvers/zod";
import {
  Form,
  FormField,
  FormItem,
  FormLabel,
  FormControl,
  FormMessage,
} from "@/components/ui/form";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { Progress } from "@/components/ui/progress";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { RadioGroup, RadioGroupItem } from "@/components/ui/radio-group";
import { Label } from "@/components/ui/label";
import { MBTI_TYPES } from "@/lib/fortune-data";
import { 
  getYearOptions, 
  getMonthOptions, 
  getDayOptions, 
  formatKoreanDate,
  koreanToIsoDate,
  TIME_PERIODS
} from "@/lib/utils";
import { saveUserProfile, getZodiacSign, getChineseZodiac } from "@/lib/user-storage";
import { type UserProfile } from "@/lib/supabase";

const formSchema = z.object({
  name: z.string().min(1, "이름을 입력해주세요."),
  birthYear: z.string().min(1, "년도를 선택해주세요."),
  birthMonth: z.string().min(1, "월을 선택해주세요."),
  birthDay: z.string().min(1, "일을 선택해주세요."),
  birthTimePeriod: z.string().optional(),
  mbti: z.string().optional(),
  gender: z.string().optional(),
});

type FormValues = z.infer<typeof formSchema>;

export default function OnboardingPage() {
  const [step, setStep] = useState(1);
  const [currentUser, setCurrentUser] = useState<any>(null);
  const [isLoading, setIsLoading] = useState(false);
  const router = useRouter();
  
  const form = useForm<FormValues>({
    resolver: zodResolver(formSchema),
    defaultValues: {
      name: "",
      birthYear: "",
      birthMonth: "",
      birthDay: "",
      birthTimePeriod: "",
      mbti: "",
      gender: "",
    },
  });

  useEffect(() => {
    // 현재 사용자 정보 확인
    const checkUser = async () => {
      try {
        const { auth } = await import('@/lib/supabase');
        const { data } = await auth.getSession();
        if (data?.session?.user) {
          setCurrentUser(data.session.user);
          // 사용자 이름을 폼에 미리 채우기
          const userName = data.session.user.user_metadata?.full_name || 
                          data.session.user.user_metadata?.name || 
                          data.session.user.email?.split('@')[0] || '';
          form.setValue('name', userName);
        }
      } catch (error) {
        console.log('게스트 사용자로 진행');
      }
    };
    
    checkUser();
  }, [form]);

  const watchedValues = form.watch();
  const yearOptions = getYearOptions();
  const monthOptions = getMonthOptions();
  const dayOptions = getDayOptions(
    watchedValues.birthYear ? parseInt(watchedValues.birthYear) : undefined,
    watchedValues.birthMonth ? parseInt(watchedValues.birthMonth) : undefined
  );

  const handleNext = () => {
    if (step === 1) {
      // 첫 번째 단계에서는 필수 필드만 검증
      const { name, birthYear, birthMonth, birthDay } = form.getValues();
      if (!name || !birthYear || !birthMonth || !birthDay) {
        form.trigger(["name", "birthYear", "birthMonth", "birthDay"]);
        return;
      }
    }
    setStep(step + 1);
  };

  const handleSubmit = async (values: FormValues) => {
    setIsLoading(true);
    
    try {
      // 한국식 날짜를 ISO 형식으로 변환
      const isoDate = koreanToIsoDate(values.birthYear, values.birthMonth, values.birthDay);
      
      // 프로필 데이터 준비
      const profileData: UserProfile = {
        id: currentUser?.id || '',
        name: values.name,
        email: currentUser?.email || '',
        birth_date: isoDate,
        birth_time: values.birthTimePeriod || '',
        birth_hour: '',
        mbti: values.mbti || '',
        gender: (values.gender as 'male' | 'female' | 'other') || 'other',
        zodiac_sign: getZodiacSign(isoDate),
        chinese_zodiac: getChineseZodiac(isoDate),
        onboarding_completed: true,
        subscription_status: 'free',
        fortune_count: 0,
        premium_fortunes_count: 0,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      };

      // user-storage.ts를 통해 저장
      saveUserProfile(profileData);

      // 인증된 사용자의 경우 Supabase에도 저장 시도
      if (currentUser) {
        try {
          const { userProfileService } = await import('@/lib/supabase');
          await userProfileService.upsertProfile({
            id: currentUser.id,
            email: currentUser.email,
            name: values.name,
            birth_date: isoDate,
            birth_time: values.birthTimePeriod || undefined,
            mbti: values.mbti || undefined,
            gender: (values.gender as 'male' | 'female' | 'other') || undefined,
            onboarding_completed: true
          });
          console.log('🔄 Supabase에 프로필 동기화 완료');
        } catch (supabaseError) {
          console.error('Supabase 동기화 실패:', supabaseError);
          // Supabase 실패해도 로컬 저장은 성공했으므로 계속 진행
        }
      }
      
      router.push("/home");
    } catch (error) {
      console.error('프로필 저장 실패:', error);
      alert('프로필 저장 중 오류가 발생했습니다. 다시 시도해주세요.');
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-purple-50 to-pink-50 dark:from-gray-900 dark:to-gray-800 flex items-center justify-center p-4">
      <div className="w-full max-w-md bg-white dark:bg-gray-800 rounded-lg shadow-lg p-6 border border-gray-200 dark:border-gray-600">
        <div className="mb-6">
          <Progress value={(step / 3) * 100} className="w-full" />
          <p className="text-sm text-gray-600 dark:text-gray-400 mt-2 text-center">
            {step} / 3 단계
          </p>
        </div>

        <Form {...form}>
          {step === 1 && (
            <form className="space-y-4" onSubmit={(e) => { e.preventDefault(); handleNext(); }}>
              <FormField
                control={form.control}
                name="name"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel className="text-gray-700 dark:text-gray-300">이름</FormLabel>
                    <FormControl>
                      <Input 
                        placeholder="홍길동" 
                        {...field} 
                        className="bg-white dark:bg-gray-700 border-gray-300 dark:border-gray-600 text-gray-900 dark:text-gray-100"
                      />
                    </FormControl>
                    <p className="text-xs text-gray-500 dark:text-gray-400">정확한 사주 분석을 위해 필요해요.</p>
                    <FormMessage />
                  </FormItem>
                )}
              />
              
              {/* 년도 선택 */}
              <FormField
                control={form.control}
                name="birthYear"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel className="text-gray-700 dark:text-gray-300">생년</FormLabel>
                    <Select onValueChange={field.onChange} value={field.value}>
                      <FormControl>
                        <SelectTrigger className="bg-white dark:bg-gray-700 border-gray-300 dark:border-gray-600 text-gray-900 dark:text-gray-100">
                          <SelectValue placeholder="년도 선택" />
                        </SelectTrigger>
                      </FormControl>
                      <SelectContent className="bg-white dark:bg-gray-800 border-gray-200 dark:border-gray-600">
                        {yearOptions.map((year) => (
                          <SelectItem 
                            key={year} 
                            value={year.toString()}
                            className="text-gray-900 dark:text-gray-100 hover:bg-gray-100 dark:hover:bg-gray-700"
                          >
                            {year}년
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                    <FormMessage />
                  </FormItem>
                )}
              />

              {/* 월 선택 */}
              <FormField
                control={form.control}
                name="birthMonth"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel className="text-gray-700 dark:text-gray-300">생월</FormLabel>
                    <Select onValueChange={field.onChange} value={field.value}>
                      <FormControl>
                        <SelectTrigger className="bg-white dark:bg-gray-700 border-gray-300 dark:border-gray-600 text-gray-900 dark:text-gray-100">
                          <SelectValue placeholder="월 선택" />
                        </SelectTrigger>
                      </FormControl>
                      <SelectContent className="bg-white dark:bg-gray-800 border-gray-200 dark:border-gray-600">
                        {monthOptions.map((month) => (
                          <SelectItem 
                            key={month} 
                            value={month.toString()}
                            className="text-gray-900 dark:text-gray-100 hover:bg-gray-100 dark:hover:bg-gray-700"
                          >
                            {month}월
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                    <FormMessage />
                  </FormItem>
                )}
              />

              {/* 일 선택 */}
              <FormField
                control={form.control}
                name="birthDay"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel className="text-gray-700 dark:text-gray-300">생일</FormLabel>
                    <Select onValueChange={field.onChange} value={field.value}>
                      <FormControl>
                        <SelectTrigger className="bg-white dark:bg-gray-700 border-gray-300 dark:border-gray-600 text-gray-900 dark:text-gray-100">
                          <SelectValue placeholder="일 선택" />
                        </SelectTrigger>
                      </FormControl>
                      <SelectContent className="bg-white dark:bg-gray-800 border-gray-200 dark:border-gray-600">
                        {dayOptions.map((day) => (
                          <SelectItem 
                            key={day} 
                            value={day.toString()}
                            className="text-gray-900 dark:text-gray-100 hover:bg-gray-100 dark:hover:bg-gray-700"
                          >
                            {day}일
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                    <FormMessage />
                  </FormItem>
                )}
              />

              {/* 시진 선택 (선택사항) */}
              <FormField
                control={form.control}
                name="birthTimePeriod"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel className="text-gray-700 dark:text-gray-300">태어난 시진 (선택사항)</FormLabel>
                    <Select onValueChange={field.onChange} value={field.value}>
                      <FormControl>
                        <SelectTrigger className="bg-white dark:bg-gray-700 border-gray-300 dark:border-gray-600 text-gray-900 dark:text-gray-100">
                          <SelectValue placeholder="시진 선택" />
                        </SelectTrigger>
                      </FormControl>
                      <SelectContent className="bg-white dark:bg-gray-800 border-gray-200 dark:border-gray-600">
                        {TIME_PERIODS.map((period) => (
                          <SelectItem 
                            key={period.value} 
                            value={period.value}
                            className="text-gray-900 dark:text-gray-100 hover:bg-gray-100 dark:hover:bg-gray-700"
                          >
                            <div className="flex flex-col">
                              <span className="font-medium">{period.label}</span>
                              <span className="text-xs text-gray-500 dark:text-gray-400">{period.description}</span>
                            </div>
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                    <p className="text-xs text-gray-500 dark:text-gray-400">더 정확한 사주 분석을 위해 필요해요.</p>
                    <FormMessage />
                  </FormItem>
                )}
              />

              {/* 선택된 생년월일 표시 */}
              {watchedValues.birthYear && watchedValues.birthMonth && watchedValues.birthDay && (
                <div className="p-3 bg-purple-50 rounded-lg border border-purple-200">
                  <p className="text-sm font-medium text-purple-800 text-center">
                    {formatKoreanDate(watchedValues.birthYear, watchedValues.birthMonth, watchedValues.birthDay)}
                  </p>
                  {watchedValues.birthTimePeriod && (
                    <p className="text-xs text-purple-600 text-center mt-1">
                      {TIME_PERIODS.find(p => p.value === watchedValues.birthTimePeriod)?.label}
                    </p>
                  )}
                </div>
              )}

              <Button type="submit" className="w-full">다음</Button>
            </form>
          )}

          {step === 2 && (
            <form className="space-y-4" onSubmit={(e) => { e.preventDefault(); handleNext(); }}>
              <FormField
                control={form.control}
                name="mbti"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel className="text-gray-700 dark:text-gray-300">MBTI (선택사항)</FormLabel>
                    <Select onValueChange={field.onChange} value={field.value}>
                      <FormControl>
                        <SelectTrigger className="bg-white dark:bg-gray-700 border-gray-300 dark:border-gray-600 text-gray-900 dark:text-gray-100">
                          <SelectValue placeholder="MBTI 선택" />
                        </SelectTrigger>
                      </FormControl>
                      <SelectContent className="bg-white dark:bg-gray-800 border-gray-200 dark:border-gray-600">
                        {MBTI_TYPES.map((type) => (
                          <SelectItem 
                            key={type} 
                            value={type}
                            className="text-gray-900 dark:text-gray-100 hover:bg-gray-100 dark:hover:bg-gray-700"
                          >
                            {type}
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                    <p className="text-xs text-gray-500 dark:text-gray-400">성격 기반 운세 분석에 활용됩니다.</p>
                    <FormMessage />
                  </FormItem>
                )}
              />
              <Button type="submit" className="w-full">다음</Button>
            </form>
          )}

          {step === 3 && (
            <form onSubmit={form.handleSubmit(handleSubmit)} className="space-y-4">
              <FormField
                control={form.control}
                name="gender"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel className="text-gray-700 dark:text-gray-300">성별 (선택사항)</FormLabel>
                    <FormControl>
                      <RadioGroup
                        onValueChange={field.onChange}
                        value={field.value}
                        className="flex flex-col space-y-2"
                      >
                        <div className="flex items-center space-x-2">
                          <RadioGroupItem value="male" id="male" />
                          <Label htmlFor="male" className="text-gray-700 dark:text-gray-300">남성</Label>
                        </div>
                        <div className="flex items-center space-x-2">
                          <RadioGroupItem value="female" id="female" />
                          <Label htmlFor="female" className="text-gray-700 dark:text-gray-300">여성</Label>
                        </div>
                      </RadioGroup>
                    </FormControl>
                    <p className="text-xs text-gray-500 dark:text-gray-400">성별별 운세 분석에 활용됩니다.</p>
                    <FormMessage />
                  </FormItem>
                )}
              />
              <Button type="submit" className="w-full" disabled={isLoading}>
                {isLoading ? "저장 중..." : "완료"}
              </Button>
            </form>
          )}
        </Form>
      </div>
    </div>
  );
}

