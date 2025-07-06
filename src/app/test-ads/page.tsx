"use client";

import { useState } from "react";
import DisplayAd from "@/components/ads/DisplayAd";
import InFeedAd from "@/components/ads/InFeedAd";
import NativeAd from "@/components/ads/NativeAd";
import FortunePageAd from "@/components/ads/FortunePageAd";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Switch } from "@/components/ui/switch";
import { Label } from "@/components/ui/label";
import { Badge } from "@/components/ui/badge";
import { Info } from "lucide-react";

export default function TestAdsPage() {
  const [testMode, setTestMode] = useState(true);
  
  const slot1 = process.env.NEXT_PUBLIC_ADSENSE_SLOT_ID;
  const slot2 = process.env.NEXT_PUBLIC_ADSENSE_DISPLAY_SLOT;

  return (
    <div className="min-h-screen p-4 bg-gray-50 dark:bg-gray-900">
      <div className="max-w-6xl mx-auto space-y-6">
        {/* 헤더 */}
        <Card>
          <CardHeader>
            <div className="flex items-center justify-between">
              <CardTitle className="text-2xl">광고 테스트 페이지</CardTitle>
              <div className="flex items-center gap-2">
                <Label htmlFor="test-mode">테스트 모드</Label>
                <Switch
                  id="test-mode"
                  checked={testMode}
                  onCheckedChange={setTestMode}
                />
              </div>
            </div>
          </CardHeader>
          <CardContent>
            <div className="space-y-2 text-sm text-gray-600 dark:text-gray-400">
              <div className="flex items-center gap-2">
                <Info className="w-4 h-4" />
                <p>현재 2개의 AdSense 슬롯을 사용합니다:</p>
              </div>
              <div className="ml-6 space-y-1">
                <p>• 기본 슬롯 (Slot 1): <code className="bg-gray-100 dark:bg-gray-800 px-2 py-1 rounded">{slot1}</code></p>
                <p>• 보조 슬롯 (Slot 2): <code className="bg-gray-100 dark:bg-gray-800 px-2 py-1 rounded">{slot2}</code></p>
              </div>
              <p className="mt-3">테스트 모드가 활성화되면 실제 광고 대신 테스트 광고가 표시됩니다.</p>
            </div>
          </CardContent>
        </Card>

        {/* 광고 그리드 */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          {/* DisplayAd - 보조 슬롯 사용 */}
          <Card>
            <CardHeader>
              <CardTitle className="text-lg flex items-center gap-2">
                디스플레이 광고
                <Badge variant="secondary">보조 슬롯</Badge>
              </CardTitle>
            </CardHeader>
            <CardContent>
              <DisplayAd 
                testMode={testMode}
                size="responsive"
              />
            </CardContent>
          </Card>

          {/* InFeedAd - 기본 슬롯 사용 */}
          <Card>
            <CardHeader>
              <CardTitle className="text-lg flex items-center gap-2">
                인피드 광고
                <Badge>기본 슬롯</Badge>
              </CardTitle>
            </CardHeader>
            <CardContent>
              <InFeedAd 
                testMode={testMode}
                title="추천 콘텐츠"
                description="사용자 맞춤 정보"
              />
            </CardContent>
          </Card>

          {/* NativeAd - 보조 슬롯 사용 */}
          <Card>
            <CardHeader>
              <CardTitle className="text-lg flex items-center gap-2">
                네이티브 광고
                <Badge variant="secondary">보조 슬롯</Badge>
              </CardTitle>
            </CardHeader>
            <CardContent>
              <NativeAd 
                testMode={testMode}
                title="추천"
              />
            </CardContent>
          </Card>

          {/* FortunePageAd - 기본 슬롯 사용 */}
          <Card>
            <CardHeader>
              <CardTitle className="text-lg flex items-center gap-2">
                운세 페이지 광고
                <Badge>기본 슬롯</Badge>
              </CardTitle>
            </CardHeader>
            <CardContent>
              <FortunePageAd />
            </CardContent>
          </Card>
        </div>

        {/* 사이즈별 디스플레이 광고 테스트 */}
        <Card>
          <CardHeader>
            <CardTitle className="text-lg">사이즈별 디스플레이 광고 테스트</CardTitle>
          </CardHeader>
          <CardContent className="space-y-6">
            <div>
              <h3 className="text-sm font-medium mb-2">Rectangle (300x250)</h3>
              <DisplayAd 
                testMode={testMode}
                size="rectangle"
                showLabel={false}
              />
            </div>
            
            <div>
              <h3 className="text-sm font-medium mb-2">Leaderboard (728x90)</h3>
              <DisplayAd 
                testMode={testMode}
                size="leaderboard"
                showLabel={false}
              />
            </div>
            
            <div>
              <h3 className="text-sm font-medium mb-2">Large Rectangle (336x280)</h3>
              <DisplayAd 
                testMode={testMode}
                size="large-rectangle"
                showLabel={false}
              />
            </div>
          </CardContent>
        </Card>

        {/* 직접 슬롯 지정 테스트 */}
        <Card>
          <CardHeader>
            <CardTitle className="text-lg">직접 슬롯 지정 테스트</CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            <div>
              <h3 className="text-sm font-medium mb-2">슬롯 1 직접 지정</h3>
              <FortunePageAd slotId={slot1} />
            </div>
            
            <div>
              <h3 className="text-sm font-medium mb-2">슬롯 2 직접 지정</h3>
              <FortunePageAd slotId={slot2} />
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}