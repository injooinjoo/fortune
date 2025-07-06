import { NextRequest, NextResponse } from 'next/server';

// Simple in-memory rate limiter (will reset on deployment)
// For production, use Upstash Redis
const rateLimitMap = new Map<string, { count: number; resetTime: number }>();

interface RateLimitOptions {
  limit?: number;
  windowMs?: number;
}

export async function withRateLimit(
  request: NextRequest,
  handler: () => Promise<NextResponse>,
  options: RateLimitOptions = {}
): Promise<NextResponse> {
  const { limit = 10, windowMs = 60000 } = options; // Default: 10 requests per minute
  
  // Get client identifier (IP or user ID)
  const forwarded = request.headers.get('x-forwarded-for');
  const ip = forwarded ? forwarded.split(',')[0] : 'unknown';
  const clientId = ip;
  
  const now = Date.now();
  const clientData = rateLimitMap.get(clientId);
  
  if (!clientData || now > clientData.resetTime) {
    // First request or window expired
    rateLimitMap.set(clientId, {
      count: 1,
      resetTime: now + windowMs
    });
    return handler();
  }
  
  if (clientData.count >= limit) {
    // Rate limit exceeded
    const retryAfter = Math.ceil((clientData.resetTime - now) / 1000);
    
    return NextResponse.json(
      { 
        error: 'Too many requests',
        retryAfter 
      },
      { 
        status: 429,
        headers: {
          'X-RateLimit-Limit': limit.toString(),
          'X-RateLimit-Remaining': '0',
          'X-RateLimit-Reset': clientData.resetTime.toString(),
          'Retry-After': retryAfter.toString()
        }
      }
    );
  }
  
  // Increment counter
  clientData.count++;
  return handler();
}

// Cleanup old entries periodically (every 5 minutes)
setInterval(() => {
  const now = Date.now();
  for (const [key, value] of rateLimitMap.entries()) {
    if (now > value.resetTime + 300000) { // 5 minutes after reset time
      rateLimitMap.delete(key);
    }
  }
}, 300000);