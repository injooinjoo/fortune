# 🚀 Fortune API Server 배포 가이드

이 문서는 Fortune API Server를 Firebase Cloud Run에 배포하는 방법을 설명합니다.

## 📋 목차

1. [사전 준비](#사전-준비)
2. [로컬 테스트](#로컬-테스트)
3. [Firebase 프로젝트 설정](#firebase-프로젝트-설정)
4. [Cloud Run 배포](#cloud-run-배포)
5. [환경 변수 설정](#환경-변수-설정)
6. [Flutter 앱 연동](#flutter-앱-연동)
7. [모니터링 및 로깅](#모니터링-및-로깅)
8. [문제 해결](#문제-해결)

## 🛠 사전 준비

### 필수 도구 설치

```bash
# Google Cloud SDK 설치
curl https://sdk.cloud.google.com | bash

# Firebase CLI 설치
npm install -g firebase-tools

# Docker 설치 (로컬 테스트용)
# https://www.docker.com/get-started 에서 다운로드
```

### 인증 설정

```bash
# Google Cloud 로그인
gcloud auth login

# 기본 프로젝트 설정
gcloud config set project YOUR_PROJECT_ID

# Firebase 로그인
firebase login
```

## 🧪 로컬 테스트

### 1. 환경 변수 설정

```bash
# .env.local 파일 생성
cp .env.example .env.local

# 필요한 환경 변수 설정
# - Supabase URL/Keys
# - OpenAI API Key
# - Redis URL/Token
# - IAP 관련 키
```

### 2. 로컬 실행

```bash
# 의존성 설치
npm install

# 개발 서버 실행
npm run dev

# 프로덕션 빌드 테스트
npm run build
npm start
```

### 3. Docker 테스트

```bash
# Docker 이미지 빌드
docker build -t fortune-api .

# 컨테이너 실행
docker run -p 3001:3001 --env-file .env.local fortune-api
```

## 🔥 Firebase 프로젝트 설정

### 1. Firebase 프로젝트 생성

```bash
# 새 프로젝트 생성 (이미 있다면 스킵)
firebase projects:create fortune-app-prod

# 프로젝트 선택
firebase use fortune-app-prod
```

### 2. Cloud Run API 활성화

```bash
# 필요한 API 활성화
gcloud services enable run.googleapis.com
gcloud services enable cloudbuild.googleapis.com
gcloud services enable secretmanager.googleapis.com
```

## 🚀 Cloud Run 배포

### 1. 첫 배포

```bash
# Cloud Run에 배포 (처음)
gcloud run deploy fortune-api \
  --source . \
  --region asia-northeast3 \
  --platform managed \
  --allow-unauthenticated \
  --memory 1Gi \
  --cpu 1 \
  --timeout 300 \
  --max-instances 10
```

### 2. 업데이트 배포

```bash
# 코드 변경 후 재배포
npm run deploy

# 또는 수동으로
gcloud run deploy fortune-api --source .
```

### 3. 배포 스크립트 사용

```bash
# scripts/deploy.sh 실행 권한 부여
chmod +x scripts/deploy.sh

# 배포 실행
./scripts/deploy.sh production
```

## 🔐 환경 변수 설정

### 1. Secret Manager 사용 (권장)

```bash
# Secret 생성
echo -n "your-secret-value" | gcloud secrets create SUPABASE_URL --data-file=-

# Cloud Run에서 Secret 사용
gcloud run services update fortune-api \
  --update-secrets=SUPABASE_URL=SUPABASE_URL:latest
```

### 2. 환경 변수 직접 설정

```bash
# 여러 환경 변수 한번에 설정
gcloud run services update fortune-api \
  --set-env-vars="NODE_ENV=production" \
  --set-env-vars="API_VERSION=v1" \
  --set-env-vars="ALLOWED_ORIGINS=https://fortune-app.com"
```

### 3. 환경 변수 파일 사용

```yaml
# env.yaml
SUPABASE_URL: "https://xxx.supabase.co"
SUPABASE_ANON_KEY: "xxx"
OPENAI_API_KEY: "sk-xxx"
```

```bash
gcloud run services update fortune-api --env-vars-file=env.yaml
```

## 📱 Flutter 앱 연동

### 1. API URL 업데이트

Flutter 앱의 환경 설정 파일에서 API URL을 Cloud Run URL로 변경:

```dart
// lib/config/environment.dart
class Environment {
  static const String apiUrl = 'https://fortune-api-xxxxx-an.a.run.app/api/v1';
}
```

### 2. 인증 헤더 확인

```dart
// API 요청 시 인증 토큰 포함
final response = await http.get(
  Uri.parse('$apiUrl/user/profile'),
  headers: {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  },
);
```

## 📊 모니터링 및 로깅

### 1. Cloud Run 메트릭 확인

```bash
# 서비스 상태 확인
gcloud run services describe fortune-api

# 로그 확인
gcloud logging read "resource.type=cloud_run_revision \
  AND resource.labels.service_name=fortune-api" \
  --limit 50
```

### 2. Google Cloud Console

- [Cloud Run 콘솔](https://console.cloud.google.com/run)에서 메트릭 확인
- CPU, 메모리, 요청 수, 레이턴시 모니터링
- 에러 로그 및 스택 트레이스 확인

### 3. 알림 설정

```bash
# CPU 사용률 알림
gcloud alpha monitoring policies create \
  --notification-channels=CHANNEL_ID \
  --display-name="High CPU Usage" \
  --condition-display-name="CPU > 80%" \
  --condition-threshold-value=0.8
```

## 🔧 문제 해결

### 일반적인 문제

#### 1. 메모리 부족
```bash
# 메모리 증가
gcloud run services update fortune-api --memory 2Gi
```

#### 2. 타임아웃 에러
```bash
# 타임아웃 시간 증가
gcloud run services update fortune-api --timeout 900
```

#### 3. 콜드 스타트 최적화
```bash
# 최소 인스턴스 설정
gcloud run services update fortune-api --min-instances 1
```

### 디버깅 팁

1. **로컬에서 프로덕션 환경 재현**
   ```bash
   NODE_ENV=production npm start
   ```

2. **상세 로그 활성화**
   ```bash
   gcloud run services update fortune-api \
     --set-env-vars="LOG_LEVEL=debug"
   ```

3. **헬스체크 엔드포인트 확인**
   ```bash
   curl https://fortune-api-xxxxx-an.a.run.app/health
   ```

## 📝 배포 체크리스트

- [ ] 모든 환경 변수가 설정되었는가?
- [ ] 데이터베이스 연결이 작동하는가?
- [ ] Redis 캐시가 연결되었는가?
- [ ] IAP 인증서가 올바르게 설정되었는가?
- [ ] CORS 설정이 Flutter 앱을 허용하는가?
- [ ] 에러 로깅이 작동하는가?
- [ ] 헬스체크 엔드포인트가 응답하는가?

## 🔄 CI/CD 설정

### GitHub Actions 사용

```yaml
# .github/workflows/deploy.yml
name: Deploy to Cloud Run

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v2
    
    - id: 'auth'
      uses: 'google-github-actions/auth@v0'
      with:
        credentials_json: '${{ secrets.GCP_SA_KEY }}'
    
    - name: Deploy to Cloud Run
      run: |
        gcloud run deploy fortune-api \
          --source . \
          --region asia-northeast3
```

## 📚 추가 리소스

- [Cloud Run 공식 문서](https://cloud.google.com/run/docs)
- [Firebase 공식 문서](https://firebase.google.com/docs)
- [Express on Cloud Run 가이드](https://cloud.google.com/run/docs/quickstarts/build-and-deploy/nodejs)

---

문제가 발생하면 [이슈 트래커](https://github.com/yourusername/fortune-api-server/issues)에 문의해주세요.