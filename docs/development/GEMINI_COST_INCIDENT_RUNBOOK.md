# Gemini Cost Incident Runbook

Last updated: 2026-03-09

## Purpose

Use this runbook when GCP spend spikes on `generativelanguage.googleapis.com` or when a Gemini API key is suspected to be leaked.

## Immediate containment

1. Check current project status.

```bash
gcloud services list --enabled --project=fortune2-463710 | rg generativelanguage
gcloud services api-keys list --project=fortune2-463710
```

2. Disable Gemini immediately if spend is still rising.

```bash
gcloud services disable generativelanguage.googleapis.com --project=fortune2-463710
supabase secrets set GEMINI_EMERGENCY_DISABLE=true --project-ref hayjukwfcsdmppairazc
```

3. Snapshot usage before changing keys.

```bash
ACCESS_TOKEN=$(gcloud auth print-access-token)
START=$(date -u -d '30 days ago' +%Y-%m-%dT%H:%M:%SZ)
END=$(date -u +%Y-%m-%dT%H:%M:%SZ)

curl -sG -H "Authorization: Bearer $ACCESS_TOKEN" \
  "https://monitoring.googleapis.com/v3/projects/fortune2-463710/timeSeries" \
  --data-urlencode 'filter=metric.type="serviceruntime.googleapis.com/api/request_count" AND resource.type="consumed_api" AND resource.labels.service="generativelanguage.googleapis.com"' \
  --data-urlencode "interval.startTime=$START" \
  --data-urlencode "interval.endTime=$END" \
  --data-urlencode 'aggregation.alignmentPeriod=86400s' \
  --data-urlencode 'aggregation.perSeriesAligner=ALIGN_SUM' \
  --data-urlencode 'view=FULL'
```

## Key rotation

1. Create a replacement Gemini key.

```bash
gcloud services api-keys create \
  --project=fortune2-463710 \
  --display-name="fortune-rotated-20260309" \
  --api-target=service=generativelanguage.googleapis.com \
  --format=json
```

2. Update Supabase secrets.

```bash
supabase secrets set \
  GEMINI_API_KEY="<new-key>" \
  GEMINI_EMERGENCY_DISABLE=false \
  GEMINI_DAILY_REQUEST_LIMIT=2500 \
  GEMINI_GUARD_WINDOW_HOURS=24 \
  LLM_USAGE_GUARD_CACHE_TTL_MS=60000 \
  --project-ref hayjukwfcsdmppairazc
```

3. Delete or revoke keys that are not part of the approved inventory.

```bash
gcloud services api-keys delete <key-id> --project=fortune2-463710
```

Approved inventory should be a short allowlist with an owner and purpose per key.

## Deployment

Redeploy every function that imports `_shared/llm` and every function that directly calls Gemini.

Minimum set for the 2026-03-09 incident fix:

```bash
supabase functions deploy free-chat --project-ref hayjukwfcsdmppairazc
supabase functions deploy fortune-yearly-encounter --project-ref hayjukwfcsdmppairazc
supabase functions deploy fortune-past-life --project-ref hayjukwfcsdmppairazc
supabase functions deploy generate-fashion-image --project-ref hayjukwfcsdmppairazc
supabase functions deploy generate-talisman --project-ref hayjukwfcsdmppairazc
supabase functions deploy generate-character-proactive-image --project-ref hayjukwfcsdmppairazc
```

If shared LLM files changed, the safer option is to deploy all Gemini-backed functions.

## Re-enable service

Only re-enable Gemini after:

1. new key is stored in Supabase
2. guard code is deployed
3. old keys are removed

```bash
gcloud services enable generativelanguage.googleapis.com --project=fortune2-463710
```

## Verification

1. Check API state and key inventory.

```bash
gcloud services list --enabled --project=fortune2-463710 | rg generativelanguage
gcloud services api-keys list --project=fortune2-463710
```

2. Confirm safety guard secrets.

```bash
supabase secrets list --project-ref hayjukwfcsdmppairazc | rg 'GEMINI_|LLM_USAGE_GUARD'
```

3. Inspect recent usage logs.

```bash
gcloud logging read \
  'logName="projects/fortune2-463710/logs/fortune-api-usage" OR jsonPayload.eventType="llm_request_blocked"' \
  --project=fortune2-463710 \
  --limit=100 \
  --freshness=7d
```

## Recurrence prevention

- Keep only one production Gemini key.
- Do not create ad hoc Gemini keys in the production GCP project.
- Treat `GEMINI_DAILY_REQUEST_LIMIT` as required for production.
- Keep `GCP_LOGGING_ENABLED=true` and review blocked-request logs weekly.
