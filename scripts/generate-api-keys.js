#!/usr/bin/env node

const crypto = require('crypto');

function generateSecureKey(length = 32) {
  return crypto.randomBytes(length).toString('hex');
}

console.log('🔐 Fortune App - Secure API Key Generator\n');

const internalApiKey = generateSecureKey(32);
const cronSecret = generateSecureKey(24);

console.log('Add these to your .env.local file:\n');
console.log(`INTERNAL_API_KEY=${internalApiKey}`);
console.log(`CRON_SECRET=${cronSecret}`);

console.log('\n📝 Usage Instructions:');
console.log('1. Internal API Key: Use for admin endpoints and batch operations');
console.log('   - Add header: x-api-key: <your-key>');
console.log('2. Cron Secret: Use for Vercel Cron jobs');
console.log('   - Add header: Authorization: Bearer <your-secret>');

console.log('\n⚠️  Security Reminders:');
console.log('- Never commit these keys to version control');
console.log('- Rotate keys regularly (recommended: every 90 days)');
console.log('- Use different keys for different environments (dev/staging/prod)');
console.log('- Monitor usage and set up alerts for suspicious activity');