#!/usr/bin/env node

const fetch = require('node-fetch');

// Test API authentication on fortune endpoints
async function testAPIAuth() {
  const baseUrl = 'http://localhost:9002';
  const endpoints = [
    '/api/fortune/love',
    '/api/fortune/wealth',
    '/api/fortune/business',
    '/api/fortune/celebrity',
    '/api/fortune/compatibility',
    '/api/fortune/daily',
    '/api/fortune/saju-psychology',
    '/api/fortune/palmistry',
    '/api/fortune/face-reading',
    '/api/fortune/startup'
  ];
  
  console.log('🔐 Testing API Authentication\n');
  console.log('Testing endpoints without authentication...\n');
  
  const results = {
    protected: 0,
    unprotected: 0,
    errors: 0,
    endpoints: []
  };
  
  // Test each endpoint without auth
  for (const endpoint of endpoints) {
    try {
      const res = await fetch(`${baseUrl}${endpoint}`, {
        method: 'GET',
        headers: {
          'Content-Type': 'application/json'
        }
      });
      
      const body = await res.json().catch(() => null);
      
      if (res.status === 401) {
        results.protected++;
        console.log(`✅ ${endpoint} - Protected (401 Unauthorized)`);
        if (body?.requireAuth) {
          console.log(`   Message: ${body.error}`);
        }
      } else if (res.status === 200) {
        results.unprotected++;
        console.log(`❌ ${endpoint} - Unprotected (200 OK)`);
      } else {
        results.errors++;
        console.log(`⚠️  ${endpoint} - Status ${res.status}`);
        if (body?.error) {
          console.log(`   Error: ${body.error}`);
        }
      }
      
      results.endpoints.push({
        endpoint,
        status: res.status,
        protected: res.status === 401
      });
      
    } catch (error) {
      results.errors++;
      console.log(`❌ ${endpoint} - Error: ${error.message}`);
    }
  }
  
  // Test with internal API key
  console.log('\n\nTesting with Internal API Key...\n');
  
  const internalApiKey = process.env.INTERNAL_API_KEY || 'test-internal-key';
  
  for (const endpoint of endpoints.slice(0, 3)) { // Test first 3 endpoints
    try {
      const res = await fetch(`${baseUrl}${endpoint}`, {
        method: 'GET',
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': internalApiKey
        }
      });
      
      if (res.status === 200) {
        console.log(`✅ ${endpoint} - Accessible with API key`);
      } else {
        console.log(`❌ ${endpoint} - Status ${res.status} with API key`);
      }
    } catch (error) {
      console.log(`❌ ${endpoint} - Error: ${error.message}`);
    }
  }
  
  // Summary
  console.log('\n\n📊 Summary:');
  console.log(`   Total endpoints tested: ${endpoints.length}`);
  console.log(`   Protected endpoints: ${results.protected}`);
  console.log(`   Unprotected endpoints: ${results.unprotected}`);
  console.log(`   Errors: ${results.errors}`);
  
  const protectionRate = Math.round((results.protected / endpoints.length) * 100);
  console.log(`   Protection rate: ${protectionRate}%`);
  
  if (protectionRate === 100) {
    console.log('\n✅ All endpoints are properly protected!');
  } else if (protectionRate >= 80) {
    console.log('\n⚠️  Most endpoints are protected, but some need attention');
  } else {
    console.log('\n❌ Many endpoints are unprotected!');
  }
  
  // List unprotected endpoints
  if (results.unprotected > 0) {
    console.log('\n🚨 Unprotected endpoints:');
    results.endpoints
      .filter(e => !e.protected)
      .forEach(e => console.log(`   - ${e.endpoint}`));
  }
}

// Test POST endpoints
async function testPOSTAuth() {
  console.log('\n\n📝 Testing POST Endpoints\n');
  
  const baseUrl = 'http://localhost:9002';
  const postEndpoints = [
    {
      url: '/api/fortune/business',
      body: {
        name: 'Test User',
        birth_date: '1990-01-01',
        business_type: 'startup',
        industry: 'tech',
        experience_years: '3',
        current_stage: 'growth',
        goals: ['expansion', 'funding']
      }
    },
    {
      url: '/api/fortune/compatibility',
      body: {
        person1: { name: 'Person A', birthDate: '1990-01-01' },
        person2: { name: 'Person B', birthDate: '1992-05-15' }
      }
    }
  ];
  
  for (const { url, body } of postEndpoints) {
    try {
      const res = await fetch(`${baseUrl}${url}`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(body)
      });
      
      if (res.status === 401) {
        console.log(`✅ ${url} - Protected (401 Unauthorized)`);
      } else if (res.status === 200) {
        console.log(`❌ ${url} - Unprotected (200 OK)`);
      } else {
        console.log(`⚠️  ${url} - Status ${res.status}`);
      }
    } catch (error) {
      console.log(`❌ ${url} - Error: ${error.message}`);
    }
  }
}

// Run tests
(async () => {
  await testAPIAuth();
  await testPOSTAuth();
})();