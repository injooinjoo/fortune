"use client";

import React, { useState } from "react";
import AppHeader from "@/components/AppHeader";
import {
  Tabs,
  TabsList,
  TabsTrigger,
  TabsContent,
} from "@/components/ui/tabs";
import { Card, CardHeader, CardTitle, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Brain } from "lucide-react";

interface PsychologyData {
  summary: string;
  personality: string;
  relationship: string;
  psyche: string;
  advice: string;
}

const mockData: PsychologyData = {
  summary: "사주 오행의 균형이 뛰어나 다양한 상황에 유연하게 대응합니다.",
  personality:
    "타고난 성격은 온화하면서도 결단력이 있어 주변의 신뢰를 얻습니다. 논리적 사고와 감성적 직관을 적절히 활용해 문제를 해결하는 능력이 뛰어납니다.",
  relationship:
    "타인을 배려하는 마음이 강해 대인관계가 원만하지만, 때로는 지나친 책임감으로 부담을 느끼기도 합니다. 의사소통이 원활해 조율 능력이 뛰어납니다.",
  psyche:
    "내면에는 이상을 향한 열정이 있지만 동시에 현실을 중시하는 면모가 공존합니다. 감정을 드러내기보다는 스스로 조절하려 노력하며, 균형을 잃지 않으려 합니다.",
  advice:
    "자신의 감정을 솔직히 표현하고 휴식을 통해 심리적 에너지를 회복하세요. 타인의 기대에 맞추기보다는 스스로의 욕구를 살펴보는 시간이 필요합니다.",
};

export default function SajuPsychologyPage() {
  const data = mockData;
  const [fontSize, setFontSize] = useState<'small' | 'medium' | 'large'>('medium');

  return (
    <>
      <AppHeader
        title="사주 심리분석"
        onFontSizeChange={setFontSize}
        currentFontSize={fontSize}
      />
      <div className="pb-32 px-4 space-y-6 pt-4">
        <header className="p-4 rounded-md bg-teal-50 text-teal-700 flex items-center justify-center gap-2">
          <Brain className="w-5 h-5" />
          <h2 className="text-lg font-semibold">{data.summary}</h2>
        </header>

        <Tabs defaultValue="personality" className="w-full">
          <TabsList className="grid w-full grid-cols-4">
            <TabsTrigger value="personality">기본 성격</TabsTrigger>
            <TabsTrigger value="relationship">대인관계</TabsTrigger>
            <TabsTrigger value="psyche">내면 심리</TabsTrigger>
            <TabsTrigger value="advice">종합 조언</TabsTrigger>
          </TabsList>

          <TabsContent value="personality" className="mt-4">
            <p className="leading-relaxed text-sm text-muted-foreground">
              {data.personality}
            </p>
          </TabsContent>

          <TabsContent value="relationship" className="mt-4">
            <p className="leading-relaxed text-sm text-muted-foreground">
              {data.relationship}
            </p>
          </TabsContent>

          <TabsContent value="psyche" className="mt-4">
            <p className="leading-relaxed text-sm text-muted-foreground">
              {data.psyche}
            </p>
          </TabsContent>

          <TabsContent value="advice" className="mt-4">
            <p className="leading-relaxed text-sm text-muted-foreground">
              {data.advice}
            </p>
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
