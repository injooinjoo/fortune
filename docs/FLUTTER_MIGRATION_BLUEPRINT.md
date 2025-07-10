# Fortune App - Flutter Migration Blueprint

## Table of Contents
1. [Executive Summary](#executive-summary)
2. [Complete Feature List](#complete-feature-list)
3. [User Flow Documentation](#user-flow-documentation)
4. [API Documentation](#api-documentation)
5. [Data Models](#data-models)
6. [Business Logic](#business-logic)
7. [UI/UX Components](#uiux-components)
8. [Integration Points](#integration-points)
9. [Security Implementation](#security-implementation)

---

## Executive Summary

The Fortune application is a comprehensive Korean fortune-telling service built with Next.js that provides 59 different types of fortune services. The application features a token-based monetization system, premium subscriptions, and integrates AI-powered fortune generation.

### Key Statistics
- **Total Fortune Services**: 59 distinct types
- **Fortune Categories**: 10 main categories
- **Payment Options**: Stripe & TossPay integration
- **Subscription Tiers**: Free, Basic, Premium, Enterprise
- **Token System**: 1-5 tokens per fortune based on complexity
- **Languages**: Korean (primary), with i18n support planned

---

## Complete Feature List

### Fortune Services by Category

#### 1. Daily Fortunes (데일리 운세)
| Service | Type | Token Cost | Cache Duration | Description |
|---------|------|------------|----------------|-------------|
| daily | Comprehensive daily | 1 | 24 hours | Complete daily fortune with all aspects |
| today | Today's fortune | 1 | 24 hours | Simple today's fortune |
| tomorrow | Tomorrow's fortune | 1 | 24 hours | Preview tomorrow's fortune |
| hourly | Hourly fortune | 2 | 24 hours | 24-hour breakdown |

#### 2. Traditional Fortunes (전통 사주)
| Service | Type | Token Cost | Cache Duration | Description |
|---------|------|------------|----------------|-------------|
| saju | Basic Saju | 3 | Lifetime | Traditional four pillars analysis |
| traditional-saju | Detailed Saju | 3 | Lifetime | Classical Saju interpretation |
| saju-psychology | Saju Psychology | 3 | Lifetime | Psychological analysis based on Saju |
| tojeong | Tojeong Secret | 3 | 1 year | 144 hexagram yearly fortune |
| salpuli | Sal removal | 2 | 72 hours | Negative energy analysis |
| palmistry | Palm reading | 2 | Lifetime | Hand line interpretation |

#### 3. Personality & Character (성격/성향)
| Service | Type | Token Cost | Cache Duration | Description |
|---------|------|------------|----------------|-------------|
| mbti | MBTI fortune | 2 | 168 hours | MBTI-based weekly fortune |
| personality | Personality analysis | 3 | Lifetime | Deep personality traits |
| blood-type | Blood type | 1 | 24 hours | Blood type compatibility |

#### 4. Love & Relationships (연애/인연)
| Service | Type | Token Cost | Cache Duration | Description |
|---------|------|------------|----------------|-------------|
| love | Love fortune | 2 | 72 hours | Romance and relationship |
| marriage | Marriage fortune | 3 | 168 hours | Marriage prospects |
| compatibility | Compatibility | 2 | 72 hours | Two-person compatibility |
| traditional-compatibility | Traditional match | 3 | 72 hours | Classical compatibility |
| couple-match | Couple analysis | 3 | 72 hours | Current relationship |
| blind-date | Blind date luck | 2 | 72 hours | Meeting new people |
| ex-lover | Ex-relationship | 2 | 72 hours | Past relationship closure |
| celebrity-match | Celebrity match | 5 | 72 hours | Fun celebrity compatibility |
| chemistry | Chemistry analysis | 3 | 72 hours | Relationship chemistry |

#### 5. Career & Business (취업/사업)
| Service | Type | Token Cost | Cache Duration | Description |
|---------|------|------------|----------------|-------------|
| career | Career fortune | 2 | 168 hours | Career development |
| employment | Employment luck | 2 | 168 hours | Job hunting success |
| business | Business fortune | 5 | 168 hours | Business operations |
| startup | Startup fortune | 5 | 168 hours | Entrepreneurship timing |
| lucky-job | Lucky profession | 2 | 720 hours | Suitable careers |

#### 6. Wealth & Investment (재물/투자)
| Service | Type | Token Cost | Cache Duration | Description |
|---------|------|------------|----------------|-------------|
| wealth | Money fortune | 2 | 168 hours | Financial luck |
| lucky-investment | Investment luck | 5 | 168 hours | Investment timing |
| lucky-realestate | Real estate luck | 5 | 168 hours | Property investment |
| lucky-sidejob | Side job luck | 2 | 168 hours | Additional income |

#### 7. Health & Lifestyle (건강/라이프)
| Service | Type | Token Cost | Cache Duration | Description |
|---------|------|------------|----------------|-------------|
| biorhythm | Biorhythm | 2 | 24 hours | Physical/emotional/intellectual cycles |
| moving | Moving fortune | 2 | 168 hours | Relocation luck |
| moving-date | Moving dates | 1 | 168 hours | Auspicious moving days |
| avoid-people | People to avoid | 2 | 168 hours | Negative influences |

#### 8. Sports & Activities (스포츠/액티비티)
| Service | Type | Token Cost | Cache Duration | Description |
|---------|------|------------|----------------|-------------|
| lucky-hiking | Hiking fortune | 1 | 720 hours | Mountain activities |
| lucky-cycling | Cycling fortune | 1 | 720 hours | Biking luck |
| lucky-running | Running fortune | 1 | 720 hours | Running performance |
| lucky-swim | Swimming fortune | 1 | 720 hours | Water activities |
| lucky-tennis | Tennis fortune | 1 | 720 hours | Tennis game luck |
| lucky-golf | Golf fortune | 1 | 720 hours | Golf performance |
| lucky-baseball | Baseball fortune | 1 | 720 hours | Baseball activities |
| lucky-fishing | Fishing fortune | 1 | 720 hours | Fishing success |

#### 9. Lucky Items (행운 아이템)
| Service | Type | Token Cost | Cache Duration | Description |
|---------|------|------------|----------------|-------------|
| lucky-color | Lucky color | 1 | 720 hours | Color of fortune |
| lucky-number | Lucky number | 1 | 720 hours | Fortunate numbers |
| lucky-items | Lucky items | 1 | 720 hours | Beneficial objects |
| lucky-outfit | Lucky outfit | 1 | 720 hours | Fashion recommendations |
| lucky-food | Lucky food | 1 | 720 hours | Beneficial foods |
| lucky-exam | Exam luck | 2 | 720 hours | Test success |
| talisman | Talisman creation | 3 | 720 hours | Custom talismans |

#### 10. Special Fortunes (특별 운세)
| Service | Type | Token Cost | Cache Duration | Description |
|---------|------|------------|----------------|-------------|
| zodiac | Zodiac fortune | 1 | 24 hours | Western astrology |
| zodiac-animal | Chinese zodiac | 1 | 24 hours | Eastern zodiac |
| birth-season | Birth season | 1 | Lifetime | Seasonal influence |
| birthstone | Birthstone | 1 | Lifetime | Gem influence |
| birthdate | Birthday fortune | 1 | 24 hours | Date-based fortune |
| past-life | Past life | 3 | Lifetime | Previous incarnation |
| new-year | New Year fortune | 3 | 1 year | Annual forecast |
| talent | Hidden talents | 3 | Lifetime | Ability discovery |
| five-blessings | Five blessings | 5 | Lifetime | Life balance analysis |
| network-report | Network analysis | 5 | 168 hours | Social connections |
| timeline | Life timeline | 3 | Lifetime | Major life events |
| wish | Wish fortune | 2 | 168 hours | Desire fulfillment |

### Interactive Features
1. **Face Reading (AI 관상)** - AI-powered physiognomy analysis
2. **Tarot Reading** - Interactive tarot card selection
3. **Psychology Test** - Personality assessments
4. **Worry Bead** - Problem-solving guidance
5. **Dream Interpretation** - Dream analysis
6. **Fortune Cookie** - Daily messages

---

## User Flow Documentation

### 1. Authentication Flow
```
Start → Check Auth Status
  ├─ Not Authenticated → Landing Page
  │   ├─ Sign Up → Email/Social Auth → Onboarding
  │   └─ Sign In → Email/Social Auth → Home
  └─ Authenticated → Check Profile
      ├─ Profile Incomplete → Onboarding
      └─ Profile Complete → Home
```

### 2. Onboarding Flow
```
Step 1: Basic Information
  - Name (required)
  - Birth Date (required)
  - Birth Time (optional - 12 time periods)
  
Step 2: Personal Details
  - MBTI (optional - 16 types)
  
Step 3: Additional Info
  - Gender (optional)
  
→ Create Profile → Sync with Supabase → Navigate to Home
```

### 3. Fortune Generation Flow
```
Select Fortune Type → Check Token Balance
  ├─ Insufficient Tokens
  │   ├─ Free User → Show Token Purchase Options
  │   └─ Premium User → Unlimited Access
  └─ Sufficient Tokens
      ├─ Check Cache → Return Cached Result
      └─ No Cache → Generate New Fortune
          ├─ Show Loading Screen (Free users see ads)
          ├─ Call AI Service
          ├─ Deduct Tokens
          ├─ Cache Result
          └─ Display Fortune
```

### 4. Payment Flow
```
Select Payment Option
  ├─ Token Purchase
  │   ├─ Small Pack (10 tokens - ₩1,000)
  │   ├─ Medium Pack (60 tokens - ₩5,000)
  │   └─ Large Pack (150 tokens - ₩10,000)
  └─ Subscription
      ├─ Basic (100 tokens/month - ₩4,900)
      ├─ Premium (Unlimited - ₩9,900/month)
      └─ Enterprise (Custom pricing)
      
→ Select Payment Method
  ├─ Stripe (International cards)
  └─ TossPay (Korean payment methods)
  
→ Process Payment → Update User Status → Redirect to Dashboard
```

---

## API Documentation

### Base URL
- Production: `https://api.fortune-app.com`
- Development: `http://localhost:3000/api`

### Authentication Headers
```typescript
{
  'Authorization': 'Bearer ${accessToken}',
  'x-api-key': '${apiKey}', // For internal/admin endpoints
  'x-cron-secret': '${cronSecret}' // For scheduled tasks
}
```

### Core API Endpoints

#### 1. Authentication
```typescript
POST   /api/auth/register     - User registration
POST   /api/auth/login        - User login
POST   /api/auth/logout       - User logout
GET    /api/auth/session      - Current session
POST   /api/auth/refresh      - Refresh token
```

#### 2. User Profile
```typescript
GET    /api/profile          - Get user profile
PUT    /api/profile          - Update profile
POST   /api/profile/complete - Complete onboarding
GET    /api/profile/stats    - User statistics
```

#### 3. Fortune Generation
```typescript
// Pattern: /api/fortune/{fortuneType}
POST   /api/fortune/daily              - Generate daily fortune
POST   /api/fortune/saju               - Generate saju fortune
POST   /api/fortune/compatibility      - Generate compatibility
POST   /api/fortune/generate-batch     - Batch generation
GET    /api/fortune/history            - Fortune history
GET    /api/fortune/[category]         - Dynamic fortune endpoint

// Request Body Example
{
  "userId": "uuid",
  "birthDate": "1990-01-01",
  "birthTime": "자시",
  "gender": "male",
  "mbti": "INTJ",
  "options": {
    "includeDetails": true,
    "language": "ko"
  }
}

// Response Example
{
  "success": true,
  "data": {
    "fortuneId": "uuid",
    "type": "daily",
    "content": {
      "summary": "오늘은 좋은 날입니다",
      "score": 85,
      "details": {...}
    },
    "generatedAt": "2024-01-01T00:00:00Z",
    "expiresAt": "2024-01-02T00:00:00Z"
  },
  "cached": false,
  "tokensUsed": 1
}
```

#### 4. Token Management
```typescript
GET    /api/user/tokens              - Get token balance
POST   /api/user/tokens/purchase     - Purchase tokens
GET    /api/user/token-history       - Token usage history
POST   /api/fortune/deduct-tokens    - Deduct tokens (internal)
```

#### 5. Payment
```typescript
POST   /api/payment/create-checkout  - Create payment session
POST   /api/payment/webhook/stripe   - Stripe webhook
POST   /api/payment/webhook/toss     - TossPay webhook
GET    /api/payment/history          - Payment history
```

#### 6. Admin Endpoints
```typescript
GET    /api/admin/token-usage        - Token usage analytics
GET    /api/admin/token-stats        - Token statistics
GET    /api/admin/redis-stats        - Cache statistics
POST   /api/cron/daily-batch         - Daily batch processing
```

### Rate Limiting
- **Free Users**: 10 requests/minute
- **Authenticated Users**: 60 requests/minute
- **Premium Users**: 100 requests/minute
- **Guest Users**: 5 requests/minute

### Error Responses
```typescript
{
  "error": "Error message",
  "code": "ERROR_CODE",
  "details": {...},
  "timestamp": "2024-01-01T00:00:00Z"
}

// Common Error Codes
- AUTHENTICATION_REQUIRED
- INSUFFICIENT_TOKENS
- RATE_LIMIT_EXCEEDED
- INVALID_REQUEST
- PROFILE_INCOMPLETE
- PAYMENT_FAILED
```

---

## Data Models

### 1. User Profile
```typescript
interface UserProfile {
  id: string;
  email: string;
  name: string;
  birth_date: string;          // YYYY-MM-DD
  birth_time?: string;         // Korean time period
  birth_hour?: string;         // Specific hour
  gender?: 'male' | 'female' | 'other';
  mbti?: string;               // 16 MBTI types
  zodiac_sign?: string;        // Western zodiac
  chinese_zodiac?: string;     // Eastern zodiac
  phone?: string;
  profile_image_url?: string;
  onboarding_completed: boolean;
  subscription_status: 'free' | 'basic' | 'premium' | 'enterprise';
  premium_until?: string;
  fortune_count: number;
  premium_fortunes_count: number;
  created_at: string;
  updated_at: string;
}
```

### 2. Fortune Data
```typescript
interface FortuneData {
  id: string;
  user_id: string;
  fortune_type: FortuneType;
  fortune_category: FortuneCategory;
  date: string;
  data: {
    summary: string;
    score: number;
    details: Record<string, any>;
    keywords: string[];
    luckyElements: {
      color: string;
      number: number;
      direction: string;
      time: string;
    };
  };
  generated_at: string;
  expires_at: string;
  cached: boolean;
  tokens_used: number;
}
```

### 3. Token System
```typescript
interface TokenBalance {
  user_id: string;
  balance: number;
  total_purchased: number;
  total_used: number;
  monthly_quota?: number;       // For subscription users
  quota_used?: number;
  last_purchase_at?: string;
  updated_at: string;
}

interface TokenTransaction {
  id: string;
  user_id: string;
  type: 'purchase' | 'usage' | 'refund' | 'bonus';
  amount: number;               // Positive for credit, negative for debit
  balance_after: number;
  fortune_type?: string;
  description: string;
  created_at: string;
}
```

### 4. Subscription
```typescript
interface Subscription {
  id: string;
  user_id: string;
  plan_type: 'basic' | 'premium' | 'enterprise';
  status: 'active' | 'cancelled' | 'expired' | 'trial';
  current_period_start: string;
  current_period_end: string;
  monthly_token_quota: number;
  tokens_used_this_period: number;
  cancel_at_period_end: boolean;
  payment_method: 'stripe' | 'toss';
  created_at: string;
  updated_at: string;
}
```

### 5. Fortune Types & Groups
```typescript
type FortuneGroupType = 
  | 'LIFE_PROFILE'           // Lifetime fixed (saju, personality)
  | 'DAILY_COMPREHENSIVE'    // Daily changing
  | 'INTERACTIVE'            // Real-time interaction
  | 'CLIENT_BASED'           // Client-side only
  | 'LOVE_PACKAGE'           // Love category (72hr cache)
  | 'CAREER_WEALTH_PACKAGE'  // Career/money (168hr cache)
  | 'LUCKY_ITEMS_PACKAGE'    // Lucky items (720hr cache)
  | 'LIFE_CAREER_PACKAGE';   // Life planning (168hr cache)
```

---

## Business Logic

### 1. Token Cost Calculation
```typescript
function getTokenCost(fortuneType: FortuneType): number {
  const costs = {
    // Simple fortunes (1 token)
    'daily': 1, 'today': 1, 'tomorrow': 1,
    'lucky-color': 1, 'lucky-number': 1,
    
    // Medium complexity (2 tokens)
    'love': 2, 'career': 2, 'wealth': 2,
    'compatibility': 2, 'biorhythm': 2,
    
    // Complex fortunes (3 tokens)
    'saju': 3, 'traditional-saju': 3,
    'marriage': 3, 'chemistry': 3,
    
    // Premium fortunes (5 tokens)
    'startup': 5, 'business': 5,
    'lucky-investment': 5, 'celebrity-match': 5
  };
  
  return costs[fortuneType] || 1;
}
```

### 2. Cache Strategy
```typescript
const cacheRules = {
  // Lifetime cache (never expires)
  'LIFE_PROFILE': null,
  
  // Daily cache (24 hours)
  'DAILY_COMPREHENSIVE': 24 * 60 * 60 * 1000,
  
  // Package-specific cache
  'LOVE_PACKAGE': 72 * 60 * 60 * 1000,      // 72 hours
  'CAREER_WEALTH_PACKAGE': 168 * 60 * 60 * 1000, // 1 week
  'LUCKY_ITEMS_PACKAGE': 720 * 60 * 60 * 1000,   // 30 days
  
  // No cache for interactive
  'INTERACTIVE': 0
};
```

### 3. Fortune Generation Algorithm
```
1. Validate user input and profile completeness
2. Check token balance (skip for unlimited users)
3. Check cache for existing fortune
4. If cached and valid, return cached result
5. Generate prompt based on:
   - User profile (birth data, MBTI, etc.)
   - Fortune type specifications
   - Cultural context (Korean fortune-telling traditions)
   - Current date/time for time-sensitive fortunes
6. Call OpenAI API with structured prompt
7. Parse and validate AI response
8. Apply post-processing:
   - Score normalization (0-100)
   - Lucky element generation
   - Keyword extraction
9. Cache result based on fortune type
10. Deduct tokens from user balance
11. Record usage analytics
12. Return formatted fortune
```

### 4. Subscription Benefits
```typescript
const subscriptionBenefits = {
  free: {
    tokenBalance: 'pay-per-use',
    adsEnabled: true,
    prioritySupport: false,
    exclusiveFortunes: false,
    batchGeneration: false
  },
  basic: {
    tokenBalance: 100, // monthly
    adsEnabled: true,
    prioritySupport: false,
    exclusiveFortunes: false,
    batchGeneration: true
  },
  premium: {
    tokenBalance: 'unlimited',
    adsEnabled: false,
    prioritySupport: true,
    exclusiveFortunes: true,
    batchGeneration: true
  }
};
```

---

## UI/UX Components

### 1. Core Layout Components
```
AppLayout
├── AppHeader
│   ├── Logo
│   ├── Navigation Menu
│   ├── Token Balance Display
│   └── User Profile Menu
├── MainContent
│   └── Page-specific content
└── BottomNavigation (Mobile)
    ├── Home
    ├── Fortune List
    ├── Profile
    └── Premium
```

### 2. Key Screens

#### Landing Page (`/`)
- Hero section with app introduction
- Feature highlights
- Authentication options
- Guest mode entry

#### Home Screen (`/home`)
- Today's fortune card
- Fortune service grid
- Recent fortunes
- Quick access buttons
- Personalized recommendations

#### Fortune List (`/fortune`)
- Categorized fortune services
- Search and filter
- Token cost indicators
- Premium badges

#### Fortune Detail Pages
- Loading animation (with ads for free users)
- Fortune content display
- Score visualizations
- Lucky elements
- Share functionality
- Related fortunes

#### Profile (`/profile`)
- User information
- Birth data
- Preferences
- Fortune history
- Token balance
- Subscription status

#### Payment (`/payment/tokens`)
- Token packages
- Subscription plans
- Payment method selection
- Purchase history

### 3. Component Library

#### Cards
- `FortuneCard` - Display fortune summaries
- `TokenPackageCard` - Show token purchase options
- `SubscriptionCard` - Display subscription tiers
- `ProfileCard` - User profile summary

#### Forms
- `UserInfoForm` - Birth data collection
- `PaymentForm` - Payment information
- `ProfileEditForm` - Profile updates

#### Modals
- `TokenPurchaseModal` - Quick token purchase
- `ShareModal` - Share fortune results
- `ProfileCompletionModal` - Complete profile reminder
- `AdModal` - Advertisement display

#### Animations
- Page transitions (Framer Motion)
- Loading states
- Fortune reveal animations
- Score meter animations

### 4. Design System

#### Colors
```scss
// Primary Colors
$primary: #8B5CF6;        // Purple
$secondary: #EC4899;      // Pink
$accent: #F59E0B;         // Amber

// Semantic Colors
$success: #10B981;        // Green
$warning: #F59E0B;        // Orange
$error: #EF4444;          // Red
$info: #3B82F6;           // Blue

// Neutral Colors
$gray-50: #F9FAFB;
$gray-900: #111827;
```

#### Typography
```scss
// Font Families
$font-primary: 'Pretendard', -apple-system, sans-serif;

// Font Sizes
$text-xs: 0.75rem;      // 12px
$text-sm: 0.875rem;     // 14px
$text-base: 1rem;       // 16px
$text-lg: 1.125rem;     // 18px
$text-xl: 1.25rem;      // 20px
$text-2xl: 1.5rem;      // 24px
```

#### Spacing
```scss
$space-1: 0.25rem;      // 4px
$space-2: 0.5rem;       // 8px
$space-3: 0.75rem;      // 12px
$space-4: 1rem;         // 16px
$space-6: 1.5rem;       // 24px
$space-8: 2rem;         // 32px
```

---

## Integration Points

### 1. External Services

#### OpenAI Integration
```typescript
// Configuration
{
  apiKey: process.env.OPENAI_API_KEY,
  model: 'gpt-4',
  temperature: 0.7,
  maxTokens: 2000,
  systemPrompt: 'Korean fortune teller context'
}
```

#### Supabase Integration
- Authentication (OAuth, Email/Password)
- Database (PostgreSQL)
- Real-time subscriptions
- File storage (profile images)
- Row Level Security (RLS)

#### Payment Integrations

**Stripe**
- International credit cards
- Subscription management
- Webhook handling
- Customer portal

**TossPay**
- Korean payment methods
- One-time payments
- Mobile payments

#### Redis Cache
- Fortune result caching
- Rate limiting
- Session management
- Real-time counters

#### Analytics
- Google Analytics 4
- Custom event tracking
- User behavior analysis
- Conversion tracking

### 2. Third-party Libraries

#### Core Dependencies
```json
{
  "next": "14.x",
  "react": "18.x",
  "typescript": "5.x",
  "@supabase/supabase-js": "2.x",
  "openai": "4.x",
  "stripe": "14.x",
  "redis": "4.x"
}
```

#### UI Libraries
```json
{
  "framer-motion": "10.x",
  "@radix-ui/react-*": "latest",
  "tailwindcss": "3.x",
  "lucide-react": "latest"
}
```

### 3. Environment Variables
```env
# App Configuration
NEXT_PUBLIC_APP_URL=
NEXT_PUBLIC_APP_NAME=

# Supabase
NEXT_PUBLIC_SUPABASE_URL=
NEXT_PUBLIC_SUPABASE_ANON_KEY=
SUPABASE_SERVICE_ROLE_KEY=

# OpenAI
OPENAI_API_KEY=

# Payment - Stripe
STRIPE_SECRET_KEY=
STRIPE_WEBHOOK_SECRET=
NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=

# Payment - TossPay
TOSS_SECRET_KEY=
NEXT_PUBLIC_TOSS_CLIENT_KEY=

# Redis
REDIS_URL=

# Security
INTERNAL_API_KEY=
CRON_SECRET=
JWT_SECRET=

# Analytics
NEXT_PUBLIC_GA_MEASUREMENT_ID=
```

---

## Security Implementation

### 1. Authentication & Authorization

#### Multi-layer Authentication
```typescript
// 1. Supabase Auth (Primary)
- Email/Password authentication
- OAuth providers (Google, Kakao, Naver)
- JWT token management
- Session handling

// 2. API Key Authentication (Admin/Internal)
- Header: x-api-key
- Used for admin endpoints
- Rotatable keys

// 3. Cron Secret (Scheduled Tasks)
- Header: x-cron-secret
- Validates scheduled job requests
```

#### Row Level Security (RLS)
```sql
-- Users can only access their own data
CREATE POLICY "Users can view own profile" 
ON user_profiles FOR SELECT 
USING (auth.uid() = user_id);

-- Similar policies for all user-related tables
```

### 2. API Security

#### Rate Limiting
```typescript
const rateLimits = {
  guest: { requests: 5, window: '1m' },
  free: { requests: 10, window: '1m' },
  authenticated: { requests: 60, window: '1m' },
  premium: { requests: 100, window: '1m' }
};
```

#### Request Validation
- Zod schema validation
- Input sanitization
- SQL injection prevention
- XSS protection

#### CORS Configuration
```typescript
const corsOptions = {
  origin: process.env.ALLOWED_ORIGINS?.split(','),
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization']
};
```

### 3. Data Protection

#### Encryption
- Passwords: Bcrypt hashing
- Sensitive data: AES-256 encryption
- API keys: Environment variables
- Payment data: PCI compliance via Stripe/TossPay

#### Privacy Controls
- GDPR compliance ready
- Data export functionality
- Account deletion
- Consent management

### 4. Security Headers
```typescript
const securityHeaders = {
  'X-Content-Type-Options': 'nosniff',
  'X-Frame-Options': 'DENY',
  'X-XSS-Protection': '1; mode=block',
  'Referrer-Policy': 'strict-origin-when-cross-origin',
  'Content-Security-Policy': "default-src 'self'"
};
```

### 5. Monitoring & Logging
- Error tracking (Sentry alternative)
- Security event logging
- Anomaly detection
- Rate limit violations
- Failed authentication attempts

---

## Migration Recommendations

### 1. Architecture Considerations for Flutter
- Implement Repository pattern for data layer
- Use BLoC or Riverpod for state management
- Create service classes for API communication
- Implement proper error handling and retry logic

### 2. Offline Capabilities
- Cache fortune results locally
- Implement sync mechanism
- Queue token deductions for offline mode
- Store user preferences locally

### 3. Platform-specific Features
- Biometric authentication
- Push notifications for daily fortunes
- Widget support for today's fortune
- Deep linking for fortune sharing

### 4. Performance Optimizations
- Lazy loading for fortune lists
- Image caching for UI assets
- Implement pagination for history
- Background fetch for daily updates

### 5. Testing Strategy
- Unit tests for business logic
- Widget tests for UI components
- Integration tests for API calls
- End-to-end tests for critical flows

---

## Appendix

### A. Fortune Generation Prompts Structure
Each fortune type has a specific prompt template that includes:
1. User context (birth data, MBTI, etc.)
2. Fortune-specific requirements
3. Output format specifications
4. Cultural considerations
5. Scoring guidelines

### B. Batch Processing Logic
Daily batch processing handles:
1. Pre-generating daily fortunes for active users
2. Cache warming for popular fortune types
3. Cleanup of expired data
4. Usage analytics aggregation

### C. Internationalization Plan
Future support planned for:
- English
- Japanese
- Chinese (Simplified/Traditional)
- Vietnamese

### D. Analytics Events
Key events tracked:
- User registration
- Onboarding completion
- Fortune generation
- Token purchase
- Subscription conversion
- Feature engagement

---

*This document serves as the complete blueprint for migrating the Fortune application from Next.js to Flutter. It encompasses all technical specifications, business logic, and implementation details required for a successful migration.*