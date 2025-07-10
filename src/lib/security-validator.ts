import { logger } from '@/lib/logger';

/**
 * Security validation utilities for environment variables and API security
 */

interface SecurityCheckResult {
  isSecure: boolean;
  warnings: string[];
  errors: string[];
  recommendations: string[];
}

interface EnvironmentVariable {
  name: string;
  isRequired: boolean;
  isSecret: boolean;
  description: string;
}

const REQUIRED_ENV_VARS: EnvironmentVariable[] = [
  // Public variables (safe to expose to client)
  { name: 'NEXT_PUBLIC_SUPABASE_URL', isRequired: true, isSecret: false, description: 'Supabase project URL' },
  { name: 'NEXT_PUBLIC_SUPABASE_ANON_KEY', isRequired: true, isSecret: false, description: 'Supabase anonymous key' },
  
  // Secret variables (must never be exposed to client)
  { name: 'SUPABASE_SERVICE_ROLE_KEY', isRequired: true, isSecret: true, description: 'Supabase service role key' },
  { name: 'OPENAI_API_KEY', isRequired: true, isSecret: true, description: 'OpenAI API key' },
  { name: 'INTERNAL_API_KEY', isRequired: true, isSecret: true, description: 'Internal API authentication key' },
  { name: 'CRON_SECRET', isRequired: true, isSecret: true, description: 'Cron job authentication secret' },
  
  // Optional but recommended
  { name: 'SENTRY_DSN', isRequired: false, isSecret: true, description: 'Sentry error monitoring DSN' },
  { name: 'NEXT_PUBLIC_SENTRY_DSN', isRequired: false, isSecret: false, description: 'Sentry client-side DSN' },
  
  // Redis configuration (optional but recommended for production)
  { name: 'UPSTASH_REDIS_REST_URL', isRequired: false, isSecret: false, description: 'Upstash Redis REST API URL' },
  { name: 'UPSTASH_REDIS_REST_TOKEN', isRequired: false, isSecret: true, description: 'Upstash Redis REST API token' },
];

/**
 * Validates environment variables for security compliance
 */
export function validateEnvironmentSecurity(): SecurityCheckResult {
  const warnings: string[] = [];
  const errors: string[] = [];
  const recommendations: string[] = [];

  // Check required environment variables
  for (const envVar of REQUIRED_ENV_VARS) {
    const value = process.env[envVar.name];
    
    if (envVar.isRequired && (!value || value.length === 0)) {
      errors.push(`Missing required environment variable: ${envVar.name} (${envVar.description})`);
    }

    if (value) {
      // Check for placeholder values
      if (value.includes('your_') || value.includes('replace_') || value === 'your-key-here') {
        errors.push(`Environment variable ${envVar.name} contains placeholder value`);
      }

      // Check secret variables for minimum security requirements
      if (envVar.isSecret) {
        if (value.length < 20) {
          warnings.push(`Environment variable ${envVar.name} is too short (minimum 20 characters recommended)`);
        }
        
        // Check for common insecure patterns
        if (value === 'test' || value === 'dev' || value === 'secret') {
          errors.push(`Environment variable ${envVar.name} uses insecure test value`);
        }
      }
    }
  }

  // Check for exposed secrets in client-side code
  const clientExposedSecrets = Object.keys(process.env)
    .filter(key => key.startsWith('NEXT_PUBLIC_'))
    .filter(key => {
      const value = process.env[key] || '';
      return REQUIRED_ENV_VARS.some(envVar => 
        envVar.isSecret && envVar.name !== key && value.includes('sk-')
      );
    });

  if (clientExposedSecrets.length > 0) {
    errors.push(`Potential secrets exposed in client environment: ${clientExposedSecrets.join(', ')}`);
  }

  // Generate recommendations
  if (errors.length === 0 && warnings.length === 0) {
    recommendations.push('✅ All environment variables are properly configured');
  }
  
  if (!process.env.SENTRY_DSN && !process.env.NEXT_PUBLIC_SENTRY_DSN) {
    recommendations.push('Consider setting up Sentry for error monitoring');
  }
  
  if (!process.env.UPSTASH_REDIS_REST_URL || !process.env.UPSTASH_REDIS_REST_TOKEN) {
    recommendations.push('Consider setting up Upstash Redis for persistent rate limiting and caching');
  }
  
  if (process.env.NODE_ENV === 'production') {
    recommendations.push('Ensure all environment variables are set in production deployment');
    recommendations.push('Review and rotate API keys regularly');
  }

  const isSecure = errors.length === 0;

  return {
    isSecure,
    warnings,
    errors,
    recommendations
  };
}

/**
 * Validates API endpoint security configuration
 */
export function validateApiSecurity(): SecurityCheckResult {
  const warnings: string[] = [];
  const errors: string[] = [];
  const recommendations: string[] = [];

  // Check authentication middleware configuration
  if (!process.env.INTERNAL_API_KEY) {
    errors.push('INTERNAL_API_KEY not configured - admin endpoints are vulnerable');
  }

  if (!process.env.CRON_SECRET) {
    errors.push('CRON_SECRET not configured - cron endpoints are vulnerable');
  }

  // Check for development configurations in production
  if (process.env.NODE_ENV === 'production') {
    if (process.env.NEXT_PUBLIC_SUPABASE_URL?.includes('localhost')) {
      errors.push('Production environment pointing to localhost Supabase');
    }
    
    const allowedOrigins = [
      process.env.NEXT_PUBLIC_APP_URL,
      process.env.NEXT_PUBLIC_VERCEL_URL
    ].filter(Boolean);
    
    if (allowedOrigins.length === 0) {
      warnings.push('No production URLs configured for CORS');
    }
  }

  // Rate limiting validation
  if (process.env.UPSTASH_REDIS_REST_URL && process.env.UPSTASH_REDIS_REST_TOKEN) {
    recommendations.push('Rate limiting is configured via Edge Middleware with Redis persistence');
  } else {
    recommendations.push('Rate limiting is configured via Edge Middleware (in-memory fallback)');
    warnings.push('Redis not configured - rate limits will reset on deployment');
  }
  recommendations.push('Monitor rate limit violations in production logs');

  const isSecure = errors.length === 0;

  return {
    isSecure,
    warnings,
    errors,
    recommendations
  };
}

/**
 * Performs comprehensive security audit
 */
export function performSecurityAudit(): {
  overall: SecurityCheckResult;
  environment: SecurityCheckResult;
  api: SecurityCheckResult;
} {
  const environment = validateEnvironmentSecurity();
  const api = validateApiSecurity();

  const overall: SecurityCheckResult = {
    isSecure: environment.isSecure && api.isSecure,
    warnings: [...environment.warnings, ...api.warnings],
    errors: [...environment.errors, ...api.errors],
    recommendations: [...environment.recommendations, ...api.recommendations]
  };

  return { overall, environment, api };
}

/**
 * Logs security audit results
 */
export function logSecurityAudit(): void {
  const audit = performSecurityAudit();
  
  logger.debug('\n🔐 SECURITY AUDIT REPORT');
  logger.debug('='.repeat(50));
  
  logger.debug(`\n📊 Overall Security Status: ${audit.overall.isSecure ? '✅ SECURE' : '❌ VULNERABLE'}`);
  
  if (audit.overall.errors.length > 0) {
    logger.debug('\n🚨 CRITICAL ERRORS:');
    audit.overall.errors.forEach(error => logger.debug(`  ❌ ${error}`));
  }
  
  if (audit.overall.warnings.length > 0) {
    logger.debug('\n⚠️  WARNINGS:');
    audit.overall.warnings.forEach(warning => logger.debug(`  ⚠️  ${warning}`));
  }
  
  if (audit.overall.recommendations.length > 0) {
    logger.debug('\n💡 RECOMMENDATIONS:');
    audit.overall.recommendations.forEach(rec => logger.debug(`  💡 ${rec}`));
  }
  
  logger.debug('\n' + '='.repeat(50));
  logger.debug('Security audit completed.\n');
}

/**
 * Middleware to check security on API requests
 */
export function requireSecureEnvironment(): void {
  const audit = performSecurityAudit();
  
  if (!audit.overall.isSecure) {
    throw new Error(`Security validation failed: ${audit.overall.errors.join(', ')}`);
  }
}