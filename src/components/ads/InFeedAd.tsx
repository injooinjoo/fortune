"use client";

import GoogleAdsense from "./GoogleAdsense";
import { Card } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";

interface InFeedAdProps {
  className?: string;
  title?: string;
  description?: string;
  testMode?: boolean;
}

export default function InFeedAd({ 
  className = "",
  title = "추천 콘텐츠",
  description = "당신을 위한 맞춤 정보",
  testMode = false
}: InFeedAdProps) {
  return (
    <Card className={`in-feed-ad border-0 shadow-sm bg-gradient-to-br from-purple-50/50 to-pink-50/50 dark:from-purple-900/10 dark:to-pink-900/10 ${className}`}>
      <div className="p-4">
        <div className="flex items-start justify-between mb-3">
          <div>
            <h3 className="font-medium text-sm text-gray-800 dark:text-gray-200">
              {title}
            </h3>
            <p className="text-xs text-gray-600 dark:text-gray-400 mt-0.5">
              {description}
            </p>
          </div>
          <Badge variant="secondary" className="text-xs">
            광고
          </Badge>
        </div>
        
        <GoogleAdsense
          useSecondarySlot={false}
          style={{
            display: 'block',
            width: '100%',
            minHeight: '120px'
          }}
          layout="in-article"
          format="fluid"
          responsive={true}
          testMode={testMode}
          fallback={
            <div className="bg-white/50 dark:bg-gray-800/50 rounded-lg p-4 min-h-[120px] flex items-center justify-center">
              <div className="text-center text-gray-500 dark:text-gray-400">
                <p className="text-sm">맞춤 콘텐츠 로딩 중...</p>
              </div>
            </div>
          }
        />
      </div>
    </Card>
  );
}