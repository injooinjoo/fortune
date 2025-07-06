# Premium Features Documentation

## Overview

Fortune Premium offers an enhanced, ad-free experience with exclusive features for users who want deeper insights and unlimited access to fortune services. This document outlines the premium features, implementation, and future roadmap.

## Current Implementation Status

### ✅ Implemented
- Premium UI pages (`/premium`, `/membership`)
- Local storage-based subscription management (demo)
- Ad-free experience logic
- Premium feature flags

### 🚧 Pending
- Real payment integration
- Server-side subscription validation
- Premium-exclusive fortune types
- Advanced analytics dashboard

## Premium Tiers

### 1. Free Tier (Basic)
- Access to all 55 fortune types
- Daily fortune limits (10 fortunes/day)
- Standard AI responses
- Ads displayed
- Basic fortune history (7 days)

### 2. Premium Tier (월 9,900원)
- **Unlimited** fortune generations
- **Ad-free** experience
- **Priority** AI processing
- **Extended** history (1 year)
- **Exclusive** fortune types
- **Advanced** analytics
- **Early access** to new features

### 3. Premium Plus Tier (월 19,900원) - Planned
- All Premium features
- **Personal AI assistant**
- **Custom fortune reports**
- **API access** for developers
- **Family sharing** (up to 5 accounts)
- **White-label** options

## Feature Comparison

| Feature | Free | Premium | Premium Plus |
|---------|------|---------|--------------|
| Daily Fortunes | 10 | Unlimited | Unlimited |
| Ad-free Experience | ❌ | ✅ | ✅ |
| Fortune History | 7 days | 1 year | Lifetime |
| AI Response Quality | Standard | Enhanced | Premium |
| Analytics Dashboard | Basic | Advanced | Professional |
| Custom Reports | ❌ | Monthly | Weekly |
| API Access | ❌ | ❌ | ✅ |
| Family Sharing | ❌ | ❌ | 5 accounts |
| Priority Support | ❌ | Email | 24/7 Chat |

## Implementation Details

### 1. Subscription Management

Located at: `/src/lib/subscription-manager.ts`

```typescript
interface Subscription {
  tier: 'free' | 'premium' | 'premium_plus';
  status: 'active' | 'cancelled' | 'expired';
  startDate: string;
  endDate: string;
  features: string[];
}

export class SubscriptionManager {
  private static STORAGE_KEY = 'fortune_subscription';

  static getSubscription(): Subscription {
    if (typeof window === 'undefined') {
      return this.getDefaultSubscription();
    }

    const stored = localStorage.getItem(this.STORAGE_KEY);
    if (stored) {
      const subscription = JSON.parse(stored);
      if (new Date(subscription.endDate) > new Date()) {
        return subscription;
      }
    }

    return this.getDefaultSubscription();
  }

  static setSubscription(subscription: Subscription): void {
    localStorage.setItem(this.STORAGE_KEY, JSON.stringify(subscription));
  }

  static isPremium(): boolean {
    const sub = this.getSubscription();
    return sub.tier !== 'free' && sub.status === 'active';
  }

  static getFeatures(): string[] {
    return this.getSubscription().features;
  }

  private static getDefaultSubscription(): Subscription {
    return {
      tier: 'free',
      status: 'active',
      startDate: new Date().toISOString(),
      endDate: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString(),
      features: ['basic_fortunes', 'limited_history']
    };
  }
}
```

### 2. Premium Feature Gates

```typescript
// hooks/usePremiumFeature.ts
export function usePremiumFeature(feature: string) {
  const subscription = useSubscription();
  
  const hasAccess = subscription.features.includes(feature) || 
                   subscription.features.includes('all_features');
  
  const requiresPremium = !hasAccess && 
                         PREMIUM_FEATURES.includes(feature);
  
  return {
    hasAccess,
    requiresPremium,
    subscription
  };
}

// Usage in components
function AdvancedAnalytics() {
  const { hasAccess, requiresPremium } = usePremiumFeature('advanced_analytics');
  
  if (requiresPremium) {
    return <PremiumUpgradePrompt feature="고급 분석" />;
  }
  
  return <AnalyticsDashboard />;
}
```

### 3. Premium UI Components

Located at: `/src/app/premium/page.tsx`

```typescript
export default function PremiumPage() {
  const features = [
    {
      icon: "✨",
      title: "무제한 운세",
      description: "하루 제한 없이 모든 운세를 무제한으로"
    },
    {
      icon: "🚫",
      title: "광고 없는 경험",
      description: "깔끔한 인터페이스로 운세에만 집중"
    },
    {
      icon: "📊",
      title: "고급 분석",
      description: "AI 기반 심층 운세 분석 리포트"
    },
    {
      icon: "📅",
      title: "1년 히스토리",
      description: "모든 운세 기록을 1년간 보관"
    },
    {
      icon: "⚡",
      title: "우선 처리",
      description: "AI 처리 우선권으로 빠른 응답"
    },
    {
      icon: "🎁",
      title: "독점 기능",
      description: "프리미엄 회원 전용 특별 운세"
    }
  ];

  return (
    <div className="max-w-4xl mx-auto p-6">
      <h1 className="text-3xl font-bold mb-8">
        Fortune Premium
      </h1>
      
      <div className="grid md:grid-cols-2 gap-6 mb-8">
        {features.map((feature, index) => (
          <FeatureCard key={index} {...feature} />
        ))}
      </div>
      
      <PricingSection />
    </div>
  );
}
```

### 4. Payment Integration (Planned)

```typescript
// lib/payment.ts
import { loadTossPayments } from '@tosspayments/payment-sdk';

export async function initializePayment() {
  const tossPayments = await loadTossPayments(
    process.env.NEXT_PUBLIC_TOSS_CLIENT_KEY!
  );
  
  return {
    requestPayment: async (amount: number, orderId: string) => {
      await tossPayments.requestPayment('카드', {
        amount,
        orderId,
        orderName: 'Fortune Premium 구독',
        successUrl: `${window.location.origin}/payment/success`,
        failUrl: `${window.location.origin}/payment/fail`,
      });
    }
  };
}

// Stripe alternative
import { loadStripe } from '@stripe/stripe-js';

export async function createCheckoutSession(priceId: string) {
  const stripe = await loadStripe(
    process.env.NEXT_PUBLIC_STRIPE_KEY!
  );
  
  const response = await fetch('/api/create-checkout-session', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ priceId })
  });
  
  const session = await response.json();
  await stripe?.redirectToCheckout({ sessionId: session.id });
}
```

## Premium-Exclusive Features

### 1. Advanced Analytics Dashboard

```typescript
// components/premium/AnalyticsDashboard.tsx
export function AnalyticsDashboard() {
  return (
    <div className="space-y-6">
      <FortuneScoreTrends />      {/* 운세 점수 추이 */}
      <LuckyPatterns />           {/* 행운 패턴 분석 */}
      <ElementBalance />          {/* 오행 균형 차트 */}
      <MonthlyReport />           {/* 월간 종합 리포트 */}
      <YearlyForecast />          {/* 연간 예측 */}
    </div>
  );
}
```

### 2. AI Personal Assistant

```typescript
// components/premium/AIAssistant.tsx
export function AIAssistant() {
  const [query, setQuery] = useState('');
  
  const askAssistant = async () => {
    const response = await fetch('/api/premium/assistant', {
      method: 'POST',
      body: JSON.stringify({ query }),
    });
    
    return response.json();
  };
  
  return (
    <div className="chat-interface">
      <ChatHistory />
      <ChatInput onSubmit={askAssistant} />
    </div>
  );
}
```

### 3. Custom Fortune Reports

```typescript
// Monthly comprehensive report
interface MonthlyReport {
  period: string;
  overallScore: number;
  highlights: string[];
  challenges: string[];
  recommendations: string[];
  luckyDays: Date[];
  detailedAnalysis: {
    love: Analysis;
    career: Analysis;
    wealth: Analysis;
    health: Analysis;
  };
}
```

### 4. Fortune API Access (Premium Plus)

```typescript
// API endpoint for premium users
// GET /api/v1/fortunes
{
  "headers": {
    "Authorization": "Bearer YOUR_API_KEY"
  }
}

// Response
{
  "fortunes": [...],
  "usage": {
    "requests_today": 150,
    "requests_limit": 1000
  }
}
```

## Monetization Strategy

### 1. Pricing Tiers
- **Basic**: Free (Ad-supported)
- **Premium**: ₩9,900/month or ₩99,000/year (17% discount)
- **Premium Plus**: ₩19,900/month or ₩199,000/year (17% discount)

### 2. Conversion Funnel
1. **Free Trial**: 7 days premium access
2. **Feature Limits**: Show premium features with upgrade prompts
3. **Special Offers**: Seasonal discounts, first month 50% off
4. **Referral Program**: 1 month free for each referral

### 3. Retention Strategies
- **Engagement Emails**: Weekly fortune summaries
- **Exclusive Content**: Premium-only fortune types
- **Loyalty Rewards**: Discounts for long-term subscribers
- **Community Access**: Premium user forums

## Implementation Roadmap

### Phase 1: Payment Integration (Q1 2025)
- [ ] Integrate Toss Payments / Stripe
- [ ] Implement subscription management API
- [ ] Create payment success/failure flows
- [ ] Add subscription webhooks

### Phase 2: Premium Features (Q2 2025)
- [ ] Advanced analytics dashboard
- [ ] AI personal assistant
- [ ] Custom report generation
- [ ] API access system

### Phase 3: Growth Features (Q3 2025)
- [ ] Referral system
- [ ] Gift subscriptions
- [ ] Corporate packages
- [ ] White-label options

## Metrics & KPIs

### Key Metrics to Track
1. **Conversion Rate**: Free to Premium (Target: 5%)
2. **Churn Rate**: Monthly cancellations (Target: <10%)
3. **ARPU**: Average Revenue Per User
4. **LTV**: Lifetime Value
5. **CAC**: Customer Acquisition Cost

### Analytics Implementation
```typescript
// utils/premium-analytics.ts
export function trackPremiumEvent(event: string, data?: any) {
  if (typeof window !== 'undefined' && window.gtag) {
    window.gtag('event', event, {
      event_category: 'Premium',
      event_label: data?.label,
      value: data?.value,
      custom_parameters: data
    });
  }
}

// Usage
trackPremiumEvent('upgrade_initiated', { 
  from: 'fortune_limit_reached',
  tier: 'premium'
});
```

## Support & Documentation

### User Support
1. **Free Users**: Community forum, FAQ
2. **Premium Users**: Email support (24h response)
3. **Premium Plus**: Priority chat support

### Help Documentation
- Getting started with Premium
- Feature tutorials
- Billing & subscription FAQ
- API documentation
- Troubleshooting guide

---

*Last updated: 2025-07-06*
*Status: 🚧 UI Implemented, Payment Integration Pending*