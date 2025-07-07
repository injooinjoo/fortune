'use client';

import { useState, useEffect } from 'react';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Badge } from '@/components/ui/badge';
import { Progress } from '@/components/ui/progress';
import { 
  LineChart, Line, BarChart, Bar, PieChart, Pie, Cell,
  XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer 
} from 'recharts';
import { 
  TrendingUp, TrendingDown, Coins, Activity, 
  Calendar, Clock, AlertTriangle, ChevronUp, ChevronDown 
} from 'lucide-react';
import { format, subDays, startOfDay, endOfDay } from 'date-fns';
import { ko } from 'date-fns/locale';

interface TokenStats {
  summary: {
    totalUsed: number;
    totalRemaining: number;
    totalPurchased: number;
    averagePerDay: number;
    trend: 'up' | 'down' | 'stable';
    trendPercentage: number;
  };
  usage: {
    daily: Array<{ date: string; tokens: number; cost: number }>;
    hourly: Array<{ hour: number; tokens: number }>;
    byFortune: Array<{ fortune: string; tokens: number; count: number }>;
  };
  users: {
    topUsers: Array<{ userId: string; name: string; tokens: number; percentage: number }>;
    activeUsers: number;
    premiumUsers: number;
  };
  predictions: {
    estimatedDaysRemaining: number;
    projectedMonthlyUsage: number;
    recommendedPurchase: number;
  };
}

const CHART_COLORS = ['#0088FE', '#00C49F', '#FFBB28', '#FF8042', '#8884D8'];

export function TokenDashboard() {
  const [stats, setStats] = useState<TokenStats | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [timeRange, setTimeRange] = useState<'7d' | '30d' | '90d'>('7d');
  const [selectedMetric, setSelectedMetric] = useState<'usage' | 'cost'>('usage');

  useEffect(() => {
    fetchTokenStats();
  }, [timeRange]);

  const fetchTokenStats = async () => {
    try {
      setLoading(true);
      setError(null);
      
      const response = await fetch(`/api/admin/token-stats?range=${timeRange}`);
      if (!response.ok) {
        throw new Error('Failed to fetch token statistics');
      }
      
      const data = await response.json();
      setStats(data.data);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Unknown error');
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="text-center">
          <Activity className="h-8 w-8 animate-pulse mx-auto mb-4" />
          <p>토큰 통계 로딩 중...</p>
        </div>
      </div>
    );
  }

  if (error || !stats) {
    return (
      <Card>
        <CardContent className="flex items-center justify-center h-64">
          <div className="text-center">
            <AlertTriangle className="h-8 w-8 text-destructive mx-auto mb-4" />
            <p className="text-destructive">{error || '데이터를 불러올 수 없습니다'}</p>
          </div>
        </CardContent>
      </Card>
    );
  }

  const formatNumber = (num: number) => {
    return new Intl.NumberFormat('ko-KR').format(num);
  };

  const formatCurrency = (num: number) => {
    return new Intl.NumberFormat('ko-KR', {
      style: 'currency',
      currency: 'KRW',
    }).format(num);
  };

  return (
    <div className="space-y-6">
      {/* 시간 범위 선택 */}
      <div className="flex justify-end">
        <Select value={timeRange} onValueChange={(value: any) => setTimeRange(value)}>
          <SelectTrigger className="w-32">
            <SelectValue />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="7d">최근 7일</SelectItem>
            <SelectItem value="30d">최근 30일</SelectItem>
            <SelectItem value="90d">최근 90일</SelectItem>
          </SelectContent>
        </Select>
      </div>

      {/* 요약 통계 */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
        <Card>
          <CardHeader className="pb-3">
            <CardTitle className="text-sm font-medium">총 사용량</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{formatNumber(stats.summary.totalUsed)}</div>
            <div className="flex items-center mt-2 text-sm">
              {stats.summary.trend === 'up' ? (
                <>
                  <ChevronUp className="h-4 w-4 text-destructive" />
                  <span className="text-destructive">{stats.summary.trendPercentage}%</span>
                </>
              ) : (
                <>
                  <ChevronDown className="h-4 w-4 text-green-600" />
                  <span className="text-green-600">{stats.summary.trendPercentage}%</span>
                </>
              )}
              <span className="text-muted-foreground ml-1">vs 이전 기간</span>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="pb-3">
            <CardTitle className="text-sm font-medium">잔여 토큰</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{formatNumber(stats.summary.totalRemaining)}</div>
            <Progress 
              value={(stats.summary.totalRemaining / (stats.summary.totalRemaining + stats.summary.totalUsed)) * 100} 
              className="mt-2 h-2"
            />
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="pb-3">
            <CardTitle className="text-sm font-medium">일평균 사용량</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{formatNumber(stats.summary.averagePerDay)}</div>
            <p className="text-sm text-muted-foreground mt-2">
              예상 잔여 일수: {stats.predictions.estimatedDaysRemaining}일
            </p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="pb-3">
            <CardTitle className="text-sm font-medium">활성 사용자</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{formatNumber(stats.users.activeUsers)}</div>
            <div className="flex items-center gap-2 mt-2">
              <Badge variant="secondary">{stats.users.premiumUsers} 프리미엄</Badge>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* 상세 차트 */}
      <Tabs defaultValue="usage" className="space-y-4">
        <TabsList className="grid w-full grid-cols-4">
          <TabsTrigger value="usage">사용량 추이</TabsTrigger>
          <TabsTrigger value="fortune">운세별 사용량</TabsTrigger>
          <TabsTrigger value="users">사용자 분석</TabsTrigger>
          <TabsTrigger value="hourly">시간대별 분석</TabsTrigger>
        </TabsList>

        <TabsContent value="usage" className="space-y-4">
          <Card>
            <CardHeader>
              <CardTitle>일별 토큰 사용량</CardTitle>
              <CardDescription>
                최근 {timeRange === '7d' ? '7일' : timeRange === '30d' ? '30일' : '90일'}간 토큰 사용 추이
              </CardDescription>
            </CardHeader>
            <CardContent>
              <div className="h-80">
                <ResponsiveContainer width="100%" height="100%">
                  <LineChart data={stats.usage.daily}>
                    <CartesianGrid strokeDasharray="3 3" />
                    <XAxis 
                      dataKey="date" 
                      tickFormatter={(date) => format(new Date(date), 'MM/dd')}
                    />
                    <YAxis />
                    <Tooltip 
                      labelFormatter={(date) => format(new Date(date), 'yyyy년 MM월 dd일')}
                      formatter={(value: number) => formatNumber(value)}
                    />
                    <Legend />
                    <Line 
                      type="monotone" 
                      dataKey="tokens" 
                      stroke="#8884d8" 
                      name="토큰 사용량"
                      strokeWidth={2}
                    />
                  </LineChart>
                </ResponsiveContainer>
              </div>
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="fortune" className="space-y-4">
          <Card>
            <CardHeader>
              <CardTitle>운세별 토큰 사용량</CardTitle>
              <CardDescription>각 운세 유형별 토큰 소비 현황</CardDescription>
            </CardHeader>
            <CardContent>
              <div className="h-80">
                <ResponsiveContainer width="100%" height="100%">
                  <PieChart>
                    <Pie
                      data={stats.usage.byFortune.slice(0, 5)}
                      cx="50%"
                      cy="50%"
                      labelLine={false}
                      label={({ fortune, percentage }: any) => `${fortune}: ${percentage}%`}
                      outerRadius={80}
                      fill="#8884d8"
                      dataKey="tokens"
                    >
                      {stats.usage.byFortune.slice(0, 5).map((entry, index) => (
                        <Cell key={`cell-${index}`} fill={CHART_COLORS[index % CHART_COLORS.length]} />
                      ))}
                    </Pie>
                    <Tooltip formatter={(value: number) => formatNumber(value)} />
                  </PieChart>
                </ResponsiveContainer>
              </div>
              <div className="mt-4 space-y-2">
                {stats.usage.byFortune.slice(0, 5).map((item, index) => (
                  <div key={item.fortune} className="flex items-center justify-between">
                    <div className="flex items-center gap-2">
                      <div 
                        className="w-3 h-3 rounded-full" 
                        style={{ backgroundColor: CHART_COLORS[index % CHART_COLORS.length] }}
                      />
                      <span className="text-sm">{item.fortune}</span>
                    </div>
                    <div className="text-sm text-muted-foreground">
                      {formatNumber(item.tokens)} 토큰 ({item.count}회)
                    </div>
                  </div>
                ))}
              </div>
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="users" className="space-y-4">
          <Card>
            <CardHeader>
              <CardTitle>상위 사용자</CardTitle>
              <CardDescription>토큰을 가장 많이 사용한 사용자</CardDescription>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                {stats.users.topUsers.map((user, index) => (
                  <div key={user.userId} className="flex items-center justify-between">
                    <div className="flex items-center gap-3">
                      <div className="text-lg font-semibold">{index + 1}</div>
                      <div>
                        <p className="font-medium">{user.name}</p>
                        <p className="text-sm text-muted-foreground">ID: {user.userId}</p>
                      </div>
                    </div>
                    <div className="text-right">
                      <p className="font-medium">{formatNumber(user.tokens)} 토큰</p>
                      <p className="text-sm text-muted-foreground">{user.percentage}%</p>
                    </div>
                  </div>
                ))}
              </div>
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="hourly" className="space-y-4">
          <Card>
            <CardHeader>
              <CardTitle>시간대별 사용 패턴</CardTitle>
              <CardDescription>24시간 토큰 사용 분포</CardDescription>
            </CardHeader>
            <CardContent>
              <div className="h-80">
                <ResponsiveContainer width="100%" height="100%">
                  <BarChart data={stats.usage.hourly}>
                    <CartesianGrid strokeDasharray="3 3" />
                    <XAxis 
                      dataKey="hour" 
                      tickFormatter={(hour) => `${hour}시`}
                    />
                    <YAxis />
                    <Tooltip 
                      labelFormatter={(hour) => `${hour}시`}
                      formatter={(value: number) => formatNumber(value)}
                    />
                    <Bar dataKey="tokens" fill="#8884d8" name="토큰 사용량" />
                  </BarChart>
                </ResponsiveContainer>
              </div>
            </CardContent>
          </Card>
        </TabsContent>
      </Tabs>

      {/* 예측 및 권장사항 */}
      <Card>
        <CardHeader>
          <CardTitle>예측 및 권장사항</CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div>
              <p className="text-sm text-muted-foreground">예상 월간 사용량</p>
              <p className="text-2xl font-bold">{formatNumber(stats.predictions.projectedMonthlyUsage)}</p>
            </div>
            <div>
              <p className="text-sm text-muted-foreground">권장 구매량</p>
              <p className="text-2xl font-bold">{formatNumber(stats.predictions.recommendedPurchase)}</p>
            </div>
            <div>
              <p className="text-sm text-muted-foreground">예상 잔여 기간</p>
              <p className="text-2xl font-bold">{stats.predictions.estimatedDaysRemaining}일</p>
            </div>
          </div>
          {stats.predictions.estimatedDaysRemaining < 7 && (
            <div className="bg-warning/10 border border-warning rounded-lg p-4">
              <div className="flex items-center gap-2">
                <AlertTriangle className="h-5 w-5 text-warning" />
                <p className="font-medium">토큰 부족 경고</p>
              </div>
              <p className="text-sm text-muted-foreground mt-1">
                현재 사용 패턴 기준으로 {stats.predictions.estimatedDaysRemaining}일 내에 토큰이 소진될 예정입니다.
                추가 구매를 고려해주세요.
              </p>
            </div>
          )}
        </CardContent>
      </Card>
    </div>
  );
}