import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { authenticateUser } from '../_shared/auth.ts'
import { corsHeaders } from '../_shared/cors.ts'

const supabaseUrl = Deno.env.get('SUPABASE_URL')!
const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!

const supabase = createClient(supabaseUrl, supabaseServiceKey, {
  auth: { autoRefreshToken: false, persistSession: false },
})

interface DeleteAccountAuditEntry {
  table: string
  column: string
  rowsDeleted: number
  error?: string
}

// Tables that MUST be deleted for App Store 5.1.1(v) compliance. If a row
// cannot be removed, the auth user is NOT deleted so the request can be
// retried cleanly on the next attempt.
const DELETE_TARGETS: Array<{ table: string; column?: string }> = [
  { table: 'trend_comment_likes' },
  { table: 'trend_likes' },
  { table: 'trend_comments' },
  { table: 'user_psychology_results' },
  { table: 'user_worldcup_results' },
  { table: 'user_balance_results' },
  { table: 'face_reading_mission_progress' },
  { table: 'face_reading_conditions' },
  { table: 'face_reading_history' },
  { table: 'user_health_surveys' },
  { table: 'user_saju' },
  { table: 'fortune_history' },
  { table: 'fortune_cache' },
  { table: 'fortune_stories' },
  { table: 'talisman_user_cache' },
  { table: 'pets' },
  { table: 'secondary_profiles' },
  { table: 'token_balance' },
  { table: 'subscriptions' },
  { table: 'user_statistics' },
  { table: 'user_profiles', column: 'id' },
]

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response(null, { headers: corsHeaders })
  }

  if (req.method !== 'POST') {
    return new Response(
      JSON.stringify({ error: 'Method not allowed' }),
      { status: 405, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
    )
  }

  const { user, error } = await authenticateUser(req)
  if (error || !user) {
    return error!
  }

  const payload = await req.json().catch(() => ({}))
  const reason = payload?.reason ?? null
  const feedback = payload?.feedback ?? null

  const userId = user.id
  console.log(`[delete-account] Request: userId=${userId}, reason=${reason}`)

  const audit: DeleteAccountAuditEntry[] = []
  const failedDeletes: DeleteAccountAuditEntry[] = []

  try {
    for (const target of DELETE_TARGETS) {
      const column = target.column ?? 'user_id'
      // `count` returns the number of rows actually deleted, which lets us
      // detect silent RLS failures (request succeeds but 0 rows modified).
      const { error: deleteError, count } = await supabase
        .from(target.table)
        .delete({ count: 'exact' })
        .eq(column, userId)

      const entry: DeleteAccountAuditEntry = {
        table: target.table,
        column,
        rowsDeleted: count ?? 0,
      }

      if (deleteError) {
        entry.error = deleteError.message
        failedDeletes.push(entry)
        console.error(
          `[delete-account] HARD_FAIL ${target.table}/${column}: ${deleteError.message}`,
        )
      } else {
        if (entry.rowsDeleted === 0) {
          // Zero-row deletes aren't always wrong (user may have no data in that
          // table), but they're worth logging so silent RLS holes surface.
          console.warn(
            `[delete-account] zero_rows ${target.table}/${column}`,
          )
        } else {
          console.log(
            `[delete-account] deleted ${entry.rowsDeleted} from ${target.table}`,
          )
        }
      }
      audit.push(entry)
    }

    if (failedDeletes.length > 0) {
      return new Response(
        JSON.stringify({
          error: 'Some user data could not be deleted. Please retry shortly.',
          failedTables: failedDeletes.map((e) => e.table),
          audit,
        }),
        {
          status: 500,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        },
      )
    }

    const { error: deleteAuthError } = await supabase.auth.admin.deleteUser(userId)
    if (deleteAuthError) {
      console.error(
        `[delete-account] HARD_FAIL auth.users: ${deleteAuthError.message}`,
      )
      return new Response(
        JSON.stringify({
          error: 'Failed to delete auth user',
          audit,
        }),
        {
          status: 500,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        },
      )
    }

    console.log(
      `[delete-account] success userId=${userId} tables=${audit.length} totalRows=${
        audit.reduce((sum, e) => sum + e.rowsDeleted, 0)
      }`,
    )

    return new Response(
      JSON.stringify({
        success: true,
        reason,
        feedback,
        deletedTables: audit.length,
      }),
      {
        status: 200,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      },
    )
  } catch (e) {
    const message = e instanceof Error ? e.message : String(e)
    console.error(`[delete-account] Unexpected error: ${message}`)
    return new Response(
      JSON.stringify({ error: 'Unexpected error' }),
      {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      },
    )
  }
})
