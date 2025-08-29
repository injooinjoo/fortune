const { createClient } = require('@supabase/supabase-js');
const fs = require('fs');
const path = require('path');

// Supabase connection details
const supabaseUrl = 'https://kfkdsoyrcgsgkjhwkcin.supabase.co';
const supabaseKey = 'your-anon-key-here'; // You'll need to provide this
const supabase = createClient(supabaseUrl, supabaseKey);

// Alternative: Direct database connection if you have the connection string
const { Client } = require('pg');

const client = new Client({
  connectionString: 'postgresql://postgres.kfkdsoyrcgsgkjhwkcin:vf8gO4yb3hUYgNWh@aws-0-ap-northeast-2.pooler.supabase.co:6543/postgres',
  ssl: {
    rejectUnauthorized: false
  }
});

async function uploadCelebrityData() {
  try {
    console.log('Connecting to database...');
    await client.connect();
    console.log('Connected successfully!');
    
    // Read the SQL file
    const sqlFilePath = path.join(__dirname, 'celebrity_saju_mega_final.sql');
    const sqlContent = fs.readFileSync(sqlFilePath, 'utf8');
    
    console.log('Executing SQL file...');
    console.log(`SQL file size: ${sqlContent.length} characters`);
    
    // Execute the SQL
    const result = await client.query(sqlContent);
    
    console.log('SQL executed successfully!');
    console.log('Result:', result);
    
    // Check the final count
    const countResult = await client.query('SELECT COUNT(*) FROM public.celebrities;');
    console.log(`Total celebrities after upload: ${countResult.rows[0].count}`);
    
  } catch (error) {
    console.error('Error uploading celebrity data:', error);
    
    // If it's a connection error, provide debugging info
    if (error.code === 'ENOTFOUND' || error.message.includes('hostname')) {
      console.log('\nConnection debugging:');
      console.log('Make sure the hostname is correct. Common formats:');
      console.log('- For direct DB: db.[project-ref].supabase.co');
      console.log('- For pooler: aws-[region].pooler.supabase.co');
      console.log('\nCurrent config:');
      console.log('Host: aws-0-ap-northeast-2.pooler.supabase.co');
      console.log('Port: 6543');
      console.log('Database: postgres');
      console.log('User: postgres.kfkdsoyrcgsgkjhwkcin');
    }
  } finally {
    await client.end();
  }
}

// Run the upload
uploadCelebrityData();