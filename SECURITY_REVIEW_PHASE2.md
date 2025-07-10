# 🔒 Flutter Security Phase 2: 고급 보안 및 결제 통합

## 개요
Fortune Flutter 프로젝트의 2단계 보안 강화 가이드입니다. 모바일 환경에서의 결제 시스템 통합과 고급 보안 기능 구현을 다룹니다.

## ✅ 구현된 보안 개선 사항

### 1. **인앱 결제 보안**
- **Google Play Billing**:
  - 서버 측 영수증 검증
  - 구매 토큰 검증
  - 리플레이 공격 방지
  ```dart
  // 구매 검증
  final isValid = await verifyPurchase(
    purchaseToken: purchase.purchaseToken,
    productId: purchase.productId,
    packageName: packageName,
  );
  ```

- **Apple StoreKit**:
  - 영수증 검증 API
  - 샌드박스/프로덕션 환경 분리
  - 구독 상태 실시간 업데이트

### 2. **고급 인증 시스템**
- **생체 인증 통합**:
  ```dart
  final LocalAuthentication auth = LocalAuthentication();
  
  // 생체 인증 가능 여부 확인
  final bool canCheckBiometrics = await auth.canCheckBiometrics;
  final bool isDeviceSupported = await auth.isDeviceSupported();
  
  // 인증 수행
  final bool didAuthenticate = await auth.authenticate(
    localizedReason: '운세를 확인하려면 인증이 필요합니다',
    options: const AuthenticationOptions(
      biometricOnly: true,
      stickyAuth: true,
    ),
  );
  ```

- **OAuth 2.0 구현**:
  - PKCE (Proof Key for Code Exchange) 적용
  - State 파라미터로 CSRF 방지
  - 안전한 리다이렉트 URI 검증

### 3. **데이터 암호화 강화**
- **End-to-End 암호화**:
  ```dart
  // AES-256 암호화
  final encrypter = Encrypter(AES(key));
  final encrypted = encrypter.encrypt(plainText, iv: iv);
  
  // RSA 키 교환
  final parser = RSAKeyParser();
  final publicKey = parser.parse(publicKeyString);
  final encryptedKey = publicKey.encrypt(aesKey);
  ```

- **SQLCipher 통합**:
  ```dart
  // 암호화된 데이터베이스
  final db = await openDatabase(
    path,
    password: dbPassword,
    singleInstance: true,
  );
  ```

### 4. **런타임 보안**
- **안티 탬퍼링**:
  ```dart
  // 앱 서명 검증
  Future<bool> verifyAppSignature() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final signature = await getPackageSignature(packageInfo.packageName);
    return signature == expectedSignature;
  }
  ```

- **루팅/탈옥 감지**:
  ```dart
  // flutter_jailbreak_detection 사용
  final bool isJailbroken = await FlutterJailbreakDetection.jailbroken;
  final bool isDeveloperMode = await FlutterJailbreakDetection.developerMode;
  
  if (isJailbroken || isDeveloperMode) {
    // 보안 경고 및 기능 제한
  }
  ```

## 🛡️ 고급 보안 기능

### 1. **네트워크 보안 강화**
- **Certificate Transparency**:
  ```dart
  // CT 로그 검증
  dio.interceptors.add(
    CertificateTransparencyInterceptor(
      expectedSCTs: ['log1', 'log2'],
    ),
  );
  ```

- **Request Signing**:
  ```dart
  // HMAC-SHA256 서명
  final signature = Hmac(sha256, secretKey).convert(
    utf8.encode('$method$path$timestamp$body'),
  );
  headers['X-Signature'] = signature.toString();
  ```

### 2. **메모리 보호**
- **민감 데이터 제거**:
  ```dart
  // 사용 후 즉시 메모리에서 제거
  class SecureString {
    final Uint8List _data;
    
    void dispose() {
      // 메모리 덮어쓰기
      for (int i = 0; i < _data.length; i++) {
        _data[i] = 0;
      }
    }
  }
  ```

- **스크린 녹화 방지**:
  ```dart
  // iOS
  if (Platform.isIOS) {
    await platform.invokeMethod('setSecureScreen', true);
  }
  
  // Android
  if (Platform.isAndroid) {
    await FlutterWindowManager.addFlags(
      FlutterWindowManager.FLAG_SECURE,
    );
  }
  ```

### 3. **API Rate Limiting (클라이언트)**
- **로컬 Rate Limiting**:
  ```dart
  class ApiRateLimiter {
    final _requestTimes = <String, List<DateTime>>{};
    final int maxRequests;
    final Duration window;
    
    bool shouldAllowRequest(String endpoint) {
      final now = DateTime.now();
      final requests = _requestTimes[endpoint] ?? [];
      
      // 시간 윈도우 내 요청 필터링
      final recentRequests = requests.where(
        (time) => now.difference(time) < window,
      ).toList();
      
      if (recentRequests.length >= maxRequests) {
        return false;
      }
      
      _requestTimes[endpoint] = [...recentRequests, now];
      return true;
    }
  }
  ```

### 4. **보안 로깅 및 모니터링**
- **보안 이벤트 추적**:
  ```dart
  class SecurityLogger {
    static void logSecurityEvent(SecurityEvent event) {
      // 민감 정보 제거
      final sanitizedEvent = event.sanitize();
      
      // 로컬 저장 (암호화)
      _saveToSecureStorage(sanitizedEvent);
      
      // 서버 전송 (배치)
      _queueForUpload(sanitizedEvent);
    }
  }
  ```

## 🚨 보안 체크리스트 (Phase 2)

### 결제 보안
- [ ] 영수증 서버 검증
- [ ] 중복 구매 방지
- [ ] 환불 처리 보안
- [ ] 구독 상태 동기화
- [ ] 테스트 구매 필터링

### 런타임 보안
- [ ] 디버거 탐지
- [ ] 후킹 방지
- [ ] 메모리 덤프 방지
- [ ] 동적 분석 방지
- [ ] 코드 무결성 검증

### 통신 보안
- [ ] Certificate Transparency
- [ ] Public Key Pinning Backup
- [ ] Request/Response 서명
- [ ] Perfect Forward Secrecy
- [ ] TLS 1.3 강제

### 데이터 보안
- [ ] 키체인/키스토어 사용
- [ ] 하드웨어 기반 암호화
- [ ] 안전한 백업/복원
- [ ] 데이터 유출 방지
- [ ] 클립보드 보안

## 📊 보안 메트릭스

### 목표 지표
| 메트릭 | 목표 | 현재 |
|--------|------|------|
| 코드 난독화율 | 100% | - |
| API 인증 적용률 | 100% | - |
| 취약점 스캔 통과 | 100% | - |
| 보안 테스트 커버리지 | 80% | - |
| OWASP Top 10 준수 | 100% | - |

### 보안 KPI
- MTTD (Mean Time To Detect): < 1시간
- MTTR (Mean Time To Respond): < 4시간
- 월간 보안 사고: 0건
- 취약점 패치 시간: < 24시간

## 🔧 보안 도구 및 라이브러리

### 필수 패키지
```yaml
dependencies:
  # 인증
  local_auth: ^2.1.6
  flutter_secure_storage: ^9.0.0
  
  # 암호화
  encrypt: ^5.0.1
  pointycastle: ^3.7.3
  
  # 보안 검사
  flutter_jailbreak_detection: ^1.10.0
  safe_device: ^1.1.2
  
  # 네트워크
  certificate_pinning_httpclient: ^2.0.0
  dio_certificate_pinning: ^5.0.2
  
  # 결제
  in_app_purchase: ^3.1.11
  purchases_flutter: ^6.9.0

dev_dependencies:
  # 보안 분석
  flutter_lints: ^3.0.1
  very_good_analysis: ^5.1.0
```

## 🚀 배포 보안 프로세스

### 1. 사전 검증
```bash
# 정적 분석
flutter analyze --no-fatal-infos

# 의존성 검사
flutter pub audit

# 보안 테스트
flutter test test/security/
```

### 2. 빌드 보안
```bash
# Android 빌드 (R8 최적화)
flutter build appbundle \
  --release \
  --obfuscate \
  --split-debug-info=./symbols \
  --dart-define=ENVIRONMENT=production

# iOS 빌드
flutter build ios \
  --release \
  --obfuscate \
  --split-debug-info=./symbols
```

### 3. 배포 후 검증
- [ ] 보안 스캔 (MobSF)
- [ ] 침투 테스트
- [ ] 난독화 검증
- [ ] API 보안 테스트
- [ ] 결제 플로우 테스트

---

**Note**: Phase 2 보안 구현은 Fortune Flutter 앱의 상용화를 위한 필수 요구사항입니다. 모든 항목을 완료한 후 보안 감사를 수행해야 합니다.