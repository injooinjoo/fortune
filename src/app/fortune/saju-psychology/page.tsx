"use client";

import { logger } from '@/lib/logger';
import React, { useState, useEffect } from "react";
import AppHeader from "@/components/AppHeader";
import {
  Tabs,
  TabsList,
  TabsTrigger,
  TabsContent,
} from "@/components/ui/tabs";
import { Card, CardHeader, CardTitle, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Brain, Loader2 } from "lucide-react";

interface PsychologyData {
  summary: string;
  personality: string;
  relationship: string;
  psyche: string;
  advice: string;
  generated_at?: string;
}

export default function SajuPsychologyPage() {
  const [data, setData] = useState<PsychologyData | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [fontSize, setFontSize] = useState<'small' | 'medium' | 'large'>('medium');

  useEffect(() => {
    const fetchPsychologyData = async () => {
      try {
        setLoading(true);
        setError(null);
        
        const response = await fetch('/api/fortune/saju-psychology');
        const result = await response.json();
        
        if (!response.ok) {
          throw new Error(result.error || '사주 심리분석을 불러오는데 실패했습니다.');
        }
        
        if (result.success && result.data) {
          setData(result.data);
        } else {
          throw new Error('데이터 형식이 올바르지 않습니다.');
        }
      } catch (err) {
        logger.error('사주 심리분석 로드 오류:', err);
        setError(err instanceof Error ? err.message : '알 수 없는 오류가 발생했습니다.');
      } finally {
        setLoading(false);
      }
    };

    fetchPsychologyData();
  }, []);

  if (loading) {
    return (
      <>
        <AppHeader
          title="사주 심리분석"
          onFontSizeChange={setFontSize}
          currentFontSize={fontSize}
        />
        <div className="pb-32 px-4 space-y-6 pt-4">
          <div className="flex items-center justify-center min-h-64">
            <div className="text-center space-y-4">
              <Loader2 className="w-8 h-8 animate-spin mx-auto text-primary" />
              <p className="text-muted-foreground">사주 심리분석을 불러오는 중...</p>
            </div>
          </div>
        </div>
      </>
    );
  }

  if (error) {
    return (
      <>
        <AppHeader
          title="사주 심리분석"
          onFontSizeChange={setFontSize}
          currentFontSize={fontSize}
        />
        <div className="pb-32 px-4 space-y-6 pt-4">
          <div className="text-center py-8">
            <p className="text-red-500 mb-4">{error}</p>
            <Button onClick={() => window.location.reload()}>
              다시 시도
            </Button>
          </div>
        </div>
      </>
    );
  }

  if (!data) {
    return (
      <>
        <AppHeader
          title="사주 심리분석"
          onFontSizeChange={setFontSize}
          currentFontSize={fontSize}
        />
        <div className="pb-32 px-4 space-y-6 pt-4">
          <div className="text-center py-8">
            <p className="text-muted-foreground">사주 심리분석 데이터가 없습니다.</p>
          </div>
        </div>
      </>
    );
  }

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
