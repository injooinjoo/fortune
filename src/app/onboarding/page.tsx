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
import { auth, userProfileService, guestProfileService } from "@/lib/supabase";

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
      const { data } = await auth.getSession();
      if (data?.session?.user) {
        setCurrentUser(data.session.user);
        // 사용자 이름을 폼에 미리 채우기
        const userName = data.session.user.user_metadata?.full_name || 
                        data.session.user.user_metadata?.name || 
                        data.session.user.email?.split('@')[0] || '';
        form.setValue('name', userName);
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
      
      const profileData = {
        name: values.name,
        birth_date: isoDate,
        birth_time: values.birthTimePeriod || undefined,
        mbti: values.mbti || undefined,
        gender: (values.gender as 'male' | 'female' | 'other') || undefined,
        onboarding_completed: true
      };

      if (currentUser) {
        // 로그인된 사용자의 경우 user_profiles 테이블에 저장
        await userProfileService.upsertProfile({
          id: currentUser.id,
          email: currentUser.email,
          ...profileData
        });
        
        console.log('사용자 프로필 저장 완료');
      } else {
        // 로그인하지 않은 사용자의 경우 로컬 스토리지에만 저장
        console.log('비로그인 사용자 - 로컬 스토리지에만 저장');
      }
      
      // 로컬 스토리지에도 백업 저장 (호환성)
      localStorage.setItem("userProfile", JSON.stringify({
        ...values,
        birthdate: isoDate
      }));
      
      router.push("/dashboard");
    } catch (error) {
      console.error('프로필 저장 실패:', error);
      // 오류가 발생해도 로컬 스토리지에 저장하고 진행
      const isoDate = koreanToIsoDate(values.birthYear, values.birthMonth, values.birthDay);
      localStorage.setItem("userProfile", JSON.stringify({
        ...values,
        birthdate: isoDate
      }));
      router.push("/dashboard");
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-purple-50 to-pink-50 flex items-center justify-center p-4">
      <div className="w-full max-w-md bg-white rounded-lg shadow-lg p-6">
        <div className="mb-6">
          <Progress value={(step / 3) * 100} className="w-full" />
          <p className="text-sm text-gray-600 mt-2 text-center">
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
                    <FormLabel>이름</FormLabel>
                    <FormControl>
                      <Input placeholder="홍길동" {...field} />
                    </FormControl>
                    <p className="text-xs text-muted-foreground">정확한 사주 분석을 위해 필요해요.</p>
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
                    <FormLabel>생년</FormLabel>
                    <Select onValueChange={field.onChange} value={field.value}>
                      <FormControl>
                        <SelectTrigger>
                          <SelectValue placeholder="년도 선택" />
                        </SelectTrigger>
                      </FormControl>
                      <SelectContent>
                        {yearOptions.map((year) => (
                          <SelectItem key={year} value={year.toString()}>
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
                    <FormLabel>생월</FormLabel>
                    <Select onValueChange={field.onChange} value={field.value}>
                      <FormControl>
                        <SelectTrigger>
                          <SelectValue placeholder="월 선택" />
                        </SelectTrigger>
                      </FormControl>
                      <SelectContent>
                        {monthOptions.map((month) => (
                          <SelectItem key={month} value={month.toString()}>
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
                    <FormLabel>생일</FormLabel>
                    <Select onValueChange={field.onChange} value={field.value}>
                      <FormControl>
                        <SelectTrigger>
                          <SelectValue placeholder="일 선택" />
                        </SelectTrigger>
                      </FormControl>
                      <SelectContent>
                        {dayOptions.map((day) => (
                          <SelectItem key={day} value={day.toString()}>
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
                    <FormLabel>태어난 시진 (선택사항)</FormLabel>
                    <Select onValueChange={field.onChange} value={field.value}>
                      <FormControl>
                        <SelectTrigger>
                          <SelectValue placeholder="시진 선택" />
                        </SelectTrigger>
                      </FormControl>
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
                    <p className="text-xs text-muted-foreground">더 정확한 사주 분석을 위해 필요해요.</p>
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
                    <FormLabel>MBTI (선택사항)</FormLabel>
                    <Select onValueChange={field.onChange} value={field.value}>
                      <FormControl>
                        <SelectTrigger>
                          <SelectValue placeholder="MBTI 선택" />
                        </SelectTrigger>
                      </FormControl>
                      <SelectContent>
                        {MBTI_TYPES.map((type) => (
                          <SelectItem key={type} value={type}>
                            {type}
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                    <p className="text-xs text-muted-foreground">성격 기반 운세 분석에 활용됩니다.</p>
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
                    <FormLabel>성별 (선택사항)</FormLabel>
                    <FormControl>
                      <RadioGroup
                        onValueChange={field.onChange}
                        value={field.value}
                        className="flex flex-col space-y-2"
                      >
                        <div className="flex items-center space-x-2">
                          <RadioGroupItem value="male" id="male" />
                          <Label htmlFor="male">남성</Label>
                        </div>
                        <div className="flex items-center space-x-2">
                          <RadioGroupItem value="female" id="female" />
                          <Label htmlFor="female">여성</Label>
                        </div>
                      </RadioGroup>
                    </FormControl>
                    <p className="text-xs text-muted-foreground">성별별 운세 분석에 활용됩니다.</p>
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

