#!/usr/bin/env node

const fetch = require('node-fetch');

// Test batch fortune generation
async function testBatchFortune() {
  const baseUrl = 'http://localhost:9002';
  const endpoint = '/api/fortune/generate-batch';
  
  console.log('🎯 Testing Batch Fortune System\n');
  
  // Test request payload
  const testRequest = {
    request_type: 'user_direct_request',
    user_profile: {
      id: 'test_user_123',
      name: '테스트 사용자',
      birth_date: '1990-05-15',
      birth_time: '14:30',
      gender: '남성',
      mbti: 'INTJ',
      zodiac_sign: '황소자리'
    },
    requested_categories: ['love', 'wealth', 'career'],
    fortune_types: ['daily', 'weekly'],
    target_date: new Date().toISOString().split('T')[0],
    generation_context: {
      is_user_initiated: true,
      cache_duration_hours: 24
    }
  };
  
  console.log('1. Testing without authentication...');
  try {
    const res = await fetch(`${baseUrl}${endpoint}`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(testRequest)
    });
    
    const body = await res.json();
    
    if (res.status === 401) {
      console.log('✅ Correctly requires authentication');
      console.log(`   Message: ${body.error}`);
    } else {
      console.log(`❌ Unexpected status: ${res.status}`);
      console.log(`   Response:`, body);
    }
  } catch (error) {
    console.log(`❌ Error: ${error.message}`);
  }
  
  // Test with internal API key
  console.log('\n2. Testing with internal API key...');
  const apiKey = process.env.INTERNAL_API_KEY || 'test-key';
  
  try {
    const res = await fetch(`${baseUrl}${endpoint}`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': apiKey
      },
      body: JSON.stringify(testRequest)
    });
    
    const body = await res.json();
    
    if (res.status === 200) {
      console.log('✅ Batch fortune generated successfully');
      console.log(`   Request ID: ${body.data?.request_id}`);
      console.log(`   Fortunes generated: ${body.data?.fortunes?.length || 0}`);
      
      if (body.data?.token_usage) {
        console.log(`   Tokens used: ${body.data.token_usage.total_tokens}`);
      }
      
      if (body.data?.cache_info) {
        console.log(`   Cache expires: ${body.data.cache_info.expires_at}`);
      }
      
      // Show sample fortune
      if (body.data?.fortunes?.[0]) {
        const firstFortune = body.data.fortunes[0];
        console.log('\n   Sample fortune:');
        console.log(`   - Type: ${firstFortune.fortune_type}`);
        console.log(`   - Category: ${firstFortune.category}`);
        console.log(`   - Title: ${firstFortune.title}`);
      }
    } else {
      console.log(`⚠️  Status: ${res.status}`);
      console.log(`   Response:`, body);
    }
  } catch (error) {
    console.log(`❌ Error: ${error.message}`);
  }
  
  // Test rate limiting
  console.log('\n3. Testing rate limiting (3 requests)...');
  
  for (let i = 0; i < 3; i++) {
    try {
      const res = await fetch(`${baseUrl}${endpoint}`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': apiKey
        },
        body: JSON.stringify({
          ...testRequest,
          user_profile: {
            ...testRequest.user_profile,
            id: `test_user_${i}`
          }
        })
      });
      
      if (res.status === 429) {
        console.log(`   Request ${i + 1}: 🚦 Rate limited`);
        console.log(`   Retry after: ${res.headers.get('retry-after')}s`);
      } else if (res.status === 200) {
        console.log(`   Request ${i + 1}: ✅ Success`);
      } else {
        console.log(`   Request ${i + 1}: ⚠️  Status ${res.status}`);
      }
    } catch (error) {
      console.log(`   Request ${i + 1}: ❌ Error`);
    }
  }
  
  // Test validation
  console.log('\n4. Testing validation...');
  
  const invalidRequests = [
    {
      name: 'Missing user profile',
      payload: { request_type: 'daily_refresh' }
    },
    {
      name: 'Invalid request type',
      payload: {
        ...testRequest,
        request_type: 'invalid_type'
      }
    },
    {
      name: 'Missing required fields',
      payload: {
        request_type: 'onboarding_complete',
        user_profile: {
          id: 'test_123'
          // Missing name and birth_date
        },
        generation_context: {
          cache_duration_hours: 24
        }
      }
    }
  ];
  
  for (const { name, payload } of invalidRequests) {
    try {
      const res = await fetch(`${baseUrl}${endpoint}`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': apiKey
        },
        body: JSON.stringify(payload)
      });
      
      const body = await res.json();
      
      if (res.status === 400) {
        console.log(`   ✅ ${name}: Correctly rejected`);
      } else {
        console.log(`   ❌ ${name}: Should have been rejected (status: ${res.status})`);
      }
    } catch (error) {
      console.log(`   ❌ ${name}: Error - ${error.message}`);
    }
  }
}

// Run test
testBatchFortune();