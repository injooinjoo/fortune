"use client";

import { useEffect } from "react";
import Link from "next/link";
import { useQuery } from "@tanstack/react-query";
import { Card, CardHeader, CardTitle, CardContent } from "@/components/ui/card";
import { Skeleton } from "@/components/ui/skeleton";
import AppHeader from "@/components/AppHeader";
import { Sun, BookOpen, Heart, Coins } from "lucide-react";
import useUserStore from "@/store/user-store";

interface HomeSummary {
  welcomeMessage: string;
  todaySummary: string;
}

const shortcuts = [
  { href: "/fortune/today", icon: Sun, label: "오늘의 운세" },
  { href: "/fortune/saju", icon: BookOpen, label: "사주" },
  { href: "/fortune/love", icon: Heart, label: "애정운" },
  { href: "/fortune/wealth", icon: Coins, label: "재물운" },
];

export default function HomePage() {
  const { name, mbti, setUser } = useUserStore();

  useEffect(() => {
    if (!name && typeof window !== "undefined") {
      const stored = localStorage.getItem("userProfile");
      if (stored) {
        try {
          const profile = JSON.parse(stored);
          setUser(profile.name || "", profile.mbti || "");
        } catch {
          // ignore
        }
      }
    }
  }, [name, setUser]);

  const { data, isLoading } = useQuery<HomeSummary>(
    ["home-summary", name, mbti],
    async () => {
      const res = await fetch("/api/fortune/home-summary");
      if (!res.ok) throw new Error("Failed to load");
      return res.json();
    },
    {
      enabled: !!name && !!mbti,
    }
  );

  return (
    <div className="min-h-screen bg-background pb-20">
      <AppHeader title="홈" />
      <div className="p-6 space-y-6">
        {isLoading || !data ? (
          <div className="space-y-4">
            <Skeleton className="h-8 w-2/3" />
            <Skeleton className="h-24 w-full" />
          </div>
        ) : (
          <>
            <h1 className="text-2xl font-bold leading-snug">
              {data.welcomeMessage}
            </h1>
            <section>
              <Card>
                <CardHeader>
                  <CardTitle>오늘의 핵심 운세</CardTitle>
                </CardHeader>
                <CardContent>
                  <p>{data.todaySummary}</p>
                </CardContent>
              </Card>
            </section>
          </>
        )}

        <section>
          <h2 className="text-lg font-semibold mb-3">나의 운세 탐험하기</h2>
          <div className="grid grid-cols-2 gap-4">
            {shortcuts.map((item) => (
              <Link href={item.href} key={item.href} className="block">
                <Card className="flex flex-col items-center py-6 hover:bg-muted/50">
                  <item.icon className="w-8 h-8 mb-2 text-primary" />
                  <span className="text-sm font-medium">{item.label}</span>
                </Card>
              </Link>
            ))}
          </div>
        </section>
      </div>
    </div>
  );
}
