#!/usr/bin/env node

/**
 * 환경 변수 검증 스크립트
 * 
 * 사용법:
 * - 개발 환경: npm run verify:env
 * - 프로덕션: NODE_ENV=production npm run verify:env
 */

const fs = require('fs');
const path = require('path');

// 색상 코드
const colors = {
  reset: '\x1b[0m',
  red: '\x1b[31m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  magenta: '\x1b[35m',
  cyan: '\x1b[36m',
};

// 환경별 필수 변수 정의
const requiredEnvVars = {
  // 공통 필수
  common: [
    'NEXT_PUBLIC_SUPABASE_URL',
    'NEXT_PUBLIC_SUPABASE_ANON_KEY',
    'SUPABASE_SERVICE_ROLE_KEY',
    'OPENAI_API_KEY',
  ],
  
  // 개발 환경
  development: [
    // 개발 환경에서는 추가 필수 없음
  ],
  
  // 프로덕션 환경
  production: [
    'STRIPE_SECRET_KEY',
    'STRIPE_WEBHOOK_SECRET',
    'STRIPE_PREMIUM_MONTHLY_PRICE_ID',
    'STRIPE_PREMIUM_YEARLY_PRICE_ID',
    'STRIPE_TOKENS_SMALL_PRICE_ID',
    'STRIPE_TOKENS_MEDIUM_PRICE_ID',
    'STRIPE_TOKENS_LARGE_PRICE_ID',
    'TOSS_CLIENT_KEY', 
    'TOSS_SECRET_KEY',
    'UPSTASH_REDIS_REST_URL',
    'UPSTASH_REDIS_REST_TOKEN',
    'INTERNAL_API_KEY',
    'CRON_SECRET',
    'SUPABASE_JWT_SECRET',
  ]
};

// 선택적 환경 변수
const optionalEnvVars = [
  'GOOGLE_GENAI_API_KEY',
  'NEXT_PUBLIC_ADSENSE_CLIENT_ID',
  'NEXT_PUBLIC_ADSENSE_SLOT_ID',
  'NEXT_PUBLIC_ADSENSE_DISPLAY_SLOT',
  'ERROR_TRACKING_ENDPOINT',
  'ERROR_TRACKING_API_KEY',
];

// 환경 변수 값 검증 규칙
const validationRules = {
  NEXT_PUBLIC_SUPABASE_URL: (value) => {
    return value.startsWith('https://') && value.includes('.supabase.co');
  },
  NEXT_PUBLIC_SUPABASE_ANON_KEY: (value) => {
    return value.startsWith('eyJ') && value.length > 100;
  },
  SUPABASE_SERVICE_ROLE_KEY: (value) => {
    return value.startsWith('eyJ') && value.length > 100;
  },
  SUPABASE_JWT_SECRET: (value) => {
    return value.length >= 32;
  },
  OPENAI_API_KEY: (value) => {
    return value.startsWith('sk-') && value.length > 40;
  },
  STRIPE_SECRET_KEY: (value) => {
    const isProduction = process.env.NODE_ENV === 'production';
    if (isProduction) {
      return value.startsWith('sk_live_') && !value.includes('test');
    }
    return value.startsWith('sk_test_') || value.startsWith('sk_live_');
  },
  STRIPE_WEBHOOK_SECRET: (value) => {
    return value.startsWith('whsec_');
  },
  STRIPE_PREMIUM_MONTHLY_PRICE_ID: (value) => {
    return value.startsWith('price_');
  },
  STRIPE_PREMIUM_YEARLY_PRICE_ID: (value) => {
    return value.startsWith('price_');
  },
  STRIPE_TOKENS_SMALL_PRICE_ID: (value) => {
    return value.startsWith('price_');
  },
  STRIPE_TOKENS_MEDIUM_PRICE_ID: (value) => {
    return value.startsWith('price_');
  },
  STRIPE_TOKENS_LARGE_PRICE_ID: (value) => {
    return value.startsWith('price_');
  },
  TOSS_CLIENT_KEY: (value) => {
    const isProduction = process.env.NODE_ENV === 'production';
    if (isProduction) {
      return value.startsWith('live_ck_');
    }
    return value.startsWith('test_ck_') || value.startsWith('live_ck_');
  },
  TOSS_SECRET_KEY: (value) => {
    const isProduction = process.env.NODE_ENV === 'production';
    if (isProduction) {
      return value.startsWith('live_sk_');
    }
    return value.startsWith('test_sk_') || value.startsWith('live_sk_');
  },
  UPSTASH_REDIS_REST_URL: (value) => {
    return value.startsWith('https://') && value.includes('.upstash.io');
  },
  UPSTASH_REDIS_REST_TOKEN: (value) => {
    return value.length > 20;
  },
  INTERNAL_API_KEY: (value) => {
    return value.length >= 32; // 최소 32자
  },
  CRON_SECRET: (value) => {
    return value.length >= 32; // 최소 32자
  }
};

function checkEnvVar(varName, required = true) {
  const value = process.env[varName];
  const exists = value !== undefined && value !== '';
  
  if (!exists && required) {
    console.log(`${colors.red}❌ ${varName}: 설정되지 않음${colors.reset}`);
    return false;
  } else if (!exists && !required) {
    console.log(`${colors.yellow}⚠️  ${varName}: 설정되지 않음 (선택사항)${colors.reset}`);
    return true;
  }
  
  // 값 검증
  const validator = validationRules[varName];
  if (validator && !validator(value)) {
    console.log(`${colors.red}❌ ${varName}: 잘못된 형식${colors.reset}`);
    
    // 프로덕션에서 테스트 키 사용 시 경고
    if (process.env.NODE_ENV === 'production') {
      if (varName.includes('STRIPE') && value.includes('test')) {
        console.log(`   ${colors.red}⚠️  프로덕션에서 Stripe 테스트 키를 사용하고 있습니다!${colors.reset}`);
      }
      if (varName.includes('TOSS') && value.includes('test')) {
        console.log(`   ${colors.red}⚠️  프로덕션에서 Toss 테스트 키를 사용하고 있습니다!${colors.reset}`);
      }
    }
    
    return false;
  }
  
  // 민감한 정보는 일부만 표시
  const displayValue = value.length > 20 ? 
    `${value.substring(0, 10)}...${value.substring(value.length - 10)}` : 
    '***';
  
  console.log(`${colors.green}✅ ${varName}: ${displayValue}${colors.reset}`);
  return true;
}

function checkDuplicateKeys() {
  const criticalKeys = ['INTERNAL_API_KEY', 'CRON_SECRET', 'SUPABASE_JWT_SECRET'];
  const values = new Set();
  
  for (const key of criticalKeys) {
    const value = process.env[key];
    if (value && values.has(value)) {
      console.log(`${colors.red}❌ 보안 경고: ${key}가 다른 키와 동일한 값을 사용하고 있습니다!${colors.reset}`);
      return false;
    }
    if (value) values.add(value);
  }
  
  return true;
}

function main() {
  console.log(`${colors.cyan}========================================${colors.reset}`);
  console.log(`${colors.cyan}🔍 환경 변수 검증 시작${colors.reset}`);
  console.log(`${colors.cyan}========================================${colors.reset}\n`);
  
  const nodeEnv = process.env.NODE_ENV || 'development';
  console.log(`${colors.blue}환경: ${nodeEnv}${colors.reset}\n`);
  
  // .env 파일 확인
  const envFile = nodeEnv === 'production' ? '.env.production' : '.env.local';
  const envPath = path.join(process.cwd(), envFile);
  
  if (!fs.existsSync(envPath)) {
    console.log(`${colors.red}❌ ${envFile} 파일을 찾을 수 없습니다.${colors.reset}`);
    
    if (nodeEnv === 'production' && fs.existsSync(path.join(process.cwd(), '.env.production.template'))) {
      console.log(`\n${colors.yellow}💡 .env.production.template 파일을 복사하여 .env.production을 생성하세요:${colors.reset}`);
      console.log(`   cp .env.production.template .env.production`);
    }
    
    process.exit(1);
  }
  
  // 환경 변수 로드
  require('dotenv').config({ path: envPath });
  
  let allValid = true;
  
  // 공통 필수 변수 확인
  console.log(`${colors.magenta}📋 필수 환경 변수${colors.reset}`);
  console.log('─'.repeat(40));
  
  const requiredVars = [
    ...requiredEnvVars.common,
    ...(requiredEnvVars[nodeEnv] || [])
  ];
  
  for (const varName of requiredVars) {
    if (!checkEnvVar(varName, true)) {
      allValid = false;
    }
  }
  
  // 선택적 변수 확인
  console.log(`\n${colors.magenta}📋 선택적 환경 변수${colors.reset}`);
  console.log('─'.repeat(40));
  
  for (const varName of optionalEnvVars) {
    checkEnvVar(varName, false);
  }
  
  // 보안 키 중복 확인
  console.log(`\n${colors.magenta}🔒 보안 검증${colors.reset}`);
  console.log('─'.repeat(40));
  
  if (!checkDuplicateKeys()) {
    allValid = false;
  }
  
  // 결과 출력
  console.log(`\n${colors.cyan}========================================${colors.reset}`);
  
  if (allValid) {
    console.log(`${colors.green}✅ 모든 필수 환경 변수가 올바르게 설정되었습니다!${colors.reset}`);
    
    // 프로덕션 환경 추가 체크
    if (nodeEnv === 'production') {
      console.log(`\n${colors.yellow}⚠️  프로덕션 배포 전 최종 확인사항:${colors.reset}`);
      console.log('• ✅ Stripe 라이브 키 사용 확인');
      console.log('• ✅ Toss 라이브 키 사용 확인');
      console.log('• ⏳ Redis 프로덕션 연결 테스트 필요');
      console.log('• ✅ 보안 키 강도 확인 (32자 이상)');
      console.log('• ⏳ 모니터링 시스템 설정 필요');
      console.log('• ⏳ 백업 계획 수립 필요');
      
      console.log(`\n${colors.blue}다음 단계:${colors.reset}`);
      console.log('1. Redis 연결 테스트: npm run test:redis');
      console.log('2. 결제 시스템 테스트: npm run test:payments');
      console.log('3. 빌드 테스트: npm run build');
    }
  } else {
    console.log(`${colors.red}❌ 일부 필수 환경 변수가 누락되었습니다!${colors.reset}`);
    console.log(`\n${colors.yellow}💡 해결 방법:${colors.reset}`);
    console.log(`1. ${envFile} 파일을 확인하세요`);
    console.log(`2. 누락된 환경 변수를 추가하세요`);
    console.log(`3. 값의 형식이 올바른지 확인하세요`);
    
    if (nodeEnv === 'production') {
      console.log(`4. 프로덕션 키를 사용하고 있는지 확인하세요 (테스트 키 X)`);
    }
    
    process.exit(1);
  }
  
  console.log(`${colors.cyan}========================================${colors.reset}`);
}

// 실행
main();