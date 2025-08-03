# 💳 Flutter Fortune 결제 시스템 설정 가이드

## 📋 개요

Fortune Flutter 앱의 결제 시스템은 **Stripe**를 기본으로 사용하며, 한국 사용자를 위해 **TossPay**도 지원할 예정입니다.

## 🔧 Stripe 결제 설정

### 1. 환경 변수 설정

`.env` 파일에 다음 키들을 설정하세요:

```env
# Stripe 키 (테스트)
STRIPE_PUBLISHABLE_KEY=pk_test_xxxxx
STRIPE_SECRET_KEY=sk_test_xxxxx

# Stripe 키 (프로덕션)
STRIPE_PUBLISHABLE_KEY=pk_live_xxxxx
STRIPE_SECRET_KEY=sk_live_xxxxx
```

### 2. 백엔드 API 설정

백엔드 API가 실행 중이어야 합니다:

```bash
# 웹 프로젝트 루트에서
npm run dev
```

Flutter 앱의 `.env` 파일에서 API URL 설정:

```env
# 개발 환경
API_BASE_URL=http://localhost:3000

# 프로덕션 환경
PROD_API_BASE_URL=https://api.fortune.com
```

### 3. 플랫폼별 설정

#### iOS
1. `ios/Runner/Info.plist`에 다음 추가:
```xml
<key>NSCameraUsageDescription</key>
<string>카드 스캔을 위해 카메라 접근이 필요합니다.</string>
```

2. Apple Pay 설정 (선택사항):
- Xcode에서 Capabilities → Apple Pay 활성화
- Merchant ID 생성 및 설정

#### Android
1. `android/app/src/main/AndroidManifest.xml`에 인터넷 권한 확인:
```xml
<uses-permission android:name="android.permission.INTERNET" />
```

2. ProGuard 규칙 추가 (`android/app/proguard-rules.pro`):
```
-keep class com.stripe.android.** { *; }
```

## 💰 결제 플로우

### 1. 토큰 패키지 구매

```dart
// 사용자가 토큰 패키지 선택
final package = TokenPackage(
  id: 'token_50',
  name: '스탠다드',
  tokens: 50,
  price: 4500,
);

// Stripe 결제 처리
final result = await _stripeService.processPayment(
  amount: package.price,
  currency: 'krw',
  customerEmail: user.email,
  metadata: {
    'userId': user.id,
    'packageId': package.id,
    'tokens': package.tokens,
  },
);
```

### 2. 구독 결제

```dart
// 무제한 구독
final result = await _stripeService.processSubscription(
  priceId: 'subscription_monthly',
  customerEmail: user.email,
  metadata: {
    'userId': user.id,
  },
);
```

## 🔐 보안 주의사항

1. **절대 하지 말아야 할 것**:
   - Secret Key를 클라이언트 코드에 포함 ❌
   - 결제 금액을 클라이언트에서 계산 ❌
   - 토큰 추가를 클라이언트에서 직접 처리 ❌

2. **반드시 해야 할 것**:
   - 모든 결제는 백엔드 API를 통해 처리 ✅
   - Webhook으로 결제 확인 ✅
   - 결제 메타데이터에 사용자 정보 포함 ✅

## 🧪 테스트

### 테스트 카드 번호
- 성공: `4242 4242 4242 4242`
- 실패: `4000 0000 0000 0002`
- 3D Secure 필요: `4000 0025 0000 3155`

### 테스트 시나리오
1. 토큰 구매 성공
2. 결제 취소
3. 카드 거절
4. 네트워크 오류
5. 구독 시작/취소

## 📊 결제 모니터링

### Stripe Dashboard
- https://dashboard.stripe.com
- 결제 내역 확인
- 고객 정보 관리
- 구독 상태 모니터링

### 로컬 로그
```dart
// lib/core/utils/logger.dart
Logger.info('결제 성공', {
  'paymentIntentId': result.paymentIntentId,
  'amount': package.price,
  'tokens': package.tokens,
});
```

## 🚀 프로덕션 체크리스트

- [ ] 프로덕션 Stripe 키 설정
- [ ] HTTPS API 엔드포인트 사용
- [ ] Webhook 엔드포인트 설정
- [ ] 결제 실패 시 재시도 로직
- [ ] 환불 정책 구현
- [ ] 결제 영수증 이메일 발송
- [ ] 구독 갱신 알림
- [ ] 결제 분석 이벤트 추가

## 🆘 문제 해결

### "결제 준비에 실패했습니다" 오류
1. 백엔드 API가 실행 중인지 확인
2. API_BASE_URL이 올바른지 확인
3. Stripe 키가 올바른지 확인

### "네트워크 오류" 발생
1. 인터넷 연결 확인
2. API 서버 상태 확인
3. CORS 설정 확인 (웹 버전)

### 결제 후 토큰이 추가되지 않음
1. Webhook 설정 확인
2. 백엔드 로그 확인
3. Supabase 연결 상태 확인

## 📚 참고 자료

- [Stripe Flutter 공식 문서](https://docs.stripe.com/payments/accept-a-payment?platform=flutter)
- [Flutter Stripe 패키지](https://pub.dev/packages/flutter_stripe)
- [Stripe 테스트 가이드](https://docs.stripe.com/testing)