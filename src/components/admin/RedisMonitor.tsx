'use client';

import { useState, useEffect } from 'react';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Progress } from '@/components/ui/progress';
import { Badge } from '@/components/ui/badge';
import { Activity, Database, Shield, AlertTriangle, RefreshCcw } from 'lucide-react';
import { Button } from '@/components/ui/button';

interface RedisStats {
  connection: boolean;
  operations: {
    reads: number;
    writes: number;
    errors: number;
  };
  rateLimit: {
    guest: { used: number; limit: number };
    standard: { used: number; limit: number };
    premium: { used: number; limit: number };
  };
  cache: {
    hits: number;
    misses: number;
    hitRate: number;
  };
  performance: {
    avgReadTime: number;
    avgWriteTime: number;
  };
  lastUpdated: string;
}

export function RedisMonitor() {
  const [stats, setStats] = useState<RedisStats | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const fetchStats = async () => {
    try {
      setLoading(true);
      setError(null);
      const response = await fetch('/api/admin/redis-stats');
      
      if (!response.ok) {
        throw new Error('Failed to fetch Redis stats');
      }
      
      const data = await response.json();
      setStats(data);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Unknown error');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchStats();
    const interval = setInterval(fetchStats, 30000); // 30초마다 업데이트
    return () => clearInterval(interval);
  }, []);

  const getRateLimitPercentage = (used: number, limit: number) => {
    return Math.min((used / limit) * 100, 100);
  };

  const getRateLimitColor = (percentage: number) => {
    if (percentage >= 90) return 'destructive';
    if (percentage >= 70) return 'warning';
    return 'default';
  };

  if (loading && !stats) {
    return (
      <Card>
        <CardContent className="flex items-center justify-center h-64">
          <div className="text-center">
            <RefreshCcw className="h-8 w-8 animate-spin mx-auto mb-4" />
            <p>Redis 상태 로딩 중...</p>
          </div>
        </CardContent>
      </Card>
    );
  }

  if (error) {
    return (
      <Card>
        <CardContent className="flex items-center justify-center h-64">
          <div className="text-center">
            <AlertTriangle className="h-8 w-8 text-destructive mx-auto mb-4" />
            <p className="text-destructive">{error}</p>
            <Button onClick={fetchStats} className="mt-4" size="sm">
              다시 시도
            </Button>
          </div>
        </CardContent>
      </Card>
    );
  }

  if (!stats) return null;

  return (
    <div className="space-y-6">
      {/* 연결 상태 */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center justify-between">
            <span className="flex items-center gap-2">
              <Database className="h-5 w-5" />
              Redis 상태
            </span>
            <Badge variant={stats.connection ? 'success' : 'destructive'}>
              {stats.connection ? '연결됨' : '연결 끊김'}
            </Badge>
          </CardTitle>
          <CardDescription>
            마지막 업데이트: {new Date(stats.lastUpdated).toLocaleString('ko-KR')}
          </CardDescription>
        </CardHeader>
      </Card>

      {/* Rate Limiting 현황 */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <Shield className="h-5 w-5" />
            Rate Limiting 현황
          </CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          {Object.entries(stats.rateLimit).map(([type, data]) => {
            const percentage = getRateLimitPercentage(data.used, data.limit);
            const color = getRateLimitColor(percentage);
            
            return (
              <div key={type} className="space-y-2">
                <div className="flex items-center justify-between">
                  <span className="text-sm font-medium capitalize">{type} 사용자</span>
                  <Badge variant={color as any}>
                    {data.used} / {data.limit}
                  </Badge>
                </div>
                <Progress value={percentage} className="h-2" />
              </div>
            );
          })}
        </CardContent>
      </Card>

      {/* 캐시 성능 */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <Activity className="h-5 w-5" />
            캐시 성능
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-2 gap-4">
            <div className="space-y-2">
              <p className="text-sm text-muted-foreground">캐시 히트율</p>
              <div className="flex items-center gap-2">
                <span className="text-2xl font-bold">
                  {stats.cache.hitRate.toFixed(1)}%
                </span>
                <Badge variant={stats.cache.hitRate > 80 ? 'success' : 'warning'}>
                  {stats.cache.hitRate > 80 ? '양호' : '개선 필요'}
                </Badge>
              </div>
            </div>
            <div className="space-y-2">
              <p className="text-sm text-muted-foreground">총 요청</p>
              <p className="text-2xl font-bold">
                {(stats.cache.hits + stats.cache.misses).toLocaleString()}
              </p>
            </div>
          </div>
          <div className="mt-4 pt-4 border-t grid grid-cols-2 gap-4 text-sm">
            <div>
              <span className="text-muted-foreground">히트: </span>
              <span className="font-medium">{stats.cache.hits.toLocaleString()}</span>
            </div>
            <div>
              <span className="text-muted-foreground">미스: </span>
              <span className="font-medium">{stats.cache.misses.toLocaleString()}</span>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* 성능 지표 */}
      <Card>
        <CardHeader>
          <CardTitle>성능 지표</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-2 gap-4">
            <div className="space-y-2">
              <p className="text-sm text-muted-foreground">평균 읽기 시간</p>
              <p className="text-2xl font-bold">{stats.performance.avgReadTime}ms</p>
            </div>
            <div className="space-y-2">
              <p className="text-sm text-muted-foreground">평균 쓰기 시간</p>
              <p className="text-2xl font-bold">{stats.performance.avgWriteTime}ms</p>
            </div>
          </div>
          <div className="mt-4 pt-4 border-t">
            <div className="flex items-center justify-between text-sm">
              <span className="text-muted-foreground">총 작업 수</span>
              <span className="font-medium">
                {(stats.operations.reads + stats.operations.writes).toLocaleString()}
              </span>
            </div>
            {stats.operations.errors > 0 && (
              <div className="flex items-center justify-between text-sm mt-2">
                <span className="text-destructive">오류 발생</span>
                <Badge variant="destructive">{stats.operations.errors}</Badge>
              </div>
            )}
          </div>
        </CardContent>
      </Card>

      {/* 새로고침 버튼 */}
      <div className="flex justify-end">
        <Button onClick={fetchStats} disabled={loading} size="sm">
          <RefreshCcw className={`h-4 w-4 mr-2 ${loading ? 'animate-spin' : ''}`} />
          새로고침
        </Button>
      </div>
    </div>
  );
}