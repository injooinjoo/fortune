"use client";

import React, { useState, useEffect } from "react";
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
import { ScrollText, Calendar, Sparkles, Loader2 } from "lucide-react";

interface MonthlyFortune {
  month: string;
  hexagram: string;
  summary: string;
  advice: string;
}

interface TojeongData {
  year: number;
  yearly_hexagram: string;
  total_fortune: string;
  monthly_fortunes: MonthlyFortune[];
}

export default function TojeongPage() {
  const [fontSize, setFontSize] = useState<'small' | 'medium' | 'large'>('medium');
  const [data, setData] = useState<TojeongData | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchTojeongFortune = async () => {
      try {
        setLoading(true);
        console.log('토정비결 데이터 요청 시작...');
        
        const response = await fetch('/api/fortune/tojeong', {
          method: 'GET',
          headers: {
            'Content-Type': 'application/json',
          },
        });

        if (!response.ok) {
          throw new Error(`운세 요청 실패: ${response.status}`);
        }

        const result = await response.json();
        console.log('토정비결 API 응답:', result);
        
        if (!result.success) {
          throw new Error(result.error || '토정비결 생성에 실패했습니다');
        }

        setData(result.data.tojeong);
        setError(null);
      } catch (err) {
        console.error('토정비결 API 오류:', err);
        setError(err instanceof Error ? err.message : '알 수 없는 오류가 발생했습니다.');
      } finally {
        setLoading(false);
      }
    };

    fetchTojeongFortune();
  }, []);

  if (loading) {
    return (
      <>
        <AppHeader title="토정비결" onFontSizeChange={setFontSize} currentFontSize={fontSize} />
        <div className="min-h-screen p-4 flex items-center justify-center">
          <div className="text-center">
            <Loader2 className="w-8 h-8 animate-spin mx-auto mb-4 text-yellow-600" />
            <p className="text-sm text-muted-foreground">토정비결을 생성하고 있습니다...</p>
          </div>
        </div>
      </>
    );
  }

  if (error) {
    return (
      <>
        <AppHeader title="토정비결" onFontSizeChange={setFontSize} currentFontSize={fontSize} />
        <div className="min-h-screen p-4 flex items-center justify-center">
          <div className="text-center">
            <p className="text-sm text-red-600 mb-4">{error}</p>
            <Button onClick={() => window.location.reload()}>다시 시도</Button>
          </div>
        </div>
      </>
    );
  }

  if (!data) {
    return (
      <>
        <AppHeader title="토정비결" onFontSizeChange={setFontSize} currentFontSize={fontSize} />
        <div className="min-h-screen p-4 flex items-center justify-center">
          <p className="text-sm text-muted-foreground">데이터를 불러올 수 없습니다.</p>
        </div>
      </>
    );
  }

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
            <p className="text-sm text-muted-foreground mb-2">주괘: {data.yearly_hexagram}</p>
            <p className="text-sm text-muted-foreground leading-relaxed">{data.total_fortune}</p>
          </CardContent>
        </Card>

        <section>
          <h3 className="text-lg font-semibold mb-2 flex items-center gap-2">
            <Calendar className="w-5 h-5 text-indigo-600" />
            월별 세운
          </h3>
          <Accordion type="single" collapsible>
            {data.monthly_fortunes.map((m: MonthlyFortune) => (
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
