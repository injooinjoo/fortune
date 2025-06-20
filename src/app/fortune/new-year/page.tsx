"use client";

import { useState } from "react";
import AppHeader from "@/components/AppHeader";
import { Card, CardHeader, CardTitle, CardContent } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import {
  Accordion,
  AccordionContent,
  AccordionItem,
  AccordionTrigger,
} from "@/components/ui/accordion";
import { PartyPopper, Coins, Heart, HeartPulse } from "lucide-react";

interface MonthlyFortune {
  month: string;
  text: string;
}

interface TopicFortune {
  id: string;
  title: string;
  text: string;
  icon: React.ComponentType<{ className?: string }>;
}

export default function NewYearFortunePage() {
  const [fontSize, setFontSize] = useState<'small' | 'medium' | 'large'>('medium');

  const general = {
    score: 86,
    summary: "새로운 도전과 변화가 행운을 가져오는 한 해입니다.",
    keywords: ["#도약", "#새로운기회", "#성장"],
  };

  const monthlyFortunes: MonthlyFortune[] = [
    { month: "1월", text: "새해 계획을 세우고 준비를 탄탄히 해야 합니다." },
    { month: "2월", text: "주변과의 협력이 중요한 시기입니다." },
    { month: "3월", text: "새로운 만남이 기회를 가져옵니다." },
    { month: "4월", text: "일의 진행이 다소 더디지만 꾸준히 나아가세요." },
    { month: "5월", text: "금전 운이 상승세를 보입니다." },
    { month: "6월", text: "사소한 갈등을 피하면 순조롭습니다." },
    { month: "7월", text: "휴식과 재충전에 신경 쓰세요." },
    { month: "8월", text: "중요한 결정은 신중하게 내리세요." },
    { month: "9월", text: "그동안의 노력이 결실을 맺기 시작합니다." },
    { month: "10월", text: "인맥을 넓히기에 좋은 달입니다." },
    { month: "11월", text: "몸과 마음의 균형을 유지하세요." },
    { month: "12월", text: "한 해를 정리하며 성과가 나타납니다." },
  ];

  const topicFortunes: TopicFortune[] = [
    {
      id: "wealth",
      title: "재물운",
      text: "안정적인 저축과 장기 투자가 유리합니다.",
      icon: Coins,
    },
    {
      id: "love",
      title: "애정운",
      text: "배려와 소통이 관계를 돈독하게 합니다.",
      icon: Heart,
    },
    {
      id: "health",
      title: "건강운",
      text: "규칙적인 생활 습관을 유지하세요.",
      icon: HeartPulse,
    },
  ];

  return (
    <>
      <AppHeader
        title="신년운세"
        onFontSizeChange={setFontSize}
        currentFontSize={fontSize}
      />
      <div className="pb-32 px-4 space-y-6 pt-4">
        <Card className="bg-gradient-to-br from-indigo-50 to-blue-50 border-indigo-200">
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <PartyPopper className="w-5 h-5 text-indigo-600" />
              2025년 종합 운세
            </CardTitle>
          </CardHeader>
          <CardContent className="space-y-2">
            <div className="flex items-center space-x-2">
              {general.keywords.map((k) => (
                <Badge key={k}>{k}</Badge>
              ))}
            </div>
            <p className="text-sm text-muted-foreground">{general.summary}</p>
          </CardContent>
        </Card>

        <section>
          <h2 className="text-lg font-semibold mb-2">월별 운세</h2>
          <Accordion type="single" collapsible className="space-y-1">
            {monthlyFortunes.map((m) => (
              <AccordionItem key={m.month} value={m.month}>
                <AccordionTrigger>{m.month}</AccordionTrigger>
                <AccordionContent>
                  <p className="text-sm text-muted-foreground">{m.text}</p>
                </AccordionContent>
              </AccordionItem>
            ))}
          </Accordion>
        </section>

        <section className="space-y-4">
          <h2 className="text-lg font-semibold">주제별 상세 운세</h2>
          {topicFortunes.map((t) => {
            const Icon = t.icon;
            return (
              <Card key={t.id}>
                <CardHeader>
                  <CardTitle className="flex items-center gap-2">
                    <Icon className="w-5 h-5 text-indigo-600" />
                    {t.title}
                  </CardTitle>
                </CardHeader>
                <CardContent>
                  <p className="text-sm text-muted-foreground">{t.text}</p>
                </CardContent>
              </Card>
            );
          })}
        </section>
      </div>
    </>
  );
}
