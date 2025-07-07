#!/usr/bin/env node

/**
 * 코드베이스 정리 스크립트
 * TODO 주석, console.log, 빌드 에러 등을 찾아서 정리
 */

const fs = require('fs').promises;
const path = require('path');
const { exec } = require('child_process');
const { promisify } = require('util');

const execAsync = promisify(exec);

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

// 검색 패턴
const patterns = {
  todo: /\/\/\s*TODO[:\s](.+)|\/\*\s*TODO[:\s](.+?)\*\//gi,
  console: /console\.(log|error|warn|info|debug)\(/g,
  debugger: /\bdebugger\b/g,
  alert: /\balert\s*\(/g,
  fixme: /\/\/\s*FIXME[:\s](.+)|\/\*\s*FIXME[:\s](.+?)\*\//gi,
  hack: /\/\/\s*HACK[:\s](.+)|\/\*\s*HACK[:\s](.+?)\*\//gi,
  deprecated: /\/\/\s*@deprecated|\/\*\s*@deprecated/gi,
  onlyDev: /\/\/\s*ONLY[_\s]?DEV|\/\*\s*ONLY[_\s]?DEV/gi,
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
  'scripts', // 이 스크립트 자체도 제외
];

// 무시할 파일 패턴
const ignoreFiles = [
  '*.min.js',
  '*.map',
  '*.lock',
  '*.log',
  '*.md',
  '*.json',
  '*.css',
  '*.scss',
  'package-lock.json',
  'yarn.lock',
];

async function findFiles() {
  // find 명령어를 사용하여 파일 찾기
  const ignorePattern = ignoreDirs.map(dir => `-path "*/${dir}" -prune -o`).join(' ');
  const command = `find src ${ignorePattern} -type f \\( -name "*.js" -o -name "*.jsx" -o -name "*.ts" -o -name "*.tsx" \\) -print`;
  
  try {
    const { stdout } = await execAsync(command);
    const files = stdout.trim().split('\n').filter(f => f);
    
    return files.filter(file => {
      if (!file) return false;
      const basename = path.basename(file);
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

async function scanFile(filePath) {
  const content = await fs.readFile(filePath, 'utf-8');
  const lines = content.split('\n');
  const issues = [];

  lines.forEach((line, index) => {
    const lineNumber = index + 1;

    // TODO 검색
    if (patterns.todo.test(line)) {
      const match = line.match(patterns.todo);
      issues.push({
        type: 'TODO',
        file: filePath,
        line: lineNumber,
        content: line.trim(),
        severity: 'info',
      });
    }

    // console.* 검색
    if (patterns.console.test(line)) {
      // 개발 관련 파일은 제외
      if (!filePath.includes('test') && !filePath.includes('debug')) {
        issues.push({
          type: 'console',
          file: filePath,
          line: lineNumber,
          content: line.trim(),
          severity: 'warning',
        });
      }
    }

    // debugger 검색
    if (patterns.debugger.test(line)) {
      issues.push({
        type: 'debugger',
        file: filePath,
        line: lineNumber,
        content: line.trim(),
        severity: 'error',
      });
    }

    // alert 검색
    if (patterns.alert.test(line)) {
      issues.push({
        type: 'alert',
        file: filePath,
        line: lineNumber,
        content: line.trim(),
        severity: 'error',
      });
    }

    // FIXME 검색
    if (patterns.fixme.test(line)) {
      issues.push({
        type: 'FIXME',
        file: filePath,
        line: lineNumber,
        content: line.trim(),
        severity: 'warning',
      });
    }
  });

  return issues;
}

async function main() {
  console.log(`${colors.cyan}🔍 코드베이스 정리 스캔 시작...${colors.reset}\n`);

  try {
    const files = await findFiles();
    console.log(`${colors.blue}📂 검사할 파일: ${files.length}개${colors.reset}\n`);

    const allIssues = [];
    let processedCount = 0;

    for (const file of files) {
      const issues = await scanFile(file);
      allIssues.push(...issues);
      processedCount++;

      // 진행 상황 표시
      if (processedCount % 10 === 0) {
        process.stdout.write(`\r처리 중... ${processedCount}/${files.length}`);
      }
    }

    process.stdout.write(`\r${colors.green}✅ 스캔 완료!${colors.reset}        \n\n`);

    // 결과 분석
    const issuesByType = {};
    allIssues.forEach(issue => {
      if (!issuesByType[issue.type]) {
        issuesByType[issue.type] = [];
      }
      issuesByType[issue.type].push(issue);
    });

    // 요약 출력
    console.log(`${colors.cyan}📊 발견된 이슈 요약:${colors.reset}`);
    console.log('─'.repeat(50));

    Object.entries(issuesByType).forEach(([type, issues]) => {
      const color = issues[0].severity === 'error' ? colors.red :
                   issues[0].severity === 'warning' ? colors.yellow :
                   colors.blue;
      console.log(`${color}${type}: ${issues.length}개${colors.reset}`);
    });

    console.log('─'.repeat(50));
    console.log(`총 이슈: ${allIssues.length}개\n`);

    // 상세 내용 출력
    if (allIssues.length > 0) {
      console.log(`${colors.cyan}📋 상세 내용:${colors.reset}\n`);

      // 타입별로 그룹화하여 출력
      Object.entries(issuesByType).forEach(([type, issues]) => {
        console.log(`${colors.magenta}### ${type} (${issues.length}개)${colors.reset}`);
        
        // 파일별로 그룹화
        const byFile = {};
        issues.forEach(issue => {
          if (!byFile[issue.file]) {
            byFile[issue.file] = [];
          }
          byFile[issue.file].push(issue);
        });

        Object.entries(byFile).forEach(([file, fileIssues]) => {
          console.log(`\n${colors.cyan}${file}:${colors.reset}`);
          fileIssues.forEach(issue => {
            const color = issue.severity === 'error' ? colors.red :
                         issue.severity === 'warning' ? colors.yellow :
                         colors.blue;
            console.log(`  ${color}Line ${issue.line}: ${issue.content}${colors.reset}`);
          });
        });

        console.log('');
      });

      // 자동 수정 가능한 항목 안내
      const consoleLogs = issuesByType['console'] || [];
      const debuggers = issuesByType['debugger'] || [];
      const alerts = issuesByType['alert'] || [];
      
      const autoFixable = consoleLogs.length + debuggers.length + alerts.length;
      
      if (autoFixable > 0) {
        console.log(`${colors.yellow}💡 자동 수정 가능한 이슈: ${autoFixable}개${colors.reset}`);
        console.log(`   - console.*: ${consoleLogs.length}개`);
        console.log(`   - debugger: ${debuggers.length}개`);
        console.log(`   - alert: ${alerts.length}개`);
        console.log(`\n${colors.green}실행: npm run code:cleanup --fix${colors.reset}`);
      }

      // 수동 검토 필요 항목
      const todos = issuesByType['TODO'] || [];
      const fixmes = issuesByType['FIXME'] || [];
      
      if (todos.length + fixmes.length > 0) {
        console.log(`\n${colors.yellow}⚠️  수동 검토 필요: ${todos.length + fixmes.length}개${colors.reset}`);
        console.log(`   - TODO: ${todos.length}개`);
        console.log(`   - FIXME: ${fixmes.length}개`);
      }
    } else {
      console.log(`${colors.green}🎉 코드가 깨끗합니다! 발견된 이슈가 없습니다.${colors.reset}`);
    }

    // 통계 파일 저장
    const report = {
      scanDate: new Date().toISOString(),
      totalFiles: files.length,
      totalIssues: allIssues.length,
      issuesByType: Object.fromEntries(
        Object.entries(issuesByType).map(([type, issues]) => [
          type,
          {
            count: issues.length,
            files: [...new Set(issues.map(i => i.file))].length,
          }
        ])
      ),
      details: allIssues,
    };

    await fs.writeFile(
      'code-cleanup-report.json',
      JSON.stringify(report, null, 2)
    );

    console.log(`\n${colors.blue}📄 상세 리포트가 code-cleanup-report.json에 저장되었습니다.${colors.reset}`);

  } catch (error) {
    console.error(`${colors.red}❌ 오류 발생:${colors.reset}`, error);
    process.exit(1);
  }
}

// 자동 수정 모드
async function autoFix() {
  console.log(`${colors.cyan}🔧 자동 수정 모드 시작...${colors.reset}\n`);
  
  // TODO: 자동 수정 로직 구현
  console.log(`${colors.yellow}자동 수정 기능은 아직 구현 중입니다.${colors.reset}`);
}

// 메인 실행
if (require.main === module) {
  const args = process.argv.slice(2);
  if (args.includes('--fix')) {
    autoFix();
  } else {
    main();
  }
}

module.exports = { main, autoFix };