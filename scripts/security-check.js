#!/usr/bin/env node

const fs = require('fs').promises;
const path = require('path');

async function checkApiSecurity() {
  const apiDir = path.join(__dirname, '../src/app/api/fortune');
  const entries = await fs.readdir(apiDir, { withFileTypes: true });
  
  const results = {
    protected: [],
    unprotected: [],
    errors: []
  };
  
  for (const entry of entries) {
    if (entry.isDirectory()) {
      const routePath = path.join(apiDir, entry.name, 'route.ts');
      
      try {
        const content = await fs.readFile(routePath, 'utf8');
        
        // Check for authentication
        const hasAuth = content.includes('withAuth') || content.includes('withFortuneAuth');
        const hasRateLimit = content.includes('withRateLimit') || content.includes('withFortuneAuth');
        const hasErrorHandling = content.includes('createSafeErrorResponse') || content.includes('try') && content.includes('catch');
        
        if (hasAuth) {
          results.protected.push({
            name: entry.name,
            auth: hasAuth,
            rateLimit: hasRateLimit,
            errorHandling: hasErrorHandling
          });
        } else {
          results.unprotected.push({
            name: entry.name,
            issues: [
              !hasAuth && 'No authentication',
              !hasRateLimit && 'No rate limiting',
              !hasErrorHandling && 'No safe error handling'
            ].filter(Boolean)
          });
        }
      } catch (error) {
        // File doesn't exist or can't be read
      }
    }
  }
  
  console.log('🔒 Fortune API Security Check Report\n');
  console.log('=' .repeat(50));
  
  console.log(`\n✅ Protected APIs (${results.protected.length}):`);
  results.protected.forEach(api => {
    console.log(`  - ${api.name}`);
    console.log(`    Auth: ✓ | Rate Limit: ${api.rateLimit ? '✓' : '✗'} | Error Handling: ${api.errorHandling ? '✓' : '✗'}`);
  });
  
  if (results.unprotected.length > 0) {
    console.log(`\n❌ Unprotected APIs (${results.unprotected.length}):`);
    results.unprotected.forEach(api => {
      console.log(`  - ${api.name}`);
      console.log(`    Issues: ${api.issues.join(', ')}`);
    });
  } else {
    console.log('\n🎉 All APIs are protected!');
  }
  
  // Check for sensitive data exposure
  console.log('\n🔍 Additional Security Checks:');
  
  // Check environment variables
  const envFile = path.join(__dirname, '../.env.local');
  try {
    await fs.access(envFile);
    console.log('  ✓ .env.local exists');
  } catch {
    console.log('  ✗ .env.local not found');
  }
  
  // Check for API key exposure
  const srcDir = path.join(__dirname, '../src');
  const jsFiles = await findFiles(srcDir, /\.(ts|js|tsx|jsx)$/);
  let exposed = 0;
  
  for (const file of jsFiles) {
    const content = await fs.readFile(file, 'utf8');
    if (content.match(/['"]sk-[a-zA-Z0-9]{48}['"]/) || 
        content.match(/['"]AIza[a-zA-Z0-9]{35}['"]/) ||
        content.match(/OPENAI_API_KEY\s*=\s*['"][^'"]+['"]/)) {
      exposed++;
      console.log(`  ✗ Potential API key exposure in: ${path.relative(srcDir, file)}`);
    }
  }
  
  if (exposed === 0) {
    console.log('  ✓ No hardcoded API keys found');
  }
  
  console.log('\n📊 Summary:');
  console.log(`  Total APIs: ${results.protected.length + results.unprotected.length}`);
  console.log(`  Protected: ${results.protected.length} (${Math.round(results.protected.length / (results.protected.length + results.unprotected.length) * 100)}%)`);
  console.log(`  Unprotected: ${results.unprotected.length}`);
}

async function findFiles(dir, pattern) {
  const files = [];
  const entries = await fs.readdir(dir, { withFileTypes: true });
  
  for (const entry of entries) {
    const fullPath = path.join(dir, entry.name);
    if (entry.isDirectory() && !entry.name.startsWith('.') && entry.name !== 'node_modules') {
      files.push(...await findFiles(fullPath, pattern));
    } else if (entry.isFile() && pattern.test(entry.name)) {
      files.push(fullPath);
    }
  }
  
  return files;
}

checkApiSecurity().catch(console.error);