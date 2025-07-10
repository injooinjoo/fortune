# 🔒 Flutter Security Review Guide

## Overview
Fortune Flutter 앱의 보안 구현 가이드 및 체크리스트입니다. 모바일 앱 특성에 맞는 보안 전략을 적용합니다.

## ✅ Flutter 앱 보안 구현 사항

### 1. **안전한 데이터 저장**
- **flutter_secure_storage**: 민감한 데이터 암호화 저장
  - iOS: Keychain 사용
  - Android: AES 암호화 후 SharedPreferences 저장
- **SQLite 암호화**: sqflite_sqlcipher 사용
- **메모리 보안**: 사용 후 민감 데이터 즉시 제거

### 2. **네트워크 보안**
- **인증서 피닝 (Certificate Pinning)**
  ```dart
  SecurityContext context = SecurityContext();
  context.setTrustedCertificatesBytes(pinnedCertificate);
  ```
- **API 통신 암호화**: HTTPS 강제
- **중간자 공격 방지**: SSL/TLS 검증

### 3. **인증 및 권한 관리**
- **생체 인증**: local_auth 패키지 사용
  - Touch ID / Face ID (iOS)
  - 지문 인식 (Android)
- **OAuth 2.0**: 소셜 로그인
- **토큰 관리**: 
  - Access Token: 메모리에만 저장
  - Refresh Token: flutter_secure_storage에 저장

### 4. **코드 보안**
- **난독화**:
  - Android: ProGuard/R8 규칙 적용
  - iOS: Swift 심볼 제거
- **안티 디버깅**: 
  - 디버거 탐지
  - 루팅/탈옥 감지
- **무결성 검증**: 앱 서명 확인

## 🛡️ 보안 체크리스트

### 1. **데이터 보호**
- [ ] 민감 데이터 평문 저장 금지
- [ ] flutter_secure_storage 사용
- [ ] 로그에 민감 정보 출력 금지
- [ ] 클립보드 복사 제한
- [ ] 스크린샷 방지 (필요시)

### 2. **네트워크 보안**
- [ ] HTTPS 사용 강제
- [ ] 인증서 피닝 구현
- [ ] API 키 하드코딩 금지
- [ ] 요청/응답 데이터 검증
- [ ] Rate Limiting 구현

### 3. **인증 보안**
- [ ] 생체 인증 구현
- [ ] 세션 타임아웃 설정
- [ ] 자동 로그아웃 기능
- [ ] 비밀번호 정책 적용
- [ ] 2단계 인증 (선택)

### 4. **코드 보안**
- [ ] 릴리스 빌드 난독화
- [ ] 디버그 정보 제거
- [ ] 안티 탬퍼링 구현
- [ ] 루팅/탈옥 탐지
- [ ] 에뮬레이터 탐지

## 🚨 주요 취약점 및 대응

### 1. **저장소 취약점**
```dart
// ❌ 잘못된 예
SharedPreferences prefs = await SharedPreferences.getInstance();
prefs.setString('password', userPassword); // 평문 저장

// ✅ 올바른 예
final storage = FlutterSecureStorage();
await storage.write(key: 'password', value: userPassword); // 암호화 저장
```

### 2. **네트워크 취약점**
```dart
// ❌ 잘못된 예
final response = await http.get(Uri.parse('http://api.example.com/data'));

// ✅ 올바른 예
final dio = Dio();
dio.interceptors.add(CertificatePinningInterceptor());
final response = await dio.get('https://api.example.com/data');
```

### 3. **코드 주입 취약점**
```dart
// ❌ 잘못된 예
webView.evaluateJavascript(userInput); // 사용자 입력 직접 실행

// ✅ 올바른 예
final sanitizedInput = HtmlEscape().convert(userInput);
webView.evaluateJavascript('displayText("$sanitizedInput")');
```

## 📱 플랫폼별 보안 설정

### Android
```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<application
    android:allowBackup="false"
    android:networkSecurityConfig="@xml/network_security_config">
    <!-- 백업 비활성화 및 네트워크 보안 설정 -->
</application>
```

```xml
<!-- android/app/src/main/res/xml/network_security_config.xml -->
<network-security-config>
    <domain-config cleartextTrafficPermitted="false">
        <domain includeSubdomains="true">api.fortune.app</domain>
        <pin-set expiration="2025-01-01">
            <pin digest="SHA-256">AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=</pin>
        </pin-set>
    </domain-config>
</network-security-config>
```

### iOS
```xml
<!-- ios/Runner/Info.plist -->
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <false/>
    <key>NSPinnedDomains</key>
    <dict>
        <key>api.fortune.app</key>
        <dict>
            <key>NSIncludesSubdomains</key>
            <true/>
            <key>NSPinnedCAIdentities</key>
            <array>
                <dict>
                    <key>SPKI-SHA256-BASE64</key>
                    <string>AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=</string>
                </dict>
            </array>
        </dict>
    </dict>
</dict>
```

## 🔍 보안 테스트

### 1. **정적 분석 (SAST)**
```bash
# Flutter 보안 분석
flutter analyze

# 의존성 취약점 검사
flutter pub audit
```

### 2. **동적 분석 (DAST)**
- OWASP ZAP을 사용한 API 테스트
- Burp Suite를 사용한 프록시 테스트
- MobSF를 사용한 모바일 앱 분석

### 3. **침투 테스트 체크리스트**
- [ ] 루팅/탈옥 우회 시도
- [ ] 인증서 피닝 우회 시도
- [ ] 메모리 덤프 분석
- [ ] 리버스 엔지니어링 시도
- [ ] API 인증 우회 시도

## 📊 보안 모니터링

### 1. **크래시 및 오류 추적**
```dart
// Firebase Crashlytics 설정
FirebaseCrashlytics.instance.recordError(
  error,
  stack,
  fatal: false,
  information: [
    // 민감 정보 제외
    'user_id': hashedUserId,
    'fortune_type': fortuneType,
  ],
);
```

### 2. **이상 행동 탐지**
- 비정상적인 API 호출 패턴
- 다중 기기 동시 로그인
- 과도한 토큰 사용
- 루팅/탈옥 기기 사용

## 🚀 보안 배포 프로세스

### 1. **빌드 전 체크리스트**
- [ ] 디버그 로그 제거
- [ ] 테스트 계정 제거
- [ ] API 키 환경 변수 확인
- [ ] 난독화 설정 확인

### 2. **빌드 명령어**
```bash
# Android (ProGuard 활성화)
flutter build apk --release --obfuscate --split-debug-info=./debug-info

# iOS
flutter build ios --release --obfuscate --split-debug-info=./debug-info
```

### 3. **배포 후 확인**
- [ ] 앱 서명 검증
- [ ] 난독화 적용 확인
- [ ] API 통신 암호화 확인
- [ ] 보안 헤더 확인

## 📚 참고 자료

- [Flutter 보안 가이드](https://docs.flutter.dev/security)
- [OWASP Mobile Top 10](https://owasp.org/www-project-mobile-top-10/)
- [Android 보안 가이드](https://developer.android.com/topic/security/best-practices)
- [iOS 보안 가이드](https://developer.apple.com/documentation/security)

---

**Note**: 이 문서는 Fortune Flutter 앱의 보안 기준입니다. 모든 개발자는 이 가이드를 준수해야 하며, 새로운 보안 위협이 발견되면 즉시 업데이트해야 합니다.