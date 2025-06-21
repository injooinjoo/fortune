"use client";

import React from "react";
import AppHeader from "@/components/AppHeader";
import Link from "next/link";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import {
  Accordion,
  AccordionContent,
  AccordionItem,
  AccordionTrigger,
} from "@/components/ui/accordion";
import { Button } from "@/components/ui/button";
import {
  Heart,
  Coins,
  HeartPulse,
  Star,
  Palette,
  Gift,
  Hash,
} from "lucide-react";

// TODO: Replace with API call to fetch daily fortune based on user's saju
const mockData = {
  dateLabel: "2025\uB144 6\uC6D4 20\uC77C \uAE08\uC694\uC77C", // 2025년 6월 20일 금요일
  score: 88,
  keywords: ["도전", "긍정", "결실"],
  summary: "새로운 시도가 좋은 결과로 이어지는 날입니다.",
  details: [
    {
      id: "general",
      title: "총운",
      score: 88,
      description:
        "당신의 노력이 결실을 맺고 주변의 도움이 따릅니다. 적극적으로 움직일수록 운이 상승합니다.",
      icon: Star,
    },
    {
      id: "love",
      title: "애정운",
      score: 84,
      description:
        "솔로라면 좋은 인연을 만날 수 있습니다. 커플은 서로에 대한 배려가 필요한 시기입니다.",
      icon: Heart,
    },
    {
      id: "money",
      title: "재물운",
      score: 76,
      description:
        "예상치 못한 지출이 생길 수 있으니 계획적인 소비가 필요합니다.",
      icon: Coins,
    },
    {
      id: "health",
      title: "건강운",
      score: 90,
      description: "에너지 넘치는 하루지만 과로하지 않도록 주의하세요.",
      icon: HeartPulse,
    },
  ],
  advices: [
    "중요한 일은 오전에 처리하세요.",
    "주변 사람들의 조언을 귀담아 들으세요.",
    "새로운 일에 과감히 도전해 보세요.",
  ],
  lucky: {
    color: "\uD30C\uB780", // 파랑
    number: 7,
    item: "\uC791\uC740 \uB178\uD2B8", // 작은 노트
  },
};

export default function DailyFortunePage() {
  const data = mockData;
  return (
    <div className="min-h-screen pb-32 px-4 space-y-6 bg-gradient-to-br from-purple-50 via-white to-indigo-50 dark:from-gray-900 dark:via-gray-800 dark:to-gray-700">
      <AppHeader title="오늘의 운세" />

      <Card>
        <CardHeader>
          <CardTitle className="text-xl">
            {data.dateLabel}
          </CardTitle>
        </CardHeader>
        <CardContent className="text-center space-y-2">
          <div className="text-5xl font-bold text-purple-700">{data.score}\uC810</div>
          <div className="flex justify-center space-x-2">
            {data.keywords.map((k) => (
              <Badge key={k} className="text-sm">
                #{k}
              </Badge>
            ))}
          </div>
          <p className="text-muted-foreground">{data.summary}</p>
        </CardContent>
      </Card>

      <section>
        <h3 className="text-lg font-semibold mb-2">세부 운세 분석</h3>
        <Accordion type="single" collapsible>
          {data.details.map((d) => {
            const Icon = d.icon;
            return (
              <AccordionItem key={d.id} value={d.id}>
                <AccordionTrigger className="text-left">
                  <div className="flex items-center space-x-2">
                    <Icon className="w-4 h-4" />
                    <span>{d.title}</span>
                    <span className="ml-2 text-sm text-muted-foreground">
                      {d.score}\uC810
                    </span>
                  </div>
                </AccordionTrigger>
                <AccordionContent>
                  <p className="text-sm text-muted-foreground">{d.description}</p>
                </AccordionContent>
              </AccordionItem>
            );
          })}
        </Accordion>
      </section>

      <section>
        <h3 className="text-lg font-semibold mb-2">오늘의 조언</h3>
        <ul className="list-disc pl-5 space-y-1 text-sm text-muted-foreground">
          {data.advices.map((a, idx) => (
            <li key={idx}>{a}</li>
          ))}
        </ul>
      </section>

      <section>
        <h3 className="text-lg font-semibold mb-2">행운을 더해줄 아이템</h3>
        <div className="space-y-2 text-sm text-muted-foreground">
          <div className="flex items-center space-x-2">
            <Palette className="w-4 h-4" />
            <span>색상: {data.lucky.color}</span>
          </div>
          <div className="flex items-center space-x-2">
            <Hash className="w-4 h-4" />
            <span>숫자: {data.lucky.number}</span>
          </div>
          <div className="flex items-center space-x-2">
            <Gift className="w-4 h-4" />
            <span>아이템: {data.lucky.item}</span>
          </div>
        </div>
      </section>

      <div className="flex justify-between pt-4">
        <Button asChild variant="outline">
          <Link href="/fortune">목록으로</Link>
        </Button>
      </div>
    </div>
  );
}
