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
    <div className="min-h-screen bg-gradient-to-br from-purple-50 to-pink-50 flex items-center justify-center p-4">
      <Card className="w-full max-w-md shadow-lg">
        <CardHeader className="text-center pb-8">
          <div className="mx-auto mb-4 w-16 h-16 bg-purple-100 rounded-full flex items-center justify-center">
            <Calendar className="w-8 h-8 text-purple-600" />
          </div>
          <h1 className="text-2xl font-bold text-gray-900 mb-2">
            생년월일을 알려주세요
          </h1>
          <CardDescription className="text-gray-600">
            정확한 사주 풀이를 위해 생년월일이 필요합니다
          </CardDescription>
        </CardHeader>

        <CardContent className="space-y-6">
          {/* 년도 선택 */}
          <div>
            <label htmlFor="birth-year" className="block text-sm font-medium text-gray-700 mb-2">
              년도
            </label>
            <Select value={birthYear} onValueChange={setBirthYear}>
              <SelectTrigger className="w-full">
                <SelectValue placeholder="년도 선택" />
              </SelectTrigger>
              <SelectContent>
                {yearOptions.map((year) => (
                  <SelectItem key={year} value={year.toString()}>
                    {year}년
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>

          {/* 월 선택 */}
          <div>
            <label htmlFor="birth-month" className="block text-sm font-medium text-gray-700 mb-2">
              월
            </label>
            <Select value={birthMonth} onValueChange={setBirthMonth}>
              <SelectTrigger className="w-full">
                <SelectValue placeholder="월 선택" />
              </SelectTrigger>
              <SelectContent>
                {monthOptions.map((month) => (
                  <SelectItem key={month} value={month.toString()}>
                    {month}월
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>

          {/* 일 선택 */}
          <div>
            <label htmlFor="birth-day" className="block text-sm font-medium text-gray-700 mb-2">
              일
            </label>
            <Select value={birthDay} onValueChange={setBirthDay}>
              <SelectTrigger className="w-full">
                <SelectValue placeholder="일 선택" />
              </SelectTrigger>
              <SelectContent>
                {dayOptions.map((day) => (
                  <SelectItem key={day} value={day.toString()}>
                    {day}일
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>

          {/* 시진 선택 (선택사항) */}
          <div>
            <div className="flex items-center gap-2 mb-2">
              <Clock className="w-4 h-4 text-gray-600" />
              <label className="block text-sm font-medium text-gray-700">
                태어난 시진 (선택사항)
              </label>
            </div>
            <p className="text-xs text-gray-500 mb-3">
              더 정확한 사주 풀이를 위해 태어난 시간대를 선택해주세요
            </p>
            <Select value={birthTimePeriod} onValueChange={setBirthTimePeriod}>
              <SelectTrigger className="w-full">
                <SelectValue placeholder="시진 선택" />
              </SelectTrigger>
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
          </div>

          {/* 선택된 생년월일 표시 */}
          {birthYear && birthMonth && birthDay && (
            <div className="p-4 bg-purple-50 rounded-lg border border-purple-200">
              <div className="text-center">
                <p className="font-semibold text-purple-800">
                  {formatKoreanDate(birthYear, birthMonth, birthDay)}
                </p>
                {birthTimePeriod && (
                  <p className="text-sm text-purple-600 mt-1">
                    {TIME_PERIODS.find(p => p.value === birthTimePeriod)?.label}
                  </p>
                )}
              </div>
            </div>
          )}

          <div className="space-y-3">
            <Button 
              onClick={handleNext}
              className="w-full bg-purple-600 hover:bg-purple-700 text-white font-medium py-3 rounded-lg shadow-lg transition-colors"
            >
              <Star className="w-4 h-4 mr-2" />
              다음
            </Button>
            
            <Button
              variant="ghost"
              onClick={() => router.back()}
              className="w-full text-gray-600 hover:text-gray-800"
            >
              이전으로
            </Button>
          </div>
        </CardContent>
      </Card>
    </div>
  );
} 