#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

// Fortune API 경로들 중 withFortuneAuth 패턴을 사용하는 파일들
const fortuneApisWithAuth = [
  'mbti/route.ts'
];

const baseDir = path.join(__dirname, '..', 'src', 'app', 'api', 'fortune');

function updateFortuneApiWithAuth(filePath) {
  const fullPath = path.join(baseDir, filePath);
  
  if (!fs.existsSync(fullPath)) {
    console.error(`❌ 파일을 찾을 수 없음: ${fullPath}`);
    return false;
  }

  let content = fs.readFileSync(fullPath, 'utf-8');
  
  // Import 문에 getUserProfileForAPI 추가
  if (!content.includes('getUserProfileForAPI')) {
    content = content.replace(
      /import { createSuccessResponse, createErrorResponse, createFortuneResponse, handleApiError } from '@\/lib\/api-response-utils';/g,
      `import { createSuccessResponse, createErrorResponse, createFortuneResponse, handleApiError } from '@/lib/api-response-utils';
import { getUserProfileForAPI } from '@/lib/api-utils';`
    );
  }
  
  // getDefaultUserProfile 함수 호출부를 찾아서 교체
  const getDefaultProfileRegex = /\/\/ 기본 사용자 프로필 생성\s*\n\s*const profile = getDefaultUserProfile\(userId\);/g;
  
  if (content.match(getDefaultProfileRegex)) {
    content = content.replace(
      getDefaultProfileRegex,
      `// 실제 사용자 프로필을 가져옴
    const { profile, needsOnboarding } = await getUserProfileForAPI(userId);
    
    if (needsOnboarding || !profile) {
      return createErrorResponse(
        '프로필 설정이 필요합니다.',
        undefined,
        { needsOnboarding: true },
        403
      );
    }`
    );
    
    fs.writeFileSync(fullPath, content, 'utf-8');
    console.log(`✅ 업데이트 완료: ${filePath}`);
    return true;
  } else {
    console.log(`ℹ️  이미 업데이트됨 또는 다른 패턴 사용: ${filePath}`);
    return false;
  }
}

console.log('🚀 나머지 Fortune API 프로필 조회 업데이트 시작...\n');

let successCount = 0;

fortuneApisWithAuth.forEach(api => {
  if (updateFortuneApiWithAuth(api)) {
    successCount++;
  }
});

console.log(`\n✅ 완료: ${successCount}개 파일 업데이트됨`);

// 모든 Fortune API에서 getDefaultUserProfile이 남아있는지 확인
console.log('\n🔍 getDefaultUserProfile 사용 현황 확인 중...');
const { execSync } = require('child_process');
try {
  const grepResult = execSync('grep -r "getDefaultUserProfile" src/app/api/fortune/', { encoding: 'utf-8' });
  console.log('⚠️  아직 getDefaultUserProfile을 사용하는 파일들:');
  console.log(grepResult);
} catch (e) {
  console.log('✅ getDefaultUserProfile을 사용하는 파일이 없습니다!');
}