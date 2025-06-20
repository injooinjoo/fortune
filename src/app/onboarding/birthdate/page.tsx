"use client";

import { useState } from "react";
import { Button } from "@/components/ui/button";
import { Card, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Calendar, Star } from "lucide-react";
import { useRouter } from "next/navigation";
import { useToast } from "@/hooks/use-toast";

export default function BirthdatePage() {
  const [birthYear, setBirthYear] = useState("");
  const [birthMonth, setBirthMonth] = useState("");
  const [birthDay, setBirthDay] = useState("");
  const [showCalendar, setShowCalendar] = useState(false);
  const router = useRouter();
  const { toast } = useToast();

  const handleNext = () => {
    if (!birthYear || !birthMonth || !birthDay) {
      toast({
        title: "생년월일을 선택해주세요",
        description: "정확한 운세를 위해 생년월일이 필요합니다.",
        variant: "destructive",
      });
      return;
    }

    // 생년월일을 로컬 스토리지에 저장
    localStorage.setItem("birthYear", birthYear);
    localStorage.setItem("birthMonth", birthMonth);
    localStorage.setItem("birthDay", birthDay);
    
    router.push("/onboarding/mbti");
  };

  const handleDaySelect = (day: string) => {
    setBirthDay(day);
    // 달력을 바로 닫지 않고 확인 버튼 클릭까지 기다림
  };

  const handleCalendarConfirm = () => {
    setShowCalendar(false);
  };

  const handleCalendarToggle = () => {
    setShowCalendar(!showCalendar);
  };

  // 년도 옵션 생성 (1950-2024)
  const yearOptions = Array.from({ length: 75 }, (_, i) => 2024 - i);
  
  // 월 옵션 생성 (1-12)
  const monthOptions = Array.from({ length: 12 }, (_, i) => i + 1);
  
  // 일 옵션 생성 (1-31)
  const dayOptions = Array.from({ length: 31 }, (_, i) => i + 1);

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

        <div className="px-6 pb-6 space-y-6">
          <div className="space-y-4">
            {/* 년도 선택 */}
            <div>
              <label htmlFor="birth-year" className="block text-sm font-medium text-gray-700 mb-2">
                년
              </label>
              <select 
                id="birth-year"
                data-testid="birth-year-select"
                aria-label="생년 선택"
                value={birthYear} 
                onChange={(e) => setBirthYear(e.target.value)}
                className="w-full p-2 border border-gray-300 rounded-md shadow-sm focus:ring-2 focus:ring-purple-500 focus:border-purple-500"
              >
                <option value="">년도 선택</option>
                {yearOptions.map((year) => (
                  <option key={year} value={year.toString()}>
                    {year}
                  </option>
                ))}
              </select>
            </div>

            {/* 월 선택 */}
            <div>
              <label htmlFor="birth-month" className="block text-sm font-medium text-gray-700 mb-2">
                월
              </label>
              <select 
                id="birth-month"
                data-testid="birth-month-select"
                aria-label="생월 선택"
                value={birthMonth} 
                onChange={(e) => setBirthMonth(e.target.value)}
                className="w-full p-2 border border-gray-300 rounded-md shadow-sm focus:ring-2 focus:ring-purple-500 focus:border-purple-500"
              >
                <option value="">월 선택</option>
                {monthOptions.map((month) => (
                  <option key={month} value={month.toString()}>
                    {month}
                  </option>
                ))}
              </select>
            </div>

            {/* 일 선택 */}
            <div>
              <label htmlFor="birth-day" className="block text-sm font-medium text-gray-700 mb-2">
                일
              </label>
              <select 
                id="birth-day"
                data-testid="birth-day-select"
                aria-label="생일 선택"
                value={birthDay} 
                onChange={(e) => setBirthDay(e.target.value)}
                className="w-full p-2 border border-gray-300 rounded-md shadow-sm focus:ring-2 focus:ring-purple-500 focus:border-purple-500"
              >
                <option value="">일 선택</option>
                {dayOptions.map((day) => (
                  <option key={day} value={day.toString()}>
                    {day}
                  </option>
                ))}
              </select>
              
              {/* 캘린더 형태 입력 (테스트용) */}
              <div className="mt-3">
                <Button 
                  variant="outline" 
                  className="w-full justify-start text-left font-normal"
                  onClick={handleCalendarToggle}
                  role="button"
                >
                  생년월일 입력
                </Button>
                
                {/* 간단한 달력 그리드 */}
                {showCalendar && (
                  <div className="mt-3 p-4 border rounded-lg bg-white">
                    <div className="text-sm font-medium mb-2">일자 선택</div>
                    <div className="grid grid-cols-7 gap-2 mb-3">
                      {dayOptions.map((day) => (
                        <Button
                          key={day}
                          variant="outline"
                          size="sm"
                          onClick={() => handleDaySelect(day.toString())}
                          className="aspect-square p-0 text-xs"
                        >
                          {day}
                        </Button>
                      ))}
                    </div>
                    <div className="flex justify-end">
                      <Button onClick={handleCalendarConfirm} size="sm">
                        확인
                      </Button>
                    </div>
                  </div>
                )}
              </div>
            </div>
          </div>

          {/* 선택된 생년월일 표시 */}
          {(birthYear && birthMonth && birthDay) || birthDay ? (
            <div 
              data-testid="birthdate-display"
              className="p-4 bg-purple-50 rounded-lg border border-purple-200"
            >
              <div className="text-center">
                {birthYear && birthMonth && birthDay ? (
                  <p className="font-semibold text-purple-800">
                    {birthYear}년 {birthMonth}월 {birthDay}일
                  </p>
                ) : birthDay ? (
                  <p className="font-semibold text-purple-800">
                    {birthDay}일 선택됨
                  </p>
                ) : null}
              </div>
            </div>
          ) : null}

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
        </div>
      </Card>
    </div>
  );
} 