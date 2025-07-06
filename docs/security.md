# Fortune App Security Documentation

## 🚨 CRITICAL SECURITY ALERT (2025년 7월 6일)

**🔴 URGENT**: 현재 Fortune 앱은 심각한 보안 취약점을 가지고 있습니다!
- 모든 API 엔드포인트가 인증 없이 공개
- OpenAI API 비용이 무제한으로 발생할 수 있음
- 즉각적인 조치가 필요합니다!

**WARNING**: The application currently has minimal security implementation. All API endpoints are publicly accessible without authentication. This document outlines the current state and planned security improvements.

## 🚨 Critical Security Issues

### 1. No Authentication on API Routes
- **Current State**: All `/api/*` endpoints are public
- **Risk Level**: HIGH
- **Impact**: Anyone can access fortune generation APIs, leading to potential abuse and cost overruns

### 2. No Rate Limiting
- **Current State**: Unlimited API calls allowed
- **Risk Level**: HIGH
- **Impact**: Vulnerable to DDoS attacks and excessive OpenAI API costs

### 3. Client-Side Secrets Exposure
- **Current State**: Some API calls made directly from client
- **Risk Level**: MEDIUM
- **Impact**: API keys could be exposed in browser

### 4. No Input Validation
- **Current State**: Limited validation on user inputs
- **Risk Level**: MEDIUM
- **Impact**: Potential for injection attacks or malformed data

## 🔒 Planned Security Implementation

### Phase 1: Authentication System (Priority: HIGH)

#### 1.1 API Authentication Middleware

```typescript
// middleware/auth.ts
import { NextRequest, NextResponse } from 'next/server';
import { verifyToken } from '@/lib/auth';

export async function authMiddleware(request: NextRequest) {
  const token = request.headers.get('Authorization')?.replace('Bearer ', '');
  
  if (!token) {
    return NextResponse.json(
      { error: 'Authentication required' },
      { status: 401 }
    );
  }
  
  try {
    const user = await verifyToken(token);
    // Add user to request context
    request.headers.set('X-User-Id', user.id);
    return NextResponse.next();
  } catch (error) {
    return NextResponse.json(
      { error: 'Invalid token' },
      { status: 401 }
    );
  }
}
```

#### 1.2 Supabase Auth Integration

```typescript
// lib/auth.ts
import { createClient } from '@supabase/supabase-js';

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_KEY!
);

export async function verifyToken(token: string) {
  const { data: { user }, error } = await supabase.auth.getUser(token);
  
  if (error || !user) {
    throw new Error('Invalid token');
  }
  
  return user;
}
```

#### 1.3 Protected API Routes

```typescript
// app/api/fortune/generate/route.ts
import { authMiddleware } from '@/middleware/auth';

export async function POST(request: Request) {
  // Apply auth middleware
  const authResponse = await authMiddleware(request);
  if (authResponse.status !== 200) {
    return authResponse;
  }
  
  // Continue with fortune generation
  // ...
}
```

### Phase 2: Rate Limiting (Priority: HIGH)

#### 2.1 Redis-based Rate Limiter

```typescript
// lib/rate-limit.ts
import Redis from 'ioredis';

const redis = new Redis(process.env.REDIS_URL!);

export async function rateLimit(
  identifier: string,
  limit: number = 100,
  window: number = 86400 // 24 hours
) {
  const key = `rate_limit:${identifier}`;
  const current = await redis.incr(key);
  
  if (current === 1) {
    await redis.expire(key, window);
  }
  
  if (current > limit) {
    return {
      success: false,
      limit,
      remaining: 0,
      reset: await redis.ttl(key)
    };
  }
  
  return {
    success: true,
    limit,
    remaining: limit - current,
    reset: await redis.ttl(key)
  };
}
```

#### 2.2 Rate Limit Middleware

```typescript
// middleware/rate-limit.ts
export async function rateLimitMiddleware(request: NextRequest) {
  const userId = request.headers.get('X-User-Id');
  const isPremiun = await checkPremiumStatus(userId);
  
  const limit = isPremium ? 1000 : 100;
  const result = await rateLimit(userId, limit);
  
  if (!result.success) {
    return NextResponse.json(
      {
        error: 'Rate limit exceeded',
        limit: result.limit,
        reset: result.reset
      },
      { 
        status: 429,
        headers: {
          'X-RateLimit-Limit': result.limit.toString(),
          'X-RateLimit-Remaining': '0',
          'X-RateLimit-Reset': result.reset.toString()
        }
      }
    );
  }
  
  return NextResponse.next();
}
```

### Phase 3: API Key Management (Priority: MEDIUM)

#### 3.1 API Key Generation

```typescript
// lib/api-keys.ts
import crypto from 'crypto';

export function generateAPIKey(): string {
  return `sk_${crypto.randomBytes(32).toString('hex')}`;
}

export async function createAPIKey(userId: string, name: string) {
  const key = generateAPIKey();
  const hashedKey = crypto
    .createHash('sha256')
    .update(key)
    .digest('hex');
  
  // Store hashed key in database
  await db.apiKeys.create({
    user_id: userId,
    name,
    key_hash: hashedKey,
    last_used: null,
    created_at: new Date()
  });
  
  return key; // Return only once for user to save
}
```

#### 3.2 API Key Validation

```typescript
// middleware/api-key.ts
export async function validateAPIKey(key: string) {
  const hashedKey = crypto
    .createHash('sha256')
    .update(key)
    .digest('hex');
  
  const apiKey = await db.apiKeys.findUnique({
    where: { key_hash: hashedKey }
  });
  
  if (!apiKey) {
    throw new Error('Invalid API key');
  }
  
  // Update last used
  await db.apiKeys.update({
    where: { id: apiKey.id },
    data: { last_used: new Date() }
  });
  
  return apiKey;
}
```

### Phase 4: Input Validation & Sanitization (Priority: MEDIUM)

#### 4.1 Request Validation Schema

```typescript
// lib/validation.ts
import { z } from 'zod';

export const userProfileSchema = z.object({
  name: z.string().min(1).max(50),
  birth_date: z.string().regex(/^\d{4}-\d{2}-\d{2}$/),
  birth_time: z.string().optional(),
  gender: z.enum(['남성', '여성', '선택 안함']),
  mbti: z.string().regex(/^[EI][NS][TF][JP]$/).optional()
});

export const fortuneRequestSchema = z.object({
  request_type: z.enum(['onboarding_complete', 'daily_refresh', 'user_direct_request']),
  user_profile: userProfileSchema,
  fortune_categories: z.array(z.string()).optional()
});
```

#### 4.2 Validation Middleware

```typescript
// middleware/validation.ts
export function validateRequest(schema: ZodSchema) {
  return async (request: NextRequest) => {
    try {
      const body = await request.json();
      const validated = schema.parse(body);
      request.validated = validated;
      return NextResponse.next();
    } catch (error) {
      return NextResponse.json(
        { error: 'Invalid request data', details: error },
        { status: 400 }
      );
    }
  };
}
```

### Phase 5: Security Headers (Priority: LOW)

#### 5.1 Security Headers Configuration

```typescript
// next.config.js
module.exports = {
  async headers() {
    return [
      {
        source: '/api/:path*',
        headers: [
          {
            key: 'X-Content-Type-Options',
            value: 'nosniff'
          },
          {
            key: 'X-Frame-Options',
            value: 'DENY'
          },
          {
            key: 'X-XSS-Protection',
            value: '1; mode=block'
          },
          {
            key: 'Referrer-Policy',
            value: 'strict-origin-when-cross-origin'
          },
          {
            key: 'Permissions-Policy',
            value: 'camera=(), microphone=(), geolocation=()'
          }
        ]
      }
    ];
  }
};
```

### Phase 6: CORS Configuration (Priority: MEDIUM)

```typescript
// middleware/cors.ts
const allowedOrigins = [
  process.env.NEXT_PUBLIC_APP_URL,
  'https://fortune-explorer.vercel.app'
];

export function corsMiddleware(request: NextRequest) {
  const origin = request.headers.get('origin');
  
  if (!origin || !allowedOrigins.includes(origin)) {
    return new Response('CORS error', { status: 403 });
  }
  
  return NextResponse.next({
    headers: {
      'Access-Control-Allow-Origin': origin,
      'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type, Authorization',
      'Access-Control-Max-Age': '86400'
    }
  });
}
```

## 🛡️ Security Best Practices

### 1. Environment Variables
```env
# .env.local
NEXT_PUBLIC_SUPABASE_URL=xxx        # Public
NEXT_PUBLIC_SUPABASE_ANON_KEY=xxx   # Public
SUPABASE_SERVICE_KEY=xxx            # Secret - Never expose
OPENAI_API_KEY=xxx                  # Secret - Never expose
REDIS_URL=xxx                       # Secret - Never expose
```

### 2. API Key Storage
- Never store API keys in code
- Use environment variables
- Rotate keys regularly
- Monitor key usage

### 3. Data Protection
- Encrypt sensitive data at rest
- Use HTTPS for all communications
- Implement proper session management
- Regular security audits

### 4. Error Handling
```typescript
// Never expose internal errors
try {
  // ... operation
} catch (error) {
  console.error('Internal error:', error);
  return NextResponse.json(
    { error: 'An error occurred' },
    { status: 500 }
  );
}
```

## 📊 Security Monitoring

### 1. Logging Strategy
```typescript
// lib/security-logger.ts
export async function logSecurityEvent(event: {
  type: 'auth_failure' | 'rate_limit' | 'invalid_input';
  userId?: string;
  ip?: string;
  details?: any;
}) {
  await db.securityLogs.create({
    data: {
      ...event,
      timestamp: new Date()
    }
  });
  
  // Alert on suspicious patterns
  if (await detectSuspiciousActivity(event)) {
    await sendSecurityAlert(event);
  }
}
```

### 2. Metrics to Track
- Failed authentication attempts
- Rate limit violations
- Unusual API usage patterns
- Error rates by endpoint
- Response times

## 🚀 Implementation Roadmap

### Q1 2025
1. **Week 1-2**: Implement authentication middleware
2. **Week 3-4**: Add rate limiting
3. **Week 5-6**: Deploy and monitor

### Q2 2025
1. **Month 1**: API key management system
2. **Month 2**: Enhanced input validation
3. **Month 3**: Security audit and penetration testing

## 🔍 Security Checklist

- [ ] Authentication on all API routes
- [ ] Rate limiting implemented
- [ ] Input validation on all endpoints
- [ ] CORS properly configured
- [ ] Security headers in place
- [ ] API keys properly managed
- [ ] Logging and monitoring active
- [ ] Regular security audits scheduled
- [ ] Incident response plan created
- [ ] Data encryption implemented

---

*Last updated: 2025-07-06*
*Security Status: ⚠️ Critical improvements needed*