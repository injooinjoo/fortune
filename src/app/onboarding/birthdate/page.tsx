"use client";

import { useState, useEffect } from "react";
import { Button } from "@/components/ui/button";
import { Card, CardHeader, CardTitle, CardDescription, CardContent } from "@/components/ui/card";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Calendar, Star, Clock } from "lucide-react";
import { useRouter } from "next/navigation";
import { useToast } from "@/hooks/use-toast";
import { 
  getYearOptions, 
  getMonthOptions, 
  getDayOptions, 
  formatKoreanDate,
  TIME_PERIODS,
  getCurrentTimePeriod
} from "@/lib/utils";

export default function BirthdatePage() {
  const [birthYear, setBirthYear] = useState("");
  const [birthMonth, setBirthMonth] = useState("");
  const [birthDay, setBirthDay] = useState("");
  const [birthTimePeriod, setBirthTimePeriod] = useState("");
  const [showTimeSelection, setShowTimeSelection] = useState(false);
  const router = useRouter();
  const { toast } = useToast();

  // 년월이 변경될 때 일 옵션 업데이트
  const dayOptions = getDayOptions(
    birthYear ? parseInt(birthYear) : undefined,
    birthMonth ? parseInt(birthMonth) : undefined
  );

  // 현재 시진을 기본값으로 설정
  useEffect(() => {
    if (!birthTimePeriod) {
      setBirthTimePeriod(getCurrentTimePeriod());
    }
  }, [birthTimePeriod]);

  const handleNext = () => {
    if (!birthYear || !birthMonth || !birthDay) {
      toast({
        title: "생년월일을 선택해주세요",
        description: "정확한 운세를 위해 생년월일이 필요합니다.",
        variant: "destructive",
      });
      return;
    }

    // 생년월일과 시진을 로컬 스토리지에 저장
    localStorage.setItem("birthYear", birthYear);
    localStorage.setItem("birthMonth", birthMonth);
    localStorage.setItem("birthDay", birthDay);
    if (birthTimePeriod) {
      localStorage.setItem("birthTimePeriod", birthTimePeriod);
    }
    
    router.push("/onboarding/mbti");
  };

  const yearOptions = getYearOptions();
  const monthOptions = getMonthOptions();

  return (
    <div className="min-h-screen bg-gradient-to-br from-purple-50 to-pink-50 dark:from-gray-900 dark:to-gray-800 flex items-center justify-center p-4">
      <Card className="w-full max-w-md shadow-lg bg-white dark:bg-gray-800 border-gray-200 dark:border-gray-600">
        <CardHeader className="text-center pb-8">
          <div className="mx-auto mb-4 w-16 h-16 bg-purple-100 dark:bg-purple-900/30 rounded-full flex items-center justify-center">
            <Calendar className="w-8 h-8 text-purple-600 dark:text-purple-400" />
          </div>
          <h1 className="text-2xl font-bold text-gray-900 dark:text-gray-100 mb-2">
            생년월일을 알려주세요
          </h1>
          <CardDescription className="text-gray-600 dark:text-gray-400">
            정확한 사주 풀이를 위해 생년월일이 필요합니다
          </CardDescription>
        </CardHeader>

        <CardContent className="space-y-6">
          {/* 년도 선택 */}
          <div>
            <label htmlFor="birth-year" className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
              년도
            </label>
            <Select value={birthYear} onValueChange={setBirthYear}>
              <SelectTrigger className="w-full bg-white dark:bg-gray-700 border-gray-300 dark:border-gray-600 text-gray-900 dark:text-gray-100">
                <SelectValue placeholder="년도 선택" />
              </SelectTrigger>
              <SelectContent className="bg-white dark:bg-gray-700 border-gray-200 dark:border-gray-600">
                {yearOptions.map((year) => (
                  <SelectItem key={year} value={year.toString()} className="text-gray-900 dark:text-gray-100 hover:bg-gray-100 dark:hover:bg-gray-600">
                    {year}년
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>

          {/* 월 선택 */}
          <div>
            <label htmlFor="birth-month" className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
              월
            </label>
            <Select value={birthMonth} onValueChange={setBirthMonth}>
              <SelectTrigger className="w-full bg-white dark:bg-gray-700 border-gray-300 dark:border-gray-600 text-gray-900 dark:text-gray-100">
                <SelectValue placeholder="월 선택" />
              </SelectTrigger>
              <SelectContent className="bg-white dark:bg-gray-700 border-gray-200 dark:border-gray-600">
                {monthOptions.map((month) => (
                  <SelectItem key={month} value={month.toString()} className="text-gray-900 dark:text-gray-100 hover:bg-gray-100 dark:hover:bg-gray-600">
                    {month}월
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>

          {/* 일 선택 */}
          <div>
            <label htmlFor="birth-day" className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
              일
            </label>
            <Select value={birthDay} onValueChange={setBirthDay}>
              <SelectTrigger className="w-full bg-white dark:bg-gray-700 border-gray-300 dark:border-gray-600 text-gray-900 dark:text-gray-100">
                <SelectValue placeholder="일 선택" />
              </SelectTrigger>
              <SelectContent className="bg-white dark:bg-gray-700 border-gray-200 dark:border-gray-600">
                {dayOptions.map((day) => (
                  <SelectItem key={day} value={day.toString()} className="text-gray-900 dark:text-gray-100 hover:bg-gray-100 dark:hover:bg-gray-600">
                    {day}일
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>

          {/* 시진 선택 (선택사항) */}
          <div>
            <div className="flex items-center gap-2 mb-2">
              <Clock className="w-4 h-4 text-gray-600 dark:text-gray-400" />
              <label className="block text-sm font-medium text-gray-700 dark:text-gray-300">
                태어난 시진 (선택사항)
              </label>
            </div>
            <p className="text-xs text-gray-500 dark:text-gray-400 mb-3">
              더 정확한 사주 풀이를 위해 태어난 시간대를 선택해주세요
            </p>
            <Select value={birthTimePeriod} onValueChange={setBirthTimePeriod}>
              <SelectTrigger className="w-full bg-white dark:bg-gray-700 border-gray-300 dark:border-gray-600 text-gray-900 dark:text-gray-100">
                <SelectValue placeholder="시진 선택" />
              </SelectTrigger>
              <SelectContent className="bg-white dark:bg-gray-700 border-gray-200 dark:border-gray-600">
                {TIME_PERIODS.map((period) => (
                  <SelectItem key={period.value} value={period.value} className="text-gray-900 dark:text-gray-100 hover:bg-gray-100 dark:hover:bg-gray-600">
                    <div className="flex flex-col">
                      <span className="font-medium">{period.label}</span>
                      <span className="text-xs text-gray-500 dark:text-gray-400">{period.description}</span>
                    </div>
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>

          {/* 선택된 생년월일 표시 */}
          {birthYear && birthMonth && birthDay && (
            <div className="p-4 bg-purple-50 dark:bg-purple-900/30 rounded-lg border border-purple-200 dark:border-purple-700">
              <div className="text-center">
                <p className="font-semibold text-purple-800 dark:text-purple-300">
                  {formatKoreanDate(birthYear, birthMonth, birthDay)}
                </p>
                {birthTimePeriod && (
                  <p className="text-sm text-purple-600 dark:text-purple-400 mt-1">
                    {TIME_PERIODS.find(p => p.value === birthTimePeriod)?.label}
                  </p>
                )}
              </div>
            </div>
          )}

          <div className="space-y-3">
            <Button 
              onClick={handleNext}
              className="w-full bg-purple-600 hover:bg-purple-700 dark:bg-purple-500 dark:hover:bg-purple-600 text-white font-medium py-3 rounded-lg shadow-lg transition-colors"
            >
              <Star className="w-4 h-4 mr-2" />
              다음
            </Button>
            
            <Button
              variant="ghost"
              onClick={() => router.back()}
              className="w-full text-gray-600 dark:text-gray-400 hover:text-gray-800 dark:hover:text-gray-200"
            >
              이전으로
            </Button>
          </div>
        </CardContent>
      </Card>
    </div>
  );
} 