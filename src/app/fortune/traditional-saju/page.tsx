"use client";

import React, { useState } from "react";
import AppHeader from "@/components/AppHeader";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { ScrollArea } from "@/components/ui/scroll-area";

interface Blessing {
  name: string;
  description: string;
}

interface Curse {
  name: string;
  description: string;
}

interface DetailItem {
  subject: string;
  text: string;
  premium?: boolean;
}

interface TraditionalSajuData {
  summary: string;
  totalFortune: string;
  elements: { subject: string; value: number }[];
  lifeCycles: {
    youth: string;
    middle: string;
    old: string;
  };
  blessings: Blessing[];
  curses: Curse[];
  details: DetailItem[];
}

// TODO: Replace with Genkit API
const mockData: TraditionalSajuData = {
  summary: "타고난 물(水)의 기운이 강해 섬세하면서도 포용력이 뛰어납니다.",
  totalFortune:
    "전체적인 운세 흐름은 안정적이지만 중요한 국면마다 결단력이 필요합니다.",
  elements: [
    { subject: "木", value: 55 },
    { subject: "火", value: 35 },
    { subject: "土", value: 50 },
    { subject: "金", value: 40 },
    { subject: "水", value: 80 },
  ],
  lifeCycles: {
    youth:
      "학업과 인간관계의 폭이 넓어지는 시기로, 다양한 경험이 후일 큰 자산이 됩니다.",
    middle:
      "직장과 가정에서 중요한 전환점을 맞이하며, 선택에 따라 성취의 폭이 달라집니다.",
    old:
      "쌓아온 지혜가 빛을 발하며 주변의 존경을 받는 시기입니다. 마음의 여유를 찾게 됩니다.",
  },
  blessings: [
    { name: "천을귀인", description: "귀인의 도움을 받아 위기를 기회로 바꾸는 복." },
    { name: "문창귀인", description: "학문과 예술 분야에서 재능을 꽃피우는 복." },
  ],
  curses: [
    { name: "백호살", description: "충동적인 성향으로 인해 갈등이 생기기 쉬움." },
    { name: "역마살", description: "이동과 변동이 잦아 한곳에 머무르기 어려움." },
  ],
  details: [
    {
      subject: "재물운",
      text: "꾸준한 재물 흐름이 있으나 과감한 투자는 신중히 결정하세요.",
    },
    {
      subject: "애정운",
      text: "배려심이 큰 편이나 때때로 우유부단함이 문제 될 수 있습니다.",
      premium: true,
    },
    {
      subject: "건강운",
      text: "스트레스 관리에 유의하면 큰 탈 없이 지낼 수 있습니다.",
    },
  ],
};

export default function TraditionalSajuPage() {
  const data = mockData; // 추후 API 연동 예정
  const [fontSize, setFontSize] = useState<'small' | 'medium' | 'large'>('medium');

  return (
    <>
      <AppHeader
        title="정통 사주"
        onFontSizeChange={setFontSize}
        currentFontSize={fontSize}
      />
      <div className="pb-32 px-4 space-y-6 pt-4">
        <header className="p-4 rounded-md bg-purple-50 text-purple-700 flex items-center justify-center gap-2">
          <h2 className="text-lg font-semibold">{data.summary}</h2>
        </header>

        <Tabs defaultValue="general" className="w-full">
          <TabsList className="grid w-full grid-cols-5">
            <TabsTrigger value="general">총운</TabsTrigger>
            <TabsTrigger value="elements">오행</TabsTrigger>
            <TabsTrigger value="cycle">인생 흐름</TabsTrigger>
            <TabsTrigger value="fate">복과 살</TabsTrigger>
            <TabsTrigger value="detail">상세</TabsTrigger>
          </TabsList>

          <TabsContent value="general" className="mt-4">
            <p className="leading-relaxed text-sm text-muted-foreground">
              {data.totalFortune}
            </p>
          </TabsContent>

          <TabsContent value="elements" className="mt-4">
            <div className="grid grid-cols-5 gap-2 text-center text-sm">
              {data.elements.map((el) => (
                <div key={el.subject} className="space-y-1">
                  <div className="text-lg font-bold text-purple-600">{el.subject}</div>
                  <div className="text-gray-600">{el.value}</div>
                </div>
              ))}
            </div>
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

          <TabsContent value="fate" className="mt-4 space-y-3">
            <ScrollArea className="h-48 pr-4">
              <h3 className="font-semibold text-sm mb-2">타고난 복(福)</h3>
              {data.blessings.map((b) => (
                <div key={b.name} className="mb-3">
                  <p className="text-purple-600 font-medium text-sm">{b.name}</p>
                  <p className="text-sm text-muted-foreground">{b.description}</p>
                </div>
              ))}
              <h3 className="font-semibold text-sm mt-4 mb-2">타고난 살(煞)</h3>
              {data.curses.map((c) => (
                <div key={c.name} className="mb-3">
                  <p className="text-red-600 font-medium text-sm">{c.name}</p>
                  <p className="text-sm text-muted-foreground">{c.description}</p>
                </div>
              ))}
            </ScrollArea>
          </TabsContent>

          <TabsContent value="detail" className="mt-4 space-y-3">
            {data.details.map((item) => (
              <Card key={item.subject}>
                <CardHeader>
                  <CardTitle>{item.subject}</CardTitle>
                </CardHeader>
                <CardContent>
                  {item.premium ? (
                    <p className="text-sm text-purple-600">프리미엄 구독 시 확인 가능합니다.</p>
                  ) : (
                    <p className="text-sm text-muted-foreground">{item.text}</p>
                  )}
                </CardContent>
              </Card>
            ))}
          </TabsContent>
        </Tabs>
      </div>
    </>
  );
}
