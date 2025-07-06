import { NextRequest } from 'next/server';
import { POST } from '@/app/api/fortune/generate-batch/route';

// Mock dependencies
jest.mock('@/lib/supabase-server', () => ({
  createServerClient: jest.fn(() => ({
    auth: {
      getUser: jest.fn(() => ({
        data: { user: { id: 'test-user-123', email: 'test@example.com' } },
        error: null
      }))
    },
    from: jest.fn(() => ({
      insert: jest.fn(() => ({ error: null }))
    }))
  }))
}));

jest.mock('@/lib/services/centralized-fortune-service', () => ({
  centralizedFortuneService: {
    callGenkitFortuneAPI: jest.fn(() => Promise.resolve({
      request_id: 'test-batch-123',
      user_id: 'test-user-123',
      request_type: 'daily_refresh',
      generated_at: new Date().toISOString(),
      analysis_results: {
        daily: { content: 'Today is your lucky day!' },
        tomorrow: { content: 'Tomorrow will be great!' }
      },
      cache_info: {
        expires_at: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(),
        cache_key: 'test-cache-key'
      },
      token_usage: {
        prompt_tokens: 100,
        completion_tokens: 200,
        total_tokens: 300,
        estimated_cost: 0.0015
      }
    }))
  }
}));

// Helper function to create mock NextRequest
const createMockRequest = (body: any, headers: Record<string, string> = {}) => {
  const url = new URL('http://localhost:3000/api/fortune/generate-batch');
  const request = new NextRequest(url, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      ...headers
    },
    body: JSON.stringify(body)
  });
  
  // Mock the json() method
  request.json = jest.fn().mockResolvedValue(body);
  
  return request;
};

describe('/api/fortune/generate-batch', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('유효한 요청을 성공적으로 처리해야 함', async () => {
    const validRequest = createMockRequest({
      request_type: 'daily_refresh',
      user_profile: {
        id: 'test-user-123',
        name: '홍길동',
        birth_date: '1990-05-15'
      },
      generation_context: {
        cache_duration_hours: 24
      }
    }, {
      'Authorization': 'Bearer valid-token'
    });

    const response = await POST(validRequest);
    const jsonData = await response.json();
    
    expect(response.status).toBe(200);
    expect(jsonData).toHaveProperty('request_id', 'test-batch-123');
    expect(jsonData).toHaveProperty('analysis_results');
    expect(jsonData.analysis_results).toHaveProperty('daily');
    expect(jsonData.analysis_results).toHaveProperty('tomorrow');
    
    // 헤더 확인
    expect(response.headers.get('X-Fortune-Batch-Id')).toBe('test-batch-123');
    expect(response.headers.get('X-Token-Usage')).toBeDefined();
  });

  it('인증되지 않은 요청을 거부해야 함', async () => {
    // Mock auth failure
    const { createServerClient } = require('@/lib/supabase-server');
    createServerClient.mockReturnValueOnce({
      auth: {
        getUser: jest.fn(() => ({
          data: { user: null },
          error: new Error('Not authenticated')
        }))
      }
    });

    const unauthorizedRequest = createMockRequest({
      request_type: 'daily_refresh',
      user_profile: {
        id: 'test-user-123',
        name: '테스트',
        birth_date: '1990-01-01'
      },
      generation_context: {
        cache_duration_hours: 24
      }
    });

    const response = await POST(unauthorizedRequest);
    const jsonData = await response.json();
    
    expect(response.status).toBe(401);
    expect(jsonData).toHaveProperty('error', '인증이 필요합니다');
  });

  it('잘못된 요청 형식을 거부해야 함', async () => {
    const invalidRequest = createMockRequest({
      // request_type이 누락됨
      user_profile: {
        id: 'test-user-123',
        name: '테스트'
        // birth_date가 누락됨
      }
    }, {
      'Authorization': 'Bearer valid-token'
    });

    const response = await POST(invalidRequest);
    const jsonData = await response.json();
    
    expect(response.status).toBe(400);
    expect(jsonData).toHaveProperty('error', '잘못된 요청 형식');
    expect(jsonData).toHaveProperty('details');
  });

  it('다른 사용자의 데이터 요청을 거부해야 함', async () => {
    const otherUserRequest = createMockRequest({
      request_type: 'daily_refresh',
      user_profile: {
        id: 'other-user-456', // 로그인한 사용자와 다른 ID
        name: '다른사용자',
        birth_date: '1985-03-20'
      },
      generation_context: {
        cache_duration_hours: 24
      }
    }, {
      'Authorization': 'Bearer valid-token'
    });

    const response = await POST(otherUserRequest);
    const jsonData = await response.json();
    
    expect(response.status).toBe(403);
    expect(jsonData).toHaveProperty('error', '권한이 없습니다');
  });

  it('rate limit을 적용해야 함', async () => {
    // 첫 10개 요청은 성공
    for (let i = 0; i < 10; i++) {
      const request = createMockRequest({
        request_type: 'user_direct_request',
        user_profile: {
          id: 'test-user-123',
          name: '테스트',
          birth_date: '1990-01-01'
        },
        generation_context: {
          cache_duration_hours: 24
        }
      }, {
        'Authorization': 'Bearer valid-token'
      });
      
      const response = await POST(request);
      expect(response.status).toBe(200);
    }
    
    // 11번째 요청은 rate limit에 걸림
    const exceededRequest = createMockRequest({
      request_type: 'user_direct_request',
      user_profile: {
        id: 'test-user-123',
        name: '테스트',
        birth_date: '1990-01-01'
      },
      generation_context: {
        cache_duration_hours: 24
      }
    }, {
      'Authorization': 'Bearer valid-token'
    });
    
    const response = await POST(exceededRequest);
    const jsonData = await response.json();
    
    expect(response.status).toBe(429);
    expect(jsonData).toHaveProperty('error', '요청 한도 초과. 잠시 후 다시 시도해주세요.');
  });

  it('서비스 오류를 적절히 처리해야 함', async () => {
    // Mock service error
    const { centralizedFortuneService } = require('@/lib/services/centralized-fortune-service');
    centralizedFortuneService.callGenkitFortuneAPI.mockRejectedValueOnce(
      new Error('Service temporarily unavailable')
    );

    const request = createMockRequest({
      request_type: 'daily_refresh',
      user_profile: {
        id: 'test-user-123',
        name: '테스트',
        birth_date: '1990-01-01'
      },
      generation_context: {
        cache_duration_hours: 24
      }
    }, {
      'Authorization': 'Bearer valid-token'
    });

    const response = await POST(request);
    const jsonData = await response.json();
    
    expect(response.status).toBe(500);
    expect(jsonData).toHaveProperty('error', '운세 생성 중 오류가 발생했습니다');
    expect(jsonData).toHaveProperty('message', 'Service temporarily unavailable');
  });

  it('온보딩 완료 요청을 처리해야 함', async () => {
    const onboardingRequest = createMockRequest({
      request_type: 'onboarding_complete',
      user_profile: {
        id: 'test-user-123',
        name: '신규사용자',
        birth_date: '2000-01-01',
        birth_time: '12:00',
        gender: 'female',
        mbti: 'ENFP'
      },
      generation_context: {
        is_initial_setup: true,
        cache_duration_hours: 8760 // 1년
      }
    }, {
      'Authorization': 'Bearer valid-token'
    });

    const response = await POST(onboardingRequest);
    const jsonData = await response.json();
    
    expect(response.status).toBe(200);
    expect(jsonData.request_type).toBe('onboarding_complete');
    expect(response.headers.get('Cache-Control')).toBeDefined();
  });
});