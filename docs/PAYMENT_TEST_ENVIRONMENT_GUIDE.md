# 결제 시스템 테스트 환경 구성 가이드 💳

## 🎯 개요
Fortune 앱의 인앱 구매 기능을 테스트하기 위한 완벽한 가이드입니다.

## 📱 iOS In-App Purchase 테스트 설정

### 1. App Store Connect 제품 등록

#### 제품 생성
1. App Store Connect → 앱 선택
2. "Features" → "In-App Purchases" → "+"
3. 제품 타입 선택: "Consumable" (소모품)

#### 토큰 패키지 등록
```
Product ID: fortune_tokens_1000
Reference Name: 1000 토큰
Price: ₩1,200

Product ID: fortune_tokens_5000  
Reference Name: 5000 토큰
Price: ₩5,900

Product ID: fortune_tokens_10000
Reference Name: 10000 토큰  
Price: ₩11,000

Product ID: fortune_tokens_30000
Reference Name: 30000 토큰
Price: ₩32,000

Product ID: fortune_tokens_50000
Reference Name: 50000 토큰
Price: ₩49,000

Product ID: fortune_tokens_100000
Reference Name: 100000 토큰
Price: ₩99,000
```

### 2. Sandbox 테스트 계정 설정

#### 테스트 계정 생성
1. App Store Connect → "Users and Access"
2. "Sandbox" → "Testers" → "+"
3. 테스트 계정 정보 입력:
   ```
   Email: test@example.com
   Password: TestPassword123!
   Secret Question: 설정
   Territory: Korea
   ```

#### iPhone 설정
1. 설정 → App Store → Sandbox Account
2. 테스트 계정으로 로그인
3. 실제 Apple ID는 로그아웃하지 않음

### 3. StoreKit Configuration 파일

#### 로컬 테스트용 설정
```json
{
  "identifier": "com.beyond.fortune.storekit",
  "products": [
    {
      "id": "fortune_tokens_1000",
      "type": "Consumable",
      "displayName": "1,000 토큰",
      "description": "운세 조회용 토큰",
      "price": 1200
    },
    {
      "id": "fortune_tokens_5000",
      "type": "Consumable", 
      "displayName": "5,000 토큰",
      "description": "5% 보너스 포함",
      "price": 5900
    }
    // ... 나머지 상품
  ]
}
```

### 4. Flutter 코드 설정

#### 개발 환경 변수
```env
# .env.development
ENABLE_PAYMENT=true
USE_SANDBOX=true
PAYMENT_DEBUG=true
```

#### 테스트 코드
```dart
// payment_test_helper.dart
class PaymentTestHelper {
  static void simulatePurchase() {
    if (kDebugMode) {
      // 테스트 구매 시뮬레이션
      print('Test Purchase Initiated');
    }
  }
  
  static void printDebugInfo() {
    print('Available Products: ${_products}');
    print('Pending Transactions: ${_pendingTransactions}');
  }
}
```

## 🧪 테스트 시나리오

### 시나리오 1: 정상 구매
1. 앱 실행 → 토큰 구매 화면
2. 1,000 토큰 선택
3. Apple ID 비밀번호 입력
4. 구매 완료 확인
5. 토큰 잔액 업데이트 확인

### 시나리오 2: 구매 취소
1. 상품 선택
2. 결제 다이얼로그에서 취소
3. 에러 처리 확인
4. UI 상태 복원 확인

### 시나리오 3: 네트워크 오류
1. 비행기 모드 활성화
2. 구매 시도
3. 오류 메시지 확인
4. 네트워크 복원 후 재시도

### 시나리오 4: 구매 복원
1. 앱 재설치
2. 같은 계정으로 로그인
3. "구매 복원" 실행
4. 이전 구매 내역 확인

### 시나리오 5: 중복 구매 방지
1. 동일 상품 연속 구매 시도
2. 트랜잭션 처리 확인
3. 중복 차감 방지 확인

## 🔍 디버깅 도구

### Xcode Console
```swift
// 트랜잭션 로그 확인
SKPaymentQueue.default().transactions.forEach { transaction in
    print("Transaction: \(transaction.transactionIdentifier ?? "nil")")
    print("State: \(transaction.transactionState.rawValue)")
}
```

### Charles Proxy 설정
1. SSL Proxying 활성화
2. iOS 기기 프록시 설정
3. 인증서 신뢰 설정
4. API 호출 모니터링

### 로그 수집
```dart
// main.dart
if (kDebugMode) {
  InAppPurchase.instance.purchaseStream.listen((purchases) {
    debugPrint('Purchase Update: ${purchases.map((p) => p.productID)}');
  });
}
```

## 🛡️ 영수증 검증

### 서버 사이드 검증 플로우
1. 클라이언트: 구매 완료 → 영수증 전송
2. 서버: Apple 서버에 검증 요청
3. 서버: 검증 결과 확인
4. 서버: 토큰 지급
5. 클라이언트: UI 업데이트

### 검증 엔드포인트
```typescript
// Edge Function: payment-verify-purchase
const verifyEndpoint = isProduction 
  ? 'https://buy.itunes.apple.com/verifyReceipt'
  : 'https://sandbox.itunes.apple.com/verifyReceipt';
```

## ⚠️ 주의사항

### 1. Sandbox 환경
- 실제 결제 X, 테스트만 가능
- 가격은 실제와 다를 수 있음
- 구독은 가속화된 시간으로 진행

### 2. 테스트 계정 관리
- 실제 Apple ID 사용 금지
- 지역별 테스트 계정 필요
- 주기적으로 새 계정 생성

### 3. 프로덕션 전환
- Sandbox URL → Production URL
- 테스트 플래그 제거
- 실제 가격 확인

## 📋 체크리스트

### 개발 단계
- [ ] StoreKit Configuration 파일 생성
- [ ] 제품 ID 하드코딩 확인
- [ ] 가격 표시 로직 구현
- [ ] 구매 플로우 구현
- [ ] 영수증 검증 구현

### 테스트 단계
- [ ] Sandbox 계정 생성
- [ ] 모든 상품 구매 테스트
- [ ] 구매 복원 테스트
- [ ] 네트워크 오류 처리
- [ ] 중복 구매 방지

### 배포 준비
- [ ] Production 환경 변수 설정
- [ ] 실제 가격 확인
- [ ] 영수증 검증 URL 변경
- [ ] 디버그 코드 제거
- [ ] 에러 로깅 설정

## 🚨 일반적인 문제 해결

### "Cannot connect to iTunes Store"
```dart
// 네트워크 연결 확인
if (await _inAppPurchase.isAvailable()) {
  // 정상
} else {
  // StoreKit 사용 불가
}
```

### 상품 목록이 비어있음
1. Product ID 확인
2. App Store Connect 상태 확인
3. 계약 동의 여부 확인

### 구매 후 토큰 미지급
1. 영수증 검증 로그 확인
2. 서버 API 응답 확인
3. 트랜잭션 완료 처리 확인

## 📚 참고 자료

- [Apple Developer - StoreKit](https://developer.apple.com/storekit/)
- [Flutter In App Purchase](https://pub.dev/packages/in_app_purchase)
- [App Store Connect Guide](https://help.apple.com/app-store-connect/)

---

**중요**: 실제 사용자에게 배포하기 전에 모든 시나리오를 철저히 테스트하세요!