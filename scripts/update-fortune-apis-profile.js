#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

// Fortune API 경로들 (getDefaultUserProfile을 사용하는 18개 파일)
const fortuneApis = [
  'biorhythm/route.ts',
  'hourly/route.ts',
  'love/route.ts',
  'mbti/route.ts',
  'monthly/route.ts',
  'network-report/route.ts',
  'personality/route.ts',
  'saju-psychology/route.ts',
  'tomorrow/route.ts',
  'traditional-compatibility/route.ts',
  'traditional-saju/route.ts',
  'weekly/route.ts',
  'yearly/route.ts',
  'zodiac-animal/route.ts',
  'destiny/route.ts',
  'marriage/route.ts',
  'talent/route.ts',
  'tojeong/route.ts'
];

const baseDir = path.join(__dirname, '..', 'src', 'app', 'api', 'fortune');

// 이미 업데이트된 파일은 제외
const completedFiles = ['love/route.ts'];

function updateFortuneApi(filePath) {
  const fullPath = path.join(baseDir, filePath);
  
  if (!fs.existsSync(fullPath)) {
    console.error(`❌ 파일을 찾을 수 없음: ${fullPath}`);
    return false;
  }

  if (completedFiles.includes(filePath)) {
    console.log(`✓ 이미 업데이트됨: ${filePath}`);
    return true;
  }

  let content = fs.readFileSync(fullPath, 'utf-8');
  
  // Import 문 업데이트
  content = content.replace(
    /import { handleFortuneResponseWithSpread } from '@\/lib\/api-utils';/g,
    "import { handleFortuneResponseWithSpread, getUserProfileForAPI } from '@/lib/api-utils';"
  );
  
  // getDefaultUserProfile 함수 제거
  content = content.replace(
    /\/\/ 개발용 기본 사용자 프로필.*?\n.*?const getDefaultUserProfile = \(userId: string\): UserProfile => \(\{[\s\S]*?\}\);/g,
    ''
  );
  
  // 프로필 조회 로직 교체
  content = content.replace(
    /\/\/ 실제 사용자 프로필을 가져와야 함 \(TODO: DB에서 조회\)\s*\n\s*const userProfile = getDefaultUserProfile\(req\.userId\);/g,
    `// 실제 사용자 프로필을 가져옴
      const { profile, needsOnboarding } = await getUserProfileForAPI(req.userId);
      
      if (needsOnboarding || !profile) {
        return createErrorResponse(
          '프로필 설정이 필요합니다.',
          undefined,
          { needsOnboarding: true },
          403
        );
      }`
  );
  
  // userProfile을 profile로 변경
  content = content.replace(/userProfile/g, 'profile');
  
  // 불필요한 UserProfile import 제거 (이미 api-utils에서 import됨)
  content = content.replace(
    /import { UserProfile } from '@\/lib\/types\/fortune-system';\n/g,
    ''
  );
  
  fs.writeFileSync(fullPath, content, 'utf-8');
  console.log(`✅ 업데이트 완료: ${filePath}`);
  return true;
}

console.log('🚀 Fortune API 프로필 조회 업데이트 시작...\n');

let successCount = 0;
let failCount = 0;

fortuneApis.forEach(api => {
  if (updateFortuneApi(api)) {
    successCount++;
  } else {
    failCount++;
  }
});

console.log(`\n✅ 완료: ${successCount}개 파일 업데이트됨`);
if (failCount > 0) {
  console.log(`❌ 실패: ${failCount}개 파일`);
}