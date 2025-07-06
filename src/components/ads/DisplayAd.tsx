"use client";

import GoogleAdsense from "./GoogleAdsense";
import { Card } from "@/components/ui/card";
import { Sparkles } from "lucide-react";

interface DisplayAdProps {
  className?: string;
  size?: 'rectangle' | 'leaderboard' | 'large-rectangle' | 'responsive';
  showLabel?: boolean;
  testMode?: boolean;
}

const adSizes = {
  rectangle: { width: 300, height: 250 },
  leaderboard: { width: 728, height: 90 },
  'large-rectangle': { width: 336, height: 280 },
  responsive: { width: '100%', height: 'auto' }
};

export default function DisplayAd({ 
  className = "", 
  size = 'responsive',
  showLabel = true,
  testMode = false
}: DisplayAdProps) {
  const adSize = adSizes[size];
  
  return (
    <div className={`display-ad-wrapper ${className}`}>
      {showLabel && (
        <div className="flex items-center justify-center gap-2 mb-2">
          <Sparkles className="w-3 h-3 text-gray-400" />
          <span className="text-xs text-gray-500 dark:text-gray-400">
            광고
          </span>
        </div>
      )}
      
      <Card className="overflow-hidden p-0 border-gray-200 dark:border-gray-700">
        <GoogleAdsense
          useSecondarySlot={true}
          style={{
            display: 'block',
            width: typeof adSize.width === 'number' ? `${adSize.width}px` : adSize.width,
            height: typeof adSize.height === 'number' ? `${adSize.height}px` : adSize.height,
            minHeight: size === 'responsive' ? '100px' : undefined
          }}
          format={size === 'responsive' ? 'auto' : 'rectangle'}
          responsive={size === 'responsive'}
          testMode={testMode}
          fallback={
            <div 
              className="bg-gray-100 dark:bg-gray-800 flex items-center justify-center"
              style={{
                width: typeof adSize.width === 'number' ? `${adSize.width}px` : adSize.width,
                height: typeof adSize.height === 'number' ? `${adSize.height}px` : '100px'
              }}
            >
              <div className="text-center">
                <Sparkles className="w-6 h-6 text-gray-400 mx-auto mb-2" />
                <p className="text-xs text-gray-500">광고 영역</p>
              </div>
            </div>
          }
        />
      </Card>
    </div>
  );
}