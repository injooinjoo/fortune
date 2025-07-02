"use client";

import React, { useState, useEffect } from "react";
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
  total_fortune?: string;
  totalFortune?: string; // 백워드 호환성
  elements: { subject: string; value: number }[];
  life_cycles?: {
    youth: string;
    middle: string;
    old: string;
  };
  lifeCycles?: { // 백워드 호환성
    youth: string;
    middle: string;
    old: string;
  };
  blessings: Blessing[];
  curses: Curse[];
  details: DetailItem[];
}

export default function TraditionalSajuPage() {
  const [data, setData] = useState<TraditionalSajuData | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [fontSize, setFontSize] = useState<'small' | 'medium' | 'large'>('medium');

  useEffect(() => {
    const fetchTraditionalSaju = async () => {
      try {
        setLoading(true);
        setError(null);
        
        const response = await fetch('/api/fortune/traditional-saju?userId=user_123');
        const result = await response.json();
        
        if (!response.ok) {
          throw new Error(result.error || '전통 사주를 가져오는 중 오류가 발생했습니다.');
        }
        
        if (result.success && result.data) {
          // API 응답 구조에 맞게 데이터 변환
          const traditionSajuData = result.data['traditional-saju'] || result.data;
          setData(traditionSajuData);
        } else {
          throw new Error('데이터를 찾을 수 없습니다.');
        }
      } catch (err) {
        console.error('❌ 전통 사주 데이터 로딩 실패:', err);
        setError(err instanceof Error ? err.message : '알 수 없는 오류가 발생했습니다.');
      } finally {
        setLoading(false);
      }
    };

    fetchTraditionalSaju();
  }, []);

  if (loading) {
    return (
      <>
        <AppHeader title="전통 사주" onFontSizeChange={setFontSize} currentFontSize={fontSize} />
        <div className="pb-32 px-4 pt-4 flex items-center justify-center min-h-[400px]">
          <div className="text-center space-y-3">
            <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-purple-600 mx-auto"></div>
            <p className="text-sm text-muted-foreground">전통 사주를 분석하고 있습니다...</p>
          </div>
        </div>
      </>
    );
  }

  if (error || !data) {
    return (
      <>
        <AppHeader title="전통 사주" onFontSizeChange={setFontSize} currentFontSize={fontSize} />
        <div className="pb-32 px-4 pt-4 flex items-center justify-center min-h-[400px]">
          <div className="text-center space-y-3">
            <p className="text-sm text-red-600">{error}</p>
            <button 
              onClick={() => window.location.reload()}
              className="px-4 py-2 bg-purple-600 text-white rounded-md text-sm hover:bg-purple-700"
            >
              다시 시도
            </button>
          </div>
        </div>
      </>
    );
  }

  // 백워드 호환성을 위한 데이터 변환
  const totalFortune = data.total_fortune || data.totalFortune || "전통 사주 분석이 완료되었습니다.";
  const lifeCycles = data.life_cycles || data.lifeCycles || {
    youth: "초년운이 분석 중입니다.",
    middle: "중년운이 분석 중입니다.", 
    old: "말년운이 분석 중입니다."
  };

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
              {totalFortune}
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
                <p className="text-sm text-muted-foreground">{lifeCycles.youth}</p>
              </CardContent>
            </Card>
            <Card>
              <CardHeader>
                <CardTitle>중년운</CardTitle>
              </CardHeader>
              <CardContent>
                <p className="text-sm text-muted-foreground">{lifeCycles.middle}</p>
              </CardContent>
            </Card>
            <Card>
              <CardHeader>
                <CardTitle>말년운</CardTitle>
              </CardHeader>
              <CardContent>
                <p className="text-sm text-muted-foreground">{lifeCycles.old}</p>
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
