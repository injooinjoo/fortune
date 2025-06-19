"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { ScrollArea, ScrollBar } from "@/components/ui/scroll-area";
import { auth } from "@/lib/supabase";
import { Sparkles, Camera, BookOpen } from "lucide-react";

interface PersonalizedFortune {
  id: string;
  title: string;
  description: string;
  route: string;
}

const personalizedFortunes: PersonalizedFortune[] = [
  { id: "mbti", title: "MBTI 주간 운세", description: "당신의 성격 유형을 위한 주간 조언", route: "/fortune/mbti" },
  { id: "zodiac", title: "별자리 월간 운세", description: "별이 알려주는 이번 달 흐름", route: "/fortune/zodiac" },
  { id: "saju", title: "사주 궁합", description: "상대와의 궁합을 확인해보세요", route: "/fortune/saju" },
];

export default function HomePage() {
  const router = useRouter();
  const [name, setName] = useState<string>("사용자");

  useEffect(() => {
    const { data: { subscription } } = auth.onAuthStateChanged((currentUser: any) => {
      if (!currentUser) {
        router.push("/auth/selection");
      } else {
        const stored = localStorage.getItem("userProfile");
        if (stored) {
          try {
            const profile = JSON.parse(stored);
            setName(profile.name);
          } catch {
            setName(currentUser.user_metadata?.name || "사용자");
          }
        } else {
          setName(currentUser.user_metadata?.name || "사용자");
        }
      }
    });

    return () => subscription?.unsubscribe();
  }, [router]);

  const today = {
    score: 85,
    keywords: ["도전", "결실"],
    summary: "새로운 시도가 좋은 결과로 이어지는 날입니다.",
  };

  return (
    <div className="min-h-screen bg-background text-foreground p-4 space-y-6">
      <header>
        <h2 className="text-2xl font-bold">{name}님, 반가워요!</h2>
      </header>

      <Link href="/fortune/today" className="block">
        <Card className="hover:shadow-md transition-shadow">
          <CardHeader>
            <CardTitle>오늘의 운세</CardTitle>
            <CardDescription>총운 {today.score}점</CardDescription>
          </CardHeader>
          <CardContent className="space-y-2">
            <div className="flex gap-2">
              {today.keywords.map((k) => (
                <Badge key={k} variant="secondary">#{k}</Badge>
              ))}
            </div>
            <p>{today.summary}</p>
          </CardContent>
        </Card>
      </Link>

      <section>
        <h3 className="text-lg font-semibold mb-2">나를 위한 맞춤 운세</h3>
        <ScrollArea className="whitespace-nowrap -mx-4 pb-2">
          <div className="flex space-x-3 px-4">
            {personalizedFortunes.map((item) => (
              <Link key={item.id} href={item.route} className="block min-w-[12rem]">
                <Card className="h-full hover:shadow-md transition-shadow">
                  <CardHeader className="pb-2">
                    <CardTitle className="text-sm">{item.title}</CardTitle>
                  </CardHeader>
                  <CardContent className="text-sm text-muted-foreground">
                    {item.description}
                  </CardContent>
                </Card>
              </Link>
            ))}
          </div>
          <ScrollBar orientation="horizontal" />
        </ScrollArea>
      </section>

      <section>
        <h3 className="text-lg font-semibold mb-2">자주 찾는 메뉴</h3>
        <div className="grid grid-cols-3 gap-2">
          <Link href="/tarot">
            <Button variant="outline" className="w-full flex-col py-4">
              <Sparkles className="mb-1" />
              타로카드
            </Button>
          </Link>
          <Link href="/physiognomy">
            <Button variant="outline" className="w-full flex-col py-4">
              <Camera className="mb-1" />
              관상 분석
            </Button>
          </Link>
          <Link href="/dream">
            <Button variant="outline" className="w-full flex-col py-4">
              <BookOpen className="mb-1" />
              꿈해몽
            </Button>
          </Link>
        </div>
      </section>

      <section>
        <h3 className="text-lg font-semibold mb-2">지금 당신의 고민은?</h3>
        <div className="flex flex-wrap gap-2">
          <Link href="/fortune/love"><Badge variant="secondary" className="px-3 py-2">연애운</Badge></Link>
          <Link href="/fortune/career"><Badge variant="secondary" className="px-3 py-2">취업운</Badge></Link>
          <Link href="/fortune/wealth"><Badge variant="secondary" className="px-3 py-2">금전운</Badge></Link>
        </div>
      </section>
    </div>
  );
}
