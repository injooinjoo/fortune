const { Redis } = require('@upstash/redis');
const { Ratelimit } = require('@upstash/ratelimit');
require('dotenv').config({ path: '.env.local' });

async function testRedisConnection() {
  console.log('🔍 Testing Redis Connection...\n');
  
  // Check environment variables
  const hasUrl = !!process.env.UPSTASH_REDIS_REST_URL;
  const hasToken = !!process.env.UPSTASH_REDIS_REST_TOKEN;
  
  console.log(`✓ UPSTASH_REDIS_REST_URL: ${hasUrl ? 'Set' : 'Not set'}`);
  console.log(`✓ UPSTASH_REDIS_REST_TOKEN: ${hasToken ? 'Set' : 'Not set'}`);
  
  if (!hasUrl || !hasToken) {
    console.log('\n❌ Redis environment variables not configured');
    console.log('Please set UPSTASH_REDIS_REST_URL and UPSTASH_REDIS_REST_TOKEN in .env.local');
    return;
  }
  
  try {
    // Initialize Redis client
    const redis = new Redis({
      url: process.env.UPSTASH_REDIS_REST_URL,
      token: process.env.UPSTASH_REDIS_REST_TOKEN,
    });
    
    console.log('\n📡 Testing Redis connection...');
    
    // Test basic operations
    await redis.set('test-key', 'test-value');
    const value = await redis.get('test-key');
    
    if (value === 'test-value') {
      console.log('✅ Redis connection successful!');
      console.log(`   Retrieved value: ${value}`);
    } else {
      console.log('❌ Redis connection test failed - unexpected value');
    }
    
    // Clean up
    await redis.del('test-key');
    
    // Test rate limiter
    console.log('\n🔒 Testing Rate Limiter...');
    const ratelimit = new Ratelimit({
      redis,
      limiter: Ratelimit.slidingWindow(5, '10 s'), // 5 requests per 10 seconds
      analytics: true,
    });
    
    const identifier = 'test-user';
    
    // Test multiple requests
    const results = [];
    for (let i = 0; i < 7; i++) {
      const result = await ratelimit.limit(identifier);
      results.push(result);
      console.log(`   Request ${i + 1}: ${result.success ? '✅ Allowed' : '❌ Blocked'} (Remaining: ${result.remaining})`);
    }
    
    console.log('\nRate limiter is working correctly!');
    
  } catch (error) {
    console.error('\n❌ Redis connection error:', error.message);
    console.log('Please check your Redis credentials');
  }
}

testRedisConnection();