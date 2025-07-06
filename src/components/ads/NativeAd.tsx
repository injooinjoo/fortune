"use client";

import { Card, CardContent } from "@/components/ui/card";
import GoogleAdsense from "./GoogleAdsense";
import { Megaphone } from "lucide-react";

interface NativeAdProps {
  className?: string;
  title?: string;
  testMode?: boolean;
}

export default function NativeAd({ 
  className = "", 
  title = "추천",
  testMode = false
}: NativeAdProps) {
  return (
    <Card className={`bg-gradient-to-br from-gray-50 to-gray-100 dark:from-gray-800 dark:to-gray-700 border-gray-200 dark:border-gray-600 ${className}`}>
      <CardContent className="p-4">
        <div className="flex items-center gap-2 mb-3">
          <Megaphone className="w-4 h-4 text-gray-600 dark:text-gray-400" />
          <span className="text-xs font-medium text-gray-600 dark:text-gray-400">
            {title}
          </span>
        </div>
        
        <GoogleAdsense
          useSecondarySlot={true}
          style={{ 
            display: "block", 
            width: "100%",
            minHeight: "100px" 
          }}
          format="fluid"
          layout="in-article"
          responsive={true}
          className="native-ad"
          testMode={testMode}
          fallback={
            <div className="animate-pulse">
              <div className="h-4 bg-gray-200 dark:bg-gray-600 rounded w-3/4 mb-2"></div>
              <div className="h-3 bg-gray-200 dark:bg-gray-600 rounded w-full mb-1"></div>
              <div className="h-3 bg-gray-200 dark:bg-gray-600 rounded w-5/6"></div>
            </div>
          }
        />
      </CardContent>
    </Card>
  );
}