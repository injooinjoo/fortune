import { Metadata } from 'next';
import { TokenDashboard } from '@/components/dashboard/TokenDashboard';

export const metadata: Metadata = {
  title: '토큰 사용량 대시보드 - Fortune',
  description: '토큰 사용 통계 및 분석',
};

export default function TokenDashboardPage() {
  return (
    <div className="container mx-auto py-8 px-4">
      <div className="mb-8">
        <h1 className="text-3xl font-bold">토큰 사용량 대시보드</h1>
        <p className="text-muted-foreground mt-2">
          토큰 사용 현황을 실시간으로 모니터링하고 분석합니다.
        </p>
      </div>
      
      <TokenDashboard />
    </div>
  );
}