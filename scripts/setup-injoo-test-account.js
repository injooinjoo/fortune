#!/usr/bin/env node

const { createClient } = require('@supabase/supabase-js');
require('dotenv').config({ path: './fortune_flutter/.env' });

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.SUPABASE_ANON_KEY;

if (!supabaseUrl || !supabaseServiceKey) {
  console.error('Missing Supabase credentials in .env file');
  process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseServiceKey);

async function setupTestAccount() {
  try {
    // Update injooinjoo@gmail.com to be a test account
    const { data, error } = await supabase
      .from('user_profiles')
      .update({
        is_test_account: true,
        test_account_features: {
          unlimited_tokens: true,
          premium_enabled: false,
          can_toggle_premium: true,
          created_at: new Date().toISOString()
        }
      })
      .eq('email', 'injooinjoo@gmail.com')
      .select();

    if (error) {
      console.error('Error updating profile:', error);
      return;
    }

    if (!data || data.length === 0) {
      console.log('No user found with email injooinjoo@gmail.com');
      return;
    }

    console.log('Successfully set up test account:');
    console.log(JSON.stringify(data[0], null, 2));
  } catch (err) {
    console.error('Unexpected error:', err);
  }
}

setupTestAccount();