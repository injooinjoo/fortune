#!/usr/bin/env bash
set -euo pipefail

# No-auth regression smoke for fortune-tarot.
# Expected after remediation: a valid tarot payload is rejected before validation/LLM.
# Required env:
#   SUPABASE_FUNCTIONS_URL=https://<project>.supabase.co/functions/v1
# or
#   SUPABASE_URL=https://<project>.supabase.co

BASE_URL="${SUPABASE_FUNCTIONS_URL:-}"
if [[ -z "$BASE_URL" && -n "${SUPABASE_URL:-}" ]]; then
  BASE_URL="${SUPABASE_URL%/}/functions/v1"
fi

if [[ -z "$BASE_URL" ]]; then
  echo "SKIP: set SUPABASE_FUNCTIONS_URL or SUPABASE_URL" >&2
  exit 77
fi

payload='{
  "question": "오늘 중요한 결정을 어떻게 보면 좋을까요?",
  "spreadType": "threeCard",
  "deckId": "rider_waite",
  "selectedCards": [
    {"index": 0, "isReversed": false},
    {"index": 17, "isReversed": true},
    {"index": 21, "isReversed": false}
  ]
}'

response_file="$(mktemp)"
trap 'rm -f "$response_file"' EXIT

status="$({
  curl -sS -o "$response_file" -w '%{http_code}' \
    -X POST "${BASE_URL%/}/fortune-tarot" \
    -H 'Content-Type: application/json' \
    --data "$payload"
} 2>&1)"

if [[ "$status" != "401" && "$status" != "403" ]]; then
  echo "FAIL: expected no-auth tarot to return 401/403, got $status" >&2
  echo "Body:" >&2
  python3 - <<'PY' "$response_file" >&2
import json, pathlib, sys
text = pathlib.Path(sys.argv[1]).read_text()
try:
    print(json.dumps(json.loads(text), ensure_ascii=False, indent=2))
except Exception:
    print(text[:1000])
PY
  exit 1
fi

if ! python3 - <<'PY' "$response_file"
import json, pathlib, sys
body = json.loads(pathlib.Path(sys.argv[1]).read_text() or '{}')
text = json.dumps(body, ensure_ascii=False)
if 'auth_required' not in text and '로그인' not in text and 'Missing authorization' not in text and 'Invalid token' not in text:
    raise SystemExit(1)
PY
then
  echo "FAIL: response did not contain an auth-required marker" >&2
  cat "$response_file" >&2
  exit 1
fi

echo "PASS: no-auth fortune-tarot blocked with HTTP $status"
