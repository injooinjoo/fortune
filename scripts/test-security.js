#!/usr/bin/env node

const BASE_URL = process.env.BASE_URL || 'http://localhost:3000';

// ANSI color codes
const colors = {
  green: '\x1b[32m',
  red: '\x1b[31m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  reset: '\x1b[0m'
};

async function testEndpoint(name, url, options = {}) {
  console.log(`\n${colors.blue}Testing: ${name}${colors.reset}`);
  console.log(`URL: ${url}`);
  
  try {
    const response = await fetch(url, options);
    const status = response.status;
    const statusColor = status >= 200 && status < 300 ? colors.green : colors.red;
    
    console.log(`Status: ${statusColor}${status}${colors.reset}`);
    
    if (response.headers.get('x-ratelimit-limit')) {
      console.log(`Rate Limit: ${response.headers.get('x-ratelimit-limit')}`);
      console.log(`Remaining: ${response.headers.get('x-ratelimit-remaining')}`);
    }
    
    const data = await response.json();
    console.log('Response:', JSON.stringify(data, null, 2));
    
    return { status, data };
  } catch (error) {
    console.error(`${colors.red}Error: ${error.message}${colors.reset}`);
    return { status: 0, error: error.message };
  }
}

async function runTests() {
  console.log(`${colors.yellow}=== Fortune App Security Tests ===${colors.reset}`);
  console.log(`Testing against: ${BASE_URL}`);
  
  // Test 1: Unauthenticated access to daily fortune (should allow guest access)
  await testEndpoint(
    '1. Daily Fortune - Guest Access',
    `${BASE_URL}/api/fortune/daily`
  );
  
  // Test 2: Rate limiting
  console.log(`\n${colors.yellow}--- Rate Limit Test ---${colors.reset}`);
  const promises = [];
  for (let i = 0; i < 12; i++) {
    promises.push(
      testEndpoint(
        `Rate Limit Request ${i + 1}`,
        `${BASE_URL}/api/fortune/daily`,
        { headers: { 'x-forwarded-for': 'test-client' } }
      )
    );
  }
  
  const results = await Promise.all(promises);
  const rateLimited = results.filter(r => r.status === 429).length;
  console.log(`\n${colors.yellow}Rate limited requests: ${rateLimited}/12${colors.reset}`);
  
  // Test 3: Batch generation without auth (should fail)
  await testEndpoint(
    '3. Batch Generation - No Auth',
    `${BASE_URL}/api/fortune/generate-batch`,
    {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        request_type: 'daily_refresh',
        user_profile: {
          id: 'test-user',
          name: 'Test User',
          birth_date: '1990-01-01'
        },
        generation_context: {
          cache_duration_hours: 24
        }
      })
    }
  );
  
  // Test 4: Batch generation with API key
  const apiKey = process.env.INTERNAL_API_KEY;
  if (apiKey) {
    await testEndpoint(
      '4. Batch Generation - With API Key',
      `${BASE_URL}/api/fortune/generate-batch`,
      {
        method: 'POST',
        headers: { 
          'Content-Type': 'application/json',
          'x-api-key': apiKey
        },
        body: JSON.stringify({
          request_type: 'daily_refresh',
          user_profile: {
            id: 'test-user',
            name: 'Test User',
            birth_date: '1990-01-01'
          },
          generation_context: {
            cache_duration_hours: 24
          }
        })
      }
    );
  } else {
    console.log(`\n${colors.yellow}Skipping API key test (INTERNAL_API_KEY not set)${colors.reset}`);
  }
  
  // Test 5: Cron endpoint without auth (should fail)
  await testEndpoint(
    '5. Cron Daily Batch - No Auth',
    `${BASE_URL}/api/cron/daily-batch`,
    { method: 'POST' }
  );
  
  console.log(`\n${colors.green}=== Tests Complete ===${colors.reset}`);
}

// Run tests
runTests().catch(console.error);