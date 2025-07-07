#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const glob = require('glob');

// Check API response format consistency
async function checkAPIResponses() {
  console.log('🔍 Checking API Response Format Consistency\n');
  
  const apiRoutes = glob.sync(path.join(__dirname, '../src/app/api/fortune/**/route.ts'))
    .filter(file => file.endsWith('route.ts'));
  
  const results = {
    total: 0,
    standardFormat: 0,
    nonStandardFormat: [],
    errorHandling: 0,
    missingErrorHandling: []
  };
  
  // Expected response patterns
  const responsePatterns = {
    // Standard success response
    success: /NextResponse\.json\s*\(\s*{\s*success:\s*true/,
    // Standard error response
    error: /NextResponse\.json\s*\(\s*{\s*(success:\s*false|error:)/,
    // Data field in response
    dataField: /data:\s*[^,}]+/,
    // Try-catch pattern
    tryCatch: /try\s*{[\s\S]*}\s*catch\s*\(/,
    // Error status codes
    errorStatus: /status:\s*(400|401|403|404|500)/
  };
  
  apiRoutes.forEach(file => {
    const content = fs.readFileSync(file, 'utf8');
    const relativePath = file.replace(path.dirname(__dirname), '');
    
    results.total++;
    
    // Check for standard response format
    const hasSuccessResponse = responsePatterns.success.test(content);
    const hasErrorResponse = responsePatterns.error.test(content);
    const hasDataField = responsePatterns.dataField.test(content);
    
    if (hasSuccessResponse && hasErrorResponse && hasDataField) {
      results.standardFormat++;
    } else {
      results.nonStandardFormat.push({
        file: relativePath,
        hasSuccess: hasSuccessResponse,
        hasError: hasErrorResponse,
        hasData: hasDataField
      });
    }
    
    // Check error handling
    if (responsePatterns.tryCatch.test(content)) {
      results.errorHandling++;
    } else {
      results.missingErrorHandling.push(relativePath);
    }
  });
  
  // Print results
  console.log('📊 Response Format Analysis:');
  console.log(`   Total endpoints: ${results.total}`);
  console.log(`   Standard format: ${results.standardFormat}`);
  console.log(`   Non-standard format: ${results.nonStandardFormat.length}`);
  console.log(`   With error handling: ${results.errorHandling}`);
  console.log(`   Missing error handling: ${results.missingErrorHandling.length}`);
  
  if (results.nonStandardFormat.length > 0) {
    console.log('\n⚠️  Non-standard response formats:');
    results.nonStandardFormat.slice(0, 10).forEach(({ file, hasSuccess, hasError, hasData }) => {
      console.log(`   ${file}`);
      console.log(`      Success: ${hasSuccess ? '✓' : '✗'}, Error: ${hasError ? '✓' : '✗'}, Data: ${hasData ? '✓' : '✗'}`);
    });
    if (results.nonStandardFormat.length > 10) {
      console.log(`   ... and ${results.nonStandardFormat.length - 10} more`);
    }
  }
  
  // Check for common issues
  console.log('\n🔎 Common Issues Check:');
  
  const issues = {
    mathRandom: 0,
    consoleLogs: 0,
    todoComments: 0,
    hardcodedData: 0
  };
  
  apiRoutes.forEach(file => {
    const content = fs.readFileSync(file, 'utf8');
    
    if (/Math\.random\(\)/.test(content)) issues.mathRandom++;
    if (/console\.(log|info|warn|error)/.test(content)) issues.consoleLogs++;
    if (/\/\/\s*TODO|\/\*\s*TODO/.test(content)) issues.todoComments++;
    if (/return\s+NextResponse\.json\(\s*{[^}]*"[^"]+"\s*:\s*"[^"]+"/m.test(content)) {
      // Check for hardcoded strings in responses (excluding error messages)
      if (!/error\s*:\s*["']/.test(content)) {
        issues.hardcodedData++;
      }
    }
  });
  
  console.log(`   Math.random usage: ${issues.mathRandom > 0 ? `❌ ${issues.mathRandom} files` : '✅ None'}`);
  console.log(`   Console logs: ${issues.consoleLogs > 0 ? `⚠️  ${issues.consoleLogs} files` : '✅ None'}`);
  console.log(`   TODO comments: ${issues.todoComments > 0 ? `📝 ${issues.todoComments} files` : '✅ None'}`);
  console.log(`   Hardcoded data: ${issues.hardcodedData > 0 ? `⚠️  ${issues.hardcodedData} files` : '✅ None'}`);
  
  // Response consistency score
  const consistencyScore = Math.round((results.standardFormat / results.total) * 100);
  console.log(`\n📈 Response Consistency Score: ${consistencyScore}%`);
  
  if (consistencyScore >= 90) {
    console.log('✅ Excellent response consistency!');
  } else if (consistencyScore >= 70) {
    console.log('⚠️  Good consistency, but some improvements needed');
  } else {
    console.log('❌ Poor consistency, standardization needed');
  }
}

// Run check
checkAPIResponses();