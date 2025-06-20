"use client";

import React, { useState } from "react";
import AppHeader from "@/components/AppHeader";
import { Tabs, TabsList, TabsTrigger, TabsContent } from "@/components/ui/tabs";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Droplet } from "lucide-react";
import {
  RadarChart,
  PolarGrid,
  PolarAngleAxis,
  PolarRadiusAxis,
  Radar,
  ResponsiveContainer,
} from "recharts";

interface TalentReport {
  summary: string;
  elements: { subject: string; value: number }[];
  strengths: string[];
  weaknesses: string[];
  recommendedFields: string[];
  tips: string[];
}

const mockReport: TalentReport = {
  summary: "화(火)의 기운이 강해 창의적이고 추진력이 뛰어난 타입입니다.",
  elements: [
    { subject: "창의", value: 80 },
    { subject: "분석", value: 65 },
    { subject: "리더십", value: 75 },
    { subject: "소통", value: 70 },
    { subject: "집중", value: 60 },
  ],
  strengths: [
    "새로운 아이디어를 빠르게 떠올리는 능력",
    "주변을 이끄는 리더십",
    "도전을 두려워하지 않는 추진력",
  ],
  weaknesses: [
    "세부 계획이 부족할 수 있음",
    "감정 기복이 심해 집중력이 흔들릴 수 있음",
  ],
  recommendedFields: [
    "예술·디자인",
    "기획·마케팅",
    "창업 및 리더십이 요구되는 분야",
  ],
  tips: [
    "장기적인 목표를 세워 꾸준히 실행력을 키우세요",
    "팀워크를 통해 약점을 보완하면 더 큰 성과를 낼 수 있습니다",
  ],
};

export default function TalentPage() {
  const [fontSize, setFontSize] = useState<'small' | 'medium' | 'large'>('medium');
  const data = mockReport; // API 연동 시 fetch 함수로 대체

  return (
    <>
      <AppHeader
        title="능력 평가"
        onFontSizeChange={setFontSize}
        currentFontSize={fontSize}
      />
      <div className="pb-32 px-4 space-y-6 pt-4">
        <header className="p-4 rounded-md bg-green-50 text-green-700 flex items-center justify-center gap-2">
          <Droplet className="w-5 h-5" />
          <h2 className="text-lg font-semibold">{data.summary}</h2>
        </header>

        <Tabs defaultValue="general" className="w-full">
          <TabsList className="grid w-full grid-cols-4">
            <TabsTrigger value="general">종합</TabsTrigger>
            <TabsTrigger value="strength">강점</TabsTrigger>
            <TabsTrigger value="weakness">약점</TabsTrigger>
            <TabsTrigger value="apply">활용법</TabsTrigger>
          </TabsList>

          <TabsContent value="general" className="mt-4">
            <div className="w-full h-64">
              <ResponsiveContainer width="100%" height="100%">
                <RadarChart data={data.elements} outerRadius="80%">
                  <PolarGrid />
                  <PolarAngleAxis dataKey="subject" />
                  <PolarRadiusAxis angle={30} domain={[0, 100]} />
                  <Radar
                    name="재능"
                    dataKey="value"
                    stroke="#10b981"
                    fill="#10b981"
                    fillOpacity={0.6}
                  />
                </RadarChart>
              </ResponsiveContainer>
            </div>
          </TabsContent>

          <TabsContent value="strength" className="mt-4 space-y-3">
            {data.strengths.map((item, index) => (
              <Card key={index}>
                <CardContent className="p-4 text-sm text-muted-foreground">
                  {item}
                </CardContent>
              </Card>
            ))}
          </TabsContent>

          <TabsContent value="weakness" className="mt-4 space-y-3">
            {data.weaknesses.map((item, index) => (
              <Card key={index}>
                <CardContent className="p-4 text-sm text-muted-foreground">
                  {item}
                </CardContent>
              </Card>
            ))}
          </TabsContent>

          <TabsContent value="apply" className="mt-4 space-y-6">
            <div className="space-y-3">
              <Card>
                <CardHeader>
                  <CardTitle>추천 분야</CardTitle>
                </CardHeader>
                <CardContent className="space-y-2">
                  {data.recommendedFields.map((field, index) => (
                    <p key={index} className="text-sm text-muted-foreground">
                      • {field}
                    </p>
                  ))}
                </CardContent>
              </Card>
              <Card>
                <CardHeader>
                  <CardTitle>성장 팁</CardTitle>
                </CardHeader>
                <CardContent className="space-y-2">
                  {data.tips.map((tip, index) => (
                    <p key={index} className="text-sm text-muted-foreground">
                      • {tip}
                    </p>
                  ))}
                </CardContent>
              </Card>
            </div>
          </TabsContent>
        </Tabs>
      </div>
    </>
  );
}
