import { NextRequest, NextResponse } from 'next/server';
import { createClient } from '@/lib/supabase/server';

export interface AuthenticatedRequest extends NextRequest {
  userId?: string;
  isGuest?: boolean;
}

export async function withAuth(
  request: NextRequest,
  handler: (req: AuthenticatedRequest) => Promise<NextResponse>
): Promise<NextResponse> {
  try {
    // Check for API key in development/admin endpoints
    const apiKey = request.headers.get('x-api-key');
    const expectedApiKey = process.env.INTERNAL_API_KEY;
    
    if (expectedApiKey && apiKey === expectedApiKey) {
      // Admin/internal access
      (request as AuthenticatedRequest).userId = 'admin';
      return handler(request as AuthenticatedRequest);
    }

    // Check for authenticated user via Supabase
    const supabase = createClient();
    const { data: { user }, error } = await supabase.auth.getUser();

    if (error || !user) {
      // Allow limited guest access for certain endpoints
      const pathname = request.nextUrl.pathname;
      const guestAllowedPaths = [
        '/api/fortune/daily',
        '/api/fortune/compatibility'
      ];
      
      if (guestAllowedPaths.some(path => pathname.includes(path))) {
        (request as AuthenticatedRequest).isGuest = true;
        return handler(request as AuthenticatedRequest);
      }

      return NextResponse.json(
        { error: 'Authentication required' },
        { status: 401 }
      );
    }

    // Authenticated user
    (request as AuthenticatedRequest).userId = user.id;
    return handler(request as AuthenticatedRequest);

  } catch (error) {
    console.error('Auth middleware error:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
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