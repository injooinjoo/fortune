#!/usr/bin/env node

const fetch = require('node-fetch');

// Test rate limiting on fortune endpoints
async function testRateLimit() {
  const baseUrl = 'http://localhost:9002';
  const endpoint = '/api/fortune/love';
  
  console.log('🧪 Testing Rate Limiting\n');
  console.log(`Endpoint: ${endpoint}`);
  console.log('Making 15 requests in quick succession...\n');
  
  const results = {
    success: 0,
    rateLimited: 0,
    unauthorized: 0,
    errors: 0
  };
  
  // Make 15 requests quickly
  const promises = [];
  for (let i = 0; i < 15; i++) {
    promises.push(
      fetch(`${baseUrl}${endpoint}`, {
        method: 'GET',
        headers: {
          'Content-Type': 'application/json',
          // Simulate requests from same IP
          'X-Forwarded-For': '192.168.1.100'
        }
      }).then(async res => {
        const headers = {
          status: res.status,
          rateLimitLimit: res.headers.get('x-ratelimit-limit'),
          rateLimitRemaining: res.headers.get('x-ratelimit-remaining'),
          rateLimitReset: res.headers.get('x-ratelimit-reset'),
          retryAfter: res.headers.get('retry-after')
        };
        
        const body = await res.json().catch(() => null);
        
        return { i, headers, body };
      }).catch(error => {
        return { i, error: error.message };
      })
    );
  }
  
  const responses = await Promise.all(promises);
  
  // Analyze results
  responses.forEach(({ i, headers, body, error }) => {
    if (error) {
      console.log(`Request ${i + 1}: ❌ Error - ${error}`);
      results.errors++;
    } else if (headers.status === 429) {
      console.log(`Request ${i + 1}: 🚦 Rate Limited`);
      console.log(`   Retry After: ${headers.retryAfter}s`);
      console.log(`   Limit: ${headers.rateLimitLimit}, Remaining: ${headers.rateLimitRemaining}`);
      results.rateLimited++;
    } else if (headers.status === 401) {
      console.log(`Request ${i + 1}: 🔒 Unauthorized (authentication required)`);
      results.unauthorized++;
    } else if (headers.status === 200) {
      console.log(`Request ${i + 1}: ✅ Success`);
      if (headers.rateLimitLimit) {
        console.log(`   Limit: ${headers.rateLimitLimit}, Remaining: ${headers.rateLimitRemaining}`);
      }
      results.success++;
    } else {
      console.log(`Request ${i + 1}: ⚠️  Status ${headers.status}`);
      results.errors++;
    }
  });
  
  // Summary
  console.log('\n📊 Summary:');
  console.log(`   Successful: ${results.success}`);
  console.log(`   Rate Limited: ${results.rateLimited}`);
  console.log(`   Unauthorized: ${results.unauthorized}`);
  console.log(`   Errors: ${results.errors}`);
  
  if (results.rateLimited > 0) {
    console.log('\n✅ Rate limiting is working!');
  } else if (results.unauthorized === 15) {
    console.log('\n⚠️  All requests require authentication (rate limiting may not be tested without auth)');
  } else {
    console.log('\n❌ Rate limiting may not be configured properly');
  }
}

// Test with authentication
async function testRateLimitWithAuth() {
  console.log('\n\n🔐 Testing Rate Limiting with Authentication\n');
  
  // Note: You would need to provide a valid auth token here
  const authToken = process.env.TEST_AUTH_TOKEN;
  
  if (!authToken) {
    console.log('⚠️  No TEST_AUTH_TOKEN found in environment');
    console.log('   Set TEST_AUTH_TOKEN to test authenticated rate limiting');
    return;
  }
  
  const baseUrl = 'http://localhost:9002';
  const endpoint = '/api/fortune/love';
  
  const results = {
    success: 0,
    rateLimited: 0,
    errors: 0
  };
  
  // Make 15 authenticated requests
  for (let i = 0; i < 15; i++) {
    try {
      const res = await fetch(`${baseUrl}${endpoint}`, {
        method: 'GET',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${authToken}`
        }
      });
      
      if (res.status === 429) {
        results.rateLimited++;
        console.log(`Request ${i + 1}: 🚦 Rate Limited (Retry after: ${res.headers.get('retry-after')}s)`);
      } else if (res.status === 200) {
        results.success++;
        console.log(`Request ${i + 1}: ✅ Success (Remaining: ${res.headers.get('x-ratelimit-remaining')})`);
      } else {
        results.errors++;
        console.log(`Request ${i + 1}: ⚠️  Status ${res.status}`);
      }
    } catch (error) {
      results.errors++;
      console.log(`Request ${i + 1}: ❌ Error - ${error.message}`);
    }
  }
  
  console.log('\n📊 Authenticated Summary:');
  console.log(`   Successful: ${results.success}`);
  console.log(`   Rate Limited: ${results.rateLimited}`);
  console.log(`   Errors: ${results.errors}`);
}

// Run tests
(async () => {
  await testRateLimit();
  await testRateLimitWithAuth();
})();