"use client";

import React, { useState, useTransition, useEffect, useMemo, useRef } from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { ChevronDown, User, Clock, ArrowLeft } from 'lucide-react';
import { useRouter } from 'next/navigation';

import { ProfileFormSchema, type ProfileFormValues } from '@/lib/schemas';
import { MBTI_TYPES, type FortuneType, GENDERS, BIRTH_TIMES } from '@/lib/fortune-data';

import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from '@/components/ui/card';
import { Form, FormControl, FormField, FormItem, FormLabel, FormMessage } from '@/components/ui/form';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Sheet, SheetContent, SheetHeader, SheetTitle, SheetTrigger, SheetClose, SheetDescription } from '@/components/ui/sheet';
import { Input } from '@/components/ui/input';
import { useToast } from '@/hooks/use-toast';
import { cn } from '@/lib/utils';

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
  ei: { label: "에너지", options: [{ value: 'E', name: "E (외향)", description: "활동으로 충전" }, { value: 'I', name: "I (내향)", description: "생각으로 충전" }] },
  sn: { label: "인식", options: [{ value: 'S', name: "S (감각)", description: "현재와 실제" }, { value: 'N', name: "N (직관)", description: "미래와 가능성" }] },
  tf: { label: "판단", options: [{ value: 'T', name: "T (사고)", description: "논리와 분석" }, { value: 'F', name: "F (감정)", description: "관계와 조화" }] },
  jp: { label: "생활", options: [{ value: 'J', name: "J (판단)", description: "계획과 통제" }, { value: 'P', name: "P (인식)", description: "자율과 융통성" }] },
} as const;

interface StepContentProps {
  children: React.ReactNode;
  isActive: boolean;
  isExiting: boolean;
  animationDelay?: string;
}

const StepContent: React.FC<StepContentProps> = ({ children, isActive, isExiting, animationDelay }) => {
  const [shouldRender, setShouldRender] = useState(isActive);

  useEffect(() => {
    if (isActive) {
      setShouldRender(true);
    } else if (isExiting) {
      const timer = setTimeout(() => setShouldRender(false), 500); // Match animation duration
      return () => clearTimeout(timer);
    }
  }, [isActive, isExiting]);

  if (!shouldRender && !isExiting) return null;

  const animationClass = isActive ? 'animate-slide-up-fade-in' : isExiting ? 'animate-fade-out-blur' : 'opacity-0';
  const style = animationDelay ? { animationDelay } : {};

  return (
    <div className={cn('absolute inset-0 w-full', animationClass)} style={style}>
      {children}
    </div>
  );
};

export default function ProfileSetupPage() {
  const [currentStep, setCurrentStep] = useState(1);
  const [previousStep, setPreviousStep] = useState(0); // To track exiting step
  const totalSteps = 3;

  const [isPending, startTransition] = useTransition();
  const { toast } = useToast();
  const router = useRouter();

  const form = useForm<ProfileFormValues>({
    resolver: zodResolver(ProfileFormSchema),
    defaultValues: {
      name: '',
      birthdate: undefined,
      mbti: '모름',
      gender: GENDERS[0].value,
      birthTime: BIRTH_TIMES[0].value,
    },
    mode: "onChange",
  });

  const [clientReady, setClientReady] = useState(false);
  const [selectedYear, setSelectedYear] = useState<number | undefined>();
  const [selectedMonth, setSelectedMonth] = useState<number | undefined>();
  const [selectedDay, setSelectedDay] = useState<number | undefined>();

  const [isMbtiSheetOpen, setIsMbtiSheetOpen] = useState(false);
  const [mbtiParts, setMbtiParts] = useState<MbtiPartsState>({ ei: null, sn: null, tf: null, jp: null });
  const [copyrightYear, setCopyrightYear] = useState<number | null>(null);
  const [animateCard, setAnimateCard] = useState(false);

  useEffect(() => {
    setClientReady(true);
    setAnimateCard(true); // Trigger card animation after mount
    const currentYear = new Date().getFullYear();
    setCopyrightYear(currentYear);

    const defaultBirthdate = form.getValues('birthdate');
    if (defaultBirthdate) {
      setSelectedYear(defaultBirthdate.getFullYear());
      setSelectedMonth(defaultBirthdate.getMonth() + 1);
      setSelectedDay(defaultBirthdate.getDate());
    }
  }, [form]);

  const watchedBirthdate = form.watch('birthdate');

  useEffect(() => {
    if (!clientReady) return;
    const formBirthdate = form.getValues('birthdate');

    if (formBirthdate) {
      const formYear = formBirthdate.getFullYear();
      const formMonth = formBirthdate.getMonth() + 1;
      const formDay = formBirthdate.getDate();

      if (selectedYear !== formYear) setSelectedYear(formYear);
      if (selectedMonth !== formMonth) setSelectedMonth(formMonth);
      if (selectedDay !== formDay) setSelectedDay(formDay);
    } else {
      if (selectedYear !== undefined || selectedMonth !== undefined || selectedDay !== undefined) {
        if (!form.getValues('birthdate')) {
          setSelectedYear(undefined);
          setSelectedMonth(undefined);
          setSelectedDay(undefined);
        }
      }
    }
  // eslint-disable-next-line react-hooks/exhaustive-deps
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
        const currentFormDate = form.getValues('birthdate');
        if (!currentFormDate || newDate.getTime() !== currentFormDate.getTime()) {
          form.setValue('birthdate', newDate, { shouldValidate: true, shouldDirty: true });
        }
      } else {
        if (form.getValues('birthdate')) {
          form.setValue('birthdate', undefined, { shouldValidate: true, shouldDirty: true });
        }
      }
    } else {
      if (form.getValues('birthdate') && (!selectedYear || !selectedMonth || !selectedDay)) {
        form.setValue('birthdate', undefined, { shouldValidate: true, shouldDirty: true });
      }
    }
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [selectedYear, selectedMonth, selectedDay, clientReady]);

  const yearOptions = useMemo(() => {
    if (!clientReady) return [];
    const currentYear = new Date().getFullYear();
    const startYear = currentYear - 100;
    const endYear = currentYear;
    return Array.from({ length: endYear - startYear + 1 }, (_, i) => endYear - i);
  }, [clientReady]);

  const monthOptions = useMemo(() => {
    return Array.from({ length: 12 }, (_, i) => i + 1);
  }, []);

  const dayOptions = useMemo(() => {
    if (!selectedYear || !selectedMonth) return [];
    if (selectedMonth < 1 || selectedMonth > 12) return [];
    const daysInSelectedMonth = new Date(selectedYear, selectedMonth, 0).getDate();
    return Array.from({ length: daysInSelectedMonth }, (_, i) => i + 1);
  }, [selectedYear, selectedMonth]);

  const mbtiValueFromForm = form.watch('mbti');

  useEffect(() => {
    if (isMbtiSheetOpen) {
      const currentMbti = form.getValues('mbti');
      if (currentMbti && currentMbti !== "모름" && currentMbti.length === 4) {
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
      } else {
        const currentMbtiOnForm = form.getValues('mbti');
        if (currentMbtiOnForm && currentMbtiOnForm !== "모름" && currentMbtiOnForm.length === 4) {
          if (!ei || !sn || !tf || !jp) {
            // A part was deselected, form MBTI remains until confirm/unknown.
          }
        }
      }
    }
  }, [mbtiParts, form, isMbtiSheetOpen]);

  const handleMbtiPartSelect = (part: MbtiPart, value: MbtiLetter<typeof part>) => {
    setMbtiParts(prev => ({ ...prev, [part]: prev[part] === value ? null : value }));
  };

  const handleMbtiSheetConfirm = () => {
    const { ei, sn, tf, jp } = mbtiParts;
    if (ei && sn && tf && jp) {
      form.setValue('mbti', `${ei}${sn}${tf}${jp}`, { shouldValidate: true, shouldDirty: true });
    } else {
      form.setValue('mbti', '모름', { shouldValidate: true, shouldDirty: true });
    }
    setIsMbtiSheetOpen(false);
  };

  const handleMbtiSheetSetToUnknown = () => {
    setMbtiParts({ ei: null, sn: null, tf: null, jp: null });
    form.setValue('mbti', '모름', { shouldValidate: true, shouldDirty: true });
    setIsMbtiSheetOpen(false);
  };

  const onSubmit = (values: ProfileFormValues) => {
    console.log("Profile Setup Data (to be saved to Firestore):", values);
    
    // 프로필 정보를 로컬스토리지에 저장
    localStorage.setItem('userProfile', JSON.stringify({
      name: values.name,
      birthdate: values.birthdate.toISOString(),
      mbti: values.mbti,
      gender: values.gender,
      birthTime: values.birthTime
    }));
    
    setPreviousStep(currentStep);
    startTransition(() => {
      return new Promise(resolve => setTimeout(() => {
        toast({
          title: "프로필 정보 저장됨",
          description: `${values.name}님의 정보가 저장되었습니다. 로그인을 진행해주세요.`,
        });
        router.push('/auth/selection');
        resolve(null);
      }, 1000));
    });
  };

  const handleNext = async () => {
    let fieldsToValidate: (keyof ProfileFormValues)[] = [];
    if (currentStep === 1) fieldsToValidate = ['name'];
    if (currentStep === 2) fieldsToValidate = ['birthdate', 'birthTime'];
    if (currentStep === 3) fieldsToValidate = ['mbti', 'gender'];

    const isValid = await form.trigger(fieldsToValidate);
    if (isValid) {
      if (currentStep < totalSteps) {
        setPreviousStep(currentStep);
        setCurrentStep(prev => prev + 1);
      } else {
        form.handleSubmit(onSubmit)();
      }
    } else {
      // Prevent focus loop if there are multiple errors
      const firstErrorField = fieldsToValidate.find(field => form.formState.errors[field]);
      if (firstErrorField) {
         // The error message will be displayed by FormMessage component
         // We don't need explicit toast for every field on every step
         // Toasting only for step 2 birthdate error as date selection isn't standard input
        if (currentStep === 2 && form.formState.errors.birthdate) toast({ title: "오류", description: "생년월일을 올바르게 입력해주세요.", variant: "destructive" });
      }
    }
  };

  const handlePrev = () => {
    setPreviousStep(currentStep);
    setCurrentStep(prev => prev - 1);
  };

  const getStepTitle = () => {
    switch (currentStep) {
      case 1: return "어떤 이름으로 불러드릴까요?";
      case 2: return "생년월일과 태어난 시간을 알려주세요.";
      case 3: return "MBTI 유형과 성별을 선택해주세요.";
      default: return "정보 입력";
    }
  };

  const getStepDescription = () => {
      return `STEP ${currentStep} / ${totalSteps}`;
  }

  const handleKeyDown = (event: React.KeyboardEvent<HTMLFormElement>) => {
    if (event.key === 'Enter') {
      // Prevent default form submission on Enter key press
      event.preventDefault();
      // Trigger handleNext only if not on the last step
      if (currentStep < totalSteps) {
        handleNext();
      }
    }
  };

  return (
    <div className="min-h-screen flex flex-col bg-background text-foreground">
      <header className="sticky top-0 z-10 flex items-center justify-between p-4 border-b bg-background/80 backdrop-blur-sm">
        {currentStep > 1 ? (
          <Button variant="ghost" size="icon" onClick={handlePrev} aria-label="이전 단계로" disabled={isPending}>
            <ArrowLeft className="h-5 w-5" />
          </Button>
        ) : (
          <div className="w-9 h-9"></div>
        )}
        <h1 className="text-lg font-semibold">사주정보 입력</h1>
        <div className="w-9 h-9"></div>
      </header>

      <main className="flex-grow flex flex-col items-center justify-center p-4 md:p-8">
        <Card className={cn("w-full max-w-md shadow-xl overflow-hidden", animateCard ? "animate-slide-up-fade-in" : "opacity-0")}>
          <CardContent className="p-6">
            <Form {...form}>
              <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-6 relative min-h-[400px]" onKeyDown={handleKeyDown}>
                <StepContent isActive={currentStep === 1} isExiting={previousStep === 1 && currentStep !== 1}>
                    <CardDescription className="text-sm">{getStepDescription()}</CardDescription>
                    <CardTitle className="text-2xl mt-1">{getStepTitle()}</CardTitle>
                    <FormField
                      control={form.control}
                      name="name"
                      render={({ field }) => (
                        <FormItem className="mt-4">
                          <FormLabel>이름</FormLabel>
                          <FormControl>
                            <Input placeholder="한글 최대 6자" {...field} />
                          </FormControl>
                          <FormMessage />
                        </FormItem>
                      )}
                    />
                </StepContent>

                <StepContent isActive={currentStep === 2} isExiting={previousStep === 2 && currentStep !== 2}>
                    <CardDescription className="text-sm">{getStepDescription()}</CardDescription>
                    <CardTitle className="text-2xl mt-1">{getStepTitle()}</CardTitle>
                    <FormField
                      control={form.control}
                      name="birthdate"
                      render={() => (
                        <FormItem className="flex flex-col mt-4">
                          <FormLabel>생년월일</FormLabel>
                          <div className="grid grid-cols-3 gap-2">
                            <Select
                              value={selectedYear?.toString() || ""}
                              onValueChange={(value) => {
                                const year = parseInt(value);
                                setSelectedYear(year);
                                if (selectedMonth && selectedDay) {
                                  const newDaysInMonth = new Date(year, selectedMonth, 0).getDate();
                                  if (selectedDay > newDaysInMonth) setSelectedDay(undefined);
                                }
                              }}
                              disabled={!clientReady}
                            >
                              <SelectTrigger><SelectValue placeholder="년" /></SelectTrigger>
                              <SelectContent>
                                {yearOptions.map((year) => (
                                  <SelectItem key={year} value={year.toString()}>{year}년</SelectItem>
                                ))}
                              </SelectContent>
                            </Select>
                            <Select
                              value={selectedMonth?.toString() || ""}
                              onValueChange={(value) => {
                                const month = parseInt(value);
                                setSelectedMonth(month);
                                if (selectedYear && selectedDay) {
                                  const newDaysInMonth = new Date(selectedYear, month, 0).getDate();
                                  if (selectedDay > newDaysInMonth) setSelectedDay(undefined);
                                }
                              }}
                              disabled={!clientReady || !selectedYear}
                            >
                              <SelectTrigger><SelectValue placeholder="월" /></SelectTrigger>
                              <SelectContent>
                                {monthOptions.map((month) => (
                                  <SelectItem key={month} value={month.toString()}>{month}월</SelectItem>
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
                                  <SelectItem key={day} value={day.toString()}>{day}일</SelectItem>
                                ))}
                                {dayOptions.length === 0 && selectedYear && selectedMonth && (
                                  <SelectItem value="-" disabled>날짜 없음</SelectItem>
                                )}
                              </SelectContent>
                            </Select>
                          </div>
                          <FormMessage>{form.formState.errors.birthdate?.message}</FormMessage>
                        </FormItem>
                      )}
                    />
                    <FormField
                      control={form.control}
                      name="birthTime"
                      render={({ field }) => (
                        <FormItem className="flex flex-col mt-4">
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
                                <SelectItem key={time.value} value={time.value}>{time.label}</SelectItem>
                              ))}
                            </SelectContent>
                          </Select>
                          <FormMessage />
                        </FormItem>
                      )}
                    />
                </StepContent>

                <StepContent isActive={currentStep === 3} isExiting={previousStep === 3 && currentStep !== 3}>
                    <CardDescription className="text-sm">{getStepDescription()}</CardDescription>
                    <CardTitle className="text-2xl mt-1">{getStepTitle()}</CardTitle>
                    <FormField
                      control={form.control}
                      name="mbti"
                      render={({ field }) => (
                        <FormItem className="flex flex-col mt-4">
                          <FormLabel>MBTI</FormLabel>
                          <Sheet open={isMbtiSheetOpen} onOpenChange={setIsMbtiSheetOpen}>
                            <SheetTrigger asChild>
                              <Button variant="outline" className="w-full justify-between font-normal">
                                {mbtiValueFromForm || "MBTI 선택 / 모름"}
                                <ChevronDown className="h-4 w-4 opacity-50" />
                              </Button>
                            </SheetTrigger>
                            <SheetContent side="bottom" className="h-auto max-h-[80vh] flex flex-col p-0">
                              <SheetHeader className="p-4 border-b">
                                <SheetTitle>MBTI 유형 선택</SheetTitle>
                                <SheetDescription>각 지표를 선택하거나 '모름'을 선택해주세요.</SheetDescription>
                              </SheetHeader>
                              <div className="flex-grow overflow-y-auto p-4 space-y-3">
                                {(Object.keys(mbtiDimensionDetails) as MbtiPart[]).map((partKey) => {
                                  const dimension = mbtiDimensionDetails[partKey];
                                  return (
                                    <div key={partKey}>
                                      <FormLabel className="text-xs font-medium text-muted-foreground mb-1.5 block">
                                        {dimension.label}
                                      </FormLabel>
                                      <div className="grid grid-cols-2 gap-2">
                                        {dimension.options.map(option => (
                                          <Button
                                            key={option.value}
                                            variant={mbtiParts[partKey] === option.value ? "default" : "outline"}
                                            className="h-auto flex flex-col justify-center items-center p-2 text-center shadow-sm hover:shadow-md transition-shadow duration-150"
                                            onClick={() => handleMbtiPartSelect(partKey, option.value as MbtiLetter<typeof partKey>)}
                                            type="button"
                                          >
                                            <span className="text-base font-semibold">{option.name}</span>
                                            <span className="mt-0.5 text-[11px] text-muted-foreground leading-tight">{option.description}</span>
                                          </Button>
                                        ))}
                                      </div>
                                    </div>
                                  );
                                })}
                              </div>
                              <div className="p-4 border-t mt-auto grid grid-cols-2 gap-2">
                                <Button type="button" variant="outline" onClick={handleMbtiSheetSetToUnknown}>모름</Button>
                                <Button type="button" onClick={handleMbtiSheetConfirm}>선택 완료</Button>
                              </div>
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
                        <FormItem className="flex flex-col mt-4">
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
                                <SelectItem key={gender.value} value={gender.value}>{gender.label}</SelectItem>
                              ))}
                            </SelectContent>
                          </Select>
                          <FormMessage />
                        </FormItem>
                      )}
                    />
                </StepContent>
              </form>
            </Form>
          </CardContent>
          <CardFooter className="flex justify-between p-6 pt-0">
            <Button type="button" variant="ghost" onClick={handlePrev} disabled={currentStep === 1 || isPending}>
              이전
            </Button>
            <Button 
              type="button" 
              onClick={handleNext} 
              disabled={isPending}
              className="min-w-[80px]"
            >
              {isPending ? (
                <div className="flex items-center">
                  <div className="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin mr-2"></div>
                  처리 중
                </div>
              ) : (
                currentStep === totalSteps ? "완료" : "다음"
              )}
            </Button>
          </CardFooter>
        </Card>
      </main>
      <footer className="py-6 text-center text-xs text-muted-foreground">
        {clientReady && copyrightYear && <p>&copy; {copyrightYear} 운세 탐험. 모든 운명은 당신의 선택에 달려있습니다.</p>}
        {!clientReady && <p>&copy; 운세 탐험. 모든 운명은 당신의 선택에 달려있습니다.</p>}
      </footer>
    </div>
  );
}
