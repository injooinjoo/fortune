#!/usr/bin/env node

const fs = require('fs').promises;
const path = require('path');

async function setupDatabase() {
  console.log('🗄️  Fortune App Database Setup Helper\n');
  console.log('=' .repeat(50));
  
  const migrationPath = path.join(__dirname, '../supabase/migrations/001_create_core_tables.sql');
  
  try {
    const sqlContent = await fs.readFile(migrationPath, 'utf8');
    
    console.log('\n📋 Database Migration Script Location:');
    console.log(`   ${migrationPath}`);
    
    console.log('\n🔧 Setup Instructions:\n');
    console.log('1. Open your Supabase Dashboard:');
    console.log('   https://app.supabase.com/project/hayjukwfcsdm\n');
    
    console.log('2. Navigate to SQL Editor (left sidebar)');
    console.log('   - Click on "SQL Editor" icon\n');
    
    console.log('3. Create a new query:');
    console.log('   - Click "New query" button');
    console.log('   - Name it: "Create Fortune Tables"\n');
    
    console.log('4. Copy and paste the migration SQL:');
    console.log('   - The migration file has been copied to your clipboard (if supported)');
    console.log('   - Or manually copy from: supabase/migrations/001_create_core_tables.sql\n');
    
    console.log('5. Execute the migration:');
    console.log('   - Click "Run" button');
    console.log('   - Wait for success message\n');
    
    console.log('6. Verify tables were created:');
    console.log('   - Go to "Table Editor" in sidebar');
    console.log('   - You should see these new tables:');
    console.log('     ✓ user_fortunes');
    console.log('     ✓ fortune_batches');
    console.log('     ✓ api_usage_logs');
    console.log('     ✓ payment_transactions');
    console.log('     ✓ subscriptions\n');
    
    console.log('7. Run verification test:');
    console.log('   npm run test:database\n');
    
    // Try to copy to clipboard (Node.js 16+)
    try {
      const { exec } = require('child_process');
      exec(`echo "${sqlContent.replace(/"/g, '\\"')}" | pbcopy`, (error) => {
        if (!error) {
          console.log('✅ Migration SQL copied to clipboard!');
        }
      });
    } catch (e) {
      // Clipboard copy failed, that's okay
    }
    
    console.log('\n📝 Troubleshooting:');
    console.log('- If tables already exist: Drop them first or use IF NOT EXISTS');
    console.log('- If RLS errors occur: The migration handles RLS setup automatically');
    console.log('- If permission errors: Check your Supabase service role key\n');
    
  } catch (error) {
    console.error('❌ Error reading migration file:', error.message);
  }
}

setupDatabase().catch(console.error);