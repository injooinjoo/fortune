"use client";

import React, { useState } from "react";
import { Tabs, TabsList, TabsTrigger, TabsContent } from "@/components/ui/tabs";
import { Card, CardHeader, CardTitle, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Droplet, Lock } from "lucide-react";
import AppHeader from "@/components/AppHeader";
import {
  RadarChart,
  PolarGrid,
  PolarAngleAxis,
  PolarRadiusAxis,
  Radar,
  ResponsiveContainer,
} from "recharts";

interface DetailItem {
  subject: string;
  text: string;
  premium?: boolean;
}

interface SajuData {
  summary: string;
  totalFortune: string;
  manse: {
    solar: string;
    lunar: string;
    ganji: string;
  };
  saju: {
    heaven: string[];
    earth: string[];
  };
  tenStars: { name: string; meaning: string }[];
  twelveFortunes: { name: string; description: string }[];
  elements: { subject: string; value: number }[];
  lifeCycles: {
    youth: string;
    middle: string;
    old: string;
  };
  details: DetailItem[];
}

// 임시 데이터. 실제 API 연동 시 fetchSajuData를 사용하세요.
const mockData: SajuData = {
  summary: "당신은 지혜로운 물(水)의 기운을 가진 사람입니다.",
  totalFortune:
    "물의 기운이 강한 당신은 유연하고 깊이 있는 사고를 지녔습니다. 주변과 조화를 이루며 때로는 흐름을 바꾸는 힘을 가졌습니다.",
  manse: {
    solar: "1990년 5월 17일",
    lunar: "음력 1990년 4월 23일",
    ganji: "경오년 을사월 정묘일 기미시",
  },
  saju: {
    heaven: ["경", "을", "정", "기"],
    earth: ["오", "사", "묘", "미"],
  },
  tenStars: [
    { name: "비견", meaning: "경쟁심과 독립" },
    { name: "식신", meaning: "표현력과 창조" },
    { name: "정재", meaning: "현실적 재물" },
    { name: "편관", meaning: "도전과 규범" },
    { name: "정인", meaning: "학습과 도움" },
  ],
  twelveFortunes: [
    { name: "장생", description: "새로운 시작과 에너지" },
    { name: "목욕", description: "감정이 예민해지는 시기" },
    { name: "관대", description: "역량이 커지는 때" },
    { name: "건록", description: "활동력이 최고조" },
    { name: "제왕", description: "가장 왕성한 상태" },
    { name: "쇠", description: "기세가 약해짐" },
    { name: "병", description: "다소 불안정" },
    { name: "사", description: "정리가 필요한 시기" },
    { name: "묘", description: "휴식과 재충전" },
    { name: "절", description: "에너지 감소" },
    { name: "태", description: "새로운 준비" },
    { name: "양", description: "다시 태어남" },
  ],
  elements: [
    { subject: "木", value: 60 },
    { subject: "火", value: 40 },
    { subject: "土", value: 55 },
    { subject: "金", value: 35 },
    { subject: "水", value: 80 },
  ],
  lifeCycles: {
    youth: "학업과 인간관계에서 다양한 경험을 쌓는 시기입니다. 도전이 많지만 성장의 발판이 됩니다.",
    middle: "직장과 가정에서 안정을 찾고 노력한 만큼 결실을 보게 됩니다.",
    old: "그동안의 지혜를 통해 주변에 귀감이 되며, 마음의 평화를 얻습니다.",
  },
  details: [
    { subject: "재물", text: "재물운이 비교적 안정적이며 꾸준한 성장을 기대할 수 있습니다." },
    { subject: "연애", text: "당신의 매력이 빛나는 시기이지만 중요한 선택은 신중히.", premium: true },
    { subject: "건강", text: "큰 무리는 없으나 수분 섭취와 휴식이 필요합니다." },
  ],
};

export async function fetchSajuData(): Promise<SajuData> {
  // TODO: Genkit API 연동
  return Promise.resolve(mockData);
}

export default function SajuAnalysisPage() {
  const data = mockData; // 추후 fetchSajuData()로 대체
  const [fontSize, setFontSize] = useState<'small' | 'medium' | 'large'>('medium');

  return (
    <>
      <AppHeader 
        title="사주팔자" 
        onFontSizeChange={setFontSize}
        currentFontSize={fontSize}
      />
      <div className="pb-32 px-4 space-y-6 pt-4">
        <header className="p-4 rounded-md bg-blue-50 dark:bg-blue-900/30 text-blue-700 dark:text-blue-300 flex items-center justify-center gap-2">
          <Droplet className="w-5 h-5" />
          <h2 className="text-lg font-semibold">{data.summary}</h2>
        </header>

        <Tabs defaultValue="general" className="w-full">
          <TabsList className="grid w-full grid-cols-4 gap-1">
            <TabsTrigger value="general">총운</TabsTrigger>
            <TabsTrigger value="manse">만세력</TabsTrigger>
            <TabsTrigger value="saju">사주팔자</TabsTrigger>
            <TabsTrigger value="elements">오행 분석</TabsTrigger>
            <TabsTrigger value="tenStar">십성</TabsTrigger>
            <TabsTrigger value="twelve">십이운성</TabsTrigger>
            <TabsTrigger value="cycle">인생 주기</TabsTrigger>
            <TabsTrigger value="detail">상세 풀이</TabsTrigger>
          </TabsList>

          <TabsContent value="general" className="mt-4">
            <p className="leading-relaxed text-sm text-muted-foreground">
              {data.totalFortune}
            </p>
          </TabsContent>

          <TabsContent value="manse" className="mt-4">
            <Card>
              <CardHeader>
                <CardTitle>만세력</CardTitle>
              </CardHeader>
              <CardContent className="space-y-1 text-sm text-muted-foreground">
                <p>양력: {data.manse.solar}</p>
                <p>음력: {data.manse.lunar}</p>
                <p>간지: {data.manse.ganji}</p>
              </CardContent>
            </Card>
          </TabsContent>

          <TabsContent value="saju" className="mt-4">
            <Card>
              <CardHeader>
                <CardTitle>사주팔자</CardTitle>
              </CardHeader>
              <CardContent>
                <div className="grid grid-cols-4 gap-2 text-center">
                  {data.saju.heaven.map((h, idx) => (
                    <div key={`h-${idx}`} className="rounded-md bg-blue-50 dark:bg-blue-900/30 p-2 text-blue-800 dark:text-blue-200">
                      {h}
                    </div>
                  ))}
                </div>
                <div className="grid grid-cols-4 gap-2 text-center mt-2">
                  {data.saju.earth.map((e, idx) => (
                    <div key={`e-${idx}`} className="rounded-md bg-green-50 dark:bg-green-900/30 p-2 text-green-800 dark:text-green-200">
                      {e}
                    </div>
                  ))}
                </div>
              </CardContent>
            </Card>
          </TabsContent>


          <TabsContent value="elements" className="mt-4">
            <div className="w-full h-64">
              <ResponsiveContainer width="100%" height="100%">
                <RadarChart data={data.elements} outerRadius="80%">
                  <PolarGrid />
                  <PolarAngleAxis dataKey="subject" />
                  <PolarRadiusAxis angle={30} domain={[0, 100]} />
                  <Radar
                    name="오행"
                    dataKey="value"
                    stroke="#3b82f6"
                    fill="#3b82f6"
                    fillOpacity={0.6}
                  />
                </RadarChart>
              </ResponsiveContainer>
            </div>
          </TabsContent>

          <TabsContent value="tenStar" className="mt-4 space-y-3">
            {data.tenStars.map((star) => (
              <Card key={star.name}>
                <CardHeader>
                  <CardTitle>{star.name}</CardTitle>
                </CardHeader>
                <CardContent>
                  <p className="text-sm text-muted-foreground">{star.meaning}</p>
                </CardContent>
              </Card>
            ))}
          </TabsContent>

          <TabsContent value="twelve" className="mt-4">
            <Card>
              <CardHeader>
                <CardTitle>십이운성</CardTitle>
              </CardHeader>
              <CardContent>
                <div className="grid grid-cols-2 gap-2">
                  {data.twelveFortunes.map((item) => (
                    <div key={item.name} className="p-2 rounded-md bg-gray-50 dark:bg-gray-800/50">
                      <div className="font-medium text-sm text-gray-800 dark:text-gray-200">{item.name}</div>
                      <p className="text-xs text-muted-foreground">
                        {item.description}
                      </p>
                    </div>
                  ))}
                </div>
              </CardContent>
            </Card>
          </TabsContent>

          <TabsContent value="cycle" className="mt-4 space-y-3">
            <Card>
              <CardHeader>
                <CardTitle>초년운</CardTitle>
              </CardHeader>
              <CardContent>
                <p className="text-sm text-muted-foreground">{data.lifeCycles.youth}</p>
              </CardContent>
            </Card>
            <Card>
              <CardHeader>
                <CardTitle>중년운</CardTitle>
              </CardHeader>
              <CardContent>
                <p className="text-sm text-muted-foreground">{data.lifeCycles.middle}</p>
              </CardContent>
            </Card>
            <Card>
              <CardHeader>
                <CardTitle>말년운</CardTitle>
              </CardHeader>
              <CardContent>
                <p className="text-sm text-muted-foreground">{data.lifeCycles.old}</p>
              </CardContent>
            </Card>
          </TabsContent>

          <TabsContent value="detail" className="mt-4 space-y-3">
            {data.details.map((item) => (
              <Card key={item.subject}>
                <CardHeader>
                  <CardTitle>{item.subject}</CardTitle>
                </CardHeader>
                <CardContent>
                  {item.premium ? (
                    <div className="flex flex-col items-center space-y-2 py-4">
                      <Lock className="w-6 h-6 text-muted-foreground" />
                      <Button size="sm">프리미엄 구독으로 전체 내용 확인하기</Button>
                    </div>
                  ) : (
                    <p className="text-sm text-muted-foreground">{item.text}</p>
                  )}
                </CardContent>
              </Card>
            ))}
          </TabsContent>
        </Tabs>

        <div className="sticky bottom-16 left-0 right-0 bg-background border-t p-4 flex gap-2">
          <Button className="flex-1">결과 저장하기</Button>
          <Button variant="outline" className="flex-1">
            공유하기
          </Button>
        </div>
      </div>
    </>
  );
}

