import { Metadata } from 'next';
import Link from 'next/link';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { 
  Activity, Database, Coins, Users, Settings, Shield,
  ArrowRight, BarChart3, AlertCircle
} from 'lucide-react';

export const metadata: Metadata = {
  title: '관리자 대시보드 - Fortune',
  description: '시스템 관리 및 모니터링',
};

const adminMenus = [
  {
    title: '토큰 사용량 대시보드',
    description: '토큰 사용 현황 및 통계 분석',
    href: '/dashboard/tokens',
    icon: Coins,
    color: 'text-yellow-600',
    bgColor: 'bg-yellow-50',
  },
  {
    title: 'Redis 모니터링',
    description: '캐시 및 Rate Limiting 상태',
    href: '/admin/redis-monitor',
    icon: Database,
    color: 'text-red-600',
    bgColor: 'bg-red-50',
  },
  {
    title: '사용자 관리',
    description: '사용자 정보 및 권한 관리',
    href: '/admin/users',
    icon: Users,
    color: 'text-blue-600',
    bgColor: 'bg-blue-50',
  },
  {
    title: '시스템 상태',
    description: '서버 상태 및 성능 모니터링',
    href: '/admin/system',
    icon: Activity,
    color: 'text-green-600',
    bgColor: 'bg-green-50',
  },
  {
    title: '보안 설정',
    description: 'API 키 및 보안 정책 관리',
    href: '/admin/security',
    icon: Shield,
    color: 'text-purple-600',
    bgColor: 'bg-purple-50',
  },
  {
    title: '통계 분석',
    description: '운세별 사용 통계 및 분석',
    href: '/admin/analytics',
    icon: BarChart3,
    color: 'text-indigo-600',
    bgColor: 'bg-indigo-50',
  },
];

export default function AdminDashboard() {
  return (
    <div className="container mx-auto py-8 px-4">
      <div className="mb-8">
        <h1 className="text-3xl font-bold">관리자 대시보드</h1>
        <p className="text-muted-foreground mt-2">
          Fortune 앱의 시스템을 관리하고 모니터링합니다.
        </p>
      </div>

      {/* 빠른 상태 요약 */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-8">
        <Card>
          <CardHeader className="pb-3">
            <CardTitle className="text-sm font-medium">활성 사용자</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">1,234</div>
            <p className="text-xs text-muted-foreground">최근 24시간</p>
          </CardContent>
        </Card>
        
        <Card>
          <CardHeader className="pb-3">
            <CardTitle className="text-sm font-medium">오늘 토큰 사용량</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">45.2K</div>
            <p className="text-xs text-muted-foreground">평균 대비 +12%</p>
          </CardContent>
        </Card>
        
        <Card>
          <CardHeader className="pb-3">
            <CardTitle className="text-sm font-medium">API 응답 시간</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">234ms</div>
            <p className="text-xs text-green-600">정상</p>
          </CardContent>
        </Card>
        
        <Card>
          <CardHeader className="pb-3">
            <CardTitle className="text-sm font-medium">시스템 상태</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="flex items-center gap-2">
              <div className="h-3 w-3 bg-green-500 rounded-full animate-pulse" />
              <span className="text-sm font-medium">모든 시스템 정상</span>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* 관리 메뉴 그리드 */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {adminMenus.map((menu) => (
          <Link href={menu.href} key={menu.href}>
            <Card className="h-full hover:shadow-lg transition-shadow cursor-pointer">
              <CardHeader>
                <div className="flex items-center justify-between">
                  <div className={`p-3 rounded-lg ${menu.bgColor}`}>
                    <menu.icon className={`h-6 w-6 ${menu.color}`} />
                  </div>
                  <ArrowRight className="h-5 w-5 text-muted-foreground" />
                </div>
                <CardTitle className="mt-4">{menu.title}</CardTitle>
                <CardDescription>{menu.description}</CardDescription>
              </CardHeader>
            </Card>
          </Link>
        ))}
      </div>

      {/* 시스템 알림 */}
      <Card className="mt-8">
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <AlertCircle className="h-5 w-5 text-warning" />
            시스템 알림
          </CardTitle>
        </CardHeader>
        <CardContent className="space-y-3">
          <div className="flex items-start gap-3">
            <div className="h-2 w-2 bg-warning rounded-full mt-1.5" />
            <div>
              <p className="text-sm font-medium">토큰 잔량 주의</p>
              <p className="text-sm text-muted-foreground">
                현재 사용 패턴 기준 5일 내 토큰 소진 예상
              </p>
            </div>
          </div>
          <div className="flex items-start gap-3">
            <div className="h-2 w-2 bg-blue-500 rounded-full mt-1.5" />
            <div>
              <p className="text-sm font-medium">시스템 업데이트 예정</p>
              <p className="text-sm text-muted-foreground">
                1월 10일 오전 2시 정기 점검 예정 (약 30분)
              </p>
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}