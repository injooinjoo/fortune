#!/usr/bin/env node

/**
 * alert()를 toast로 교체하는 스크립트
 */

const fs = require('fs').promises;
const path = require('path');
const { promisify } = require('util');
const exec = promisify(require('child_process').exec);

// 색상 코드
const colors = {
  reset: '\x1b[0m',
  red: '\x1b[31m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  cyan: '\x1b[36m',
};

// 무시할 디렉토리
const ignoreDirs = [
  'node_modules',
  '.next',
  'dist',
  'build',
  '.git',
  'coverage',
  '.vercel',
  'public',
  'scripts',
];

// 무시할 파일
const ignoreFiles = [
  '*.test.ts',
  '*.test.tsx',
  '*.spec.ts',
  '*.spec.tsx',
];

async function findFiles() {
  const ignorePattern = ignoreDirs.map(dir => `-path "*/${dir}" -prune -o`).join(' ');
  const command = `find src ${ignorePattern} -type f \\( -name "*.js" -o -name "*.jsx" -o -name "*.ts" -o -name "*.tsx" \\) -print`;
  
  try {
    const { stdout } = await exec(command);
    const files = stdout.trim().split('\n').filter(f => f);
    
    return files.filter(file => {
      if (!file) return false;
      const basename = path.basename(file);
      
      // 무시할 파일 체크
      return !ignoreFiles.some(pattern => {
        if (pattern.startsWith('*')) {
          return basename.endsWith(pattern.slice(1));
        }
        return basename === pattern;
      });
    });
  } catch (error) {
    console.error('파일 검색 실패:', error);
    return [];
  }
}

function getToastType(alertMessage) {
  // 메시지 내용에 따라 적절한 toast 타입 결정
  const message = alertMessage.toLowerCase();
  
  if (message.includes('error') || message.includes('오류') || message.includes('실패')) {
    return 'error';
  } else if (message.includes('success') || message.includes('성공') || message.includes('완료')) {
    return 'success';
  } else if (message.includes('warning') || message.includes('경고') || message.includes('주의')) {
    return 'warning';
  }
  
  return 'default';
}

function createToastCall(alertContent, isClientComponent) {
  // alert 내용을 파싱하여 toast 호출로 변환
  const toastType = getToastType(alertContent);
  
  if (isClientComponent) {
    // 클라이언트 컴포넌트: useToast 훅 사용
    return `toast({
      title: ${alertContent},
      variant: "${toastType === 'error' ? 'destructive' : 'default'}",
    })`;
  } else {
    // 서버 컴포넌트나 일반 파일: toast 함수 직접 사용
    return `// TODO: Convert to toast notification
    // Original alert: ${alertContent}`;
  }
}

async function processFile(filePath) {
  let content = await fs.readFile(filePath, 'utf-8');
  const originalContent = content;
  let changeCount = 0;
  
  // 파일이 클라이언트 컴포넌트인지 확인
  const isClientComponent = content.includes('"use client"') || content.includes("'use client'");
  const isReactComponent = filePath.endsWith('.tsx') || filePath.endsWith('.jsx');
  
  // alert() 패턴 찾기 (복잡한 경우도 처리)
  const alertRegex = /alert\s*\(((?:[^()]+|\([^)]*\))*)\)/g;
  const matches = [...content.matchAll(alertRegex)];
  
  if (matches.length === 0) {
    return { file: filePath, changes: 0, modified: false };
  }
  
  // toast import 여부 확인
  const hasToastImport = content.includes('import { toast }') || content.includes('import { useToast }');
  
  // 각 매치를 역순으로 처리 (위치 변경 방지)
  for (let i = matches.length - 1; i >= 0; i--) {
    const match = matches[i];
    const fullMatch = match[0];
    const alertContent = match[1];
    
    if (isReactComponent && isClientComponent) {
      // React 클라이언트 컴포넌트
      const toastCall = createToastCall(alertContent, true);
      content = content.slice(0, match.index) + toastCall + content.slice(match.index + fullMatch.length);
      changeCount++;
    } else {
      // 서버 컴포넌트나 일반 JS 파일
      const comment = createToastCall(alertContent, false);
      content = content.slice(0, match.index) + comment + content.slice(match.index + fullMatch.length);
      changeCount++;
    }
  }
  
  // import 추가 (필요한 경우)
  if (changeCount > 0 && isReactComponent && isClientComponent && !hasToastImport) {
    // 컴포넌트 내에서 toast 사용 여부 확인
    const needsHook = content.includes('toast({');
    
    if (needsHook) {
      // 첫 번째 import 문 찾기
      const firstImportMatch = content.match(/^import\s+.+from\s+['"].+['"];?\s*$/m);
      
      if (firstImportMatch) {
        const firstImportIndex = content.indexOf(firstImportMatch[0]);
        const beforeImport = content.slice(0, firstImportIndex);
        const afterImport = content.slice(firstImportIndex);
        
        // useToast import 추가
        content = beforeImport + `import { useToast } from '@/hooks/use-toast';\n` + afterImport;
        
        // 컴포넌트 함수 내부에 const { toast } = useToast() 추가
        const componentMatch = content.match(/(?:function|const)\s+\w+\s*(?:\([^)]*\))?\s*(?::|=>)?\s*{/);
        if (componentMatch) {
          const insertPos = content.indexOf(componentMatch[0]) + componentMatch[0].length;
          const indentation = '  ';
          content = content.slice(0, insertPos) + 
                   `\n${indentation}const { toast } = useToast();` + 
                   content.slice(insertPos);
        }
      }
    }
  }
  
  // 파일 저장
  if (changeCount > 0) {
    await fs.writeFile(filePath, content, 'utf-8');
    
    return {
      file: filePath,
      changes: changeCount,
      modified: true,
      requiresManualReview: !isClientComponent || !isReactComponent
    };
  }
  
  return {
    file: filePath,
    changes: 0,
    modified: false
  };
}

async function main() {
  console.log(`${colors.cyan}🔄 alert() → toast 교체 시작...${colors.reset}\n`);

  try {
    const files = await findFiles();
    console.log(`${colors.blue}📂 검사할 파일: ${files.length}개${colors.reset}\n`);

    let totalChanges = 0;
    let modifiedFiles = 0;
    let manualReviewFiles = 0;
    const results = [];

    // 진행률 표시
    for (let i = 0; i < files.length; i++) {
      const file = files[i];
      const result = await processFile(file);
      results.push(result);

      if (result.modified) {
        totalChanges += result.changes;
        modifiedFiles++;
        if (result.requiresManualReview) {
          manualReviewFiles++;
        }
      }

      // 진행 상황 표시
      if ((i + 1) % 10 === 0 || i === files.length - 1) {
        process.stdout.write(`\r처리 중... ${i + 1}/${files.length} (수정된 파일: ${modifiedFiles}개)`);
      }
    }

    process.stdout.write(`\r${colors.green}✅ 교체 완료!${colors.reset}                        \n\n`);

    // 결과 요약
    console.log(`${colors.cyan}📊 교체 결과:${colors.reset}`);
    console.log('─'.repeat(50));
    console.log(`총 파일 수: ${files.length}개`);
    console.log(`수정된 파일: ${modifiedFiles}개`);
    console.log(`교체된 alert 호출: ${totalChanges}개`);
    console.log(`수동 검토 필요: ${manualReviewFiles}개`);
    console.log('─'.repeat(50));

    // 수정된 파일 목록
    if (modifiedFiles > 0) {
      console.log(`\n${colors.yellow}📝 수정된 파일:${colors.reset}`);
      results
        .filter(r => r.modified)
        .sort((a, b) => b.changes - a.changes)
        .slice(0, 20)
        .forEach(r => {
          const reviewFlag = r.requiresManualReview ? ' ⚠️' : '';
          console.log(`  ${colors.cyan}${r.file}${colors.reset}: ${r.changes}개 교체${reviewFlag}`);
        });
      
      if (modifiedFiles > 20) {
        console.log(`  ... 그 외 ${modifiedFiles - 20}개 파일`);
      }
    }

    // 수동 검토 필요한 파일
    if (manualReviewFiles > 0) {
      console.log(`\n${colors.yellow}⚠️  수동 검토 필요한 파일:${colors.reset}`);
      console.log('서버 컴포넌트나 일반 JS 파일에서는 자동 변환이 제한적입니다.');
      console.log('TODO 주석을 확인하고 적절한 방법으로 수정해주세요.\n');
    }

    // 다음 단계 안내
    console.log(`\n${colors.green}✨ 완료! 다음 단계:${colors.reset}`);
    console.log('1. 빌드 테스트: npm run build');
    console.log('2. 타입 체크: npm run type-check');
    console.log('3. 수동 검토가 필요한 파일들을 확인하세요');
    console.log('4. Toaster 컴포넌트가 루트 레이아웃에 추가되어 있는지 확인하세요');

  } catch (error) {
    console.error(`${colors.red}❌ 오류 발생:${colors.reset}`, error);
    process.exit(1);
  }
}

// 메인 실행
if (require.main === module) {
  main();
}

module.exports = { main };