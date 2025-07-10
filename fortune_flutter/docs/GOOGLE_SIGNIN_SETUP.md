# Google Sign-In 설정 가이드

## 1. Google Cloud Console 설정

### 1.1 프로젝트 생성
1. [Google Cloud Console](https://console.cloud.google.com) 접속
2. 새 프로젝트 생성 또는 기존 프로젝트 선택

### 1.2 OAuth 2.0 클라이언트 ID 생성

#### Web Application
1. APIs & Services > Credentials로 이동
2. "Create Credentials" > "OAuth client ID" 선택
3. Application type: "Web application"
4. Name: "Fortune Web"
5. Authorized JavaScript origins:
   - `http://localhost:9002` (개발용)
   - `https://your-domain.com` (프로덕션)
6. Authorized redirect URIs:
   - `http://localhost:9002/auth/callback`
   - `https://your-domain.com/auth/callback`
7. Create 클릭 후 Client ID 복사

#### iOS Application
1. Application type: "iOS" 선택
2. Name: "Fortune iOS"
3. Bundle ID: `com.yourcompany.fortune` (실제 Bundle ID로 변경)
4. Create 클릭

#### Android Application
1. Application type: "Android" 선택
2. Name: "Fortune Android"
3. Package name: `com.yourcompany.fortune` (실제 패키지명으로 변경)
4. SHA-1 certificate fingerprint 입력
5. Create 클릭

## 2. 플러터 프로젝트 설정

### 2.1 Web 설정
`web/index.html` 파일에서 YOUR_GOOGLE_CLIENT_ID를 실제 Web Client ID로 변경:
```html
<meta name="google-signin-client_id" content="YOUR_WEB_CLIENT_ID.apps.googleusercontent.com">
```

### 2.2 iOS 설정
1. `ios/Runner/Info.plist`에 추가:
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>YOUR_REVERSED_CLIENT_ID</string>
        </array>
    </dict>
</array>
```

2. REVERSED_CLIENT_ID 형식: `com.googleusercontent.apps.YOUR_CLIENT_ID`

### 2.3 Android 설정
1. `android/app/src/main/res/values/strings.xml`에 추가:
```xml
<resources>
    <string name="default_web_client_id">YOUR_WEB_CLIENT_ID.apps.googleusercontent.com</string>
</resources>
```

## 3. 환경 변수 설정

### 3.1 개발 환경 (.env)
```bash
GOOGLE_WEB_CLIENT_ID=your_web_client_id.apps.googleusercontent.com
GOOGLE_IOS_CLIENT_ID=your_ios_client_id.apps.googleusercontent.com
GOOGLE_ANDROID_CLIENT_ID=your_android_client_id.apps.googleusercontent.com
```

### 3.2 실행 시 환경 변수 전달
```bash
flutter run --dart-define=GOOGLE_WEB_CLIENT_ID=your_web_client_id.apps.googleusercontent.com
```

## 4. Supabase 설정

### 4.1 Authentication 설정
1. Supabase Dashboard > Authentication > Providers
2. Google 활성화
3. Client ID와 Client Secret 입력
4. Redirect URL 복사 (Google Console에 추가 필요)

### 4.2 Database 설정
`user_profiles` 테이블에 필드 추가:
```sql
ALTER TABLE user_profiles 
ADD COLUMN auth_provider VARCHAR(50),
ADD COLUMN profile_image_url TEXT;
```

## 5. 테스트

### 5.1 Web 테스트
```bash
flutter run -d chrome --web-port=9002
```

### 5.2 iOS 테스트
- 실제 디바이스 또는 시뮬레이터에서 테스트
- Bundle ID가 Google Console과 일치하는지 확인

### 5.3 Android 테스트
- SHA-1 fingerprint가 올바른지 확인
- Debug와 Release 빌드 모두에 대한 SHA-1 등록

## 6. 문제 해결

### 6.1 "popup_closed_by_user" 오류
- 팝업 차단기 비활성화
- 올바른 redirect URI 설정 확인

### 6.2 "invalid_client" 오류
- Client ID가 올바른지 확인
- 플랫폼별 올바른 Client ID 사용 확인

### 6.3 iOS에서 로그인 안 됨
- URL Scheme 설정 확인
- Info.plist 설정 확인