# Apple Sign In Key 폐기/재발급 절차 (2026-05-05)

## 배경

`scripts/generate_apple_secret.py` 의 이전 버전에 Apple private key 본문이 하드코딩되어 git 히스토리에 들어갔다. `/ultrareview` 가 P0 (보안 사고) 로 플래그.

**KEY_ID `3A6YZN2YW8`** 는 노출됨. 즉시 폐기 필요.

## 조치 (사용자 작업, 즉시)

### 1) Apple Developer console 에서 키 폐기
1. https://developer.apple.com/account/resources/authkeys/list 접속
2. KEY_ID `3A6YZN2YW8` 찾기 → Revoke
3. 폐기 사유: "leaked private key in source repository"

### 2) 새 키 발급
1. 같은 페이지 → `+` (Create a key)
2. Name: "Fortune Apple Sign In - 2026"
3. Service: **Sign in with Apple** 체크 → Configure → Primary App ID 선택
4. Continue → Register → **Download .p8** (재다운로드 불가, 안전하게 보관)
5. 새 KEY_ID 메모

### 3) 환경변수로 주입
로컬 (개발자 본인) 에서만 키 사용. git 추적 금지.

`~/.zshrc` 또는 프로젝트 `.env.local` (gitignored) 에:

```bash
export APPLE_TEAM_ID=5F7CN7Y54D
export APPLE_SERVICE_ID=com.beyond.fortune.service
export APPLE_KEY_ID=<신규 KEY_ID>
export APPLE_PRIVATE_KEY="$(cat /path/to/AuthKey_<KEY_ID>.p8)"
```

### 4) Supabase Auth provider 업데이트
1. `python3 scripts/generate_apple_secret.py` 실행 → client_secret JWT 출력
2. Supabase Dashboard → Authentication → Providers → Apple → "Secret Key (for OAuth)" 에 붙여넣기
3. Save

### 5) (선택) git history 정리
이미 폐기된 키이므로 history 에 남아도 위험은 0 이지만, 깔끔히 지우려면:

```bash
# BFG repo cleaner 사용 (별도 설치)
git clone --mirror https://github.com/injooinjoo/fortune.git
cd fortune.git
java -jar bfg.jar --replace-text patterns.txt
git reflog expire --expire=now --all && git gc --prune=now --aggressive
git push --force
```

⚠️ force-push 는 모든 협업자 fetch/rebase 필요. 솔로 운영이면 즉시 가능, 협업이면 주의.

## 향후 가드

- `.gitignore` 에 `.env.local`, `*.p8`, `AuthKey_*.p8` 추가 (이번 PR 에 포함).
- Pre-commit hook 으로 `BEGIN PRIVATE KEY` / `BEGIN RSA PRIVATE KEY` 패턴 감지 → 차단 (TODO Slice 3).
- TruffleHog / GitGuardian 같은 secret scanner CI 도입 권장.
