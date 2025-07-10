# Google Sign-In 설정 수정 가이드

## 문제 해결 완료

Google 로그인이 작동하지 않는 문제를 해결하기 위해 다음과 같은 수정사항을 적용했습니다:

### 1. 환경 변수 설정 개선
- `.env` 파일에 Google OAuth 클라이언트 ID 설정 추가
- 웹, iOS, Android 각 플랫폼별 클라이언트 ID 지원

### 2. 코드 수정 사항

#### Environment 클래스 업데이트
- `lib/core/config/environment.dart`에 Google 클라이언트 ID 접근 메서드 추가
- `googleWebClientId`, `googleIosClientId`, `googleAndroidClientId` getter 추가

#### SocialAuthService 개선
- `lib/services/social_auth_service.dart`에서 Environment 클래스 사용
- 플랫폼별 적절한 클라이언트 ID 자동 선택

#### 개발 스크립트 업데이트
- `run_dev.sh`에 환경 변수 자동 로드 기능 추가
- dart-define 파라미터로 Google 클라이언트 ID 전달

### 3. 플랫폼별 설정

#### Web 설정
- `web/index.html`에 Google Sign-In 메타 태그 설정 안내 추가

#### iOS 설정
- `ios/Runner/Info.plist`에 CFBundleURLTypes 설정 추가
- Reversed Client ID 형식 안내 포함

#### Android 설정
- `android/app/src/main/res/values/strings.xml` 파일 생성
- default_web_client_id 설정 추가

## 설정 방법

### 1. Google Cloud Console에서 OAuth 2.0 클라이언트 ID 생성

1. [Google Cloud Console](https://console.cloud.google.com) 접속
2. APIs & Services > Credentials로 이동
3. 각 플랫폼별 OAuth 클라이언트 ID 생성:
   - Web application
   - iOS application
   - Android application

### 2. .env 파일 업데이트

```bash
# .env 파일에서 다음 값들을 실제 클라이언트 ID로 변경
GOOGLE_WEB_CLIENT_ID=your-actual-web-client-id.apps.googleusercontent.com
GOOGLE_IOS_CLIENT_ID=your-actual-ios-client-id.apps.googleusercontent.com
GOOGLE_ANDROID_CLIENT_ID=your-actual-android-client-id.apps.googleusercontent.com
```

### 3. 플랫폼별 설정 파일 업데이트

#### Web (web/index.html)
```html
<meta name="google-signin-client_id" content="your-actual-web-client-id.apps.googleusercontent.com">
```

#### iOS (ios/Runner/Info.plist)
```xml
<string>com.googleusercontent.apps.your-actual-ios-client-id</string>
```

#### Android (android/app/src/main/res/values/strings.xml)
```xml
<string name="default_web_client_id">your-actual-web-client-id.apps.googleusercontent.com</string>
```

### 4. Supabase 설정

1. Supabase Dashboard > Authentication > Providers
2. Google 프로바이더 활성화
3. Client ID와 Client Secret 입력
4. Redirect URLs 설정:
   - Web: `http://localhost:9002/auth/callback`
   - Mobile: `io.supabase.flutter://login-callback/`

### 5. 개발 서버 실행

```bash
# 개발 서버 실행 (자동으로 환경 변수 로드)
./run_dev.sh
```

## 주의사항

1. **보안**: 실제 클라이언트 ID는 절대 Git에 커밋하지 마세요
2. **플랫폼별 ID**: 각 플랫폼(Web, iOS, Android)은 별도의 클라이언트 ID가 필요합니다
3. **Redirect URI**: Google Console에서 설정한 Redirect URI가 앱의 설정과 일치해야 합니다
4. **Bundle ID/Package Name**: iOS와 Android의 Bundle ID/Package Name이 Google Console 설정과 일치해야 합니다

## 문제 해결

### "popup_closed_by_user" 오류
- 브라우저 팝업 차단 해제
- Redirect URI 설정 확인

### "invalid_client" 오류
- 클라이언트 ID가 올바른지 확인
- 플랫폼에 맞는 클라이언트 ID 사용 확인

### 로그인 후 리다이렉트 안 됨
- Supabase의 Site URL 설정 확인
- Deep link 설정 확인 (모바일)

## 테스트 체크리스트

- [ ] .env 파일에 실제 Google 클라이언트 ID 입력
- [ ] web/index.html의 메타 태그 업데이트
- [ ] iOS Info.plist의 Reversed Client ID 업데이트
- [ ] Android strings.xml의 Web Client ID 업데이트
- [ ] Supabase Dashboard에서 Google Provider 설정
- [ ] 웹에서 Google 로그인 테스트
- [ ] iOS에서 Google 로그인 테스트 (실제 기기)
- [ ] Android에서 Google 로그인 테스트