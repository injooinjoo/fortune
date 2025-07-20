# 📱 Fortune 앱 인앱 결제 설정 종합 가이드

> **최종 업데이트**: 2025년 7월 15일  
> **대상 플랫폼**: iOS (App Store), Android (Google Play)

## 📋 개요

Fortune 앱은 Google Play Store와 Apple App Store의 인앱 결제를 사용하여 토큰과 구독 상품을 판매합니다.

### 상품 구조
- **소모성 상품**: 토큰 패키지 (10개, 50개, 100개, 200개)
- **구독 상품**: 월간/연간 무제한 이용권

---

## 🍎 iOS 설정 (App Store Connect)

### 1. App Store Connect에서 인앱 상품 등록

1. [App Store Connect](https://appstoreconnect.apple.com) 접속
2. 앱 선택 → "기능" → "인앱 구입" 클릭
3. "+" 버튼 클릭하여 새 상품 추가

### 2. 상품 ID 및 정보 입력

#### 소모성 상품 (토큰 패키지)
| 제품 ID | 참조명 | 가격 | 설명 |
|---------|--------|------|------|
| `com.fortune.app.tokens10` | 토큰 10개 | ₩1,000 | 기본 토큰 패키지 |
| `com.fortune.app.tokens50` | 토큰 50개 | ₩4,500 | 10% 할인 |
| `com.fortune.app.tokens100` | 토큰 100개 | ₩8,000 | 20% 할인 |
| `com.fortune.app.tokens200` | 토큰 200개 | ₩14,000 | 30% 할인 |

#### 자동 갱신 구독
| 제품 ID | 참조명 | 가격 | 기간 | 혜택 |
|---------|--------|------|------|------|
| `com.fortune.app.subscription.monthly` | 월간 무제한 | ₩9,900 | 1개월 | 모든 운세 무제한 |
| `com.fortune.app.subscription.yearly` | 연간 무제한 | ₩99,000 | 1년 | 2개월 무료 혜택 |

### 3. iOS 프로젝트 설정

#### Info.plist 수정
```xml
<key>SKAdNetworkItems</key>
<array>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>cstr6suwn9.skadnetwork</string>
    </dict>
</array>
```

#### Runner.entitlements 추가
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.developer.in-app-payments</key>
    <array>
        <string>com.fortune.app.tokens10</string>
        <string>com.fortune.app.tokens50</string>
        <string>com.fortune.app.tokens100</string>
        <string>com.fortune.app.tokens200</string>
        <string>com.fortune.app.subscription.monthly</string>
        <string>com.fortune.app.subscription.yearly</string>
    </array>
</dict>
</plist>
```

### 4. 샌드박스 테스터 설정

1. App Store Connect → "사용자 및 액세스"
2. "샌드박스 테스터" 선택
3. "+" 버튼으로 새 테스터 추가
4. 테스트용 Apple ID 생성 (실제 이메일 불필요)

---

## 🤖 Android 설정 (Google Play)

### 1. Google Play Console 설정

1. [Google Play Console](https://play.google.com/console) 접속
2. 앱 선택 → **수익 창출** → **제품** → **인앱 상품**

### 2. 상품 생성

#### 소모성 상품 (토큰)
| 상품 ID | 상품명 | 가격 | 설명 |
|---------|--------|------|------|
| `com.fortune.tokens.10` | 토큰 10개 | ₩1,000 | 기본 토큰 패키지 |
| `com.fortune.tokens.50` | 토큰 50개 | ₩4,500 | 10% 할인 |
| `com.fortune.tokens.100` | 토큰 100개 | ₩8,000 | 20% 할인 |
| `com.fortune.tokens.200` | 토큰 200개 | ₩14,000 | 30% 할인 |

#### 구독 상품
| 상품 ID | 상품명 | 가격 | 청구 주기 |
|---------|--------|------|----------|
| `com.fortune.subscription.monthly` | 월간 무제한 이용권 | ₩9,900 | 매월 |
| `com.fortune.subscription.yearly` | 연간 무제한 이용권 | ₩99,000 | 매년 |

### 3. 서비스 계정 설정

1. **Google Cloud Console에서 서비스 계정 생성**
   - 프로젝트 선택 → IAM 및 관리자 → 서비스 계정
   - "서비스 계정 만들기" 클릭
   - 이름: `fortune-play-billing`

2. **Play Console API 액세스 권한 부여**
   - Google Play Console → 설정 → API 액세스
   - 서비스 계정 연결
   - 권한 부여: "재무 데이터 보기", "주문 및 구독 관리"

3. **JSON 키 다운로드**
   - 서비스 계정 → 키 → 새 키 만들기 → JSON
   - 다운로드한 파일을 안전하게 보관

### 4. AndroidManifest.xml 권한 추가
```xml
<uses-permission android:name="com.android.vending.BILLING" />
```

---

## 🔧 Flutter 앱 구현

### 1. 패키지 추가
```yaml
dependencies:
  in_app_purchase: ^3.1.11
  in_app_purchase_android: ^0.3.0
  in_app_purchase_storekit: ^0.3.6
```

### 2. 플랫폼별 상품 ID 매핑
```dart
class IAPProducts {
  static const Map<String, ProductDetails> products = {
    // iOS 상품 ID
    'com.fortune.app.tokens10': ProductDetails(
      id: 'com.fortune.app.tokens10',
      title: '토큰 10개',
      price: '₩1,000',
      tokens: 10,
    ),
    // Android 상품 ID
    'com.fortune.tokens.10': ProductDetails(
      id: 'com.fortune.tokens.10',
      title: '토큰 10개',
      price: '₩1,000',
      tokens: 10,
    ),
    // ... 나머지 상품들
  };
  
  // 플랫폼별 ID 가져오기
  static String getProductId(String baseId) {
    if (Platform.isIOS) {
      return 'com.fortune.app.$baseId';
    } else {
      return 'com.fortune.$baseId';
    }
  }
}
```

### 3. 구매 플로우 구현
```dart
class IAPService {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  
  Future<void> initializePurchase() async {
    final available = await _inAppPurchase.isAvailable();
    if (!available) {
      throw Exception('인앱 결제를 사용할 수 없습니다');
    }
    
    // 구매 리스너 설정
    _subscription = _inAppPurchase.purchaseStream.listen(
      _handlePurchaseUpdate,
      onDone: _updateStreamOnDone,
      onError: _updateStreamOnError,
    );
    
    // 미완료 구매 복원
    await _inAppPurchase.restorePurchases();
  }
  
  Future<void> buyProduct(String productId) async {
    final ProductDetailsResponse response = await _inAppPurchase
        .queryProductDetails({productId}.toSet());
        
    if (response.notFoundIDs.isNotEmpty) {
      throw Exception('상품을 찾을 수 없습니다');
    }
    
    final ProductDetails productDetails = response.productDetails.first;
    final PurchaseParam purchaseParam = PurchaseParam(
      productDetails: productDetails,
    );
    
    await _inAppPurchase.buyConsumable(
      purchaseParam: purchaseParam,
    );
  }
  
  void _handlePurchaseUpdate(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased) {
        // 서버에서 구매 검증
        _verifyPurchase(purchase);
      } else if (purchase.status == PurchaseStatus.error) {
        // 에러 처리
        _handleError(purchase.error!);
      }
      
      // 구매 완료 처리
      if (purchase.pendingCompletePurchase) {
        _inAppPurchase.completePurchase(purchase);
      }
    }
  }
}
```

---

## 🔐 서버 검증

### 1. Supabase Edge Function 구현
```typescript
// /supabase/functions/verify-purchase/index.ts
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'

serve(async (req) => {
  const { platform, purchaseToken, productId } = await req.json()
  
  if (platform === 'ios') {
    // App Store 영수증 검증
    const verified = await verifyAppStoreReceipt(purchaseToken)
    if (verified) {
      await grantTokensToUser(userId, productId)
    }
  } else if (platform === 'android') {
    // Google Play 영수증 검증
    const verified = await verifyGooglePlayPurchase(purchaseToken, productId)
    if (verified) {
      await grantTokensToUser(userId, productId)
    }
  }
  
  return new Response(JSON.stringify({ success: true }))
})
```

### 2. 영수증 검증 로직

#### iOS (App Store)
```typescript
async function verifyAppStoreReceipt(receipt: string) {
  const response = await fetch('https://buy.itunes.apple.com/verifyReceipt', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      'receipt-data': receipt,
      'password': Deno.env.get('APP_STORE_SHARED_SECRET')
    })
  })
  
  const data = await response.json()
  return data.status === 0
}
```

#### Android (Google Play)
```typescript
async function verifyGooglePlayPurchase(token: string, productId: string) {
  // Google Play Developer API 사용
  const auth = await getGoogleAuth()
  const response = await fetch(
    `https://androidpublisher.googleapis.com/androidpublisher/v3/applications/${packageName}/purchases/products/${productId}/tokens/${token}`,
    {
      headers: { 'Authorization': `Bearer ${auth.accessToken}` }
    }
  )
  
  const data = await response.json()
  return data.purchaseState === 0 // 0 = 구매됨
}
```

---

## 🧪 테스트 가이드

### iOS 테스트
1. 테스트 기기에서 App Store 로그아웃
2. 샌드박스 테스터 계정으로 로그인
3. 앱에서 구매 진행
4. 샌드박스 환경에서는 실제 결제 없이 테스트 가능

### Android 테스트
1. Google Play Console → 설정 → 라이선스 테스트
2. 테스터 이메일 추가
3. 앱을 내부 테스트 트랙에 업로드
4. 테스터에게 테스트 링크 공유

### 테스트 시나리오
- [ ] 토큰 구매 성공
- [ ] 구독 시작
- [ ] 구독 갱신
- [ ] 구독 취소
- [ ] 구매 복원
- [ ] 네트워크 오류 처리
- [ ] 중복 구매 방지

---

## 🚨 일반적인 문제 해결

### iOS 문제
1. **"Cannot connect to iTunes Store"**
   - 샌드박스 URL 확인
   - 인터넷 연결 확인
   - 샌드박스 계정 재로그인

2. **구매 후 상품이 제공되지 않음**
   - 영수증 검증 로직 확인
   - 서버 로그 확인

### Android 문제
1. **"상품을 찾을 수 없습니다"**
   - 상품 ID 확인
   - Play Console에서 상품 활성화 확인
   - 앱이 게시되었는지 확인

2. **"구매를 완료할 수 없습니다"**
   - Google Play 서비스 업데이트
   - 결제 프로필 확인

---

## 📊 수익 분석

### 주요 지표
- 일일 활성 구매자 (DAP)
- 평균 구매 가격 (ARPU)
- 구독 전환율
- 구독 유지율

### 분석 도구
- App Store Connect 판매 및 트렌드
- Google Play Console 수익 보고서
- Firebase Analytics 맞춤 이벤트

---

## 📝 체크리스트

### 출시 전 확인사항
- [ ] 모든 상품 ID가 올바르게 설정됨
- [ ] 가격이 정확하게 표시됨
- [ ] 구매 검증 로직이 작동함
- [ ] 환불 정책이 명시됨
- [ ] 개인정보 처리방침에 결제 정보 포함
- [ ] 테스트 계정으로 전체 플로우 확인

### 규정 준수
- [ ] Apple App Store Review Guidelines 준수
- [ ] Google Play 정책 준수
- [ ] 소비자 보호법 준수
- [ ] 청소년 보호 정책 준수

---

*이 가이드는 Fortune 앱의 인앱 결제 구현을 위한 종합 가이드입니다.*