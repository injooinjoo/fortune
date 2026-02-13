# App Store Connect 인앱 구매 상품 설계서

## 📋 개요

| 항목 | 값 |
|------|---|
| 앱 이름 | Fortune |
| Bundle ID | `com.beyond.fortune` |
| 총 상품 수 | 6개 (구독 2개 + 소모성 4개) |
| 작성일 | 2024년 |

---

## 🔄 자동 갱신 구독 (Auto-Renewable Subscriptions)

### 구독 그룹 설정

| 항목 | 값 |
|------|---|
| 그룹 이름 | Fortune Premium |
| 그룹 참조 이름 | fortune_premium_group |

---

### 상품 1: Pro 구독 (기존 월간 → Pro)

| 항목 | 값 |
|------|---|
| **참조 이름** | Fortune Pro Subscription |
| **상품 ID** | `com.beyond.fortune.subscription.monthly` |
| **유형** | 자동 갱신 구독 (Auto-Renewable Subscription) |
| **구독 기간** | 1개월 |
| **그룹 내 순서** | 1 (Level 1 - Pro) |

#### 가격표

| 국가 | 가격 | App Store Tier |
|------|------|----------------|
| 한국 | ₩4,500 | Tier 4 |
| 미국 | $3.99 | Tier 4 |
| 일본 | ¥600 | Tier 4 |

#### 현지화 정보 (한국어)

| 항목 | 내용 |
|------|------|
| 표시 이름 | Pro 구독 |
| 설명 | 매월 30,000개의 토큰을 자동 충전받고 프리미엄 운세를 이용하세요. 언제든 해지 가능합니다. |

#### 현지화 정보 (영어)

| 항목 | 내용 |
|------|------|
| 표시 이름 | Pro Subscription |
| 설명 | Get 30,000 tokens recharged monthly and access premium fortune readings. Cancel anytime. |

---

### 상품 2: Max 구독 (월간)

| 항목 | 값 |
|------|---|
| **참조 이름** | Fortune Max Subscription |
| **상품 ID** | `com.beyond.fortune.subscription.max` |
| **유형** | 자동 갱신 구독 (Auto-Renewable Subscription) |
| **구독 기간** | 1개월 |
| **그룹 내 순서** | 2 (Level 2 - Max) |

#### 가격표

| 국가 | 가격 | App Store Tier |
|------|------|----------------|
| 한국 | ₩12,900 | Tier 13 |
| 미국 | $12.99 | Tier 13 |
| 일본 | ¥2,000 | Tier 20 |

#### 현지화 정보 (한국어)

| 항목 | 내용 |
|------|------|
| 표시 이름 | Max 구독 |
| 설명 | 매월 100,000개의 토큰을 자동 충전받고 모든 기능을 무제한으로 이용하세요. 언제든 해지 가능합니다. |

#### 현지화 정보 (영어)

| 항목 | 내용 |
|------|------|
| 표시 이름 | Max Subscription |
| 설명 | Get 100,000 tokens recharged monthly and unlimited access to all features. Cancel anytime. |

---

## 💰 소모성 상품 (Consumables)

### 상품 3: 토큰 10개

| 항목 | 값 |
|------|---|
| **참조 이름** | Fortune Tokens 10 |
| **상품 ID** | `com.beyond.fortune.tokens10` |
| **유형** | 소모성 (Consumable) |

#### 가격표

| 국가 | 가격 | App Store Tier |
|------|------|----------------|
| 한국 | ₩1,100 | Tier 1 |
| 미국 | $0.99 | Tier 1 |
| 일본 | ¥160 | Tier 1 |

#### 현지화 정보 (한국어)

| 항목 | 내용 |
|------|------|
| 표시 이름 | 토큰 10개 |
| 설명 | 10개의 토큰을 충전하여 운세를 확인하세요. 기본 운세 10회를 이용할 수 있습니다. |

#### 현지화 정보 (영어)

| 항목 | 내용 |
|------|------|
| 표시 이름 | 10 Tokens |
| 설명 | Purchase 10 tokens to check your fortune. Use for up to 10 basic fortune readings. |

---

### 상품 4: 토큰 50개

| 항목 | 값 |
|------|---|
| **참조 이름** | Fortune Tokens 50 |
| **상품 ID** | `com.beyond.fortune.tokens50` |
| **유형** | 소모성 (Consumable) |

#### 가격표

| 국가 | 가격 | App Store Tier | 보너스 |
|------|------|----------------|--------|
| 한국 | ₩4,400 | Tier 4 | 10% 보너스 |
| 미국 | $3.99 | Tier 4 | 10% 보너스 |
| 일본 | ¥600 | Tier 4 | 10% 보너스 |

#### 현지화 정보 (한국어)

| 항목 | 내용 |
|------|------|
| 표시 이름 | 토큰 50개 |
| 설명 | 50개의 토큰을 충전하세요. 10% 보너스 토큰이 포함되어 있습니다. |

#### 현지화 정보 (영어)

| 항목 | 내용 |
|------|------|
| 표시 이름 | 50 Tokens |
| 설명 | Purchase 50 tokens with 10% bonus included. Great value for regular users. |

---

### 상품 5: 토큰 100개

| 항목 | 값 |
|------|---|
| **참조 이름** | Fortune Tokens 100 |
| **상품 ID** | `com.beyond.fortune.tokens100` |
| **유형** | 소모성 (Consumable) |

#### 가격표

| 국가 | 가격 | App Store Tier | 보너스 |
|------|------|----------------|--------|
| 한국 | ₩7,700 | Tier 7 | 20% 보너스 |
| 미국 | $6.99 | Tier 7 | 20% 보너스 |
| 일본 | ¥1,100 | Tier 11 | 20% 보너스 |

#### 현지화 정보 (한국어)

| 항목 | 내용 |
|------|------|
| 표시 이름 | 토큰 100개 |
| 설명 | 100개의 토큰을 충전하세요. 20% 보너스 토큰이 포함되어 더욱 알뜰합니다. |

#### 현지화 정보 (영어)

| 항목 | 내용 |
|------|------|
| 표시 이름 | 100 Tokens |
| 설명 | Purchase 100 tokens with 20% bonus included. Best value for enthusiasts. |

---

### 상품 6: 토큰 200개

| 항목 | 값 |
|------|---|
| **참조 이름** | Fortune Tokens 200 |
| **상품 ID** | `com.beyond.fortune.tokens200` |
| **유형** | 소모성 (Consumable) |

#### 가격표

| 국가 | 가격 | App Store Tier | 보너스 |
|------|------|----------------|--------|
| 한국 | ₩13,000 | Tier 13 | 30% 보너스 |
| 미국 | $12.99 | Tier 13 | 30% 보너스 |
| 일본 | ¥2,000 | Tier 20 | 30% 보너스 |

#### 현지화 정보 (한국어)

| 항목 | 내용 |
|------|------|
| 표시 이름 | 토큰 200개 |
| 설명 | 200개의 토큰을 충전하세요. 30% 보너스 토큰이 포함된 최고의 가성비 패키지입니다. |

#### 현지화 정보 (영어)

| 항목 | 내용 |
|------|------|
| 표시 이름 | 200 Tokens |
| 설명 | Purchase 200 tokens with 30% bonus included. Ultimate value package for power users. |

---

## 📸 스크린샷 요구사항

### 구독 상품 스크린샷

- **크기**: 640 x 920 픽셀 (최소)
- **형식**: PNG 또는 JPEG
- **내용**: 구독 페이지 UI 스크린샷
  - 프리미엄 혜택 표시
  - 가격 정보 명시
  - 무제한 운세, 광고 제거 등 혜택 나열

### 소모성 상품 스크린샷

- **크기**: 640 x 920 픽셀 (최소)
- **형식**: PNG 또는 JPEG
- **내용**: 토큰 구매 페이지 UI 스크린샷
  - 토큰 패키지 목록
  - 각 패키지별 가격 및 보너스 표시

---

## 🔍 심사 정보 (Review Information)

### 심사 노트

```
This app offers both subscription and consumable in-app purchases:

1. SUBSCRIPTIONS (Auto-Renewable, Monthly):
   - Pro Subscription (₩4,500/month): 30,000 tokens/month + premium features
   - Max Subscription (₩12,900/month): 100,000 tokens/month + all features

2. CONSUMABLES (Tokens):
   - Tokens are used to access individual fortune readings
   - Token packages: 10, 50, 100, 200 tokens with bonus tiers

Subscription Management:
- Users can manage subscriptions via iOS Settings > Apple ID > Subscriptions
- Clear cancellation instructions are provided in the app

Demo Account (if needed):
- No login required for testing
- In-app purchases can be tested with Sandbox accounts
```

---

## ⚙️ 코드 업데이트 필요사항

현재 `in_app_products.dart`의 가격이 App Store Tier와 다릅니다. App Store Connect 설정 후 실제 가격은 Store에서 가져오므로 코드 수정은 선택사항입니다.

### 가격 비교

| 상품 | 코드 가격 | App Store Tier 가격 (KRW) |
|------|----------|--------------------------|
| tokens10 | ₩1,000 | ₩1,100 (Tier 1) |
| tokens50 | ₩4,500 | ₩4,400 (Tier 4) |
| tokens100 | ₩8,000 | ₩7,700 (Tier 7) |
| tokens200 | ₩14,000 | ₩13,000 (Tier 13) |
| Pro (monthly) | ₩4,500 | ₩4,500 (Tier 4) ✅ |
| Max (monthly) | ₩12,900 | ₩12,900 (Tier 13) ✅ |

> **참고**: 실제 가격은 `ProductDetails.price`에서 가져오므로 UI에서는 Store 가격이 표시됩니다.

---

## 📋 App Store Connect 설정 체크리스트

### 1단계: 계약 및 세금/뱅킹 설정
- [ ] 유료 앱 계약 동의
- [ ] 세금 정보 입력
- [ ] 뱅킹 정보 입력

### 2단계: 구독 그룹 생성
- [ ] "Fortune Premium" 구독 그룹 생성
- [ ] 그룹 참조 이름: `fortune_premium_group`

### 3단계: 구독 상품 추가
- [ ] Pro Subscription 추가
  - [ ] 상품 ID: `com.beyond.fortune.subscription.monthly`
  - [ ] 가격 설정 (Tier 4 - ₩4,500)
  - [ ] 현지화 정보 입력 (한국어, 영어)
  - [ ] 스크린샷 업로드
- [x] Max Subscription 추가
  - [x] 상품 ID: `com.beyond.fortune.subscription.max`
  - [x] 가격 설정 (Tier 13 - ₩12,900)
  - [x] 현지화 정보 입력 (한국어)
  - [ ] 스크린샷 업로드

### 4단계: 소모성 상품 추가
- [ ] Tokens 10 추가
  - [ ] 상품 ID: `com.beyond.fortune.tokens10`
  - [ ] 유형: 소모성 (Consumable)
  - [ ] 가격 설정 (Tier 1)
  - [ ] 현지화 정보 입력
- [ ] Tokens 50 추가
  - [ ] 상품 ID: `com.beyond.fortune.tokens50`
  - [ ] 유형: 소모성 (Consumable)
  - [ ] 가격 설정 (Tier 4)
  - [ ] 현지화 정보 입력
- [ ] Tokens 100 추가
  - [ ] 상품 ID: `com.beyond.fortune.tokens100`
  - [ ] 유형: 소모성 (Consumable)
  - [ ] 가격 설정 (Tier 7)
  - [ ] 현지화 정보 입력
- [ ] Tokens 200 추가
  - [ ] 상품 ID: `com.beyond.fortune.tokens200`
  - [ ] 유형: 소모성 (Consumable)
  - [ ] 가격 설정 (Tier 13)
  - [ ] 현지화 정보 입력

### 5단계: 심사 제출
- [ ] 모든 상품 "심사 대기 중" 상태 확인
- [ ] 앱 버전과 함께 심사 제출

---

## 🧪 Sandbox 테스트

### 테스트 계정 생성
1. App Store Connect > 사용자 및 액세스 > Sandbox 테스터
2. 새 테스터 추가
3. 테스트용 이메일 (실제 Apple ID와 다른 이메일)

### 테스트 절차
1. 기기에서 기존 Apple ID 로그아웃
2. 앱에서 구매 시도
3. Sandbox 계정으로 로그인 프롬프트 표시
4. 테스트 완료

### 주의사항
- Sandbox에서 구독은 짧은 기간으로 테스트됨
  - 1개월 → 5분
  - 1년 → 1시간
- 최대 6회 자동 갱신 후 중단

---

## 📞 지원 연락처

문의사항이 있으시면 아래로 연락해주세요:
- 개발팀: dev@beyond.fortune
- Apple Developer 지원: https://developer.apple.com/contact/
