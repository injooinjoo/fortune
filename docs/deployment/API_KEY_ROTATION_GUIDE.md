# API 키 재발급 및 보안 설정 가이드

**작성일**: 2025년 1월
**목적**: iOS 출시 전 노출된 API 키 재발급 및 보안 설정

---

## 🚨 CRITICAL: 즉시 재발급 필요한 API 키

다음 API 키들이 `.env` 파일에 노출되어 있어 즉시 재발급이 필요합니다:

### 1. OpenAI API Key 🔴 HIGH PRIORITY

**현재 노출된 키**: `sk-proj-cR68...`

**재발급 절차**:
1. https://platform.openai.com/api-keys 접속
2. 노출된 키 삭제 (Revoke)
3. "Create new secret key" 클릭
4. 새 키를 안전하게 저장 (1Password, Secrets Manager)
5. `.env` 파일 업데이트:
   ```env
   OPENAI_API_KEY=새로_발급받은_키
   ```

**검증**:
```bash
# 테스트 API 호출
curl https://api.openai.com/v1/models \
  -H "Authorization: Bearer $OPENAI_API_KEY"
```

---

### 2. Supabase Service Role Key 🔴 HIGH PRIORITY

**현재 노출된 키**: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`

**재발급 절차**:
1. https://app.supabase.com 접속
2. 프로젝트 선택 → Settings → API
3. "Service Role" 섹션에서 "Reset" 클릭
4. **경고**: 기존 서비스 즉시 중단될 수 있음!
5. 새 키 복사 후 안전하게 저장
6. `.env` 파일 업데이트:
   ```env
   SUPABASE_SERVICE_ROLE_KEY=새로_발급받은_키
   ```

**검증**:
```bash
# Supabase 연결 테스트
curl https://hayjukwfcsdmppairazc.supabase.co/rest/v1/ \
  -H "apikey: $SUPABASE_SERVICE_ROLE_KEY" \
  -H "Authorization: Bearer $SUPABASE_SERVICE_ROLE_KEY"
```

---

### 3. Upstash Redis Token 🔴 HIGH PRIORITY

**현재 노출된 키**: `AV2WAAIjcDE...`

**재발급 절차**:
1. https://console.upstash.com 접속
2. Redis 데이터베이스 선택
3. "Details" 탭 → "REST API" 섹션
4. "Rotate Token" 클릭
5. 새 토큰 복사 후 안전하게 저장
6. `.env` 파일 업데이트:
   ```env
   UPSTASH_REDIS_REST_TOKEN=새로_발급받은_토큰
   ```

**검증**:
```bash
# Redis 연결 테스트
curl $UPSTASH_REDIS_REST_URL/get/test \
  -H "Authorization: Bearer $UPSTASH_REDIS_REST_TOKEN"
```

---

### 4. Figma Access Token 🟡 MEDIUM PRIORITY

**현재 노출된 키**: `figd_bR2cafXD...`

**재발급 절차**:
1. https://www.figma.com/settings 접속
2. "Personal access tokens" 섹션
3. 기존 토큰 삭제
4. "Create new token" 클릭
5. 토큰 이름 입력 (예: "Fortune App Production")
6. 새 토큰 복사 후 안전하게 저장
7. `.env` 파일 업데이트:
   ```env
   FIGMA_ACCESS_TOKEN=새로_발급받은_토큰
   ```

---

### 5. Kakao REST API Key 🟡 MEDIUM PRIORITY

**현재 노출된 키**: `966326ff2bcc...`

**재발급 절차**:
1. https://developers.kakao.com 접속
2. 내 애플리케이션 선택
3. "앱 키" 탭
4. REST API 키 "재발급" 클릭
5. **경고**: 기존 API 호출 즉시 차단됨!
6. 새 키 복사 후 안전하게 저장
7. `.env` 파일 업데이트:
   ```env
   KAKAO_REST_API_KEY=새로_발급받은_키
   ```

---

### 6. Internal API Key & CRON Secret 🟡 MEDIUM PRIORITY

**현재 노출된 키**:
- INTERNAL_API_KEY: `eb68fe1fbb80...`
- CRON_SECRET: `092dd8a5b1d1...`

**새 키 생성**:
```bash
# 안전한 랜덤 키 생성 (64자)
openssl rand -hex 32
# 출력 예: a8f5b2c3d4e6f7g8h9i0j1k2l3m4n5o6p7q8r9s0t1u2v3w4x5y6z7

# 또는 Python으로 생성
python3 -c "import secrets; print(secrets.token_hex(32))"
```

**업데이트**:
```env
INTERNAL_API_KEY=새로_생성한_키_1
CRON_SECRET=새로_생성한_키_2
```

---

## 📝 Supabase Anon Key - 교체 권장

**현재 노출된 키**: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...` (anon key)

**참고**: Anon Key는 클라이언트에서 공개적으로 사용되므로 노출이 치명적이지는 않습니다.
하지만 RLS (Row Level Security) 정책이 제대로 설정되지 않은 경우 보안 위험이 있습니다.

**재발급 여부 판단**:
- ✅ RLS 정책 완벽히 설정됨 → 재발급 선택사항
- ❌ RLS 정책 미흡 → 즉시 재발급 필요

**재발급 방법**: Service Role Key와 동일 (Supabase Dashboard)

---

## 🔐 환경변수 안전 관리 방법

### 로컬 개발 환경

1. **.env 파일 사용** (현재 방식)
   ```bash
   # .env 파일에 키 저장
   OPENAI_API_KEY=새_키

   # .gitignore 확인
   cat .gitignore | grep ".env"
   ```

2. **절대 Git에 커밋하지 않기**
   ```bash
   # .env가 .gitignore에 있는지 확인
   git status | grep ".env"
   # 출력 없어야 정상
   ```

### iOS 빌드 환경

**옵션 1: Xcode 환경변수 (권장)**
1. Xcode에서 프로젝트 열기
2. Target → Build Settings → User-Defined
3. 각 API 키를 환경변수로 추가
4. Info.plist에서 `$(VARIABLE_NAME)` 형태로 참조

**옵션 2: Fastlane Secrets**
```ruby
# fastlane/.env.secret (gitignore에 포함)
OPENAI_API_KEY=새_키
SUPABASE_SERVICE_ROLE_KEY=새_키
```

**옵션 3: iOS Keychain 사용**
- flutter_secure_storage 패키지 사용
- 앱 최초 실행 시 Keychain에 저장
- 이후 Keychain에서 읽기

### CI/CD 환경 (GitHub Actions, Codemagic 등)

**GitHub Secrets 사용**:
1. Repository → Settings → Secrets and variables → Actions
2. "New repository secret" 클릭
3. 각 API 키 추가:
   - Name: `OPENAI_API_KEY`
   - Value: 새_키

**Workflow에서 사용**:
```yaml
# .github/workflows/ios-build.yml
env:
  OPENAI_API_KEY: ${{ secrets.OPENAI_API_KEY }}
  SUPABASE_SERVICE_ROLE_KEY: ${{ secrets.SUPABASE_SERVICE_ROLE_KEY }}
```

---

## ✅ API 키 재발급 체크리스트

### 즉시 수행 (출시 불가)

- [ ] **OpenAI API Key 재발급**
  - [ ] platform.openai.com에서 기존 키 삭제
  - [ ] 새 키 발급 및 안전 저장
  - [ ] `.env` 파일 업데이트
  - [ ] 연결 테스트 성공

- [ ] **Supabase Service Role Key 재발급**
  - [ ] Supabase Dashboard에서 재발급
  - [ ] `.env` 파일 업데이트
  - [ ] 연결 테스트 성공
  - [ ] Edge Functions 정상 작동 확인

- [ ] **Upstash Redis Token 재발급**
  - [ ] Upstash Console에서 재발급
  - [ ] `.env` 파일 업데이트
  - [ ] 연결 테스트 성공

### 권장 수행 (중요도 높음)

- [ ] **Figma Access Token 재발급**
- [ ] **Kakao REST API Key 재발급**
- [ ] **Internal API Key 새로 생성**
- [ ] **CRON Secret 새로 생성**

### 보안 설정

- [ ] **.env 파일이 .gitignore에 있는지 확인**
- [ ] **Git 히스토리에 키가 없는지 검색**
  ```bash
  git log -p | grep "sk-proj-\|eyJhbGciOiJIUzI1NiI"
  ```
- [ ] **1Password/LastPass 등에 백업**
- [ ] **팀원들에게 새 키 안전하게 공유**

### iOS 배포 환경

- [ ] **Xcode 환경변수 설정** (옵션)
- [ ] **Fastlane .env.secret 설정** (옵션)
- [ ] **GitHub Secrets 설정** (CI/CD 사용 시)

---

## 🚫 절대 하지 말아야 할 것

1. ❌ API 키를 소스 코드에 하드코딩
2. ❌ `.env` 파일을 Git에 커밋
3. ❌ API 키를 Slack, 이메일로 평문 전송
4. ❌ 스크린샷에 API 키 노출
5. ❌ 공개 저장소에 키 업로드

---

## 🔍 키 노출 검증 방법

### Git 히스토리 검색
```bash
# Git 히스토리에서 민감 정보 검색
git log -p | grep -E "sk-proj-|eyJhbGciOiJIUzI1NiI|AV2WAA|figd_|966326ff"

# 특정 파일 히스토리 검색
git log -p -- .env
```

### 현재 소스 코드 검색
```bash
# Dart 파일에서 하드코딩된 키 검색
grep -r "sk-proj-\|eyJhbGciOiJIUzI1NiI\|AV2WAA\|figd_\|966326ff" lib/

# Info.plist, xcconfig 파일 검색
grep -r "sk-proj-\|eyJhbGciOiJIUzI1NiI\|AV2WAA\|figd_\|966326ff" ios/
```

### GitHub 공개 검색
```bash
# GitHub에서 자신의 저장소 검색
# https://github.com/search?q=repo:YOUR_USERNAME/fortune+sk-proj-&type=code
```

---

## 📞 도움이 필요한 경우

### OpenAI 지원
- https://help.openai.com
- API 키 분실 시 복구 불가능, 재발급 필수

### Supabase 지원
- https://supabase.com/support
- Discord: https://discord.supabase.com

### Upstash 지원
- https://upstash.com/docs
- Discord: https://upstash.com/discord

---

## 📚 참고 자료

- [OWASP API Security Top 10](https://owasp.org/www-project-api-security/)
- [GitHub Secret Scanning](https://docs.github.com/en/code-security/secret-scanning)
- [12 Factor App - Config](https://12factor.net/config)
- [Flutter Secure Storage](https://pub.dev/packages/flutter_secure_storage)

---

**마지막 업데이트**: 2025년 1월
**작성자**: Claude Code
**우선순위**: 🔴 CRITICAL - iOS 출시 전 필수 완료
