#!/usr/bin/env node

/**
 * Test script to verify Supabase authentication configuration
 * Run with: node scripts/test-auth-flow.js
 */

const chalk = require('chalk');

console.log(chalk.blue('\n🔍 Testing Supabase Authentication Configuration\n'));

// Check environment variables
const requiredEnvVars = [
  'NEXT_PUBLIC_SUPABASE_URL',
  'NEXT_PUBLIC_SUPABASE_ANON_KEY'
];

let hasErrors = false;

console.log(chalk.yellow('1. Checking environment variables:'));
requiredEnvVars.forEach(varName => {
  const value = process.env[varName];
  if (value) {
    console.log(chalk.green(`   ✓ ${varName}: Set (${value.substring(0, 20)}...)`));
  } else {
    console.log(chalk.red(`   ✗ ${varName}: Not set`));
    hasErrors = true;
  }
});

console.log(chalk.yellow('\n2. Checking Supabase URL format:'));
const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
if (supabaseUrl) {
  if (supabaseUrl.includes('.supabase.co')) {
    console.log(chalk.green('   ✓ Valid Supabase URL format'));
  } else {
    console.log(chalk.red('   ✗ Invalid Supabase URL format'));
    hasErrors = true;
  }
}

console.log(chalk.yellow('\n3. Authentication flow recommendations:'));
console.log(chalk.cyan('   • PKCE is enabled by default in Supabase Auth'));
console.log(chalk.cyan('   • Code verifier is automatically generated and stored by Supabase'));
console.log(chalk.cyan('   • Ensure callback URL is correctly configured in Supabase dashboard'));
console.log(chalk.cyan('   • Callback URL should be: http://localhost:9002/auth/callback'));

console.log(chalk.yellow('\n4. Common PKCE issues and solutions:'));
console.log(chalk.magenta('   • Issue: "code verifier should be non-empty"'));
console.log(chalk.white('     → Solution: Don\'t clear localStorage before OAuth redirect'));
console.log(chalk.magenta('   • Issue: Authentication loops'));
console.log(chalk.white('     → Solution: Check redirect URL configuration in Supabase dashboard'));
console.log(chalk.magenta('   • Issue: Session not persisting'));
console.log(chalk.white('     → Solution: Ensure localStorage is available and not blocked'));

if (hasErrors) {
  console.log(chalk.red('\n❌ Some issues were found. Please fix them before testing authentication.\n'));
  process.exit(1);
} else {
  console.log(chalk.green('\n✅ Configuration looks good! You can test the authentication flow.\n'));
  console.log(chalk.blue('Next steps:'));
  console.log(chalk.white('1. Ensure your Supabase project has Google OAuth configured'));
  console.log(chalk.white('2. Add http://localhost:9002/auth/callback to allowed redirect URLs'));
  console.log(chalk.white('3. Test the login flow in your browser\n'));
}