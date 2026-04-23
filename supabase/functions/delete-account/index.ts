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
  // 채팅/대화 상태 (CASCADE 는 이미 걸려 있지만 audit-row count 확보 위해 명시)
  { table: 'chat_conversations' },
  { table: 'character_conversations' },
  // 푸시 토큰 + 알림 설정 (W12)
  { table: 'fcm_tokens' },
  { table: 'user_notification_preferences' },
  // LLM usage logs — user_id FK 없음, CASCADE 의존 불가. 명시 삭제 필수 (W12).
  { table: 'llm_usage_logs' },
  // UGC moderation 데이터 — 사용자가 신고한 내역 + 차단한 캐릭터는
  // 본인 데이터이므로 계정 삭제 시 함께 제거 (5.1.1(v) + GDPR 삭제권).
  { table: 'message_reports', column: 'reporter_id' },
  { table: 'character_blocks' },
  { table: 'user_profiles', column: 'id' },
]

// Storage 버킷에서 사용자 개인정보(프로필 이미지) 일괄 purge.
// `profile-images` 버킷은 public 이며 경로 prefix 가 `<userId>/`.
// supabase.storage API 로 userId 로 시작하는 객체 목록 수집 후 remove. (W8)
async function purgeUserStorage(
  supabase: ReturnType<typeof createClient>,
  userId: string,
): Promise<{ bucket: string; removed: number; error?: string }> {
  const bucket = 'profile-images'
  try {
    const { data: listed, error: listError } = await supabase.storage
      .from(bucket)
      .list(userId, { limit: 1000 })
    if (listError) {
      return { bucket, removed: 0, error: listError.message }
    }
    if (!listed || listed.length === 0) {
      return { bucket, removed: 0 }
    }
    const paths = listed.map((f) => `${userId}/${f.name}`)
    const { error: removeError } = await supabase.storage.from(bucket).remove(paths)
    if (removeError) {
      return { bucket, removed: 0, error: removeError.message }
    }
    return { bucket, removed: paths.length }
  } catch (e) {
    return { bucket, removed: 0, error: e instanceof Error ? e.message : String(e) }
  }
}

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

    // Storage 버킷 purge — 테이블 삭제와 동일하게 실패 시 auth.users 삭제를
    // 중단하고 재시도 가능하게 한다.
    const storageResult = await purgeUserStorage(supabase, userId)
    if (storageResult.error) {
      console.error(
        `[delete-account] HARD_FAIL storage/${storageResult.bucket}: ${storageResult.error}`,
      )
      return new Response(
        JSON.stringify({
          error: 'Some user storage could not be purged. Please retry shortly.',
          failedStorage: storageResult.bucket,
          audit,
        }),
        {
          status: 500,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        },
      )
    }
    console.log(
      `[delete-account] purged ${storageResult.removed} from storage/${storageResult.bucket}`,
    )

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
