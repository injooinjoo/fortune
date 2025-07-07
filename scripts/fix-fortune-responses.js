#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const glob = require('glob');

// Find all route.ts files in the fortune API directory
const apiFiles = glob.sync('src/app/api/fortune/**/route.ts');

console.log(`Found ${apiFiles.length} API route files to check...`);

let updatedFiles = 0;

apiFiles.forEach(filePath => {
  let content = fs.readFileSync(filePath, 'utf8');
  let originalContent = content;
  let hasChanges = false;

  // Pattern 1: Simple success response with data/analysis/fortune/result
  content = content.replace(
    /return NextResponse\.json\(\s*{\s*success:\s*true,\s*(data|analysis|fortune|result|answer|interpretation|results|predictions|response):\s*([^,}]+),\s*timestamp:\s*new Date\(\)\.toISOString\(\)\s*}\s*\);/g,
    (match, dataKey, dataValue) => {
      hasChanges = true;
      return `return NextResponse.json({
      success: true,
      ${dataKey}: ${dataValue},
      cached: false,
      generated_at: new Date().toISOString()
    });`;
    }
  );

  // Pattern 2: Simple success response without timestamp
  content = content.replace(
    /return NextResponse\.json\(\s*{\s*success:\s*true,\s*(data|analysis|fortune|result|answer|interpretation|results|predictions|response):\s*([^}]+)\s*}\s*\);/g,
    (match, dataKey, dataValue) => {
      // Check if it already has cached and generated_at
      if (dataValue.includes('cached') && dataValue.includes('generated_at')) {
        return match;
      }
      hasChanges = true;
      return `return NextResponse.json({
      success: true,
      ${dataKey}: ${dataValue},
      cached: false,
      generated_at: new Date().toISOString()
    });`;
    }
  );

  // Pattern 3: Response with ...result spread
  content = content.replace(
    /return NextResponse\.json\(\s*{\s*\.\.\.([^,}]+),\s*timestamp:\s*new Date\(\)\.toISOString\(\)\s*}\s*\);/g,
    (match, spreadVar) => {
      hasChanges = true;
      return `return NextResponse.json({
      ...${spreadVar},
      cached: false,
      generated_at: new Date().toISOString()
    });`;
    }
  );

  // Pattern 4: Direct object responses
  content = content.replace(
    /return NextResponse\.json\(([a-zA-Z_]\w*)\);/g,
    (match, varName) => {
      // Skip if it's already a structured response
      if (varName === 'response' || varName === 'result') {
        hasChanges = true;
        return `return NextResponse.json({
      success: true,
      data: ${varName},
      cached: false,
      generated_at: new Date().toISOString()
    });`;
      }
      return match;
    }
  );

  if (hasChanges) {
    fs.writeFileSync(filePath, content);
    updatedFiles++;
    console.log(`✅ Updated: ${filePath}`);
  }
});

console.log(`\nCompleted! Updated ${updatedFiles} files.`);