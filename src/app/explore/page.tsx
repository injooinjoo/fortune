"use client";

import React, { useState } from "react";
import { useRouter } from "next/navigation";
import { Search, Star, Heart, Gem, Calendar, User, Hand, Smile, Bot, Brain } from "lucide-react";

import { Input } from "@/components/ui/input";
import { Tabs, TabsList, TabsTrigger, TabsContent } from "@/components/ui/tabs";
import { Card, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { cn } from "@/lib/utils";

interface FortuneItem {
  id: string;
  name: string;
  description: string;
  icon: React.ComponentType<{ className?: string }>;
  route: string;
}

const fortuneCategories: Record<string, { label: string; items: FortuneItem[] }> = {
  daily: {
    label: "데일리",
    items: [
      { id: "general", name: "오늘의 총운", description: "오늘의 총운을 확인하세요", icon: Star, route: "/fortune/daily" },
      { id: "love", name: "연애운", description: "오늘의 총운을 확인하세요", icon: Heart, route: "/fortune/love" },
      { id: "wealth", name: "재물운", description: "오늘의 총운을 확인하세요", icon: Gem, route: "/fortune/wealth" },
    ],
  },
  deep: {
    label: "심층 분석",
    items: [
      { id: "saju", name: "사주팔자", description: "오늘의 총운을 확인하세요", icon: Calendar, route: "/fortune/saju" },
      { id: "saju-psychology", name: "사주 심리분석", description: "성격과 관계 탐구", icon: Brain, route: "/fortune/saju-psychology" },
      { id: "mbti", name: "MBTI 운세", description: "오늘의 총운을 확인하세요", icon: User, route: "/fortune/mbti" },
    ],
  },
  interactive: {
    label: "인터랙티브",
    items: [
      { id: "compatibility", name: "AI 궁합", description: "오늘의 총운을 확인하세요", icon: Bot, route: "/fortune/compatibility" },
    ],
  },
  traditional: {
    label: "전통 점술",
    items: [
      { id: "face", name: "관상", description: "오늘의 총운을 확인하세요", icon: Smile, route: "/fortune/face" },
      { id: "palm", name: "손금", description: "오늘의 총운을 확인하세요", icon: Hand, route: "/fortune/palm" },
    ],
  },
};

export default function ExplorePage() {
  const router = useRouter();
  const [tab, setTab] = useState<string>("daily");

  const items = fortuneCategories[tab]?.items ?? [];

  return (
    <div className="p-4 space-y-4">
      <div className="relative">
        <Input placeholder="찾고 싶은 운세가 있나요? (예: 재물, 궁합)" className="pl-10" />
        <Search className="absolute left-3 top-1/2 h-5 w-5 -translate-y-1/2 text-muted-foreground" />
      </div>

      <Tabs value={tab} onValueChange={setTab} className="space-y-4">
        <TabsList className="grid w-full grid-cols-4">
          {Object.entries(fortuneCategories).map(([key, value]) => (
            <TabsTrigger key={key} value={key} className="text-sm">
              {value.label}
            </TabsTrigger>
          ))}
        </TabsList>
        {Object.entries(fortuneCategories).map(([key, value]) => (
          <TabsContent key={key} value={key}>
            <div className="grid grid-cols-2 sm:grid-cols-3 gap-4 pt-2">
              {value.items.map((item) => (
                <Card
                  key={item.id}
                  onClick={() => router.push(item.route)}
                  className="cursor-pointer hover:shadow-md transition-shadow text-center p-4"
                >
                  <CardHeader className="items-center">
                    <item.icon className="h-8 w-8 text-primary" />
                  </CardHeader>
                  <CardTitle className="text-base font-medium">{item.name}</CardTitle>
                  <CardDescription className="mt-1 text-sm">
                    {item.description}
                  </CardDescription>
                </Card>
              ))}
            </div>
          </TabsContent>
        ))}
      </Tabs>
    </div>
  );
}

