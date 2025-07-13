const axios = require('axios');

const API_BASE_URL = 'http://localhost:3001/api/v1';

// Test configuration
const testConfig = {
  authToken: '', // Add a valid JWT token here
  userId: '', // Add a test user ID here
};

// Test endpoints
async function testEndpoints() {
  console.log('🧪 Testing Fortune API Server endpoints...\n');

  // Test health check
  try {
    console.log('1. Testing health check...');
    const health = await axios.get(`${API_BASE_URL}/`);
    console.log('✅ Health check passed:', health.data);
  } catch (error) {
    console.error('❌ Health check failed:', error.message);
  }

  // Test auth endpoints
  if (testConfig.authToken) {
    const headers = {
      Authorization: `Bearer ${testConfig.authToken}`,
    };

    try {
      console.log('\n2. Testing user profile...');
      const profile = await axios.get(`${API_BASE_URL}/user/profile`, { headers });
      console.log('✅ User profile:', profile.data);
    } catch (error) {
      console.error('❌ User profile failed:', error.message);
    }

    try {
      console.log('\n3. Testing token balance...');
      const balance = await axios.get(`${API_BASE_URL}/token/balance`, { headers });
      console.log('✅ Token balance:', balance.data);
    } catch (error) {
      console.error('❌ Token balance failed:', error.message);
    }

    try {
      console.log('\n4. Testing fortune generation...');
      const fortune = await axios.post(
        `${API_BASE_URL}/fortune/daily`,
        {
          name: 'Test User',
          birthDate: '1990-01-01',
          birthTime: '12:00',
          gender: 'male',
        },
        { headers }
      );
      console.log('✅ Fortune generated:', fortune.data);
    } catch (error) {
      console.error('❌ Fortune generation failed:', error.message);
    }
  } else {
    console.log('\n⚠️  Skipping authenticated endpoints - no auth token provided');
  }

  console.log('\n✨ API test completed!');
}

// Run tests
testEndpoints().catch(console.error);

console.log(`
To run authenticated tests:
1. Get a valid JWT token from Supabase auth
2. Add it to testConfig.authToken
3. Run: node test-api.js
`);