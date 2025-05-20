
"use client";

import React, { useState, useTransition, useEffect, useMemo } from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
// import { format } from 'date-fns'; // No longer needed for displaying date in button
// import { ko } from 'date-fns/locale'; // No longer needed
import { Sparkles, Wand2, Loader2, AlertTriangle, Lightbulb, Users, Star, Heart, Briefcase, Coins, RotateCcw } from 'lucide-react'; // CalendarIcon removed

import { FortuneFormSchema, type FortuneFormValues } from '@/lib/schemas';
import { FORTUNE_TYPES, type FortuneType } from '@/lib/fortune-data';
import { getFortuneAction, type ActionResult } from './actions';
import type { GenerateFortuneInsightsOutput } from "@/ai/flows/generate-fortune-insights";

import { Button } from '@/components/ui/button';
// Calendar component and Sheet components are no longer needed for date picking
// import { Calendar } from '@/components/ui/calendar';
// import { Sheet, SheetContent, SheetTrigger, SheetHeader, SheetTitle, SheetDescription } from '@/components/ui/sheet';
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from '@/components/ui/card';
import { Checkbox } from '@/components/ui/checkbox';
import { Form, FormControl, FormDescription, FormField, FormItem, FormLabel, FormMessage } from '@/components/ui/form';
import { Input } from '@/components/ui/input';
import { Accordion, AccordionContent, AccordionItem, AccordionTrigger } from '@/components/ui/accordion';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { useToast } from '@/hooks/use-toast';
import { cn } from '@/lib/utils';


const fortuneIconMapping: Record<FortuneType, React.ElementType> = {
  "사주팔자": Wand2,
  "MBTI 운세": Users,
  "띠운세": Sparkles,
  "별자리운세": Star,
  "연애운": Heart,
  "결혼운": Heart,
  "취업운": Briefcase,
  "오늘의 총운": Lightbulb,
  "금전운": Coins,
};


export default function FortunePage() {
  const [isPending, startTransition] = useTransition();
  const [fortuneResult, setFortuneResult] = useState<GenerateFortuneInsightsOutput | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [lastSubmittedData, setLastSubmittedData] = useState<FortuneFormValues | null>(null);
  
  const [clientReady, setClientReady] = useState(false);
  const [currentYear, setCurrentYear] = useState<number>(2024); 
  const [minCalendarDate, setMinCalendarDate] = useState<Date>(new Date("1900-01-01"));
  // maxCalendarDate is no longer directly used by selects, currentYear is used for year range.

  // States for individual year, month, day selects
  const [selectedYear, setSelectedYear] = useState<number | undefined>();
  const [selectedMonth, setSelectedMonth] = useState<number | undefined>(); // 1-indexed
  const [selectedDay, setSelectedDay] = useState<number | undefined>();


  useEffect(() => {
    setClientReady(true);
    const now = new Date();
    setCurrentYear(now.getFullYear());
    setMinCalendarDate(new Date("1900-01-01"));
    // setMaxCalendarDate(now); // Not directly used by selects anymore
  }, []);

  const { toast } = useToast();

  const form = useForm<FortuneFormValues>({
    resolver: zodResolver(FortuneFormSchema),
    defaultValues: {
      birthdate: undefined,
      mbti: '',
      fortuneTypes: [],
    },
  });

  // Effect to sync individual select states from form's birthdate value
  const birthdateFromForm = form.watch('birthdate');
  useEffect(() => {
    if (birthdateFromForm instanceof Date) {
      if (birthdateFromForm.getFullYear() !== selectedYear ||
          birthdateFromForm.getMonth() + 1 !== selectedMonth ||
          birthdateFromForm.getDate() !== selectedDay) {
        setSelectedYear(birthdateFromForm.getFullYear());
        setSelectedMonth(birthdateFromForm.getMonth() + 1);
        setSelectedDay(birthdateFromForm.getDate());
      }
    } else if (birthdateFromForm === undefined) {
      if (selectedYear !== undefined || selectedMonth !== undefined || selectedDay !== undefined) {
        setSelectedYear(undefined);
        setSelectedMonth(undefined);
        setSelectedDay(undefined);
      }
    }
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [birthdateFromForm]); // Dependencies carefully chosen to avoid loops with the next effect


  // Effect to update form's birthdate from individual select states
  useEffect(() => {
    if (selectedYear !== undefined && selectedMonth !== undefined && selectedDay !== undefined) {
      const daysInMonthValue = new Date(selectedYear, selectedMonth, 0).getDate();
      const dayToUse = Math.min(selectedDay, daysInMonthValue);

      // If the selected day was invalid for the month and got clamped, update the selectedDay state.
      // This will re-trigger this effect with the corrected day.
      if (dayToUse !== selectedDay) {
        setSelectedDay(dayToUse);
        return; 
      }
      
      const newDate = new Date(selectedYear, selectedMonth - 1, dayToUse);
      const currentFormDate = form.getValues("birthdate");

      if (!currentFormDate || currentFormDate.getTime() !== newDate.getTime()) {
        form.setValue("birthdate", newDate, { shouldValidate: true, shouldDirty: true });
      }
    } else {
      // If any part of year/month/day is not selected, set birthdate in form to undefined
      const currentFormDate = form.getValues("birthdate");
      if (currentFormDate !== undefined) {
        form.setValue("birthdate", undefined, { shouldValidate: true, shouldDirty: true });
      }
    }
  }, [selectedYear, selectedMonth, selectedDay, form]);

  const years = useMemo(() => {
    if (!clientReady) return [];
    return Array.from({ length: currentYear - minCalendarDate.getFullYear() + 1 }, (_, i) => minCalendarDate.getFullYear() + i).reverse();
  }, [clientReady, currentYear, minCalendarDate]);

  const months = useMemo(() => {
    if (!clientReady) return [];
    return Array.from({ length: 12 }, (_, i) => i + 1);
  }, [clientReady]);

  const days = useMemo(() => {
    if (!clientReady || !selectedYear || !selectedMonth) return [];
    return Array.from({ length: new Date(selectedYear, selectedMonth, 0).getDate() }, (_, i) => i + 1);
  }, [clientReady, selectedYear, selectedMonth]);


  const onSubmit = (values: FortuneFormValues) => {
    setError(null);
    setFortuneResult(null);
    setLastSubmittedData(values);

    startTransition(async () => {
      const result: ActionResult = await getFortuneAction(values);
      if (result.error) {
        setError(result.error);
        toast({
          title: "오류 발생",
          description: result.error,
          variant: "destructive",
        });
      } else if (result.data) {
        setFortuneResult(result.data);
        toast({
          title: "운세 도착!",
          description: "당신의 맞춤 운세를 확인해보세요.",
        });
      }
    });
  };
  
  const handleRetry = () => {
    if (lastSubmittedData) {
      onSubmit(lastSubmittedData);
    }
  };

  const DailyFortuneSnippet = () => {
    if (!fortuneResult || !fortuneResult.insights) return null;
    
    const todayFortuneType: FortuneType = "오늘의 총운";
    const dailyInsight = fortuneResult.insights[todayFortuneType] || 
                         Object.values(fortuneResult.insights)[0]; 

    if (!dailyInsight) return null;

    const IconComponent = fortuneIconMapping[todayFortuneType] || Lightbulb;

    return (
      <Card className="mb-8 shadow-lg border-accent">
        <CardHeader>
          <CardTitle className="flex items-center text-accent">
            <IconComponent className="mr-2 h-6 w-6" />
            오늘의 운세 하이라이트
          </CardTitle>
          <CardDescription>오늘 당신을 위한 특별한 메시지입니다.</CardDescription>
        </CardHeader>
        <CardContent>
          <p className="text-lg leading-relaxed">{dailyInsight}</p>
        </CardContent>
      </Card>
    );
  };


  return (
    <div className="min-h-screen flex flex-col items-center justify-center p-4 md:p-8 bg-background">
      <header className="mb-10 text-center">
        <div className="flex items-center justify-center mb-2">
           <Sparkles className="h-16 w-16 text-primary" />
          <h1 className="ml-3 text-5xl font-bold tracking-tight text-primary">
            운세 탐험
          </h1>
        </div>
        <p className="text-xl text-muted-foreground">
          당신의 운명을 탐험하고 새로운 가능성을 발견하세요.
        </p>
      </header>

      <main className="w-full max-w-2xl">
        <Card className="shadow-2xl">
          <CardHeader>
            <CardTitle className="text-2xl">나의 운세 정보 입력</CardTitle>
            <CardDescription>생년월일, MBTI, 그리고 원하는 운세 종류를 선택해주세요.</CardDescription>
          </CardHeader>
          <CardContent>
            <Form {...form}>
              <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-8">
                <FormField
                  control={form.control}
                  name="birthdate"
                  render={({ field }) => ( // field is still useful for error state etc.
                    <FormItem className="flex flex-col">
                      <FormLabel>생년월일</FormLabel>
                      <div className="flex space-x-2">
                        <Select
                          value={selectedYear ? String(selectedYear) : undefined}
                          onValueChange={(value) => setSelectedYear(value ? parseInt(value) : undefined)}
                          disabled={!clientReady}
                        >
                          <SelectTrigger className="w-[120px]">
                            <SelectValue placeholder="연도" />
                          </SelectTrigger>
                          <SelectContent>
                            {years.map(year => (
                              <SelectItem key={year} value={String(year)}>{year}년</SelectItem>
                            ))}
                          </SelectContent>
                        </Select>
                        <Select
                          value={selectedMonth ? String(selectedMonth) : undefined}
                          onValueChange={(value) => setSelectedMonth(value ? parseInt(value) : undefined)}
                          disabled={!clientReady}
                        >
                          <SelectTrigger className="w-[100px]">
                            <SelectValue placeholder="월" />
                          </SelectTrigger>
                          <SelectContent>
                            {months.map(month => (
                              <SelectItem key={month} value={String(month)}>{month}월</SelectItem>
                            ))}
                          </SelectContent>
                        </Select>
                        <Select
                          value={selectedDay ? String(selectedDay) : undefined}
                          onValueChange={(value) => setSelectedDay(value ? parseInt(value) : undefined)}
                          disabled={!clientReady || !selectedYear || !selectedMonth}
                        >
                          <SelectTrigger className="w-[100px]">
                            <SelectValue placeholder="일" />
                          </SelectTrigger>
                          <SelectContent>
                            {days.map(day => (
                              <SelectItem key={day} value={String(day)}>{day}일</SelectItem>
                            ))}
                          </SelectContent>
                        </Select>
                      </div>
                      <FormMessage />
                    </FormItem>
                  )}
                />

                <FormField
                  control={form.control}
                  name="mbti"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>MBTI</FormLabel>
                      <FormControl>
                        <Input type="text" placeholder="예: INFJ" {...field} />
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )}
                />

                <FormField
                  control={form.control}
                  name="fortuneTypes"
                  render={() => (
                    <FormItem>
                      <div className="mb-4">
                        <FormLabel className="text-base">운세 종류 선택</FormLabel>
                        <FormDescription>
                          알고 싶은 운세를 모두 선택하세요.
                        </FormDescription>
                      </div>
                      <div className="grid grid-cols-2 md:grid-cols-3 gap-4">
                        {FORTUNE_TYPES.map((item) => (
                          <FormField
                            key={item}
                            control={form.control}
                            name="fortuneTypes"
                            render={({ field }) => {
                              return (
                                <FormItem
                                  key={item}
                                  className="flex flex-row items-start space-x-3 space-y-0"
                                >
                                  <FormControl>
                                    <Checkbox
                                      checked={field.value?.includes(item)}
                                      onCheckedChange={(checked) => {
                                        return checked
                                          ? field.onChange([...(field.value || []), item])
                                          : field.onChange(
                                              (field.value || []).filter(
                                                (value) => value !== item
                                              )
                                            );
                                      }}
                                    />
                                  </FormControl>
                                  <FormLabel className="font-normal">
                                    {item}
                                  </FormLabel>
                                </FormItem>
                              );
                            }}
                          />
                        ))}
                      </div>
                      <FormMessage />
                    </FormItem>
                  )}
                />
                <Button type="submit" className="w-full" disabled={isPending}>
                  {isPending ? (
                    <>
                      <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                      운세 생성 중...
                    </>
                  ) : (
                    <>
                      <Sparkles className="mr-2 h-4 w-4" />
                      운세 보기
                    </>
                  )}
                </Button>
              </form>
            </Form>
          </CardContent>
        </Card>

        {isPending && (
          <div className="mt-8 text-center">
            <Loader2 className="mx-auto h-12 w-12 animate-spin text-primary" />
            <p className="mt-2 text-lg text-muted-foreground">잠시만 기다려주세요, 신비로운 기운을 모으고 있습니다...</p>
          </div>
        )}

        {error && !isPending && (
          <Card className="mt-8 border-destructive bg-destructive/10">
            <CardHeader>
              <CardTitle className="flex items-center text-destructive">
                <AlertTriangle className="mr-2 h-6 w-6" />
                오류가 발생했습니다
              </CardTitle>
            </CardHeader>
            <CardContent>
              <p>{error}</p>
            </CardContent>
            {lastSubmittedData && (
              <CardFooter>
                <Button variant="destructive" onClick={handleRetry} disabled={isPending}>
                  <RotateCcw className="mr-2 h-4 w-4" />
                  다시 시도
                </Button>
              </CardFooter>
            )}
          </Card>
        )}
        
        {fortuneResult && !isPending && (
          <div className="mt-10">
            <DailyFortuneSnippet />
            <h2 className="text-3xl font-semibold text-center mb-6 text-primary">
              당신의 맞춤 운세 결과
            </h2>
            <Accordion type="multiple" className="w-full space-y-4">
              {Object.entries(fortuneResult.insights).map(([type, insight]) => {
                const Icon = fortuneIconMapping[type as FortuneType] || Wand2;
                return (
                  <AccordionItem value={type} key={type} className="bg-card rounded-lg shadow-md border border-primary/20 overflow-hidden">
                    <AccordionTrigger className="px-6 py-4 text-lg hover:bg-primary/5 transition-colors">
                      <div className="flex items-center">
                        <Icon className="mr-3 h-6 w-6 text-primary" />
                        {type}
                      </div>
                    </AccordionTrigger>
                    <AccordionContent className="px-6 pb-6 pt-2 text-base leading-relaxed bg-background/50">
                      {insight.split('\\n').map((paragraph, index) => (
                        <p key={index} className="mb-2 last:mb-0">{paragraph}</p>
                      ))}
                    </AccordionContent>
                  </AccordionItem>
                );
              })}
            </Accordion>
          </div>
        )}
      </main>

      <footer className="mt-16 text-center text-sm text-muted-foreground">
        {clientReady ? (
          <p>&copy; {currentYear} 운세 탐험. 모든 운명은 당신의 선택에 달려있습니다.</p>
        ) : (
          <p>&copy; 운세 탐험. 모든 운명은 당신의 선택에 달려있습니다.</p> 
        )}
        <p className="mt-1">본 운세 내용은 재미를 위한 참고 자료로만 활용해주세요.</p>
      </footer>
    </div>
  );
}
