#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const glob = require('glob');

// Find all route files with syntax errors
const API_PATTERN = 'src/app/api/fortune/**/route.ts';

function fixSyntaxErrors(filePath) {
  let content = fs.readFileSync(filePath, 'utf8');
  let modified = false;

  // Fix pattern 1: createSuccessResponse with object syntax
  // createSuccessResponse(result, cached: false, generated_at: ...) 
  // should be createSuccessResponse(result, undefined, { cached: false, generated_at: ... })
  const successPattern = /createSuccessResponse\(([^,]+),\s*\n?\s*([^)]+):\s*([^,\n]+),\s*\n?\s*([^)]+):\s*([^)]+)\)/g;
  if (successPattern.test(content)) {
    content = content.replace(successPattern, (match, data, key1, value1, key2, value2) => {
      return `createSuccessResponse(${data}, undefined, { ${key1}: ${value1}, ${key2}: ${value2} })`;
    });
    modified = true;
  }

  // Fix pattern 2: createErrorResponse with object syntax
  // createErrorResponse('PROFILE_REQUIRED', message: '...', redirect: '...')
  // should be createErrorResponse('...', 'PROFILE_REQUIRED', { redirect: '...' }, 400)
  const errorPattern = /createErrorResponse\('([^']+)',\s*\n?\s*message:\s*'([^']+)',\s*\n?\s*redirect:\s*'([^']+)'\s*,\s*undefined,\s*undefined,\s*(\d+)\)/g;
  if (errorPattern.test(content)) {
    content = content.replace(errorPattern, (match, code, message, redirect, status) => {
      return `createErrorResponse('${message}', '${code}', { redirect: '${redirect}' }, ${status})`;
    });
    modified = true;
  }

  // Fix pattern 3: createErrorResponse with data: null
  // createErrorResponse(error.message, data: null, undefined, undefined, 500)
  // should be createErrorResponse(error.message, undefined, null, 500)
  const errorDataPattern = /createErrorResponse\(([^,]+),\s*\n?\s*data:\s*null\s*,\s*undefined,\s*undefined,\s*(\d+)\)/g;
  if (errorDataPattern.test(content)) {
    content = content.replace(errorDataPattern, (match, message, status) => {
      return `createErrorResponse(${message}, undefined, null, ${status})`;
    });
    modified = true;
  }

  if (modified) {
    fs.writeFileSync(filePath, content, 'utf8');
    console.log(`✅ Fixed: ${filePath}`);
    return true;
  }
  return false;
}

// Main execution
console.log('🔧 Fixing API syntax errors...\n');

const files = glob.sync(API_PATTERN);
let fixedCount = 0;

files.forEach(file => {
  try {
    if (fixSyntaxErrors(file)) {
      fixedCount++;
    }
  } catch (error) {
    console.error(`❌ Error fixing ${file}:`, error.message);
  }
});

console.log(`\n✅ Fixed ${fixedCount} files with syntax errors.`);