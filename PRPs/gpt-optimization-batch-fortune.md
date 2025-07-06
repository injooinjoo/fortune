name: "GPT 호출 최적화 - 중앙 집중식 묶음 운세 생성"
description: |
  모든 운세 페이지의 GPT 호출을 중앙 집중화하여 토큰 사용량을 최적화하고 비용을 절감하는 시스템을 구현합니다. 
  개별 API 호출을 묶음 요청으로 통합하여 중복된 사용자 프로필 전송을 제거하고, 관련 운세들의 컨텍스트를 공유하여 
  토큰 효율성을 극대화합니다.

## 핵심 원칙
1. **컨텍스트가 왕**: 필요한 모든 문서, 예제 및 주의사항이 아래에 포함되어 있습니다.
2. **검증 우선**: 구현은 테스트에 의해 주도됩니다. 테스트를 통과하도록 코드를 작성합니다.
3. **전역 규칙 따르기**: 루트 `CLAUDE.md` 파일의 모든 지침을 따라야 합니다.

---

## 🎯 목표
현재 개별적으로 GPT를 호출하는 55개의 운세 페이지를 중앙 집중식 묶음 요청 시스템으로 통합합니다.

### 현재 달성한 성과:
- ✅ 모든 55개 운세 페이지 GPT 연동 완료 (100%)
- ✅ 중앙 API 함수 `callGenkitFortuneAPI` 구현 완료
- ✅ 배치 생성 기능 `generateBatchFortunes` 구현 완료
- ✅ 통합 API 엔드포인트 `/api/fortune/generate` 구현 완료

### 남은 최적화 작업:
- 토큰 사용량을 65-85% 절감하여 월 운영 비용 대폭 감소
- 토큰 사용량 모니터링 대시보드 구축
- Math.random() 제거로 서버사이드 결정적 생성

## ✅ 성공 기준 (현재 상태)
- [✅] `callGenkitFortuneAPI` 함수가 구현되어 모든 묶음 요청을 처리함 (`/src/lib/daily-fortune-service.ts`)
- [✅] 배치 운세 생성 기능 구현 (`generateBatchFortunes` in `/src/ai/openai-client.ts`)
- [✅] 통합 API 엔드포인트 구현 (`/api/fortune/generate`)
- [✅] 개별 운세 페이지들이 GPT 연동 완료 (100%)
- [ ] 토큰 사용량 모니터링 대시보드가 구현됨 (미구현)
- [ ] 전용 `/api/fortune/generate-batch` 엔드포인트 (현재는 `/api/fortune/generate`에 통합)
- [ ] 모든 새 코드가 100% 단위 테스트로 커버됨 (부분적)
- [✅] 기능이 README.md에 문서화됨 (업데이트 완료)

---

## 📚 필요한 모든 컨텍스트

### 문서 및 참조
```yaml
# 반드시 읽어야 함 - 이 컨텍스트는 성공적인 구현에 중요합니다.
- file: src/CLAUDE.md
  why: "프로젝트 전체의 코딩 규칙과 스타일 가이드"
- file: docs/gpt-fortune-json-examples.md
  why: "GPT 입출력 JSON 형식과 묶음 요청 전략 상세 설명"
- file: docs/AI_MODELS.md
  why: "GPT 모델 선택 로직과 비용 최적화 전략"
- file: docs/TODO_GPT_INTEGRATION.md
  why: "현재 GPT 연동 상태와 다음 단계 작업 내용"
- file: src/lib/services/fortune-service.ts
  why: "기존 운세 서비스의 캐싱 및 데이터베이스 패턴"
- file: src/lib/services/batch-fortune-service.ts
  why: "기존 배치 처리 로직 참고"
- file: src/ai/openai-client.ts
  why: "현재 OpenAI API 호출 패턴과 토큰 관리"
- url: https://nextjs.org/docs/app/api-reference/functions/next-request
  why: "Next.js 15 App Router API 라우트 패턴"
- url: https://platform.openai.com/docs/api-reference/chat/create
  why: "OpenAI API 배치 요청 최적화 방법"
```

### 원하는 코드베이스 구조
```bash
# 생성할 모든 새 파일과 수정할 기존 파일 목록.
# 새 파일/디렉토리는 (+), 수정된 파일은 (M) 사용.
.
├── src/
│   ├── app/
│   │   └── api/
│   │       └── fortune/
│   │           └── (+) generate-batch/
│   │               └── (+) route.ts
│   ├── lib/
│   │   ├── services/
│   │   │   ├── (+) centralized-fortune-service.ts
│   │   │   ├── (M) fortune-service.ts
│   │   │   └── (M) batch-fortune-service.ts
│   │   └── utils/
│   │       └── (+) token-monitor.ts
│   ├── types/
│   │   ├── (M) fortune.d.ts
│   │   └── (+) batch-fortune.d.ts
│   ├── config/
│   │   └── (+) fortune-packages.ts
│   └── hooks/
│       └── (M) use-daily-fortune.ts
├── __tests__/
│   ├── services/
│   │   ├── (+) centralized-fortune-service.test.ts
│   │   └── (+) token-monitor.test.ts
│   └── api/
│       └── (+) generate-batch.test.ts
└── (M) README.md
```

### 알려진 주의사항 및 라이브러리 특성
```typescript
// 중요: OpenAI API는 한 번의 요청에 여러 메시지를 포함할 수 있음
// 예: messages 배열에 여러 운세 요청을 포함하되, 토큰 한도 주의
// 예: GPT-4o-mini는 비용 효율적, GPT-4-turbo는 이미지 분석용
// 주의: 한국어 텍스트 인코딩 시 토큰 수가 영어보다 많음
// 주의: Redis 캐시 키는 사용자별, 운세 타입별로 구분
// 패턴: 서버 컴포넌트에서만 환경 변수 접근
```

---

## 🛠️ 구현 청사진

### 작업 1: 운세 패키지 설정 정의
**파일:** `src/config/fortune-packages.ts`

**작업:** 5개의 운세 패키지 그룹과 각 패키지에 포함되는 운세 타입 정의

**의사 코드:**
```typescript
// src/config/fortune-packages.ts
export const FORTUNE_PACKAGES = {
  TRADITIONAL_PACKAGE: {
    name: 'traditional_package',
    fortunes: ['saju', 'traditional-saju', 'tojeong', 'salpuli', 'past-life'],
    cacheDuration: 365 * 24 * 60 * 60 * 1000, // 1년
    description: '생년월일시 기반 전통 운명학 종합 분석'
  },
  DAILY_PACKAGE: {
    name: 'daily_package', 
    fortunes: ['daily', 'hourly', 'today', 'tomorrow'],
    cacheDuration: 24 * 60 * 60 * 1000, // 24시간
    description: '일일 종합 운세'
  },
  LOVE_PACKAGE_SINGLE: {
    name: 'love_package_single',
    fortunes: ['love', 'destiny', 'blind-date', 'celebrity-match'],
    cacheDuration: 72 * 60 * 60 * 1000, // 72시간
    description: '솔로를 위한 연애운 패키지'
  },
  CAREER_WEALTH_PACKAGE: {
    name: 'career_wealth_package',
    fortunes: ['career', 'wealth', 'business', 'lucky-investment'],
    cacheDuration: 168 * 60 * 60 * 1000, // 7일
    description: '커리어와 재물운 종합'
  },
  LUCKY_ITEMS_PACKAGE: {
    name: 'lucky_items_package',
    fortunes: ['lucky-color', 'lucky-number', 'lucky-items', 'lucky-outfit', 'lucky-food'],
    cacheDuration: 720 * 60 * 60 * 1000, // 30일
    description: '행운 아이템 종합 패키지'
  }
};

// 패키지 타입별 GPT 모델 선택
export function selectModelForPackage(packageName: string): string {
  switch(packageName) {
    case 'traditional_package':
      return 'gpt-4-turbo-preview'; // 전문적 분석 필요
    case 'daily_package':
    case 'lucky_items_package':
      return 'gpt-4o-mini'; // 비용 효율적
    default:
      return 'gpt-3.5-turbo'; // 일반 용도
  }
}
```

### 작업 2: 배치 운세 타입 정의
**파일:** `src/types/batch-fortune.d.ts`

**작업:** 묶음 요청과 응답에 대한 TypeScript 타입 정의

**의사 코드:**
```typescript
// src/types/batch-fortune.d.ts
export interface BatchFortuneRequest {
  request_type: 'onboarding_complete' | 'daily_refresh' | 'user_direct_request';
  user_profile: {
    id: string;
    name: string;
    birth_date: string;
    birth_time?: string;
    gender?: string;
    mbti?: string;
    zodiac_sign?: string;
    relationship_status?: string;
    [key: string]: any;
  };
  requested_categories?: string[];
  fortune_types?: string[];
  target_date?: string;
  analysis_period?: string;
  generation_context: {
    is_initial_setup?: boolean;
    is_daily_auto_generation?: boolean;
    is_user_initiated?: boolean;
    cache_duration_hours: number;
    [key: string]: any;
  };
}

export interface BatchFortuneResponse {
  request_id: string;
  user_id: string;
  request_type: string;
  generated_at: string;
  analysis_results: {
    [fortuneType: string]: any;
  };
  package_summary?: any;
  unified_recommendations?: any;
  cache_info: {
    expires_at: string;
    cache_key: string;
  };
  token_usage?: {
    prompt_tokens: number;
    completion_tokens: number;
    total_tokens: number;
    estimated_cost: number;
  };
}

export interface FortunePackageConfig {
  name: string;
  fortunes: string[];
  cacheDuration: number;
  description: string;
}
```

### 작업 3: 중앙 집중식 운세 서비스 구현
**파일:** `src/lib/services/centralized-fortune-service.ts`

**작업:** 모든 운세 요청을 처리하는 중앙 서비스 레이어 구현

**의사 코드:**
```typescript
// src/lib/services/centralized-fortune-service.ts
import { BatchFortuneRequest, BatchFortuneResponse } from '@/types/batch-fortune';
import { FORTUNE_PACKAGES, selectModelForPackage } from '@/config/fortune-packages';
import { openAIClient } from '@/ai/openai-client';
import { redisClient } from '@/lib/redis';
import { supabase } from '@/lib/supabase';
import { TokenMonitor } from '@/lib/utils/token-monitor';

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

  // 메인 진입점 - 모든 운세 요청 처리
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
      const gptResponse = await openAIClient.generateBatchFortunes({
        prompt,
        model,
        maxTokens: this.calculateMaxTokens(packageConfig),
        temperature: 0.8
      });
      
      // 6. 토큰 사용량 모니터링
      await this.tokenMonitor.recordUsage({
        userId: request.user_profile.id,
        packageName: packageConfig.name,
        tokens: gptResponse.usage,
        duration: Date.now() - startTime,
        cost: this.calculateCost(gptResponse.usage, model)
      });

      // 7. 응답 파싱 및 구조화
      const response = this.parseGPTResponse(gptResponse, request);
      
      // 8. 캐시 저장 (개별 운세별로도 저장)
      await this.saveToCache(response, packageConfig);
      
      // 9. 데이터베이스 저장
      await this.saveToDatabase(response);
      
      return response;
    } catch (error) {
      console.error('중앙 운세 생성 오류:', error);
      // 폴백 처리
      return this.generateFallbackResponse(request);
    }
  }

  // 요청 타입에 따른 패키지 결정
  private determinePackage(request: BatchFortuneRequest): FortunePackageConfig {
    if (request.request_type === 'onboarding_complete') {
      return FORTUNE_PACKAGES.TRADITIONAL_PACKAGE;
    }
    
    if (request.request_type === 'daily_refresh') {
      return FORTUNE_PACKAGES.DAILY_PACKAGE;
    }
    
    // 사용자 직접 요청의 경우 요청된 운세 타입 분석
    const requestedFortunes = request.fortune_types || request.requested_categories || [];
    
    // 패키지 매칭 로직
    for (const [key, config] of Object.entries(FORTUNE_PACKAGES)) {
      const matchCount = requestedFortunes.filter(f => 
        config.fortunes.includes(f)
      ).length;
      
      if (matchCount >= config.fortunes.length * 0.6) {
        return config;
      }
    }
    
    // 매칭되는 패키지가 없으면 커스텀 패키지 생성
    return {
      name: 'custom_package',
      fortunes: requestedFortunes,
      cacheDuration: 60 * 60 * 1000, // 1시간
      description: '사용자 맞춤 운세'
    };
  }

  // 프롬프트 생성
  private buildPrompt(request: BatchFortuneRequest, packageConfig: FortunePackageConfig): string {
    const basePrompt = `당신은 전문 운세 상담사입니다. 
    다음 사용자의 정보를 바탕으로 ${packageConfig.description}을 제공해주세요.
    
    사용자 정보:
    ${JSON.stringify(request.user_profile, null, 2)}
    
    요청된 운세 타입들: ${packageConfig.fortunes.join(', ')}
    
    각 운세별로 구체적이고 개인화된 내용을 제공하되, 
    전체적으로 일관성 있는 메시지를 전달해주세요.
    
    응답은 반드시 다음 JSON 형식을 따라주세요:
    {
      "request_type": "${request.request_type}",
      "analysis_results": {
        // 각 운세 타입별 결과
      },
      "package_summary": {
        // 패키지 전체 요약
      }
    }`;
    
    return basePrompt;
  }

  // 캐시 확인
  private async checkCache(
    request: BatchFortuneRequest, 
    packageConfig: FortunePackageConfig
  ): Promise<BatchFortuneResponse | null> {
    const cacheKey = this.generateCacheKey(request, packageConfig);
    
    // Redis 캐시 확인
    const cached = await redisClient.get(cacheKey);
    if (cached) {
      return JSON.parse(cached);
    }
    
    // 데이터베이스 캐시 확인
    const dbCached = await this.checkDatabaseCache(request, packageConfig);
    if (dbCached) {
      // Redis에 다시 저장
      await redisClient.setex(cacheKey, 3600, JSON.stringify(dbCached));
      return dbCached;
    }
    
    return null;
  }

  // 캐시 키 생성
  private generateCacheKey(
    request: BatchFortuneRequest, 
    packageConfig: FortunePackageConfig
  ): string {
    const date = request.target_date || new Date().toISOString().split('T')[0];
    return `fortune:batch:${request.user_profile.id}:${packageConfig.name}:${date}`;
  }

  // 최대 토큰 계산
  private calculateMaxTokens(packageConfig: FortunePackageConfig): number {
    // 패키지 크기에 따라 동적으로 계산
    const baseTokens = 500;
    const tokensPerFortune = 300;
    return baseTokens + (packageConfig.fortunes.length * tokensPerFortune);
  }

  // 비용 계산
  private calculateCost(usage: any, model: string): number {
    const costs: { [key: string]: number } = {
      'gpt-4o-mini': 0.00015,
      'gpt-3.5-turbo': 0.0005,
      'gpt-4-turbo': 0.01,
      'gpt-4-turbo-preview': 0.01
    };
    
    const costPer1k = costs[model] || 0.001;
    return (usage.total_tokens / 1000) * costPer1k;
  }

  // 개별 운세로 분리하여 저장
  private async saveToCache(
    response: BatchFortuneResponse, 
    packageConfig: FortunePackageConfig
  ): Promise<void> {
    // 패키지 전체 캐시
    const packageCacheKey = this.generateCacheKey(
      { user_profile: { id: response.user_id } } as any, 
      packageConfig
    );
    await redisClient.setex(
      packageCacheKey, 
      packageConfig.cacheDuration / 1000, 
      JSON.stringify(response)
    );
    
    // 개별 운세별 캐시
    for (const [fortuneType, data] of Object.entries(response.analysis_results)) {
      const individualKey = `fortune:${response.user_id}:${fortuneType}:${new Date().toISOString().split('T')[0]}`;
      await redisClient.setex(
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

  // 데이터베이스 저장
  private async saveToDatabase(response: BatchFortuneResponse): Promise<void> {
    // 배치 레코드 저장
    await supabase.from('fortune_batches').insert({
      batch_id: response.request_id,
      user_id: response.user_id,
      request_type: response.request_type,
      fortune_types: Object.keys(response.analysis_results),
      token_usage: response.token_usage,
      generated_at: response.generated_at,
      expires_at: response.cache_info.expires_at
    });
    
    // 개별 운세 레코드 저장
    const fortunes = Object.entries(response.analysis_results).map(([type, data]) => ({
      user_id: response.user_id,
      fortune_type: type,
      fortune_data: data,
      batch_id: response.request_id,
      generated_at: response.generated_at,
      expires_at: response.cache_info.expires_at
    }));
    
    await supabase.from('user_fortunes').insert(fortunes);
  }

  // 폴백 응답 생성
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
}

// 싱글톤 인스턴스 export
export const centralizedFortuneService = CentralizedFortuneService.getInstance();
```

### 작업 4: 토큰 모니터링 유틸리티
**파일:** `src/lib/utils/token-monitor.ts`

**작업:** GPT API 토큰 사용량 추적 및 비용 모니터링

**의사 코드:**
```typescript
// src/lib/utils/token-monitor.ts
import { supabase } from '@/lib/supabase';

export interface TokenUsageRecord {
  userId: string;
  packageName: string;
  tokens: {
    prompt_tokens: number;
    completion_tokens: number;
    total_tokens: number;
  };
  duration: number;
  cost: number;
}

export class TokenMonitor {
  private dailyUsage: Map<string, number> = new Map();
  private monthlyUsage: Map<string, number> = new Map();

  // 토큰 사용량 기록
  async recordUsage(record: TokenUsageRecord): Promise<void> {
    // 메모리 캐시 업데이트
    this.updateLocalCache(record);
    
    // 데이터베이스에 기록
    await this.saveToDatabase(record);
    
    // 임계값 확인
    await this.checkThresholds(record.userId);
  }

  // 일일/월간 사용량 조회
  async getUsageStats(userId: string): Promise<{
    daily: { tokens: number; cost: number };
    monthly: { tokens: number; cost: number };
  }> {
    const today = new Date().toISOString().split('T')[0];
    const thisMonth = today.substring(0, 7);
    
    // 데이터베이스에서 집계
    const { data: dailyData } = await supabase
      .from('token_usage')
      .select('total_tokens, cost')
      .eq('user_id', userId)
      .gte('created_at', today)
      .lt('created_at', today + 'T23:59:59');
    
    const { data: monthlyData } = await supabase
      .from('token_usage')
      .select('total_tokens, cost')
      .eq('user_id', userId)
      .gte('created_at', thisMonth + '-01')
      .lt('created_at', thisMonth + '-31T23:59:59');
    
    return {
      daily: this.aggregateUsage(dailyData || []),
      monthly: this.aggregateUsage(monthlyData || [])
    };
  }

  // 패키지별 효율성 분석
  async analyzePackageEfficiency(): Promise<{
    [packageName: string]: {
      avgTokensPerRequest: number;
      avgCostPerRequest: number;
      savingsPercent: number;
    };
  }> {
    // 최근 7일간의 데이터 분석
    const analysis: any = {};
    
    for (const packageName of Object.keys(FORTUNE_PACKAGES)) {
      const { data } = await supabase
        .from('token_usage')
        .select('*')
        .eq('package_name', packageName)
        .gte('created_at', new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString());
      
      if (data && data.length > 0) {
        const avgTokens = data.reduce((sum, r) => sum + r.total_tokens, 0) / data.length;
        const avgCost = data.reduce((sum, r) => sum + r.cost, 0) / data.length;
        
        // 개별 호출 대비 절감률 계산
        const individualCost = this.calculateIndividualCost(packageName);
        const savingsPercent = ((individualCost - avgCost) / individualCost) * 100;
        
        analysis[packageName] = {
          avgTokensPerRequest: Math.round(avgTokens),
          avgCostPerRequest: avgCost,
          savingsPercent: Math.round(savingsPercent)
        };
      }
    }
    
    return analysis;
  }

  // 사용량 임계값 확인
  private async checkThresholds(userId: string): Promise<void> {
    const stats = await this.getUsageStats(userId);
    
    // 일일 한도 확인 (예: 10,000 토큰)
    if (stats.daily.tokens > 10000) {
      console.warn(`사용자 ${userId}가 일일 토큰 한도에 근접: ${stats.daily.tokens}`);
      // 알림 발송 로직
    }
    
    // 월간 비용 한도 확인 (예: $10)
    if (stats.monthly.cost > 10) {
      console.warn(`사용자 ${userId}가 월간 비용 한도 초과: $${stats.monthly.cost}`);
      // 서비스 제한 로직
    }
  }

  // 개별 호출 비용 계산 (비교용)
  private calculateIndividualCost(packageName: string): number {
    const config = FORTUNE_PACKAGES[packageName];
    if (!config) return 0;
    
    // 각 운세당 평균 500 토큰 가정
    const totalTokens = config.fortunes.length * 500;
    const costPer1k = 0.0005; // GPT-3.5 기준
    
    return (totalTokens / 1000) * costPer1k;
  }
}
```

### 작업 5: API 라우트 구현
**파일:** `src/app/api/fortune/generate-batch/route.ts`

**작업:** 중앙 집중식 배치 운세 생성 API 엔드포인트

**의사 코드:**
```typescript
// src/app/api/fortune/generate-batch/route.ts
import { NextRequest, NextResponse } from 'next/server';
import { centralizedFortuneService } from '@/lib/services/centralized-fortune-service';
import { BatchFortuneRequest } from '@/types/batch-fortune';
import { createServerClient } from '@/lib/supabase-server';
import { z } from 'zod';

// 요청 검증 스키마
const requestSchema = z.object({
  request_type: z.enum(['onboarding_complete', 'daily_refresh', 'user_direct_request']),
  user_profile: z.object({
    id: z.string(),
    name: z.string(),
    birth_date: z.string(),
    birth_time: z.string().optional(),
    gender: z.string().optional(),
    mbti: z.string().optional(),
    zodiac_sign: z.string().optional()
  }),
  requested_categories: z.array(z.string()).optional(),
  fortune_types: z.array(z.string()).optional(),
  target_date: z.string().optional(),
  generation_context: z.object({
    cache_duration_hours: z.number()
  })
});

export async function POST(request: NextRequest) {
  try {
    // 1. 인증 확인
    const supabase = createServerClient();
    const { data: { user }, error: authError } = await supabase.auth.getUser();
    
    if (authError || !user) {
      return NextResponse.json(
        { error: '인증이 필요합니다' },
        { status: 401 }
      );
    }

    // 2. 요청 본문 파싱 및 검증
    const body = await request.json();
    const validationResult = requestSchema.safeParse(body);
    
    if (!validationResult.success) {
      return NextResponse.json(
        { error: '잘못된 요청 형식', details: validationResult.error },
        { status: 400 }
      );
    }

    const batchRequest: BatchFortuneRequest = validationResult.data;
    
    // 3. 사용자 ID 검증
    if (batchRequest.user_profile.id !== user.id && !isAdminUser(user)) {
      return NextResponse.json(
        { error: '권한이 없습니다' },
        { status: 403 }
      );
    }

    // 4. Rate limiting 확인
    const rateLimitOk = await checkRateLimit(user.id, batchRequest.request_type);
    if (!rateLimitOk) {
      return NextResponse.json(
        { error: '요청 한도 초과. 잠시 후 다시 시도해주세요.' },
        { status: 429 }
      );
    }

    // 5. 중앙 서비스 호출
    const response = await centralizedFortuneService.callGenkitFortuneAPI(batchRequest);
    
    // 6. 응답 헤더 설정
    const headers = new Headers();
    headers.set('X-Fortune-Batch-Id', response.request_id);
    headers.set('X-Token-Usage', JSON.stringify(response.token_usage));
    
    if (response.cache_info) {
      headers.set('Cache-Control', `private, max-age=${response.cache_info.expires_at}`);
    }

    return NextResponse.json(response, { headers, status: 200 });
    
  } catch (error) {
    console.error('배치 운세 생성 오류:', error);
    
    // 에러 로깅
    await logError(error, request);
    
    return NextResponse.json(
      { 
        error: '운세 생성 중 오류가 발생했습니다',
        message: error instanceof Error ? error.message : '알 수 없는 오류'
      },
      { status: 500 }
    );
  }
}

// Rate limiting 함수
async function checkRateLimit(userId: string, requestType: string): Promise<boolean> {
  const limits = {
    'onboarding_complete': { max: 1, window: 86400 }, // 하루 1회
    'daily_refresh': { max: 2, window: 86400 }, // 하루 2회  
    'user_direct_request': { max: 10, window: 3600 } // 시간당 10회
  };
  
  const limit = limits[requestType as keyof typeof limits];
  if (!limit) return true;
  
  // Redis를 사용한 rate limiting 구현
  const key = `ratelimit:${requestType}:${userId}`;
  const current = await redisClient.incr(key);
  
  if (current === 1) {
    await redisClient.expire(key, limit.window);
  }
  
  return current <= limit.max;
}

// 관리자 확인
function isAdminUser(user: any): boolean {
  return user.email?.endsWith('@fortune-admin.com') || false;
}

// 에러 로깅
async function logError(error: any, request: NextRequest): Promise<void> {
  const errorLog = {
    timestamp: new Date().toISOString(),
    error: error.message || 'Unknown error',
    stack: error.stack,
    url: request.url,
    method: request.method,
    headers: Object.fromEntries(request.headers.entries())
  };
  
  await supabase.from('error_logs').insert(errorLog);
}
```

### 작업 6: 기존 서비스 수정
**파일:** `src/lib/services/fortune-service.ts` (수정)

**작업:** 기존 FortuneService가 새로운 중앙 서비스를 사용하도록 수정

**의사 코드:**
```typescript
// src/lib/services/fortune-service.ts에 추가/수정
import { centralizedFortuneService } from './centralized-fortune-service';

// getOrCreateFortune 메서드 수정
async getOrCreateFortune(
  userId: string,
  fortuneType: string,
  category: string,
  userProfile?: any
): Promise<any> {
  // 기존 캐시 확인 로직...
  
  // 캐시 미스 시 중앙 서비스 사용
  if (!cachedData) {
    // 관련 운세들을 함께 요청할지 결정
    const relatedFortunes = this.getRelatedFortunes(fortuneType);
    
    if (relatedFortunes.length > 1) {
      // 묶음 요청
      const batchResponse = await centralizedFortuneService.callGenkitFortuneAPI({
        request_type: 'user_direct_request',
        user_profile: userProfile,
        fortune_types: relatedFortunes,
        generation_context: {
          cache_duration_hours: this.getCacheDuration(fortuneType) / 3600000
        }
      });
      
      // 요청된 운세 추출
      return batchResponse.analysis_results[fortuneType];
    } else {
      // 단일 요청 (기존 방식 유지)
      return await this.generateSingleFortune(userId, fortuneType, userProfile);
    }
  }
  
  return cachedData;
}

// 관련 운세 찾기
private getRelatedFortunes(fortuneType: string): string[] {
  // 패키지 설정에서 관련 운세 찾기
  for (const config of Object.values(FORTUNE_PACKAGES)) {
    if (config.fortunes.includes(fortuneType)) {
      return config.fortunes;
    }
  }
  return [fortuneType];
}
```

### 작업 7: 훅 수정
**파일:** `src/hooks/use-daily-fortune.ts` (수정)

**작업:** useDailyFortune 훅이 새로운 배치 API를 사용하도록 수정

**의사 코드:**
```typescript
// src/hooks/use-daily-fortune.ts 수정
export function useDailyFortune() {
  // ... 기존 코드 ...
  
  const refreshDailyFortune = async () => {
    try {
      // 새로운 배치 API 호출
      const response = await fetch('/api/fortune/generate-batch', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          request_type: 'daily_refresh',
          user_profile: userProfile,
          target_date: new Date().toISOString().split('T')[0],
          generation_context: {
            cache_duration_hours: 24
          }
        })
      });
      
      if (response.ok) {
        const batchData = await response.json();
        // 개별 운세 데이터 추출 및 상태 업데이트
        setDailyFortune(batchData.analysis_results.daily);
        // 다른 관련 운세도 캐시에 저장
        saveBatchToLocalCache(batchData);
      }
    } catch (error) {
      console.error('일일 운세 갱신 실패:', error);
    }
  };
  
  // ... 나머지 코드 ...
}
```

### 작업 8: 단위 테스트 작성
**파일:** `__tests__/services/centralized-fortune-service.test.ts`

**작업:** 중앙 서비스에 대한 포괄적인 테스트 작성

**의사 코드:**
```typescript
// __tests__/services/centralized-fortune-service.test.ts
import { CentralizedFortuneService } from '@/lib/services/centralized-fortune-service';
import { BatchFortuneRequest } from '@/types/batch-fortune';

describe('CentralizedFortuneService', () => {
  let service: CentralizedFortuneService;
  
  beforeEach(() => {
    service = CentralizedFortuneService.getInstance();
    // Mock 설정
    jest.clearAllMocks();
  });

  describe('callGenkitFortuneAPI', () => {
    it('온보딩 완료 요청을 올바르게 처리해야 함', async () => {
      const request: BatchFortuneRequest = {
        request_type: 'onboarding_complete',
        user_profile: {
          id: 'test-user',
          name: '테스트',
          birth_date: '1990-01-01'
        },
        generation_context: {
          is_initial_setup: true,
          cache_duration_hours: 8760
        }
      };
      
      const response = await service.callGenkitFortuneAPI(request);
      
      expect(response).toHaveProperty('request_id');
      expect(response.request_type).toBe('onboarding_complete');
      expect(response.analysis_results).toHaveProperty('saju');
      expect(response.analysis_results).toHaveProperty('traditional-saju');
    });

    it('캐시된 결과를 반환해야 함', async () => {
      // 첫 번째 호출
      const request = createTestRequest();
      const firstResponse = await service.callGenkitFortuneAPI(request);
      
      // 두 번째 호출 (캐시에서)
      const secondResponse = await service.callGenkitFortuneAPI(request);
      
      expect(secondResponse.request_id).toBe(firstResponse.request_id);
      expect(mockOpenAI.generateBatchFortunes).toHaveBeenCalledTimes(1);
    });

    it('토큰 한도 초과 시 적절히 처리해야 함', async () => {
      // 대량 요청 시뮬레이션
      const largeRequest = createLargeRequest();
      
      const response = await service.callGenkitFortuneAPI(largeRequest);
      
      expect(response.token_usage.total_tokens).toBeLessThan(4000);
    });
  });

  describe('패키지 결정 로직', () => {
    it('요청된 운세에 따라 올바른 패키지를 선택해야 함', () => {
      const fortunes = ['love', 'destiny', 'blind-date'];
      const packageConfig = service['determinePackage']({
        request_type: 'user_direct_request',
        fortune_types: fortunes
      });
      
      expect(packageConfig.name).toBe('love_package_single');
    });
  });
});
```

### 작업 9: API 테스트
**파일:** `__tests__/api/generate-batch.test.ts`

**작업:** API 엔드포인트 통합 테스트

**의사 코드:**
```typescript
// __tests__/api/generate-batch.test.ts
import { createMocks } from 'node-mocks-http';
import { POST } from '@/app/api/fortune/generate-batch/route';

describe('/api/fortune/generate-batch', () => {
  it('유효한 요청을 처리해야 함', async () => {
    const { req, res } = createMocks({
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer valid-token'
      },
      body: {
        request_type: 'daily_refresh',
        user_profile: {
          id: 'user-123',
          name: '홍길동',
          birth_date: '1990-05-15'
        },
        generation_context: {
          cache_duration_hours: 24
        }
      }
    });

    await POST(req as any);
    
    expect(res._getStatusCode()).toBe(200);
    const jsonData = JSON.parse(res._getData());
    expect(jsonData).toHaveProperty('request_id');
    expect(jsonData).toHaveProperty('analysis_results');
  });

  it('인증되지 않은 요청을 거부해야 함', async () => {
    const { req, res } = createMocks({
      method: 'POST',
      body: {}
    });

    await POST(req as any);
    
    expect(res._getStatusCode()).toBe(401);
  });

  it('rate limit을 적용해야 함', async () => {
    // 다수의 요청 시뮬레이션
    for (let i = 0; i < 15; i++) {
      const { req, res } = createMocks({
        method: 'POST',
        headers: { 'Authorization': 'Bearer valid-token' },
        body: createValidRequest()
      });
      
      await POST(req as any);
      
      if (i < 10) {
        expect(res._getStatusCode()).toBe(200);
      } else {
        expect(res._getStatusCode()).toBe(429);
      }
    }
  });
});
```

### 작업 10: README 업데이트
**파일:** `README.md` (수정)

**작업:** 새로운 GPT 최적화 기능 문서화

**의사 코드:**
```markdown
## 🚀 GPT 호출 최적화

Fortune 앱은 중앙 집중식 GPT 호출 시스템을 통해 토큰 사용량을 최적화합니다.

### 주요 기능

- **묶음 요청**: 관련된 운세들을 한 번의 API 호출로 생성
- **토큰 절약**: 65-85%의 토큰 사용량 감소
- **스마트 캐싱**: 패키지별 최적화된 캐시 전략
- **비용 모니터링**: 실시간 토큰 사용량 및 비용 추적

### 운세 패키지

1. **전통·사주 패키지** (1년 캐시)
   - 사주, 전통사주, 토정비결, 살풀이, 전생
   
2. **일일 종합 패키지** (24시간 캐시)
   - 오늘의 운세, 시간별 운세, 내일의 운세

3. **연애·인연 패키지** (72시간 캐시)
   - 연애운, 인연운, 소개팅운, 연예인 궁합

4. **취업·재물 패키지** (7일 캐시)
   - 취업운, 금전운, 사업운, 투자운

5. **행운 아이템 패키지** (30일 캐시)
   - 행운의 색, 숫자, 아이템, 의상, 음식

### API 사용법

```typescript
// 배치 운세 생성
const response = await fetch('/api/fortune/generate-batch', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    request_type: 'daily_refresh',
    user_profile: {
      id: userId,
      name: userName,
      birth_date: birthDate
    },
    generation_context: {
      cache_duration_hours: 24
    }
  })
});
```

### 토큰 사용량 모니터링

관리자는 `/admin/token-usage` 페이지에서 실시간 토큰 사용량과 비용을 모니터링할 수 있습니다.
```

---

## 🔄 검증 루프

### 레벨 1: 린팅 및 스타일 검사
```bash
# 이 명령을 실행하세요. 보고된 오류를 수정한 후 진행하세요.
npm run lint
npm run format
```

### 레벨 2: 타입 검사
```bash
# 이 명령을 실행하세요. 타입 오류를 수정하세요.
npm run type-check
```

### 레벨 3: 단위 테스트
```bash
# 테스트를 실행하세요. 모든 테스트가 통과해야 합니다.
npm test -- centralized-fortune-service
npm test -- generate-batch
npm test -- token-monitor
```

### 레벨 4: 통합 테스트
```bash
# 개발 서버 실행
npm run dev

# 다른 터미널에서 배치 API 테스트
# 온보딩 완료 테스트
curl -X POST http://localhost:3000/api/fortune/generate-batch \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer your-token" \
  -d '{
    "request_type": "onboarding_complete",
    "user_profile": {
      "id": "test-user",
      "name": "테스트",
      "birth_date": "1990-01-01"
    },
    "generation_context": {
      "cache_duration_hours": 8760
    }
  }'

# 일일 운세 갱신 테스트  
curl -X POST http://localhost:3000/api/fortune/generate-batch \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer your-token" \
  -d '{
    "request_type": "daily_refresh",
    "user_profile": {
      "id": "test-user",
      "name": "테스트",
      "birth_date": "1990-01-01"
    },
    "target_date": "2025-01-01",
    "generation_context": {
      "cache_duration_hours": 24
    }
  }'
```

### 레벨 5: 성능 테스트
```bash
# 토큰 사용량 비교 테스트
npm run test:performance -- --compare-token-usage

# 응답 시간 테스트
npm run test:performance -- --response-time
```

---

## ✅ 최종 검증 체크리스트 (현재 상태)
- [✅] 중앙 API 함수 `callGenkitFortuneAPI` 구현 완료
- [✅] 배치 생성 함수 `generateBatchFortunes` 구현 완료
- [✅] 통합 API가 모든 운세 패키지를 올바르게 처리함
- [✅] 캐싱 시스템 기본 구현 완료 (localStorage 기반)
- [✅] README에 현재 상태 문서화됨
- [ ] 토큰 사용량이 기존 대비 65% 이상 감소함 (측정 필요)
- [ ] Rate limiting이 적절히 적용됨 (미구현)
- [ ] 토큰 모니터링 대시보드가 정확한 데이터를 표시함 (미구현)
- [ ] 포괄적인 테스트 커버리지 (부분적)