import { NextRequest, NextResponse } from 'next/server';
import { createServerClient } from '@supabase/ssr';

export interface AuthenticatedRequest extends NextRequest {
  userId?: string;
  userEmail?: string;
  isPremium?: boolean;
}

export async function withAuth(
  request: NextRequest,
  handler: (req: AuthenticatedRequest) => Promise<NextResponse>
): Promise<NextResponse> {
  try {
    // Check for API key in development/admin endpoints
    const apiKey = request.headers.get('x-api-key');
    const cronSecret = request.headers.get('x-cron-secret');
    const expectedApiKey = process.env.INTERNAL_API_KEY;
    const expectedCronSecret = process.env.CRON_SECRET;
    
    // Admin/internal/cron access
    if ((expectedApiKey && apiKey === expectedApiKey) || 
        (expectedCronSecret && cronSecret === expectedCronSecret)) {
      (request as AuthenticatedRequest).userId = 'system';
      return handler(request as AuthenticatedRequest);
    }

    // Create Supabase client for server-side auth
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

    // Check for Bearer token in Authorization header
    const authHeader = request.headers.get('authorization');
    let user = null;
    let error = null;

    if (authHeader && authHeader.startsWith('Bearer ')) {
      const token = authHeader.substring(7);
      const result = await supabase.auth.getUser(token);
      user = result.data.user;
      error = result.error;
    } else {
      // Fallback to session from cookies
      const result = await supabase.auth.getUser();
      user = result.data.user;
      error = result.error;
    }

    if (error || !user) {
      // 인증되지 않은 사용자는 로그인 필요
      return NextResponse.json(
        { 
          error: '로그인이 필요합니다.',
          code: 'AUTHENTICATION_REQUIRED',
          requireAuth: true
        },
        { status: 401 }
      );
    }

    // Check premium status
    const { data: profile } = await supabase
      .from('user_profiles')
      .select('premium_until')
      .eq('id', user.id)
      .single();

    const isPremium = profile?.premium_until && new Date(profile.premium_until) > new Date();

    // Authenticated user
    (request as AuthenticatedRequest).userId = user.id;
    (request as AuthenticatedRequest).userEmail = user.email;
    (request as AuthenticatedRequest).isPremium = isPremium;
    
    return handler(request as AuthenticatedRequest);

  } catch (error) {
    console.error('Auth middleware error:', error);
    return NextResponse.json(
      { error: 'Authentication service temporarily unavailable' },
      { status: 503 }
    );
  }
}

// Simple API key validation for critical endpoints
export function validateApiKey(request: NextRequest): boolean {
  const apiKey = request.headers.get('x-api-key');
  const expectedApiKey = process.env.INTERNAL_API_KEY;
  
  if (!expectedApiKey) {
    console.error('INTERNAL_API_KEY not configured');
    return false;
  }
  
  return apiKey === expectedApiKey;
}