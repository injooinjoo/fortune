import { BatchFortuneRequest, BatchFortuneResponse, FortunePackageConfig } from '@/types/batch-fortune';
import { FORTUNE_PACKAGES, selectModelForPackage, findPackageByFortuneTypes } from '@/config/fortune-packages';
import { supabase } from '@/lib/supabase';
import { TokenMonitor } from '@/lib/utils/token-monitor';

// 메모리 캐시 구현
class MemoryCache {
  private cache: Map<string, { data: any; expires: number }> = new Map();

  async get(key: string): Promise<string | null> {
    const item = this.cache.get(key);
    if (!item) return null;
    
    if (Date.now() > item.expires) {
      this.cache.delete(key);
      return null;
    }
    
    return JSON.stringify(item.data);
  }

  async setex(key: string, seconds: number, value: string): Promise<void> {
    this.cache.set(key, {
      data: JSON.parse(value),
      expires: Date.now() + (seconds * 1000)
    });
  }

  async incr(key: string): Promise<number> {
    const current = this.cache.get(key);
    const value = current ? (current.data + 1) : 1;
    this.cache.set(key, { data: value, expires: Date.now() + 3600000 });
    return value;
  }

  async expire(key: string, seconds: number): Promise<void> {
    const item = this.cache.get(key);
    if (item) {
      item.expires = Date.now() + (seconds * 1000);
    }
  }
}

const memoryCache = new MemoryCache();

export class CentralizedFortuneService {
  private static instance: CentralizedFortuneService;
  private tokenMonitor: TokenMonitor;

  private constructor() {
    this.tokenMonitor = new TokenMonitor();
  }

  static getInstance(): CentralizedFortuneService {
    if (!this.instance) {
      this.instance = new CentralizedFortuneService();
    }
    return this.instance;
  }

  async callGenkitFortuneAPI(request: BatchFortuneRequest): Promise<BatchFortuneResponse> {
    try {
      // 1. 요청 타입에 따라 패키지 결정
      const packageConfig = this.determinePackage(request);
      
      // 2. 캐시 확인
      const cachedResult = await this.checkCache(request, packageConfig);
      if (cachedResult) {
        return cachedResult;
      }

      // 3. GPT 프롬프트 생성
      const prompt = this.buildPrompt(request, packageConfig);
      
      // 4. 적절한 모델 선택
      const model = selectModelForPackage(packageConfig.name);
      
      // 5. OpenAI API 호출
      const startTime = Date.now();
      
      // OpenAI 클라이언트 동적 import
      const { generateBatchFortunes } = await import('@/ai/openai-client');
      
      const gptResponse = await generateBatchFortunes({
        user_id: request.user_profile.id,
        fortunes: packageConfig.fortunes,
        profile: {
          name: request.user_profile.name,
          birthDate: request.user_profile.birth_date,
          gender: request.user_profile.gender,
          mbti: request.user_profile.mbti
        }
      });
      
      // 6. 토큰 사용량 모니터링
      const tokenUsage = {
        prompt_tokens: 0,
        completion_tokens: 0,
        total_tokens: gptResponse.token_usage || 0
      };
      
      await this.tokenMonitor.recordUsage({
        userId: request.user_profile.id,
        packageName: packageConfig.name,
        tokens: tokenUsage,
        duration: Date.now() - startTime,
        cost: this.calculateCost(tokenUsage, model)
      });

      // 7. 응답 파싱 및 구조화
      const response = this.parseGPTResponse(gptResponse, request, packageConfig);
      
      // 8. 캐시 저장 (개별 운세별로도 저장)
      await this.saveToCache(response, packageConfig);
      
      // 9. 데이터베이스 저장
      await this.saveToDatabase(response);
      
      return response;
    } catch (error) {
      console.error('중앙 운세 생성 오류:', error);
      return this.generateFallbackResponse(request);
    }
  }

  private determinePackage(request: BatchFortuneRequest): FortunePackageConfig {
    if (request.request_type === 'onboarding_complete') {
      return {
        ...FORTUNE_PACKAGES.TRADITIONAL_PACKAGE,
        fortunes: [...FORTUNE_PACKAGES.TRADITIONAL_PACKAGE.fortunes]
      };
    }
    
    if (request.request_type === 'daily_refresh') {
      return {
        ...FORTUNE_PACKAGES.DAILY_PACKAGE,
        fortunes: [...FORTUNE_PACKAGES.DAILY_PACKAGE.fortunes]
      };
    }
    
    // 사용자 직접 요청의 경우 요청된 운세 타입 분석
    const requestedFortunes = request.fortune_types || request.requested_categories || [];
    
    // 패키지 매칭 로직
    const matchedPackage = findPackageByFortuneTypes(requestedFortunes);
    if (matchedPackage) {
      return {
        ...matchedPackage,
        fortunes: [...matchedPackage.fortunes]
      };
    }
    
    // 매칭되는 패키지가 없으면 커스텀 패키지 생성
    return {
      name: 'custom_package',
      fortunes: requestedFortunes,
      cacheDuration: 60 * 60 * 1000, // 1시간
      description: '사용자 맞춤 운세'
    };
  }

  private buildPrompt(request: BatchFortuneRequest, packageConfig: FortunePackageConfig): string {
    const basePrompt = `당신은 전문 운세 상담사입니다. 
    다음 사용자의 정보를 바탕으로 ${packageConfig.description}을 제공해주세요.
    
    사용자 정보:
    - 이름: ${request.user_profile.name}
    - 생년월일: ${request.user_profile.birth_date}
    ${request.user_profile.birth_time ? `- 생시: ${request.user_profile.birth_time}` : ''}
    ${request.user_profile.gender ? `- 성별: ${request.user_profile.gender}` : ''}
    ${request.user_profile.mbti ? `- MBTI: ${request.user_profile.mbti}` : ''}
    ${request.user_profile.zodiac_sign ? `- 별자리: ${request.user_profile.zodiac_sign}` : ''}
    
    요청된 운세 타입들: ${packageConfig.fortunes.join(', ')}
    
    각 운세별로 구체적이고 개인화된 내용을 제공하되, 
    전체적으로 일관성 있는 메시지를 전달해주세요.
    
    응답은 반드시 다음 JSON 형식을 따라주세요:
    {
      "request_type": "${request.request_type}",
      "analysis_results": {
        ${packageConfig.fortunes.map(f => `"${f}": { /* 운세 내용 */ }`).join(',\n        ')}
      },
      "package_summary": {
        "overall_theme": "전체 테마",
        "key_insights": ["주요 통찰 1", "주요 통찰 2"],
        "recommendations": ["추천사항 1", "추천사항 2"]
      }
    }`;
    
    return basePrompt;
  }

  private async checkCache(
    request: BatchFortuneRequest, 
    packageConfig: FortunePackageConfig
  ): Promise<BatchFortuneResponse | null> {
    const cacheKey = this.generateCacheKey(request, packageConfig);
    
    // 메모리 캐시 확인
    const cached = await memoryCache.get(cacheKey);
    if (cached) {
      return JSON.parse(cached);
    }
    
    // 데이터베이스 캐시 확인
    const dbCached = await this.checkDatabaseCache(request, packageConfig);
    if (dbCached) {
      // 메모리 캐시에 다시 저장
      await memoryCache.setex(cacheKey, 3600, JSON.stringify(dbCached));
      return dbCached;
    }
    
    return null;
  }

  private generateCacheKey(
    request: BatchFortuneRequest, 
    packageConfig: FortunePackageConfig
  ): string {
    const date = request.target_date || new Date().toISOString().split('T')[0];
    return `fortune:batch:${request.user_profile.id}:${packageConfig.name}:${date}`;
  }

  private calculateMaxTokens(packageConfig: FortunePackageConfig): number {
    const baseTokens = 500;
    const tokensPerFortune = 300;
    return baseTokens + (packageConfig.fortunes.length * tokensPerFortune);
  }

  private calculateCost(usage: any, model: string): number {
    if (!usage) return 0;
    
    const costs: { [key: string]: number } = {
      'gpt-4o-mini': 0.00015,
      'gpt-3.5-turbo': 0.0005,
      'gpt-4-turbo': 0.01,
      'gpt-4-turbo-preview': 0.01
    };
    
    const costPer1k = costs[model] || 0.001;
    return (usage.total_tokens / 1000) * costPer1k;
  }

  private parseGPTResponse(
    gptResponse: any, 
    request: BatchFortuneRequest,
    packageConfig: FortunePackageConfig
  ): BatchFortuneResponse {
    // 결정적 ID 생성 (사용자 ID와 타임스탬프 기반)
    const timestamp = Date.now();
    const userHash = this.hashString(request.user_profile.id);
    const requestId = `batch_${timestamp}_${userHash}`;
    const now = new Date();
    const expiresAt = new Date(now.getTime() + packageConfig.cacheDuration);
    
    // generateBatchFortunes는 { data: BatchFortuneResponse, token_usage: number } 형식으로 반환
    const analysisResults = gptResponse.data || this.generateFallbackFortunes(request);
    
    return {
      request_id: requestId,
      user_id: request.user_profile.id,
      request_type: request.request_type,
      generated_at: now.toISOString(),
      analysis_results: analysisResults,
      package_summary: {
        overall_theme: `${packageConfig.description} 분석 완료`,
        key_insights: Object.keys(analysisResults).map(key => `${key} 운세 생성 완료`),
        recommendations: ['긍정적인 마음가짐을 유지하세요']
      },
      cache_info: {
        expires_at: expiresAt.toISOString(),
        cache_key: this.generateCacheKey(request, packageConfig)
      },
      token_usage: gptResponse.token_usage ? {
        prompt_tokens: 0,
        completion_tokens: 0,
        total_tokens: gptResponse.token_usage,
        estimated_cost: this.calculateCost({ total_tokens: gptResponse.token_usage }, selectModelForPackage(packageConfig.name))
      } : undefined
    };
  }

  private async saveToCache(
    response: BatchFortuneResponse, 
    packageConfig: FortunePackageConfig
  ): Promise<void> {
    // 패키지 전체 캐시
    const packageCacheKey = response.cache_info.cache_key;
    await memoryCache.setex(
      packageCacheKey, 
      packageConfig.cacheDuration / 1000, 
      JSON.stringify(response)
    );
    
    // 개별 운세별 캐시
    for (const [fortuneType, data] of Object.entries(response.analysis_results)) {
      const individualKey = `fortune:${response.user_id}:${fortuneType}:${new Date().toISOString().split('T')[0]}`;
      await memoryCache.setex(
        individualKey,
        packageConfig.cacheDuration / 1000,
        JSON.stringify({
          fortune_type: fortuneType,
          data,
          generated_at: response.generated_at,
          from_batch: true,
          batch_id: response.request_id
        })
      );
    }
  }

  private async saveToDatabase(response: BatchFortuneResponse): Promise<void> {
    try {
      // 배치 레코드 저장 (analysis_results 포함)
      const { error: batchError } = await supabase.from('fortune_batches').insert({
        batch_id: response.request_id,
        user_id: response.user_id,
        request_type: response.request_type,
        fortune_types: Object.keys(response.analysis_results),
        analysis_results: response.analysis_results, // 전체 분석 결과 저장
        token_usage: response.token_usage,
        generated_at: response.generated_at,
        expires_at: response.cache_info.expires_at
      });

      if (batchError) {
        console.error('배치 레코드 저장 오류:', batchError);
      }
      
      // 개별 운세는 메모리 캐시에만 저장 (user_fortunes 테이블 대신)
      // 배치에서 개별 운세를 가져올 수 있도록 fortune_batches 테이블에 전체 데이터 저장
    } catch (error) {
      console.error('데이터베이스 저장 실패:', error);
    }
  }

  private async checkDatabaseCache(
    request: BatchFortuneRequest,
    packageConfig: FortunePackageConfig
  ): Promise<BatchFortuneResponse | null> {
    try {
      const date = request.target_date || new Date().toISOString().split('T')[0];
      
      const { data, error } = await supabase
        .from('fortune_batches')
        .select('*')
        .eq('user_id', request.user_profile.id)
        .eq('request_type', request.request_type)
        .gte('expires_at', new Date().toISOString())
        .order('created_at', { ascending: false })
        .limit(1);

      if (error || !data || data.length === 0) {
        return null;
      }

      // fortune_batches 테이블에 전체 분석 결과가 저장되어 있다고 가정
      const batchData = data[0];
      
      // analysis_results가 직접 저장되어 있는지 확인
      const analysisResults = batchData.analysis_results || {};

      return {
        request_id: data[0].batch_id,
        user_id: data[0].user_id,
        request_type: data[0].request_type,
        generated_at: data[0].generated_at,
        analysis_results: analysisResults,
        cache_info: {
          expires_at: data[0].expires_at,
          cache_key: this.generateCacheKey(request, packageConfig)
        },
        token_usage: data[0].token_usage
      };
    } catch (error) {
      console.error('데이터베이스 캐시 확인 오류:', error);
      return null;
    }
  }

  private generateFallbackResponse(request: BatchFortuneRequest): BatchFortuneResponse {
    return {
      request_id: `fallback_${Date.now()}`,
      user_id: request.user_profile.id,
      request_type: request.request_type,
      generated_at: new Date().toISOString(),
      analysis_results: this.generateFallbackFortunes(request),
      cache_info: {
        expires_at: new Date(Date.now() + 3600000).toISOString(),
        cache_key: 'fallback'
      }
    };
  }

  private generateFallbackFortunes(request: BatchFortuneRequest): { [key: string]: any } {
    const fortunes: { [key: string]: any } = {};
    const requestedFortunes = request.fortune_types || request.requested_categories || [];
    
    requestedFortunes.forEach(fortuneType => {
      fortunes[fortuneType] = {
        title: `${fortuneType} 운세`,
        content: '현재 운세를 생성할 수 없습니다. 잠시 후 다시 시도해주세요.',
        score: 50,
        advice: '긍정적인 마음가짐을 유지하세요.'
      };
    });
    
    return fortunes;
  }

  // 문자열을 결정적으로 해시하는 헬퍼 함수
  private hashString(str: string): string {
    let hash = 0;
    for (let i = 0; i < str.length; i++) {
      const char = str.charCodeAt(i);
      hash = ((hash << 5) - hash) + char;
      hash = hash & hash; // Convert to 32bit integer
    }
    return Math.abs(hash).toString(36);
  }
}

// 싱글톤 인스턴스 export
export const centralizedFortuneService = CentralizedFortuneService.getInstance();