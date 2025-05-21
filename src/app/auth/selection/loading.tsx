
import { FortuneCompassIcon } from '@/components/icons/fortune-compass-icon';

export default function Loading() {
  return (
    <div className="min-h-screen flex flex-col items-center justify-center bg-background text-foreground p-4">
      <FortuneCompassIcon className="h-16 w-16 text-primary animate-spin mb-6" />
      <p className="text-lg text-muted-foreground">인증 페이지를 불러오는 중입니다...</p>
    </div>
  );
}
