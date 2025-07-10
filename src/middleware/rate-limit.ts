import { logger } from '@/lib/logger';
import { NextRequest, NextResponse } from 'next/server';
import { getRateLimiters, isRedisAvailable } from '@/lib/redis';

// Fallback in-memory rate limiter for when Redis is not available
const rateLimitMap = new Map<string, { count: number; resetTime: number }>();

interface RateLimitOptions {
  limit?: number;
  windowMs?: number;
  premiumLimit?: number;
  skipForSystem?: boolean;
}

export async function withRateLimit(
  request: NextRequest,
  handler: () => Promise<NextResponse>,
  options: RateLimitOptions = {}
): Promise<NextResponse> {
  const { 
    limit = 10, 
    windowMs = 60000, // Default: 10 requests per minute
    premiumLimit = 100, 
    skipForSystem = true 
  } = options;
  
  // Skip rate limiting for system/admin requests
  if (skipForSystem) {
    const apiKey = request.headers.get('x-api-key');
    const cronSecret = request.headers.get('x-cron-secret');
    if (apiKey === process.env.INTERNAL_API_KEY || 
        cronSecret === process.env.CRON_SECRET) {
      return handler();
    }
  }

  // Get client identifier and user info
  const forwarded = request.headers.get('x-forwarded-for');
  const realIp = request.headers.get('x-real-ip');
  const ip = forwarded ? forwarded.split(',')[0].trim() : realIp || 'unknown';
  
  // Use user ID if available, otherwise fall back to IP
  const userId = (request as any).userId;
  const isPremium = (request as any).isPremium;
  const isGuest = (request as any).isGuest;
  
  const clientId = userId && userId !== 'guest' ? `user:${userId}` : `ip:${ip}`;
  
  // Try to use Redis-based rate limiting
  if (isRedisAvailable()) {
    const rateLimiters = getRateLimiters();
    
    // Select appropriate rate limiter based on user type
    let rateLimiter;
    if (isPremium && rateLimiters.premium) {
      rateLimiter = rateLimiters.premium;
    } else if (isGuest && rateLimiters.guest) {
      rateLimiter = rateLimiters.guest;
    } else if (rateLimiters.standard) {
      rateLimiter = rateLimiters.standard;
    }
    
    if (rateLimiter) {
      try {
        const { success, limit: effectiveLimit, remaining, reset } = await rateLimiter.limit(clientId);
        
        if (!success) {
          const retryAfter = Math.ceil((reset - Date.now()) / 1000);
          
          // Log rate limit violations for monitoring
          logger.warn(`Rate limit exceeded for ${clientId} (Redis)`);
          
          return NextResponse.json(
            { 
              error: 'Too many requests. Please wait before trying again.',
              retryAfter,
              limit: effectiveLimit,
              message: isPremium ? 'Premium rate limit exceeded' : 
                      isGuest ? 'Guest users have limited access. Please sign in for higher limits.' :
                      'Rate limit exceeded. Consider upgrading to premium for higher limits.'
            },
            { 
              status: 429,
              headers: {
                'X-RateLimit-Limit': effectiveLimit.toString(),
                'X-RateLimit-Remaining': remaining.toString(),
                'X-RateLimit-Reset': reset.toString(),
                'Retry-After': retryAfter.toString(),
                'X-RateLimit-Policy': isPremium ? 'premium' : 'standard'
              }
            }
          );
        }
        
        // Request allowed - add headers and continue
        const response = await handler();
        response.headers.set('X-RateLimit-Limit', effectiveLimit.toString());
        response.headers.set('X-RateLimit-Remaining', remaining.toString());
        response.headers.set('X-RateLimit-Reset', reset.toString());
        return response;
        
      } catch (error) {
        logger.error('Redis rate limiting error:', error);
        // Fall through to in-memory rate limiting
      }
    }
  }
  
  // Fallback to in-memory rate limiting if Redis is not available
  logger.info('Using in-memory rate limiting (Redis not available)');
  
  // Determine rate limit based on user type
  let effectiveLimit = limit;
  if (isPremium) {
    effectiveLimit = premiumLimit;
  } else if (isGuest) {
    effectiveLimit = Math.floor(limit / 2); // Stricter limits for guests
  }
  
  const now = Date.now();
  const clientData = rateLimitMap.get(clientId);
  
  if (!clientData || now > clientData.resetTime) {
    // First request or window expired
    rateLimitMap.set(clientId, {
      count: 1,
      resetTime: now + windowMs
    });
    return addRateLimitHeaders(handler(), effectiveLimit, effectiveLimit - 1, clientData?.resetTime || now + windowMs);
  }
  
  if (clientData.count >= effectiveLimit) {
    // Rate limit exceeded
    const retryAfter = Math.ceil((clientData.resetTime - now) / 1000);
    
    // Log rate limit violations for monitoring
    logger.warn(`Rate limit exceeded for ${clientId} (in-memory): ${clientData.count}/${effectiveLimit}`);
    
    return NextResponse.json(
      { 
        error: 'Too many requests. Please wait before trying again.',
        retryAfter,
        limit: effectiveLimit,
        message: isPremium ? 'Premium rate limit exceeded' : 
                isGuest ? 'Guest users have limited access. Please sign in for higher limits.' :
                'Rate limit exceeded. Consider upgrading to premium for higher limits.'
      },
      { 
        status: 429,
        headers: {
          'X-RateLimit-Limit': effectiveLimit.toString(),
          'X-RateLimit-Remaining': '0',
          'X-RateLimit-Reset': clientData.resetTime.toString(),
          'Retry-After': retryAfter.toString(),
          'X-RateLimit-Policy': isPremium ? 'premium' : isGuest ? 'guest' : 'standard'
        }
      }
    );
  }
  
  // Increment counter
  clientData.count++;
  const remaining = effectiveLimit - clientData.count;
  
  return addRateLimitHeaders(handler(), effectiveLimit, remaining, clientData.resetTime);
}

function addRateLimitHeaders(
  response: Promise<NextResponse>, 
  limit: number, 
  remaining: number, 
  resetTime: number
): Promise<NextResponse> {
  return response.then(res => {
    res.headers.set('X-RateLimit-Limit', limit.toString());
    res.headers.set('X-RateLimit-Remaining', remaining.toString());
    res.headers.set('X-RateLimit-Reset', resetTime.toString());
    return res;
  });
}

// Cleanup old entries periodically (every 5 minutes) - only for in-memory fallback
if (typeof window === 'undefined') {
  setInterval(() => {
    const now = Date.now();
    for (const [key, value] of rateLimitMap.entries()) {
      if (now > value.resetTime + 300000) { // 5 minutes after reset time
        rateLimitMap.delete(key);
      }
    }
  }, 300000);
}