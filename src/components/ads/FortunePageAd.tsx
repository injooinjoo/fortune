"use client";

import { Card } from "@/components/ui/card";
import GoogleAdsense from "./GoogleAdsense";
import { Gift } from "lucide-react";

interface FortunePageAdProps {
  className?: string;
  slotId?: string;
}

export default function FortunePageAd({ 
  className = "", 
  slotId 
}: FortunePageAdProps) {
  return (
    <Card className={`p-4 bg-gradient-to-br from-purple-50 to-pink-50 dark:from-purple-900/20 dark:to-pink-900/20 border-purple-200 dark:border-purple-700 ${className}`}>
      <div className="flex items-center justify-center gap-2 mb-3">
        <Gift className="w-4 h-4 text-purple-600 dark:text-purple-400" />
        <span className="text-sm font-medium text-purple-800 dark:text-purple-300">
          후원 광고
        </span>
      </div>
      
      <div className="min-h-[250px] bg-white/50 dark:bg-gray-800/50 rounded-lg p-2 flex items-center justify-center">
        <GoogleAdsense
          slot={slotId}
          useSecondarySlot={false}
          style={{ 
            display: "block", 
            width: "100%", 
            minHeight: "250px" 
          }}
          format="rectangle"
          responsive={true}
          className="fortune-page-ad"
          fallback={
            <div className="text-center text-gray-500 dark:text-gray-400">
              <Gift className="w-8 h-8 mx-auto mb-2 opacity-50" />
              <p className="text-sm">광고를 불러오는 중...</p>
            </div>
          }
        />
      </div>
      
      <p className="text-xs text-center text-gray-600 dark:text-gray-400 mt-3">
        광고 수익은 더 나은 서비스 제공에 사용됩니다
      </p>
    </Card>
  );
}