# 인앱결제 설정 가이드

## 📱 iOS 설정 (App Store Connect)

### 1. App Store Connect에서 인앱 상품 등록

1. [App Store Connect](https://appstoreconnect.apple.com) 접속
2. 앱 선택 → "기능" → "인앱 구입" 클릭
3. "+" 버튼 클릭하여 새 상품 추가

### 2. 상품 ID 및 정보 입력

#### 소모성 상품 (토큰 패키지)
| 제품 ID | 참조명 | 가격 |
|---------|--------|------|
| `com.fortune.app.tokens10` | 토큰 10개 | ₩1,000 |
| `com.fortune.app.tokens50` | 토큰 50개 | ₩4,500 |
| `com.fortune.app.tokens100` | 토큰 100개 | ₩8,000 |
| `com.fortune.app.tokens200` | 토큰 200개 | ₩14,000 |

#### 자동 갱신 구독
| 제품 ID | 참조명 | 가격 | 기간 |
|---------|--------|------|------|
| `com.fortune.app.subscription.monthly` | 월간 무제한 | ₩9,900 | 1개월 |
| `com.fortune.app.subscription.yearly` | 연간 무제한 | ₩99,000 | 1년 |

### 3. iOS 프로젝트 설정

#### Info.plist 수정
```xml
<!-- 이미 있는 경우 추가하지 않음 -->
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

### 4. 테스트 계정 설정
1. App Store Connect → "사용자 및 액세스" → "샌드박스 테스터"
2. 새 테스터 추가 (테스트용 이메일 필요)
3. 기기에서 설정 → iTunes 및 App Store → 샌드박스 계정 로그인

---

## 🤖 Android 설정 (Google Play Console)

### 1. Google Play Console에서 인앱 상품 등록

1. [Google Play Console](https://play.google.com/console) 접속
2. 앱 선택 → "수익 창출" → "제품" → "인앱 상품"
3. "상품 만들기" 클릭

### 2. 상품 ID 및 정보 입력

**중요**: Android는 iOS와 동일한 제품 ID 사용

#### 관리형 제품 (토큰 패키지)
- `com.fortune.app.tokens10`
- `com.fortune.app.tokens50`
- `com.fortune.app.tokens100`
- `com.fortune.app.tokens200`

#### 구독
- `com.fortune.app.subscription.monthly`
- `com.fortune.app.subscription.yearly`

### 3. Android 프로젝트 설정

#### android/app/build.gradle
```gradle
dependencies {
    // 이미 추가되어 있음 (in_app_purchase 패키지가 자동으로 처리)
}
```

#### AndroidManifest.xml
```xml
<uses-permission android:name="com.android.vending.BILLING" />
<!-- 이미 추가되어 있을 가능성 높음 -->
```

### 4. 서명된 APK 업로드
- 인앱결제 테스트를 위해서는 서명된 APK를 업로드해야 함
- 내부 테스트 트랙에 업로드 권장

### 5. 테스트 계정 설정
1. Google Play Console → "설정" → "라이선스 테스트"
2. 테스터 이메일 추가
3. 테스트 기기에서 해당 Google 계정으로 로그인

---

## 🧪 테스트 방법

### iOS 테스트
1. 실제 기기 사용 (시뮬레이터 X)
2. 샌드박스 계정으로 로그인
3. 앱에서 구매 시도
4. 샌드박스 환경임을 알리는 팝업 확인

### Android 테스트
1. 테스트 계정으로 로그인된 기기 사용
2. 앱이 Google Play Console에 업로드되어 있어야 함
3. 테스트 구매 시 "테스트 카드"로 결제 가능

---

## 🔧 백엔드 설정

### 1. 영수증 검증 API 구현

```typescript
// /api/payment/verify-purchase
export async function POST(req: Request) {
  const { productId, purchaseToken, platform } = await req.json();
  
  if (platform === 'ios') {
    // Apple 영수증 검증
    const verifyUrl = process.env.NODE_ENV === 'production'
      ? 'https://buy.itunes.apple.com/verifyReceipt'
      : 'https://sandbox.itunes.apple.com/verifyReceipt';
    
    // 검증 로직
  } else if (platform === 'android') {
    // Google Play 영수증 검증
    // Google Play Developer API 사용
  }
  
  // 검증 성공 시 토큰 추가 또는 구독 상태 업데이트
}
```

### 2. 구독 상태 관리
- 구독 만료 날짜 추적
- 자동 갱신 처리
- 구독 취소 처리

### 3. Webhook 설정
- Apple: App Store Server Notifications
- Google: Real-time Developer Notifications

---

## 📋 체크리스트

### iOS
- [ ] App Store Connect에 상품 등록
- [ ] 상품 상태가 "판매 준비 완료"인지 확인
- [ ] 계약, 세금 및 은행 정보 입력 완료
- [ ] 샌드박스 테스터 계정 생성
- [ ] 실제 기기에서 테스트

### Android
- [ ] Google Play Console에 상품 등록
- [ ] 상품 활성화 상태 확인
- [ ] 판매자 계정 설정 완료
- [ ] 서명된 APK 업로드
- [ ] 라이선스 테스터 추가
- [ ] 실제 기기에서 테스트

### 백엔드
- [ ] 영수증 검증 API 구현
- [ ] 토큰 추가 API 구현
- [ ] 구독 상태 관리 구현
- [ ] Webhook 처리 구현

---

## 🚨 주의사항

1. **상품 ID는 변경 불가**: 한 번 생성한 상품 ID는 변경할 수 없으므로 신중히 설정
2. **가격 티어**: iOS는 가격 티어 시스템, Android는 직접 가격 입력
3. **환율 차이**: 국가별로 환율에 따른 가격 차이 고려
4. **테스트 환경**: 실제 결제가 되지 않도록 항상 테스트 환경에서 진행
5. **구독 그룹**: iOS에서는 구독을 그룹으로 관리 (업그레이드/다운그레이드 가능)

---

## 📞 지원

- [Apple Developer - In-App Purchase](https://developer.apple.com/in-app-purchase/)
- [Google Play - In-app products](https://support.google.com/googleplay/android-developer/answer/1153481)
- [Flutter in_app_purchase 패키지](https://pub.dev/packages/in_app_purchase)