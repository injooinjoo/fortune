# .well-known Deployment Checklist

## Files to deploy
- `docs/deployment/well-known/apple-app-site-association`
- `docs/deployment/well-known/assetlinks.json`
- `web/.well-known/apple-app-site-association`
- `web/.well-known/assetlinks.json`

## Required hosting rules
- Serve **directly** at:
  - `https://www.zpzg.co.kr/.well-known/apple-app-site-association`
  - `https://zpzg.co.kr/.well-known/apple-app-site-association`
  - `https://www.zpzg.co.kr/.well-known/assetlinks.json`
  - `https://zpzg.co.kr/.well-known/assetlinks.json`
- Return `HTTP 200` (no `301/302/307/308` redirect).
- Serve `Content-Type: application/json`.

## Android fingerprint note
- `assetlinks.json` currently contains the upload keystore fingerprint from local signing:
  - `E7:58:39:4F:F8:58:86:B4:E8:62:6C:85:A5:8D:DA:82:C6:CD:47:FE:C8:22:F4:7D:41:69:61:21:CB:9E:3E:EF`
- If Google Play App Signing is enabled, replace this with the **App Signing certificate** SHA-256 from Play Console.

## Vercel Dashboard exact action steps (production)
1. Vercel 로그인 후 프로젝트 페이지로 이동한다.
2. 해당 프로젝트를 열고, 좌측 메뉴에서 `Settings` 또는 프로젝트 상단 탭의 `Settings`로 이동한다.
3. `Domains` 메뉴를 연다.
   - `zpzg.co.kr` 항목이 있으면 행 우측의 점 세 개 메뉴(`...`)를 클릭한다.
   - 메뉴에 `Manage Domain` / `Edit` / `Redirects` 류가 보이면 **도메인 리다이렉트 설정**으로 진입한다.
4. `zpzg.co.kr`가 `www.zpzg.co.kr`로 리다이렉트되고 있다면 삭제한다.
   - `Redirects` 목록에서 Source가 `https://zpzg.co.kr/:path*` 또는 `/`인 항목을 찾는다.
   - Source/Destination 확인 후 `Delete` 처리한다.
5. 리다이렉트가 `Domains` 탭 자체에 `Redirects to https://www.zpzg.co.kr` 같은 형태로 표시되는 경우:
   - 행 우측의 `x` 또는 `Remove` 버튼을 눌러 제거한다.
6. `www.zpzg.co.kr`은 유지하고, `zpzg.co.kr`은 리다이렉트 없이 직접 접근되도록 둔다.
7. 저장 후 **즉시 테스트 URL로 재확인**한다.
   - `https://zpzg.co.kr/.well-known/apple-app-site-association`
   - `https://zpzg.co.kr/.well-known/assetlinks.json`
8. 확인이 되지 않을 경우:
   - `Settings > Redirects`에서 새로 추가된 규칙(도메인/와일드카드)을 다시 검색해 제거한다.
   - 도메인 자체가 `www`으로 강제되는 별도 팀/프로젝트 설정이 없는지 `Domains` 목록 전체를 마지막으로 점검한다.

## Verification commands
```bash
# One-shot (recommended)
./scripts/verify_deep_links.sh

# Manual raw checks
curl -sSL -D - https://zpzg.co.kr/.well-known/apple-app-site-association -o /tmp/zpzg-aasa.out
curl -sSL -D - https://www.zpzg.co.kr/.well-known/apple-app-site-association -o /tmp/www-aasa.out
curl -sSL -D - https://zpzg.co.kr/.well-known/assetlinks.json -o /tmp/zpzg-assetlinks.out
curl -sSL -D - https://www.zpzg.co.kr/.well-known/assetlinks.json -o /tmp/www-assetlinks.out
```

Check:
- No redirect response for both hosts.
- Final response status is `200`.
- `assetlinks.json` has real SHA-256 fingerprint (no placeholder).
- No Vercel/hosting redirect from apex to www: configure your production domain so `zpzg.co.kr` serves the same files directly.

## Post-deploy auto checks (cron / daily)

### 1) Cron (Linux/macOS)
```bash
# 로그 디렉터리 준비
mkdir -p logs
PROJECT_DIR="/Users/jacobmac/Desktop/Dev/fortune"  # 운영 저장소 경로

# (선택) 절대 경로가 바뀐다면 아래 명령으로 실시간 경로 추출
# PROJECT_DIR="$(git rev-parse --show-toplevel)"

# 사용자 crontab에 10분마다 점검 등록
(crontab -l 2>/dev/null; echo "*/10 * * * * cd ${PROJECT_DIR} && ./scripts/verify_deep_links.sh >> logs/deep-link-monitor.log 2>&1") | crontab -

# 매일 09:10에 한 번 더 실행되는 일일 체크(요약 전송용으로 별도 로그)
(crontab -l 2>/dev/null; echo "10 9 * * * cd ${PROJECT_DIR} && ./scripts/verify_deep_links.sh >> logs/deep-link-monitor-daily.log 2>&1") | crontab -
```

### 2) 즉시 실패 시 Slack/메일 연동 예시(원하면)
- `scripts/verify_deep_links.sh` 실패 시 exit code가 `1`이므로 실패 탐지 스크립트에서 `||` 다음 동작으로 알림을 붙인다.
  - 예: `./scripts/verify_deep_links.sh || ./scripts/notify-deep-link-fail.sh`

### 3) 매일 점검 리포트(휴리스틱)
```bash
for d in zpzg.co.kr www.zpzg.co.kr; do
  echo "=== $d ==="
  ./scripts/verify_deep_links.sh "$d"
done | tee logs/daily-deep-link-$(date +%F).log
```

## Pro 없이 처리해야 할 때 (Vercel REST API)

UI가 막히거나 Pro 권한이 안 보일 때는 API 토큰으로 `zpzg.co.kr` 리다이렉트를 제거할 수 있다.

1) Vercel 토큰 준비
- `https://vercel.com/account/tokens`에서 토큰 생성
- 터미널에 적용
  - `export VERCEL_TOKEN=...`
  - `export VERCEL_PROJECT=zpzg-landing`
  - (팀 프로젝트면) `export VERCEL_TEAM_ID=team_xxx` 추가

2) 현재 도메인 설정 확인
```bash
curl -sS \
  -H "Authorization: Bearer ${VERCEL_TOKEN}" \
  "https://api.vercel.com/v9/projects/${VERCEL_PROJECT}/domains${VERCEL_TEAM_ID:+?teamId=${VERCEL_TEAM_ID}}" \
  | jq '.domains[] | {name, redirect, redirectStatusCode}'
```

3) `zpzg.co.kr`의 redirect 제거
```bash
curl -sS -X PATCH \
  -H "Authorization: Bearer ${VERCEL_TOKEN}" \
  -H "Content-Type: application/json" \
  "https://api.vercel.com/v9/projects/${VERCEL_PROJECT}/domains/zpzg.co.kr${VERCEL_TEAM_ID:+?teamId=${VERCEL_TEAM_ID}}" \
  -d '{"redirect":null,"redirectStatusCode":null,"gitBranch":null}'
```

4) 바로 검증
```bash
./scripts/verify_deep_links.sh
```

참고: `jq`가 없으면 `brew install jq` 후 진행.

`scripts/remove_vercel_apex_redirect.sh`를 만들면 팀/도메인만 바꿔 재사용 가능.
