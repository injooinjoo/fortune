# Delete Account Controlled Write Smoke — 20260611021447

- Verdict: **PASS**
- Supabase host: hayjukwfcsdmppairazc.supabase.co
- Controlled test email: ondo-delete-smoke-20260611021447@example.com
- User ID: 5f083c4e-5576-4b92-99bd-a9ae5e529b61
- Started: 2026-06-11T02:14:47.296Z
- Finished: 2026-06-11T02:14:52.390Z

## Evidence JSON

```json
{
  "runId": "20260611021447",
  "email": "ondo-delete-smoke-20260611021447@example.com",
  "startedAt": "2026-06-11T02:14:47.296Z",
  "urlHost": "hayjukwfcsdmppairazc.supabase.co",
  "steps": [
    {
      "step": "auth.admin.createUser",
      "ok": true,
      "userId": "5f083c4e-5576-4b92-99bd-a9ae5e529b61"
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
  "userId": "5f083c4e-5576-4b92-99bd-a9ae5e529b61",
  "seededStorage": [
    {
      "bucket": "palm-reading-images",
      "objectPath": "5f083c4e-5576-4b92-99bd-a9ae5e529b61/smoke-20260611021447.png"
    },
    {
      "bucket": "poster-guide-images",
      "objectPath": "5f083c4e-5576-4b92-99bd-a9ae5e529b61/smoke-20260611021447.png"
    },
    {
      "bucket": "past-life-portraits",
      "objectPath": "5f083c4e-5576-4b92-99bd-a9ae5e529b61/smoke-20260611021447.png"
    },
    {
      "bucket": "talisman-images",
      "objectPath": "5f083c4e-5576-4b92-99bd-a9ae5e529b61/smoke-20260611021447.png"
    },
    {
      "bucket": "yearly-encounter-images",
      "objectPath": "5f083c4e-5576-4b92-99bd-a9ae5e529b61/smoke-20260611021447.png"
    },
    {
      "bucket": "friend-avatars",
      "objectPath": "5f083c4e-5576-4b92-99bd-a9ae5e529b61/smoke-20260611021447.png"
    },
    {
      "bucket": "character-audio-messages",
      "objectPath": "users/5f083c4e-5576-4b92-99bd-a9ae5e529b61/smoke-20260611021447.m4a"
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
    "status": 200,
    "ok": true,
    "body": {
      "success": true,
      "reason": "controlled_security_smoke",
      "feedback": "Hermes delete-account smoke 20260611021447",
      "deletedTables": 28
    }
  },
  "after": {
    "authUser": {
      "exists": false,
      "error": "User not found"
    },
    "token_balance": {
      "count": 0,
      "error": null
    },
    "storage": {
      "palm-reading-images": {
        "count": 0,
        "error": null
      },
      "poster-guide-images": {
        "count": 0,
        "error": null
      },
      "past-life-portraits": {
        "count": 0,
        "error": null
      },
      "talisman-images": {
        "count": 0,
        "error": null
      },
      "yearly-encounter-images": {
        "count": 0,
        "error": null
      },
      "friend-avatars": {
        "count": 0,
        "error": null
      },
      "character-audio-messages": {
        "count": 0,
        "error": null
      }
    }
  },
  "verdict": "PASS",
  "finishedAt": "2026-06-11T02:14:52.390Z"
}
```
