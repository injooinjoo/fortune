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
  timestamp?: string;
}

export interface FortuneGenerationOptions {
  prompt: string;
  model: string;
  maxTokens: number;
  temperature: number;
}

export interface CachedFortune {
  fortune_type: string;
  data: any;
  generated_at: string;
  from_batch: boolean;
  batch_id?: string;
  expires_at?: string;
}