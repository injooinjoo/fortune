'use client';

import { useState, useEffect } from 'react';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Skeleton } from '@/components/ui/skeleton';
import { 
  BarChart, 
  Bar, 
  LineChart, 
  Line, 
  PieChart, 
  Pie, 
  Cell, 
  XAxis, 
  YAxis, 
  CartesianGrid, 
  Tooltip, 
  Legend, 
  ResponsiveContainer 
} from 'recharts';
import { format, subDays, startOfDay, endOfDay } from 'date-fns';
import { ko } from 'date-fns/locale';
import { 
  TrendingUp, 
  TrendingDown, 
  DollarSign, 
  Zap, 
  Package, 
  Calendar,
  Download,
  RefreshCw,
  AlertCircle
} from 'lucide-react';
import AppHeader from '@/components/AppHeader';
import { TokenMonitor } from '@/lib/utils/token-monitor';

interface TokenUsageStats {
  daily: { tokens: number; cost: number };
  monthly: { tokens: number; cost: number };
  byPackage: {
    [packageName: string]: {
      avgTokensPerRequest: number;
      avgCostPerRequest: number;
      savingsPercent: number;
      requestCount: number;
    };
  };
  timeline: {
    date: string;
    tokens: number;
    cost: number;
    requests: number;
  }[];
  topUsers: {
    userId: string;
    userName: string;
    totalTokens: number;
    totalCost: number;
    requestCount: number;
  }[];
}

const COLORS = ['#8b5cf6', '#3b82f6', '#10b981', '#f59e0b', '#ef4444', '#ec4899'];

export default function TokenUsagePage() {
  const [stats, setStats] = useState<TokenUsageStats | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [timeRange, setTimeRange] = useState<'7d' | '30d' | '90d'>('7d');
  const [fontSize, setFontSize] = useState<'small' | 'medium' | 'large'>('medium');

  const tokenMonitor = new TokenMonitor();

  const fetchUsageStats = async () => {
    setLoading(true);
    setError(null);

    try {
      // 시간 범위 계산
      const days = timeRange === '7d' ? 7 : timeRange === '30d' ? 30 : 90;
      const startDate = subDays(new Date(), days);

      // API 호출로 통계 가져오기
      const response = await fetch(`/api/admin/token-usage?days=${days}`, {
        headers: {
          'Authorization': `Bearer ${await getAdminToken()}`
        }
      });

      if (!response.ok) {
        throw new Error('통계 데이터를 불러올 수 없습니다.');
      }

      const data = await response.json();
      setStats(data);
    } catch (err) {
      console.error('토큰 사용량 조회 오류:', err);
      setError(err instanceof Error ? err.message : '알 수 없는 오류가 발생했습니다.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchUsageStats();
  }, [timeRange]);

  const formatCurrency = (value: number) => {
    return new Intl.NumberFormat('ko-KR', {
      style: 'currency',
      currency: 'USD',
      minimumFractionDigits: 2,
      maximumFractionDigits: 4
    }).format(value);
  };

  const formatNumber = (value: number) => {
    return new Intl.NumberFormat('ko-KR').format(value);
  };

  if (loading) {
    return <TokenUsagePageSkeleton />;
  }

  if (error) {
    return (
      <div className="min-h-screen bg-background">
        <AppHeader
          title="토큰 사용량 모니터링"
          showBack={true}
          onFontSizeChange={setFontSize}
          currentFontSize={fontSize}
        />
        <div className="container mx-auto px-4 py-8 pt-20">
          <Card className="p-8 text-center">
            <AlertCircle className="w-12 h-12 text-destructive mx-auto mb-4" />
            <h3 className="text-lg font-semibold mb-2">오류가 발생했습니다</h3>
            <p className="text-muted-foreground mb-4">{error}</p>
            <Button onClick={fetchUsageStats}>다시 시도</Button>
          </Card>
        </div>
      </div>
    );
  }

  if (!stats) {
    return null;
  }

  const packageData = Object.entries(stats.byPackage).map(([name, data]) => ({
    name: name.replace('_', ' '),
    ...data
  }));

  const costTrend = stats.timeline.reduce((acc, day, index, arr) => {
    if (index === 0) return 0;
    return ((day.cost - arr[index - 1].cost) / arr[index - 1].cost) * 100;
  }, 0);

  return (
    <div className="min-h-screen bg-background">
      <AppHeader
        title="토큰 사용량 모니터링"
        showBack={true}
        onFontSizeChange={setFontSize}
        currentFontSize={fontSize}
      />
      
      <div className="container mx-auto px-4 py-8 pt-20">
        {/* 헤더 섹션 */}
        <div className="flex items-center justify-between mb-6">
          <div>
            <h1 className="text-2xl font-bold">토큰 사용량 대시보드</h1>
            <p className="text-muted-foreground">GPT API 사용량 및 비용 분석</p>
          </div>
          <div className="flex gap-2">
            <Button variant="outline" size="sm" onClick={fetchUsageStats}>
              <RefreshCw className="w-4 h-4 mr-2" />
              새로고침
            </Button>
            <Button variant="outline" size="sm">
              <Download className="w-4 h-4 mr-2" />
              내보내기
            </Button>
          </div>
        </div>

        {/* 요약 카드 */}
        <div className="grid gap-4 md:grid-cols-4 mb-6">
          <Card>
            <CardHeader className="pb-2">
              <CardTitle className="text-sm font-medium text-muted-foreground">
                일일 토큰 사용량
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">{formatNumber(stats.daily.tokens)}</div>
              <p className="text-xs text-muted-foreground mt-1">
                전일 대비 {costTrend > 0 ? '+' : ''}{costTrend.toFixed(1)}%
              </p>
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="pb-2">
              <CardTitle className="text-sm font-medium text-muted-foreground">
                일일 비용
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">{formatCurrency(stats.daily.cost)}</div>
              <div className="flex items-center gap-1 mt-1">
                {costTrend > 0 ? (
                  <TrendingUp className="w-3 h-3 text-destructive" />
                ) : (
                  <TrendingDown className="w-3 h-3 text-success" />
                )}
                <span className={`text-xs ${costTrend > 0 ? 'text-destructive' : 'text-success'}`}>
                  {Math.abs(costTrend).toFixed(1)}%
                </span>
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="pb-2">
              <CardTitle className="text-sm font-medium text-muted-foreground">
                월간 토큰 사용량
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">{formatNumber(stats.monthly.tokens)}</div>
              <p className="text-xs text-muted-foreground mt-1">
                예상 월 비용: {formatCurrency(stats.monthly.cost)}
              </p>
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="pb-2">
              <CardTitle className="text-sm font-medium text-muted-foreground">
                평균 절감률
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold text-success">
                {Object.values(stats.byPackage).reduce((sum, pkg) => sum + pkg.savingsPercent, 0) / Object.keys(stats.byPackage).length}%
              </div>
              <p className="text-xs text-muted-foreground mt-1">
                배치 처리 효과
              </p>
            </CardContent>
          </Card>
        </div>

        {/* 시간 범위 선택 */}
        <div className="flex justify-end mb-4">
          <div className="flex gap-1 p-1 bg-muted rounded-lg">
            {(['7d', '30d', '90d'] as const).map((range) => (
              <Button
                key={range}
                variant={timeRange === range ? 'default' : 'ghost'}
                size="sm"
                onClick={() => setTimeRange(range)}
              >
                {range === '7d' ? '7일' : range === '30d' ? '30일' : '90일'}
              </Button>
            ))}
          </div>
        </div>

        {/* 차트 탭 */}
        <Tabs defaultValue="timeline" className="space-y-4">
          <TabsList className="grid w-full grid-cols-4">
            <TabsTrigger value="timeline">시간별 추이</TabsTrigger>
            <TabsTrigger value="packages">패키지별 분석</TabsTrigger>
            <TabsTrigger value="users">사용자별 현황</TabsTrigger>
            <TabsTrigger value="efficiency">효율성 분석</TabsTrigger>
          </TabsList>

          <TabsContent value="timeline" className="space-y-4">
            <Card>
              <CardHeader>
                <CardTitle>토큰 사용량 추이</CardTitle>
                <CardDescription>
                  일별 토큰 사용량 및 비용 변화
                </CardDescription>
              </CardHeader>
              <CardContent>
                <ResponsiveContainer width="100%" height={300}>
                  <LineChart data={stats.timeline}>
                    <CartesianGrid strokeDasharray="3 3" />
                    <XAxis 
                      dataKey="date" 
                      tickFormatter={(date) => format(new Date(date), 'MM/dd', { locale: ko })}
                    />
                    <YAxis yAxisId="left" />
                    <YAxis yAxisId="right" orientation="right" />
                    <Tooltip
                      formatter={(value: any, name: string) => {
                        if (name === '비용') return formatCurrency(value);
                        return formatNumber(value);
                      }}
                    />
                    <Legend />
                    <Line
                      yAxisId="left"
                      type="monotone"
                      dataKey="tokens"
                      stroke="#8b5cf6"
                      name="토큰"
                      strokeWidth={2}
                    />
                    <Line
                      yAxisId="right"
                      type="monotone"
                      dataKey="cost"
                      stroke="#10b981"
                      name="비용"
                      strokeWidth={2}
                    />
                  </LineChart>
                </ResponsiveContainer>
              </CardContent>
            </Card>
          </TabsContent>

          <TabsContent value="packages" className="space-y-4">
            <Card>
              <CardHeader>
                <CardTitle>패키지별 사용량</CardTitle>
                <CardDescription>
                  각 운세 패키지의 토큰 사용량 및 효율성
                </CardDescription>
              </CardHeader>
              <CardContent>
                <ResponsiveContainer width="100%" height={300}>
                  <BarChart data={packageData}>
                    <CartesianGrid strokeDasharray="3 3" />
                    <XAxis dataKey="name" />
                    <YAxis />
                    <Tooltip />
                    <Legend />
                    <Bar dataKey="avgTokensPerRequest" fill="#8b5cf6" name="평균 토큰" />
                    <Bar dataKey="requestCount" fill="#3b82f6" name="요청 수" />
                  </BarChart>
                </ResponsiveContainer>

                <div className="grid gap-4 mt-6 md:grid-cols-2">
                  {packageData.map((pkg, index) => (
                    <Card key={pkg.name} className="p-4">
                      <div className="flex items-center justify-between mb-2">
                        <h4 className="font-semibold">{pkg.name}</h4>
                        <Badge variant="secondary">
                          {pkg.savingsPercent}% 절감
                        </Badge>
                      </div>
                      <div className="space-y-1 text-sm">
                        <div className="flex justify-between">
                          <span className="text-muted-foreground">평균 토큰:</span>
                          <span>{formatNumber(pkg.avgTokensPerRequest)}</span>
                        </div>
                        <div className="flex justify-between">
                          <span className="text-muted-foreground">평균 비용:</span>
                          <span>{formatCurrency(pkg.avgCostPerRequest)}</span>
                        </div>
                        <div className="flex justify-between">
                          <span className="text-muted-foreground">총 요청:</span>
                          <span>{formatNumber(pkg.requestCount)}</span>
                        </div>
                      </div>
                    </Card>
                  ))}
                </div>
              </CardContent>
            </Card>
          </TabsContent>

          <TabsContent value="users" className="space-y-4">
            <Card>
              <CardHeader>
                <CardTitle>상위 사용자</CardTitle>
                <CardDescription>
                  토큰 사용량 기준 상위 10명
                </CardDescription>
              </CardHeader>
              <CardContent>
                <div className="space-y-4">
                  {stats.topUsers.map((user, index) => (
                    <div key={user.userId} className="flex items-center justify-between p-4 border rounded-lg">
                      <div className="flex items-center gap-3">
                        <div className={`w-8 h-8 rounded-full flex items-center justify-center text-white font-semibold`}
                          style={{ backgroundColor: COLORS[index % COLORS.length] }}
                        >
                          {index + 1}
                        </div>
                        <div>
                          <p className="font-medium">{user.userName}</p>
                          <p className="text-sm text-muted-foreground">
                            {formatNumber(user.requestCount)}회 요청
                          </p>
                        </div>
                      </div>
                      <div className="text-right">
                        <p className="font-medium">{formatNumber(user.totalTokens)} 토큰</p>
                        <p className="text-sm text-muted-foreground">
                          {formatCurrency(user.totalCost)}
                        </p>
                      </div>
                    </div>
                  ))}
                </div>
              </CardContent>
            </Card>
          </TabsContent>

          <TabsContent value="efficiency" className="space-y-4">
            <Card>
              <CardHeader>
                <CardTitle>효율성 분석</CardTitle>
                <CardDescription>
                  배치 처리를 통한 비용 절감 효과
                </CardDescription>
              </CardHeader>
              <CardContent>
                <div className="grid gap-6 md:grid-cols-2">
                  <div>
                    <h4 className="font-semibold mb-4">절감률 분포</h4>
                    <ResponsiveContainer width="100%" height={200}>
                      <PieChart>
                        <Pie
                          data={packageData}
                          dataKey="savingsPercent"
                          nameKey="name"
                          cx="50%"
                          cy="50%"
                          outerRadius={80}
                          label
                        >
                          {packageData.map((entry, index) => (
                            <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                          ))}
                        </Pie>
                        <Tooltip />
                      </PieChart>
                    </ResponsiveContainer>
                  </div>

                  <div className="space-y-4">
                    <div className="p-4 bg-success/10 rounded-lg">
                      <div className="flex items-center gap-2 mb-2">
                        <TrendingDown className="w-5 h-5 text-success" />
                        <h4 className="font-semibold">총 절감액</h4>
                      </div>
                      <p className="text-2xl font-bold text-success">
                        {formatCurrency(
                          Object.values(stats.byPackage).reduce(
                            (sum, pkg) => sum + (pkg.avgCostPerRequest * pkg.requestCount * pkg.savingsPercent / 100),
                            0
                          )
                        )}
                      </p>
                      <p className="text-sm text-muted-foreground mt-1">
                        배치 처리로 절약한 비용
                      </p>
                    </div>

                    <div className="p-4 bg-primary/10 rounded-lg">
                      <div className="flex items-center gap-2 mb-2">
                        <Zap className="w-5 h-5 text-primary" />
                        <h4 className="font-semibold">평균 효율성</h4>
                      </div>
                      <p className="text-2xl font-bold text-primary">
                        {(Object.values(stats.byPackage).reduce((sum, pkg) => sum + pkg.savingsPercent, 0) / Object.keys(stats.byPackage).length).toFixed(1)}%
                      </p>
                      <p className="text-sm text-muted-foreground mt-1">
                        개별 호출 대비 토큰 절감
                      </p>
                    </div>
                  </div>
                </div>
              </CardContent>
            </Card>
          </TabsContent>
        </Tabs>
      </div>
    </div>
  );
}

function TokenUsagePageSkeleton() {
  return (
    <div className="min-h-screen bg-background">
      <AppHeader
        title="토큰 사용량 모니터링"
        showBack={true}
      />
      
      <div className="container mx-auto px-4 py-8 pt-20">
        <div className="space-y-6">
          <div className="grid gap-4 md:grid-cols-4">
            {[1, 2, 3, 4].map((i) => (
              <Card key={i}>
                <CardHeader className="pb-2">
                  <Skeleton className="h-4 w-24" />
                </CardHeader>
                <CardContent>
                  <Skeleton className="h-8 w-32" />
                  <Skeleton className="h-3 w-20 mt-2" />
                </CardContent>
              </Card>
            ))}
          </div>

          <Card>
            <CardHeader>
              <Skeleton className="h-6 w-32" />
              <Skeleton className="h-4 w-48 mt-2" />
            </CardHeader>
            <CardContent>
              <Skeleton className="h-64 w-full" />
            </CardContent>
          </Card>
        </div>
      </div>
    </div>
  );
}

// 관리자 토큰 가져오기 (실제 구현 필요)
async function getAdminToken(): Promise<string> {
  // Supabase 인증 또는 별도 관리자 인증 로직
  return 'admin-token';
}