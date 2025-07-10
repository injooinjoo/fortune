'use client';

import { useToast } from '@/hooks/use-toast';
import { logger } from '@/lib/logger';
import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { FortunePackageSelector } from './FortunePackageSelector';
import { BatchFortuneDisplay } from './BatchFortuneDisplay';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Alert, AlertDescription } from '@/components/ui/alert';
import { Skeleton } from '@/components/ui/skeleton';
import { BatchFortuneRequest, BatchFortuneResponse } from '@/types/batch-fortune';
import { useUser } from '@/hooks/use-user';
import { motion } from 'framer-motion';
import { Sparkles, RefreshCw, AlertCircle } from 'lucide-react';

interface BatchFortuneContainerProps {
  defaultPackage?: string;
  onFortuneGenerated?: (data: BatchFortuneResponse) => void;
}

export function BatchFortuneContainer({
  defaultPackage,
  onFortuneGenerated
}: BatchFortuneContainerProps) {
  const { toast } = useToast();
  const router = useRouter();
  const { user, profile } = useUser();
  const [selectedPackage, setSelectedPackage] = useState<string | undefined>(defaultPackage);
  const [fortuneData, setFortuneData] = useState<BatchFortuneResponse | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [showPackageSelector, setShowPackageSelector] = useState(!defaultPackage);

  // 배치 운세 생성 함수
  const generateBatchFortune = async (packageId: string) => {
    if (!user || !profile) {
      setError('로그인이 필요합니다.');
      return;
    }

    setLoading(true);
    setError(null);

    try {
      const request: BatchFortuneRequest = {
        request_type: 'user_direct_request',
        user_profile: {
          id: user.id,
          name: profile.name || '사용자',
          birth_date: profile.birth_date || '1990-01-01',
          birth_time: profile.birth_time,
          gender: profile.gender,
          mbti: profile.mbti,
          zodiac_sign: profile.zodiac_sign,
          relationship_status: profile.relationship_status
        },
        requested_categories: [packageId],
        target_date: new Date().toISOString().split('T')[0],
        generation_context: {
          cache_duration_hours: 24,
          is_user_initiated: true
        }
      };

      const response = await fetch('/api/fortune/generate-batch', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${await user.getIdToken()}`
        },
        body: JSON.stringify(request)
      });

      if (!response.ok) {
        const errorData = await response.json();
        throw new Error(errorData.error || '운세 생성에 실패했습니다.');
      }

      const data: BatchFortuneResponse = await response.json();
      setFortuneData(data);
      setShowPackageSelector(false);

      // 콜백 실행
      if (onFortuneGenerated) {
        onFortuneGenerated(data);
      }

      // 로컬 스토리지에 캐시
      localStorage.setItem(
        `batch_fortune_${packageId}_${data.generated_at}`,
        JSON.stringify(data)
      );
    } catch (err) {
      logger.error('배치 운세 생성 오류:', err);
      setError(err instanceof Error ? err.message : '알 수 없는 오류가 발생했습니다.');
    } finally {
      setLoading(false);
    }
  };

  // 패키지 선택 핸들러
  const handlePackageSelect = (packageId: string) => {
    setSelectedPackage(packageId);
    generateBatchFortune(packageId);
  };

  // 운세 새로고침
  const handleRefresh = () => {
    if (selectedPackage) {
      generateBatchFortune(selectedPackage);
    }
  };

  // 개별 운세 공유
  const handleShare = async (fortuneType: string) => {
    if (!fortuneData) return;

    const fortuneContent = fortuneData.analysis_results[fortuneType];
    const shareData = {
      title: `${fortuneType} 운세`,
      text: fortuneContent.summary || fortuneContent.content || '운세 결과',
      url: `${window.location.origin}/fortune/${fortuneType}`
    };

    try {
      if (navigator.share) {
        await navigator.share(shareData);
      } else {
        // 클립보드에 복사
        await navigator.clipboard.writeText(
          `${shareData.title}\n${shareData.text}\n${shareData.url}`
        );
        toast({
      title: '클립보드에 복사되었습니다!',
      variant: "default",
    });
      }
    } catch (err) {
      logger.error('공유 실패:', err);
    }
  };

  // 초기 로드 시 캐시 확인
  useEffect(() => {
    if (defaultPackage && !fortuneData) {
      const today = new Date().toISOString().split('T')[0];
      const cacheKey = `batch_fortune_${defaultPackage}_${today}`;
      const cached = localStorage.getItem(cacheKey);

      if (cached) {
        try {
          const cachedData = JSON.parse(cached);
          setFortuneData(cachedData);
          setShowPackageSelector(false);
        } catch (err) {
          logger.error('캐시 파싱 오류:', err);
        }
      }
    }
  }, [defaultPackage, fortuneData]);

  // 로그인 필요 시
  if (!user || !profile) {
    return (
      <Card className="p-8 text-center">
        <CardContent>
          <AlertCircle className="w-12 h-12 text-muted-foreground mx-auto mb-4" />
          <h3 className="text-lg font-semibold mb-2">로그인이 필요합니다</h3>
          <p className="text-muted-foreground mb-4">
            운세를 확인하려면 먼저 로그인해주세요.
          </p>
          <Button onClick={() => router.push('/auth/signin')}>
            로그인하기
          </Button>
        </CardContent>
      </Card>
    );
  }

  return (
    <div className="space-y-6">
      {/* 헤더 */}
      <motion.div
        initial={{ opacity: 0, y: -20 }}
        animate={{ opacity: 1, y: 0 }}
        className="text-center"
      >
        <div className="flex items-center justify-center gap-2 mb-2">
          <Sparkles className="w-6 h-6 text-primary" />
          <h1 className="text-2xl font-bold">운세 묶음 패키지</h1>
        </div>
        <p className="text-muted-foreground">
          관련된 운세들을 한 번에 확인하고 종합적인 인사이트를 받아보세요
        </p>
      </motion.div>

      {/* 에러 표시 */}
      {error && (
        <Alert variant="destructive">
          <AlertCircle className="h-4 w-4" />
          <AlertDescription>{error}</AlertDescription>
        </Alert>
      )}

      {/* 패키지 선택기 또는 결과 표시 */}
      {showPackageSelector && !fortuneData ? (
        <div>
          <h2 className="text-lg font-semibold mb-4">운세 패키지를 선택하세요</h2>
          <FortunePackageSelector
            onSelectPackage={handlePackageSelect}
            selectedPackage={selectedPackage}
            loading={loading}
          />
        </div>
      ) : (
        <>
          {/* 선택된 패키지 정보 */}
          {selectedPackage && !loading && (
            <Card className="bg-primary/5 border-primary/20">
              <CardHeader className="pb-3">
                <div className="flex items-center justify-between">
                  <CardTitle className="text-base">
                    현재 패키지: {selectedPackage.replace('_', ' ')}
                  </CardTitle>
                  <Button
                    variant="ghost"
                    size="sm"
                    onClick={() => {
                      setShowPackageSelector(true);
                      setFortuneData(null);
                    }}
                  >
                    다른 패키지 선택
                  </Button>
                </div>
              </CardHeader>
            </Card>
          )}

          {/* 운세 결과 표시 */}
          <BatchFortuneDisplay
            fortuneData={fortuneData}
            loading={loading}
            onRefresh={handleRefresh}
            onShare={handleShare}
          />
        </>
      )}

      {/* 로딩 상태 */}
      {loading && (
        <div className="space-y-4">
          <div className="flex items-center justify-center py-8">
            <div className="relative">
              <div className="absolute inset-0 flex items-center justify-center">
                <RefreshCw className="w-8 h-8 text-primary animate-spin" />
              </div>
              <div className="w-20 h-20 border-4 border-primary/20 rounded-full" />
            </div>
          </div>
          <div className="text-center">
            <p className="text-lg font-medium">운세를 생성하고 있습니다...</p>
            <p className="text-sm text-muted-foreground mt-1">
              AI가 당신만을 위한 특별한 운세를 준비하고 있어요
            </p>
          </div>
          <div className="grid gap-4 md:grid-cols-2">
            {[1, 2, 3, 4].map((i) => (
              <Skeleton key={i} className="h-32" />
            ))}
          </div>
        </div>
      )}
    </div>
  );
}