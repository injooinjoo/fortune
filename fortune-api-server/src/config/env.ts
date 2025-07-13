import joi from 'joi';
import logger from '../utils/logger';

// Environment variables schema
const envSchema = joi.object({
  NODE_ENV: joi.string().valid('development', 'production', 'test').default('development'),
  PORT: joi.number().default(3001),
  API_VERSION: joi.string().default('v1'),
  
  // CORS
  ALLOWED_ORIGINS: joi.string().required(),
  
  // Supabase
  SUPABASE_URL: joi.string().uri().required(),
  SUPABASE_ANON_KEY: joi.string().required(),
  SUPABASE_SERVICE_ROLE_KEY: joi.string().required(),
  
  // OpenAI
  OPENAI_API_KEY: joi.string().required(),
  OPENAI_MODEL: joi.string().default('gpt-4-turbo-preview'),
  
  // Redis
  UPSTASH_REDIS_REST_URL: joi.string().uri().required(),
  UPSTASH_REDIS_REST_TOKEN: joi.string().required(),
  
  // Security
  JWT_SECRET: joi.string().required(),
  INTERNAL_API_KEY: joi.string().required(),
  CRON_SECRET: joi.string().required(),
  
  // Optional
  GOOGLE_AI_API_KEY: joi.string().optional(),
  STRIPE_SECRET_KEY: joi.string().optional(),
  STRIPE_WEBHOOK_SECRET: joi.string().optional(),
  TOSS_SECRET_KEY: joi.string().optional(),
  
  // In-App Purchase
  APPLE_IAP_SHARED_SECRET: joi.string().optional(),
  GOOGLE_SERVICE_ACCOUNT_KEY_PATH: joi.string().optional(),
  
  // Rate limiting
  RATE_LIMIT_WINDOW_MS: joi.number().default(60000),
  RATE_LIMIT_MAX_REQUESTS: joi.number().default(100),
  
  // Logging
  LOG_LEVEL: joi.string().valid('error', 'warn', 'info', 'debug').default('info'),
  LOG_FORMAT: joi.string().valid('json', 'simple').default('json'),
}).unknown(true);

export function validateEnv(): void {
  const { error } = envSchema.validate(process.env, {
    abortEarly: false,
  });
  
  if (error) {
    logger.error('Environment validation failed:', error.details);
    throw new Error(`Environment validation failed: ${error.message}`);
  }
}

// Type-safe environment variables
export const env = {
  NODE_ENV: process.env.NODE_ENV as 'development' | 'production' | 'test',
  PORT: parseInt(process.env.PORT || '3001'),
  API_VERSION: process.env.API_VERSION || 'v1',
  
  // CORS
  ALLOWED_ORIGINS: process.env.ALLOWED_ORIGINS?.split(',') || [],
  
  // Supabase
  SUPABASE_URL: process.env.SUPABASE_URL!,
  SUPABASE_ANON_KEY: process.env.SUPABASE_ANON_KEY!,
  SUPABASE_SERVICE_ROLE_KEY: process.env.SUPABASE_SERVICE_ROLE_KEY!,
  
  // OpenAI
  OPENAI_API_KEY: process.env.OPENAI_API_KEY!,
  OPENAI_MODEL: process.env.OPENAI_MODEL || 'gpt-4-turbo-preview',
  
  // Redis
  UPSTASH_REDIS_REST_URL: process.env.UPSTASH_REDIS_REST_URL!,
  UPSTASH_REDIS_REST_TOKEN: process.env.UPSTASH_REDIS_REST_TOKEN!,
  
  // Security
  JWT_SECRET: process.env.JWT_SECRET!,
  INTERNAL_API_KEY: process.env.INTERNAL_API_KEY!,
  CRON_SECRET: process.env.CRON_SECRET!,
  
  // Optional
  GOOGLE_AI_API_KEY: process.env.GOOGLE_AI_API_KEY,
  STRIPE_SECRET_KEY: process.env.STRIPE_SECRET_KEY,
  STRIPE_WEBHOOK_SECRET: process.env.STRIPE_WEBHOOK_SECRET,
  TOSS_SECRET_KEY: process.env.TOSS_SECRET_KEY,
  
  // In-App Purchase
  APPLE_IAP_SHARED_SECRET: process.env.APPLE_IAP_SHARED_SECRET,
  GOOGLE_SERVICE_ACCOUNT_KEY_PATH: process.env.GOOGLE_SERVICE_ACCOUNT_KEY_PATH,
  
  // Rate limiting
  RATE_LIMIT_WINDOW_MS: parseInt(process.env.RATE_LIMIT_WINDOW_MS || '60000'),
  RATE_LIMIT_MAX_REQUESTS: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS || '100'),
  
  // Logging
  LOG_LEVEL: process.env.LOG_LEVEL || 'info',
  LOG_FORMAT: process.env.LOG_FORMAT || 'json',
};