#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

// 이미 withAuth가 적용된 파일들
const alreadyProtected = [
  'daily', 'lucky-investment', 'generate-batch', 'love', 
  'marriage', 'destiny', 'talent', 'tojeong'
];

// 보호가 필요한 파일들 (이미 수정한 파일 제외)
const filesToProtect = [
  'hourly', 'weekly', 'monthly', 'yearly', 'tomorrow', 'new-year',
  'birthdate', 'birth-season', 'zodiac', 'zodiac-animal', 'mbti',
  'blood-type', 'birthstone', 'personality', 'biorhythm',
  'lucky-color', 'lucky-number', 'lucky-food', 'lucky-items', 'lucky-outfit',
  'lucky-exam', 'lucky-job', 'lucky-realestate', 'lucky-sidejob',
  'lucky-fishing', 'lucky-hiking', 'lucky-running', 'lucky-swim',
  'lucky-cycling', 'lucky-golf', 'lucky-tennis', 'lucky-baseball',
  'lucky-series', 'avoid-people', 'network-report',
  'career', 'employment', 'business', 'startup', 'wealth',
  'chemistry', 'compatibility', 'couple-match', 'blind-date', 'ex-lover',
  'traditional-compatibility', 'traditional-saju', 'saju-psychology',
  'palmistry', 'physiognomy', 'face-reading', 
  'five-blessings', 'timeline', 'past-life', 'celebrity', 'celebrity-match',
  'moving', 'moving-date', 'salpuli', 'talisman', 'wish',
  'generate', '[category]'
];

// 이미 수정한 파일
const alreadyModified = ['today'];

function generateSecureRouteCode(fileName) {
  // 기본 템플릿
  return `import { NextRequest, NextResponse } from 'next/server';
import { withFortuneAuth, createSafeErrorResponse } from '@/lib/security-api-utils';
import { AuthenticatedRequest } from '@/middleware/auth';
import { FortuneService } from '@/lib/services/fortune-service';
import { UserProfile } from '@/lib/types/fortune-system';

export const GET = withFortuneAuth(async (request: AuthenticatedRequest, fortuneService: FortuneService) => {
  try {
    console.log('🔮 ${fileName} 운세 API 요청');
    
    // 기본 사용자 프로필 생성 (게스트용)
    const userProfile: UserProfile = {
      id: request.userId!,
      name: request.isGuest ? '게스트 사용자' : '회원',
      birth_date: '1990-01-01',
      birth_time: '오시',
      gender: '선택 안함',
      mbti: 'ENFP',
      zodiac_sign: '염소자리',
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    };
    
    const result = await fortuneService.getOrCreateFortune(
      request.userId!, 
      '${fileName}',
      userProfile
    );
    
    console.log('✅ ${fileName} 운세 API 응답 완료');
    
    return NextResponse.json({
      success: true,
      data: result.data,
      cached: result.cached,
      cache_source: result.cache_source,
      generated_at: result.generated_at
    });
    
  } catch (error) {
    return createSafeErrorResponse(error, '${fileName} 운세를 가져오는 중 오류가 발생했습니다.');
  }
});`;
}

// 실행
console.log('🔒 Fortune API 보안 적용 시작...\n');

filesToProtect.forEach(fileName => {
  if (alreadyModified.includes(fileName)) {
    console.log(`⏭️  ${fileName} - 이미 수정됨`);
    return;
  }
  
  const filePath = path.join(__dirname, `../src/app/api/fortune/${fileName}/route.ts`);
  
  if (!fs.existsSync(filePath)) {
    console.log(`❌ ${fileName} - 파일이 존재하지 않음`);
    return;
  }
  
  console.log(`📝 ${fileName} - 보안 적용 중...`);
  
  // 파일 백업
  const backupPath = filePath + '.backup';
  if (!fs.existsSync(backupPath)) {
    fs.copyFileSync(filePath, backupPath);
  }
  
  // 새 코드 생성 및 저장
  // 주의: 실제로는 기존 코드를 분석하여 필요한 부분만 수정해야 함
  // 이 스크립트는 데모용이므로 실제 사용 시 주의 필요
  console.log(`✅ ${fileName} - 백업 완료 (실제 수정은 수동으로 필요)`);
});

console.log('\n📋 요약:');
console.log(`- 이미 보호된 파일: ${alreadyProtected.length}개`);
console.log(`- 보호 필요 파일: ${filesToProtect.length}개`);
console.log(`- 이미 수정된 파일: ${alreadyModified.length}개`);
console.log('\n⚠️  주의: 이 스크립트는 백업만 생성합니다. 실제 수정은 각 파일의 구조를 확인하여 수동으로 진행하세요.');