#!/usr/bin/env node

// Test database connection and setup
require('dotenv').config({ path: '.env.local' });

async function testDatabaseSetup() {
  console.log('🗄️  Fortune App Database Test\n');
  
  // Check environment variables first
  console.log('📋 Environment Variables Check:');
  const envVars = {
    'NEXT_PUBLIC_SUPABASE_URL': process.env.NEXT_PUBLIC_SUPABASE_URL,
    'NEXT_PUBLIC_SUPABASE_ANON_KEY': process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY,
    'SUPABASE_SERVICE_ROLE_KEY': process.env.SUPABASE_SERVICE_ROLE_KEY,
    'OPENAI_API_KEY': process.env.OPENAI_API_KEY
  };
  
  Object.entries(envVars).forEach(([key, value]) => {
    const status = value ? '✅' : '❌';
    const displayValue = value ? (value.substring(0, 20) + '...') : 'Not set';
    console.log(`${status} ${key}: ${displayValue}`);
  });
  
  const missingVars = Object.entries(envVars)
    .filter(([key, value]) => !value)
    .map(([key]) => key);
  
  if (missingVars.length > 0) {
    console.log(`\n❌ Missing environment variables: ${missingVars.join(', ')}`);
    console.log('\n📝 To fix this:');
    console.log('1. Copy .env.local.example to .env.local');
    console.log('2. Set up your Supabase project at https://supabase.com');
    console.log('3. Fill in the required values');
    console.log('4. Get OpenAI API key from https://platform.openai.com');
    return;
  }
  
  console.log('\n✅ All environment variables are set!');
  
  // Test Supabase connection
  console.log('\n🔌 Testing Supabase connection...');
  
  try {
    const { createClient } = require('@supabase/supabase-js');
    
    const supabase = createClient(
      process.env.NEXT_PUBLIC_SUPABASE_URL,
      process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY
    );
    
    // Test basic connection
    const { data, error } = await supabase
      .from('user_profiles')
      .select('count')
      .limit(1);
    
    if (error) {
      console.log('❌ Database connection failed:', error.message);
      console.log('\n📝 Possible solutions:');
      console.log('1. Check if your Supabase URL and keys are correct');
      console.log('2. Run the migration: supabase/migrations/001_create_core_tables.sql');
      console.log('3. Check if RLS policies allow access');
      return;
    }
    
    console.log('✅ Database connection successful!');
    
    // Test required tables
    console.log('\n📋 Testing required tables...');
    const requiredTables = [
      'user_profiles',
      'user_fortunes', 
      'fortune_batches',
      'api_usage_logs',
      'payment_transactions',
      'subscriptions'
    ];
    
    const tableStatus = {};
    for (const table of requiredTables) {
      try {
        const { error } = await supabase
          .from(table)
          .select('*')
          .limit(1);
        
        tableStatus[table] = !error;
        const status = error ? '❌' : '✅';
        console.log(`${status} ${table}${error ? ': ' + error.message : ''}`);
      } catch (err) {
        tableStatus[table] = false;
        console.log(`❌ ${table}: ${err.message}`);
      }
    }
    
    const missingTables = Object.entries(tableStatus)
      .filter(([table, exists]) => !exists)
      .map(([table]) => table);
    
    if (missingTables.length > 0) {
      console.log(`\n❌ Missing tables: ${missingTables.join(', ')}`);
      console.log('\n📝 To create tables:');
      console.log('1. Open Supabase dashboard → SQL Editor');
      console.log('2. Run: supabase/migrations/001_create_core_tables.sql');
      console.log('3. Re-run this test');
      return;
    }
    
    console.log('\n✅ All tables exist!');
    
    // Test OpenAI API
    console.log('\n🤖 Testing OpenAI API...');
    try {
      const OpenAI = require('openai');
      const openai = new OpenAI({
        apiKey: process.env.OPENAI_API_KEY,
      });
      
      const response = await openai.chat.completions.create({
        model: "gpt-3.5-turbo",
        messages: [{ role: "user", content: "Hello" }],
        max_tokens: 5
      });
      
      if (response.choices && response.choices.length > 0) {
        console.log('✅ OpenAI API connection successful!');
      } else {
        console.log('❌ OpenAI API returned empty response');
      }
    } catch (error) {
      console.log('❌ OpenAI API failed:', error.message);
      console.log('\n📝 To fix:');
      console.log('1. Get API key from https://platform.openai.com');
      console.log('2. Set OPENAI_API_KEY in .env.local');
      console.log('3. Ensure you have credits in your OpenAI account');
    }
    
    console.log('\n🎉 Database setup test completed!');
    console.log('\n📋 Next Steps:');
    console.log('1. If all tests pass, you can start the development server');
    console.log('2. Create your first user profile through the app');
    console.log('3. Test fortune generation functionality');
    
  } catch (error) {
    console.log('❌ Test failed:', error.message);
    console.log('\n📝 Make sure you have installed dependencies:');
    console.log('npm install @supabase/supabase-js openai');
  }
}

// Run the test
testDatabaseSetup().catch(console.error);