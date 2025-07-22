# Supabase API Key 오류 해결 가이드

## 문제 상황
현재 Flutter 앱에서 Supabase 연결 시 "Invalid API key" (401) 오류가 발생하고 있습니다.

## 해결 방법

### 1. Supabase 대시보드에서 올바른 API 키 가져오기

1. Supabase 대시보드 접속:
   ```
   https://supabase.com/dashboard/project/hayjukwfcsdmppairazc/settings/api
   ```

2. "Project API keys" 섹션 확인:
   - `anon` `public` 키를 찾아서 복사
   - 이 키는 `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9`로 시작해야 함

3. 프로젝트 상태 확인:
   - 프로젝트가 "Active" 상태인지 확인
   - 만약 "Paused" 상태라면 "Resume project" 버튼 클릭

### 2. .env 파일 업데이트

1. Flutter 프로젝트의 `.env` 파일 열기:
   ```
   fortune_flutter/.env
   ```

2. SUPABASE_ANON_KEY를 대시보드에서 복사한 키로 교체:
   ```
   SUPABASE_ANON_KEY=<대시보드에서 복사한 anon key>
   ```

### 3. 앱 재시작

```bash
cd fortune_flutter
flutter clean
flutter pub get
flutter run
```

## 추가 확인 사항

### 프로젝트가 일시정지된 경우
무료 티어의 Supabase 프로젝트는 일정 기간 사용하지 않으면 자동으로 일시정지됩니다.
- 대시보드에서 "Resume project" 클릭
- 프로젝트가 다시 활성화될 때까지 몇 분 대기

### API 키가 여전히 작동하지 않는 경우
1. 브라우저의 개발자 도구(F12)를 열고 네트워크 탭 확인
2. 실제 요청에서 사용되는 URL과 헤더 확인
3. Supabase 대시보드의 "Logs" 섹션에서 401 오류 로그 확인

## 테스트 방법

API 키가 올바르게 설정되었는지 확인하려면:

1. 브라우저에서 다음 URL 접속:
   ```
   https://hayjukwfcsdmppairazc.supabase.co/rest/v1/
   ```

2. 401 오류가 표시되면 정상 (인증이 필요한 엔드포인트)

3. 404나 다른 오류가 표시되면 프로젝트 URL이 잘못되었거나 프로젝트가 비활성화된 것

## 임시 해결책

만약 기존 프로젝트를 복구할 수 없다면:

1. 새 Supabase 프로젝트 생성
2. 새 프로젝트의 URL과 API 키로 `.env` 파일 업데이트
3. 필요한 테이블과 정책 재생성