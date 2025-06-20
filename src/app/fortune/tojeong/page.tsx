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
import AppHeader from "@/components/AppHeader";
import { ScrollText, Calendar, Sparkles } from "lucide-react";

interface MonthlyFortune {
  month: string;
  hexagram: string;
  summary: string;
  advice: string;
}

interface TojeongData {
  year: number;
  yearlyHexagram: string;
  totalFortune: string;
  monthly: MonthlyFortune[];
}

const data: TojeongData = {
  year: 2025,
  yearlyHexagram: "천지비(天地否)",
  totalFortune:
    "새로운 도전보다 준비에 힘써야 하는 시기입니다. 주변의 충고를 경청하면 큰 어려움 없이 한 해를 보낼 수 있습니다.",
  monthly: [
    { month: "1월", hexagram: "천풍구", summary: "새로운 인연이 다가옵니다.", advice: "만남을 두려워하지 마세요." },
    { month: "2월", hexagram: "지택림", summary: "작은 성과가 이어집니다.", advice: "꾸준함을 유지하세요." },
    { month: "3월", hexagram: "산수몽", summary: "결단이 필요한 달입니다.", advice: "주저하지 말고 선택하세요." },
    { month: "4월", hexagram: "풍천소축", summary: "기쁜 소식이 찾아옵니다.", advice: "겸손함을 잃지 마세요." },
    { month: "5월", hexagram: "지수사", summary: "움직임보다 기다림이 유리합니다.", advice: "성급한 행동을 삼가세요." },
    { month: "6월", hexagram: "산천대축", summary: "성장 기운이 높습니다.", advice: "배움에 힘쓰면 보답이 있습니다." },
    { month: "7월", hexagram: "택산함", summary: "주변과의 협력이 중요합니다.", advice: "협동심을 발휘하세요." },
    { month: "8월", hexagram: "천수송", summary: "지출이 늘어날 수 있습니다.", advice: "금전 관리를 철저히 하세요." },
    { month: "9월", hexagram: "지화명이", summary: "관계가 원만해지는 달입니다.", advice: "감사를 표현하세요." },
    { month: "10월", hexagram: "풍뢰익", summary: "노력한 만큼 결과가 옵니다.", advice: "포기하지 마세요." },
    { month: "11월", hexagram: "택화혁", summary: "변화의 기운이 강합니다.", advice: "새로운 계획을 세우세요." },
    { month: "12월", hexagram: "천택리", summary: "한 해를 정리할 시기입니다.", advice: "성과를 돌아보며 쉬어가세요." },
  ],
};

export default function TojeongPage() {
  const [fontSize, setFontSize] = useState<'small' | 'medium' | 'large'>('medium');

  return (
    <>
      <AppHeader title="토정비결" onFontSizeChange={setFontSize} currentFontSize={fontSize} />
      <div className="min-h-screen p-4 space-y-6 pb-32">
        <Card className="bg-gradient-to-br from-yellow-50 to-orange-50 border-yellow-200">
          <CardHeader>
            <CardTitle className="flex items-center gap-2 text-yellow-700">
              <ScrollText className="w-5 h-5" />
              {data.year}년 총운
            </CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-sm text-muted-foreground mb-2">주괘: {data.yearlyHexagram}</p>
            <p className="text-sm text-muted-foreground leading-relaxed">{data.totalFortune}</p>
          </CardContent>
        </Card>

        <section>
          <h3 className="text-lg font-semibold mb-2 flex items-center gap-2">
            <Calendar className="w-5 h-5 text-indigo-600" />
            월별 세운
          </h3>
          <Accordion type="single" collapsible>
            {data.monthly.map((m) => (
              <AccordionItem key={m.month} value={m.month}>
                <AccordionTrigger className="text-left">
                  <div className="flex items-center gap-2">
                    <Badge variant="secondary" className="text-sm">
                      {m.month}
                    </Badge>
                    <span className="ml-2 text-sm text-muted-foreground">{m.hexagram}</span>
                  </div>
                </AccordionTrigger>
                <AccordionContent className="space-y-2">
                  <p className="text-sm text-muted-foreground">{m.summary}</p>
                  <p className="text-sm text-gray-600">조언: {m.advice}</p>
                </AccordionContent>
              </AccordionItem>
            ))}
          </Accordion>
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
              <p className="text-sm text-muted-foreground">공유 기능은 준비 중입니다.</p>
            </DialogContent>
          </Dialog>
        </div>
      </div>
    </>
  );
}
