"use client";

import React, { useState, useEffect } from "react";
import AppHeader from "@/components/AppHeader";
import { Tabs, TabsList, TabsTrigger, TabsContent } from "@/components/ui/tabs";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Droplet } from "lucide-react";
import { useAuth } from '@/contexts/auth-context';
import {
  RadarChart,
  PolarGrid,
  PolarAngleAxis,
  PolarRadiusAxis,
  Radar,
  ResponsiveContainer,
} from "recharts";

interface TalentReport {
  summary: string;
  elements: { subject: string; value: number }[];
  strengths: string[];
  weaknesses: string[];
  recommended_fields: string[];
  growth_tips: string[];
  skill_analysis: {
    analytical: number;
    creative: number;
    leadership: number;
    communication: number;
    focus: number;
  };
  potential_score: number;
  development_phases: Array<{
    phase: string;
    description: string;
    focus: string;
  }>;
}

export default function TalentPage() {
  const { session } = useAuth();
  const [fontSize, setFontSize] = useState<'small' | 'medium' | 'large'>('medium');
  const [data, setData] = useState<TalentReport | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchTalentData = async () => {
      try {
        setLoading(true);
        
        // AuthContext에서 세션 가져오기
        console.log('세션 상태:', session ? '로그인됨' : '미로그인');
        
        const response = await fetch('/api/fortune/talent', {
          method: 'GET',
          headers: {
            'Content-Type': 'application/json',
            ...(session?.access_token && {
              'Authorization': `Bearer ${session.access_token}`
            })
          },
        });
        
        if (!response.ok) {
          if (response.status === 401) {
            throw new Error('로그인이 필요합니다.');
          }
          throw new Error('재능 운세 데이터를 가져오는데 실패했습니다.');
        }
        
        const result = await response.json();
        
        if (result.success && result.data) {
          setData(result.data);
        } else {
          throw new Error('재능 운세 데이터가 올바르지 않습니다.');
        }
      } catch (err) {
        console.error('재능 운세 로드 오류:', err);
        setError(err instanceof Error ? err.message : '알 수 없는 오류가 발생했습니다.');
      } finally {
        setLoading(false);
      }
    };

    fetchTalentData();
  }, [session]);

  if (loading) {
    return (
      <>
        <AppHeader title="능력 평가" />
        <div className="pb-32 px-4 pt-4 flex items-center justify-center min-h-[400px]">
          <div className="text-center">
            <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-green-600 mx-auto mb-4"></div>
            <p className="text-muted-foreground">재능 분석 중...</p>
          </div>
        </div>
      </>
    );
  }

  if (error || !data) {
    return (
      <>
        <AppHeader title="능력 평가" />
        <div className="pb-32 px-4 pt-4 flex items-center justify-center min-h-[400px]">
          <div className="text-center">
            <p className="text-red-600 mb-2">⚠️ 오류가 발생했습니다</p>
            <p className="text-muted-foreground text-sm">{error}</p>
          </div>
        </div>
      </>
    );
  }

  return (
    <>
      <AppHeader
        title="능력 평가"
        onFontSizeChange={setFontSize}
        currentFontSize={fontSize}
      />
      <div className="pb-32 px-4 space-y-6 pt-4">
        <header className="p-4 rounded-md bg-green-50 text-green-700 flex items-center justify-center gap-2">
          <Droplet className="w-5 h-5" />
          <h2 className="text-lg font-semibold">{data.summary}</h2>
        </header>

        <Tabs defaultValue="general" className="w-full">
          <TabsList className="grid w-full grid-cols-4">
            <TabsTrigger value="general">종합</TabsTrigger>
            <TabsTrigger value="strength">강점</TabsTrigger>
            <TabsTrigger value="weakness">약점</TabsTrigger>
            <TabsTrigger value="apply">활용법</TabsTrigger>
          </TabsList>

          <TabsContent value="general" className="mt-4">
            <div className="w-full h-64">
              <ResponsiveContainer width="100%" height="100%">
                <RadarChart data={data.elements} outerRadius="80%">
                  <PolarGrid />
                  <PolarAngleAxis dataKey="subject" />
                  <PolarRadiusAxis angle={30} domain={[0, 100]} />
                  <Radar
                    name="재능"
                    dataKey="value"
                    stroke="#10b981"
                    fill="#10b981"
                    fillOpacity={0.6}
                  />
                </RadarChart>
              </ResponsiveContainer>
            </div>
          </TabsContent>

          <TabsContent value="strength" className="mt-4 space-y-3">
            {data.strengths.map((item, index) => (
              <Card key={index}>
                <CardContent className="p-4 text-sm text-muted-foreground">
                  {item}
                </CardContent>
              </Card>
            ))}
          </TabsContent>

          <TabsContent value="weakness" className="mt-4 space-y-3">
            {data.weaknesses.map((item, index) => (
              <Card key={index}>
                <CardContent className="p-4 text-sm text-muted-foreground">
                  {item}
                </CardContent>
              </Card>
            ))}
          </TabsContent>

          <TabsContent value="apply" className="mt-4 space-y-6">
            <div className="space-y-3">
              <Card>
                <CardHeader>
                  <CardTitle>추천 분야</CardTitle>
                </CardHeader>
                <CardContent className="space-y-2">
                  {data.recommended_fields.map((field: string, index: number) => (
                    <p key={index} className="text-sm text-muted-foreground">
                      • {field}
                    </p>
                  ))}
                </CardContent>
              </Card>
              <Card>
                <CardHeader>
                  <CardTitle>성장 팁</CardTitle>
                </CardHeader>
                <CardContent className="space-y-2">
                  {data.growth_tips.map((tip: string, index: number) => (
                    <p key={index} className="text-sm text-muted-foreground">
                      • {tip}
                    </p>
                  ))}
                </CardContent>
              </Card>
            </div>
          </TabsContent>
        </Tabs>
      </div>
    </>
  );
}
