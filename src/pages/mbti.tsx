import React, { useEffect, useState } from 'react';
import { MBTI_TYPES } from '@/lib/fortune-data';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { FortuneCompassIcon } from '@/components/icons/fortune-compass-icon';

interface MbtiInfo {
  title: string;
  description: string;
  image?: string;
}

export default function MbtiPage() {
  const [selectedType, setSelectedType] = useState<string | null>(null);
  const [mbtiData, setMbtiData] = useState<MbtiInfo | null>(null);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (!selectedType) return;

    const fetchMbti = async () => {
      setIsLoading(true);
      setError(null);
      try {
        const res = await fetch(`/api/mbti/${selectedType}`);
        if (!res.ok) throw new Error('데이터를 불러오는데 실패했습니다.');
        const data: MbtiInfo = await res.json();
        setMbtiData(data);
      } catch (err: any) {
        setError(err.message || '알 수 없는 오류가 발생했습니다.');
        setMbtiData(null);
      } finally {
        setIsLoading(false);
      }
    };

    fetchMbti();
  }, [selectedType]);

  return (
    <div className="min-h-screen p-4 flex flex-col items-center">
      <h1 className="text-2xl font-bold mb-4">MBTI 유형별 정보</h1>
      <div className="grid grid-cols-4 gap-2 mb-6 w-full max-w-md">
        {MBTI_TYPES.map((type) => (
          <Button
            key={type}
            variant={selectedType === type ? 'default' : 'outline'}
            onClick={() => setSelectedType(type)}
            className="text-sm"
          >
            {type}
          </Button>
        ))}
      </div>

      {isLoading && (
        <div className="flex flex-col items-center mt-4">
          <FortuneCompassIcon className="h-10 w-10 text-primary animate-spin mb-2" />
          <p className="text-muted-foreground">불러오는 중...</p>
        </div>
      )}

      {error && <p className="text-destructive mt-4">{error}</p>}

      {mbtiData && !isLoading && !error && (
        <Card className="w-full max-w-md mt-4">
          <CardHeader>
            <CardTitle>{mbtiData.title}</CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            {mbtiData.image && (
              <img
                src={mbtiData.image}
                alt={mbtiData.title}
                className="w-full h-auto rounded-md"
              />
            )}
            <p id="mbti-result-text">{mbtiData.description}</p>
          </CardContent>
        </Card>
      )}

      {!selectedType && !isLoading && !mbtiData && !error && (
        <p className="text-muted-foreground mt-4">
          알고 싶은 MBTI 유형을 선택해주세요.
        </p>
      )}
    </div>
  );
}
