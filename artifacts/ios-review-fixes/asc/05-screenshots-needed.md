# ASC 스크린샷 준비 리스트

iOS 앱 스크린샷 요구 (2024-2026 기준):
- **iPhone 6.9" (iPhone 16 Pro Max)**: 1290×2796 px — 필수 3~10장
- **iPhone 6.5"** (iPhone 14 Plus): 1242×2688 또는 1284×2778 — 필수 3~10장
- **iPad 13"** (iPad Pro M4): 2064×2752 — 앱이 `supportsTablet: true` 일 때 필수

## 핵심 스크린샷 세트 (10장 권장, 앱스토어 리스팅용)

| # | 화면 | 캡션 후보 | 목적 |
|---|------|----------|------|
| 1 | Welcome carousel (첫 번째 slide) | "마음을 들여다보는 가장 따뜻한 방법" | hero — 브랜드 인식 |
| 2 | Chat 홈 (캐릭터 리스트) | "AI 캐릭터와 매일 대화하며 내 사주를 풀어봐요" | 핵심 기능 |
| 3 | 결과 카드 — hero-saju 또는 hero-tarot | "매일 새로운 운세를 카드로 받아봐요" | 결과 시각화 |
| 4 | 캐릭터 프로필 | "캐릭터마다 다른 성격, 다른 대화" | 다양성 |
| 5 | 관상 분석 결과 (face-reading) | "사진 한 장으로 관상을 분석" | 차별화 |
| 6 | 프로필/토큰 잔액 | "모든 기능을 편하게 즐겨요" | Premium hint |
| 7 | Premium paywall | "Unlimited 플랜으로 무제한 상담" | IAP |
| 8 | 만세력 카드 | "전통 만세력 기반 정통 사주" | 깊이 |
| 9 | 설정 (개인정보/이용약관) | "내 데이터는 내가 관리" | 투명성 |
| 10 | 채팅 신고/차단 메뉴 (신규) | "안전한 AI 대화 환경" | **P11 5.2.3 증거** |

---

## 리뷰어용 참고 스크린샷 (ASC에 따로 첨부 — 선택)

ASC Review Notes 하단 "Attach additional info" 또는 직접 이미지 설명 요청 시 사용.

### 📸 이전 리젝 사유 해결 증거

- **2.1 iPad Sign in**: iPad에서 "Sign in with Apple" 버튼 → 완료 후 홈(/chat) 화면 — 2-shot (tap + post-auth)
- **3.1.2 Subscription**: Paywall 전체 화면 — 구독 공시 블록 + EULA/Privacy 링크 보이도록 스크롤

### 📸 신규 UGC 기능 증거 (P11)

- **메시지 신고 플로우**: (a) AI 메시지 long-press 직후, (b) 신고 모달 전체, (c) 신고 완료 토스트
- **캐릭터 차단 플로우**: (a) 프로필 화면 "안전 도구" 섹션, (b) 확인 Alert, (c) 차단 후 빈 리스트

### 📸 의료 컴플라이언스 증거 (P10)

- **Health 결과 카드**: disclaimer 문구가 카드 하단에 보이는 전체 스크린샷

---

## 캡처 방법

### 시뮬레이터 (권장 — 빠르고 일관성)

```bash
cd /Users/injoo/Desktop/Dev/fortune/apps/mobile-rn
npx expo run:ios --device "iPhone 16 Pro Max"
# 시뮬레이터: Cmd+S → ~/Desktop 에 PNG 저장
```

iPad:
```bash
npx expo run:ios --device "iPad Pro (13-inch) (M4)"
```

### 실기기 (화질/해상도 최고)

1. iPhone: 잠금 버튼 + 볼륨↑ 동시 → 사진 앱 → AirDrop
2. iPad: 상단 버튼 + 볼륨↑ 동시

### 스크린샷 후처리

- ASC 요구 해상도 맞추기 (Sketch/Figma 캔버스 사이즈 1290×2796 등)
- 상태바 9:41 / 네트워크 만땅 / 배터리 100% (Figma overlay 또는 Status Bar Customizer)
- **개인 정보 블러 처리**: test@zpzg.com 이외 실제 계정 정보 노출 금지
- 캡션 텍스트 추가 (브랜드 톤: Pretendard, 다크 배경)

---

## Rejection-avoiding 체크리스트

- [ ] 모든 스크린샷이 **실제 앱 UI** (wireframe/mockup 금지 — 심사 시 크로스체크)
- [ ] 가격 정보가 ASC IAP 설정과 일치 (paywall 가격 표시 있다면)
- [ ] 빈 상태, 로딩 스피너만 있는 화면 금지
- [ ] 타사 브랜드 로고 노출 금지 (Google 로그인 버튼 등은 OK, 상호 연결 시 표기)
- [ ] 실제 연예인 얼굴/사진 금지 (face-reading은 자기 얼굴만)
- [ ] 개인정보/민감정보가 화면에 보이지 않도록 (특히 Health 관련)

---

## 우선순위 (2단 마감 시 최소)

**반드시 (P0)**: #2, #3, #7 — 기능 + 구매 + 결과 표현
**매우 권장 (P1)**: #1, #10 — 브랜드 + UGC 안전
**권장 (P2)**: #4~#6, #8~#9

제출에 최소 iPhone 6.5"와 iPhone 6.9"를 각각 3장 이상, iPad 13"를 3장 이상 필요.
