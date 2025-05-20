
"use client";

import React, { useState, useTransition } from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { format } from 'date-fns';
import { ko } from 'date-fns/locale';
import { CalendarIcon, Sparkles, Wand2, Loader2, AlertTriangle, Lightbulb, Users, Star, Heart, Briefcase, Coins, RotateCcw } from 'lucide-react';

import { FortuneFormSchema, type FortuneFormValues } from '@/lib/schemas';
import { FORTUNE_TYPES, type FortuneType } from '@/lib/fortune-data';
import { getFortuneAction, type ActionResult } from './actions';
import type { GenerateFortuneInsightsOutput } from "@/ai/flows/generate-fortune-insights";

import { Button } from '@/components/ui/button';
import { Calendar } from '@/components/ui/calendar';
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from '@/components/ui/card';
import { Checkbox } from '@/components/ui/checkbox';
import { Form, FormControl, FormDescription, FormField, FormItem, FormLabel, FormMessage } from '@/components/ui/form';
import { Input } from '@/components/ui/input';
import { Accordion, AccordionContent, AccordionItem, AccordionTrigger } from '@/components/ui/accordion';
import { Sheet, SheetContent, SheetTrigger, SheetHeader, SheetTitle, SheetDescription } from '@/components/ui/sheet';
import { useToast } from '@/hooks/use-toast';
import { cn } from '@/lib/utils';
import { FortuneCompassIcon } from '@/components/icons/fortune-compass-icon';

const fortuneIconMapping: Record<FortuneType, React.ElementType> = {
  "사주팔자": Wand2,
  "MBTI 운세": Users,
  "띠운세": Sparkles, // Could use a specific animal icon if available or desired
  "별자리운세": Star,
  "연애운": Heart,
  "결혼운": Heart, // Could differentiate if specific icons exist
  "취업운": Briefcase,
  "오늘의 총운": Lightbulb,
  "금전운": Coins,
};


export default function FortunePage() {
  const [isPending, startTransition] = useTransition();
  const [fortuneResult, setFortuneResult] = useState<GenerateFortuneInsightsOutput | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [lastSubmittedData, setLastSubmittedData] = useState<FortuneFormValues | null>(null);
  const [isCalendarSheetOpen, setIsCalendarSheetOpen] = React.useState(false);

  const { toast } = useToast();

  const form = useForm<FortuneFormValues>({
    resolver: zodResolver(FortuneFormSchema),
    defaultValues: {
      birthdate: undefined,
      mbti: '',
      fortuneTypes: [],
    },
  });

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
                         Object.values(fortuneResult.insights)[0]; // Fallback to first insight

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
    <div className="min-h-screen flex flex-col items-center justify-center p-4 md:p-8 bg-gradient-to-br from-background to-purple-100 dark:from-gray-900 dark:to-indigo-900">
      <header className="mb-10 text-center">
        <div className="flex items-center justify-center mb-2">
          <FortuneCompassIcon className="h-16 w-16 text-primary" />
          <h1 className="ml-3 text-5xl font-bold tracking-tight text-primary">
            Fortune Compass
          </h1>
        </div>
        <p className="text-xl text-muted-foreground">
          AI가 밝혀주는 당신의 미래, 지금 바로 확인하세요.
        </p>
      </header>

      <main className="w-full max-w-2xl">
        <Card className="shadow-2xl">
          <CardHeader>
            <CardTitle className="text-2xl">나의 운세 알아보기</CardTitle>
            <CardDescription>생년월일, MBTI, 그리고 원하는 운세 종류를 선택해주세요.</CardDescription>
          </CardHeader>
          <CardContent>
            <Form {...form}>
              <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-8">
                <FormField
                  control={form.control}
                  name="birthdate"
                  render={({ field }) => (
                    <FormItem className="flex flex-col">
                      <FormLabel>생년월일</FormLabel>
                      <Sheet open={isCalendarSheetOpen} onOpenChange={setIsCalendarSheetOpen}>
                        <SheetTrigger asChild>
                          <FormControl>
                            <Button
                              variant={"outline"}
                              className={cn(
                                "w-full pl-3 text-left font-normal",
                                !field.value && "text-muted-foreground"
                              )}
                            >
                              {field.value ? (
                                format(field.value, "PPP", { locale: ko })
                              ) : (
                                <span>날짜를 선택하세요</span>
                              )}
                              <CalendarIcon className="ml-auto h-4 w-4 opacity-50" />
                            </Button>
                          </FormControl>
                        </SheetTrigger>
                        <SheetContent side="bottom" className="p-0 flex flex-col items-center h-auto">
                          <SheetHeader className="pt-4">
                            <SheetTitle>생년월일 선택</SheetTitle>
                            <SheetDescription>달력에서 날짜를 선택해주세요.</SheetDescription>
                          </SheetHeader>
                          <Calendar
                            mode="single"
                            selected={field.value}
                            onSelect={(date) => {
                              field.onChange(date);
                              setIsCalendarSheetOpen(false);
                            }}
                            disabled={(date) =>
                              date > new Date() || date < new Date("1900-01-01")
                            }
                            initialFocus
                            captionLayout="dropdown-buttons"
                            fromYear={1900}
                            toYear={new Date().getFullYear()}
                            className="pt-2 pb-4"
                          />
                        </SheetContent>
                      </Sheet>
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
                        <Input placeholder="예: INFJ" {...field} />
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
        <p>&copy; {new Date().getFullYear()} Fortune Compass. 모든 운명은 당신의 선택에 달려있습니다.</p>
        <p className="mt-1">본 운세 내용은 재미를 위한 참고 자료로만 활용해주세요.</p>
      </footer>
    </div>
  );
}

    