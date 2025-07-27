#!/usr/bin/env node

const https = require('https');

const SUPABASE_URL = 'https://hayjukwfcsdmppairazc.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhheWp1a3dmY3NkbXBwYWlyYXpjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjkxNjMzNDgsImV4cCI6MjA0NDczOTM0OH0.2PUrxG7A5SJHRs0YIsPHlG5aX7s1tBoAnDq1Pce-QMo';

async function setupTestAccount() {
  console.log('Setting up test account for injooinjoo@gmail.com...');
  
  const url = new URL(`${SUPABASE_URL}/functions/v1/setup-test-account`);
  
  const options = {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${SUPABASE_ANON_KEY}`,
      'Content-Type': 'application/json'
    }
  };

  return new Promise((resolve, reject) => {
    const req = https.request(url, options, (res) => {
      let data = '';
      
      res.on('data', (chunk) => {
        data += chunk;
      });
      
      res.on('end', () => {
        try {
          const result = JSON.parse(data);
          if (res.statusCode === 200) {
            console.log('✅ Success:', result.message);
            if (result.profile) {
              console.log('📧 Email:', result.profile.email);
              console.log('🧪 Test Account:', result.profile.is_test_account);
              console.log('🎁 Features:', JSON.stringify(result.profile.test_account_features, null, 2));
            }
            resolve(result);
          } else {
            console.error('❌ Error:', result.error);
            reject(new Error(result.error));
          }
        } catch (e) {
          console.error('❌ Failed to parse response:', e);
          console.error('Response:', data);
          reject(e);
        }
      });
    });
    
    req.on('error', (e) => {
      console.error('❌ Request failed:', e);
      reject(e);
    });
    
    req.end();
  });
}

// Run if called directly
if (require.main === module) {
  setupTestAccount()
    .then(() => process.exit(0))
    .catch(() => process.exit(1));
}

module.exports = setupTestAccount;