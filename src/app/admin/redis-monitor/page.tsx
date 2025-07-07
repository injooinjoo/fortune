import { Metadata } from 'next';
import { RedisMonitor } from '@/components/admin/RedisMonitor';

export const metadata: Metadata = {
  title: 'Redis 모니터링 - Fortune Admin',
  description: 'Redis 캐시 및 Rate Limiting 모니터링',
};

export default function RedisMonitorPage() {
  return (
    <div className="container mx-auto py-8 px-4">
      <div className="mb-8">
        <h1 className="text-3xl font-bold">Redis 모니터링</h1>
        <p className="text-muted-foreground mt-2">
          캐시 성능과 Rate Limiting 상태를 실시간으로 모니터링합니다.
        </p>
      </div>
      
      <RedisMonitor />
    </div>
  );
}