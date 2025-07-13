# 🔒 Fortune 프로젝트 보안 체크리스트

> **작성일**: 2025년 7월 11일  
> **우선순위**: 🚨 **긴급** - 즉시 조치 필요

## 🚨 즉시 처리 필요한 보안 이슈

### 1. 노출된 API 키 및 시크릿

#### 🔴 심각도: 매우 높음
현재 여러 .env 파일에 실제 API 키와 시크릿이 노출되어 있습니다:

| 항목 | 위치 | 상태 | 조치 |
|------|------|------|------|
| OpenAI API Key | 여러 .env 파일 | 🚨 노출됨 | 즉시 재발급 필요 |
| Supabase Service Role Key | .env.local, fortune-api-server/.env | 🚨 노출됨 | 즉시 재발급 필요 |
| Upstash Redis Token | 여러 .env 파일 | 🚨 노출됨 | 즉시 재발급 필요 |
| Google OAuth Client Secret | .env 파일들 | 🚨 노출됨 | 재발급 필요 |
| Stripe Secret Key | .env 파일들 | ⚠️ 테스트 키 | 프로덕션 키 설정 시 주의 |

### 2. Git 이력 정리

#### 🔴 조치 필요
```bash
# 민감한 파일들을 git 이력에서 제거
git filter-branch --force --index-filter \
  'git rm --cached --ignore-unmatch .env .env.local .env.production client_secret*.json' \
  --prune-empty --tag-name-filter cat -- --all

# 강제 푸시 (주의: 팀원들과 조율 필요)
git push origin --force --all
git push origin --force --tags
```

## 📋 보안 강화 체크리스트

### Phase 1: 긴급 조치 (24시간 이내)

- [ ] **OpenAI API 키 재발급**
  - OpenAI 대시보드에서 기존 키 무효화
  - 새 키 생성
  - Supabase Secrets에 저장

- [ ] **Supabase Service Role Key 재발급**
  - Supabase 대시보드에서 키 재생성
  - Edge Functions secrets 업데이트
  - 로컬 개발 환경 업데이트

- [ ] **Redis (Upstash) 토큰 재발급**
  - Upstash 콘솔에서 토큰 재생성
  - 환경 변수 업데이트

- [ ] **Google OAuth 시크릿 재설정**
  - Google Cloud Console에서 재발급
  - OAuth 동의 화면 재구성

### Phase 2: Git 보안 (48시간 이내)

- [ ] **.gitignore 업데이트**
  ```gitignore
  # Environment files
  .env
  .env.*
  !.env.example
  
  # Secrets
  **/client_secret*.json
  **/service-account*.json
  
  # API keys
  **/api-keys/
  **/secrets/
  ```

- [ ] **.env.example 파일 생성**
  - 모든 환경 변수의 템플릿 제공
  - 실제 값 없이 구조만 표시

- [ ] **Git 이력 정리**
  - BFG Repo-Cleaner 또는 git filter-branch 사용
  - 민감한 파일 완전 제거

### Phase 3: 시크릿 관리 시스템 (1주일 이내)

- [ ] **Supabase Secrets 설정**
  ```bash
  supabase secrets set OPENAI_API_KEY="sk-..."
  supabase secrets set STRIPE_SECRET_KEY="sk-..."
  ```

- [ ] **GitHub Secrets 설정**
  - CI/CD용 시크릿 설정
  - 환경별 시크릿 분리

- [ ] **로컬 개발 가이드 작성**
  - .env.example 사용법
  - 시크릿 관리 best practices

## 🛡️ 보안 모범 사례

### 1. API 키 관리
- ❌ 절대 하드코딩하지 않기
- ❌ Git에 커밋하지 않기
- ✅ 환경 변수 사용
- ✅ 시크릿 관리 서비스 사용
- ✅ 정기적 키 로테이션

### 2. 인증/인가
- ✅ JWT 토큰 검증 강화
- ✅ Rate limiting 구현
- ✅ 사용자별 할당량 관리
- ✅ 역할 기반 접근 제어 (RBAC)

### 3. 데이터 보호
- ✅ HTTPS 강제
- ✅ 민감 데이터 암호화
- ✅ SQL injection 방지
- ✅ XSS 방지

### 4. 모니터링
- ✅ 보안 이벤트 로깅
- ✅ 비정상 접근 패턴 감지
- ✅ 실시간 알림 설정

## 🚀 권장 도구

### 시크릿 관리
- **Supabase Secrets**: Edge Functions용
- **GitHub Secrets**: CI/CD용
- **Google Secret Manager**: GCP 서비스용

### 보안 스캐닝
- **GitGuardian**: 시크릿 노출 감지
- **Snyk**: 의존성 취약점 스캔
- **OWASP ZAP**: 웹 애플리케이션 보안 테스트

## 📝 액션 아이템

### 오늘 (2025.07.11)
1. [ ] 모든 노출된 API 키 재발급
2. [ ] .gitignore 업데이트
3. [ ] 팀원들에게 보안 이슈 공유

### 내일 (2025.07.12)
1. [ ] Git 이력 정리
2. [ ] .env.example 파일 생성
3. [ ] Supabase Secrets 설정

### 이번 주
1. [ ] 보안 감사 실시
2. [ ] 자동화된 보안 스캔 설정
3. [ ] 보안 교육 자료 작성

## ⚠️ 중요 참고사항

1. **절대 실제 API 키를 문서에 포함시키지 마세요**
2. **시크릿 재발급 후 기존 키는 즉시 무효화하세요**
3. **팀원들과 조율하여 Git 이력 정리를 진행하세요**
4. **정기적인 보안 감사를 실시하세요**

---

*이 문서는 Fortune 프로젝트의 보안을 강화하기 위한 가이드입니다.*  
*질문이나 우려사항이 있으면 즉시 팀 리더에게 보고하세요.*