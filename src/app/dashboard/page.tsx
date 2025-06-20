"use client";

import { useState } from "react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Card, CardHeader, CardTitle, CardDescription, CardContent } from "@/components/ui/card";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Star, Calendar, Sparkles, Clock } from "lucide-react";
import AppHeader from "@/components/AppHeader";
import { 
  getYearOptions, 
  getMonthOptions, 
  getDayOptions, 
  formatKoreanDate,
  koreanToIsoDate,
  TIME_PERIODS
} from "@/lib/utils";

export default function DashboardPage() {
  const [birthYear, setBirthYear] = useState("");
  const [birthMonth, setBirthMonth] = useState("");
  const [birthDay, setBirthDay] = useState("");
  const [birthTimePeriod, setBirthTimePeriod] = useState("");
  const [showResult, setShowResult] = useState(false);
  const [fortuneResult, setFortuneResult] = useState("");

  const yearOptions = getYearOptions();
  const monthOptions = getMonthOptions();
  const dayOptions = getDayOptions(
    birthYear ? parseInt(birthYear) : undefined,
    birthMonth ? parseInt(birthMonth) : undefined
  );

  const handleFortuneSubmit = () => {
    if (!birthYear || !birthMonth || !birthDay) {
      alert("생년월일을 모두 선택해주세요.");
      return;
    }

    // 간단한 운세 생성
    const results = [
      "오늘은 새로운 시작에 좋은 날입니다. 도전하는 마음가짐으로 하루를 보내세요.",
      "사랑운이 상승하는 시기입니다. 소중한 사람과의 시간을 늘려보세요.",
      "재물운이 좋은 날입니다. 투자나 새로운 사업 기회를 고려해보세요.",
      "건강에 주의가 필요한 시기입니다. 규칙적인 생활 패턴을 유지하세요.",
      "인간관계에서 좋은 소식이 있을 것입니다. 주변 사람들과 소통하세요."
    ];
    
    const randomResult = results[Math.floor(Math.random() * results.length)];
    setFortuneResult(randomResult);
    setShowResult(true);
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-purple-50 to-pink-50 dark:from-gray-900 dark:via-gray-800 dark:to-gray-700 pb-20">
      <AppHeader title="대시보드" />
      
      <div className="px-6 pt-6 space-y-6">
        <div className="text-center mb-8">
          <h1 className="text-2xl font-bold text-gray-900 mb-2">
            운세 대시보드
          </h1>
          <p className="text-gray-600">
            생년월일을 입력하고 오늘의 운세를 확인해보세요
          </p>
        </div>

        <Card className="shadow-lg">
          <CardHeader className="text-center">
            <div className="mx-auto mb-4 w-16 h-16 bg-purple-100 rounded-full flex items-center justify-center">
              <Calendar className="w-8 h-8 text-purple-600" />
            </div>
            <CardTitle className="text-xl font-bold text-gray-900">
              운세 정보 입력
            </CardTitle>
            <CardDescription className="text-gray-600">
              정확한 운세를 위해 생년월일을 입력해주세요
            </CardDescription>
          </CardHeader>
          
          <CardContent className="space-y-4">
            {/* 년도 선택 */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
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
              <label className="block text-sm font-medium text-gray-700 mb-2">
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
              <label className="block text-sm font-medium text-gray-700 mb-2">
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
              <div className="p-3 bg-purple-50 rounded-lg border border-purple-200">
                <p className="text-sm font-medium text-purple-800 text-center">
                  {formatKoreanDate(birthYear, birthMonth, birthDay)}
                </p>
                {birthTimePeriod && (
                  <p className="text-xs text-purple-600 text-center mt-1">
                    {TIME_PERIODS.find(p => p.value === birthTimePeriod)?.label}
                  </p>
                )}
              </div>
            )}
            
            <Button 
              onClick={handleFortuneSubmit}
              className="w-full bg-purple-600 hover:bg-purple-700 text-white font-medium py-3 rounded-lg shadow-lg transition-colors"
            >
              <Star className="w-4 h-4 mr-2" />
              운세 보기
            </Button>
          </CardContent>
        </Card>

        {showResult && (
          <Card className="shadow-lg" data-testid="fortune-result">
            <CardHeader className="text-center">
              <div className="mx-auto mb-4 w-16 h-16 bg-yellow-100 rounded-full flex items-center justify-center">
                <Sparkles className="w-8 h-8 text-yellow-600" />
              </div>
              <CardTitle className="text-xl font-bold text-gray-900">
                오늘의 운세
              </CardTitle>
            </CardHeader>
            
            <CardContent>
              <div className="text-center space-y-4">
                <p className="text-gray-700 leading-relaxed">
                  {fortuneResult}
                </p>
                <div className="flex justify-center items-center space-x-4 text-sm text-gray-600">
                  <div className="flex items-center space-x-1">
                    <Star className="w-4 h-4 text-yellow-500" />
                    <span>행운 지수: 85%</span>
                  </div>
                  <div className="flex items-center space-x-1">
                    <Calendar className="w-4 h-4 text-purple-500" />
                    <span>{new Date().toLocaleDateString('ko-KR', {
                      year: 'numeric',
                      month: '2-digit',
                      day: '2-digit'
                    }).replace(/\./g, '').replace(/\s/g, '').replace(/(\d{4})(\d{2})(\d{2})/, '$1년 $2월 $3일')}</span>
                  </div>
                </div>
              </div>
            </CardContent>
          </Card>
        )}
      </div>
    </div>
  );
}
