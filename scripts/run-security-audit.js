// Load environment variables
require('dotenv').config({ path: '.env.local' });

// Mock Next.js environment
global.process.env.NODE_ENV = process.env.NODE_ENV || 'development';

// Import and run security audit
const { logSecurityAudit } = require('../src/lib/security-validator.ts');

console.log('Running security audit...\n');
logSecurityAudit();