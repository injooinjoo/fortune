import { NextRequest, NextResponse } from 'next/server';
import { createServerClient } from '@supabase/ssr';
import { logger } from '@/lib/logger';

// Rate limiting configuration by endpoint type
const RATE_LIMITS = {
  '/api/fortune/generate-batch': { max: 2, window: 3600000 }, // 2 per hour for batch
  '/api/fortune/': { max: 10, window: 60000 }, // 10 per minute for regular fortune
  '/api/payment/': { max: 5, window: 60000 }, // 5 payment requests per minute
  '/api/': { max: 20, window: 60000 }, // 20 per minute for other APIs
};

// Simple in-memory store (resets on deployment)
const rateLimitStore = new Map<string, { count: number; resetTime: number }>();

export async function middleware(request: NextRequest) {
  const { pathname } = request.nextUrl;
  
  // Skip middleware for auth routes to prevent interference
  if (pathname.startsWith('/auth/')) {
    logger.info('🔓 Skipping middleware for auth route:', pathname);
    return NextResponse.next();
  }
  
  // Protected routes that require authentication
  const protectedRoutes = [
    '/fortune',
    '/home',
    '/profile',
    '/settings'
  ];
  
  // Check if the current path requires authentication
  const isProtectedRoute = protectedRoutes.some(route => pathname.startsWith(route));
  
  if (isProtectedRoute) {
    // Create Supabase client for server-side auth check
    const supabase = createServerClient(
      process.env.NEXT_PUBLIC_SUPABASE_URL!,
      process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
      {
        cookies: {
          get(name: string) {
            return request.cookies.get(name)?.value;
          },
          set() {
            // Not needed for auth checks
          },
          remove() {
            // Not needed for auth checks
          },
        },
      }
    );

    try {
      const { data: { session }, error } = await supabase.auth.getSession();
      
      if (error || !session?.user) {
        // Redirect to main page if not authenticated
        const loginUrl = new URL('/', request.url);
        loginUrl.searchParams.set('returnUrl', pathname);
        return NextResponse.redirect(loginUrl);
      }
    } catch (error) {
      logger.error('Middleware auth check failed:', error);
      // Redirect to main page on auth error
      const loginUrl = new URL('/', request.url);
      loginUrl.searchParams.set('returnUrl', pathname);
      return NextResponse.redirect(loginUrl);
    }
  }

  const response = NextResponse.next();

  // Add security headers to all requests
  response.headers.set('X-Content-Type-Options', 'nosniff');
  response.headers.set('X-Frame-Options', 'DENY');  
  response.headers.set('X-XSS-Protection', '1; mode=block');
  response.headers.set('Referrer-Policy', 'strict-origin-when-cross-origin');
  response.headers.set('Permissions-Policy', 'camera=(), microphone=(), geolocation=()');

  // Handle CORS for API routes
  if (pathname.startsWith('/api/')) {
    const origin = request.headers.get('origin');
    const allowedOrigins = [
      process.env.NEXT_PUBLIC_VERCEL_URL ? `https://${process.env.NEXT_PUBLIC_VERCEL_URL}` : null,
      process.env.NEXT_PUBLIC_APP_URL,
      'http://localhost:3000',
      'http://localhost:9002',
    ].filter(Boolean);

    // Handle preflight OPTIONS requests
    if (request.method === 'OPTIONS') {
      return new Response(null, {
        status: 200,
        headers: {
          'Access-Control-Allow-Origin': allowedOrigins.includes(origin || '') ? origin! : allowedOrigins[0] || '*',
          'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
          'Access-Control-Allow-Headers': 'Content-Type, Authorization, X-API-Key, X-Cron-Secret',
          'Access-Control-Allow-Credentials': 'true',
          'Access-Control-Max-Age': '86400',
        },
      });
    }

    // Set CORS headers for actual requests
    if (origin && allowedOrigins.includes(origin)) {
      response.headers.set('Access-Control-Allow-Origin', origin);
      response.headers.set('Access-Control-Allow-Credentials', 'true');
    }

    // Apply rate limiting to API routes
    const rateLimitResult = applyRateLimit(request, pathname);
    if (rateLimitResult) {
      return rateLimitResult;
    }

    // Add rate limit headers to successful responses
    addRateLimitHeaders(response, request, pathname);
  }

  return response;
}

function applyRateLimit(request: NextRequest, pathname: string): NextResponse | null {
  // Skip rate limiting for system requests
  const apiKey = request.headers.get('x-api-key');
  const cronSecret = request.headers.get('x-cron-secret');
  if (apiKey === process.env.INTERNAL_API_KEY || cronSecret === process.env.CRON_SECRET) {
    return null;
  }

  // Find matching rate limit configuration
  const rateLimitConfig = Object.entries(RATE_LIMITS)
    .filter(([path]) => pathname.startsWith(path))
    .sort((a, b) => b[0].length - a[0].length)[0]; // Most specific path first

  if (!rateLimitConfig) {
    return null; // No rate limiting for this path
  }

  const [, config] = rateLimitConfig;
  
  // Get client identifier
  const forwarded = request.headers.get('x-forwarded-for');
  const realIp = request.headers.get('x-real-ip');
  const ip = forwarded ? forwarded.split(',')[0].trim() : realIp || 'unknown';
  
  const clientKey = `${ip}:${pathname.split('/').slice(0, 3).join('/')}`; // Group by API section
  
  const now = Date.now();
  const clientData = rateLimitStore.get(clientKey) || { count: 0, resetTime: now + config.window };
  
  // Reset if window expired
  if (now > clientData.resetTime) {
    clientData.count = 0;
    clientData.resetTime = now + config.window;
  }
  
  // Check rate limit
  if (clientData.count >= config.max) {
    const retryAfter = Math.ceil((clientData.resetTime - now) / 1000);
    
    // Log rate limit violations for monitoring
    logger.warn(`Rate limit exceeded for ${clientKey}: ${clientData.count}/${config.max}`);
    
    return NextResponse.json(
      { 
        error: 'Too many requests. Please wait before trying again.',
        retryAfter,
        limit: config.max,
        message: 'Rate limit exceeded. Please try again later or consider upgrading for higher limits.'
      },
      { 
        status: 429,
        headers: {
          'X-RateLimit-Limit': config.max.toString(),
          'X-RateLimit-Remaining': '0',
          'X-RateLimit-Reset': clientData.resetTime.toString(),
          'Retry-After': retryAfter.toString(),
          'X-RateLimit-Policy': 'global',
        }
      }
    );
  }
  
  // Increment counter
  clientData.count++;
  rateLimitStore.set(clientKey, clientData);
  
  return null; // No rate limit violation
}

function addRateLimitHeaders(response: NextResponse, request: NextRequest, pathname: string): void {
  const rateLimitConfig = Object.entries(RATE_LIMITS)
    .filter(([path]) => pathname.startsWith(path))
    .sort((a, b) => b[0].length - a[0].length)[0];

  if (!rateLimitConfig) return;

  const [, config] = rateLimitConfig;
  const forwarded = request.headers.get('x-forwarded-for');
  const realIp = request.headers.get('x-real-ip');
  const ip = forwarded ? forwarded.split(',')[0].trim() : realIp || 'unknown';
  const clientKey = `${ip}:${pathname.split('/').slice(0, 3).join('/')}`;
  
  const clientData = rateLimitStore.get(clientKey);
  if (clientData) {
    response.headers.set('X-RateLimit-Limit', config.max.toString());
    response.headers.set('X-RateLimit-Remaining', Math.max(0, config.max - clientData.count).toString());
    response.headers.set('X-RateLimit-Reset', clientData.resetTime.toString());
  }
}

export const config = {
  matcher: [
    '/api/:path*',
    '/auth/:path*',
    '/fortune/:path*',
    '/home/:path*',
    '/profile/:path*',
    '/settings/:path*',
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