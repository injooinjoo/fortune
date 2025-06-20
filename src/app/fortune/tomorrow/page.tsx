"use client";

import React from "react";
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

export default function TomorrowFortunePage() {
  // 내일 날짜 예시
  const dateLabel = "2025\uB144 6\uC6D4 21\uC77C \uD1A0\uC694\uC77C"; // 2025년 6월 21일 토요일
  const score = 88;
  const keywords = ["#기회", "#성장", "#조심"];
  const summary = "적극적인 도전이 행운을 부르지만 세심한 주의가 필요한 날입니다.";

  const details = [
    {
      id: "general",
      title: "총운",
      score: 88,
      description:
        "새로운 시도가 긍정적인 변화를 이끌 수 있지만 작은 실수에 유의하세요.",
      icon: Star,
    },
    {
      id: "love",
      title: "애정운",
      score: 82,
      description:
        "마음이 맞는 상대를 만날 가능성이 높습니다. 그러나 서두르지 말고 천천히 접근하세요.",
      icon: Heart,
    },
    {
      id: "career",
      title: "직업운",
      score: 78,
      description:
        "작은 실수로 큰 영향을 받을 수 있으니 세부사항을 꼼꼼히 확인하세요.",
      icon: Briefcase,
    },
    {
      id: "money",
      title: "금전운",
      score: 73,
      description:
        "예상치 못한 수입이 있지만 지출 계획을 세우는 것이 좋습니다.",
      icon: Coins,
    },
    {
      id: "health",
      title: "건강운",
      score: 92,
      description: "컨디션이 좋지만 무리하면 피로가 쌓일 수 있습니다.",
      icon: HeartPulse,
    },
  ];

  const advices = [
    "중요한 결정은 오전에 마무리하세요.",
    "작은 실수에 대비해 계획을 점검하세요.",
    "동료와 협력하면 예상보다 큰 성과를 얻습니다.",
  ];

  const lucky = {
    color: "\uB179\uC0C9", // 녹색
    number: 3,
    item: "\uD589\uC6B4\uC758 \uB3D9\uC804", // 행운의 동전
  };

  return (
    <div className="min-h-screen p-4 space-y-6">
      <Card>
        <CardHeader>
          <CardTitle as="h2" className="text-xl">
            {dateLabel}
          </CardTitle>
        </CardHeader>
        <CardContent className="text-center space-y-2">
          <div className="text-5xl font-bold">{score}\uC810</div>
          <div className="flex justify-center space-x-2">
            {keywords.map((k) => (
              <Badge key={k}>{k}</Badge>
            ))}
          </div>
          <p className="text-muted-foreground">{summary}</p>
        </CardContent>
      </Card>

      <section>
        <h3 className="text-lg font-semibold mb-2">세부 운세 분석</h3>
        <Accordion type="single" collapsible>
          {details.map((d) => {
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
                  <p className="text-sm text-muted-foreground">
                    {d.description}
                  </p>
                </AccordionContent>
              </AccordionItem>
            );
          })}
        </Accordion>
      </section>

      <section>
        <h3 className="text-lg font-semibold mb-2">내일의 조언</h3>
        <ul className="list-disc pl-5 space-y-1 text-sm text-muted-foreground">
          {advices.map((a, idx) => (
            <li key={idx}>{a}</li>
          ))}
        </ul>
      </section>

      <section>
        <h3 className="text-lg font-semibold mb-2">행운을 더해줄 아이템</h3>
        <div className="space-y-2 text-sm text-muted-foreground">
          <div className="flex items-center space-x-2">
            <Palette className="w-4 h-4" />
            <span>색상: {lucky.color}</span>
          </div>
          <div className="flex items-center space-x-2">
            <Hash className="w-4 h-4" />
            <span>숫자: {lucky.number}</span>
          </div>
          <div className="flex items-center space-x-2">
            <Gift className="w-4 h-4" />
            <span>아이템: {lucky.item}</span>
          </div>
        </div>
      </section>

      <div className="flex justify-between pt-4">
        <Button asChild variant="outline">
          <Link href="/fortune">목록으로</Link>
        </Button>

        <Dialog>
          <DialogTrigger asChild>
            <Button>공유하기</Button>
          </DialogTrigger>
          <DialogContent>
            <DialogHeader>
              <DialogTitle>공유하기</DialogTitle>
            </DialogHeader>
            <p className="text-sm text-muted-foreground">
              공유 기능은 준비 중입니다.
            </p>
          </DialogContent>
        </Dialog>
      </div>
    </div>
  );
}
