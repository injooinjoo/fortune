# GCP API Usage Monitoring (Gemini Cost Trace)

This project now supports structured API usage logging to Google Cloud Logging from Supabase Edge Functions.

## What is logged

- Event type (`llm_usage`, `llm_usage_error`)
- Function/fortune type
- Request ID
- User ID (when available)
- Provider/model
- Prompt/completion/total tokens
- Estimated cost (USD)
- Latency
- Success/failure and error message

## Implemented paths

- Shared logger: `supabase/functions/_shared/llm/usage-logger.ts`
- GCP transport: `supabase/functions/_shared/monitoring/gcp-logging.ts`
- Added usage logging for:
  - `supabase/functions/free-chat/index.ts`
  - `supabase/functions/fortune-yearly-encounter/index.ts`

## Required secrets

Set the following Supabase Edge secrets:

```bash
supabase secrets set GCP_LOGGING_ENABLED=true
supabase secrets set GCP_LOGGING_LOG_NAME=fortune-api-usage
supabase secrets set GCP_LOGGING_SERVICE_ACCOUNT_JSON='{"type":"service_account","project_id":"...","private_key_id":"...","private_key":"-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n","client_email":"...","client_id":"...","token_uri":"https://oauth2.googleapis.com/token"}'
```

Optional fallback if `project_id` is not in JSON:

```bash
supabase secrets set GCP_PROJECT_ID=<your-gcp-project-id>
```

## IAM requirement

The service account used in `GCP_LOGGING_SERVICE_ACCOUNT_JSON` must have:

- `roles/logging.logWriter`

## How to check in GCP

Open Logs Explorer and filter:

```text
resource.type="global"
logName="projects/<PROJECT_ID>/logs/fortune-api-usage"
jsonPayload.service="fortune-edge"
```

Example filters:

```text
jsonPayload.model="gemini-2.5-flash-image"
```

```text
jsonPayload.success=false
```

```text
jsonPayload.functionName="yearly-encounter"
```

## Recommended metric/alert

Create a Log-based metric from `jsonPayload.totalTokens` and add alerting for abnormal spikes per model/function.
