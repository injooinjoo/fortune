import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { authenticateUser } from '../_shared/auth.ts'
import { corsHeaders } from '../_shared/cors.ts'

const supabaseUrl = Deno.env.get('SUPABASE_URL')!
const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!

const supabase = createClient(supabaseUrl, supabaseServiceKey, {
  auth: { autoRefreshToken: false, persistSession: false }
})

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response(null, { headers: corsHeaders })
  }

  if (req.method !== 'POST') {
    return new Response(
      JSON.stringify({ error: 'Method not allowed' }),
      { status: 405, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }

  const { user, error } = await authenticateUser(req)
  if (error || !user) {
    return error!
  }

  const payload = await req.json().catch(() => ({}))
  const reason = payload?.reason ?? null
  const feedback = payload?.feedback ?? null

  try {
    const userId = user.id
    console.log(`[delete-account] Request: userId=${userId}, reason=${reason}`)

    const deleteByUserId = async (table: string, column = 'user_id') => {
      const { error: deleteError } = await supabase
        .from(table)
        .delete()
        .eq(column, userId)

      if (deleteError) {
        console.log(`[delete-account] Delete failed: ${table} - ${deleteError.message}`)
      }
    }

    await deleteByUserId('trend_comment_likes')
    await deleteByUserId('trend_likes')
    await deleteByUserId('trend_comments')
    await deleteByUserId('user_psychology_results')
    await deleteByUserId('user_worldcup_results')
    await deleteByUserId('user_balance_results')
    await deleteByUserId('face_reading_mission_progress')
    await deleteByUserId('face_reading_conditions')
    await deleteByUserId('face_reading_history')
    await deleteByUserId('user_health_surveys')
    await deleteByUserId('user_saju')
    await deleteByUserId('fortune_history')
    await deleteByUserId('fortune_cache')
    await deleteByUserId('fortune_stories')
    await deleteByUserId('talisman_user_cache')
    await deleteByUserId('pets')
    await deleteByUserId('secondary_profiles')
    await deleteByUserId('token_balance')
    await deleteByUserId('subscriptions')
    await deleteByUserId('user_statistics')
    await deleteByUserId('user_profiles', 'id')

    const { error: deleteAuthError } = await supabase.auth.admin.deleteUser(userId)
    if (deleteAuthError) {
      console.log(`[delete-account] Auth delete failed: ${deleteAuthError.message}`)
      return new Response(
        JSON.stringify({ error: 'Failed to delete auth user' }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    return new Response(
      JSON.stringify({ success: true, reason, feedback }),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  } catch (e) {
    console.log(`[delete-account] Unexpected error: ${e}`)
    return new Response(
      JSON.stringify({ error: 'Unexpected error' }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})
