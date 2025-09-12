# Fortune Flutter 프로덕션 배포 가이드

## 목차
1. [환경 설정](#환경-설정)
2. [Android 배포](#android-배포)
3. [iOS 배포](#ios-배포)
4. [배포 전 체크리스트](#배포-전-체크리스트)
5. [문제 해결](#문제-해결)

## 환경 설정

### 1. 환경 변수 설정

1. `.env.production.example`을 `.env`로 복사:
   ```bash
   cp .env.production.example .env
   ```

2. `.env` 파일을 열어 모든 프로덕션 값으로 교체:
   - `PROD_API_BASE_URL`: 프로덕션 API URL (HTTPS 필수)
   - `SUPABASE_URL`, `SUPABASE_ANON_KEY`: Supabase 프로젝트 정보
   - 결제 키: Stripe, TossPay 프로덕션 키
   - 기타 필수 환경 변수

### 2. 환경 검증

환경이 올바르게 설정되었는지 확인:
```bash
flutter run --release
```

## Android 배포

### 1. 키스토어 생성

```bash
keytool -genkey -v -keystore ~/fortune-release-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias fortune
```

### 2. key.properties 설정

1. `android/key.properties.example`을 `android/key.properties`로 복사
2. 실제 키스토어 정보로 업데이트:
   ```properties
   storePassword=your_keystore_password
   keyPassword=your_key_password
   keyAlias=fortune
   storeFile=/Users/your_username/fortune-release-key.jks
   ```

### 3. 빌드 실행

```bash
./build_production.sh android
```

### 4. Google Play Console 업로드

1. [Google Play Console](https://play.google.com/console) 접속
2. 앱 생성 또는 선택
3. 프로덕션 트랙에서 새 릴리스 생성
4. `build/app/outputs/bundle/release/app-release.aab` 업로드

## iOS 배포

### 1. Apple Developer 설정

1. [Apple Developer](https://developer.apple.com) 계정 필요
2. App ID 생성: `com.beyond.fortune`
3. 프로비저닝 프로필 생성 (Distribution)

### 2. Xcode 설정

1. `ios/Runner.xcworkspace`를 Xcode에서 열기
2. Runner 타겟 선택
3. Signing & Capabilities 탭에서:
   - Team 선택
   - Bundle Identifier 확인
   - Provisioning Profile 선택

### 3. 빌드 실행

```bash
./build_production.sh ios
```

### 4. App Store Connect 업로드

1. Xcode에서 Product → Archive
2. Distribute App 선택
3. App Store Connect 선택
4. 업로드 완료 후 [App Store Connect](https://appstoreconnect.apple.com)에서 제출

## 배포 전 체크리스트

### 보안 체크
- [ ] 모든 API URL이 HTTPS 사용
- [ ] 디버그 로그 제거됨
- [ ] ProGuard/R8 규칙 적용됨 (Android)
- [ ] 민감한 정보가 코드에 하드코딩되지 않음

### 기능 테스트
- [ ] 로그인/회원가입 정상 작동
- [ ] 결제 시스템 정상 작동
- [ ] 운세 생성 정상 작동
- [ ] 광고 표시 정상 작동

### 성능 최적화
- [ ] 이미지 최적화됨
- [ ] 불필요한 의존성 제거됨
- [ ] 앱 크기 최적화됨

### 환경 변수
- [ ] `ENVIRONMENT=production`
- [ ] 프로덕션 API URL 설정됨
- [ ] 프로덕션 결제 키 설정됨
- [ ] Sentry DSN 설정됨

## 문제 해결

### Android 빌드 오류

1. **키스토어를 찾을 수 없음**
   ```
   키스토어 경로가 올바른지 확인
   key.properties 파일이 있는지 확인
   ```

2. **메서드 수 제한 초과**
   ```
   multidexEnabled true가 설정되어 있는지 확인
   ```

### iOS 빌드 오류

1. **코드 서명 오류**
   ```
   개발자 인증서가 유효한지 확인
   프로비저닝 프로필이 올바른지 확인
   ```

2. **Pod 설치 오류**
   ```bash
   cd ios
   pod deintegrate
   pod install
   ```

### 환경 변수 오류

1. **필수 환경 변수 누락**
   ```
   .env 파일의 모든 필수 변수가 설정되었는지 확인
   environment.dart의 검증 로직 확인
   ```

## 버전 관리

### 버전 업데이트

`pubspec.yaml`에서 버전 업데이트:
```yaml
version: 1.0.0+1  # 1.0.0은 버전명, +1은 빌드 번호
```

### 체인지로그 작성

각 릴리스마다 CHANGELOG.md 업데이트 필수

## 모니터링

### Sentry 설정

1. [Sentry](https://sentry.io) 프로젝트 생성
2. DSN을 `.env`에 추가
3. 릴리스 추적 활성화

### 앱 성능 모니터링

1. Firebase Performance Monitoring 설정
2. 주요 화면 로딩 시간 추적
3. API 응답 시간 모니터링

## 지원

문제가 발생하면:
1. 로그 확인
2. 환경 변수 재확인
3. 빌드 캐시 정리 (`flutter clean`)
4. 이슈 트래커에 문의
