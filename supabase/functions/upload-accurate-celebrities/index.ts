import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  try {
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    
    const supabase = createClient(supabaseUrl, supabaseServiceKey)
    
    if (req.method === 'POST') {
      const { celebrities } = await req.json()
      
      if (!celebrities || !Array.isArray(celebrities)) {
        return new Response(
          JSON.stringify({ error: 'celebrities array is required' }),
          { headers: { 'Content-Type': 'application/json' }, status: 400 }
        )
      }

      // First, try to create the table if it doesn't exist
      try {
        const createTableSQL = `
          CREATE TABLE IF NOT EXISTS public.celebrities (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            name_en TEXT DEFAULT '',
            birth_date TEXT NOT NULL,
            birth_time TEXT DEFAULT '12:00',
            gender TEXT NOT NULL,
            birth_place TEXT DEFAULT '',
            category TEXT NOT NULL,
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
          
          ALTER TABLE public.celebrities ENABLE ROW LEVEL SECURITY;
          
          CREATE POLICY IF NOT EXISTS "Anyone can view celebrities" ON public.celebrities
            FOR SELECT USING (true);
        `
        
        await supabase.rpc('exec_sql', { sql: createTableSQL }).catch(() => {
          // If RPC doesn't work, that's okay, we'll try the insert anyway
          console.log('RPC exec_sql not available, proceeding with insert')
        })
      } catch (createError) {
        console.log('Table creation attempt failed:', createError)
      }

      // Clear existing celebrities
      const { error: deleteError } = await supabase
        .from('celebrities')
        .delete()
        .neq('id', 'never_match') // Delete all rows
        
      if (deleteError) {
        console.error('Delete error:', deleteError)
        return new Response(
          JSON.stringify({ error: 'Failed to clear existing data', details: deleteError }),
          { headers: { 'Content-Type': 'application/json' }, status: 500 }
        )
      }

      // Insert new celebrities in batches
      const batchSize = 100
      let insertedCount = 0
      
      for (let i = 0; i < celebrities.length; i += batchSize) {
        const batch = celebrities.slice(i, i + batchSize)
        
        const { error: insertError } = await supabase
          .from('celebrities')
          .insert(batch)
          
        if (insertError) {
          console.error(`Batch ${i / batchSize + 1} error:`, insertError)
          return new Response(
            JSON.stringify({ 
              error: `Failed to insert batch ${i / batchSize + 1}`, 
              details: insertError,
              inserted: insertedCount 
            }),
            { headers: { 'Content-Type': 'application/json' }, status: 500 }
          )
        }
        
        insertedCount += batch.length
        console.log(`Inserted batch ${i / batchSize + 1}: ${batch.length} celebrities`)
      }

      return new Response(
        JSON.stringify({ 
          success: true, 
          message: `Successfully uploaded ${insertedCount} celebrities`,
          inserted: insertedCount
        }),
        { headers: { 'Content-Type': 'application/json' } }
      )
    } else if (req.method === 'GET') {
      // Check current status
      const { count, error } = await supabase
        .from('celebrities')
        .select('*', { count: 'exact' })
        
      if (error) {
        return new Response(
          JSON.stringify({ error: 'Failed to get count', details: error }),
          { headers: { 'Content-Type': 'application/json' }, status: 500 }
        )
      }
      
      return new Response(
        JSON.stringify({ 
          success: true, 
          current_count: count,
          message: `Currently ${count} celebrities in database`
        }),
        { headers: { 'Content-Type': 'application/json' } }
      )
    }

    return new Response(
      JSON.stringify({ error: 'Method not allowed' }),
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