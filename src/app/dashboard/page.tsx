"use client";

import { useState } from "react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Card, CardHeader, CardTitle, CardDescription, CardContent } from "@/components/ui/card";
import { Star, Calendar, Sparkles } from "lucide-react";
import AppHeader from "@/components/AppHeader";

export default function DashboardPage() {
  const [birthDate, setBirthDate] = useState("");
  const [showResult, setShowResult] = useState(false);
  const [fortuneResult, setFortuneResult] = useState("");

  const handleFortuneSubmit = () => {
    if (!birthDate) {
      alert("생년월일을 입력해주세요.");
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
    <div className="min-h-screen bg-gradient-to-br from-purple-50 to-pink-50 pb-20">
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
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                생년월일
              </label>
              <Input
                type="date"
                value={birthDate}
                onChange={(e) => setBirthDate(e.target.value)}
                className="w-full"
              />
            </div>
            
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
                    <span>{new Date().toLocaleDateString()}</span>
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
