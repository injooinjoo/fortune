import { createClient } from '@supabase/supabase-js';
import { env } from './env';
import logger from '../utils/logger';

// Create Supabase client
export const supabase = createClient(
  env.SUPABASE_URL,
  env.SUPABASE_ANON_KEY,
  {
    auth: {
      autoRefreshToken: true,
      persistSession: false,
    },
  }
);

// Create Supabase admin client for server-side operations
export const supabaseAdmin = createClient(
  env.SUPABASE_URL,
  env.SUPABASE_SERVICE_ROLE_KEY,
  {
    auth: {
      autoRefreshToken: false,
      persistSession: false,
    },
  }
);

// Test Supabase connection
export async function testSupabaseConnection(): Promise<boolean> {
  try {
    const { data, error } = await supabaseAdmin
      .from('user_profiles')
      .select('count')
      .limit(1);

    if (error) {
      logger.error('Supabase connection test failed:', error);
      return false;
    }

    logger.info('Supabase connection successful');
    return true;
  } catch (error) {
    logger.error('Supabase connection test error:', error);
    return false;
  }
}