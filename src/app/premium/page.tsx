"use client";

import React from 'react';
import { Check, X } from 'lucide-react';
import { Table, TableHeader, TableBody, TableRow, TableHead, TableCell } from '@/components/ui/table';
import { Card, CardHeader, CardTitle, CardDescription, CardContent, CardFooter } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';

export default function PremiumPage() {
  const handleSubscription = (plan: 'monthly' | 'yearly') => {
    console.log(`subscribe: ${plan}`);
  };

  return (
    <div className="min-h-screen bg-background text-foreground p-6">
      <div className="max-w-2xl mx-auto space-y-10">
        {/* Headline Section */}
        <section className="text-center space-y-2">
          <h1 className="text-3xl font-bold">운명의 모든 비밀을 잠금 해제하세요</h1>
          <p className="text-muted-foreground">광고 없는 쾌적한 환경에서 더 깊이 있는 운세 분석을 경험하세요.</p>
        </section>

        {/* Feature Comparison */}
        <section>
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>기능</TableHead>
                <TableHead className="text-center">무료</TableHead>
                <TableHead className="text-center">프리미엄</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              <TableRow>
                <TableCell>상세 사주 분석 리포트</TableCell>
                <TableCell className="text-center"><X className="mx-auto" /></TableCell>
                <TableCell className="text-center text-primary"><Check className="mx-auto" /></TableCell>
              </TableRow>
              <TableRow>
                <TableCell>광고 제거</TableCell>
                <TableCell className="text-center"><X className="mx-auto" /></TableCell>
                <TableCell className="text-center text-primary"><Check className="mx-auto" /></TableCell>
              </TableRow>
              <TableRow>
                <TableCell>무제한 타로카드 이용</TableCell>
                <TableCell className="text-center"><X className="mx-auto" /></TableCell>
                <TableCell className="text-center text-primary"><Check className="mx-auto" /></TableCell>
              </TableRow>
              <TableRow>
                <TableCell>월간 운세 리포트</TableCell>
                <TableCell className="text-center"><X className="mx-auto" /></TableCell>
                <TableCell className="text-center text-primary"><Check className="mx-auto" /></TableCell>
              </TableRow>
            </TableBody>
          </Table>
        </section>

        {/* Subscription Plans */}
        <section className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <Card>
            <CardHeader>
              <CardTitle>월간 플랜</CardTitle>
              <CardDescription>₩9,900 / 월</CardDescription>
            </CardHeader>
            <CardContent />
            <CardFooter>
              <Button className="w-full" onClick={() => handleSubscription('monthly')}>
                월간 플랜 구독하기
              </Button>
            </CardFooter>
          </Card>

          <Card>
            <CardHeader>
              <div className="flex items-start justify-between">
                <div>
                  <CardTitle>연간 플랜</CardTitle>
                  <CardDescription>₩99,000 / 년 (월 ₩8,250)</CardDescription>
                </div>
                <Badge>25% 할인</Badge>
              </div>
            </CardHeader>
            <CardContent />
            <CardFooter>
              <Button className="w-full" onClick={() => handleSubscription('yearly')}>
                연간 플랜 구독하기
              </Button>
            </CardFooter>
          </Card>
        </section>

        {/* Promotion */}
        <section className="text-center">
          <p className="text-lg font-semibold">첫 달 무료 체험</p>
        </section>
      </div>
    </div>
  );
}

