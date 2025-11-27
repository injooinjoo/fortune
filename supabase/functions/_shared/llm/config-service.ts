// 동적 LLM 설정 서비스
// DB 기반 모델 설정 + 캐싱 + A/B 테스트 지원

import { createClient, SupabaseClient } from 'https://esm.sh/@supabase/supabase-js@2'

export interface DynamicModelConfig {
  provider: 'gemini' | 'openai' | 'anthropic' | 'grok'
  model: string
  temperature: number
  maxTokens: number
  isAbTest?: boolean
}

interface CachedConfig {
  config: DynamicModelConfig
  timestamp: number
}

// 메모리 캐시 (60초 TTL)
const configCache = new Map<string, CachedConfig>()
const CACHE_TTL_MS = 60 * 1000 // 60초

// Supabase 클라이언트 싱글톤
let supabaseClient: SupabaseClient | null = null

function getSupabaseClient(): SupabaseClient {
  if (!supabaseClient) {
    supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )
  }
  return supabaseClient
}

export class ConfigService {
  /**
   * 운세 타입에 맞는 모델 설정 가져오기 (비동기)
   * 우선순위: DB 운세별 > DB _default > 환경변수 > 하드코딩
   */
  static async getModelConfig(fortuneType: string): Promise<DynamicModelConfig> {
    // 1. 캐시 확인
    const cached = this.getCachedConfig(fortuneType)
    if (cached) {
      console.log(`📦 캐시된 설정 사용: ${fortuneType}`)
      return cached
    }

    // 2. DB에서 운세별 설정 조회
    const dbConfig = await this.fetchFromDB(fortuneType)
    if (dbConfig) {
      this.cacheConfig(fortuneType, dbConfig)
      return dbConfig
    }

    // 3. DB에서 기본 설정 조회
    const defaultConfig = await this.fetchFromDB('_default')
    if (defaultConfig) {
      this.cacheConfig(fortuneType, defaultConfig)
      return defaultConfig
    }

    // 4. 환경변수/하드코딩 폴백
    const fallback = this.getStaticFallback()
    this.cacheConfig(fortuneType, fallback)
    return fallback
  }

  /**
   * DB에서 설정 조회
   */
  private static async fetchFromDB(fortuneType: string): Promise<DynamicModelConfig | null> {
    try {
      const supabase = getSupabaseClient()
      const { data, error } = await supabase
        .from('llm_model_config')
        .select('*')
        .eq('fortune_type', fortuneType)
        .eq('is_active', true)
        .single()

      if (error || !data) {
        return null
      }

      // A/B 테스트 처리
      if (data.ab_test_enabled && data.ab_test_model && data.ab_test_percentage > 0) {
        const shouldUseAbVariant = Math.random() * 100 < data.ab_test_percentage
        if (shouldUseAbVariant) {
          console.log(`🔬 A/B 테스트 변형 사용: ${fortuneType} → ${data.ab_test_model}`)
          return {
            provider: data.ab_test_provider || data.provider,
            model: data.ab_test_model,
            temperature: data.temperature,
            maxTokens: data.max_tokens,
            isAbTest: true,
          }
        }
      }

      return {
        provider: data.provider,
        model: data.model,
        temperature: data.temperature,
        maxTokens: data.max_tokens,
        isAbTest: false,
      }
    } catch (error) {
      console.error(`❌ DB 설정 조회 실패 (${fortuneType}):`, error)
      return null
    }
  }

  /**
   * 정적 폴백 설정 (환경변수 또는 하드코딩)
   */
  private static getStaticFallback(): DynamicModelConfig {
    return {
      provider: (Deno.env.get('LLM_PROVIDER') || 'gemini') as DynamicModelConfig['provider'],
      model: Deno.env.get('LLM_DEFAULT_MODEL') || 'gemini-2.0-flash-lite',
      temperature: 1,
      maxTokens: 8192,
      isAbTest: false,
    }
  }

  /**
   * 캐시에서 설정 가져오기
   */
  private static getCachedConfig(fortuneType: string): DynamicModelConfig | null {
    const cached = configCache.get(fortuneType)
    if (cached && Date.now() - cached.timestamp < CACHE_TTL_MS) {
      return cached.config
    }
    return null
  }

  /**
   * 설정 캐싱
   */
  private static cacheConfig(fortuneType: string, config: DynamicModelConfig): void {
    configCache.set(fortuneType, {
      config,
      timestamp: Date.now(),
    })
  }

  /**
   * 캐시 초기화 (테스트용)
   */
  static clearCache(): void {
    configCache.clear()
  }

  /**
   * 캐시 상태 확인 (디버깅용)
   */
  static getCacheStats(): { size: number; keys: string[] } {
    return {
      size: configCache.size,
      keys: Array.from(configCache.keys()),
    }
  }
}
