#!/usr/bin/env node

/**
 * console.log를 logger로 교체하는 스크립트
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
  'logger.ts',
  'logger.js',
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

async function processFile(filePath) {
  let content = await fs.readFile(filePath, 'utf-8');
  const originalContent = content;
  let changeCount = 0;

  // Import 문 확인
  const hasLoggerImport = content.includes('import { logger }') || content.includes('from \'@/lib/logger\'');
  
  // console.log 패턴 교체
  const patterns = [
    // console.log
    {
      regex: /console\.log\s*\(/g,
      replacement: 'logger.debug(',
      type: 'debug'
    },
    // console.error
    {
      regex: /console\.error\s*\(/g,
      replacement: 'logger.error(',
      type: 'error'
    },
    // console.warn
    {
      regex: /console\.warn\s*\(/g,
      replacement: 'logger.warn(',
      type: 'warn'
    },
    // console.info
    {
      regex: /console\.info\s*\(/g,
      replacement: 'logger.info(',
      type: 'info'
    }
  ];

  // 각 패턴에 대해 교체 수행
  patterns.forEach(({ regex, replacement }) => {
    const matches = content.match(regex);
    if (matches) {
      changeCount += matches.length;
      content = content.replace(regex, replacement);
    }
  });

  // 변경사항이 있으면
  if (changeCount > 0) {
    // logger import 추가 (필요한 경우)
    if (!hasLoggerImport) {
      // TypeScript/TSX 파일인 경우
      if (filePath.endsWith('.ts') || filePath.endsWith('.tsx')) {
        // 첫 번째 import 문 찾기
        const firstImportMatch = content.match(/^import\s+.+from\s+['"].+['"];?\s*$/m);
        if (firstImportMatch) {
          const firstImportIndex = content.indexOf(firstImportMatch[0]);
          const beforeImport = content.slice(0, firstImportIndex);
          const afterImport = content.slice(firstImportIndex);
          content = beforeImport + `import { logger } from '@/lib/logger';\n` + afterImport;
        } else {
          // import 문이 없으면 파일 시작 부분에 추가
          content = `import { logger } from '@/lib/logger';\n\n` + content;
        }
      }
    }

    // 파일 저장
    await fs.writeFile(filePath, content, 'utf-8');
    
    return {
      file: filePath,
      changes: changeCount,
      modified: true
    };
  }

  return {
    file: filePath,
    changes: 0,
    modified: false
  };
}

async function main() {
  console.log(`${colors.cyan}🔄 console.log → logger 교체 시작...${colors.reset}\n`);

  try {
    const files = await findFiles();
    console.log(`${colors.blue}📂 검사할 파일: ${files.length}개${colors.reset}\n`);

    let totalChanges = 0;
    let modifiedFiles = 0;
    const results = [];

    // 진행률 표시
    for (let i = 0; i < files.length; i++) {
      const file = files[i];
      const result = await processFile(file);
      results.push(result);

      if (result.modified) {
        totalChanges += result.changes;
        modifiedFiles++;
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
    console.log(`교체된 console 호출: ${totalChanges}개`);
    console.log('─'.repeat(50));

    // 수정된 파일 목록
    if (modifiedFiles > 0) {
      console.log(`\n${colors.yellow}📝 수정된 파일:${colors.reset}`);
      results
        .filter(r => r.modified)
        .sort((a, b) => b.changes - a.changes)
        .slice(0, 20)
        .forEach(r => {
          console.log(`  ${colors.cyan}${r.file}${colors.reset}: ${r.changes}개 교체`);
        });
      
      if (modifiedFiles > 20) {
        console.log(`  ... 그 외 ${modifiedFiles - 20}개 파일`);
      }
    }

    // 다음 단계 안내
    console.log(`\n${colors.green}✨ 완료! 다음 단계:${colors.reset}`);
    console.log('1. 빌드 테스트: npm run build');
    console.log('2. 타입 체크: npm run type-check');
    console.log('3. 로그 레벨 조정은 logger.setLevel()로 가능합니다');

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