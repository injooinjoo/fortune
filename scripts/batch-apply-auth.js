#!/usr/bin/env node

const fs = require('fs').promises;
const path = require('path');

async function applyAuthToFile(filePath) {
  try {
    let content = await fs.readFile(filePath, 'utf8');
    
    // 이미 withAuth가 있으면 스킵
    if (content.includes('withFortuneAuth') || content.includes('withAuth')) {
      return { success: true, skipped: true };
    }
    
    // import 추가
    if (!content.includes("import { withFortuneAuth")) {
      const importIndex = content.indexOf("import { FortuneService");
      if (importIndex !== -1) {
        const endOfImport = content.indexOf('\n', importIndex);
        content = content.slice(0, endOfImport + 1) + 
          "import { withFortuneAuth, createSafeErrorResponse } from '@/lib/security-api-utils';\n" +
          "import { AuthenticatedRequest } from '@/middleware/auth';\n" +
          content.slice(endOfImport + 1);
      }
    }
    
    // GET 함수 변경
    content = content.replace(
      /export\s+async\s+function\s+GET\s*\([^)]*\)\s*{/g,
      'export const GET = withFortuneAuth(async (request: AuthenticatedRequest, fortuneService: FortuneService) => {'
    );
    
    // POST 함수 변경
    content = content.replace(
      /export\s+async\s+function\s+POST\s*\([^)]*\)\s*{/g,
      'export const POST = withFortuneAuth(async (request: AuthenticatedRequest, fortuneService: FortuneService) => {'
    );
    
    // FortuneService 인스턴스 생성 제거 (이미 주입됨)
    content = content.replace(/const fortuneService = .*?;\n/g, '');
    
    // request를 AuthenticatedRequest로 사용
    content = content.replace(/searchParams\.get\('userId'\)[^;]*;/g, 'request.userId!;');
    content = content.replace(/`guest_\${[^}]*}`/g, 'request.userId!');
    
    // 에러 처리 개선
    content = content.replace(
      /return NextResponse\.json\(\s*{\s*(?:success:\s*false,?\s*)?error:[^}]+}\s*,\s*{\s*status:\s*500\s*}\s*\);/g,
      (match) => {
        const errorMatch = match.match(/error:\s*['"`]([^'"`]+)['"`]/);
        const errorMsg = errorMatch ? errorMatch[1] : '운세를 가져오는 중 오류가 발생했습니다.';
        return `return createSafeErrorResponse(error, '${errorMsg}');`;
      }
    );
    
    // 함수 끝에 괄호 추가
    content = content.replace(/}\s*$/, '});\n');
    
    await fs.writeFile(filePath, content);
    return { success: true, skipped: false };
    
  } catch (error) {
    return { success: false, error: error.message };
  }
}

async function main() {
  const apiDir = path.join(__dirname, '../src/app/api/fortune');
  const entries = await fs.readdir(apiDir, { withFileTypes: true });
  
  const results = {
    success: 0,
    skipped: 0,
    failed: 0,
    errors: []
  };
  
  for (const entry of entries) {
    if (entry.isDirectory()) {
      const routePath = path.join(apiDir, entry.name, 'route.ts');
      
      try {
        await fs.access(routePath);
        console.log(`Processing ${entry.name}...`);
        
        const result = await applyAuthToFile(routePath);
        
        if (result.success) {
          if (result.skipped) {
            console.log(`  ⏭️  Skipped (already protected)`);
            results.skipped++;
          } else {
            console.log(`  ✅ Applied auth`);
            results.success++;
          }
        } else {
          console.log(`  ❌ Failed: ${result.error}`);
          results.failed++;
          results.errors.push({ file: entry.name, error: result.error });
        }
      } catch {
        // 파일이 없으면 스킵
      }
    }
  }
  
  console.log('\n📊 Summary:');
  console.log(`✅ Successfully updated: ${results.success}`);
  console.log(`⏭️  Already protected: ${results.skipped}`);
  console.log(`❌ Failed: ${results.failed}`);
  
  if (results.errors.length > 0) {
    console.log('\n❌ Errors:');
    results.errors.forEach(({ file, error }) => {
      console.log(`  - ${file}: ${error}`);
    });
  }
}

main().catch(console.error);