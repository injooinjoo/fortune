#!/usr/bin/env node

/**
 * 환경 변수 검증 스크립트
 * 프로덕션 배포 전 모든 필수 환경 변수가 설정되었는지 확인
 */

const fs = require('fs');
const path = require('path');
const dotenv = require('dotenv');

// .env.local 파일 로드
const envPath = path.join(__dirname, '..', '.env.local');
if (fs.existsSync(envPath)) {
  dotenv.config({ path: envPath });
}

// 환경 변수 설정 체크
const requiredEnvVars = {
  // Supabase (필수)
  'NEXT_PUBLIC_SUPABASE_URL': { 
    required: true, 
    pattern: /^https:\/\/.+\.supabase\.co$/,
    description: 'Supabase 프로젝트 URL'
  },
  'NEXT_PUBLIC_SUPABASE_ANON_KEY': { 
    required: true, 
    pattern: /^eyJ/,
    description: 'Supabase Anonymous Key'
  },
  'SUPABASE_SERVICE_ROLE_KEY': { 
    required: true, 
    pattern: /^eyJ/,
    description: 'Supabase Service Role Key'
  },
  
  // AI API Keys (필수)
  'OPENAI_API_KEY': { 
    required: true, 
    pattern: /^sk-/,
    description: 'OpenAI API Key'
  },
  
  // 보안 키 (필수)
  'INTERNAL_API_KEY': { 
    required: true, 
    minLength: 32,
    description: '내부 API 보안 키'
  },
  'CRON_SECRET': { 
    required: true, 
    minLength: 32,
    description: 'Cron 작업 보안 키'
  },
  
  // Stripe (프로덕션 필수)
  'STRIPE_SECRET_KEY': { 
    required: true, 
    pattern: /^sk_(test_|live_)/,
    description: 'Stripe Secret Key',
    productionPattern: /^sk_live_/
  },
  'STRIPE_WEBHOOK_SECRET': { 
    required: true, 
    pattern: /^whsec_/,
    description: 'Stripe Webhook Secret'
  },
  
  // Toss Payments (프로덕션 필수)
  'TOSS_CLIENT_KEY': { 
    required: true, 
    pattern: /^(test_|live_)ck_/,
    description: 'Toss Payments Client Key',
    productionPattern: /^live_ck_/
  },
  'TOSS_SECRET_KEY': { 
    required: true, 
    pattern: /^(test_|live_)sk_/,
    description: 'Toss Payments Secret Key',
    productionPattern: /^live_sk_/
  },
  
  // Redis (필수)
  'UPSTASH_REDIS_REST_URL': { 
    required: true, 
    pattern: /^https:\/\/.+\.upstash\.io$/,
    description: 'Upstash Redis REST URL'
  },
  'UPSTASH_REDIS_REST_TOKEN': { 
    required: true, 
    minLength: 20,
    description: 'Upstash Redis Token'
  },
  
  // Sentry (권장)
  'SENTRY_DSN': { 
    required: false, 
    pattern: /^https:\/\/.+@.+\.ingest\.sentry\.io\/.+$/,
    description: 'Sentry DSN'
  },
};

// 결과 저장
const results = {
  valid: [],
  invalid: [],
  missing: [],
  warnings: []
};

// 환경 변수 검증
console.log('\n🔍 Fortune 앱 환경 변수 검증 시작...\n');

const isProduction = process.env.NODE_ENV === 'production' || process.argv.includes('--production');

for (const [key, config] of Object.entries(requiredEnvVars)) {
  const value = process.env[key];
  
  if (!value) {
    if (config.required) {
      results.missing.push(`❌ ${key}: ${config.description} (필수)`);
    } else {
      results.warnings.push(`⚠️  ${key}: ${config.description} (권장)`);
    }
    continue;
  }
  
  // 패턴 검증
  if (config.pattern && !config.pattern.test(value)) {
    results.invalid.push(`❌ ${key}: 올바르지 않은 형식`);
    continue;
  }
  
  // 프로덕션 패턴 검증
  if (isProduction && config.productionPattern && !config.productionPattern.test(value)) {
    results.warnings.push(`⚠️  ${key}: 테스트 키 사용 중 (프로덕션에는 실제 키 필요)`);
    continue;
  }
  
  // 최소 길이 검증
  if (config.minLength && value.length < config.minLength) {
    results.invalid.push(`❌ ${key}: 너무 짧음 (최소 ${config.minLength}자)`);
    continue;
  }
  
  // 테스트 키 감지
  if (value.includes('test_') || value.includes('_test')) {
    if (!isProduction) {
      results.valid.push(`✅ ${key}: 설정됨 (테스트 키)`);
    } else {
      results.warnings.push(`⚠️  ${key}: 테스트 키 사용 중`);
    }
  } else {
    results.valid.push(`✅ ${key}: 설정됨`);
  }
}

// 추가 검증: Price ID들
const priceIds = [
  'STRIPE_PREMIUM_MONTHLY_PRICE_ID',
  'STRIPE_PREMIUM_YEARLY_PRICE_ID',
  'STRIPE_TOKENS_SMALL_PRICE_ID',
  'STRIPE_TOKENS_MEDIUM_PRICE_ID',
  'STRIPE_TOKENS_LARGE_PRICE_ID'
];

priceIds.forEach(key => {
  const value = process.env[key];
  if (!value) {
    results.missing.push(`❌ ${key}: Stripe 가격 ID (필수)`);
  } else if (!value.startsWith('price_')) {
    results.invalid.push(`❌ ${key}: 올바르지 않은 가격 ID 형식`);
  } else {
    results.valid.push(`✅ ${key}: 설정됨`);
  }
});

// 결과 출력
console.log('\n📊 검증 결과:\n');

if (results.valid.length > 0) {
  console.log('✅ 올바르게 설정된 환경 변수:');
  results.valid.forEach(msg => console.log(`   ${msg}`));
}

if (results.warnings.length > 0) {
  console.log('\n⚠️  경고:');
  results.warnings.forEach(msg => console.log(`   ${msg}`));
}

if (results.invalid.length > 0) {
  console.log('\n❌ 잘못된 환경 변수:');
  results.invalid.forEach(msg => console.log(`   ${msg}`));
}

if (results.missing.length > 0) {
  console.log('\n❌ 누락된 환경 변수:');
  results.missing.forEach(msg => console.log(`   ${msg}`));
}

// 요약
const totalRequired = Object.values(requiredEnvVars).filter(c => c.required).length + priceIds.length;
const totalValid = results.valid.length;
const totalIssues = results.invalid.length + results.missing.length;

console.log('\n📈 요약:');
console.log(`   총 필수 환경 변수: ${totalRequired}개`);
console.log(`   올바르게 설정됨: ${totalValid}개`);
console.log(`   문제 있음: ${totalIssues}개`);
console.log(`   경고: ${results.warnings.length}개`);

// 종료 코드 설정
if (totalIssues > 0) {
  console.log('\n❌ 환경 변수 설정을 완료한 후 다시 실행하세요.');
  console.log('📚 자세한 설정 방법은 docs/PRODUCTION_ENV_SETUP.md를 참고하세요.\n');
  process.exit(1);
} else if (results.warnings.length > 0) {
  console.log('\n⚠️  경고가 있지만 실행 가능합니다.');
  console.log('📚 프로덕션 배포 전에는 모든 경고를 해결하세요.\n');
  process.exit(0);
} else {
  console.log('\n✅ 모든 환경 변수가 올바르게 설정되었습니다!\n');
  process.exit(0);
}