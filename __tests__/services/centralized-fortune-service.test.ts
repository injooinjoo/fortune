import { CentralizedFortuneService } from '@/lib/services/centralized-fortune-service';
import { BatchFortuneRequest } from '@/types/batch-fortune';
import { FORTUNE_PACKAGES } from '@/config/fortune-packages';

// Mock dependencies
jest.mock('@/lib/supabase', () => ({
  supabase: {
    from: jest.fn(() => ({
      insert: jest.fn(() => ({ error: null })),
      select: jest.fn(() => ({
        eq: jest.fn(() => ({
          gte: jest.fn(() => ({
            order: jest.fn(() => ({
              limit: jest.fn(() => ({ data: null, error: null }))
            }))
          }))
        }))
      }))
    }))
  }
}));

jest.mock('@/ai/openai-client', () => ({
  generateBatchFortunes: jest.fn(() => Promise.resolve({
    data: {
      saju: { content: 'test saju fortune' },
      'traditional-saju': { content: 'test traditional saju' }
    },
    token_usage: 1000
  }))
}));

jest.mock('@/lib/utils/token-monitor', () => ({
  TokenMonitor: jest.fn().mockImplementation(() => ({
    recordUsage: jest.fn()
  }))
}));

describe('CentralizedFortuneService', () => {
  let service: CentralizedFortuneService;
  
  beforeEach(() => {
    jest.clearAllMocks();
    service = CentralizedFortuneService.getInstance();
  });

  describe('callGenkitFortuneAPI', () => {
    it('온보딩 완료 요청을 올바르게 처리해야 함', async () => {
      const request: BatchFortuneRequest = {
        request_type: 'onboarding_complete',
        user_profile: {
          id: 'test-user-123',
          name: '홍길동',
          birth_date: '1990-01-01',
          birth_time: '14:30',
          gender: 'male',
          mbti: 'INTJ'
        },
        generation_context: {
          is_initial_setup: true,
          cache_duration_hours: 8760
        }
      };
      
      const response = await service.callGenkitFortuneAPI(request);
      
      expect(response).toHaveProperty('request_id');
      expect(response.request_type).toBe('onboarding_complete');
      expect(response.analysis_results).toBeDefined();
      expect(response.user_id).toBe('test-user-123');
    });

    it('일일 운세 갱신 요청을 처리해야 함', async () => {
      const request: BatchFortuneRequest = {
        request_type: 'daily_refresh',
        user_profile: {
          id: 'test-user-456',
          name: '김철수',
          birth_date: '1985-05-15'
        },
        target_date: '2024-01-01',
        generation_context: {
          is_daily_auto_generation: true,
          cache_duration_hours: 24
        }
      };
      
      const response = await service.callGenkitFortuneAPI(request);
      
      expect(response.request_type).toBe('daily_refresh');
      expect(response.cache_info).toBeDefined();
      expect(response.cache_info.expires_at).toBeDefined();
    });

    it('캐시된 결과를 반환해야 함', async () => {
      const request: BatchFortuneRequest = {
        request_type: 'user_direct_request',
        user_profile: {
          id: 'cached-user',
          name: '캐시테스트',
          birth_date: '1995-03-20'
        },
        fortune_types: ['saju', 'tojeong'],
        generation_context: {
          cache_duration_hours: 72
        }
      };
      
      // 첫 번째 호출
      const firstResponse = await service.callGenkitFortuneAPI(request);
      
      // 두 번째 호출 (캐시에서)
      const secondResponse = await service.callGenkitFortuneAPI(request);
      
      // request_id가 같아야 함 (캐시에서 가져온 경우)
      expect(secondResponse.request_id).toBe(firstResponse.request_id);
    });

    it('사용자 요청에 따라 올바른 패키지를 선택해야 함', async () => {
      const request: BatchFortuneRequest = {
        request_type: 'user_direct_request',
        user_profile: {
          id: 'test-user',
          name: '테스트',
          birth_date: '2000-01-01'
        },
        fortune_types: ['love', 'destiny', 'blind-date'],
        generation_context: {
          cache_duration_hours: 72
        }
      };
      
      const response = await service.callGenkitFortuneAPI(request);
      
      // love_package_single이 선택되어야 함
      expect(response.analysis_results).toBeDefined();
      expect(Object.keys(response.analysis_results).length).toBeGreaterThan(0);
    });

    it('오류 발생 시 폴백 응답을 생성해야 함', async () => {
      // OpenAI 클라이언트가 오류를 발생시키도록 설정
      const { generateBatchFortunes } = require('@/ai/openai-client');
      generateBatchFortunes.mockRejectedValueOnce(new Error('API Error'));
      
      const request: BatchFortuneRequest = {
        request_type: 'user_direct_request',
        user_profile: {
          id: 'error-user',
          name: '에러테스트',
          birth_date: '1990-01-01'
        },
        fortune_types: ['daily'],
        generation_context: {
          cache_duration_hours: 24
        }
      };
      
      const response = await service.callGenkitFortuneAPI(request);
      
      expect(response).toBeDefined();
      expect(response.request_id).toContain('fallback');
      expect(response.analysis_results).toBeDefined();
    });
  });

  describe('패키지 결정 로직', () => {
    it('온보딩 완료 시 전통 패키지를 선택해야 함', () => {
      const packageConfig = service['determinePackage']({
        request_type: 'onboarding_complete',
        user_profile: { id: 'test', name: 'test', birth_date: '1990-01-01' },
        generation_context: { cache_duration_hours: 24 }
      });
      
      expect(packageConfig.name).toBe('traditional_package');
      expect(packageConfig.fortunes).toContain('saju');
      expect(packageConfig.fortunes).toContain('tojeong');
    });

    it('일일 갱신 시 일일 패키지를 선택해야 함', () => {
      const packageConfig = service['determinePackage']({
        request_type: 'daily_refresh',
        user_profile: { id: 'test', name: 'test', birth_date: '1990-01-01' },
        generation_context: { cache_duration_hours: 24 }
      });
      
      expect(packageConfig.name).toBe('daily_package');
      expect(packageConfig.fortunes).toContain('daily');
      expect(packageConfig.fortunes).toContain('tomorrow');
    });

    it('요청된 운세에 따라 적절한 패키지를 매칭해야 함', () => {
      const packageConfig = service['determinePackage']({
        request_type: 'user_direct_request',
        user_profile: { id: 'test', name: 'test', birth_date: '1990-01-01' },
        fortune_types: ['career', 'wealth', 'business'],
        generation_context: { cache_duration_hours: 168 }
      });
      
      expect(packageConfig.name).toBe('career_wealth_package');
    });

    it('매칭되지 않는 경우 커스텀 패키지를 생성해야 함', () => {
      const packageConfig = service['determinePackage']({
        request_type: 'user_direct_request',
        user_profile: { id: 'test', name: 'test', birth_date: '1990-01-01' },
        fortune_types: ['random-fortune', 'another-fortune'],
        generation_context: { cache_duration_hours: 24 }
      });
      
      expect(packageConfig.name).toBe('custom_package');
      expect(packageConfig.fortunes).toEqual(['random-fortune', 'another-fortune']);
      expect(packageConfig.cacheDuration).toBe(60 * 60 * 1000); // 1시간
    });
  });
});