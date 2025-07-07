/**
 * 향상된 운세 서비스
 * GPT-4.1-nano 기반의 고품질 운세 생성 시스템
 */

import { generateBatchFortunes, generateSingleFortune } from '@/ai/openai-client';
import { FORTUNE_TEMPLATES, validateFortuneResponse } from '@/ai/prompts/fortune-templates';
import { fortuneCache, generateCacheKey, CACHE_TTL, withCache, cacheStats } from '@/lib/fortune-cache';
import { trackTokenUsage, deductTokens, getUserTokenBalance } from '@/lib/token-tracker';
import { 
  withErrorRecovery, 
  classifyError, 
  getUserFriendlyErrorMessage,
  TokenLimitError,
  AIServiceError 
} from '@/lib/fortune-errors';
import { sanitizeForAI, postprocessAIResponse } from '@/lib/unicode-utils';
import { createDeterministicRandom, getTodayDateString } from '@/lib/deterministic-random';

// 운세 서비스 설정
const CONFIG = {
  maxRetries: 3,
  retryDelayMs: 1000,
  batchSize: 5, // 한 번에 생성할 최대 운세 수
  tokenBuffer: 10, // 토큰 여유분
  enablePrefetch: true, // 사전 로드 활성화
};

// 운세 생성 옵션
export interface FortuneGenerationOptions {
  userId: string;
  fortuneType: string;
  profile: any;
  force?: boolean; // 캐시 무시하고 새로 생성
  params?: Record<string, any>; // 추가 파라미터
}

// 운세 응답 인터페이스
export interface EnhancedFortuneResponse {
  success: boolean;
  fortuneType: string;
  data: any;
  metadata: {
    cached: boolean;
    generatedAt: string;
    expiresAt: string;
    tokensUsed?: number;
    responseTime: number;
    quality: 'high' | 'medium' | 'fallback';
  };
  error?: string;
}

/**
 * 향상된 운세 서비스 클래스
 */
export class EnhancedFortuneService {
  private static instance: EnhancedFortuneService;

  private constructor() {}

  static getInstance(): EnhancedFortuneService {
    if (!this.instance) {
      this.instance = new EnhancedFortuneService();
    }
    return this.instance;
  }

  /**
   * 단일 운세 생성
   */
  async generateFortune(options: FortuneGenerationOptions): Promise<EnhancedFortuneResponse> {
    const startTime = Date.now();
    const { userId, fortuneType, profile, force = false, params = {} } = options;

    try {
      // 1. 토큰 잔액 확인
      const tokenBalance = await getUserTokenBalance(userId);
      const estimatedTokens = this.estimateTokenUsage(fortuneType);
      
      if (tokenBalance && tokenBalance.balance < estimatedTokens + CONFIG.tokenBuffer) {
        throw new TokenLimitError(estimatedTokens, tokenBalance.balance);
      }

      // 2. 캐시 키 생성
      const cacheKey = generateCacheKey({
        userId,
        fortuneType,
        date: getTodayDateString(),
        extra: params,
      });

      // 3. 캐시된 운세 조회 또는 새로 생성
      const ttl = CACHE_TTL[fortuneType as keyof typeof CACHE_TTL] || CACHE_TTL.default;
      
      const fortuneData = await withCache(
        cacheKey,
        async () => {
          // AI로 운세 생성
          return await this.generateWithAI(fortuneType, profile, params);
        },
        { ttl, force }
      );

      // 4. 응답 검증
      if (!validateFortuneResponse(fortuneData, fortuneType)) {
        throw new AIServiceError('Invalid fortune response format');
      }

      // 5. 토큰 사용 기록 (캐시 미스인 경우만)
      const cached = !force && cacheStats.getStats().hits > 0;
      if (!cached && userId) {
        await trackTokenUsage({
          userId,
          fortuneType,
          tokensUsed: estimatedTokens,
          model: 'gpt-4.1-nano',
          endpoint: `/api/fortune/${fortuneType}`,
          responseTime: Date.now() - startTime,
        });
      }

      // 6. 성공 응답 생성
      return {
        success: true,
        fortuneType,
        data: fortuneData,
        metadata: {
          cached,
          generatedAt: new Date().toISOString(),
          expiresAt: new Date(Date.now() + ttl * 1000).toISOString(),
          tokensUsed: cached ? 0 : estimatedTokens,
          responseTime: Date.now() - startTime,
          quality: 'high',
        },
      };

    } catch (error) {
      // 에러 처리 및 폴백
      return await this.handleError(error, options, startTime);
    }
  }

  /**
   * 배치 운세 생성 (여러 운세를 한 번에)
   */
  async generateBatchFortunes(
    userId: string,
    fortuneTypes: string[],
    profile: any
  ): Promise<Record<string, EnhancedFortuneResponse>> {
    const results: Record<string, EnhancedFortuneResponse> = {};

    // 배치 크기로 분할
    const batches = this.chunkArray(fortuneTypes, CONFIG.batchSize);

    for (const batch of batches) {
      // 각 배치를 병렬로 처리
      const batchPromises = batch.map(fortuneType =>
        this.generateFortune({ userId, fortuneType, profile })
          .then(response => ({ fortuneType, response }))
      );

      const batchResults = await Promise.all(batchPromises);
      
      // 결과 병합
      batchResults.forEach(({ fortuneType, response }) => {
        results[fortuneType] = response;
      });
    }

    return results;
  }

  /**
   * AI를 통한 운세 생성 (내부 메서드)
   */
  private async generateWithAI(
    fortuneType: string,
    profile: any,
    params: Record<string, any>
  ): Promise<any> {
    // 프로필 정제
    const cleanProfile = {
      name: sanitizeForAI(profile.name || '사용자'),
      birthDate: profile.birthDate,
      gender: profile.gender,
      mbti: profile.mbti,
      blood_type: profile.blood_type,
    };

    // 템플릿 기반 생성
    const template = FORTUNE_TEMPLATES[fortuneType as keyof typeof FORTUNE_TEMPLATES];
    
    if (template) {
      // 템플릿이 있는 경우 구조화된 프롬프트 사용
      const promptData = template(cleanProfile, params);
      const response = await generateSingleFortune(
        fortuneType,
        cleanProfile,
        { customPrompt: promptData.user }
      );
      return postprocessAIResponse(JSON.stringify(response));
    } else {
      // 템플릿이 없는 경우 기본 생성
      const response = await generateSingleFortune(fortuneType, cleanProfile, params);
      return response;
    }
  }

  /**
   * 에러 처리 및 폴백 생성
   */
  private async handleError(
    error: any,
    options: FortuneGenerationOptions,
    startTime: number
  ): Promise<EnhancedFortuneResponse> {
    const classifiedError = classifyError(error);
    const userMessage = getUserFriendlyErrorMessage(error);

    // 토큰 부족이나 검증 오류는 폴백 없이 실패
    if (error instanceof TokenLimitError || error.code === 'VALIDATION_ERROR') {
      return {
        success: false,
        fortuneType: options.fortuneType,
        data: null,
        metadata: {
          cached: false,
          generatedAt: new Date().toISOString(),
          expiresAt: new Date().toISOString(),
          responseTime: Date.now() - startTime,
          quality: 'fallback',
        },
        error: userMessage,
      };
    }

    // 폴백 운세 생성 시도
    try {
      const fallbackData = await this.generateFallbackFortune(options);
      
      return {
        success: true,
        fortuneType: options.fortuneType,
        data: fallbackData,
        metadata: {
          cached: false,
          generatedAt: new Date().toISOString(),
          expiresAt: new Date(Date.now() + 3600 * 1000).toISOString(), // 1시간
          responseTime: Date.now() - startTime,
          quality: 'fallback',
        },
      };
    } catch (fallbackError) {
      // 최종 실패
      return {
        success: false,
        fortuneType: options.fortuneType,
        data: null,
        metadata: {
          cached: false,
          generatedAt: new Date().toISOString(),
          expiresAt: new Date().toISOString(),
          responseTime: Date.now() - startTime,
          quality: 'fallback',
        },
        error: userMessage,
      };
    }
  }

  /**
   * 폴백 운세 생성 (이전 데이터 활용)
   */
  private async generateFallbackFortune(options: FortuneGenerationOptions): Promise<any> {
    const { userId, fortuneType, profile } = options;
    
    // 1. 이전 날짜의 캐시 확인 (최대 7일 전까지)
    for (let daysAgo = 1; daysAgo <= 7; daysAgo++) {
      const pastDate = new Date();
      pastDate.setDate(pastDate.getDate() - daysAgo);
      const dateStr = pastDate.toISOString().split('T')[0];
      
      const pastKey = generateCacheKey({
        userId,
        fortuneType,
        date: dateStr,
      });
      
      const pastData = await fortuneCache.get(pastKey);
      if (pastData) {
        // 이전 데이터를 약간 수정하여 반환
        return this.modifyPastFortune(pastData, daysAgo);
      }
    }

    // 2. 기본 폴백 데이터 생성
    const rng = createDeterministicRandom(userId, getTodayDateString(), fortuneType);
    
    return {
      overall_luck: rng.randomInt(60, 85),
      summary: `${profile.name}님의 ${fortuneType} 운세입니다. 일시적인 문제로 상세 분석이 제한되었습니다.`,
      advice: '긍정적인 마음가짐으로 하루를 시작하세요. 곧 더 자세한 운세를 확인하실 수 있습니다.',
      quality: 'fallback',
      generated_at: new Date().toISOString(),
    };
  }

  /**
   * 과거 운세 데이터 수정
   */
  private modifyPastFortune(pastData: any, daysAgo: number): any {
    const modified = { ...pastData };
    
    // 날짜 관련 필드 업데이트
    modified.generated_at = new Date().toISOString();
    
    // 점수 약간 조정 (±5%)
    if (modified.overall_luck) {
      const adjustment = Math.floor(Math.random() * 11) - 5;
      modified.overall_luck = Math.max(0, Math.min(100, modified.overall_luck + adjustment));
    }
    
    // 요약에 날짜 참조 추가
    if (modified.summary) {
      modified.summary = modified.summary + ' (최근 운세 기반으로 업데이트됨)';
    }
    
    modified.based_on_past = true;
    modified.days_ago = daysAgo;
    
    return modified;
  }

  /**
   * 토큰 사용량 예측
   */
  private estimateTokenUsage(fortuneType: string): number {
    const estimates: Record<string, number> = {
      daily: 40,
      tarot: 80,
      compatibility: 70,
      mbti: 60,
      saju: 120,
      simple: 30,
      default: 50,
    };
    
    return estimates[fortuneType] || estimates.default;
  }

  /**
   * 배열을 청크로 분할
   */
  private chunkArray<T>(array: T[], chunkSize: number): T[][] {
    const chunks: T[][] = [];
    for (let i = 0; i < array.length; i += chunkSize) {
      chunks.push(array.slice(i, i + chunkSize));
    }
    return chunks;
  }

  /**
   * 운세 품질 평가
   */
  async evaluateFortuneQuality(fortuneData: any, fortuneType: string): Promise<{
    score: number;
    issues: string[];
    suggestions: string[];
  }> {
    const issues: string[] = [];
    const suggestions: string[] = [];
    let score = 100;

    // 1. 필수 필드 체크
    if (!validateFortuneResponse(fortuneData, fortuneType)) {
      issues.push('필수 필드 누락');
      score -= 30;
    }

    // 2. 텍스트 길이 체크
    const textFields = ['summary', 'advice', 'overall_reading'];
    textFields.forEach(field => {
      if (fortuneData[field] && fortuneData[field].length < 50) {
        issues.push(`${field} 필드가 너무 짧음`);
        suggestions.push(`${field}를 더 상세하게 작성하세요`);
        score -= 10;
      }
    });

    // 3. 점수 범위 체크
    const scoreFields = ['overall_luck', 'overall_score'];
    scoreFields.forEach(field => {
      if (fortuneData[field]) {
        const value = fortuneData[field];
        if (value < 0 || value > 100) {
          issues.push(`${field} 값이 범위를 벗어남`);
          score -= 15;
        }
      }
    });

    // 4. 개인화 수준 체크
    const personalFields = ['name', 'birthDate'];
    const hasPersonalization = personalFields.some(field => 
      JSON.stringify(fortuneData).includes(field)
    );
    
    if (!hasPersonalization) {
      issues.push('개인화 요소 부족');
      suggestions.push('사용자 이름이나 생년월일을 활용한 개인화 추가');
      score -= 20;
    }

    return {
      score: Math.max(0, score),
      issues,
      suggestions,
    };
  }
}

// 싱글톤 인스턴스 export
export const enhancedFortuneService = EnhancedFortuneService.getInstance();