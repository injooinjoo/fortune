#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const glob = require('glob');

// Security audit results
const auditResults = {
  endpoints: {
    total: 0,
    protected: 0,
    unprotected: [],
    rateLimited: 0,
    missingRateLimit: []
  },
  authentication: {
    withAuth: 0,
    withFortuneAuth: 0,
    unprotected: []
  },
  security: {
    mathRandom: [],
    hardcodedSecrets: [],
    missingErrorHandling: []
  }
};

// Patterns to check
const patterns = {
  authentication: {
    withAuth: /withAuth\s*\(/,
    withFortuneAuth: /withFortuneAuth\s*\(/
  },
  rateLimit: /withRateLimit\s*\(/,
  mathRandom: /Math\.random\(\)/,
  hardcodedSecrets: /(api[_-]?key|secret|password|token)\s*[:=]\s*["'][^"']+["']/i,
  errorHandling: /catch\s*\(/
};

// Get all API route files
const apiRoutes = glob.sync(path.join(__dirname, '../src/app/api/**/*.ts'))
  .filter(file => file.endsWith('route.ts'));

console.log('🔒 Security Audit Report\n');
console.log(`Found ${apiRoutes.length} API endpoints to audit\n`);

// Analyze each file
apiRoutes.forEach(file => {
  const content = fs.readFileSync(file, 'utf8');
  const relativePath = file.replace(path.dirname(__dirname), '');
  
  auditResults.endpoints.total++;
  
  // Check authentication
  const hasAuth = patterns.authentication.withAuth.test(content) || 
                  patterns.authentication.withFortuneAuth.test(content);
  
  if (hasAuth) {
    auditResults.endpoints.protected++;
    if (patterns.authentication.withAuth.test(content)) {
      auditResults.authentication.withAuth++;
    }
    if (patterns.authentication.withFortuneAuth.test(content)) {
      auditResults.authentication.withFortuneAuth++;
    }
  } else {
    // Check if it's a public endpoint (webhook, cron, etc.)
    const isPublicEndpoint = relativePath.includes('/webhook/') || 
                            relativePath.includes('/cron/') ||
                            relativePath.includes('/health');
    
    if (!isPublicEndpoint) {
      auditResults.endpoints.unprotected.push(relativePath);
      auditResults.authentication.unprotected.push(relativePath);
    }
  }
  
  // Check rate limiting
  if (patterns.rateLimit.test(content)) {
    auditResults.endpoints.rateLimited++;
  } else if (!relativePath.includes('/webhook/') && !relativePath.includes('/cron/')) {
    auditResults.endpoints.missingRateLimit.push(relativePath);
  }
  
  // Check for Math.random
  if (patterns.mathRandom.test(content)) {
    auditResults.security.mathRandom.push(relativePath);
  }
  
  // Check for hardcoded secrets
  const secretMatches = content.match(patterns.hardcodedSecrets);
  if (secretMatches && !relativePath.includes('.example')) {
    // Filter out environment variable references
    const realSecrets = secretMatches.filter(match => 
      !match.includes('process.env') && 
      !match.includes('NEXT_PUBLIC_')
    );
    if (realSecrets.length > 0) {
      auditResults.security.hardcodedSecrets.push({
        file: relativePath,
        matches: realSecrets
      });
    }
  }
  
  // Check error handling
  const hasExportedFunctions = content.match(/export\s+(async\s+)?function\s+(GET|POST|PUT|DELETE|PATCH)/g);
  if (hasExportedFunctions && !patterns.errorHandling.test(content)) {
    auditResults.security.missingErrorHandling.push(relativePath);
  }
});

// Print results
console.log('📊 Authentication Coverage:');
console.log(`   ✅ Protected endpoints: ${auditResults.endpoints.protected}/${auditResults.endpoints.total}`);
console.log(`   📦 Using withAuth: ${auditResults.authentication.withAuth}`);
console.log(`   🔐 Using withFortuneAuth: ${auditResults.authentication.withFortuneAuth}`);

if (auditResults.endpoints.unprotected.length > 0) {
  console.log(`\n   ⚠️  Unprotected endpoints (${auditResults.endpoints.unprotected.length}):`);
  auditResults.endpoints.unprotected.forEach(endpoint => {
    console.log(`      - ${endpoint}`);
  });
}

console.log('\n🚦 Rate Limiting:');
console.log(`   ✅ Rate limited endpoints: ${auditResults.endpoints.rateLimited}`);
if (auditResults.endpoints.missingRateLimit.length > 0) {
  console.log(`   ⚠️  Missing rate limiting (${auditResults.endpoints.missingRateLimit.length}):`);
  auditResults.endpoints.missingRateLimit.slice(0, 5).forEach(endpoint => {
    console.log(`      - ${endpoint}`);
  });
  if (auditResults.endpoints.missingRateLimit.length > 5) {
    console.log(`      ... and ${auditResults.endpoints.missingRateLimit.length - 5} more`);
  }
}

console.log('\n🔍 Security Issues:');
if (auditResults.security.mathRandom.length > 0) {
  console.log(`   ⚠️  Math.random() usage found (${auditResults.security.mathRandom.length} files):`);
  auditResults.security.mathRandom.forEach(file => {
    console.log(`      - ${file}`);
  });
} else {
  console.log('   ✅ No Math.random() usage found');
}

if (auditResults.security.hardcodedSecrets.length > 0) {
  console.log(`\n   🚨 Potential hardcoded secrets (${auditResults.security.hardcodedSecrets.length} files):`);
  auditResults.security.hardcodedSecrets.forEach(({file, matches}) => {
    console.log(`      - ${file}`);
    matches.forEach(match => console.log(`        "${match}"`));
  });
} else {
  console.log('   ✅ No hardcoded secrets found');
}

if (auditResults.security.missingErrorHandling.length > 0) {
  console.log(`\n   ⚠️  Missing error handling (${auditResults.security.missingErrorHandling.length} files)`);
}

// Summary
console.log('\n📋 Summary:');
const protectionRate = Math.round((auditResults.endpoints.protected / auditResults.endpoints.total) * 100);
const securityScore = protectionRate - 
  (auditResults.security.mathRandom.length * 5) - 
  (auditResults.security.hardcodedSecrets.length * 10) -
  (auditResults.endpoints.unprotected.length * 2);

console.log(`   Security Score: ${Math.max(0, securityScore)}/100`);
console.log(`   Protection Rate: ${protectionRate}%`);

if (securityScore < 80) {
  console.log('\n⚠️  Security improvements needed!');
} else {
  console.log('\n✅ Good security posture!');
}