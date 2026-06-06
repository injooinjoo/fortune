import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { authenticateUser } from "../_shared/auth.ts";
import { corsHeaders } from "../_shared/cors.ts";

const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

const supabase = createClient(supabaseUrl, supabaseServiceKey, {
  auth: { autoRefreshToken: false, persistSession: false },
});

interface DeleteAccountAuditEntry {
  table: string;
  column: string;
  rowsDeleted: number;
  error?: string;
}

interface DeleteAccountStorageAuditEntry {
  bucket: string;
  prefix: string;
  removed: number;
  error?: string;
}

// Tables that MUST be deleted for App Store 5.1.1(v) compliance. If a row
// cannot be removed, the auth user is NOT deleted so the request can be
// retried cleanly on the next attempt.
const DELETE_TARGETS: Array<{ table: string; column?: string }> = [
  { table: "trend_comment_likes" },
  { table: "trend_likes" },
  { table: "trend_comments" },
  { table: "user_psychology_results" },
  { table: "user_worldcup_results" },
  { table: "user_balance_results" },
  { table: "face_reading_mission_progress" },
  { table: "face_reading_conditions" },
  { table: "face_reading_history" },
  { table: "user_health_surveys" },
  { table: "user_saju" },
  { table: "fortune_history" },
  { table: "fortune_cache" },
  { table: "fortune_stories" },
  { table: "talisman_user_cache" },
  { table: "pets" },
  { table: "secondary_profiles" },
  { table: "token_balance" },
  { table: "subscriptions" },
  { table: "user_statistics" },
  // 채팅/대화 상태 (CASCADE 는 이미 걸려 있지만 audit-row count 확보 위해 명시)
  { table: "chat_conversations" },
  { table: "character_conversations" },
  // 푸시 토큰 + 알림 설정 (W12)
  { table: "fcm_tokens" },
  { table: "user_notification_preferences" },
  // LLM usage logs — user_id FK 없음, CASCADE 의존 불가. 명시 삭제 필수 (W12).
  { table: "llm_usage_logs" },
  // UGC moderation 데이터 — 사용자가 신고한 내역 + 차단한 캐릭터는
  // 본인 데이터이므로 계정 삭제 시 함께 제거 (5.1.1(v) + GDPR 삭제권).
  { table: "message_reports", column: "reporter_id" },
  { table: "character_blocks" },
  { table: "user_profiles", column: "id" },
];

const USER_STORAGE_TARGETS: Array<
  { bucket: string; prefix: (userId: string) => string }
> = [
  { bucket: "profile-images", prefix: (userId) => userId },
  { bucket: "palm-reading-images", prefix: (userId) => userId },
  { bucket: "poster-guide-images", prefix: (userId) => userId },
  { bucket: "past-life-portraits", prefix: (userId) => userId },
  { bucket: "talisman-images", prefix: (userId) => userId },
  { bucket: "yearly-encounter-images", prefix: (userId) => userId },
  { bucket: "friend-avatars", prefix: (userId) => userId },
  { bucket: "character-audio-messages", prefix: (userId) => userId },
];

async function listStoragePathsRecursively(
  supabaseClient: typeof supabase,
  bucket: string,
  prefix: string,
): Promise<string[]> {
  const { data: entries, error } = await supabaseClient.storage
    .from(bucket)
    .list(prefix, { limit: 1000 });
  if (error) {
    throw new Error(error.message);
  }
  if (!entries || entries.length === 0) {
    return [];
  }

  const paths: string[] = [];
  for (const entry of entries) {
    const path = `${prefix}/${entry.name}`;
    if (entry.id === null) {
      paths.push(
        ...await listStoragePathsRecursively(supabaseClient, bucket, path),
      );
    } else {
      paths.push(path);
    }
  }
  return paths;
}

// Storage 버킷에서 사용자 개인정보/생성 결과물을 일괄 purge.
// profile-images 는 없는 환경도 있어서 warn-only 로 처리하고, 실제 UGC/result
// 버킷은 userId prefix 기준으로 재귀 삭제한다.
async function purgeUserStorage(
  supabaseClient: typeof supabase,
  userId: string,
): Promise<DeleteAccountStorageAuditEntry[]> {
  const audit: DeleteAccountStorageAuditEntry[] = [];

  for (const target of USER_STORAGE_TARGETS) {
    const prefix = target.prefix(userId);
    try {
      const paths = await listStoragePathsRecursively(
        supabaseClient,
        target.bucket,
        prefix,
      );
      if (paths.length === 0) {
        audit.push({ bucket: target.bucket, prefix, removed: 0 });
        continue;
      }
      const { error: removeError } = await supabaseClient.storage
        .from(target.bucket)
        .remove(paths);
      if (removeError) {
        audit.push({
          bucket: target.bucket,
          prefix,
          removed: 0,
          error: removeError.message,
        });
      } else {
        audit.push({ bucket: target.bucket, prefix, removed: paths.length });
      }
    } catch (e) {
      audit.push({
        bucket: target.bucket,
        prefix,
        removed: 0,
        error: e instanceof Error ? e.message : String(e),
      });
    }
  }

  return audit;
}

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response(null, { headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return new Response(
      JSON.stringify({ error: "Method not allowed" }),
      {
        status: 405,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      },
    );
  }

  const { user, error } = await authenticateUser(req);
  if (error || !user) {
    return error!;
  }

  const payload = await req.json().catch(() => ({}));
  const reason = payload?.reason ?? null;
  const feedback = payload?.feedback ?? null;

  const userId = user.id;
  console.log(`[delete-account] Request: userId=${userId}, reason=${reason}`);

  const audit: DeleteAccountAuditEntry[] = [];
  const failedDeletes: DeleteAccountAuditEntry[] = [];

  try {
    for (const target of DELETE_TARGETS) {
      const column = target.column ?? "user_id";
      // `count` returns the number of rows actually deleted, which lets us
      // detect silent RLS failures (request succeeds but 0 rows modified).
      const { error: deleteError, count } = await supabase
        .from(target.table)
        .delete({ count: "exact" })
        .eq(column, userId);

      const entry: DeleteAccountAuditEntry = {
        table: target.table,
        column,
        rowsDeleted: count ?? 0,
      };

      if (deleteError) {
        entry.error = deleteError.message;
        failedDeletes.push(entry);
        console.error(
          `[delete-account] HARD_FAIL ${target.table}/${column}: ${deleteError.message}`,
        );
      } else {
        if (entry.rowsDeleted === 0) {
          // Zero-row deletes aren't always wrong (user may have no data in that
          // table), but they're worth logging so silent RLS holes surface.
          console.warn(
            `[delete-account] zero_rows ${target.table}/${column}`,
          );
        } else {
          console.log(
            `[delete-account] deleted ${entry.rowsDeleted} from ${target.table}`,
          );
        }
      }
      audit.push(entry);
    }

    if (failedDeletes.length > 0) {
      return new Response(
        JSON.stringify({
          error: "Some user data could not be deleted. Please retry shortly.",
          failedTables: failedDeletes.map((e) => e.table),
          audit,
        }),
        {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    // Storage 버킷 purge — 테이블 삭제와 동일하게 실패 시 auth.users 삭제를
    // 중단하고 재시도 가능하게 한다.
    const storageAudit = await purgeUserStorage(supabase, userId);
    const failedStorage = storageAudit.filter((entry) => {
      // profile-images is optional in some deployments; all other user-owned
      // buckets must purge before auth.users is deleted.
      return entry.error && entry.bucket !== "profile-images";
    });
    if (failedStorage.length > 0) {
      console.error(
        `[delete-account] HARD_FAIL storage: ${
          failedStorage
            .map((entry) => `${entry.bucket}/${entry.prefix}: ${entry.error}`)
            .join("; ")
        }`,
      );
      return new Response(
        JSON.stringify({
          error: "Some user storage could not be purged. Please retry shortly.",
          failedStorage: failedStorage.map((entry) => entry.bucket),
          audit,
          storageAudit,
        }),
        {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }
    console.log(
      `[delete-account] purged storage=${
        storageAudit
          .map((entry) => `${entry.bucket}:${entry.removed}`)
          .join(",")
      }`,
    );

    const { error: deleteAuthError } = await supabase.auth.admin.deleteUser(
      userId,
    );
    if (deleteAuthError) {
      console.error(
        `[delete-account] HARD_FAIL auth.users: ${deleteAuthError.message}`,
      );
      return new Response(
        JSON.stringify({
          error: "Failed to delete auth user",
          audit,
        }),
        {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    console.log(
      `[delete-account] success userId=${userId} tables=${audit.length} totalRows=${
        audit.reduce((sum, e) => sum + e.rowsDeleted, 0)
      }`,
    );

    return new Response(
      JSON.stringify({
        success: true,
        reason,
        feedback,
        deletedTables: audit.length,
      }),
      {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      },
    );
  } catch (e) {
    const message = e instanceof Error ? e.message : String(e);
    console.error(`[delete-account] Unexpected error: ${message}`);
    return new Response(
      JSON.stringify({ error: "Unexpected error" }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      },
    );
  }
});
