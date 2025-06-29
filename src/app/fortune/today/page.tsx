"use client";

import React, { useState } from "react";
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
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog";
import {
  Star,
  Heart,
  Briefcase,
  Coins,
  HeartPulse,
  Palette,
  Gift,
  Hash,
} from "lucide-react";
import AppHeader from "@/components/AppHeader";

export default function TodayFortunePage() {
  const [fontSize, setFontSize] = useState<'small'|'medium'|'large'>('medium');
  const dateLabel = "2025년 6월 20일 금요일";
  const score = 85;
  const keywords = ["#도전", "#긍정", "#결실"];
  const summary = "새로운 시도가 좋은 결과로 이어지는 날입니다.";

  const details = [
    {
      id: "general",
      title: "총운",
      score: 85,
      description:
        "당신의 노력이 결실을 맺고 주변의 도움이 따릅니다. 적극적으로 움직일수록 운이 상승합니다.",
      icon: Star,
    },
    {
      id: "love",
      title: "애정운",
      score: 80,
      description:
        "솔로라면 좋은 인연을 만날 수 있습니다. 커플은 서로에 대한 배려가 필요한 시기입니다.",
      icon: Heart,
    },
    {
      id: "career",
      title: "직업운",
      score: 75,
      description:
        "새로운 책임이 주어지지만 기회로 삼는다면 성장할 수 있습니다.",
      icon: Briefcase,
    },
    {
      id: "money",
      title: "금전운",
      score: 70,
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
  ];

  const advices = [
    "중요한 일은 오전에 처리하세요.",
    "주변 사람들의 조언을 귀담아 들으세요.",
    "새로운 일에 과감히 도전해 보세요.",
  ];

  const lucky = {
    color: "파랑",
    number: 7,
    item: "작은 노트",
  };

  return (
    <div className="min-h-screen pb-32 px-4 space-y-6 bg-gradient-to-br from-emerald-50 to-teal-50 dark:from-gray-900 dark:to-gray-800">
      <AppHeader title="오늘의 운세" onFontSizeChange={setFontSize} currentFontSize={fontSize} />
      <Card className="border-emerald-200 dark:border-gray-700 bg-white/80 dark:bg-gray-800/80 backdrop-blur-sm">
        <CardHeader>
          <CardTitle className="text-xl text-gray-900 dark:text-gray-100">
            {dateLabel}
          </CardTitle>
        </CardHeader>
        <CardContent className="text-center space-y-2">
          <div className="text-5xl font-bold text-emerald-600 dark:text-emerald-400">{score}점</div>
          <div className="flex justify-center space-x-2">
            {keywords.map((k) => (
              <Badge key={k} className="bg-emerald-100 text-emerald-800 dark:bg-emerald-900 dark:text-emerald-200">{k}</Badge>
            ))}
          </div>
          <p className="text-gray-600 dark:text-gray-300">{summary}</p>
        </CardContent>
      </Card>

      <section>
        <h3 className="text-lg font-semibold mb-2 text-gray-900 dark:text-gray-100">세부 운세 분석</h3>
        <Accordion type="single" collapsible className="bg-white/60 dark:bg-gray-800/60 rounded-lg border border-emerald-200 dark:border-gray-700">
          {details.map((d) => {
            const Icon = d.icon;
            return (
              <AccordionItem key={d.id} value={d.id} className="border-emerald-100 dark:border-gray-700">
                <AccordionTrigger className="text-left hover:bg-emerald-50 dark:hover:bg-gray-700 px-4">
                  <div className="flex items-center space-x-2">
                    <Icon className="w-4 h-4 text-emerald-600 dark:text-emerald-400" />
                    <span className="text-gray-900 dark:text-gray-100">{d.title}</span>
                    <span className="ml-2 text-sm text-emerald-600 dark:text-emerald-400 font-medium">
                      {d.score}점
                    </span>
                  </div>
                </AccordionTrigger>
                <AccordionContent className="px-4">
                  <p className="text-sm text-gray-600 dark:text-gray-300">
                    {d.description}
                  </p>
                </AccordionContent>
              </AccordionItem>
            );
          })}
        </Accordion>
      </section>

      <section>
        <h3 className="text-lg font-semibold mb-2 text-gray-900 dark:text-gray-100">오늘의 조언</h3>
        <div className="bg-white/60 dark:bg-gray-800/60 rounded-lg border border-emerald-200 dark:border-gray-700 p-4">
          <ul className="list-disc pl-5 space-y-1 text-sm text-gray-600 dark:text-gray-300">
            {advices.map((a, idx) => (
              <li key={idx}>{a}</li>
            ))}
          </ul>
        </div>
      </section>

      <section>
        <h3 className="text-lg font-semibold mb-2 text-gray-900 dark:text-gray-100">행운을 더해줄 아이템</h3>
        <div className="bg-white/60 dark:bg-gray-800/60 rounded-lg border border-emerald-200 dark:border-gray-700 p-4">
          <div className="space-y-3 text-sm">
            <div className="flex items-center space-x-3">
              <Palette className="w-5 h-5 text-emerald-600 dark:text-emerald-400" />
              <span className="text-gray-900 dark:text-gray-100 font-medium">색상:</span>
              <span className="text-emerald-700 dark:text-emerald-300 font-semibold">{lucky.color}</span>
            </div>
            <div className="flex items-center space-x-3">
              <Hash className="w-5 h-5 text-emerald-600 dark:text-emerald-400" />
              <span className="text-gray-900 dark:text-gray-100 font-medium">숫자:</span>
              <span className="text-emerald-700 dark:text-emerald-300 font-semibold">{lucky.number}</span>
            </div>
            <div className="flex items-center space-x-3">
              <Gift className="w-5 h-5 text-emerald-600 dark:text-emerald-400" />
              <span className="text-gray-900 dark:text-gray-100 font-medium">아이템:</span>
              <span className="text-emerald-700 dark:text-emerald-300 font-semibold">{lucky.item}</span>
            </div>
          </div>
        </div>
      </section>

      <div className="flex justify-start pt-4">
        <Button asChild variant="outline" className="border-emerald-300 text-emerald-700 hover:bg-emerald-50 dark:border-emerald-600 dark:text-emerald-300 dark:hover:bg-emerald-900/20">
          <Link href="/fortune">목록으로</Link>
        </Button>
      </div>
    </div>
  );
}
