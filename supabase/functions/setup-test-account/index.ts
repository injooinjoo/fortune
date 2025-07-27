import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const supabase = createClient(supabaseUrl, supabaseServiceKey)

    // Check if the migration has already been applied
    const { data: existingProfile } = await supabase
      .from('user_profiles')
      .select('email, is_test_account')
      .eq('email', 'injooinjoo@gmail.com')
      .single()

    if (existingProfile?.is_test_account === true) {
      return new Response(
        JSON.stringify({ 
          message: 'Test account already set up',
          email: 'injooinjoo@gmail.com'
        }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Update the user profile to mark as test account
    const { data, error } = await supabase
      .from('user_profiles')
      .update({
        is_test_account: true,
        test_account_features: {
          unlimited_tokens: true,
          premium_enabled: true,
          can_toggle_premium: true,
          created_at: new Date().toISOString()
        }
      })
      .eq('email', 'injooinjoo@gmail.com')
      .select()
      .single()

    if (error) {
      throw error
    }

    return new Response(
      JSON.stringify({ 
        success: true,
        message: 'Test account successfully set up',
        profile: data
      }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { 
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      }
    )
  }
})