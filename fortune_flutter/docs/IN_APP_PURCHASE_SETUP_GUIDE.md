# 📱 Flutter Fortune 인앱 결제 설정 가이드

## 📋 개요

Fortune Flutter 앱은 Google Play Store와 Apple App Store의 인앱 결제를 사용하여 토큰과 구독을 판매합니다.

## 🤖 Google Play 인앱 결제 설정

### 1. Google Play Console 설정

1. [Google Play Console](https://play.google.com/console) 접속
2. 앱 선택 → **수익 창출** → **제품** → **인앱 상품**

### 2. 상품 생성

#### 소모성 상품 (토큰)
```
상품 ID: com.fortune.tokens.10
상품명: 토큰 10개
가격: ₩1,000

상품 ID: com.fortune.tokens.50
상품명: 토큰 50개
가격: ₩4,500

상품 ID: com.fortune.tokens.100
상품명: 토큰 100개
가격: ₩8,000

상품 ID: com.fortune.tokens.200
상품명: 토큰 200개
가격: ₩14,000
```

#### 구독 상품
```
상품 ID: com.fortune.subscription.monthly
상품명: 월간 무제한 이용권
가격: ₩9,900/월

상품 ID: com.fortune.subscription.yearly
상품명: 연간 무제한 이용권
가격: ₩99,000/년
```

### 3. 서비스 계정 설정

1. Google Cloud Console에서 서비스 계정 생성
2. Play Console API 액세스 권한 부여
3. JSON 키 다운로드
4. 백엔드 서버에 키 파일 저장

### 4. Android 앱 설정

`android/app/build.gradle`:
```gradle
dependencies {
    implementation 'com.android.billingclient:billing:6.0.0'
}
```

## 🍎 Apple App Store 인앱 결제 설정

### 1. App Store Connect 설정

1. [App Store Connect](https://appstoreconnect.apple.com) 접속
2. 앱 선택 → **기능** → **인앱 구입**

### 2. 상품 생성

#### 소모성 상품 (토큰)
```
제품 ID: com.fortune.tokens.10
참조명: 토큰 10개
가격: Tier 1 (₩1,200)

제품 ID: com.fortune.tokens.50
참조명: 토큰 50개
가격: Tier 5 (₩5,900)

제품 ID: com.fortune.tokens.100
참조명: 토큰 100개
가격: Tier 10 (₩11,000)

제품 ID: com.fortune.tokens.200
참조명: 토큰 200개
가격: Tier 20 (₩22,000)
```

#### 자동 갱신 구독
```
제품 ID: com.fortune.subscription.monthly
참조명: 월간 무제한 이용권
가격: Tier 10 (₩11,000/월)

제품 ID: com.fortune.subscription.yearly
참조명: 연간 무제한 이용권
가격: Tier 60 (₩119,000/년)
```

### 3. iOS 앱 설정

1. Xcode에서 프로젝트 열기
2. **Signing & Capabilities** → **+ Capability** → **In-App Purchase** 추가
3. `ios/Runner/Info.plist`에 추가:
```xml
<key>SKAdNetworkItems</key>
<array>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>cstr6suwn9.skadnetwork</string>
    </dict>
</array>
```

### 4. App Store 서버 알림 설정

1. App Store Connect → 앱 정보 → **App Store 서버 알림**
2. URL 입력: `https://api.fortune.com/webhooks/apple/subscription`
3. 버전: V2 선택

## 🔧 Flutter 앱 구현

### 1. 패키지 설치

```bash
flutter pub add in_app_purchase
```

### 2. 초기화 코드

```dart
// main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 인앱 결제 초기화
  final InAppPurchaseService purchaseService = InAppPurchaseService();
  await purchaseService.initialize();
  
  runApp(MyApp());
}
```

### 3. 상품 표시

```dart
// 상품 목록 로드
await _purchaseService.loadProducts();
final products = _purchaseService.getProducts();

// UI에 표시
for (final product in products) {
  print('${product.title}: ${product.price}');
}
```

### 4. 구매 처리

```dart
// 구매 시작
await _purchaseService.purchaseProduct(productId);

// 구매 결과는 자동으로 처리됨 (InAppPurchaseService 내부)
```

## 🔐 서버 검증

### 1. Google Play 영수증 검증

백엔드 API: `/api/payment/verify-purchase`

```javascript
// Google Play 검증
const { google } = require('googleapis');

async function verifyGooglePurchase(purchaseToken, productId) {
  const auth = new google.auth.GoogleAuth({
    keyFile: 'path/to/service-account-key.json',
    scopes: ['https://www.googleapis.com/auth/androidpublisher'],
  });
  
  const androidPublisher = google.androidpublisher({
    version: 'v3',
    auth,
  });
  
  const res = await androidPublisher.purchases.products.get({
    packageName: 'com.fortune.fortune_flutter',
    productId,
    token: purchaseToken,
  });
  
  return res.data.purchaseState === 0; // 0 = purchased
}
```

### 2. App Store 영수증 검증

```javascript
// App Store 검증
async function verifyApplePurchase(receiptData) {
  const response = await fetch('https://buy.itunes.apple.com/verifyReceipt', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      'receipt-data': receiptData,
      'password': process.env.APPLE_SHARED_SECRET,
      'exclude-old-transactions': true,
    }),
  });
  
  const data = await response.json();
  return data.status === 0; // 0 = valid receipt
}
```

## 🧪 테스트

### Google Play 테스트

1. **내부 테스트 트랙**에 앱 업로드
2. 테스터 이메일 추가
3. 테스트 계정으로 구매 테스트

### Apple 테스트

1. **TestFlight**에 앱 업로드
2. Sandbox 테스터 계정 생성
3. 테스트 기기에서 Sandbox 계정으로 로그인
4. 구매 테스트

### 테스트 시나리오

- [ ] 토큰 구매 성공
- [ ] 구매 취소
- [ ] 구매 복원
- [ ] 구독 시작
- [ ] 구독 갱신
- [ ] 구독 취소
- [ ] 네트워크 오류 처리
- [ ] 중복 구매 방지

## ⚠️ 주의사항

1. **상품 ID는 변경 불가**
   - 한 번 생성한 상품 ID는 변경할 수 없음
   - 신중하게 네이밍 규칙 설정

2. **가격 정책**
   - Apple은 지역별 고정 가격 티어 사용
   - Google은 지역별 가격 자동 조정 가능

3. **심사 고려사항**
   - 모든 인앱 상품 설명 필요
   - 스크린샷 준비
   - 구독 약관 페이지 필수

4. **환불 정책**
   - 플랫폼별 환불 정책 숙지
   - 서버에서 환불 상태 추적

## 📊 분석 및 모니터링

### 이벤트 추적
```dart
// 구매 시작
Analytics.logEvent('begin_checkout', {
  'currency': 'KRW',
  'value': product.price,
  'items': [productId],
});

// 구매 완료
Analytics.logEvent('purchase', {
  'transaction_id': purchaseDetails.purchaseID,
  'currency': 'KRW',
  'value': amount,
  'items': [productId],
});
```

### 대시보드 확인
- Google Play Console → 재무 보고서
- App Store Connect → 판매 및 추세
- 자체 관리자 대시보드

## 🚀 프로덕션 체크리스트

- [ ] 모든 상품 ID가 코드와 일치하는지 확인
- [ ] 서버 검증 API 구현 완료
- [ ] 구매 복원 기능 테스트
- [ ] 환불 처리 로직 구현
- [ ] 구독 상태 동기화
- [ ] 에러 로깅 설정
- [ ] 분석 이벤트 설정
- [ ] 고객 지원 가이드 작성