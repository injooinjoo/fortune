
"use client";

import React, { useState, useTransition, useEffect, useMemo } from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { Sparkles, Wand2, Loader2, AlertTriangle, Lightbulb, Users, Star, Heart, Briefcase, Coins, RotateCcw, ChevronDown, User, Clock } from 'lucide-react';

import { FortuneFormSchema, type FortuneFormValues } from '@/lib/schemas';
import { FORTUNE_TYPES, MBTI_TYPES, type FortuneType, GENDERS, BIRTH_TIMES } from '@/lib/fortune-data'; 
import { getFortuneAction, type ActionResult } from './actions';
import type { GenerateFortuneInsightsOutput } from "@/ai/flows/generate-fortune-insights";

import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from '@/components/ui/card';
import { Form, FormControl, FormDescription, FormField, FormItem, FormLabel, FormMessage } from '@/components/ui/form';
import { Accordion, AccordionContent, AccordionItem, AccordionTrigger } from '@/components/ui/accordion';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Sheet, SheetContent, SheetHeader, SheetTitle, SheetTrigger, SheetClose } from '@/components/ui/sheet';
import { Input } from '@/components/ui/input';
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

type MbtiPart = 'ei' | 'sn' | 'tf' | 'jp';
type MbtiLetter<T extends MbtiPart> = 
  T extends 'ei' ? 'E' | 'I' :
  T extends 'sn' ? 'S' | 'N' :
  T extends 'tf' ? 'T' | 'F' :
  'J' | 'P';

interface MbtiPartsState {
  ei: MbtiLetter<'ei'> | null;
  sn: MbtiLetter<'sn'> | null;
  tf: MbtiLetter<'tf'> | null;
  jp: MbtiLetter<'jp'> | null;
}

const mbtiDimensionDetails = {
  ei: {
    label: "에너지 방향",
    options: [
      { value: 'E', name: "외향", description: "외부 세계와 활동" },
      { value: 'I', name: "내향", description: "내면 세계와 성찰" },
    ],
  },
  sn: {
    label: "인식 방식",
    options: [
      { value: 'S', name: "감각형", description: "오감과 실제 경험" },
      { value: 'N', name: "직관형", description: "통찰과 가능성" },
    ],
  },
  tf: {
    label: "판단 기준",
    options: [
      { value: 'T', name: "사고형", description: "논리와 분석" },
      { value: 'F', name: "감정형", description: "관계와 조화" },
    ],
  },
  jp: {
    label: "생활 양식",
    options: [
      { value: 'J', name: "판단형", description: "체계적이고 계획적" },
      { value: 'P', name: "인식형", description: "자율적이고 융통성" },
    ],
  },
} as const;


export default function FortunePage() {
  const [isPending, startTransition] = useTransition();
  const [fortuneResult, setFortuneResult] = useState<GenerateFortuneInsightsOutput | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [lastSubmittedData, setLastSubmittedData] = useState<FortuneFormValues | null>(null);
  
  const [clientReady, setClientReady] = useState(false);
  const [currentYear, setCurrentYear] = useState<number | null>(null);
  const [minCalendarDate, setMinCalendarDate] = useState<Date | null>(null);
  const [maxCalendarDate, setMaxCalendarDate] = useState<Date | null>(null);
  
  const [isMbtiSheetOpen, setIsMbtiSheetOpen] = useState(false);
  const [mbtiParts, setMbtiParts] = useState<MbtiPartsState>({ ei: null, sn: null, tf: null, jp: null });

  const [selectedYear, setSelectedYear] = useState<number | undefined>();
  const [selectedMonth, setSelectedMonth] = useState<number | undefined>();
  const [selectedDay, setSelectedDay] = useState<number | undefined>();

  useEffect(() => {
    setClientReady(true);
    const now = new Date();
    setCurrentYear(now.getFullYear());
    setMinCalendarDate(new Date(now.getFullYear() - 100, 0, 1)); // 100 years ago
    setMaxCalendarDate(now);
  }, []);

  const { toast } = useToast();

  const form = useForm<FortuneFormValues>({
    resolver: zodResolver(FortuneFormSchema),
    defaultValues: {
      birthdate: undefined,
      mbti: '',
      gender: GENDERS[2].value, 
      birthTime: BIRTH_TIMES[0].value, 
      fortuneTypes: [],
    },
  });

  const watchedBirthdate = form.watch('birthdate');

  useEffect(() => {
    if (!clientReady) return;

    if (watchedBirthdate) {
      const formYear = watchedBirthdate.getFullYear();
      const formMonth = watchedBirthdate.getMonth() + 1;
      const formDay = watchedBirthdate.getDate();

      if (selectedYear !== formYear) setSelectedYear(formYear);
      if (selectedMonth !== formMonth) setSelectedMonth(formMonth);
      if (selectedDay !== formDay) setSelectedDay(formDay);
    } else {
      if (selectedYear !== undefined) setSelectedYear(undefined);
      if (selectedMonth !== undefined) setSelectedMonth(undefined);
      if (selectedDay !== undefined) setSelectedDay(undefined);
    }
  }, [watchedBirthdate, clientReady]); 

  useEffect(() => {
    if (!clientReady) return;

    if (selectedYear && selectedMonth && selectedDay) {
      const newDate = new Date(selectedYear, selectedMonth - 1, selectedDay);
      if (
        newDate.getFullYear() === selectedYear &&
        newDate.getMonth() === selectedMonth - 1 &&
        newDate.getDate() === selectedDay
      ) {
        if (!watchedBirthdate || newDate.getTime() !== watchedBirthdate.getTime()) {
          form.setValue('birthdate', newDate, { shouldValidate: true, shouldDirty: true });
        }
      } else {
        if (watchedBirthdate) {
         form.setValue('birthdate', undefined, { shouldValidate: true, shouldDirty: true });
        }
      }
    } else {
      if (watchedBirthdate) {
        form.setValue('birthdate', undefined, { shouldValidate: true, shouldDirty: true });
      }
    }
  }, [selectedYear, selectedMonth, selectedDay, clientReady, form, watchedBirthdate]);


  const yearOptions = useMemo(() => {
    if (!minCalendarDate || !maxCalendarDate) return [];
    const startYear = minCalendarDate.getFullYear();
    const endYear = maxCalendarDate.getFullYear();
    return Array.from({ length: endYear - startYear + 1 }, (_, i) => endYear - i);
  }, [minCalendarDate, maxCalendarDate]);

  const monthOptions = useMemo(() => {
    return Array.from({ length: 12 }, (_, i) => i + 1);
  }, []);

  const dayOptions = useMemo(() => {
    if (!selectedYear || !selectedMonth) return [];
    const daysInSelectedMonth = new Date(selectedYear, selectedMonth, 0).getDate();
    return Array.from({ length: daysInSelectedMonth }, (_, i) => i + 1);
  }, [selectedYear, selectedMonth]);


  useEffect(() => {
    if (isMbtiSheetOpen) {
      const currentMbti = form.getValues('mbti');
      if (currentMbti && currentMbti.length === 4) {
        setMbtiParts({
          ei: currentMbti[0] as MbtiLetter<'ei'>,
          sn: currentMbti[1] as MbtiLetter<'sn'>,
          tf: currentMbti[2] as MbtiLetter<'tf'>,
          jp: currentMbti[3] as MbtiLetter<'jp'>,
        });
      } else {
        setMbtiParts({ ei: null, sn: null, tf: null, jp: null });
      }
    }
  }, [isMbtiSheetOpen, form]);

  useEffect(() => {
    if (isMbtiSheetOpen) { 
      const { ei, sn, tf, jp } = mbtiParts;
      if (ei && sn && tf && jp) {
        const fullMbti = `${ei}${sn}${tf}${jp}`;
        if (form.getValues('mbti') !== fullMbti) {
          form.setValue('mbti', fullMbti, { shouldValidate: true, shouldDirty: true });
        }
      }
    }
  }, [mbtiParts, form, isMbtiSheetOpen]);


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

  const handleMbtiPartSelect = (part: MbtiPart, value: MbtiLetter<typeof part>) => {
    setMbtiParts(prev => ({ ...prev, [part]: value }));
  };
  
  const mbtiValueFromForm = form.watch('mbti');

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
    <div className="min-h-screen flex flex-col items-center justify-center p-4 md:p-8 bg-background text-foreground">
      <header className="mb-10 text-center">
        <h1 className="text-5xl font-bold tracking-tight text-primary">
          운세 탐험
        </h1>
        <p className="text-xl text-muted-foreground">
          당신의 운명을 탐험하고 새로운 가능성을 발견하세요.
        </p>
      </header>

      <main className="w-full max-w-2xl">
        <Card className="shadow-2xl">
          <CardHeader>
            <CardTitle className="text-2xl">나의 운세 정보 입력</CardTitle>
            <CardDescription>생년월일, MBTI, 성별, 태어난 시 그리고 원하는 운세 종류를 선택해주세요.</CardDescription>
          </CardHeader>
          <CardContent>
            <Form {...form}>
              <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-8">
                <FormField
                  control={form.control}
                  name="birthdate"
                  render={() => ( 
                    <FormItem className="flex flex-col">
                      <FormLabel>생년월일</FormLabel>
                      <div className="grid grid-cols-3 gap-2">
                        <Select
                          value={selectedYear?.toString() || ""}
                          onValueChange={(value) => {
                            const year = parseInt(value);
                            setSelectedYear(year);
                            if (selectedMonth && selectedDay && new Date(year, selectedMonth -1, selectedDay).getMonth() !== selectedMonth -1) {
                                setSelectedDay(undefined);
                            }
                          }}
                          disabled={!clientReady}
                        >
                          <SelectTrigger><SelectValue placeholder="년" /></SelectTrigger>
                          <SelectContent>
                            {yearOptions.map((year) => (
                              <SelectItem key={year} value={year.toString()}>
                                {year}년
                              </SelectItem>
                            ))}
                          </SelectContent>
                        </Select>
                         <Select
                          value={selectedMonth?.toString() || ""}
                          onValueChange={(value) => {
                            const month = parseInt(value);
                            setSelectedMonth(month);
                             if (selectedYear && selectedDay && new Date(selectedYear, month - 1, selectedDay).getMonth() !== month -1) {
                                setSelectedDay(undefined);
                            }
                          }}
                          disabled={!clientReady || !selectedYear}
                        >
                          <SelectTrigger><SelectValue placeholder="월" /></SelectTrigger>
                          <SelectContent>
                            {monthOptions.map((month) => (
                              <SelectItem key={month} value={month.toString()}>
                                {month}월
                              </SelectItem>
                            ))}
                          </SelectContent>
                        </Select>
                        <Select
                          value={selectedDay?.toString() || ""}
                          onValueChange={(value) => setSelectedDay(parseInt(value))}
                          disabled={!clientReady || !selectedYear || !selectedMonth}
                        >
                          <SelectTrigger><SelectValue placeholder="일" /></SelectTrigger>
                          <SelectContent>
                            {dayOptions.map((day) => (
                              <SelectItem key={day} value={day.toString()}>
                                {day}일
                              </SelectItem>
                            ))}
                            {dayOptions.length === 0 && selectedYear && selectedMonth && (
                               <SelectItem value="-" disabled>날짜 없음</SelectItem>
                            )}
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
                    <FormItem className="flex flex-col">
                      <FormLabel>MBTI</FormLabel>
                      <Sheet open={isMbtiSheetOpen} onOpenChange={setIsMbtiSheetOpen}>
                        <SheetTrigger asChild>
                           <Button variant="outline" className="w-full justify-between">
                            {mbtiValueFromForm || "MBTI 선택"}
                            <ChevronDown className="h-4 w-4 opacity-50" />
                          </Button>
                        </SheetTrigger>
                        <SheetContent side="bottom" className="h-[70vh] flex flex-col p-0">
                          <SheetHeader className="p-4 border-b">
                            <SheetTitle>MBTI 유형 선택</SheetTitle>
                          </SheetHeader>
                          <div className="flex-grow overflow-y-auto p-4 space-y-4">
                            {(Object.keys(mbtiDimensionDetails) as MbtiPart[]).map((partKey) => {
                              const dimension = mbtiDimensionDetails[partKey];
                              return (
                                <div key={partKey}>
                                  <FormLabel className="text-sm font-medium text-foreground mb-1.5 block">
                                    {dimension.label}
                                  </FormLabel>
                                  <div className="grid grid-cols-2 gap-2">
                                    {dimension.options.map(option => (
                                      <Button
                                        key={option.value}
                                        variant={mbtiParts[partKey] === option.value ? "default" : "outline"}
                                        className="h-auto flex flex-col justify-center items-center p-2.5 text-center shadow-sm hover:shadow-md transition-shadow duration-150"
                                        onClick={() => handleMbtiPartSelect(partKey, option.value as MbtiLetter<typeof partKey>)}
                                        type="button"
                                      >
                                        <span className="text-xl font-bold">{option.value}</span>
                                        <span className="mt-0.5 text-xs font-semibold">{option.name}</span>
                                        <span className="mt-0.5 text-[10px] text-muted-foreground leading-tight">{option.description}</span>
                                      </Button>
                                    ))}
                                  </div>
                                </div>
                              );
                            })}
                          </div>
                           <SheetClose asChild>
                              <Button 
                                type="button" 
                                variant="ghost" 
                                className="mt-auto border-t rounded-none w-full py-3"
                                onClick={() => {
                                  const { ei, sn, tf, jp } = mbtiParts;
                                  if (ei && sn && tf && jp) {
                                    const fullMbti = `${ei}${sn}${tf}${jp}`;
                                    if (form.getValues('mbti') !== fullMbti) {
                                      form.setValue('mbti', fullMbti, { shouldValidate: true, shouldDirty: true });
                                    }
                                  } else if (form.getValues('mbti') !== '') {
                                    form.setValue('mbti', '', { shouldValidate: true, shouldDirty: true });
                                  }
                                }}
                              >
                                {mbtiValueFromForm && mbtiValueFromForm.length === 4 ? '완료' : '닫기'}
                              </Button>
                           </SheetClose>
                        </SheetContent>
                      </Sheet>
                       <FormMessage />
                    </FormItem>
                  )}
                />

                <FormField
                  control={form.control}
                  name="gender"
                  render={({ field }) => (
                    <FormItem className="flex flex-col">
                      <FormLabel>성별</FormLabel>
                      <Select onValueChange={field.onChange} defaultValue={field.value}>
                        <FormControl>
                          <SelectTrigger>
                            <User className="mr-2 h-4 w-4 opacity-50" />
                            <SelectValue placeholder="성별을 선택해주세요" />
                          </SelectTrigger>
                        </FormControl>
                        <SelectContent>
                          {GENDERS.map((gender) => (
                            <SelectItem key={gender.value} value={gender.value}>
                              {gender.label}
                            </SelectItem>
                          ))}
                        </SelectContent>
                      </Select>
                      <FormMessage />
                    </FormItem>
                  )}
                />

                <FormField
                  control={form.control}
                  name="birthTime"
                  render={({ field }) => (
                    <FormItem className="flex flex-col">
                      <FormLabel>태어난 시</FormLabel>
                      <Select onValueChange={field.onChange} defaultValue={field.value}>
                        <FormControl>
                          <SelectTrigger>
                            <Clock className="mr-2 h-4 w-4 opacity-50" />
                            <SelectValue placeholder="태어난 시를 선택해주세요" />
                          </SelectTrigger>
                        </FormControl>
                        <SelectContent>
                          {BIRTH_TIMES.map((time) => (
                            <SelectItem key={time.value} value={time.value}>
                              {time.label}
                            </SelectItem>
                          ))}
                        </SelectContent>
                      </Select>
                      <FormMessage />
                    </FormItem>
                  )}
                />

                <FormField
                  control={form.control}
                  name="fortuneTypes"
                  render={({ field }) => (
                    <FormItem>
                      <div className="mb-4">
                        <FormLabel className="text-base">운세 종류 선택</FormLabel>
                        <FormDescription>
                          알고 싶은 운세를 모두 선택하세요.
                        </FormDescription>
                      </div>
                      <div className="grid grid-cols-2 md:grid-cols-3 gap-3">
                        {FORTUNE_TYPES.map((item) => (
                          <Button
                            key={item}
                            type="button"
                            variant={field.value?.includes(item) ? "default" : "outline"}
                            onClick={() => {
                              const currentSelection = field.value || [];
                              const newSelection = currentSelection.includes(item)
                                ? currentSelection.filter((i) => i !== item)
                                : [...currentSelection, item];
                              field.onChange(newSelection);
                            }}
                            className="w-full h-auto py-3 text-sm justify-center"
                          >
                            {item}
                          </Button>
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
        {clientReady && currentYear ? (
          <p>&copy; {currentYear} 운세 탐험. 모든 운명은 당신의 선택에 달려있습니다.</p>
        ) : (
          <p>&copy; 운세 탐험. 모든 운명은 당신의 선택에 달려있습니다.</p> 
        )}
        <p className="mt-1">본 운세 내용은 재미를 위한 참고 자료로만 활용해주세요.</p>
      </footer>
    </div>
  );
}
