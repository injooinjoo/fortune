# Delete Account Controlled Write Smoke — 20260611021250

- Verdict: **FAIL**
- Supabase host: hayjukwfcsdmppairazc.supabase.co
- Controlled test email: ondo-delete-smoke-20260611021250@example.com
- User ID: f10afa4c-42cc-44c2-a34a-5ff9b7648ddd
- Started: 2026-06-11T02:12:50.676Z
- Finished: 2026-06-11T02:12:55.046Z

## Evidence JSON

```json
{
  "runId": "20260611021250",
  "email": "ondo-delete-smoke-20260611021250@example.com",
  "startedAt": "2026-06-11T02:12:50.676Z",
  "urlHost": "hayjukwfcsdmppairazc.supabase.co",
  "steps": [
    {
      "step": "auth.admin.createUser",
      "ok": true,
      "userId": "f10afa4c-42cc-44c2-a34a-5ff9b7648ddd"
    },
    {
      "step": "auth.signInWithPassword",
      "ok": true,
      "tokenPresent": true
    },
    {
      "step": "seed.token_balance",
      "ok": true
    }
  ],
  "userId": "f10afa4c-42cc-44c2-a34a-5ff9b7648ddd",
  "seededStorage": [
    {
      "bucket": "palm-reading-images",
      "objectPath": "f10afa4c-42cc-44c2-a34a-5ff9b7648ddd/smoke-20260611021250.png"
    },
    {
      "bucket": "poster-guide-images",
      "objectPath": "f10afa4c-42cc-44c2-a34a-5ff9b7648ddd/smoke-20260611021250.png"
    },
    {
      "bucket": "past-life-portraits",
      "objectPath": "f10afa4c-42cc-44c2-a34a-5ff9b7648ddd/smoke-20260611021250.png"
    },
    {
      "bucket": "talisman-images",
      "objectPath": "f10afa4c-42cc-44c2-a34a-5ff9b7648ddd/smoke-20260611021250.png"
    },
    {
      "bucket": "yearly-encounter-images",
      "objectPath": "f10afa4c-42cc-44c2-a34a-5ff9b7648ddd/smoke-20260611021250.png"
    },
    {
      "bucket": "friend-avatars",
      "objectPath": "f10afa4c-42cc-44c2-a34a-5ff9b7648ddd/smoke-20260611021250.png"
    },
    {
      "bucket": "character-audio-messages",
      "objectPath": "users/f10afa4c-42cc-44c2-a34a-5ff9b7648ddd/smoke-20260611021250.m4a"
    }
  ],
  "before": {
    "token_balance": {
      "count": 1,
      "error": null
    },
    "storage": {
      "palm-reading-images": {
        "count": 1,
        "error": null
      },
      "poster-guide-images": {
        "count": 1,
        "error": null
      },
      "past-life-portraits": {
        "count": 1,
        "error": null
      },
      "talisman-images": {
        "count": 1,
        "error": null
      },
      "yearly-encounter-images": {
        "count": 1,
        "error": null
      },
      "friend-avatars": {
        "count": 1,
        "error": null
      },
      "character-audio-messages": {
        "count": 1,
        "error": null
      }
    }
  },
  "deleteAccountResponse": {
    "status": 500,
    "ok": false,
    "body": {
      "error": "Some user data could not be deleted. Please retry shortly.",
      "failedTables": [
        "trend_comment_likes",
        "trend_likes",
        "trend_comments",
        "user_psychology_results",
        "user_worldcup_results",
        "user_balance_results",
        "face_reading_mission_progress",
        "face_reading_conditions",
        "face_reading_history",
        "secondary_profiles"
      ],
      "audit": [
        {
          "table": "trend_comment_likes",
          "column": "user_id",
          "rowsDeleted": 0,
          "error": "relation \"public.trend_comment_likes\" does not exist"
        },
        {
          "table": "trend_likes",
          "column": "user_id",
          "rowsDeleted": 0,
          "error": "relation \"public.trend_likes\" does not exist"
        },
        {
          "table": "trend_comments",
          "column": "user_id",
          "rowsDeleted": 0,
          "error": "relation \"public.trend_comments\" does not exist"
        },
        {
          "table": "user_psychology_results",
          "column": "user_id",
          "rowsDeleted": 0,
          "error": "relation \"public.user_psychology_results\" does not exist"
        },
        {
          "table": "user_worldcup_results",
          "column": "user_id",
          "rowsDeleted": 0,
          "error": "relation \"public.user_worldcup_results\" does not exist"
        },
        {
          "table": "user_balance_results",
          "column": "user_id",
          "rowsDeleted": 0,
          "error": "relation \"public.user_balance_results\" does not exist"
        },
        {
          "table": "face_reading_mission_progress",
          "column": "user_id",
          "rowsDeleted": 0,
          "error": "relation \"public.face_reading_mission_progress\" does not exist"
        },
        {
          "table": "face_reading_conditions",
          "column": "user_id",
          "rowsDeleted": 0,
          "error": "relation \"public.face_reading_conditions\" does not exist"
        },
        {
          "table": "face_reading_history",
          "column": "user_id",
          "rowsDeleted": 0,
          "error": "relation \"public.face_reading_history\" does not exist"
        },
        {
          "table": "user_health_surveys",
          "column": "user_id",
          "rowsDeleted": 0
        },
        {
          "table": "user_saju",
          "column": "user_id",
          "rowsDeleted": 0
        },
        {
          "table": "fortune_history",
          "column": "user_id",
          "rowsDeleted": 0
        },
        {
          "table": "fortune_cache",
          "column": "user_id",
          "rowsDeleted": 0
        },
        {
          "table": "fortune_stories",
          "column": "user_id",
          "rowsDeleted": 0
        },
        {
          "table": "talisman_user_cache",
          "column": "user_id",
          "rowsDeleted": 0
        },
        {
          "table": "pets",
          "column": "user_id",
          "rowsDeleted": 0
        },
        {
          "table": "secondary_profiles",
          "column": "user_id",
          "rowsDeleted": 0,
          "error": "column secondary_profiles.user_id does not exist"
        },
        {
          "table": "token_balance",
          "column": "user_id",
          "rowsDeleted": 1
        },
        {
          "table": "subscriptions",
          "column": "user_id",
          "rowsDeleted": 0
        },
        {
          "table": "user_statistics",
          "column": "user_id",
          "rowsDeleted": 0
        },
        {
          "table": "chat_conversations",
          "column": "user_id",
          "rowsDeleted": 0
        },
        {
          "table": "character_conversations",
          "column": "user_id",
          "rowsDeleted": 0
        },
        {
          "table": "fcm_tokens",
          "column": "user_id",
          "rowsDeleted": 0
        },
        {
          "table": "user_notification_preferences",
          "column": "user_id",
          "rowsDeleted": 0
        },
        {
          "table": "llm_usage_logs",
          "column": "user_id",
          "rowsDeleted": 0
        },
        {
          "table": "message_reports",
          "column": "reporter_id",
          "rowsDeleted": 0
        },
        {
          "table": "character_blocks",
          "column": "user_id",
          "rowsDeleted": 0
        },
        {
          "table": "user_profiles",
          "column": "id",
          "rowsDeleted": 1
        }
      ]
    }
  },
  "verdict": "FAIL",
  "error": "delete-account returned 500",
  "cleanupAttempted": true,
  "cleanupError": null,
  "finishedAt": "2026-06-11T02:12:55.046Z"
}
```
