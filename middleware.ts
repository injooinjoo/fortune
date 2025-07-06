import { NextRequest, NextResponse } from 'next/server';

// Rate limiting configuration
const RATE_LIMIT_WINDOW = 60000; // 1 minute
const RATE_LIMIT_MAX = 10; // 10 requests per minute

// Simple in-memory store (resets on deployment)
const rateLimitStore = new Map<string, { count: number; resetTime: number }>();

export async function middleware(request: NextRequest) {
  // Only apply to API routes
  if (!request.nextUrl.pathname.startsWith('/api/')) {
    return NextResponse.next();
  }

  // Get client IP
  const forwarded = request.headers.get('x-forwarded-for');
  const ip = forwarded ? forwarded.split(',')[0] : 'unknown';
  
  // Apply rate limiting to fortune endpoints
  if (request.nextUrl.pathname.startsWith('/api/fortune/')) {
    const now = Date.now();
    const clientData = rateLimitStore.get(ip) || { count: 0, resetTime: now + RATE_LIMIT_WINDOW };
    
    // Reset if window expired
    if (now > clientData.resetTime) {
      clientData.count = 0;
      clientData.resetTime = now + RATE_LIMIT_WINDOW;
    }
    
    // Check rate limit
    if (clientData.count >= RATE_LIMIT_MAX) {
      const retryAfter = Math.ceil((clientData.resetTime - now) / 1000);
      
      return NextResponse.json(
        { 
          error: 'Too many requests. Please try again later.',
          retryAfter 
        },
        { 
          status: 429,
          headers: {
            'X-RateLimit-Limit': RATE_LIMIT_MAX.toString(),
            'X-RateLimit-Remaining': '0',
            'X-RateLimit-Reset': clientData.resetTime.toString(),
            'Retry-After': retryAfter.toString()
          }
        }
      );
    }
    
    // Increment counter
    clientData.count++;
    rateLimitStore.set(ip, clientData);
    
    // Add rate limit headers to response
    const response = NextResponse.next();
    response.headers.set('X-RateLimit-Limit', RATE_LIMIT_MAX.toString());
    response.headers.set('X-RateLimit-Remaining', (RATE_LIMIT_MAX - clientData.count).toString());
    response.headers.set('X-RateLimit-Reset', clientData.resetTime.toString());
    
    return response;
  }

  return NextResponse.next();
}

export const config = {
  matcher: [
    '/api/:path*',
  ],
};

// Cleanup old entries periodically
if (typeof global !== 'undefined' && !global.rateLimitCleanupInterval) {
  global.rateLimitCleanupInterval = setInterval(() => {
    const now = Date.now();
    for (const [key, value] of rateLimitStore.entries()) {
      if (now > value.resetTime + 300000) { // 5 minutes after reset
        rateLimitStore.delete(key);
      }
    }
  }, 300000); // Every 5 minutes
}