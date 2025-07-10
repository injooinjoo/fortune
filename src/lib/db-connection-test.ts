import { logger } from '@/lib/logger';
import { supabase } from './supabase';

export class DatabaseConnectionTest {
  
  /**
   * Test basic Supabase connection
   */
  static async testConnection(): Promise<{ success: boolean; message: string }> {
    try {
      const { data, error } = await supabase
        .from('user_profiles')
        .select('count')
        .limit(1);
      
      if (error) {
        return {
          success: false,
          message: `Database connection failed: ${error.message}`
        };
      }
      
      return {
        success: true,
        message: 'Database connection successful'
      };
    } catch (error) {
      return {
        success: false,
        message: `Connection error: ${error instanceof Error ? error.message : 'Unknown error'}`
      };
    }
  }
  
  /**
   * Test all required tables exist
   */
  static async testTables(): Promise<{ success: boolean; message: string; details: Record<string, boolean> }> {
    const requiredTables = [
      'user_profiles',
      'user_fortunes', 
      'fortune_batches',
      'api_usage_logs',
      'payment_transactions',
      'subscriptions'
    ];
    
    const tableStatus: Record<string, boolean> = {};
    let allTablesExist = true;
    
    for (const table of requiredTables) {
      try {
        const { error } = await supabase
          .from(table)
          .select('*')
          .limit(1);
        
        tableStatus[table] = !error;
        if (error) allTablesExist = false;
      } catch {
        tableStatus[table] = false;
        allTablesExist = false;
      }
    }
    
    return {
      success: allTablesExist,
      message: allTablesExist 
        ? 'All required tables exist' 
        : 'Some tables are missing',
      details: tableStatus
    };
  }
  
  /**
   * Test environment variables
   */
  static testEnvironmentVariables(): { success: boolean; message: string; details: Record<string, boolean> } {
    const requiredEnvVars = {
      'NEXT_PUBLIC_SUPABASE_URL': !!process.env.NEXT_PUBLIC_SUPABASE_URL,
      'NEXT_PUBLIC_SUPABASE_ANON_KEY': !!process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY,
      'SUPABASE_SERVICE_ROLE_KEY': !!process.env.SUPABASE_SERVICE_ROLE_KEY,
      'OPENAI_API_KEY': !!process.env.OPENAI_API_KEY
    };
    
    const allPresent = Object.values(requiredEnvVars).every(Boolean);
    
    return {
      success: allPresent,
      message: allPresent 
        ? 'All environment variables are set' 
        : 'Some environment variables are missing',
      details: requiredEnvVars
    };
  }
  
  /**
   * Test user creation and profile setup
   */
  static async testUserOperations(): Promise<{ success: boolean; message: string }> {
    try {
      // Test creating a test profile
      const testProfile = {
        name: '테스트사용자',
        birth_date: '1990-01-01',
        gender: 'male',
        email: `test_${Date.now()}@example.com`
      };
      
      const { data: insertData, error: insertError } = await supabase
        .from('user_profiles')
        .insert(testProfile)
        .select()
        .single();
      
      if (insertError) {
        return {
          success: false,
          message: `Failed to insert test profile: ${insertError.message}`
        };
      }
      
      // Test reading the profile back
      const { data: selectData, error: selectError } = await supabase
        .from('user_profiles')
        .select('*')
        .eq('id', insertData.id)
        .single();
      
      if (selectError) {
        return {
          success: false,
          message: `Failed to read test profile: ${selectError.message}`
        };
      }
      
      // Clean up test data
      await supabase
        .from('user_profiles')
        .delete()
        .eq('id', insertData.id);
      
      return {
        success: true,
        message: 'User operations test passed'
      };
    } catch (error) {
      return {
        success: false,
        message: `User operations test failed: ${error instanceof Error ? error.message : 'Unknown error'}`
      };
    }
  }
  
  /**
   * Run all tests
   */
  static async runAllTests(): Promise<{
    success: boolean;
    results: {
      connection: Awaited<ReturnType<typeof DatabaseConnectionTest.testConnection>>;
      tables: Awaited<ReturnType<typeof DatabaseConnectionTest.testTables>>;
      environment: ReturnType<typeof DatabaseConnectionTest.testEnvironmentVariables>;
      userOperations: Awaited<ReturnType<typeof DatabaseConnectionTest.testUserOperations>>;
    }
  }> {
    logger.debug('🧪 Running database tests...');
    
    const results = {
      connection: await this.testConnection(),
      tables: await this.testTables(),
      environment: this.testEnvironmentVariables(),
      userOperations: await this.testUserOperations()
    };
    
    const allSuccess = Object.values(results).every(result => result.success);
    
    // Log results
    logger.debug('\n📋 Test Results:');
    logger.debug('================');
    
    Object.entries(results).forEach(([testName, result]) => {
      const status = result.success ? '✅' : '❌';
      logger.debug(`${status} ${testName}: ${result.message}`);
      
      if ('details' in result && result.details) {
        Object.entries(result.details).forEach(([key, value]) => {
          const detailStatus = value ? '✓' : '✗';
          logger.debug(`  ${detailStatus} ${key}`);
        });
      }
    });
    
    logger.debug('\n' + (allSuccess ? '🎉 All tests passed!' : '⚠️  Some tests failed'));
    
    return {
      success: allSuccess,
      results
    };
  }
}

// Export for direct usage
export const runDatabaseTests = DatabaseConnectionTest.runAllTests.bind(DatabaseConnectionTest);