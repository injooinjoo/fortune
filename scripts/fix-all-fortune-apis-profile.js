#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const baseDir = path.join(__dirname, '..', 'src', 'app', 'api', 'fortune');

// 모든 route.ts 파일 찾기 (백업 파일 제외)
function findAllRouteFiles() {
  const output = execSync('find src/app/api/fortune -name "route.ts" | grep -v backup', { 
    encoding: 'utf-8',
    cwd: path.join(__dirname, '..')
  });
  return output.trim().split('\n').filter(f => f);
}

// getDefaultUserProfile을 사용하는 파일 찾기
function findFilesWithDefaultProfile() {
  try {
    const output = execSync('grep -l "getDefaultUserProfile" src/app/api/fortune/*/route.ts | grep -v backup', { 
      encoding: 'utf-8',
      cwd: path.join(__dirname, '..')
    });
    return output.trim().split('\n').filter(f => f);
  } catch (e) {
    return [];
  }
}

function updateFortuneApi(filePath) {
  const fullPath = path.join(__dirname, '..', filePath);
  
  if (!fs.existsSync(fullPath)) {
    console.error(`❌ 파일을 찾을 수 없음: ${fullPath}`);
    return false;
  }

  let content = fs.readFileSync(fullPath, 'utf-8');
  let modified = false;
  
  // 이미 getUserProfileForAPI를 사용하는지 확인
  if (content.includes('getUserProfileForAPI')) {
    console.log(`✓ 이미 업데이트됨: ${filePath}`);
    return true;
  }
  
  // Import 문 업데이트 - 다양한 패턴 처리
  if (!content.includes("import { getUserProfileForAPI }")) {
    // handleFortuneResponse import가 있는 경우
    if (content.includes("import { handleFortuneResponse } from '@/lib/api-utils'")) {
      content = content.replace(
        "import { handleFortuneResponse } from '@/lib/api-utils'",
        "import { handleFortuneResponse, getUserProfileForAPI } from '@/lib/api-utils'"
      );
      modified = true;
    }
    // handleFortuneResponseWithSpread import가 있는 경우
    else if (content.includes("import { handleFortuneResponseWithSpread } from '@/lib/api-utils'")) {
      content = content.replace(
        "import { handleFortuneResponseWithSpread } from '@/lib/api-utils'",
        "import { handleFortuneResponseWithSpread, getUserProfileForAPI } from '@/lib/api-utils'"
      );
      modified = true;
    }
    // api-utils import가 없는 경우 추가
    else if (content.includes("from '@/lib/api-response-utils'")) {
      content = content.replace(
        /from '@\/lib\/api-response-utils';/,
        `from '@/lib/api-response-utils';
import { getUserProfileForAPI } from '@/lib/api-utils';`
      );
      modified = true;
    }
  }
  
  // getDefaultUserProfile 함수 정의 제거
  if (content.includes('const getDefaultUserProfile')) {
    content = content.replace(
      /\/\/ 개발용 기본 사용자 프로필.*?\n.*?const getDefaultUserProfile = [\s\S]*?\n\}\);?\n/g,
      ''
    );
    modified = true;
  }
  
  // 프로필 조회 로직 교체 - 다양한 패턴 처리
  const patterns = [
    {
      // 패턴 1: const profile = getDefaultUserProfile(userId);
      search: /const profile = getDefaultUserProfile\(([^)]+)\);/g,
      replace: (match, userId) => `// 실제 사용자 프로필을 가져옴
    const { profile, needsOnboarding } = await getUserProfileForAPI(${userId});
    
    if (needsOnboarding || !profile) {
      return createErrorResponse(
        '프로필 설정이 필요합니다.',
        undefined,
        { needsOnboarding: true },
        403
      );
    }`
    },
    {
      // 패턴 2: const userProfile = getDefaultUserProfile(userId);
      search: /const userProfile = getDefaultUserProfile\(([^)]+)\);/g,
      replace: (match, userId) => `// 실제 사용자 프로필을 가져옴
    const { profile: userProfile, needsOnboarding } = await getUserProfileForAPI(${userId});
    
    if (needsOnboarding || !userProfile) {
      return createErrorResponse(
        '프로필 설정이 필요합니다.',
        undefined,
        { needsOnboarding: true },
        403
      );
    }`
    },
    {
      // 패턴 3: userProfile = getDefaultUserProfile(userId);
      search: /userProfile = getDefaultUserProfile\(([^)]+)\);/g,
      replace: (match, userId) => `// 실제 사용자 프로필을 가져옴
    const { profile: userProfile, needsOnboarding } = await getUserProfileForAPI(${userId});
    
    if (needsOnboarding || !userProfile) {
      return createErrorResponse(
        '프로필 설정이 필요합니다.',
        undefined,
        { needsOnboarding: true },
        403
      );
    }`
    }
  ];
  
  patterns.forEach(pattern => {
    if (content.match(pattern.search)) {
      content = content.replace(pattern.search, pattern.replace);
      modified = true;
    }
  });
  
  if (modified) {
    fs.writeFileSync(fullPath, content, 'utf-8');
    console.log(`✅ 업데이트 완료: ${filePath}`);
    return true;
  } else {
    console.log(`ℹ️  변경사항 없음: ${filePath}`);
    return false;
  }
}

console.log('🚀 모든 Fortune API 프로필 조회 업데이트 시작...\n');

const filesToUpdate = findFilesWithDefaultProfile();
console.log(`📋 업데이트할 파일 ${filesToUpdate.length}개 발견\n`);

let successCount = 0;
filesToUpdate.forEach(file => {
  if (updateFortuneApi(file)) {
    successCount++;
  }
});

console.log(`\n✅ 완료: ${successCount}개 파일 업데이트됨`);

// 최종 확인
console.log('\n🔍 최종 getDefaultUserProfile 사용 현황 확인...');
const remaining = findFilesWithDefaultProfile();
if (remaining.length > 0) {
  console.log(`⚠️  아직 ${remaining.length}개 파일이 getDefaultUserProfile을 사용합니다:`);
  remaining.forEach(f => console.log(`  - ${f}`));
} else {
  console.log('✅ 모든 파일이 성공적으로 업데이트되었습니다!');
}