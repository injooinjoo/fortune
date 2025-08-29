import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  try {
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    
    const supabase = createClient(supabaseUrl, supabaseServiceKey)
    
    if (req.method === 'POST') {
      // Create celebrities table with proper schema for our accurate data
      const createTableSQL = `
        -- Drop table if exists
        DROP TABLE IF EXISTS public.celebrities CASCADE;
        
        -- Create celebrities table
        CREATE TABLE public.celebrities (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            name_en TEXT DEFAULT '',
            birth_date TEXT NOT NULL,
            birth_time TEXT DEFAULT '12:00',
            gender TEXT NOT NULL CHECK (gender IN ('male', 'female', 'mixed')),
            birth_place TEXT DEFAULT '',
            category TEXT NOT NULL CHECK (category IN ('politician', 'actor', 'singer', 'streamer', 'business_leader', 'entertainer', 'athlete')),
            agency TEXT DEFAULT '',
            year_pillar TEXT DEFAULT '',
            month_pillar TEXT DEFAULT '',
            day_pillar TEXT DEFAULT '',
            hour_pillar TEXT DEFAULT '',
            saju_string TEXT DEFAULT '',
            wood_count INTEGER DEFAULT 0,
            fire_count INTEGER DEFAULT 0,
            earth_count INTEGER DEFAULT 0,
            metal_count INTEGER DEFAULT 0,
            water_count INTEGER DEFAULT 0,
            full_saju_data TEXT DEFAULT '',
            data_source TEXT DEFAULT 'accurate_manual',
            created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
            updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
        );

        -- Create indexes for better query performance
        CREATE INDEX idx_celebrities_category ON public.celebrities(category);
        CREATE INDEX idx_celebrities_name ON public.celebrities(name);
        CREATE INDEX idx_celebrities_birth_date ON public.celebrities(birth_date);
        CREATE INDEX idx_celebrities_gender ON public.celebrities(gender);

        -- Enable Row Level Security
        ALTER TABLE public.celebrities ENABLE ROW LEVEL SECURITY;

        -- Allow public read access
        CREATE POLICY "Anyone can view celebrities" ON public.celebrities
            FOR SELECT USING (true);

        -- Allow service role to insert/update/delete
        CREATE POLICY "Service role can manage celebrities" ON public.celebrities
            FOR ALL USING (auth.jwt() ->> 'role' = 'service_role');
      `
      
      const { error } = await supabase.rpc('exec_sql', { sql: createTableSQL })
      
      if (error) {
        // Try direct SQL execution if RPC fails
        try {
          await supabase.from('_supabase_migrations').select('*').limit(1)
          // If we can query migrations, try a different approach
          console.error('RPC failed, trying alternative approach:', error)
          return new Response(
            JSON.stringify({ 
              error: 'Failed to create table via RPC', 
              details: error,
              suggestion: 'Please create table manually via Supabase dashboard' 
            }),
            { headers: { 'Content-Type': 'application/json' }, status: 500 }
          )
        } catch (altError) {
          console.error('Alternative approach also failed:', altError)
        }
      }

      return new Response(
        JSON.stringify({ 
          success: true, 
          message: 'Celebrities table created successfully'
        }),
        { headers: { 'Content-Type': 'application/json' } }
      )
    }

    return new Response(
      JSON.stringify({ error: 'Only POST method allowed' }),
      { headers: { 'Content-Type': 'application/json' }, status: 405 }
    )
    
  } catch (error) {
    console.error('Function error:', error)
    return new Response(
      JSON.stringify({ error: 'Internal server error', details: error.message }),
      { headers: { 'Content-Type': 'application/json' }, status: 500 }
    )
  }
})