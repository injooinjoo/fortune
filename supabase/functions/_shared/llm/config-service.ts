// 동적 LLM 설정 서비스
// DB 기반 모델 설정 + 캐싱 + A/B 테스트 지원

import {
  createClient,
  SupabaseClient,
} from "https://esm.sh/@supabase/supabase-js@2";
import {
  GEMINI_SAFE_TEXT_MODEL,
  isHighCostGeminiModel,
  isPreviewGeminiModel,
} from "./models.ts";

export interface DynamicModelConfig {
  provider: "gemini" | "openai" | "anthropic" | "grok" | "gemma";
  model: string;
  temperature: number;
  maxTokens: number;
  isAbTest?: boolean;
}

interface CachedConfig {
  config: DynamicModelConfig;
  timestamp: number;
}

// 메모리 캐시 (기본 300초 TTL - 환경변수로 조정 가능)
const configCache = new Map<string, CachedConfig>();
const CACHE_TTL_MS = parseInt(
  Deno.env.get("LLM_CONFIG_CACHE_TTL_MS") || "300000",
); // 5분 (비용 최적화)
const SAFE_GEMINI_FALLBACK_MODEL = GEMINI_SAFE_TEXT_MODEL;
const DEFAULT_MAX_DB_TOKENS = 2048;

const FORTUNE_TYPE_ALIASES: Record<string, string> = {
  "fortune-time": "time",
  "fortune-biorhythm": "biorhythm",
  "fortune-pet": "pet-compatibility",
  "fortune-face-reading": "face-reading",
  "fortune-lucky-items": "lucky-items",
  "fortune-match-insight": "match-insight",
  "fortune-new-year": "new-year",
  "fortune-past-life": "past-life",
};

function isHighCostModelsAllowed(): boolean {
  const raw = Deno.env.get("LLM_ALLOW_HIGH_COST_MODELS");
  if (!raw) return false;
  const normalized = raw.trim().toLowerCase();
  return normalized === "1" || normalized === "true" || normalized === "yes" ||
    normalized === "on";
}

function isPreviewModelsAllowed(): boolean {
  const raw = Deno.env.get("LLM_ALLOW_PREVIEW_MODELS");
  if (!raw) return false;
  const normalized = raw.trim().toLowerCase();
  return normalized === "1" || normalized === "true" || normalized === "yes" ||
    normalized === "on";
}

function isAbTestEnabled(): boolean {
  const raw = Deno.env.get("LLM_AB_TEST_ENABLED");
  if (!raw) return true; // 기본값: 활성화 (DB 설정 존중)
  const normalized = raw.trim().toLowerCase();
  return normalized === "1" || normalized === "true" || normalized === "yes" ||
    normalized === "on";
}

function getAbTestMaxPercentage(): number {
  const raw = Deno.env.get("LLM_AB_TEST_MAX_PERCENTAGE");
  const parsed = parseInt(raw || "100");
  return Number.isFinite(parsed) ? Math.min(Math.max(parsed, 0), 100) : 100;
}

function getDbMaxTokenCap(): number {
  const rawCap = Number(
    Deno.env.get("LLM_MAX_DB_TOKENS_CAP") || DEFAULT_MAX_DB_TOKENS,
  );
  if (!Number.isFinite(rawCap)) {
    return DEFAULT_MAX_DB_TOKENS;
  }
  return Math.max(256, Math.min(Math.floor(rawCap), 8192));
}

// Supabase 클라이언트 싱글톤
let supabaseClient: SupabaseClient | null = null;

function getSupabaseClient(): SupabaseClient {
  if (!supabaseClient) {
    supabaseClient = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
    );
  }
  return supabaseClient;
}

export class ConfigService {
  /**
   * 운세 타입에 맞는 모델 설정 가져오기 (비동기)
   * 우선순위: DB 운세별 > DB _default > 환경변수 > 하드코딩
   */
  static async getModelConfig(
    fortuneType: string,
  ): Promise<DynamicModelConfig> {
    const requestedType = fortuneType.trim();

    // 1. 캐시 확인
    const cached = this.getCachedConfig(requestedType);
    if (cached) {
      console.log(`📦 캐시된 설정 사용: ${requestedType}`);
      return cached;
    }

    // 2. DB에서 운세별 설정 조회 (별칭 포함)
    const lookupKeys = this.buildLookupKeys(requestedType);
    for (const key of lookupKeys) {
      const dbConfig = await this.fetchFromDB(key);
      if (dbConfig) {
        const guarded = this.guardConfig(requestedType, dbConfig);
        this.cacheConfig(requestedType, guarded);
        return guarded;
      }
    }

    // 3. DB에서 기본 설정 조회
    const defaultConfig = await this.fetchFromDB("_default");
    if (defaultConfig) {
      const guarded = this.guardConfig(requestedType, defaultConfig);
      this.cacheConfig(requestedType, guarded);
      return guarded;
    }

    // 4. 환경변수/하드코딩 폴백
    const fallback = this.guardConfig(requestedType, this.getStaticFallback());
    this.cacheConfig(requestedType, fallback);
    return fallback;
  }

  /**
   * DB에서 설정 조회
   */
  private static async fetchFromDB(
    fortuneType: string,
  ): Promise<DynamicModelConfig | null> {
    try {
      const supabase = getSupabaseClient();
      const { data, error } = await supabase
        .from("llm_model_config")
        .select("*")
        .eq("fortune_type", fortuneType)
        .eq("is_active", true)
        .single();

      if (error || !data) {
        return null;
      }

      // A/B 테스트 처리 (환경변수로 전역 비활성화 가능, 최대 비율 제한 가능)
      const abTestGlobalEnabled = isAbTestEnabled();
      const abTestMaxPct = getAbTestMaxPercentage();
      const effectiveAbPct = Math.min(
        data.ab_test_percentage || 0,
        abTestMaxPct,
      );

      if (
        abTestGlobalEnabled && data.ab_test_enabled && data.ab_test_model &&
        effectiveAbPct > 0
      ) {
        const shouldUseAbVariant = Math.random() * 100 < effectiveAbPct;
        if (shouldUseAbVariant) {
          console.log(
            `🔬 A/B 테스트 변형 사용: ${fortuneType} → ${data.ab_test_model} (${effectiveAbPct}%)`,
          );
          return {
            provider: data.ab_test_provider || data.provider,
            model: data.ab_test_model,
            temperature: data.temperature,
            maxTokens: data.max_tokens,
            isAbTest: true,
          };
        }
      } else if (!abTestGlobalEnabled && data.ab_test_enabled) {
        console.log(
          `⚠️ A/B 테스트 비활성화됨 (LLM_AB_TEST_ENABLED=false): ${fortuneType}`,
        );
      }

      return {
        provider: data.provider,
        model: data.model,
        temperature: data.temperature,
        maxTokens: data.max_tokens,
        isAbTest: false,
      };
    } catch (error) {
      console.error(`❌ DB 설정 조회 실패 (${fortuneType}):`, error);
      return null;
    }
  }

  /**
   * 정적 폴백 설정 (환경변수 또는 하드코딩)
   */
  private static getStaticFallback(): DynamicModelConfig {
    return {
      provider:
        (Deno.env.get("LLM_PROVIDER") || "gemini") as DynamicModelConfig[
          "provider"
        ],
      model: Deno.env.get("LLM_DEFAULT_MODEL") || SAFE_GEMINI_FALLBACK_MODEL,
      temperature: 0.7,
      maxTokens: getDbMaxTokenCap(),
      isAbTest: false,
    };
  }

  private static buildLookupKeys(fortuneType: string): string[] {
    const keys = new Set<string>([fortuneType]);

    if (fortuneType.startsWith("fortune-")) {
      keys.add(fortuneType.replace(/^fortune-/, ""));
    }

    const alias = FORTUNE_TYPE_ALIASES[fortuneType];
    if (alias) {
      keys.add(alias);
    }

    return Array.from(keys);
  }

  private static guardConfig(
    fortuneType: string,
    config: DynamicModelConfig,
  ): DynamicModelConfig {
    const maxTokens = this.clampMaxTokens(config.maxTokens);
    const normalizedModel = (config.model || "").trim();

    let guarded: DynamicModelConfig = {
      ...config,
      model: normalizedModel || SAFE_GEMINI_FALLBACK_MODEL,
      maxTokens,
    };

    if (
      guarded.provider === "gemini" &&
      isPreviewGeminiModel(guarded.model) &&
      !isPreviewModelsAllowed()
    ) {
      console.warn(
        `🚨 프리뷰 Gemini 모델 차단: ${fortuneType} - ${guarded.model} -> ${SAFE_GEMINI_FALLBACK_MODEL}`,
      );
      guarded = {
        ...guarded,
        model: SAFE_GEMINI_FALLBACK_MODEL,
        isAbTest: false,
      };
    }

    if (
      guarded.provider === "gemini" &&
      !isHighCostModelsAllowed() &&
      this.isHighCostGeminiModel(guarded.model)
    ) {
      console.warn(
        `🚨 고비용 Gemini 모델 차단: ${fortuneType} - ${guarded.model} -> ${SAFE_GEMINI_FALLBACK_MODEL}`,
      );
      guarded = {
        ...guarded,
        model: SAFE_GEMINI_FALLBACK_MODEL,
        isAbTest: false,
      };
    }

    return guarded;
  }

  private static clampMaxTokens(maxTokens: number): number {
    const cap = getDbMaxTokenCap();
    const parsed = Number(maxTokens);
    if (!Number.isFinite(parsed) || parsed <= 0) {
      return cap;
    }
    return Math.max(128, Math.min(Math.floor(parsed), cap));
  }

  private static isHighCostGeminiModel(model: string): boolean {
    return isHighCostGeminiModel(model);
  }

  /**
   * 캐시에서 설정 가져오기
   */
  private static getCachedConfig(
    fortuneType: string,
  ): DynamicModelConfig | null {
    const cached = configCache.get(fortuneType);
    if (cached && Date.now() - cached.timestamp < CACHE_TTL_MS) {
      return cached.config;
    }
    return null;
  }

  /**
   * 설정 캐싱
   */
  private static cacheConfig(
    fortuneType: string,
    config: DynamicModelConfig,
  ): void {
    configCache.set(fortuneType, {
      config,
      timestamp: Date.now(),
    });
  }

  /**
   * 캐시 초기화 (테스트용)
   */
  static clearCache(): void {
    configCache.clear();
  }

  /**
   * 캐시 상태 확인 (디버깅용)
   */
  static getCacheStats(): { size: number; keys: string[] } {
    return {
      size: configCache.size,
      keys: Array.from(configCache.keys()),
    };
  }
}
