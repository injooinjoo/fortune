# Redis Rate Limiting Guide

This guide explains how to set up and use Redis-based rate limiting for the Fortune Edge Functions.

## Overview

The Redis rate limiting system provides distributed rate limiting across all Edge Function instances, ensuring consistent rate limits even in a scaled environment.

## Features

- **Distributed Rate Limiting**: Works across multiple Edge Function instances
- **Graceful Fallback**: Falls back to in-memory rate limiting if Redis is unavailable
- **Multiple Limiters**: Pre-configured limiters for different use cases
- **Custom Key Generation**: Support for IP-based, user-based, or custom keys
- **Automatic Headers**: Rate limit headers included in all responses

## Setup

### 1. Upstash Redis Setup

1. Create an account at [Upstash](https://upstash.com)
2. Create a new Redis database
3. Copy your REST URL and token from the dashboard

### 2. Environment Variables

Add these to your Supabase Edge Functions environment:

```bash
# Production
supabase secrets set UPSTASH_REDIS_REST_URL=https://your-database.upstash.io
supabase secrets set UPSTASH_REDIS_REST_TOKEN=your-token-here

# Local development
echo "UPSTASH_REDIS_REST_URL=https://your-database.upstash.io" >> .env.local
echo "UPSTASH_REDIS_REST_TOKEN=your-token-here" >> .env.local
```

### 3. Import and Use

```typescript
import { redisRateLimiters, applyRateLimitHeaders } from '../_shared/redis-rate-limit.ts'

serve(async (req: Request) => {
  // Apply rate limiting
  const rateLimitResponse = await redisRateLimiters.fortune.createMiddleware()(req)
  if (rateLimitResponse) return rateLimitResponse

  // Your function logic here...

  // Apply rate limit headers to response
  const response = new Response(/* ... */)
  return applyRateLimitHeaders(req, response)
})
```

## Pre-configured Limiters

### General API Rate Limit
```typescript
redisRateLimiters.general
// 60 requests per minute
```

### Strict Rate Limit (Expensive Operations)
```typescript
redisRateLimiters.strict
// 10 requests per minute
```

### Fortune Generation
```typescript
redisRateLimiters.fortune
// 20 fortunes per minute per user
```

### Authentication
```typescript
redisRateLimiters.auth
// 5 attempts per 15 minutes per IP
```

### Payment Verification
```typescript
redisRateLimiters.payment
// 5 verifications per minute
```

## Custom Rate Limiters

Create custom rate limiters for specific needs:

```typescript
import { RedisRateLimiter } from '../_shared/redis-rate-limit.ts'

const customLimiter = new RedisRateLimiter({
  windowMs: 5 * 60 * 1000,  // 5 minutes
  max: 100,                 // 100 requests
  keyPrefix: 'rl:custom:',  // Redis key prefix
})

// With custom key generator
const ipBasedLimiter = new RedisRateLimiter({
  windowMs: 60 * 1000,
  max: 30,
  keyPrefix: 'rl:ip:',
}).createMiddleware((req) => {
  // Use only IP address
  return req.headers.get('x-forwarded-for') || 'unknown'
})
```

## Response Headers

All rate-limited responses include these headers:

```
X-RateLimit-Limit: 20        # Maximum requests allowed
X-RateLimit-Remaining: 15    # Remaining requests in window
X-RateLimit-Reset: 2024-01-15T10:30:00.000Z  # Window reset time
Retry-After: 45              # Seconds to wait (only on 429 responses)
```

## Error Responses

When rate limit is exceeded:

```json
{
  "error": "Too Many Requests",
  "message": "Rate limit exceeded. Please try again later.",
  "retryAfter": 45
}
```

## Monitoring

### Redis Dashboard

Monitor rate limiting in the Upstash dashboard:
- Current memory usage
- Command statistics
- Key patterns

### Custom Monitoring

```typescript
// Check current rate limit status
const result = await redisRateLimiters.fortune.checkLimit(userId)
console.log({
  allowed: result.allowed,
  remaining: result.remaining,
  resetTime: new Date(result.resetTime)
})
```

## Best Practices

1. **Choose Appropriate Windows**: Balance between user experience and resource protection
2. **Set Reasonable Limits**: Based on actual usage patterns
3. **Use Different Limiters**: Apply strict limits to expensive operations
4. **Monitor Usage**: Adjust limits based on real-world usage
5. **Handle Failures Gracefully**: The system fails open (allows requests) if Redis is down

## Troubleshooting

### Redis Connection Issues

If you see "Rate limiting will fall back to in-memory" warnings:
1. Check your Upstash credentials
2. Verify network connectivity
3. Check Upstash service status

### Inconsistent Rate Limits

If limits seem inconsistent:
1. Ensure all functions use Redis (not mixed with in-memory)
2. Check clock synchronization
3. Verify key generation logic

### Performance Issues

If rate limiting adds latency:
1. Check Redis region (use closest region)
2. Consider increasing limits
3. Monitor Redis response times

## Migration from In-Memory

To migrate existing functions:

1. Replace imports:
```typescript
// Old
import { rateLimiters } from '../_shared/rate-limit.ts'

// New
import { redisRateLimiters } from '../_shared/redis-rate-limit.ts'
```

2. Update middleware usage:
```typescript
// Old
rateLimiters.fortune.createMiddleware()

// New
redisRateLimiters.fortune.createMiddleware()
```

3. Add header application to all responses:
```typescript
return applyRateLimitHeaders(req, response)
```

## Cost Considerations

Upstash Redis pricing:
- Pay-per-request model
- First 10,000 commands free daily
- Rate limiting typically uses 2-3 commands per request
- Monitor usage to estimate costs

## Security Considerations

1. **Don't expose Redis credentials**: Use environment variables
2. **Validate key generation**: Ensure keys can't be manipulated
3. **Set appropriate limits**: Too high defeats the purpose
4. **Monitor for abuse**: Watch for patterns of limit circumvention