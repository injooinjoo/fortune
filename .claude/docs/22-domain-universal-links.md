# zpzg.co.kr 도메인 및 Universal Links 설정 가이드

> 최종 업데이트: 2025.01.16

## 개요

| 항목 | 값 |
|------|-----|
| 도메인 | zpzg.co.kr |
| 등록기관 | 가비아 (Gabia) |
| 웹 호스팅 | Vercel (zpzg-landing 프로젝트) |
| API 도메인 | api.zpzg.co.kr → Supabase |
| iOS Bundle ID | com.beyond.fortune |
| iOS Team ID | 5F7CN7Y54D |
| Android Package | com.beyond.fortune |

---

## 1. 아키텍처

```
┌─────────────────────────────────────────────────────────────┐
│                      zpzg.co.kr                             │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────┐     ┌─────────────┐     ┌─────────────┐   │
│  │   Vercel    │     │  Supabase   │     │   Flutter   │   │
│  │  (Landing)  │     │    (API)    │     │    (App)    │   │
│  └─────────────┘     └─────────────┘     └─────────────┘   │
│         │                   │                   │           │
│         ▼                   ▼                   ▼           │
│  zpzg.co.kr          api.zpzg.co.kr       앱 딥링크        │
│  /.well-known/       /functions/v1/       Universal Links  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 2. 가비아 DNS 설정

### 필수 레코드

| 타입 | 호스트 | 값 | TTL | 용도 |
|------|--------|-----|-----|------|
| A | @ | 76.76.21.21 | 3600 | Vercel (루트 도메인) |
| CNAME | www | cname.vercel-dns.com | 3600 | Vercel (www 서브도메인) |
| CNAME | api | [Supabase 제공 값] | 3600 | Supabase API |

### 설정 방법

1. 가비아 로그인 → My가비아 → 도메인 관리
2. zpzg.co.kr 선택 → DNS 관리
3. 레코드 추가:
   - A 레코드: 호스트 `@`, 값 `76.76.21.21`
   - CNAME: 호스트 `www`, 값 `cname.vercel-dns.com`
   - CNAME: 호스트 `api`, 값 `[Supabase에서 확인]`

### DNS 전파 확인

```bash
# A 레코드 확인
dig zpzg.co.kr A

# CNAME 확인
dig www.zpzg.co.kr CNAME
dig api.zpzg.co.kr CNAME

# 또는 온라인 도구
# https://dnschecker.org/
```

---

## 3. Vercel 설정

### 프로젝트 위치

```
/private/tmp/zpzg-landing/
├── public/
│   ├── .well-known/
│   │   ├── apple-app-site-association  # iOS Universal Links
│   │   └── assetlinks.json             # Android App Links
│   └── index.html                       # 랜딩 페이지
├── vercel.json                          # Vercel 설정
└── package.json
```

### Vercel 도메인 연결

1. Vercel 대시보드 → zpzg-landing 프로젝트
2. Settings → Domains
3. `zpzg.co.kr` 추가
4. `www.zpzg.co.kr` 추가 (선택)

### 검증

```bash
# AASA 파일 확인
curl -I https://zpzg.co.kr/.well-known/apple-app-site-association

# assetlinks.json 확인
curl -I https://zpzg.co.kr/.well-known/assetlinks.json

# Content-Type이 application/json이어야 함
```

---

## 4. iOS 설정 (Universal Links)

### 4.1 앱 설정 (완료됨)

**파일: `ios/Runner/Runner.entitlements`**
```xml
<key>com.apple.developer.associated-domains</key>
<array>
    <string>applinks:zpzg.co.kr</string>
    <string>webcredentials:zpzg.co.kr</string>
</array>
```

### 4.2 Apple Developer Portal 설정 (필수)

1. https://developer.apple.com 로그인
2. Certificates, Identifiers & Profiles
3. Identifiers → com.beyond.fortune 선택
4. Capabilities → Associated Domains 활성화 (체크)
5. Save

### 4.3 apple-app-site-association (서버 - 완료됨)

**파일: `public/.well-known/apple-app-site-association`**
```json
{
  "applinks": {
    "details": [
      {
        "appIDs": ["5F7CN7Y54D.com.beyond.fortune"],
        "components": [{ "/": "/*", "comment": "Match all paths" }]
      }
    ]
  },
  "webcredentials": {
    "apps": ["5F7CN7Y54D.com.beyond.fortune"]
  }
}
```

### 4.4 테스트

1. 앱 삭제 후 재설치 (또는 새 빌드)
2. Safari에서 `https://zpzg.co.kr/chat` 열기
3. 링크 길게 누르기 → "ZPZG에서 열기" 옵션 확인
4. 또는 메모장에 링크 붙여넣기 → 탭하여 앱 열림 확인

---

## 5. Android 설정 (App Links)

### 5.1 앱 설정 (완료됨)

**파일: `android/app/src/main/AndroidManifest.xml`**
```xml
<!-- Universal Links for zpzg.co.kr -->
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data
        android:scheme="https"
        android:host="zpzg.co.kr"
        android:pathPattern=".*" />
</intent-filter>
```

### 5.2 SHA256 인증서 지문 획득

```bash
# 개발용 (debug)
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

# 배포용 (release) - 실제 키스토어 경로 사용
keytool -list -v -keystore /path/to/release.keystore -alias your-alias

# Play Store App Signing 사용 시
# Google Play Console → 앱 → 설정 → 앱 서명 → SHA-256 인증서 지문 복사
```

### 5.3 assetlinks.json 업데이트 (필수)

**파일: `public/.well-known/assetlinks.json`**
```json
[{
  "relation": ["delegate_permission/common.handle_all_urls"],
  "target": {
    "namespace": "android_app",
    "package_name": "com.beyond.fortune",
    "sha256_cert_fingerprints": [
      "XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX"
    ]
  }
}]
```

**참고**: Play Store App Signing 사용 시 Google에서 제공하는 SHA256과 로컬 업로드 키 SHA256 모두 추가

### 5.4 Google Play Console 설정 (배포 시)

1. Google Play Console → 앱 선택
2. 설정 → 앱 무결성 → 앱 서명
3. SHA-256 인증서 지문 복사
4. assetlinks.json에 추가
5. Vercel 재배포

### 5.5 테스트

```bash
# adb로 앱 링크 검증
adb shell am start -a android.intent.action.VIEW -d "https://zpzg.co.kr/chat"

# 또는 앱 링크 설정 확인
adb shell pm get-app-links com.beyond.fortune
```

---

## 6. Supabase 커스텀 도메인

### 6.1 Supabase 대시보드 설정

1. Supabase 대시보드 → 프로젝트 선택
2. Project Settings → Custom Domains
3. `api.zpzg.co.kr` 입력
4. 제공되는 CNAME 값 복사

### 6.2 가비아 DNS 추가

| 타입 | 호스트 | 값 |
|------|--------|-----|
| CNAME | api | [Supabase 제공 CNAME 값] |

### 6.3 환경 변수 업데이트

**파일: `.env.production`**
```
PROD_API_BASE_URL=https://api.zpzg.co.kr/functions/v1
```

---

## 7. Flutter 앱 설정 (완료됨)

### 7.1 환경 변수

**파일: `.env`**
```
APP_DOMAIN=zpzg.co.kr
```

### 7.2 Environment 클래스

**파일: `lib/core/config/environment.dart`**
```dart
// App Domain 설정 (공유 링크, 딥링크용)
static String get appDomain => dotenv.env['APP_DOMAIN'] ?? 'zpzg.co.kr';
static String get appBaseUrl => 'https://$appDomain';
static String get defaultShareImageUrl => '$appBaseUrl/images/default_share.png';
```

### 7.3 카카오 공유 서비스

**파일: `lib/services/kakao_share_service.dart`**
- 모든 하드코딩 URL을 `Environment.appBaseUrl` 사용으로 변경

---

## 8. App Store / Play Store 설정

### 8.1 App Store Connect

**앱 정보 업데이트 필요 항목:**

| 항목 | 현재 | 변경 |
|------|------|------|
| 마케팅 URL | (없음 또는 기존) | https://zpzg.co.kr |
| 지원 URL | (기존) | https://zpzg.co.kr/support |
| 개인정보 처리방침 URL | (기존) | https://zpzg.co.kr/privacy |

**설정 방법:**
1. App Store Connect 로그인
2. 앱 선택 → 앱 정보
3. URL 항목들 업데이트
4. 저장

### 8.2 Google Play Console

**스토어 등록정보 업데이트 필요 항목:**

| 항목 | 현재 | 변경 |
|------|------|------|
| 개발자 웹사이트 | (기존) | https://zpzg.co.kr |
| 개인정보처리방침 URL | (기존) | https://zpzg.co.kr/privacy |
| 지원 이메일 | (기존) | support@zpzg.co.kr (선택) |

**설정 방법:**
1. Google Play Console 로그인
2. 앱 선택 → 스토어 등록정보 → 기본 스토어 등록정보
3. 연락처 세부정보 업데이트
4. 저장

### 8.3 앱 링크 검증 (Android)

Google Play Console에서 앱 링크 검증:
1. 설정 → 앱 무결성
2. 앱 링크 섹션 확인
3. zpzg.co.kr 도메인 검증 상태 확인

---

## 9. 카카오 개발자 설정

### Kakao Developers 업데이트

1. https://developers.kakao.com 로그인
2. 앱 선택 → 앱 설정 → 플랫폼
3. **iOS**:
   - 번들 ID: com.beyond.fortune
   - 앱스토어 ID: (앱스토어 ID)
4. **Android**:
   - 패키지명: com.beyond.fortune
   - 마켓 URL: (플레이스토어 URL)
5. **Web**:
   - 사이트 도메인: https://zpzg.co.kr 추가

---

## 10. 체크리스트

### 완료됨 ✅

- [x] Vercel 프로젝트 생성 (zpzg-landing)
- [x] apple-app-site-association 파일 생성
- [x] assetlinks.json 파일 생성 (SHA256 제외)
- [x] vercel.json 헤더 설정
- [x] Vercel 배포 완료
- [x] Flutter Environment 클래스 수정
- [x] KakaoShareService URL 수정
- [x] iOS Runner.entitlements 수정
- [x] Android AndroidManifest.xml 수정
- [x] flutter analyze 통과

### 진행 필요 🔄

- [ ] 가비아 DNS 설정 (A, CNAME 레코드)
- [ ] Vercel 도메인 연결 (zpzg.co.kr)
- [ ] Apple Developer Portal Associated Domains 활성화
- [ ] Android SHA256 지문 추가 (assetlinks.json)
- [ ] Supabase 커스텀 도메인 설정 (api.zpzg.co.kr)

### 배포 시 필요 📋

- [ ] App Store Connect URL 업데이트
- [ ] Google Play Console URL 업데이트
- [ ] Google Play Console 앱 링크 검증
- [ ] Kakao Developers 도메인 추가

---

## 11. 문제 해결

### Universal Links가 작동하지 않을 때

1. **AASA 파일 확인**
   ```bash
   curl https://zpzg.co.kr/.well-known/apple-app-site-association
   ```
   - Content-Type: application/json 확인
   - appIDs 형식: TeamID.BundleID

2. **앱 재설치**
   - iOS는 앱 설치 시 AASA를 다운로드
   - 변경 후 앱 삭제 → 재설치 필요

3. **Apple CDN 캐시**
   - Apple은 AASA를 CDN에 캐시함
   - 변경 반영까지 최대 24시간 소요
   - 테스트: https://app-site-association.cdn-apple.com/a/v1/zpzg.co.kr

### Android App Links가 작동하지 않을 때

1. **assetlinks.json 확인**
   ```bash
   curl https://zpzg.co.kr/.well-known/assetlinks.json
   ```

2. **SHA256 지문 확인**
   - Play Store App Signing 사용 시 Google 제공 지문 사용
   - 개발 빌드와 릴리즈 빌드 지문이 다름

3. **검증 상태 확인**
   ```bash
   adb shell pm get-app-links com.beyond.fortune
   ```

---

## 12. 관련 파일 경로

| 파일 | 경로 |
|------|------|
| Environment 설정 | `lib/core/config/environment.dart` |
| 카카오 공유 | `lib/services/kakao_share_service.dart` |
| iOS 권한 | `ios/Runner/Runner.entitlements` |
| Android 매니페스트 | `android/app/src/main/AndroidManifest.xml` |
| AASA 파일 | `/private/tmp/zpzg-landing/public/.well-known/apple-app-site-association` |
| assetlinks | `/private/tmp/zpzg-landing/public/.well-known/assetlinks.json` |
| Vercel 설정 | `/private/tmp/zpzg-landing/vercel.json` |