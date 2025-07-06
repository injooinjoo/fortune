# Google AdSense Integration Guide

## Overview

The Fortune app has successfully integrated Google AdSense for monetization. This document covers the implementation details, best practices, and optimization strategies.

## Current Implementation

### Components Structure

```
src/components/ads/
├── AdSenseProvider.tsx    # Global AdSense script provider
├── GoogleAdsense.tsx       # Core AdSense component
├── FortunePageAd.tsx      # Fortune page specific ad wrapper
└── NativeAd.tsx           # Native-style ad component
```

### 1. AdSense Provider

Located at: `/src/components/ads/AdSenseProvider.tsx`

```typescript
'use client';

import Script from 'next/script';

interface AdSenseProviderProps {
  clientId: string;
}

export function AdSenseProvider({ clientId }: AdSenseProviderProps) {
  return (
    <Script
      id="google-adsense"
      async
      src={`https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=${clientId}`}
      crossOrigin="anonymous"
      strategy="afterInteractive"
    />
  );
}
```

### 2. Core AdSense Component

Located at: `/src/components/ads/GoogleAdsense.tsx`

```typescript
'use client';

import { useEffect } from 'react';

interface GoogleAdsenseProps {
  slot: string;
  format?: 'auto' | 'fluid' | 'rectangle' | 'vertical' | 'horizontal';
  responsive?: boolean;
  className?: string;
}

export function GoogleAdsense({
  slot,
  format = 'auto',
  responsive = true,
  className = ''
}: GoogleAdsenseProps) {
  useEffect(() => {
    try {
      ((window as any).adsbygoogle = (window as any).adsbygoogle || []).push({});
    } catch (error) {
      console.error('AdSense error:', error);
    }
  }, []);

  return (
    <ins
      className={`adsbygoogle ${className}`}
      style={{ display: 'block' }}
      data-ad-client={process.env.NEXT_PUBLIC_ADSENSE_CLIENT_ID}
      data-ad-slot={slot}
      data-ad-format={format}
      data-full-width-responsive={responsive}
    />
  );
}
```

### 3. Fortune Page Ad Component

Located at: `/src/components/ads/FortunePageAd.tsx`

```typescript
'use client';

import { GoogleAdsense } from './GoogleAdsense';

interface FortunePageAdProps {
  variant?: 'top' | 'middle' | 'bottom';
}

export function FortunePageAd({ variant = 'bottom' }: FortunePageAdProps) {
  const slotMap = {
    top: process.env.NEXT_PUBLIC_ADSENSE_SLOT_TOP,
    middle: process.env.NEXT_PUBLIC_ADSENSE_SLOT_MIDDLE,
    bottom: process.env.NEXT_PUBLIC_ADSENSE_SLOT_BOTTOM
  };

  const slot = slotMap[variant] || slotMap.bottom;

  if (!slot) return null;

  return (
    <div className="my-8 flex justify-center">
      <GoogleAdsense
        slot={slot}
        format="auto"
        className="w-full max-w-[728px]"
      />
    </div>
  );
}
```

### 4. Native Ad Component

Located at: `/src/components/ads/NativeAd.tsx`

```typescript
'use client';

import { GoogleAdsense } from './GoogleAdsense';

export function NativeAd() {
  const slot = process.env.NEXT_PUBLIC_ADSENSE_SLOT_NATIVE;
  
  if (!slot) return null;

  return (
    <div className="native-ad-container p-4 rounded-lg bg-gray-50">
      <span className="text-xs text-gray-500">광고</span>
      <GoogleAdsense
        slot={slot}
        format="fluid"
        className="native-ad"
      />
    </div>
  );
}
```

## Environment Configuration

### Required Environment Variables

```env
# .env.local
NEXT_PUBLIC_ADSENSE_CLIENT_ID=ca-pub-XXXXXXXXXX
NEXT_PUBLIC_ADSENSE_SLOT_TOP=1234567890
NEXT_PUBLIC_ADSENSE_SLOT_MIDDLE=2345678901
NEXT_PUBLIC_ADSENSE_SLOT_BOTTOM=3456789012
NEXT_PUBLIC_ADSENSE_SLOT_NATIVE=4567890123
```

## Implementation Guide

### 1. Root Layout Setup

In `/src/app/layout.tsx`:

```typescript
import { AdSenseProvider } from '@/components/ads/AdSenseProvider';

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const adsenseClientId = process.env.NEXT_PUBLIC_ADSENSE_CLIENT_ID;

  return (
    <html lang="ko">
      <body>
        {adsenseClientId && (
          <AdSenseProvider clientId={adsenseClientId} />
        )}
        {children}
      </body>
    </html>
  );
}
```

### 2. Fortune Page Integration

Example in `/src/app/fortune/daily/page.tsx`:

```typescript
import { FortunePageAd } from '@/components/ads/FortunePageAd';

export default function DailyFortunePage() {
  return (
    <div>
      {/* Top ad */}
      <FortunePageAd variant="top" />
      
      {/* Fortune content */}
      <FortuneContent />
      
      {/* Bottom ad */}
      <FortunePageAd variant="bottom" />
    </div>
  );
}
```

### 3. Conditional Ad Display

For premium users without ads:

```typescript
export default function FortunePage() {
  const { isPremium } = useUser();

  return (
    <div>
      {!isPremium && <FortunePageAd variant="top" />}
      
      <FortuneContent />
      
      {!isPremium && <FortunePageAd variant="bottom" />}
    </div>
  );
}
```

## Ad Placement Strategy

### 1. Fortune Pages
- **Top Ad**: After header, before fortune content
- **Middle Ad**: Between fortune sections (for long content)
- **Bottom Ad**: After fortune content, before footer

### 2. List Pages
- **Native Ads**: Integrated within fortune card lists
- **Banner Ads**: Between list sections

### 3. Interactive Pages
- **Sticky Ads**: Fixed position during interactions
- **Interstitial**: After completing actions (carefully placed)

## Best Practices

### 1. User Experience
- Never place ads that interfere with fortune reading
- Maintain clear distinction between ads and content
- Use "광고" label for transparency
- Responsive design for all screen sizes

### 2. Performance
```typescript
// Lazy load ads below the fold
import dynamic from 'next/dynamic';

const FortunePageAd = dynamic(
  () => import('@/components/ads/FortunePageAd'),
  { 
    ssr: false,
    loading: () => <div className="h-[250px]" /> // Placeholder
  }
);
```

### 3. Ad Refresh Strategy
```typescript
// Refresh ads on route change
useEffect(() => {
  const refreshAds = () => {
    if (typeof window !== 'undefined' && (window as any).adsbygoogle) {
      (window as any).adsbygoogle.push({});
    }
  };

  refreshAds();
}, [pathname]); // Refresh when route changes
```

## Revenue Optimization

### 1. Ad Unit Types
- **Display Ads**: Standard banner ads
- **Native Ads**: Blend with content design
- **Matched Content**: Related fortune suggestions
- **In-feed Ads**: Within fortune lists

### 2. Optimal Sizes
```typescript
const adSizes = {
  desktop: {
    leaderboard: '728x90',
    mediumRectangle: '300x250',
    largeRectangle: '336x280'
  },
  mobile: {
    mobileBanner: '320x50',
    largeMobileBanner: '320x100',
    mediumRectangle: '300x250'
  }
};
```

### 3. Placement Guidelines
- **Above the fold**: 1 ad maximum
- **Content length**: 1 ad per 500 words
- **Sidebar**: Sticky ad for desktop
- **Mobile**: Fixed bottom banner (closeable)

## Analytics Integration

### 1. Track Ad Performance
```typescript
// utils/analytics.ts
export function trackAdImpression(adSlot: string, position: string) {
  if (typeof window !== 'undefined' && window.gtag) {
    window.gtag('event', 'ad_impression', {
      ad_slot: adSlot,
      ad_position: position,
      page_path: window.location.pathname
    });
  }
}
```

### 2. Monitor Key Metrics
- **CTR (Click-Through Rate)**: Target 1-2%
- **RPM (Revenue Per Mille)**: Track by page type
- **Viewability**: Ensure 70%+ viewable impressions
- **Load Time**: Keep under 3 seconds

## Premium User Experience

### 1. Ad-Free Implementation
```typescript
// hooks/useAdsVisibility.ts
export function useAdsVisibility() {
  const { subscription } = useUser();
  
  return {
    showAds: !subscription?.isPremium,
    adFreeUntil: subscription?.expiresAt
  };
}
```

### 2. Fallback for Ad Blockers
```typescript
// components/ads/AdBlockerMessage.tsx
export function AdBlockerMessage() {
  return (
    <div className="p-4 bg-yellow-50 rounded-lg">
      <p className="text-sm">
        광고는 무료 서비스 운영에 도움이 됩니다. 
        광고 없는 경험을 원하시면 프리미엄을 이용해주세요.
      </p>
    </div>
  );
}
```

## Compliance & Policies

### 1. AdSense Policies
- No clicking own ads
- No encouraging clicks
- No misleading placement
- Content must be family-safe

### 2. Privacy Compliance
- Cookie consent banner required
- Privacy policy must mention ads
- GDPR compliance for EU users
- CCPA compliance for California users

### 3. Korean Regulations
- 개인정보처리방침 명시
- 광고 표시 의무
- 청소년 보호 정책

## Troubleshooting

### Common Issues

1. **Ads not showing**
   - Check AdSense approval status
   - Verify client ID and slot IDs
   - Check for ad blockers
   - Ensure proper domain verification

2. **Low revenue**
   - Optimize placement
   - Improve content quality
   - Increase traffic
   - Test different ad formats

3. **Policy violations**
   - Review content guidelines
   - Check ad placement
   - Remove prohibited content
   - Appeal if wrongly flagged

## Future Enhancements

1. **A/B Testing**: Test different placements
2. **Auto Ads**: Implement AdSense Auto Ads
3. **AMP Support**: Accelerated Mobile Pages
4. **Header Bidding**: Increase competition
5. **Video Ads**: Implement rewarded video ads

---

*Last updated: 2025-07-06*
*Status: ✅ Fully Implemented*