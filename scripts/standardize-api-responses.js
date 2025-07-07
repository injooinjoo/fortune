#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const glob = require('glob');

// API 파일 패턴
const API_PATTERN = 'src/app/api/fortune/**/route.ts';

// 표준화가 필요한 패턴들
const PATTERNS_TO_REPLACE = [
  // Pattern 1: { error: '...' } -> createErrorResponse
  {
    pattern: /return NextResponse\.json\(\s*{\s*error:\s*['"`]([^'"`]+)['"`]\s*},\s*{\s*status:\s*(\d+)\s*}\s*\)/g,
    replacement: "return createErrorResponse('$1', undefined, undefined, $2)"
  },
  // Pattern 2: { success: false, error: ... } -> createErrorResponse
  {
    pattern: /return NextResponse\.json\(\s*{\s*success:\s*false,\s*error:\s*([^}]+)\s*},\s*{\s*status:\s*(\d+)\s*}\s*\)/g,
    replacement: "return createErrorResponse($1, undefined, undefined, $2)"
  },
  // Pattern 3: Simple success response
  {
    pattern: /return NextResponse\.json\(\s*{\s*success:\s*true,\s*data:\s*([^}]+)\s*}\s*\)/g,
    replacement: "return createSuccessResponse($1)"
  }
];

function updateApiFile(filePath) {
  let content = fs.readFileSync(filePath, 'utf8');
  let modified = false;

  // Check if already using new utils
  if (content.includes('api-response-utils')) {
    console.log(`⏭️  Skipping (already updated): ${filePath}`);
    return;
  }

  // Add import if needed
  if (!content.includes('createSuccessResponse') && !content.includes('createErrorResponse')) {
    // Find the last import statement
    const importMatch = content.match(/^(import[\s\S]*?)\n\n/m);
    if (importMatch) {
      const imports = importMatch[1];
      const newImport = "import { createSuccessResponse, createErrorResponse, createFortuneResponse, handleApiError } from '@/lib/api-response-utils';";
      content = content.replace(imports, imports + '\n' + newImport);
      modified = true;
    }
  }

  // Apply replacements
  PATTERNS_TO_REPLACE.forEach(({ pattern, replacement }) => {
    if (pattern.test(content)) {
      content = content.replace(pattern, replacement);
      modified = true;
    }
  });

  // Special case for fortune responses
  const fortunePattern = /return NextResponse\.json\(\s*{\s*success:\s*true,\s*data:\s*{\s*type:\s*['"`]([^'"`]+)['"`],\s*([\s\S]*?)\s*}\s*}\s*\)/g;
  if (fortunePattern.test(content)) {
    content = content.replace(fortunePattern, (match, type, rest) => {
      return `return createFortuneResponse({ type: '${type}', ${rest} }, '${type}', req.userId)`;
    });
    modified = true;
  }

  if (modified) {
    fs.writeFileSync(filePath, content, 'utf8');
    console.log(`✅ Updated: ${filePath}`);
  } else {
    console.log(`⏭️  No changes needed: ${filePath}`);
  }
}

// Main execution
console.log('🔧 Standardizing API responses...\n');

const files = glob.sync(API_PATTERN);
console.log(`Found ${files.length} API files to process.\n`);

let updatedCount = 0;
files.forEach(file => {
  try {
    updateApiFile(file);
    updatedCount++;
  } catch (error) {
    console.error(`❌ Error updating ${file}:`, error.message);
  }
});

console.log(`\n✅ Standardization complete! Updated ${updatedCount} files.`);

// Create a sample migration guide
const migrationGuide = `
# API Response Standardization Guide

## Before:
\`\`\`typescript
return NextResponse.json({ error: 'Something went wrong' }, { status: 500 });
return NextResponse.json({ success: true, data: { ... } });
\`\`\`

## After:
\`\`\`typescript
import { createSuccessResponse, createErrorResponse } from '@/lib/api-response-utils';

return createErrorResponse('Something went wrong', 'ERROR_CODE', null, 500);
return createSuccessResponse({ ... });
\`\`\`

## Standard Response Format:

### Success:
\`\`\`json
{
  "success": true,
  "data": { ... },
  "message": "Optional success message",
  "metadata": {
    "timestamp": "2025-01-09T10:00:00Z",
    "fortune_type": "love",
    "user_id": "123"
  }
}
\`\`\`

### Error:
\`\`\`json
{
  "success": false,
  "error": {
    "message": "Error description",
    "code": "ERROR_CODE",
    "details": { ... }
  },
  "metadata": {
    "timestamp": "2025-01-09T10:00:00Z"
  }
}
\`\`\`
`;

fs.writeFileSync('API_STANDARDIZATION_GUIDE.md', migrationGuide);
console.log('\n📖 Created API_STANDARDIZATION_GUIDE.md for reference.');