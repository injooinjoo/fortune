#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const glob = require('glob');

// Files to check
const apiRoutePattern = path.join(__dirname, '../src/app/api/fortune/**/route.ts');

// Functions and their required imports
const functionsToCheck = {
  'withFortuneAuth': '@/lib/security-api-utils',
  'createSafeErrorResponse': '@/lib/security-api-utils',
  'AuthenticatedRequest': '@/middleware/auth',
  'FortuneService': '@/lib/services/fortune-service'
};

// Get all API route files
const files = glob.sync(apiRoutePattern);

console.log(`Checking ${files.length} API route files...\n`);

const filesWithMissingImports = [];

files.forEach(file => {
  const content = fs.readFileSync(file, 'utf8');
  const missingImports = [];
  
  // Check each function
  Object.entries(functionsToCheck).forEach(([funcName, importPath]) => {
    // Check if function is used in the file
    const funcRegex = new RegExp(`\\b${funcName}\\b`, 'g');
    if (funcRegex.test(content)) {
      // Check if it's imported
      const importRegex = new RegExp(`import.*{[^}]*${funcName}[^}]*}.*from\\s+['"]${importPath.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')}['"]`);
      if (!importRegex.test(content)) {
        missingImports.push({ function: funcName, requiredImport: importPath });
      }
    }
  });
  
  if (missingImports.length > 0) {
    filesWithMissingImports.push({
      file: file.replace(path.dirname(__dirname), ''),
      missingImports
    });
  }
});

// Report results
if (filesWithMissingImports.length === 0) {
  console.log('✅ All files have proper imports!');
} else {
  console.log(`Found ${filesWithMissingImports.length} files with missing imports:\n`);
  
  filesWithMissingImports.forEach(({ file, missingImports }) => {
    console.log(`📁 ${file}`);
    missingImports.forEach(({ function: func, requiredImport }) => {
      console.log(`   ❌ Missing import for '${func}' from '${requiredImport}'`);
    });
    console.log('');
  });
}